import 'package:flutter/foundation.dart';
import 'package:acumen/features/business/models/quiz_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizController with ChangeNotifier {
  // Singleton instance for the entire app
  static QuizController? _instance;
  
  static QuizController getInstance() {
    _instance ??= QuizController();
    return _instance!;
  }

  final List<QuizQuestion> _questions;
  final Map<String, String> _answers = {};
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  String? _error;
  final List<Map<String, dynamic>> _quizzes = [];
  final List<Map<String, dynamic>> _quizResults = [];

  QuizController({List<QuizQuestion>? questions})
      : _questions = questions ?? QuizModel.defaultQuestions {
    // Initialize with empty lists
    _quizzes.clear();
    _quizResults.clear();
    
    // Load real quizzes from database
    _loadQuizzes();
  }

  // Getters
  List<QuizQuestion> get questions => _questions;
  Map<String, String> get answers => _answers;
  int get currentQuestionIndex => _currentQuestionIndex;
  QuizQuestion get currentQuestion => _questions[_currentQuestionIndex];
  int get totalQuestions => _questions.length;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLastQuestion => _currentQuestionIndex == _questions.length - 1;
  bool get isFirstQuestion => _currentQuestionIndex == 0;
  double get progress => (_currentQuestionIndex + 1) / _questions.length;
  List<Map<String, dynamic>> get quizzes => [..._quizzes];
  
  // Get quiz by ID
  Map<String, dynamic>? getQuizById(String id) {
    try {
      return _quizzes.firstWhere((quiz) => quiz['id'] == id);
    } catch (e) {
      if (kDebugMode) {
        print('Quiz not found: $e');
      }
      return null;
    }
  }
  
  // Get quizzes assigned to a specific student
  List<Map<String, dynamic>> getAssignedQuizzes(String studentId) {
    return _quizzes.where((quiz) {
      if (quiz['assignToAll'] == true) {
        return true;
      }
      final selectedStudents = quiz['selectedStudents'] as List?;
      return selectedStudents != null && selectedStudents.contains(studentId);
    }).toList();
  }
  
  // Get all quiz results
  List<Map<String, dynamic>> getQuizResults() {
    return [..._quizResults];
  }

  // Answer the current question
  void answerQuestion(String answer) {
    _answers[currentQuestion.id] = answer;
    notifyListeners();
  }

  // Move to next question
  bool nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Move to previous question
  bool previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Check if current question is answered
  bool isQuestionAnswered(String questionId) {
    return _answers.containsKey(questionId);
  }

  // Get answer for a specific question
  String? getAnswerForQuestion(String questionId) {
    return _answers[questionId];
  }

  // Reset the quiz
  void resetQuiz() {
    _currentQuestionIndex = 0;
    _answers.clear();
    _error = null;
    notifyListeners();
  }

  // Validate if all questions are answered
  bool areAllQuestionsAnswered() {
    return _questions.every((question) => _answers.containsKey(question.id));
  }

  // Get unanswered questions
  List<String> getUnansweredQuestions() {
    return _questions
        .where((question) => !_answers.containsKey(question.id))
        .map((question) => question.id)
        .toList();
  }

  void addAnswer(String questionId, String answer) {
    _answers[questionId] = answer;
    notifyListeners();
  }

  void clearAnswers() {
    _answers.clear();
    notifyListeners();
  }
  
  // New method to load quizzes from database
  Future<void> _loadQuizzes() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      if (kDebugMode) {
        print('Loading quizzes from database...');
      }
      
      // Load quizzes from Firestore
      final firestore = FirebaseFirestore.instance;
      final quizzesSnapshot = await firestore.collection('quizzes')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();
      
      // Clear existing quizzes and add from database
      _quizzes.clear();
      for (var doc in quizzesSnapshot.docs) {
        _quizzes.add({
          'id': doc.id,
          ...doc.data(),
        });
      }
      
      if (kDebugMode) {
        print('Loaded ${_quizzes.length} quizzes from database');
      }
    } catch (e) {
      _error = 'Failed to load quizzes: $e';
      if (kDebugMode) {
        print(_error);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Method to reload quizzes (call when new quizzes might be available)
  Future<void> refreshQuizzes() async {
    await _loadQuizzes();
  }
  
  // Override the addQuiz method to save to database as well
  Future<bool> addQuiz(Map<String, dynamic> quizData) async {
    _isLoading = true;
    notifyListeners();
    
    try {
    // Generate a unique ID for the quiz
    final String quizId = 'quiz_${DateTime.now().millisecondsSinceEpoch}';
    
      // Ensure all questions have IDs
      if (quizData.containsKey('questions') && quizData['questions'] is List) {
        final questions = quizData['questions'] as List;
        for (int i = 0; i < questions.length; i++) {
          if (questions[i] is Map) {
            final question = questions[i] as Map;
            // If question has no ID, generate one
            if (!question.containsKey('id') || question['id'] == null || question['id'].toString().isEmpty) {
              final String questionId = 'q_${DateTime.now().millisecondsSinceEpoch}_${i}_${(1000 + i)}';
              question['id'] = questionId;
            }
          }
        }
      }
    
      // Create the complete quiz data
      final completeQuizData = {
      ...quizData,
      'id': quizId,
      'createdAt': DateTime.now().toIso8601String(),
        'isActive': true,
        'createdBy': FirebaseAuth.instance.currentUser?.uid,
      };
      
      // Save to Firestore
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('quizzes').doc(quizId).set(completeQuizData);
      
      // Add to local list
      _quizzes.add(completeQuizData);
    
    // Notify listeners that the quiz list has changed
    notifyListeners();
    
    if (kDebugMode) {
      print('Quiz added successfully: $quizId');
      print('Total quizzes: ${_quizzes.length}');
  }
  
      return true;
    } catch (e) {
      _error = 'Failed to add quiz: $e';
      if (kDebugMode) {
        print(_error);
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Override the deleteQuiz method to update database as well
  Future<bool> deleteQuiz(String quizId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Remove from Firestore
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('quizzes').doc(quizId).update({
        'isActive': false,
        'deletedAt': DateTime.now().toIso8601String(),
      });
      
      // Remove from local list
    final initialLength = _quizzes.length;
    _quizzes.removeWhere((quiz) => quiz['id'] == quizId);
    
    final removed = _quizzes.length < initialLength;
    if (removed) {
      notifyListeners();
      if (kDebugMode) {
        print('Quiz deleted: $quizId');
      }
    }
    
    return removed;
    } catch (e) {
      _error = 'Failed to delete quiz: $e';
      if (kDebugMode) {
        print(_error);
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Add a quiz result to database as well
  Future<void> addQuizResult(Map<String, dynamic> result) async {
    try {
      final resultWithMetadata = {
      ...result,
      'id': 'result_${DateTime.now().millisecondsSinceEpoch}',
      'date': DateTime.now().toIso8601String(),
        'userId': FirebaseAuth.instance.currentUser?.uid,
      };
      
      // Save to local list
      _quizResults.add(resultWithMetadata);
      
      // Save to Firestore
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('quiz_results').add(resultWithMetadata);
      
    notifyListeners();
    
    if (kDebugMode) {
      print('Quiz result added: ${result['studentName']} - Score: ${result['score']}%');
    }
    } catch (e) {
      _error = 'Failed to add quiz result: $e';
      if (kDebugMode) {
        print(_error);
      }
    }
  }
  
  // Load quiz results for a specific quiz or all quizzes
  Future<List<Map<String, dynamic>>> loadQuizResults({String? quizId}) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Load from Firestore
      final firestore = FirebaseFirestore.instance;
      late QuerySnapshot resultsSnapshot;
      
      if (quizId != null) {
        resultsSnapshot = await firestore.collection('quiz_results')
            .where('quizId', isEqualTo: quizId)
            .orderBy('date', descending: true)
            .get();
      } else {
        resultsSnapshot = await firestore.collection('quiz_results')
            .orderBy('date', descending: true)
            .get();
      }
      
      // Convert to list of maps
      final results = resultsSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
      
      return results;
    } catch (e) {
      _error = 'Failed to load quiz results: $e';
      if (kDebugMode) {
        print(_error);
      }
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Check if a quiz has video
  bool quizHasVideo(String quizId) {
    final quiz = getQuizById(quizId);
    if (quiz == null) return false;
    
    return quiz['videoUrl'] != null && quiz['videoUrl'].toString().isNotEmpty;
  }
  
  // Get video ID from quiz
  String? getVideoIdFromQuiz(String quizId) {
    final quiz = getQuizById(quizId);
    if (quiz == null) return null;
    
    final videoUrl = quiz['videoUrl'];
    if (videoUrl == null || videoUrl.toString().isEmpty) return null;
    
    try {
      final Uri uri = Uri.parse(videoUrl.toString());
      if (uri.host.contains('youtu.be')) {
        return uri.pathSegments.last;
      } else if (uri.host.contains('youtube.com')) {
        return uri.queryParameters['v'];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing video URL: $e');
      }
    }
    
    return null;
  }
} 