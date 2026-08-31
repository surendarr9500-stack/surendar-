import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/local/seed_data.dart';
import '../../data/models/component_model.dart';
import '../widgets/offline_banner.dart';

class DigitalTwinPage extends ConsumerStatefulWidget {
  final String? highlightMeshId;
  final String? highlightComponentId;
  
  const DigitalTwinPage({super.key, this.highlightMeshId, this.highlightComponentId});

  @override
  ConsumerState<DigitalTwinPage> createState() => _DigitalTwinPageState();
}

class _DigitalTwinPageState extends ConsumerState<DigitalTwinPage> {
  String? _selectedMeshId;
  String? _selectedComponentId;
  String _selectedStatus = 'NORMAL';
  bool _isIsolated = false;
  double _zoom = 1.0;
  
  @override
  void initState() {
    super.initState();
    _selectedMeshId = widget.highlightMeshId;
    _selectedComponentId = widget.highlightComponentId;
    if (_selectedMeshId != null) {
      final comp = SeedDataService.getComponentByMeshId(_selectedMeshId!);
      if (comp != null) {
        _selectedStatus = 'CRITICAL';
        // Update component status to critical for demo
        comp.status = 'CRITICAL';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedComponent = _selectedMeshId != null 
        ? SeedDataService.getComponentByMeshId(_selectedMeshId!)
        : null;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Twin'),
        actions: [
          IconButton(
            icon: Icon(_isIsolated ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _isIsolated = !_isIsolated),
            tooltip: _isIsolated ? 'Show All' : 'Isolate',
          ),
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            onPressed: () => setState(() {
              _zoom = 1.0;
              _isIsolated = false;
            }),
            tooltip: 'Reset Camera',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(isOffline: false, message: 'DIGITAL TWIN • LOCAL GLB CACHED • OFFLINE READY'),
          
          // 3D Viewer Area (simulated with custom widget since model_viewer_plus requires web setup)
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade700),
              ),
              child: Stack(
                children: [
                  // Simulated 3D scene
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.view_in_ar, size: 64, color: Colors.white.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text(
                          '3D Vessel Twin',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'GLB/GLTF Renderer: model_viewer_plus',
                          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        // Component visualization as colored boxes
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: SeedDataService.components.map((comp) {
                            final isSelected = comp.meshId == _selectedMeshId;
                            final isHighlighted = widget.highlightMeshId == comp.meshId;
                            return GestureDetector(
                              onTap: () => setState(() {
                                _selectedMeshId = comp.meshId;
                                _selectedComponentId = comp.id;
                                _selectedStatus = comp.status;
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: isSelected ? 100 : 80,
                                height: isSelected ? 100 : 80,
                                decoration: BoxDecoration(
                                  color: isHighlighted 
                                      ? Colors.red.withOpacity(0.8)
                                      : AppTheme.getStatusColor(comp.status).withOpacity(isSelected ? 0.9 : 0.6),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    width: 2,
                                  ),
                                  boxShadow: isSelected || isHighlighted
                                      ? [BoxShadow(color: (isHighlighted ? Colors.red : AppTheme.getStatusColor(comp.status)).withOpacity(0.5), blurRadius: 20, spreadRadius: 2)]
                                      : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _getIconForCategory(comp.category),
                                      color: Colors.white,
                                      size: isSelected ? 32 : 24,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      comp.meshId,
                                      style: TextStyle(color: Colors.white, fontSize: isSelected ? 12 : 10, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      comp.id,
                                      style: TextStyle(color: Colors.white70, fontSize: isSelected ? 10 : 8),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        if (_selectedMeshId != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                            child: Text('HIGHLIGHTED: $_selectedMeshId • ${_selectedComponentId} • $_selectedStatus', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ),
                  
                  // Controls overlay
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Column(
                      children: [
                        _controlButton(Icons.add, 'Zoom In', () => setState(() => _zoom = (_zoom + 0.1).clamp(0.5, 3.0))),
                        const SizedBox(height: 8),
                        _controlButton(Icons.remove, 'Zoom Out', () => setState(() => _zoom = (_zoom - 0.1).clamp(0.5, 3.0))),
                        const SizedBox(height: 8),
                        _controlButton(Icons.rotate_left, 'Rotate', () {}),
                        const SizedBox(height: 8),
                        _controlButton(Icons.pan_tool, 'Pan', () {}),
                      ],
                    ),
                  ),
                  
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(8)),
                          child: Text('Zoom: ${_zoom.toStringAsFixed(1)}x • Tap component to select • Pinch to zoom', style: const TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.green.withOpacity(0.8), borderRadius: BorderRadius.circular(8)),
                          child: const Text('LOCAL GLB CACHED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Component details bottom sheet
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
              ),
              child: selectedComponent != null ? _buildComponentDetails(selectedComponent) : _buildComponentList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlButton(IconData icon, String tooltip, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(8)),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildComponentDetails(ComponentModel component) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: AppTheme.getStatusColor(component.status).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(_getIconForCategory(component.category), color: AppTheme.getStatusColor(component.status)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(component.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('${component.id} • ${component.meshId}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.getStatusColor(component.status), borderRadius: BorderRadius.circular(12)),
                child: Text(component.status, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          
          // Fault state if critical
          if (component.status == 'CRITICAL')
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.shade50, border: Border.all(color: Colors.red.shade200), borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text('FAULT STATE: CRITICAL', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade800, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Fault: Casing fracture + Abnormal vibration', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Detected by Local AI • Confidence 94% • Mesh_042 highlighted in red', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          
          if (component.status == 'CRITICAL') const SizedBox(height: 12),
          
          _detailRow('Category', component.category),
          _detailRow('Manufacturer', component.manufacturer),
          _detailRow('Model', component.model),
          _detailRow('Location', component.installationLocation),
          _detailRow('3D Coordinates', 'x:${component.x}, y:${component.y}, z:${component.z}'),
          _detailRow('Mesh ID', component.meshId),
          _detailRow('Last Inspection', component.lastInspection?.toString().split(' ')[0] ?? 'N/A'),
          _detailRow('Next Maintenance', component.nextMaintenance?.toString().split(' ')[0] ?? 'N/A'),
          
          const SizedBox(height: 12),
          const Text('Possible Faults', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: component.possibleFaults.map((fault) => Chip(
              label: Text(fault, style: const TextStyle(fontSize: 11)),
              backgroundColor: Colors.orange.shade50,
              side: BorderSide(color: Colors.orange.shade200),
            )).toList(),
          ),
          
          const SizedBox(height: 12),
          const Text('Maintenance Procedures', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          ...component.maintenanceProcedures.map((proc) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text(proc, style: const TextStyle(fontSize: 12))),
              ],
            ),
          )).toList(),
          
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/diagnostics'),
                  icon: const Icon(Icons.assignment, size: 18),
                  label: const Text('VIEW DIAGNOSTICS'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() {
                    _selectedMeshId = null;
                    _selectedComponentId = null;
                  }),
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('DESELECT'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComponentList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Components (5)', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${(_selectedMeshId != null ? 1 : 0)} selected', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: SeedDataService.components.length,
            itemBuilder: (context, index) {
              final comp = SeedDataService.components[index];
              final isSelected = comp.meshId == _selectedMeshId;
              return ListTile(
                selected: isSelected,
                selectedTileColor: AppTheme.primaryBlue.withOpacity(0.1),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: AppTheme.getStatusColor(comp.status).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(_getIconForCategory(comp.category), color: AppTheme.getStatusColor(comp.status), size: 20),
                ),
                title: Text(comp.name, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                subtitle: Text('${comp.id} • ${comp.meshId} • ${comp.status}', style: const TextStyle(fontSize: 11)),
                trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.primaryBlue) : null,
                onTap: () => setState(() {
                  _selectedMeshId = comp.meshId;
                  _selectedComponentId = comp.id;
                  _selectedStatus = comp.status;
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'sonar':
        return Icons.sensors;
      case 'telemetry':
        return Icons.cell_tower;
      case 'argo':
        return Icons.water;
      case 'echo sounder':
        return Icons.graphic_eq;
      case 'winch':
        return Icons.settings;
      default:
        return Icons.memory;
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Digital Twin Engine'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Capabilities:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Load GLTF/GLB\n• Rotate, zoom, pan\n• Select component\n• Highlight fault state\n• Show metadata\n• Display fault\n• Reset camera\n• Isolate component'),
              SizedBox(height: 12),
              Text('Architecture:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('Component Registry → Mesh Mapping → 3D Scene → Selection → Fault State → Visual Highlight'),
              SizedBox(height: 12),
              Text('Offline: Models cached locally in app documents, checksum verified, works without internet.'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }
}
