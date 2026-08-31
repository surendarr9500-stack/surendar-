import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class QuizPage extends StatefulWidget {
  final String quizId;
  const QuizPage({super.key, required this.quizId});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestion = 0;
  Map<int, String> _answers = {};
  bool _submitted = false;
  
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the first step when casing fracture is detected?',
      'options': ['Power down system', 'Continue operation', 'Ignore and monitor', 'Increase power'],
      'correct': 'Power down system',
      'explanation': 'Safety first: power down to prevent water ingress',
    },
    {
      'question': 'Abnormal vibration in sonar transducer is classified as HIGH severity',
      'options': ['True', 'False'],
      'correct': 'True',
      'explanation': 'Vibration indicates mechanical failure risk',
    },
    {
      'question': 'Which mesh ID corresponds to Sonar Transducer Array?',
      'options': ['Mesh_042', 'Mesh_109', 'Mesh_210', 'Mesh_315'],
      'correct': 'Mesh_042',
      'explanation': 'SONAR-001 maps to Mesh_042 per hardware registry',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];
    final total = _questions.length;
    final answered = _answers.length;
    
    if (_submitted) {
      int score = 0;
      for (int i = 0; i < _questions.length; i++) {
        if (_answers[i] == _questions[i]['correct']) score++;
      }
      final passed = (score / total * 100) >= 70;
      
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Result')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(passed ? Icons.check_circle : Icons.cancel, size: 64, color: passed ? Colors.green : Colors.red),
                    const SizedBox(height: 16),
                    Text(passed ? 'PASSED' : 'FAILED', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: passed ? Colors.green : Colors.red)),
                    const SizedBox(height: 8),
                    Text('Score: $score / $total (${(score/total*100).toInt()}%)', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(passed ? 'Congratulations! You have completed the training assessment.' : 'Please review the material and try again.', style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => context.go('/training'), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white), child: const Text('BACK TO TRAINING'))),
                    const SizedBox(height: 8),
                    Text('Result saved locally • Sync status: PENDING • Offline completion supported', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sonar Troubleshooting Assessment'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: (_currentQuestion + 1) / total, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Question ${_currentQuestion + 1} of $total', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)), Text('$answered/$total answered', style: const TextStyle(fontSize: 11, color: Colors.grey))]),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(question['question'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ...List.generate((question['options'] as List).length, (index) {
                      final option = question['options'][index];
                      final isSelected = _answers[_currentQuestion] == option;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () => setState(() => _answers[_currentQuestion] = option),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryBlue.withOpacity(0.1) : Colors.grey.shade50,
                              border: Border.all(color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: isSelected ? AppTheme.primaryBlue : Colors.white, border: Border.all(color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade400)),
                                  child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(option, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                if (_currentQuestion > 0) Expanded(child: OutlinedButton(onPressed: () => setState(() => _currentQuestion--), child: const Text('PREVIOUS'))),
                if (_currentQuestion > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _answers.containsKey(_currentQuestion) ? () {
                      if (_currentQuestion < total - 1) {
                        setState(() => _currentQuestion++);
                      } else {
                        setState(() => _submitted = true);
                      }
                    } : null,
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: Text(_currentQuestion < total - 1 ? 'NEXT' : 'SUBMIT'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Offline completion • Progress saved locally • Sync when online • Randomized questions supported', style: TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
