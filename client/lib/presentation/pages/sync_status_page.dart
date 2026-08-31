import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/offline_banner.dart';

class SyncStatusPage extends StatefulWidget {
  const SyncStatusPage({super.key});

  @override
  State<SyncStatusPage> createState() => _SyncStatusPageState();
}

class _SyncStatusPageState extends State<SyncStatusPage> {
  bool _isSyncing = false;
  int _pendingCount = 12;
  int _syncedCount = 45;
  int _failedCount = 2;
  int _conflictCount = 1;
  
  final List<Map<String, dynamic>> _transactions = [
    {'id': 'tx-001', 'entity_type': 'diagnostic', 'entity_id': 'diag-001', 'operation': 'CREATE', 'status': 'PENDING', 'created_at': '2024-02-15 10:30', 'retry': 0},
    {'id': 'tx-002', 'entity_type': 'progress', 'entity_id': 'course-001', 'operation': 'UPDATE', 'status': 'PENDING', 'created_at': '2024-02-15 11:00', 'retry': 0},
    {'id': 'tx-003', 'entity_type': 'quiz_attempt', 'entity_id': 'attempt-001', 'operation': 'CREATE', 'status': 'PENDING', 'created_at': '2024-02-15 11:15', 'retry': 1},
    {'id': 'tx-004', 'entity_type': 'diagnostic', 'entity_id': 'diag-002', 'operation': 'UPDATE', 'status': 'SYNCING', 'created_at': '2024-02-15 11:30', 'retry': 0},
    {'id': 'tx-005', 'entity_type': 'diagnostic', 'entity_id': 'diag-003', 'operation': 'CREATE', 'status': 'CONFLICT', 'created_at': '2024-02-15 09:00', 'retry': 2},
    {'id': 'tx-006', 'entity_type': 'maintenance', 'entity_id': 'maint-001', 'operation': 'CREATE', 'status': 'FAILED', 'created_at': '2024-02-15 08:00', 'retry': 5},
  ];

  Future<void> _sync() async {
    setState(() => _isSyncing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isSyncing = false;
      _pendingCount = 0;
      _syncedCount += 12;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sync completed: 12 transactions synced'), backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sync Status')),
      body: Column(
        children: [
          OfflineBanner(isOffline: _pendingCount > 0, message: _pendingCount > 0 ? '$_pendingCount PENDING • SYNC QUEUE • OFFLINE MODE' : 'SYNCED • CLOUD CONNECTED'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.5,
                    children: [
                      _statCard('PENDING', _pendingCount.toString(), Colors.orange, Icons.pending),
                      _statCard('SYNCED', _syncedCount.toString(), Colors.green, Icons.check_circle),
                      _statCard('FAILED', _failedCount.toString(), Colors.red, Icons.error),
                      _statCard('CONFLICT', _conflictCount.toString(), Colors.purple, Icons.warning),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Sync button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSyncing ? null : _sync,
                      icon: _isSyncing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.sync),
                      label: Text(_isSyncing ? 'SYNCING...' : 'SYNC NOW (${_pendingCount} pending)'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Sync Flow: Local Transaction → Sync Queue → Connectivity Restored → Authentication → Upload → Server Validation → Conflict Detection → Ack → Local State Update', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  const SizedBox(height: 16),
                  
                  // Last sync info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Last Sync', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 8),
                          _infoRow('Last successful', '2 hours ago'),
                          _infoRow('Device ID', 'device-abc-123'),
                          _infoRow('User', 'field_engineer'),
                          _infoRow('Server', 'https://api.moes.gov.in'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Transactions
                  const Text('Sync Queue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  ..._transactions.map((tx) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: _getStatusColor(tx['status']), borderRadius: BorderRadius.circular(8)),
                                child: Text(tx['status'], style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 8),
                              Text(tx['entity_type'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Text(tx['operation'], style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                              const Spacer(),
                              Text('Retry: ${tx['retry']}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('ID: ${tx['entity_id']} • Tx: ${tx['id']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          Text('Created: ${tx['created_at']}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          if (tx['status'] == 'CONFLICT' || tx['status'] == 'FAILED')
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Expanded(child: OutlinedButton(onPressed: () {}, child: Text(tx['status'] == 'CONFLICT' ? 'RESOLVE' : 'RETRY', style: const TextStyle(fontSize: 11)))),
                                  const SizedBox(width: 8),
                                  Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: tx['status'] == 'CONFLICT' ? Colors.purple : Colors.red, foregroundColor: Colors.white), child: Text(tx['status'] == 'CONFLICT' ? 'USE LOCAL' : 'DELETE', style: const TextStyle(fontSize: 11)))),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  )).toList(),
                  
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Conflict Resolution', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade800, fontSize: 12)),
                          const SizedBox(height: 8),
                          const Text('Strategies per entity:\n• Diagnostics: field-level merge, never silent loss\n• Progress: last-write-wins with version\n• Components: version comparison, manual', style: TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)), Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color))]),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(children: [SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey))), Expanded(child: Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))]));
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING': return Colors.orange;
      case 'SYNCING': return Colors.blue;
      case 'SYNCED': return Colors.green;
      case 'FAILED': return Colors.red;
      case 'CONFLICT': return Colors.purple;
      default: return Colors.grey;
    }
  }
}
