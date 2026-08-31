import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/local/seed_data.dart';
import '../widgets/offline_banner.dart';

class TrainingPage extends StatelessWidget {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Training'), actions: [IconButton(icon: const Icon(Icons.download), onPressed: () {})]),
      body: Column(
        children: [
          const OfflineBanner(isOffline: false, message: 'TRAINING • 2 COURSES OFFLINE AVAILABLE • LOCAL PLAYBACK'),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: SeedDataService.courses.length,
              itemBuilder: (context, index) {
                final course = SeedDataService.courses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => context.push('/training/${course['id']}'),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                child: Icon(Icons.school, color: AppTheme.primaryBlue),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(course['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    Text('${course['category']} • ${course['difficulty']} • ${course['duration_minutes']} min', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), border: Border.all(color: Colors.green), borderRadius: BorderRadius.circular(12)),
                                child: const Text('OFFLINE', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(course['description'], style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Progress', style: TextStyle(fontSize: 11, color: Colors.grey)), Text('${course['progress']}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]),
                                    const SizedBox(height: 4),
                                    LinearProgressIndicator(value: course['progress'] / 100, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue), minHeight: 4),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(onPressed: () => context.push('/training/${course['id']}'), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)), child: const Text('CONTINUE', style: TextStyle(fontSize: 11))),
                            ],
                          ),
                        ],
                      ),
                    ),
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

class TrainingDetailPage extends StatelessWidget {
  final String courseId;
  const TrainingDetailPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final course = SeedDataService.courses.firstWhere((c) => c['id'] == courseId, orElse: () => SeedDataService.courses[0]);
    final modules = course['modules'] as List;
    
    return Scaffold(
      appBar: AppBar(title: Text(course['title'])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(course['description'], style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Row(children: [
                      _infoChip(Icons.category, course['category']),
                      const SizedBox(width: 8),
                      _infoChip(Icons.signal_cellular_alt, course['difficulty']),
                      const SizedBox(width: 8),
                      _infoChip(Icons.timer, '${course['duration_minutes']} min'),
                    ]),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(value: course['progress'] / 100, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue)),
                    const SizedBox(height: 4),
                    Text('${course['progress']}% completed', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Modules', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...modules.map((module) {
              final lessons = module['lessons'] as List;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text(module['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(module['description'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  children: lessons.map<Widget>((lesson) {
                    return ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: lesson['completed'] ? Colors.green.withOpacity(0.1) : AppTheme.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Icon(lesson['type'] == 'video' ? Icons.play_circle : lesson['type'] == 'document' ? Icons.description : Icons.quiz, color: lesson['completed'] ? Colors.green : AppTheme.primaryBlue, size: 20),
                      ),
                      title: Text(lesson['title'], style: const TextStyle(fontSize: 13)),
                      subtitle: Text('${lesson['type']} • ${lesson['duration']} min • ${lesson['completed'] ? 'Completed' : 'Not started'}', style: const TextStyle(fontSize: 11)),
                      trailing: lesson['completed'] ? const Icon(Icons.check_circle, color: Colors.green, size: 20) : const Icon(Icons.play_arrow, size: 20),
                      onTap: () {
                        if (lesson['type'] == 'quiz') {
                          context.push('/quiz/quiz-001');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening ${lesson['title']} - offline playback with resume position'), backgroundColor: AppTheme.primaryBlue));
                        }
                      },
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [Icon(icon, size: 12, color: Colors.grey[600]), const SizedBox(width: 4), Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700]))]),
    );
  }
}
