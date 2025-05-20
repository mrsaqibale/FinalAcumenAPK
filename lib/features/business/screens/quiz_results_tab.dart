import 'package:acumen/features/business/controllers/quiz_controller.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class QuizResultsTab extends StatefulWidget {
  const QuizResultsTab({Key? key}) : super(key: key);

  @override
  State<QuizResultsTab> createState() => _QuizResultsTabState();
}

class _QuizResultsTabState extends State<QuizResultsTab> {
  List<Map<String, dynamic>> _quizResults = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQuizResults();
  }

  Future<void> _loadQuizResults() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final quizController = Provider.of<QuizController>(context, listen: false);
      final results = await quizController.loadQuizResults();
      
      if (mounted) {
        setState(() {
          _quizResults = results;
          _isLoading = false;
        });
      }
      
      if (kDebugMode) {
        print("Loaded ${_quizResults.length} quiz results");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading quiz results: $e");
      }
      
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading quiz results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadQuizResults,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      );
    }
    
    if (_quizResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assessment_outlined,
              size: 72,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No quiz results yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When students complete quizzes, their results will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadQuizResults,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      );
    }
    
    // Group results by quiz
    final Map<String, List<Map<String, dynamic>>> groupedResults = {};
    
    for (final result in _quizResults) {
      final quizName = result['quizName'] ?? 'Unknown Quiz';
      if (!groupedResults.containsKey(quizName)) {
        groupedResults[quizName] = [];
      }
      groupedResults[quizName]!.add(result);
    }
    
    return RefreshIndicator(
      onRefresh: _loadQuizResults,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiz Results (${_quizResults.length})',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: groupedResults.length,
                itemBuilder: (context, index) {
                  final quizName = groupedResults.keys.elementAt(index);
                  final quizResults = groupedResults[quizName]!;
                  final totalSubmissions = quizResults.length;
                  
                  // Calculate average score
                  int totalScore = 0;
                  for (final result in quizResults) {
                    totalScore += (result['score'] as int?) ?? 0;
                  }
                  final averageScore = totalScore / totalSubmissions;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      title: Text(
                        quizName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '$totalSubmissions submissions • Avg. score: ${averageScore.toStringAsFixed(1)}%',
                      ),
                      leading: const Icon(
                        Icons.quiz,
                        color: AppTheme.primaryColor,
                      ),
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: quizResults.length,
                          itemBuilder: (context, i) {
                            final result = quizResults[i];
                            final studentName = result['studentName'] ?? 'Unknown Student';
                            final score = result['score'] ?? 0;
                            
                            // Format date
                            String formattedDate = 'Unknown date';
                            if (result['date'] != null) {
                              try {
                                final date = DateTime.parse(result['date']);
                                formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(date);
                              } catch (e) {
                                if (kDebugMode) {
                                  print("Error parsing date: $e");
                                }
                              }
                            }
                            
                            // Get accuracy information if available
                            String accuracyInfo = '';
                            if (result.containsKey('correctAnswers') && result.containsKey('totalQuestions')) {
                              int correctAnswers = result['correctAnswers'] as int? ?? 0;
                              int totalQuestions = result['totalQuestions'] as int? ?? 0;
                              accuracyInfo = '$correctAnswers/$totalQuestions correct';
                            }
                            
                            return ListTile(
                              title: Text(studentName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(formattedDate),
                                  if (accuracyInfo.isNotEmpty)
                                    Text(
                                      accuracyInfo,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getScoreColor(score),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '$score%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              onTap: () => _showResultDetails(context, result),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getScoreColor(int score) {
    if (score >= 90) {
      return Colors.green;
    } else if (score >= 75) {
      return Colors.blue;
    } else if (score >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
  
  void _showResultDetails(BuildContext context, Map<String, dynamic> result) {
    final studentName = result['studentName'] ?? 'Unknown Student';
    final quizName = result['quizName'] ?? 'Unknown Quiz';
    final score = result['score'] ?? 0;
    
    // Format date
    String formattedDate = 'Unknown date';
    if (result['date'] != null) {
      try {
        final date = DateTime.parse(result['date']);
        formattedDate = DateFormat('MMMM d, yyyy • h:mm a').format(date);
      } catch (e) {
        if (kDebugMode) {
          print("Error parsing date: $e");
        }
      }
    }
    
    // Get answers and detailed information
    final answers = result['answers'] as Map<String, dynamic>? ?? {};
    final correctAnswers = result['correctAnswers'] as int? ?? 0;
    final totalQuestions = result['totalQuestions'] as int? ?? 0;
    final questionDetails = result['questionDetails'] as List<dynamic>? ?? [];
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Result Details',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Student:', studentName),
              _buildDetailRow('Quiz:', quizName),
              _buildDetailRow('Date:', formattedDate),
              _buildDetailRow('Score:', '$score%'),
              
              if (correctAnswers > 0 || totalQuestions > 0)
                _buildDetailRow('Accuracy:', '$correctAnswers out of $totalQuestions correct'),
              
              if (questionDetails.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Question Details:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: questionDetails.length,
                    itemBuilder: (context, index) {
                      final detail = questionDetails[index] as Map<String, dynamic>;
                      final isAnswered = detail['isAnswered'] as bool? ?? false;
                      final isCorrect = detail['isCorrect'] as bool? ?? false;
                      final questionText = detail['questionText'] as String? ?? 'Question ${index + 1}';
                      final userAnswer = detail['userAnswer'] as String? ?? 'Not answered';
                      final correctAnswer = detail['correctAnswer'] as String? ?? 'Unknown';
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  isAnswered 
                                      ? (isCorrect ? Icons.check_circle : Icons.cancel)
                                      : Icons.remove_circle_outline,
                                  color: isAnswered 
                                      ? (isCorrect ? Colors.green : Colors.red)
                                      : Colors.grey,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Q${index + 1}: $questionText',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            if (isAnswered) ...[
                              Padding(
                                padding: const EdgeInsets.only(left: 26.0),
                                child: Text(
                                  'Answer: $userAnswer',
                                  style: TextStyle(
                                    color: isCorrect ? Colors.green : Colors.red,
                                    fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (!isCorrect && detail.containsKey('correctAnswer'))
                                Padding(
                                  padding: const EdgeInsets.only(left: 26.0),
                                  child: Text(
                                    'Correct: $correctAnswer',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ] else
                              Padding(
                                padding: const EdgeInsets.only(left: 26.0),
                                child: Text(
                                  'Not answered',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ] else if (answers.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Answers:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: answers.length,
                    itemBuilder: (context, index) {
                      final questionId = answers.keys.elementAt(index);
                      final answer = answers[questionId];
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Q${index + 1}:',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                answer.toString(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CLOSE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 