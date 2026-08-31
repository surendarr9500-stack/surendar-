import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/offline_banner.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  final _searchController = TextEditingController();
  String _filterCategory = 'ALL';
  
  final List<Map<String, dynamic>> _documents = [
    {'id': 'doc-001', 'title': 'SONAR-001 Technical Manual v2.1', 'version': '2.1', 'category': 'Manual', 'component': 'SONAR-001', 'language': 'en', 'offline': true, 'size': '5.2 MB', 'updated': '2024-01-15'},
    {'id': 'doc-002', 'title': 'Telemetry Systems Operations Guide', 'version': '1.5', 'category': 'Manual', 'component': 'TELEM-001', 'language': 'en', 'offline': true, 'size': '3.1 MB', 'updated': '2024-02-01'},
    {'id': 'doc-003', 'title': 'Argo Float Maintenance Procedures', 'version': '3.0', 'category': 'Maintenance', 'component': 'ARGO-001', 'language': 'en', 'offline': true, 'size': '2.8 MB', 'updated': '2024-01-20'},
    {'id': 'doc-004', 'title': 'Echo Sounder Calibration Guide', 'version': '1.2', 'category': 'Calibration', 'component': 'ECHO-001', 'language': 'en', 'offline': false, 'size': '1.5 MB', 'updated': '2024-02-10'},
    {'id': 'doc-005', 'title': 'Winch Safety Procedures', 'version': '2.0', 'category': 'Safety', 'component': 'WINCH-001', 'language': 'en', 'offline': true, 'size': '1.2 MB', 'updated': '2024-01-10'},
    {'id': 'doc-006', 'title': 'Oceanographic Survey Best Practices', 'version': '1.0', 'category': 'Operations', 'component': null, 'language': 'en', 'offline': false, 'size': '4.0 MB', 'updated': '2024-02-15'},
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _documents.where((doc) {
      final matchesSearch = _searchController.text.isEmpty || doc['title'].toString().toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesCategory = _filterCategory == 'ALL' || doc['category'] == _filterCategory;
      return matchesSearch && matchesCategory;
    }).toList();
    
    return Scaffold(
      appBar: AppBar(title: const Text('Documents')),
      body: Column(
        children: [
          const OfflineBanner(isOffline: false, message: 'DOCUMENTS • LOCAL FTS SEARCH • OFFLINE AVAILABLE'),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search documents, manuals, procedures...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['ALL', 'Manual', 'Maintenance', 'Calibration', 'Safety', 'Operations'].map((cat) {
                      final isSelected = _filterCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.grey[700])),
                          selected: isSelected,
                          onSelected: (selected) => setState(() => _filterCategory = cat),
                          selectedColor: AppTheme.primaryBlue,
                          backgroundColor: Colors.grey.shade100,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final doc = filtered[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.description, color: AppTheme.primaryBlue, size: 20),
                    ),
                    title: Text(doc['title'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${doc['category']} • v${doc['version']} • ${doc['size']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        Row(
                          children: [
                            if (doc['component'] != null) ...[
                              Icon(Icons.memory, size: 10, color: Colors.grey[600]),
                              const SizedBox(width: 2),
                              Text(doc['component'], style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                              const SizedBox(width: 8),
                            ],
                            Icon(doc['offline'] ? Icons.offline_pin : Icons.cloud_download, size: 10, color: doc['offline'] ? Colors.green : Colors.grey),
                            const SizedBox(width: 2),
                            Text(doc['offline'] ? 'Offline' : 'Online only', style: TextStyle(fontSize: 10, color: doc['offline'] ? Colors.green : Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(icon: const Icon(Icons.more_vert, size: 20), onPressed: () {}),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening ${doc['title']} - local file viewer with FTS search'), backgroundColor: AppTheme.primaryBlue));
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
