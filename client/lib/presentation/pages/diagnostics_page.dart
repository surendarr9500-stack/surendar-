import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/local/seed_data.dart';
import '../widgets/offline_banner.dart';

class DiagnosticsPage extends StatefulWidget {
  const DiagnosticsPage({super.key});

  @override
  State<DiagnosticsPage> createState() => _DiagnosticsPageState();
}

class _DiagnosticsPageState extends State<DiagnosticsPage> {
  String _filterStatus = 'ALL';
  
  @override
  Widget build(BuildContext context) {
    final filtered = _filterStatus == 'ALL' 
        ? SeedDataService.diagnostics 
        : SeedDataService.diagnostics.where((d) => d['status'] == _filterStatus).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostics'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: _showFilter),
          IconButton(icon: const Icon(Icons.add), onPressed: () => context.push('/troubleshooting')),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(isOffline: true, message: '12 PENDING SYNC • LOCAL DB • OFFLINE MODE'),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _filterChip('ALL', filtered.length),
                const SizedBox(width: 8),
                _filterChip('OPEN', SeedDataService.diagnostics.where((d) => d['status'] == 'OPEN').length),
                const SizedBox(width: 8),
                _filterChip('IN_PROGRESS', SeedDataService.diagnostics.where((d) => d['status'] == 'IN_PROGRESS').length),
                const SizedBox(width: 8),
                _filterChip('RESOLVED', SeedDataService.diagnostics.where((d) => d['status'] == 'RESOLVED').length),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty 
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[300]), const SizedBox(height: 16), Text('No diagnostics for $_filterStatus', style: TextStyle(color: Colors.grey[600]))]))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final diag = filtered[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: _getSeverityColor(diag['severity']), borderRadius: BorderRadius.circular(12)),
                                    child: Text(diag['severity'], style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: _getStatusColor(diag['status']).withOpacity(0.1), border: Border.all(color: _getStatusColor(diag['status'])), borderRadius: BorderRadius.circular(12)),
                                    child: Text(diag['status'], style: TextStyle(fontSize: 10, color: _getStatusColor(diag['status']), fontWeight: FontWeight.bold)),
                                  ),
                                  const Spacer(),
                                  Text(diag['created_at'].toString().split('T')[0], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(diag['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(diag['description'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.memory, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(diag['component_id'], style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                  const SizedBox(width: 12),
                                  Icon(Icons.sync, size: 14, color: diag['sync_status'] == 'PENDING' ? Colors.orange : Colors.green),
                                  const SizedBox(width: 4),
                                  Text(diag['sync_status'], style: TextStyle(fontSize: 11, color: diag['sync_status'] == 'PENDING' ? Colors.orange : Colors.green)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: OutlinedButton.icon(onPressed: () => context.push('/digital-twin?componentId=${diag['component_id']}'), icon: const Icon(Icons.view_in_ar, size: 16), label: const Text('TWIN', style: TextStyle(fontSize: 11)))),
                                  const SizedBox(width: 8),
                                  Expanded(child: ElevatedButton.icon(onPressed: () => _showDiagnosticDetails(diag), icon: const Icon(Icons.visibility, size: 16), label: const Text('DETAILS', style: TextStyle(fontSize: 11)), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/troubleshooting'),
        icon: const Icon(Icons.add),
        label: const Text('NEW DIAGNOSTIC'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _filterChip(String status, int count) {
    final isSelected = _filterStatus == status;
    return FilterChip(
      label: Text('$status ($count)', style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.grey[700])),
      selected: isSelected,
      onSelected: (selected) => setState(() => _filterStatus = status),
      backgroundColor: Colors.grey.shade100,
      selectedColor: AppTheme.primaryBlue,
      checkmarkColor: Colors.white,
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'CRITICAL': return Colors.red;
      case 'HIGH': return Colors.orange;
      case 'MEDIUM': return Colors.blue;
      case 'LOW': return Colors.green;
      default: return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'OPEN': return Colors.red;
      case 'IN_PROGRESS': return Colors.orange;
      case 'RESOLVED': return Colors.green;
      case 'CLOSED': return Colors.grey;
      default: return Colors.blue;
    }
  }

  void _showFilter() {
    showModalBottomSheet(context: context, builder: (context) => Container(padding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('Filter Diagnostics', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 12), ...['ALL', 'OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED'].map((s) => ListTile(title: Text(s), onTap: () { setState(() => _filterStatus = s); Navigator.pop(context); })))])));
  }

  void _showDiagnosticDetails(Map<String, dynamic> diag) {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text(diag['title']),
      content: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ID: ${diag['id']}'), Text('Component: ${diag['component_id']}'), Text('Severity: ${diag['severity']}'), Text('Status: ${diag['status']}'), const SizedBox(height: 8), Text('Description: ${diag['description']}'), const SizedBox(height: 8), Text('Created: ${diag['created_at']}'), Text('Sync: ${diag['sync_status']}'),
        const SizedBox(height: 12), const Text('Workflow:', style: TextStyle(fontWeight: FontWeight.bold)), const Text('Create Record → Select Component → Describe Fault → AI Analysis → Recommended Procedure → Technician Action → Resolution → Close Record', style: TextStyle(fontSize: 11)),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('CLOSE')), ElevatedButton(onPressed: () { Navigator.pop(context); context.push('/digital-twin?componentId=${diag['component_id']}'); }, child: const Text('VIEW TWIN'))],
    ));
  }
}
