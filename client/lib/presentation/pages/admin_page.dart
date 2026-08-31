import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Administration'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Users'),
              Tab(text: 'Training'),
              Tab(text: 'Assets'),
              Tab(text: 'Knowledge'),
              Tab(text: 'System'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _usersTab(),
            _trainingTab(),
            _assetsTab(),
            _knowledgeTab(),
            _systemTab(),
          ],
        ),
      ),
    );
  }

  Widget _usersTab() {
    final users = [
      {'username': 'admin', 'email': 'admin@moes.gov.in', 'role': 'administrator', 'active': true},
      {'username': 'field_engineer', 'email': 'field@moes.gov.in', 'role': 'field_engineer', 'active': true},
      {'username': 'technician', 'email': 'tech@moes.gov.in', 'role': 'technician', 'active': true},
      {'username': 'training_officer', 'email': 'training@moes.gov.in', 'role': 'training_officer', 'active': true},
      {'username': 'supervisor', 'email': 'supervisor@moes.gov.in', 'role': 'supervisor', 'active': true},
    ];
    
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Users (5)', style: TextStyle(fontWeight: FontWeight.bold)), ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 16), label: const Text('CREATE USER', style: TextStyle(fontSize: 11)), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white))]),
        const SizedBox(height: 12),
        ...users.map((user) => Card(
          child: ListTile(
            leading: CircleAvatar(backgroundColor: AppTheme.primaryBlue, child: Text(user['username'].toString()[0].toUpperCase(), style: const TextStyle(color: Colors.white))),
            title: Text(user['username'].toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            subtitle: Text('${user['email']} • ${user['role']}', style: const TextStyle(fontSize: 11)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: (user['active'] as bool) ? Colors.green : Colors.red, borderRadius: BorderRadius.circular(8)), child: Text((user['active'] as bool) ? 'ACTIVE' : 'DISABLED', style: const TextStyle(fontSize: 9, color: Colors.white))), IconButton(icon: const Icon(Icons.more_vert, size: 18), onPressed: () {})]),
          ),
        )).toList(),
      ],
    );
  }

  Widget _trainingTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Training Management', style: TextStyle(fontWeight: FontWeight.bold)), ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 16), label: const Text('CREATE COURSE', style: TextStyle(fontSize: 11)), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white))]),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Courses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), const SizedBox(height: 8), _adminRow('Sonar Operations and Maintenance', 'Published • v1 • 240 min', Icons.school), _adminRow('Telemetry Systems', 'Draft • v1 • 180 min', Icons.cell_tower), _adminRow('Argo Float Maintenance', 'Published • v1 • 300 min', Icons.water)]))),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Quizzes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), const SizedBox(height: 8), _adminRow('Sonar Troubleshooting Assessment', '3 questions • 70% pass', Icons.quiz)]))),
      ],
    );
  }

  Widget _assetsTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Asset Management', style: TextStyle(fontWeight: FontWeight.bold)), ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 16), label: const Text('CREATE COMPONENT', style: TextStyle(fontSize: 11)), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white))]),
        const SizedBox(height: 12),
        ...[
          {'id': 'SONAR-001', 'name': 'Sonar Transducer Array', 'mesh': 'Mesh_042', 'status': 'NORMAL'},
          {'id': 'TELEM-001', 'name': 'Telemetry Transceiver Mast', 'mesh': 'Mesh_109', 'status': 'NORMAL'},
          {'id': 'ARGO-001', 'name': 'Autonomous Argo Profiling Float', 'mesh': 'Mesh_210', 'status': 'NORMAL'},
          {'id': 'ECHO-001', 'name': 'Multi-beam Echo Sounder', 'mesh': 'Mesh_315', 'status': 'NORMAL'},
          {'id': 'WINCH-001', 'name': 'Hydraulic Deep-Sea Winch', 'mesh': 'Mesh_410', 'status': 'NORMAL'},
        ].map((comp) => Card(
          child: ListTile(
            leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.memory, color: AppTheme.primaryBlue, size: 20)),
            title: Text(comp['name'].toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            subtitle: Text('${comp['id']} • ${comp['mesh']} • ${comp['status']}', style: const TextStyle(fontSize: 11)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.upload_file, size: 18), onPressed: () {}, tooltip: 'Upload Model'), IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () {})]),
          ),
        )).toList(),
      ],
    );
  }

  Widget _knowledgeTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Knowledge Base', style: TextStyle(fontWeight: FontWeight.bold)), ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.upload_file, size: 16), label: const Text('UPLOAD DOC', style: TextStyle(fontSize: 11)), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white))]),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Pipeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), const SizedBox(height: 8), const Text('Document → Extraction → Cleaning → Chunking → Metadata → Indexing → Local Retrieval → Relevant Knowledge → AI Response', style: TextStyle(fontSize: 11, color: Colors.grey)), const SizedBox(height: 12), const Text('Indexed Documents (10 chunks)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), const SizedBox(height: 8), _adminRow('Sonar Casing Fracture', 'SONAR-001 • HIGH', Icons.description), _adminRow('Telemetry Signal Loss', 'TELEM-001 • CRITICAL', Icons.description), _adminRow('Hydraulic Leak', 'WINCH-001 • CRITICAL', Icons.description)]))),
      ],
    );
  }

  Widget _systemTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text('System Status', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: [
            _systemStat('Devices', '5', Colors.blue, Icons.devices),
            _systemStat('Pending Sync', '12', Colors.orange, Icons.sync),
            _systemStat('Storage Used', '2.4 GB', Colors.green, Icons.storage),
            _systemStat('AI Engine', 'Healthy', Colors.teal, Icons.smart_toy),
          ],
        ),
        const SizedBox(height: 16),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Storage Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), const SizedBox(height: 12), _storageRow('Training Media', '1.2 GB', 0.5), _storageRow('Documents', '0.8 GB', 0.33), _storageRow('3D Models', '0.3 GB', 0.12), _storageRow('Database', '0.1 GB', 0.04)]))),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Recent Logs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), const SizedBox(height: 8), _logRow('INFO', 'Sync completed: 12 transactions'), _logRow('WARN', 'AI engine fallback to Dart matcher'), _logRow('INFO', 'User field_engineer login'), _logRow('ERROR', 'Failed to download model Mesh_315')]))),
      ],
    );
  }

  Widget _adminRow(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)), child: Icon(icon, size: 16, color: Colors.grey[700])), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey))]))]),
    );
  }

  Widget _systemStat(String title, String value, Color color, IconData icon) {
    return Card(child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)), Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color))])])));
  }

  Widget _storageRow(String label, String size, double progress) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 12)), Text(size, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]), const SizedBox(height: 4), LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue), minHeight: 4)]));
  }

  Widget _logRow(String level, String message) {
    Color color = level == 'ERROR' ? Colors.red : level == 'WARN' ? Colors.orange : Colors.green;
    return Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.1), border: Border.all(color: color.withOpacity(0.3)), borderRadius: BorderRadius.circular(4)), child: Text(level, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold))), const SizedBox(width: 8), Expanded(child: Text(message, style: const TextStyle(fontSize: 11)))]));
  }
}
