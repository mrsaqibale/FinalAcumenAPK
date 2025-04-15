import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'quiz_results_screen.dart';

class QuizQuestionScreen extends StatefulWidget {
  final int currentQuestion;
  final int totalQuestions;
  final List<Map<String, dynamic>> questions;
  final Map<String, dynamic> answers;

  const QuizQuestionScreen({
    super.key,
    this.currentQuestion = 1,
    this.totalQuestions = 5,
    required this.questions,
    required this.answers,
  });

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  late Map<String, dynamic> currentQuestionData;
  String? selectedOption;

  @override
  void initState() {
    super.initState();
    currentQuestionData = widget.questions[widget.currentQuestion - 1];
    // Check if there's a saved answer for this question
    if (widget.answers.containsKey(currentQuestionData['id'])) {
      selectedOption = widget.answers[currentQuestionData['id']];
    }
  }

  void _selectOption(String option) {
    setState(() {
      selectedOption = option;
    });
  }

  void _goToNextQuestion() {
    // Save the answer
    widget.answers[currentQuestionData['id']] = selectedOption;

    if (widget.currentQuestion < widget.totalQuestions) {
      // Go to next question
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizQuestionScreen(
            currentQuestion: widget.currentQuestion + 1,
            totalQuestions: widget.totalQuestions,
            questions: widget.questions,
            answers: widget.answers,
          ),
        ),
      );
    } else {
      // Go to results screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultsScreen(answers: widget.answers),
        ),
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
          ),
        ),
      );
    } else {
      // Go back to career counseling screen
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.black),
          onPressed: _goBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${widget.currentQuestion} of ${widget.totalQuestions}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${widget.currentQuestion}.${currentQuestionData['question']}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestionData['options'].length,
                itemBuilder: (context, index) {
                  final option = currentQuestionData['options'][index];
                  final isSelected = selectedOption == option;
                  
                  return GestureDetector(
                    onTap: () => _selectOption(option),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected 
                                  ? AppTheme.primaryColor 
                                  : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        title: Text(
                          option,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 120,
                  child: OutlinedButton(
                    onPressed: _goBack,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: selectedOption != null ? _goToNextQuestion : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      widget.currentQuestion < widget.totalQuestions ? 'NEXT' : 'FINISH',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 
