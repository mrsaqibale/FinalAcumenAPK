import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acumen/features/business/controllers/quiz_controller.dart';
import 'package:acumen/features/business/screens/add_quiz_screen.dart';

class MentorQuizResultsScreen extends StatelessWidget {
  const MentorQuizResultsScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<QuizController>(
        builder: (context, quizController, child) {
          // Get quiz results from the controller
          final quizResults = quizController.getQuizResults();
          
          if (quizResults.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
            children: [
                  Icon(Icons.quiz_outlined, size: 70, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No quiz results yet',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                ),
              ),
                  SizedBox(height: 8),
                  Text(
                    'Assign quizzes to students to see results',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                const Text(
                  'Student Quiz Results',
                  style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
                const SizedBox(height: 16),
                
                // Results list
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: quizResults.length,
                  itemBuilder: (context, index) {
                    final result = quizResults[index];
                    final score = result['score'] as int;
    
    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
        child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
            children: [
                            // Student info and quiz name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                                    result['studentName'] ?? 'Unknown Student',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                                  const SizedBox(height: 4),
                          Text(
                                    result['quizName'] ?? 'Unnamed Quiz',
                            style: TextStyle(
                                      color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                                  const SizedBox(height: 4),
                      Text(
                                    'Completed: ${result['date'] ?? 'Unknown date'}',
                        style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                            ),
                            
                            // Score
                  Container(
                              width: 60,
                              height: 60,
                    decoration: BoxDecoration(
                                shape: BoxShape.circle,
                      color: _getScoreColor(score).withOpacity(0.1),
                                border: Border.all(
                                  color: _getScoreColor(score),
                                  width: 2,
                                ),
                    ),
                    child: Center(
                                child: Text(
                                  '$score%',
                                  style: TextStyle(
                        color: _getScoreColor(score),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                      ),
                    ),
                  ),
                ],
              ),
                      ),
    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to add quiz screen
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider.value(
                value: QuizController.getInstance(),
                child: const AddQuizScreen(),
              ),
            ),
          );
          
          // Show success message if quiz was added
          if (result == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Quiz added successfully!')),
            );
          }
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 75) return Colors.blue;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
} 