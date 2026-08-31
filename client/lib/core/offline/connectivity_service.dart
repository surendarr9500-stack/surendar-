import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';

enum ConnectivityStatus {
  online,
  offline,
  degraded,
}

class ConnectivityService {
  final Connectivity _connectivity;
  final Dio _dio;
  final StreamController<ConnectivityStatus> _controller;
  
  ConnectivityService({Connectivity? connectivity, Dio? dio})
      : _connectivity = connectivity ?? Connectivity(),
        _dio = dio ?? Dio(),
        _controller = StreamController<ConnectivityStatus>.broadcast();

  Stream<ConnectivityStatus> get connectivityStream => _controller.stream;
  
  ConnectivityStatus _currentStatus = ConnectivityStatus.offline;
  ConnectivityStatus get currentStatus => _currentStatus;
  
  Timer? _periodicCheckTimer;
  bool _isChecking = false;

  Future<void> initialize() async {
    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((results) async {
      await _checkAndUpdateStatus();
    });
    
    // Initial check
    await _checkAndUpdateStatus();
    
    // Periodic backend health check every 30 seconds
    _periodicCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _checkAndUpdateStatus();
    });
  }

  Future<void> _checkAndUpdateStatus() async {
    if (_isChecking) return;
    _isChecking = true;
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      final hasNetwork = connectivityResults.any((r) => r != ConnectivityResult.none);
      
      if (!hasNetwork) {
        _updateStatus(ConnectivityStatus.offline);
        return;
      }
      
      // Has network, check backend reachability
      try {
        final response = await _dio.get(
          '${AppConfig.apiBaseUrl}/health',
          options: Options(
            sendTimeout: const Duration(seconds: 3),
            receiveTimeout: const Duration(seconds: 3),
          ),
        );
        if (response.statusCode == 200) {
          _updateStatus(ConnectivityStatus.online);
        } else {
          _updateStatus(ConnectivityStatus.degraded);
        }
      } catch (e) {
        // Network exists but backend unreachable -> degraded/offline
        // For offline-first, if network exists but backend down, we still consider offline for operational purposes
        // But mark degraded if we want to distinguish
        _updateStatus(ConnectivityStatus.offline);
      }
    } finally {
      _isChecking = false;
    }
  }

  void _updateStatus(ConnectivityStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _controller.add(status);
    }
  }

  Future<bool> get isOnline async {
    await _checkAndUpdateStatus();
    return _currentStatus == ConnectivityStatus.online;
  }

  Future<bool> get isOffline async {
    return !await isOnline;
  }

  // For testing / manual override
  void setStatusForTesting(ConnectivityStatus status) {
    _updateStatus(status);
  }

  void dispose() {
    _periodicCheckTimer?.cancel();
    _controller.close();
  }
}

// Riverpod provider
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  // Initialize if not already
  service.initialize();
  return service.connectivityStream;
});
