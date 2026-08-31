import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double? progress;
  final VoidCallback? onTap;
  
  const StatusCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: Icon(icon, size: 16, color: color),
                  ),
                  if (onTap != null) Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey[400]),
                ],
              ),
              const Spacer(),
              Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
              Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              if (progress != null) ...[
                const SizedBox(height: 6),
                LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 3),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
