import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'quiz_question_screen.dart';

class CareerCounselingScreen extends StatelessWidget {
  const CareerCounselingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define quiz questions
    final quizQuestions = [
      {
        'id': 'education',
        'question': 'What is your highest level of Education?',
        'options': [
          'High School',
          'Associate degree',
          'Bachelor\'s degree',
          'Graduate degree',
        ],
      },
      {
        'id': 'interest',
        'question': 'Which field interests you the most?',
        'options': [
          'Technology',
          'Business & Finance',
          'Healthcare',
          'Arts & Design',
        ],
      },
      {
        'id': 'skills',
        'question': 'What skills are you most confident in?',
        'options': [
          'Problem solving',
          'Communication',
          'Analysis',
          'Creativity',
        ],
      },
      {
        'id': 'work_style',
        'question': 'What work environment do you prefer?',
        'options': [
          'Remote work',
          'Office setting',
          'Field work',
          'Flexible hours',
        ],
      },
      {
        'id': 'goals',
        'question': 'What are your career goals?',
        'options': [
          'High salary',
          'Work-life balance',
          'Leadership positions',
          'Making a difference',
        ],
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'Career counceling',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Take The career assessment quiz',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            const Text(
              'answer a series of questions to evaluate your strength and interests',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Column(
              children: [
                Image.asset(
                  'assets/images/quiz.png',
                  height: 400,
                  width: 400,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Start the quiz
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizQuestionScreen(
                        questions: quizQuestions,
                        answers: {},
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Start Quiz',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
} 
