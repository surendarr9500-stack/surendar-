# CAPACITY CONNECT - Digital Twin Design

## 1. Overview
Digital Twin is a 3D visualization of vessel / equipment with component mapping. Must work offline with locally cached GLB/GLTF assets. Highlights fault states from AI engine and diagnostics.

## 2. Asset Management

### Models
- Whole vessel model: `vessel.glb` (optional)
- Component models: individual GLB per component or single scene with named meshes
- Mapping: mesh name = mesh_id (e.g., Mesh_042) corresponds to component SONAR-001

### Storage
- Remote URL: from backend `/api/v1/digital-twin/models/{mesh_id}/download`
- Local path: `app_documents/digital_twin/{mesh_id}.glb`
- Metadata in `digital_twin_models` table: file_path, checksum, version, is_downloaded
- Fallback: if GLB not available, show 2D schematic or component list with status colors

### Initial Demo Assets
For hackathon, we provide:
- Procedural placeholder GLB or simple colored boxes representing components
- Or use `model_viewer_plus` with demo models from Google
- Ensure Mesh_042, Mesh_109, Mesh_210, Mesh_315, Mesh_410 exist as nodes

## 3. Rendering Abstraction

Interface `DigitalTwinRenderer`:

```dart
abstract class DigitalTwinRenderer {
  Future<void> loadModel(String path);
  Future<void> highlightComponent(String meshId, ComponentStatus status);
  Future<void> isolateComponent(String meshId);
  Future<void> resetCamera();
  Future<void> selectComponent(String meshId);
  void setOnComponentSelected(Function(String meshId) callback);
  Widget buildViewer();
}
```

Implementations:
- `ModelViewerRenderer` using `model_viewer_plus` (best for Web/Android, supports GLB, camera controls, JS interop for highlighting via annotations)
- `O3DRenderer` using `o3d` package
- `FallbackRenderer` - 2D list with status colors, when 3D not available

For production, we use `model_viewer_plus` as primary because it supports:
- GLTF/GLB loading
- Rotate, zoom, pan (built-in)
- Annotations for component selection
- Programmatic camera control
- Material override via JS (for fault highlighting)

## 4. Component State Model

```dart
enum ComponentStatus {
  NORMAL,    // green
  WARNING,   // yellow
  DEGRADED,  // orange
  CRITICAL,  // red
  MAINTENANCE, // blue
  OFFLINE,   // gray
  UNKNOWN    // light gray
}

class DigitalTwinState {
  final String meshId;
  final ComponentStatus status;
  final String? fault;
  final DateTime updatedAt;
}
```

Mapping status -> color:
- NORMAL: #4CAF50
- WARNING: #FFC107
- DEGRADED: #FF9800
- CRITICAL: #F44336
- MAINTENANCE: #2196F3
- OFFLINE: #9E9E9E
- UNKNOWN: #BDBDBD

State stored in:
- Local DB `components.status`
- In-memory `DigitalTwinStateService` (Riverpod provider)
- Cloud sync via `/api/v1/digital-twin/state`

## 5. Interaction Flow

```
Component Registry (DB)
       ↓
Mesh Mapping (component.mesh_id -> scene node)
       ↓
3D Scene Load
       ↓
Component Selection (user taps mesh)
       ↓
Fault State Lookup (from state service)
       ↓
Visual Highlight (emissive color + outline)
       ↓
Show Details Bottom Sheet (component metadata, fault, actions)
```

AI Integration:
```
AI Result {component_id, mesh_id, severity}
   ↓
DigitalTwinStateService.updateState(mesh_id, severity->status, fault)
   ↓
Renderer.highlightComponent(mesh_id, status)
   ↓
Camera animates to component (optional)
```

## 6. UI Features

- Load GLB
- Rotate (orbit)
- Zoom (pinch/scroll)
- Pan
- Select component (tap)
- Highlight component (color change)
- Show component metadata (bottom sheet)
- Display fault state (banner + color)
- Reset camera button
- Isolate component button (hide others)
- Show component details button
- Toggle wireframe / labels
- Search component -> focus

## 7. Performance

- GLB files optimized: <10MB each, Draco compressed
- Lazy load: only load visible models
- Use isolates for parsing
- Cache rendered thumbnails
- 60fps target, reduce draw calls

## 8. Offline

- Models cached locally, works without internet
- If model not cached, show placeholder and allow download when online
- State still works without model (list view)

## 9. Security

- Models integrity checked via SHA256 checksum
- No executable code in GLB (validate)
- Access control: only authenticated users can view twin (role check)

## 10. Testing

- Unit: state mapping, status -> color, mesh_id resolution
- Widget: renderer loads, highlight changes color, selection callback
- Integration: AI result -> highlight -> details shown
- Failure: model missing -> fallback, corrupted GLB -> error handling

## 11. Demo Scenario

- Load vessel twin
- AI identifies SONAR-001 / Mesh_042 HIGH
- Twin highlights Mesh_042 in red
- User taps Mesh_042 -> shows "Sonar Transducer Array - CRITICAL - Casing fracture"
- User taps "View Diagnostic Guidance" -> navigates to diagnostic page
