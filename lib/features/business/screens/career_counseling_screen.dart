import 'package:acumen/features/career/screens/quiz_question_screen.dart';
import 'package:acumen/features/career/screens/video_intro_screen.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:acumen/features/business/controllers/quiz_controller.dart';
import 'package:acumen/features/business/widgets/quiz_intro_card.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class CareerCounselingScreen extends StatefulWidget {
  const CareerCounselingScreen({super.key});

  @override
  State<CareerCounselingScreen> createState() => _CareerCounselingScreenState();
}

class _CareerCounselingScreenState extends State<CareerCounselingScreen> {
  bool _isLoading = false;
  String? _error;
  bool _showAdditionalQuizzes = false;
  
  @override
  void initState() {
    super.initState();
    _refreshQuizzes();
  }

  Future<void> _refreshQuizzes() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final controller = QuizController.getInstance();
      await controller.refreshQuizzes();
    } catch (e) {
      if (kDebugMode) {
        print("Error refreshing quizzes: $e");
      }
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading quizzes: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: QuizController.getInstance(),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          title: Text(
            _showAdditionalQuizzes ? 'Additional Quizzes' : 'Career counseling',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          leading: IconButton(
            icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
            onPressed: () {
              if (_showAdditionalQuizzes) {
                setState(() {
                  _showAdditionalQuizzes = false;
                });
              } else {
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _refreshQuizzes,
              tooltip: 'Refresh Quizzes',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _error != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading quizzes',
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
                    onPressed: _refreshQuizzes,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            )
            : Consumer<QuizController>(
          builder: (context, controller, child) {
            if (_showAdditionalQuizzes) {
              // Show additional quizzes
              return controller.quizzes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.quiz, color: Colors.grey[400], size: 64),
                        const SizedBox(height: 16),
                        Text(
                          "No additional quizzes available",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Mentors can create quizzes that will appear here",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showAdditionalQuizzes = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Back to Main Quiz"),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refreshQuizzes,
                    child: ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        // Optional back button at the top
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _showAdditionalQuizzes = false;
                              });
                            },
                            icon: const Icon(Icons.arrow_back),
                            label: const Text("Back to Main Quiz"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              foregroundColor: Colors.black,
                            ),
                          ),
                        ),
                        
                        ...controller.quizzes.map((quiz) {
                          final String title = quiz['title'] ?? 'Untitled Quiz';
                          final String description = quiz['description'] ?? 'No description';
                          final String? videoUrl = quiz['videoUrl'];
                          final bool hasVideo = videoUrl != null && videoUrl.isNotEmpty;
                          final int watchTime = quiz['watchTimeInMinutes'] ?? 0;
                          
                          // Ensure questions is a list of maps
                          List<Map<String, dynamic>> questions = [];
                          if (quiz['questions'] != null) {
                            if (quiz['questions'] is List) {
                              questions = (quiz['questions'] as List).map((q) {
                                if (q is Map) {
                                  return Map<String, dynamic>.from(q);
                                } else {
                                  return {'error': 'Invalid question format'};
                                }
                              }).toList();
                            }
                          }
                          
                          final int questionsCount = questions.length;
                          final int questionsPerPage = quiz['questionsPerPage'] ?? 5;
                          
                          // Extract video ID
                          String videoId = "";
                          if (hasVideo) {
                            final extractedId = _extractVideoId(videoUrl!);
                            if (extractedId != null) {
                              videoId = extractedId;
                            }
                          }
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Quiz Title
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // Description
                                  Text(
                                    description,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Additional Info
                                  Row(
                                    children: [
                                      // Questions count
                                      Icon(Icons.quiz, color: AppTheme.primaryColor, size: 18),
                                      const SizedBox(width: 4),
                                      Text('$questionsCount Questions'),
                                      
                                      const SizedBox(width: 16),
                                      
                                      // Video info (if available)
                                      if (hasVideo) ...[
                                        Icon(Icons.videocam, color: AppTheme.primaryColor, size: 18),
                                        const SizedBox(width: 4),
                                        Text('$watchTime min video'),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Start Quiz Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        controller.clearAnswers(); // Clear previous answers
                                        
                                        // Always use _startQuiz which will handle video if needed
                                        _startQuiz(context, quiz, controller);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        minimumSize: const Size(double.infinity, 48),
                                      ),
                                      child: const Text(
                                        'Start Quiz',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
            } else {
              // Show main quiz
              return RefreshIndicator(
                onRefresh: _refreshQuizzes,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Default Career Assessment Quiz Card
                    QuizIntroCard(
                      onStartQuiz: () {
                        // Change to show additional quizzes instead of starting the quiz directly
                        setState(() {
                          _showAdditionalQuizzes = true;
                        });
                      },
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
  
  // Extract YouTube video ID from URL
  String? _extractVideoId(String url) {
    try {
      final Uri uri = Uri.parse(url);
      if (uri.host.contains('youtu.be')) {
        return uri.pathSegments.last;
      } else if (uri.host.contains('youtube.com')) {
        return uri.queryParameters['v'];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error extracting video ID: $e");
      }
    }
    return null;
  }
  
  // Helper method to start a quiz
  void _startQuiz(BuildContext context, Map<String, dynamic> quiz, QuizController controller) {
    final String quizId = quiz['id'];
    final String title = quiz['title'] ?? 'Untitled Quiz';
    
    // Ensure questions is a list of maps
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
    
    final int questionsPerPage = quiz['questionsPerPage'] ?? 5;
    
    // Extract video ID from URL if available
    final String? videoUrl = quiz['videoUrl'];
    final int watchTime = quiz['watchTimeInMinutes'] ?? 0;
    String videoId = "";
    
    if (videoUrl != null && videoUrl.isNotEmpty) {
      final extractedId = _extractVideoId(videoUrl);
      if (extractedId != null) {
        videoId = extractedId;
      }
    }
    
    if (kDebugMode) {
      print("Starting quiz: $title with ${questions.length} questions");
      print("Quiz parameters: questionsPerPage=$questionsPerPage, videoId=$videoId, watchTime=$watchTime");
    }
    
    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No questions found in this quiz!')),
      );
      return;
    }
    
    try {
      // If there's a video, go to the VideoIntroScreen first
      if (videoId.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoIntroScreen(
              videoId: videoId,
              quizTitle: title,
              watchTimeMinutes: watchTime,
              onComplete: () {
                // Navigate to quiz screen after video
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizQuestionScreen(
                      currentQuestion: 1,
                      totalQuestions: questions.length,
                      questions: questions,
                      answers: {},
                      videoId: "",
                      questionsPerPage: questionsPerPage,
                      onComplete: (answers, score) {
                        // Save quiz result to controller
                        controller.addQuizResult({
                          'quizId': quizId,
                          'quizName': title,
                          'studentName': 'Current User', // In a real app, get actual user name
                          'score': score,
                          'answers': answers,
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );
      } else {
        // No video, go directly to quiz
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizQuestionScreen(
              currentQuestion: 1,
              totalQuestions: questions.length,
              questions: questions,
              answers: {},
              videoId: "",
              questionsPerPage: questionsPerPage,
              onComplete: (answers, score) {
                // Save quiz result to controller
                controller.addQuizResult({
                  'quizId': quizId,
                  'quizName': title,
                  'studentName': 'Current User', // In a real app, get actual user name
                  'score': score,
                  'answers': answers,
                });
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error starting quiz: $e");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting quiz: $e')),
      );
    }
  }
} 
