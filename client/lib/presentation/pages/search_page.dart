import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/local/seed_data.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _isSearching = false;

  void _search(String query) {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _isSearching = true);
    
    Future.delayed(const Duration(milliseconds: 300), () {
      final lowerQuery = query.toLowerCase();
      final results = <Map<String, dynamic>>[];
      
      // Search components
      for (final comp in SeedDataService.components) {
        if (comp.name.toLowerCase().contains(lowerQuery) || comp.id.toLowerCase().contains(lowerQuery) || comp.description.toLowerCase().contains(lowerQuery)) {
          results.add({'type': 'component', 'title': comp.name, 'subtitle': '${comp.id} • ${comp.meshId} • ${comp.category}', 'id': comp.id, 'icon': Icons.memory, 'color': AppTheme.primaryBlue});
        }
      }
      
      // Search courses
      for (final course in SeedDataService.courses) {
        if (course['title'].toString().toLowerCase().contains(lowerQuery) || course['description'].toString().toLowerCase().contains(lowerQuery)) {
          results.add({'type': 'course', 'title': course['title'], 'subtitle': '${course['category']} • ${course['difficulty']}', 'id': course['id'], 'icon': Icons.school, 'color': Colors.purple});
        }
      }
      
      // Search diagnostics
      for (final diag in SeedDataService.diagnostics) {
        if (diag['title'].toString().toLowerCase().contains(lowerQuery) || diag['description'].toString().toLowerCase().contains(lowerQuery)) {
          results.add({'type': 'diagnostic', 'title': diag['title'], 'subtitle': '${diag['component_id']} • ${diag['severity']} • ${diag['status']}', 'id': diag['id'], 'icon': Icons.assignment, 'color': Colors.orange});
        }
      }
      
      // Search knowledge base (mock)
      if (lowerQuery.contains('sonar') || lowerQuery.contains('fracture') || lowerQuery.contains('vibration')) {
        results.add({'type': 'knowledge', 'title': 'Sonar Transducer Array - Casing Fracture', 'subtitle': 'Knowledge Base • SONAR-001 • HIGH severity', 'id': 'kb-001', 'icon': Icons.lightbulb, 'color': Colors.amber});
      }
      if (lowerQuery.contains('telemetry') || lowerQuery.contains('signal')) {
        results.add({'type': 'knowledge', 'title': 'Telemetry Transceiver - Signal Loss', 'subtitle': 'Knowledge Base • TELEM-001 • CRITICAL', 'id': 'kb-003', 'icon': Icons.lightbulb, 'color': Colors.amber});
      }
      
      setState(() {
        _results = results;
        _isSearching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Global Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search courses, documents, components, diagnostics, knowledge...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); _search(''); }) : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _search,
            ),
          ),
          if (_isSearching) const LinearProgressIndicator(minHeight: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                const Text('Local Index • FTS5 • Offline Search • No cloud required', style: TextStyle(fontSize: 11, color: Colors.grey)),
                const Spacer(),
                Text('${_results.length} results', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _searchController.text.isEmpty
                ? _buildEmptyState()
                : _results.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search_off, size: 48, color: Colors.grey[300]), const SizedBox(height: 12), Text('No results for "${_searchController.text}"', style: TextStyle(color: Colors.grey[600])), const SizedBox(height: 8), const Text('Try: sonar, telemetry, vibration, fracture, training', style: TextStyle(fontSize: 11, color: Colors.grey))]))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final result = _results[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: (result['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(result['icon'] as IconData, color: result['color'] as Color, size: 20)),
                              title: Text(result['title'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              subtitle: Text(result['subtitle'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: Text(result['type'], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              onTap: () {
                                switch (result['type']) {
                                  case 'component':
                                    context.push('/digital-twin?componentId=${result['id']}');
                                    break;
                                  case 'course':
                                    context.push('/training/${result['id']}');
                                    break;
                                  case 'diagnostic':
                                    context.push('/diagnostics');
                                    break;
                                  case 'knowledge':
                                    context.push('/troubleshooting');
                                    break;
                                }
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

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Search Index', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _searchCategory('Components', ['SONAR-001', 'TELEM-001', 'ARGO-001', 'ECHO-001', 'WINCH-001']),
          const SizedBox(height: 12),
          _searchCategory('Recent Searches', ['sonar fracture', 'telemetry signal loss', 'vibration']),
          const SizedBox(height: 12),
          _searchCategory('Suggested', ['abnormal vibration', 'casing fracture', 'hydraulic leak', 'training']),
          const SizedBox(height: 16),
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [Icon(Icons.info, size: 16, color: Colors.blue.shade700), const SizedBox(width: 8), Text('Search Architecture', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade800, fontSize: 12))]),
                  const SizedBox(height: 8),
                  const Text('Global Search → Local Index (FTS5) → Relevant Results → Entity Viewer', style: TextStyle(fontSize: 11)),
                  const SizedBox(height: 8),
                  const Text('Searches: Courses, Documents, Components, Diagnostics, Maintenance, Knowledge Base', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 4),
                  const Text('Offline: No internet required, local SQLite FTS5 + knowledge base', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchCategory(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items.map((item) => ActionChip(
            label: Text(item, style: const TextStyle(fontSize: 11)),
            onPressed: () { _searchController.text = item; _search(item); },
            backgroundColor: Colors.grey.shade100,
          )).toList(),
        ),
      ],
    );
  }
}
