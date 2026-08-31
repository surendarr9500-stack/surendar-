import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../offline/connectivity_service.dart';
import '../security/secure_storage_service.dart';
import '../../data/datasources/local/app_database.dart';

enum SyncState {
  idle,
  syncing,
  completed,
  failed,
}

class SyncEngine {
  final AppDatabase _db;
  final Dio _dio;
  final SecureStorageService _secureStorage;
  final ConnectivityService _connectivity;
  final Logger _logger;
  
  final StreamController<SyncState> _stateController = StreamController.broadcast();
  Stream<SyncState> get syncStateStream => _stateController.stream;
  
  SyncState _currentState = SyncState.idle;
  SyncState get currentState => _currentState;

  SyncEngine({
    required AppDatabase db,
    required Dio dio,
    required SecureStorageService secureStorage,
    required ConnectivityService connectivity,
    Logger? logger,
  })  : _db = db,
        _dio = dio,
        _secureStorage = secureStorage,
        _connectivity = connectivity,
        _logger = logger ?? Logger();

  Future<void> initialize() async {
    // Listen to connectivity restored
    _connectivity.connectivityStream.listen((status) async {
      if (status == ConnectivityStatus.online) {
        _logger.i('Connectivity restored, triggering sync');
        await sync();
      }
    });
    
    // Reset any stuck SYNCING to PENDING on startup (app killed during sync)
    await _resetStuckSyncing();
  }

  Future<void> _resetStuckSyncing() async {
    final stuck = await _db.syncQueueDao.getByStatus(AppConstants.syncSyncing);
    for (final tx in stuck) {
      await _db.syncQueueDao.updateStatus(tx.transactionId, AppConstants.syncPending);
    }
    if (stuck.isNotEmpty) {
      _logger.w('Reset ${stuck.length} stuck SYNCING transactions to PENDING');
    }
  }

  Future<void> enqueue({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
    int version = 1,
  }) async {
    final deviceId = await _secureStorage.read(AppConstants.keyDeviceId) ?? 'unknown_device';
    final userId = await _secureStorage.read(AppConstants.keyUserId) ?? 'unknown_user';
    
    final transaction = SyncQueueCompanion.insert(
      transactionId: const Uuid().v4(),
      deviceId: deviceId,
      userId: userId,
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      payload: jsonEncode(payload),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncStatus: AppConstants.syncPending,
      retryCount: 0,
      version: version,
    );
    
    await _db.syncQueueDao.insertTransaction(transaction);
    _logger.i('Enqueued $operation for $entityType:$entityId');
    
    // Try immediate sync if online
    if (_connectivity.currentStatus == ConnectivityStatus.online) {
      unawaited(sync());
    }
  }

  Future<void> sync() async {
    if (_currentState == SyncState.syncing) {
      _logger.w('Sync already in progress, skipping');
      return;
    }
    
    final isOnline = await _connectivity.isOnline;
    if (!isOnline) {
      _logger.w('Cannot sync, offline');
      return;
    }
    
    _updateState(SyncState.syncing);
    _logger.i('Starting sync process');
    
    try {
      await _uploadPending();
      await _downloadServerChanges();
      _updateState(SyncState.completed);
      _logger.i('Sync completed successfully');
      
      // Update last sync time
      await _secureStorage.saveLastSyncAt(DateTime.now().toIso8601String());
      await _secureStorage.saveLastOnlineAt(DateTime.now());
      
      // Log audit
      await _db.auditLogsDao.insertLog(
        AuditLogsCompanion.insert(
          id: const Uuid().v4(),
          timestamp: DateTime.now(),
          userId: await _secureStorage.read(AppConstants.keyUserId) ?? 'unknown',
          deviceId: await _secureStorage.read(AppConstants.keyDeviceId) ?? 'unknown',
          event: AppConstants.auditSyncCompleted,
          entityType: 'sync',
          entityId: 'batch',
          result: 'SUCCESS',
          metadata: jsonEncode({'pending_count': 0}),
          syncStatus: AppConstants.syncPending,
        ),
      );
    } catch (e, stack) {
      _logger.e('Sync failed', error: e, stackTrace: stack);
      _updateState(SyncState.failed);
      
      await _db.auditLogsDao.insertLog(
        AuditLogsCompanion.insert(
          id: const Uuid().v4(),
          timestamp: DateTime.now(),
          userId: await _secureStorage.read(AppConstants.keyUserId) ?? 'unknown',
          deviceId: await _secureStorage.read(AppConstants.keyDeviceId) ?? 'unknown',
          event: AppConstants.auditSyncFailed,
          entityType: 'sync',
          entityId: 'batch',
          result: 'FAILURE',
          metadata: jsonEncode({'error': e.toString()}),
          syncStatus: AppConstants.syncPending,
        ),
      );
    }
  }

  Future<void> _uploadPending() async {
    final pending = await _db.syncQueueDao.getPending(limit: AppConfig.syncBatchSize);
    if (pending.isEmpty) {
      _logger.i('No pending transactions to upload');
      return;
    }
    
    _logger.i('Uploading ${pending.length} pending transactions');
    
    // Mark as SYNCING
    for (final tx in pending) {
      await _db.syncQueueDao.updateStatus(tx.transactionId, AppConstants.syncSyncing);
    }
    
    try {
      final accessToken = await _secureStorage.read(AppConstants.keyAccessToken);
      if (accessToken == null) throw Exception('No access token');
      
      final deviceId = await _secureStorage.read(AppConstants.keyDeviceId) ?? 'unknown';
      
      final payload = {
        'device_id': deviceId,
        'transactions': pending.map((tx) => {
          'transaction_id': tx.transactionId,
          'entity_type': tx.entityType,
          'entity_id': tx.entityId,
          'operation': tx.operation,
          'payload': jsonDecode(tx.payload),
          'created_at': tx.createdAt.toIso8601String(),
          'version': tx.version,
        }).toList(),
      };
      
      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/sync/upload',
        data: payload,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final accepted = List<String>.from(data['accepted'] ?? []);
        final conflicts = List<Map<String, dynamic>>.from(data['conflicts'] ?? []);
        final failed = List<Map<String, dynamic>>.from(data['failed'] ?? []);
        
        // Mark accepted as SYNCED
        for (final txId in accepted) {
          await _db.syncQueueDao.updateStatus(txId, AppConstants.syncSynced);
        }
        
        // Handle conflicts
        for (final conflict in conflicts) {
          final txId = conflict['transaction_id'] as String;
          await _db.syncQueueDao.updateStatus(
            txId,
            AppConstants.syncConflict,
            errorMessage: jsonEncode(conflict),
          );
        }
        
        // Handle failed
        for (final fail in failed) {
          final txId = fail['transaction_id'] as String;
          final tx = pending.firstWhere((t) => t.transactionId == txId);
          if (tx.retryCount >= AppConfig.syncMaxRetries) {
            await _db.syncQueueDao.updateStatus(
              txId,
              AppConstants.syncFailed,
              errorMessage: fail['error']?.toString(),
            );
          } else {
            await _db.syncQueueDao.incrementRetry(txId);
            await _db.syncQueueDao.updateStatus(txId, AppConstants.syncPending);
          }
        }
        
        _logger.i('Upload result: ${accepted.length} accepted, ${conflicts.length} conflicts, ${failed.length} failed');
      } else {
        throw Exception('Upload failed with status ${response.statusCode}');
      }
    } catch (e) {
      // On exception, revert SYNCING to PENDING for retry
      for (final tx in pending) {
        final current = await _db.syncQueueDao.getByTransactionId(tx.transactionId);
        if (current != null && current.syncStatus == AppConstants.syncSyncing) {
          if (current.retryCount >= AppConfig.syncMaxRetries) {
            await _db.syncQueueDao.updateStatus(
              tx.transactionId,
              AppConstants.syncFailed,
              errorMessage: e.toString(),
            );
          } else {
            await _db.syncQueueDao.incrementRetry(tx.transactionId);
            await _db.syncQueueDao.updateStatus(tx.transactionId, AppConstants.syncPending);
          }
        }
      }
      rethrow;
    }
  }

  Future<void> _downloadServerChanges() async {
    try {
      final accessToken = await _secureStorage.read(AppConstants.keyAccessToken);
      if (accessToken == null) return;
      
      final lastSyncAt = await _secureStorage.getLastSyncAt();
      final deviceId = await _secureStorage.read(AppConstants.keyDeviceId) ?? 'unknown';
      
      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/sync/download',
        queryParameters: {
          'device_id': deviceId,
          if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final transactions = List<Map<String, dynamic>>.from(data['transactions'] ?? []);
        
        for (final tx in transactions) {
          await _applyServerTransaction(tx);
        }
        
        _logger.i('Downloaded and applied ${transactions.length} server transactions');
      }
    } catch (e) {
      _logger.e('Failed to download server changes: $e');
      // Don't fail entire sync for download failure
    }
  }

  Future<void> _applyServerTransaction(Map<String, dynamic> tx) async {
    final entityType = tx['entity_type'] as String;
    final entityId = tx['entity_id'] as String;
    final operation = tx['operation'] as String;
    final payload = tx['payload'] as Map<String, dynamic>;
    
    _logger.d('Applying server tx: $entityType $entityId $operation');
    
    // Apply based on entity type - simplified, real implementation would have per-entity logic
    switch (entityType) {
      case 'component':
        // Update local component
        break;
      case 'course':
        // Update course
        break;
      case 'diagnostic':
        // If local has pending changes, detect conflict
        final localPending = await _db.syncQueueDao.getPendingForEntity(entityType, entityId);
        if (localPending.isNotEmpty) {
          // Conflict - mark for manual resolution
          _logger.w('Conflict detected for $entityType:$entityId');
          return;
        }
        // Otherwise apply server change
        break;
      default:
        _logger.w('Unknown entity type for server sync: $entityType');
    }
  }

  Future<int> getPendingCount() async {
    final pending = await _db.syncQueueDao.getByStatus(AppConstants.syncPending);
    return pending.length;
  }

  Future<List<SyncQueueData>> getConflicts() async {
    return await _db.syncQueueDao.getByStatus(AppConstants.syncConflict);
  }

  Future<void> resolveConflict(String transactionId, String strategy, {Map<String, dynamic>? mergedPayload}) async {
    // strategy: use_local, use_server, merge
    if (strategy == 'use_local') {
      await _db.syncQueueDao.updateStatus(transactionId, AppConstants.syncPending);
      await sync();
    } else if (strategy == 'use_server') {
      await _db.syncQueueDao.updateStatus(transactionId, AppConstants.syncSynced);
    } else if (strategy == 'merge' && mergedPayload != null) {
      final tx = await _db.syncQueueDao.getByTransactionId(transactionId);
      if (tx != null) {
        await _db.syncQueueDao.updatePayload(transactionId, jsonEncode(mergedPayload));
        await _db.syncQueueDao.updateStatus(transactionId, AppConstants.syncPending);
        await sync();
      }
    }
  }

  void _updateState(SyncState state) {
    _currentState = state;
    _stateController.add(state);
  }

  void dispose() {
    _stateController.close();
  }
}

final syncEngineProvider = Provider<SyncEngine>((ref) {
  throw UnimplementedError('SyncEngine must be overridden with actual db, dio, etc');
});

final syncStateProvider = StreamProvider<SyncState>((ref) {
  final engine = ref.watch(syncEngineProvider);
  return engine.syncStateStream;
});

final pendingSyncCountProvider = FutureProvider<int>((ref) async {
  final engine = ref.watch(syncEngineProvider);
  return await engine.getPendingCount();
});
