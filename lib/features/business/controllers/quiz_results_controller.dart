import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:acumen/features/profile/controllers/user_controller.dart';
import 'package:acumen/features/business/models/quiz_result_model.dart';
import 'package:acumen/features/business/models/career_suggestion_model.dart';

// Global navigator key for accessing context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Extension for UserController to provide a currentUser getter
extension UserControllerExtension on UserController {
  dynamic get currentUser => getLoggedInUser();
}

class QuizResultsController with ChangeNotifier {
  bool _isLoading = true;
  double _score = 0.0;
  List<CareerSuggestionModel> _careerSuggestions = [];
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  double get score => _score;
  List<CareerSuggestionModel> get careerSuggestions => _careerSuggestions;
  String? get error => _error;

  Future<void> processResults(Map<String, dynamic> answers, String? assignedBy) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Calculate score based on answers
      await _calculateScore(answers);
      
      // Generate career suggestions based on score
      await _generateCareerSuggestions();
      
      // Save quiz results
      await _saveQuizResults(answers, assignedBy);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error processing quiz results: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> processResultsWithDetails(Map<String, dynamic> resultData, String? assignedBy) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Use the pre-calculated score from the detailed result data
      _score = resultData['score'].toDouble();
      
      // Generate career suggestions based on score
      await _generateCareerSuggestions();
      
      // Create quiz result model
      final quizResult = QuizResultModel.anonymous(
        answers: Map<String, dynamic>.from(resultData['answers']),
        score: _score,
        correctAnswers: resultData['correctAnswers'] as int,
        totalQuestions: resultData['totalQuestions'] as int,
        questionDetails: List<Map<String, dynamic>>.from(resultData['questionDetails']),
        assignedBy: assignedBy,
      );
      
      // Save detailed quiz results
      await _saveDetailedQuizResults(quizResult);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error processing detailed quiz results: $e');
      }
      _error = 'Error processing quiz results: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _calculateScore(Map<String, dynamic> answers) async {
    try {
      // Get correct answers from backend or local storage
      final prefs = await SharedPreferences.getInstance();
      final String? correctAnswersJson = prefs.getString('correct_quiz_answers');
      
      if (correctAnswersJson == null) {
        throw Exception('Correct answers not found');
      }

      final Map<String, dynamic> correctAnswers = jsonDecode(correctAnswersJson);
      int correct = 0;
      
      for (var entry in answers.entries) {
        if (correctAnswers.containsKey(entry.key) && 
            correctAnswers[entry.key] == entry.value) {
          correct++;
        }
      }
      
      _score = (correct / correctAnswers.length) * 100;
    } catch (e) {
      throw Exception('Failed to calculate score: $e');
    }
  }

  Future<void> _generateCareerSuggestions() async {
    try {
      // Get career suggestions from backend or local storage
      final prefs = await SharedPreferences.getInstance();
      final String? suggestionsJson = prefs.getString('career_suggestions');
      
      List<CareerSuggestionModel> allSuggestions;
      
      if (suggestionsJson == null) {
        // Use default suggestions if none are found
        allSuggestions = CareerSuggestionModel.getDefaultSuggestions();
        
        // Save default suggestions for future use
        await prefs.setString('career_suggestions', 
          jsonEncode(allSuggestions.map((s) => s.toJson()).toList()));
      } else {
        final List<dynamic> jsonList = jsonDecode(suggestionsJson);
        allSuggestions = jsonList.map((json) => 
          CareerSuggestionModel.fromJson(json)).toList();
      }
      
      // Filter and calculate percentages for suggestions
      _careerSuggestions = allSuggestions
          .where((suggestion) => suggestion.minScore <= _score)
          .map((suggestion) => CareerSuggestionModel(
                title: suggestion.title,
                description: suggestion.description,
                minScore: suggestion.minScore,
                maxScore: suggestion.maxScore,
                percentage: CareerSuggestionModel.calculatePercentage(
                  _score, 
                  suggestion.minScore, 
                  suggestion.maxScore
                ),
              ))
          .toList();
          
      // Sort by percentage in descending order
      _careerSuggestions.sort((a, b) => b.percentage.compareTo(a.percentage));
          
      // Ensure we always have at least one suggestion
      if (_careerSuggestions.isEmpty) {
        _careerSuggestions = [
          CareerSuggestionModel(
            title: 'Career Exploration',
            description: 'Explore different career paths to find your passion',
            minScore: 0,
            maxScore: 100,
            percentage: 100,
          ),
        ];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error generating career suggestions: $e');
      }
      // Provide a fallback suggestion if there's an error
      _careerSuggestions = [
        CareerSuggestionModel(
          title: 'Career Exploration',
          description: 'Explore different career paths to find your passion',
          minScore: 0,
          maxScore: 100,
          percentage: 100,
        ),
      ];
    }
  }

  Future<void> _saveQuizResults(Map<String, dynamic> answers, String? assignedBy) async {
    try {
      final userController = Provider.of<UserController>(
        navigatorKey.currentContext!,
        listen: false
      );
      final currentUser = userController.currentUser;
      
      // Create quiz result model
      final quizResult = currentUser != null
          ? QuizResultModel(
              userId: currentUser.id,
              userName: currentUser.name,
              userEmail: currentUser.email,
              answers: answers,
              score: _score,
              correctAnswers: 0, // Will be updated when we have question details
              totalQuestions: answers.length,
              questionDetails: [], // Will be updated when we have question details
              date: DateTime.now(),
              assignedBy: assignedBy,
            )
          : QuizResultModel.anonymous(
              answers: answers,
              score: _score,
              correctAnswers: 0,
              totalQuestions: answers.length,
              questionDetails: [],
              assignedBy: assignedBy,
            );
      
      await _saveDetailedQuizResults(quizResult);
      
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save quiz results: $e');
      }
      // Don't throw the error, just log it and continue
    }
  }

  Future<void> _saveDetailedQuizResults(QuizResultModel quizResult) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing quiz results
      List<dynamic> existingResults = [];
      final String? resultsJson = prefs.getString('quiz_results');
      if (resultsJson != null) {
        existingResults = jsonDecode(resultsJson) as List<dynamic>;
      }
      
      // Add new result
      existingResults.add(quizResult.toJson());
      
      // Save back to SharedPreferences
      await prefs.setString('quiz_results', jsonEncode(existingResults));
      
      // Update user's quiz statistics if user is logged in
      if (quizResult.userId.startsWith('anonymous_')) {
        if (kDebugMode) {
          print('Skipping quiz stats update for anonymous user');
        }
      } else {
        await _updateUserQuizStats(quizResult.userId, existingResults);
      }
      
      if (kDebugMode) {
        print('Saved quiz result with score: ${quizResult.score}%');
        print('Correct answers: ${quizResult.correctAnswers} out of ${quizResult.totalQuestions}');
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save detailed quiz results: $e');
      }
      // Don't throw the error, just log it and continue
    }
  }

  Future<void> _updateUserQuizStats(String userId, List<dynamic> allResults) async {
    try {
      final userResults = allResults.where((result) => 
          (result as Map<String, dynamic>)['userId'] == userId).toList();
      
      final userQuizStats = {
        'totalQuizzes': userResults.length,
        'averageScore': userResults.isEmpty ? 0 : 
            userResults.map((r) => (r as Map<String, dynamic>)['score'] as num)
                .reduce((a, b) => a + b) / userResults.length,
        'lastQuizDate': DateTime.now().toIso8601String(),
      };
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_${userId}_quiz_stats', jsonEncode(userQuizStats));
      
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update user quiz stats: $e');
      }
      // Don't throw the error, just log it and continue
    }
  }
} 