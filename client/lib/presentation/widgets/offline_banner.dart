import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  final bool isOffline;
  final String? message;
  
  const OfflineBanner({super.key, required this.isOffline, this.message});

  @override
  Widget build(BuildContext context) {
    if (!isOffline && message == null) {
      return const SizedBox.shrink();
    }
    
    // If offline, show offline banner, otherwise if message provided show custom
    final showOffline = isOffline;
    final text = message ?? (isOffline ? 'OFFLINE • LOCAL ENGINE ACTIVE' : 'ONLINE • CLOUD CONNECTED');
    final color = showOffline ? Colors.red : Colors.green;
    final icon = showOffline ? Icons.wifi_off : Icons.wifi;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          if (showOffline) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
              child: Text('LOCAL AI', style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }
}
