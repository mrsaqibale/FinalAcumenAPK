import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import 'package:acumen/features/business/screens/quiz_results_screen.dart';

class QuizQuestionScreen extends StatefulWidget {
  final int currentQuestion;
  final int totalQuestions;
  final List<Map<String, dynamic>> questions;
  final Map<String, dynamic> answers;
  final String? assignedBy;
  final String? videoId;
  final int questionsPerPage;
  final int watchTimeMinutes;
  final Function(Map<String, dynamic>, int)? onComplete;

  const QuizQuestionScreen({
    super.key,
    this.currentQuestion = 1,
    this.totalQuestions = 5,
    required this.questions,
    required this.answers,
    this.assignedBy,
    this.videoId = 'dQw4w9WgXcQ', // Default video if none provided
    this.questionsPerPage = 1,
    this.watchTimeMinutes = 3,
    this.onComplete,
  });

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  late int _currentPage;
  late Map<String, dynamic> _answers;
  late PageController _pageController;
  late Map<String, dynamic> currentQuestionData;
  String? selectedOption;
  bool _videoWatched = false;
  late YoutubePlayerController _controller;
  Duration _currentPosition = Duration.zero;
  Duration _requiredWatchTime = Duration.zero;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _currentPage = ((widget.currentQuestion - 1) ~/ widget.questionsPerPage) + 1;
    _answers = Map<String, dynamic>.from(widget.answers);
    _pageController = PageController(initialPage: _currentPage - 1);
    _requiredWatchTime = Duration(minutes: widget.watchTimeMinutes);
    
    // Make sure we have valid questions before proceeding
    if (widget.questions.isNotEmpty) {
    currentQuestionData = widget.questions[widget.currentQuestion - 1];
    
    // Check if there's a saved answer for this question
    if (widget.answers.containsKey(currentQuestionData['id'])) {
      selectedOption = widget.answers[currentQuestionData['id']];
    }
    } else {
      // Handle empty questions case
      if (kDebugMode) {
        print("Warning: No questions provided to QuizQuestionScreen");
      }
    }
    
    // Only initialize video player if videoId is provided
    if (widget.videoId != null && widget.videoId!.isNotEmpty) {
    // Initialize YouTube player
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        forceHD: false,
          disableDragSeek: false, // Allow seeking
        loop: false,
        enableCaption: true,
        captionLanguage: 'en',
      ),
    );
    
    // Add listener to track video completion
    _controller.addListener(_videoListener);
      
      // Check if video has been watched
      _checkVideoStatus();
    } else {
      // If no video, mark as watched
      _videoWatched = true;
    }
  }

  @override
  void dispose() {
    if (widget.videoId != null && widget.videoId!.isNotEmpty) {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _checkVideoStatus() async {
    if (widget.currentQuestion > 1) {
      // If not the first question, we've already watched the video
      setState(() {
        _videoWatched = true;
      });
      return;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final bool watched = prefs.getBool('video_${widget.videoId}_watched') ?? false;
    
    setState(() {
      _videoWatched = watched;
    });
  }

  void _videoListener() {
    if (!mounted) return;

    final position = _controller.value.position;
    
    // Start the timer when video starts playing
    if (_startTime == null && position.inSeconds > 0) {
      _startTime = DateTime.now();
      if (kDebugMode) {
        print("Video started playing at: $_startTime");
        print("Required watch time: ${_requiredWatchTime.inMinutes} minutes");
      }
    }
    
    setState(() {
      _currentPosition = position;
    });

    // Check if required watch time has elapsed
    if (_startTime != null) {
      final elapsedTime = DateTime.now().difference(_startTime!);
      if (kDebugMode) {
        print("Elapsed time: ${elapsedTime.inMinutes}:${elapsedTime.inSeconds % 60}");
      }
      if (elapsedTime >= _requiredWatchTime && !_videoWatched) {
        if (kDebugMode) {
          print("Required watch time completed!");
        }
      _setVideoAsWatched();
      }
    }
  }

  Future<void> _setVideoAsWatched() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('video_${widget.videoId}_watched', true);
    
    setState(() {
      _videoWatched = true;
    });
  }

  void _selectAnswer(String questionId, String answer) {
    if (kDebugMode) {
      print("Selecting answer: questionId=$questionId, answer=$answer");
      print("Current answers before update: $_answers");
    }
    
    // Using setState to update the UI
    setState(() {
      _answers[questionId] = answer;
      
      // Debug logging
      if (kDebugMode) {
        print("Updated answers: $_answers");
      }
    });
    
    // Add haptic feedback
    HapticFeedback.mediumImpact();
  }

  bool _canGoNext() {
    final startQuestionIndex = (_currentPage - 1) * widget.questionsPerPage;
    final endQuestionIndex = _currentPage * widget.questionsPerPage;
    final pageQuestions = widget.questions.sublist(
      startQuestionIndex,
      endQuestionIndex > widget.totalQuestions ? widget.totalQuestions : endQuestionIndex,
    );
    
    // Check if all questions on this page have answers
    return pageQuestions.every((q) {
      // Get the question ID, generate one if missing
      String qId = q['id']?.toString() ?? '';
      if (qId.isEmpty) {
        qId = _generateQuestionId(q);
        q['id'] = qId; // Store the generated ID
      }
      return _answers.containsKey(qId);
    });
  }

  void _goToNextPage() {
    if (_currentPage < (widget.totalQuestions / widget.questionsPerPage).ceil()) {
      setState(() {
        _currentPage++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Calculate score based on answers
      int correctAnswers = 0;
      int totalQuestions = widget.questions.length;
      List<Map<String, dynamic>> questionDetails = [];
      
      // For the default career assessment quiz which doesn't have correct answers,
      // we just calculate a random score between 70-100
      int score = 0;
      
      if (widget.questions.isNotEmpty && widget.questions[0].containsKey('correctOptionIndex')) {
        // For quizzes with correct answers, calculate actual score
        for (var i = 0; i < widget.questions.length; i++) {
          final question = widget.questions[i];
          
          // Get the question ID, generate one if missing
          String questionId = question['id']?.toString() ?? '';
          if (questionId.isEmpty) {
            questionId = _generateQuestionId(question);
            question['id'] = questionId; // Store the generated ID
          }
          
          final userAnswer = _answers[questionId];
          String questionText = question['question']?.toString() ?? 'Question ${i+1}';
          
          // Create question detail for result tracking
          Map<String, dynamic> questionDetail = {
            'questionId': questionId,
            'questionText': questionText,
            'userAnswer': userAnswer,
            'isAnswered': userAnswer != null,
            'isCorrect': false,
          };
          
          // Skip if no answer but count total questions
          if (userAnswer == null) {
            questionDetails.add(questionDetail);
            continue;
          }
          
          if (!question.containsKey('correctOptionIndex')) {
            questionDetails.add(questionDetail);
            continue;
          }
          
          final correctIndex = question['correctOptionIndex'] as int? ?? 0;
          
          // Skip if options list is empty or incorrect index
          if (question['options'] == null || 
              !(question['options'] is List) || 
              (question['options'] as List).isEmpty ||
              correctIndex >= (question['options'] as List).length) {
            questionDetails.add(questionDetail);
            continue;
          }
          
          final correctAnswer = question['options'][correctIndex].toString();
          questionDetail['correctAnswer'] = correctAnswer;
          
          if (kDebugMode) {
            print("Checking answer for question $questionId: user=$userAnswer, correct=$correctAnswer");
          }
          
          if (userAnswer == correctAnswer) {
            correctAnswers++;
            questionDetail['isCorrect'] = true;
            if (kDebugMode) {
              print("Correct answer for question $questionId");
            }
          }
          
          questionDetails.add(questionDetail);
        }
        
        // Calculate percentage based on total questions
        score = totalQuestions > 0 
            ? (correctAnswers / totalQuestions * 100).round() 
            : 0;
            
        if (kDebugMode) {
          print("Quiz score calculation: $correctAnswers correct out of $totalQuestions total questions = $score%");
        }
      } else {
        // For career assessment quizzes without correct answers
        // We still track the answers but use a higher baseline score
        for (var i = 0; i < widget.questions.length; i++) {
          final question = widget.questions[i];
          String questionId = question['id']?.toString() ?? '';
          if (questionId.isEmpty) {
            questionId = _generateQuestionId(question);
            question['id'] = questionId;
          }
          
          final userAnswer = _answers[questionId];
          String questionText = question['question']?.toString() ?? 'Question ${i+1}';
          
          questionDetails.add({
            'questionId': questionId,
            'questionText': questionText,
            'userAnswer': userAnswer,
            'isAnswered': userAnswer != null,
          });
        }
        
        // Random score for career assessment between 70-95
        int answeredCount = _answers.length;
        // Base score between 70-80 
        int baseScore = 70 + (answeredCount * 2);
        // Add some randomness (0-15)
        int randomBonus = DateTime.now().millisecondsSinceEpoch % 16;
        // Cap at 95
        score = (baseScore + randomBonus).clamp(70, 95);
      }
      
      // Enhanced result data with detailed question info
      final Map<String, dynamic> resultData = {
        'score': score,
        'answers': Map<String, dynamic>.from(_answers),
        'correctAnswers': correctAnswers,
        'totalQuestions': totalQuestions,
        'questionDetails': questionDetails,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      // Call completion callback if provided
      if (widget.onComplete != null) {
        widget.onComplete!(_answers, score);
      }
      
      // Go to results screen with enhanced data
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultsScreen(
            answers: _answers,
            assignedBy: widget.assignedBy,
            resultData: resultData,
          ),
        ),
      );
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goBack() {
    if (widget.currentQuestion > 1) {
      // Go to previous question
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizQuestionScreen(
            currentQuestion: widget.currentQuestion - 1,
            totalQuestions: widget.totalQuestions,
            questions: widget.questions,
            answers: widget.answers,
            assignedBy: widget.assignedBy,
            videoId: widget.videoId,
          ),
        ),
      );
    } else {
      // Go back to career counseling screen
      Navigator.pop(context);
    }
  }

  Widget _buildVideoSection() {
    // If no video ID is provided, show a message and continue button
    if (widget.videoId == null) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ready to Start',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'You can now begin the career assessment quiz',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _videoWatched = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Start Quiz',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    // Show video player if videoId is provided
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Before you start the quiz',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Please watch this ${widget.watchTimeMinutes} minute video about career development',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: AppTheme.primaryColor,
              progressColors: ProgressBarColors(
                playedColor: AppTheme.primaryColor,
                handleColor: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Required Watch Time: ${widget.watchTimeMinutes} minutes\n'
            'Time Elapsed: ${_startTime != null ? DateTime.now().difference(_startTime!).inMinutes : 0}:${_startTime != null ? (DateTime.now().difference(_startTime!).inSeconds % 60).toString().padLeft(2, '0') : '00'}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: SizedBox(
              width: 300,
            child: ElevatedButton(
              onPressed: _videoWatched 
                  ? () {
                      setState(() {
                        // Force refresh UI showing quiz section
                      });
                    } 
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: Text(
                _videoWatched 
                    ? 'Continue to Quiz' 
                      : 'Please Watch the Video (${widget.watchTimeMinutes} mins)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show video section if it's the first question and video not watched yet
    if (widget.currentQuestion == 1 && !_videoWatched) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.grey[100],
          elevation: 0,
          leading: IconButton(
            icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Career Assessment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        body: _buildVideoSection(),
      );
    }
    
    // Otherwise show the quiz
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.black),
          onPressed: _goBack,
        ),
        title: const Text(
          'Career Assessment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
        children: [
          LinearProgressIndicator(
            value: _currentPage / (widget.totalQuestions / widget.questionsPerPage).ceil(),
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                  'Page $_currentPage of ${(widget.totalQuestions / widget.questionsPerPage).ceil()}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.currentQuestion} of ${widget.totalQuestions}',
                  style: TextStyle(
                    color: Colors.grey[600],
              ),
            ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swiping
              itemCount: (widget.totalQuestions / widget.questionsPerPage).ceil(),
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page + 1;
                });
              },
              itemBuilder: (context, pageIndex) {
                final startQuestionIndex = pageIndex * widget.questionsPerPage;
                final endQuestionIndex = (pageIndex + 1) * widget.questionsPerPage;
                final pageQuestions = widget.questions.sublist(
                  startQuestionIndex,
                  endQuestionIndex > widget.totalQuestions ? widget.totalQuestions : endQuestionIndex,
                );
                
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question progress
                        Text(
                          'Question ${widget.currentQuestion} of ${widget.totalQuestions}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Question text
                        Text(
                          pageQuestions[0]['question']?.toString() ?? 'Question not available',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Options
                        ...(() {
                          final question = pageQuestions[0];
                          final String questionId = question['id']?.toString() ?? _generateQuestionId(question);
                          final List<String> options = [];
                          if (question['options'] is List) {
                            for (var option in question['options']) {
                              if (option != null) {
                                options.add(option.toString());
                              }
                            }
                          }
                          return options.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final option = entry.value;
                            final isSelected = _answers[questionId] == option;
                            return GestureDetector(
                              onTap: () {
                                if (option.isNotEmpty) {
                                  _selectAnswer(questionId, option);
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: isSelected ? AppTheme.primaryColor : Colors.grey.shade400,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade400,
                                          width: 2,
                                        ),
                                        color: isSelected ? AppTheme.primaryColor : Colors.white,
                                      ),
                                      child: isSelected
                                          ? const Center(
                                              child: Icon(Icons.circle, size: 14, color: Colors.white),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        option,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList();
                        })(),
                        const Spacer(),
                        // Navigation buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _currentPage > 1 ? _goToPreviousPage : null,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.black),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: const Text('Back', style: TextStyle(color: Colors.black)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _canGoNext() ? _goToNextPage : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: const Text('NEXT', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
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

  // Helper method to generate a consistent ID for a question without one
  String _generateQuestionId(Map<String, dynamic> question) {
    // Create a deterministic ID based on the question content
    final String questionText = question['question']?.toString() ?? '';
    if (questionText.isEmpty) return '';
    
    // Generate an ID based on the first few characters of the question and a timestamp
    String baseId = questionText.substring(0, questionText.length > 10 ? 10 : questionText.length)
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return 'q_${baseId.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}';
  }
} 
