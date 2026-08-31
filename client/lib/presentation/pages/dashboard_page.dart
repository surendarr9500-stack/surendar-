import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/datasources/local/seed_data.dart';
import '../widgets/offline_banner.dart';
import '../widgets/status_card.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool _isOffline = false;
  int _pendingSync = 12;
  int _trainingProgress = 82;
  int _activeAlerts = 3;
  double _twinHealth = 87.0;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Capacity Connect'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => context.push('/sync'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          // Offline banner - real connectivity status
          OfflineBanner(isOffline: _isOffline),
          
          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with mission
                  _buildHeader(),
                  const SizedBox(height: 16),
                  
                  // Status grid
                  _buildStatusGrid(isMobile),
                  const SizedBox(height: 16),
                  
                  // Quick actions
                  _buildQuickActions(context, isMobile),
                  const SizedBox(height: 16),
                  
                  // Recent activity & components
                  _buildTwoColumnSection(isMobile),
                  const SizedBox(height: 16),
                  
                  // Demo fault card
                  _buildDemoFaultCard(context),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMobile ? _buildBottomNav(context) : null,
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primaryBlue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.waves, color: AppTheme.primaryBlue),
                ),
                const SizedBox(height: 12),
                const Text('Field Engineer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const Text('field@moes.gov.in', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: const Text('OFFLINE READY', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          _drawerItem(Icons.dashboard, 'Dashboard', '/dashboard', true),
          _drawerItem(Icons.build, 'Troubleshooting', '/troubleshooting', false),
          _drawerItem(Icons.view_in_ar, 'Digital Twin', '/digital-twin', false),
          _drawerItem(Icons.assignment, 'Diagnostics', '/diagnostics', false),
          _drawerItem(Icons.school, 'Training', '/training', false),
          _drawerItem(Icons.description, 'Documents', '/documents', false),
          _drawerItem(Icons.search, 'Search', '/search', false),
          const Divider(),
          _drawerItem(Icons.sync, 'Sync Status ($_pendingSync pending)', '/sync', false),
          _drawerItem(Icons.admin_panel_settings, 'Admin', '/admin', false),
          _drawerItem(Icons.settings, 'Settings', '/settings', false),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => context.go('/login'),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, String route, bool selected) {
    return ListTile(
      leading: Icon(icon, color: selected ? AppTheme.primaryBlue : Colors.grey[600]),
      title: Text(title, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal, color: selected ? AppTheme.primaryBlue : null)),
      selected: selected,
      selectedTileColor: AppTheme.primaryBlue.withOpacity(0.1),
      onTap: () {
        Navigator.pop(context);
        if (!selected) context.push(route);
      },
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.sailing, color: AppTheme.primaryBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('MISSION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey)),
                  const SizedBox(height: 2),
                  const Text('Oceanographic Survey', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('RV Sindhu Sadhana • Arabian Sea', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: _isOffline ? Colors.red : Colors.green, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(_isOffline ? 'OFFLINE' : 'ONLINE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _isOffline ? Colors.red : Colors.green)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(_isOffline ? 'LOCAL AI ACTIVE' : 'CLOUD CONNECTED', style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusGrid(bool isMobile) {
    return GridView.count(
      crossAxisCount: isMobile ? 2 : 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: isMobile ? 1.5 : 1.8,
      children: [
        StatusCard(
          title: 'TRAINING',
          value: '$_trainingProgress%',
          subtitle: 'Completed',
          icon: Icons.school,
          color: AppTheme.primaryBlue,
          progress: _trainingProgress / 100,
        ),
        StatusCard(
          title: 'ACTIVE ALERTS',
          value: '$_activeAlerts',
          subtitle: 'Critical: 1',
          icon: Icons.warning_amber,
          color: Colors.orange,
        ),
        StatusCard(
          title: 'DIGITAL TWIN',
          value: '${_twinHealth.toInt()}% HEALTH',
          subtitle: '5 components',
          icon: Icons.view_in_ar,
          color: Colors.green,
          progress: _twinHealth / 100,
        ),
        StatusCard(
          title: 'SYNC QUEUE',
          value: '$_pendingSync PENDING',
          subtitle: 'Last: 2h ago',
          icon: Icons.sync,
          color: _pendingSync > 10 ? Colors.red : Colors.blue,
          onTap: () => context.push('/sync'),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isMobile) {
    final actions = [
      {'icon': Icons.build, 'label': 'Troubleshoot', 'route': '/troubleshooting', 'color': AppTheme.primaryBlue},
      {'icon': Icons.view_in_ar, 'label': 'Digital Twin', 'route': '/digital-twin', 'color': Colors.teal},
      {'icon': Icons.assignment, 'label': 'Diagnostics', 'route': '/diagnostics', 'color': Colors.orange},
      {'icon': Icons.school, 'label': 'Training', 'route': '/training', 'color': Colors.purple},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: isMobile ? 2 : 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: actions.map((action) {
            return Card(
              child: InkWell(
                onTap: () => context.push(action['route'] as String),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: (action['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Icon(action['icon'] as IconData, color: action['color'] as Color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(action['label'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                      const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTwoColumnSection(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildComponentsList(),
          const SizedBox(height: 16),
          _buildRecentActivity(),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildComponentsList()),
        const SizedBox(width: 16),
        Expanded(child: _buildRecentActivity()),
      ],
    );
  }

  Widget _buildComponentsList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Components', style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton(onPressed: () => context.push('/digital-twin'), child: const Text('View Twin')),
              ],
            ),
            const SizedBox(height: 8),
            ...SeedDataService.components.map((comp) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: AppTheme.getStatusColor(comp.status).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.memory, color: AppTheme.getStatusColor(comp.status), size: 20),
                ),
                title: Text(comp.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Text('${comp.id} • ${comp.meshId}', style: const TextStyle(fontSize: 11)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppTheme.getStatusColor(comp.status), borderRadius: BorderRadius.circular(12)),
                  child: Text(comp.status, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                onTap: () => context.push('/digital-twin?meshId=${comp.meshId}&componentId=${comp.id}'),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {'event': 'DIAGNOSTIC_CREATED', 'desc': 'Sonar abnormal vibration', 'time': '2h ago', 'icon': Icons.build, 'color': Colors.orange},
      {'event': 'TRAINING_COMPLETED', 'desc': 'Sonar Fundamentals completed', 'time': '5h ago', 'icon': Icons.school, 'color': Colors.green},
      {'event': 'COMPONENT_INSPECTED', 'desc': 'TELEM-001 inspected', 'time': '1d ago', 'icon': Icons.view_in_ar, 'color': Colors.blue},
      {'event': 'AI_ANALYSIS', 'desc': 'AI analysis for SONAR-001', 'time': '1d ago', 'icon': Icons.smart_toy, 'color': Colors.purple},
      {'event': 'SYNC_COMPLETED', 'desc': '12 records synced', 'time': '2d ago', 'icon': Icons.sync, 'color': Colors.teal},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...activities.map((activity) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: (activity['color'] as Color).withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(activity['icon'] as IconData, color: activity['color'] as Color, size: 16),
                ),
                title: Text(activity['desc'] as String, style: const TextStyle(fontSize: 13)),
                subtitle: Text('${activity['event']} • ${activity['time']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoFaultCard(BuildContext context) {
    return Card(
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.orange.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.bug_report, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LIVE ENGINEERING DEMO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      Text('Preloaded fault scenario', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                  child: const Text('HIGH', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Component: Sonar Transducer Array (SONAR-001)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Mesh: Mesh_042', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text('Problem: Abnormal vibration and casing fracture.', style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 8),
                  const Text('Expected: Component SONAR-001, Mesh_042, HIGH severity, diagnostic procedure', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/troubleshooting'),
                icon: const Icon(Icons.play_arrow),
                label: const Text('RUN LIVE DEMO'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            break;
          case 1:
            context.push('/troubleshooting');
            break;
          case 2:
            context.push('/digital-twin');
            break;
          case 3:
            context.push('/diagnostics');
            break;
          case 4:
            context.push('/training');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Fix'),
        BottomNavigationBarItem(icon: Icon(Icons.view_in_ar), label: 'Twin'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Diag'),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Learn'),
      ],
    );
  }
}
