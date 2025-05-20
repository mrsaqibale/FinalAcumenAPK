import 'package:acumen/features/business/controllers/quiz_controller.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuizManagementTab extends StatelessWidget {
  final VoidCallback onAddQuiz;
  final Function(String) onDeleteQuiz;
  final VoidCallback onRefresh;

  const QuizManagementTab({
    Key? key,
    required this.onAddQuiz,
    required this.onDeleteQuiz,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizController>(
      builder: (context, quizController, child) {
        final quizzes = quizController.quizzes;
        
        if (quizzes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz, size: 70, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No quizzes added yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to add a new quiz',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onAddQuiz,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Quiz'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            final title = quiz['title'] ?? 'Untitled Quiz';
            final description = quiz['description'] ?? 'No description';
            
            // Safely get questions count
            int questionsCount = 0;
            if (quiz['questions'] != null && quiz['questions'] is List) {
              questionsCount = (quiz['questions'] as List).length;
            }
            
            // Format creation date
            String formattedDate = 'Unknown date';
            try {
              if (quiz['createdAt'] != null) {
                final createdAt = DateTime.parse(quiz['createdAt']).toLocal();
                formattedDate = '${createdAt.day}/${createdAt.month}/${createdAt.year}';
              }
            } catch (e) {
              if (kDebugMode) {
                print('Error parsing date: $e');
              }
            }
            
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.quiz, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            if (value == 'edit') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Edit functionality coming soon')),
                              );
                            } else if (value == 'delete') {
                              _showDeleteConfirmation(context, quiz['id']);
                            } else if (value == 'assign') {
                              _showAssignQuizDialog(context, quiz);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'assign',
                              child: Row(
                                children: [
                                  Icon(Icons.assignment_ind, size: 18),
                                  SizedBox(width: 8),
                                  Text('Assign'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$questionsCount Questions',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Created: $formattedDate',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    if (quiz['videoUrl'] != null && quiz['videoUrl'].toString().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.videocam, size: 16, color: Colors.blue[700]),
                          const SizedBox(width: 4),
                          Text(
                            'Has intro video',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _showQuizDetailsDialog(context, quiz);
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppTheme.primaryColor),
                            ),
                            child: const Text('Preview'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _showAssignQuizDialog(context, quiz);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                            ),
                            child: const Text('Assign'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String quizId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quiz'),
        content: const Text('Are you sure you want to delete this quiz? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDeleteQuiz(quizId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  void _showQuizDetailsDialog(BuildContext context, Map<String, dynamic> quiz) {
    // Safely extract questions
    List<Map<String, dynamic>> questions = [];
    if (quiz['questions'] != null && quiz['questions'] is List) {
      questions = (quiz['questions'] as List).map((q) {
        if (q is Map) {
          return Map<String, dynamic>.from(q);
        } else {
          return {'error': 'Invalid question format'};
        }
      }).toList();
    }
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quiz['title'] ?? 'Untitled Quiz',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                quiz['description'] ?? 'No description',
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Questions:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: questions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final question = entry.value;
                      final options = question['options'] as List? ?? [];
                      
                      // Safely get correct option index
                      int correctIndex = 0;
                      if (question.containsKey('correctOptionIndex')) {
                        correctIndex = question['correctOptionIndex'] as int? ?? 0;
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Q${index + 1}. ${question['question'] ?? 'Unknown question'}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            ...options.asMap().entries.map((optionEntry) {
                              final optionIndex = optionEntry.key;
                              final option = optionEntry.value;
                              final isCorrect = optionIndex == correctIndex;
                              
                              return Padding(
                                padding: const EdgeInsets.only(left: 16, top: 4),
                                child: Row(
                                  children: [
                                    isCorrect
                                        ? const Icon(Icons.check_circle, color: Colors.green, size: 16)
                                        : const Icon(Icons.circle_outlined, color: Colors.grey, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        option.toString(),
                                        style: TextStyle(
                                          color: isCorrect ? Colors.green : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CLOSE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAssignQuizDialog(BuildContext context, Map<String, dynamic> quiz) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Quiz'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select students to assign "${quiz['title']}"'),
            const SizedBox(height: 16),
            const CheckboxListTile(
              title: Text('All Students'),
              value: true,
              onChanged: null,
            ),
            const SizedBox(height: 8),
            const Text('Or select individual students:'),
            const SizedBox(height: 8),
            const CheckboxListTile(
              title: Text('John Doe'),
              value: false,
              onChanged: null,
            ),
            const CheckboxListTile(
              title: Text('Jane Smith'),
              value: false,
              onChanged: null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Quiz assigned successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('ASSIGN'),
          ),
        ],
      ),
    );
  }
} 