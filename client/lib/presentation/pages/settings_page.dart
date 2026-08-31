import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Storage Management', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _storageRow('Total Storage', '64 GB', 1.0),
                  _storageRow('Used', '2.4 GB (3.7%)', 0.037),
                  const Divider(),
                  _storageRow('Training Media', '1.2 GB', 0.5, color: Colors.blue),
                  _storageRow('Documents', '0.8 GB', 0.33, color: Colors.green),
                  _storageRow('3D Models', '0.3 GB', 0.12, color: Colors.orange),
                  _storageRow('AI Models', '0.05 GB', 0.02, color: Colors.purple),
                  _storageRow('Database', '0.05 GB', 0.02, color: Colors.teal),
                  const SizedBox(height: 12),
                  Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.cleaning_services, size: 16), label: const Text('CLEAR CACHE', style: TextStyle(fontSize: 11)))), const SizedBox(width: 8), Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.delete, size: 16), label: const Text('MANAGE FILES', style: TextStyle(fontSize: 11)), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white)))]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _settingsTile(Icons.security, 'Security', 'AES-256-GCM, Secure Storage, Biometrics', () {}),
                _settingsTile(Icons.sync, 'Synchronization', '12 pending, last sync 2h ago', () {}),
                _settingsTile(Icons.wifi_off, 'Offline Mode', 'Offline auth 72h, device registered', () {}),
                _settingsTile(Icons.smart_toy, 'Local AI Engine', '127.0.0.1:8001, TF-IDF + keyword matching', () {}),
                _settingsTile(Icons.view_in_ar, 'Digital Twin', '5 models cached, checksum verified', () {}),
                _settingsTile(Icons.language, 'Language', 'English (en) - Future: Hindi, regional', () {}),
                _settingsTile(Icons.notifications, 'Notifications', 'Alerts for critical faults', () {}),
                _settingsTile(Icons.info, 'About', 'Capacity Connect v1.0.0 - SIH 2026 SIH26075', () {}),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Versioning', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade800, fontSize: 12)),
                  const SizedBox(height: 8),
                  _versionRow('Application', '1.0.0'),
                  _versionRow('API', 'v1'),
                  _versionRow('Knowledge Base', 'v1 - 10 chunks'),
                  _versionRow('3D Models', 'v1 - 5 models'),
                  _versionRow('AI Model', 'deterministic v1 - pluggable LLM future'),
                  _versionRow('Training Content', 'v1 - 3 courses'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _storageRow(String label, String size, double progress, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 12)), Text(size, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation<Color>(color ?? AppTheme.primaryBlue), minHeight: 4),
        ],
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: AppTheme.primaryBlue, size: 20)),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _versionRow(String label, String version) {
    return Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 11)), Text(version, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))])),
  }
}
