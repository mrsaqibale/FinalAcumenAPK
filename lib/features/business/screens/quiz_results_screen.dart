import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class QuizResultsScreen extends StatelessWidget {
  final Map<String, dynamic> answers;

  const QuizResultsScreen({
    super.key,
    required this.answers,
  });

  @override
  Widget build(BuildContext context) {
    // Sample career suggestions based on answers
    // In a real app, this would be calculated based on the user's answers
    final careerSuggestions = [
      {
        'title': 'Software engineer',
        'percentage': 90,
      },
      {
        'title': 'Data scientist',
        'percentage': 80,
      },
      {
        'title': 'Financial analyst',
        'percentage': 75,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.black),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Results',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Based on your answers, here are some career suggestions for you',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: careerSuggestions.length + 1, // +1 for the button at the end
                itemBuilder: (context, index) {
                  if (index < careerSuggestions.length) {
                    final suggestion = careerSuggestions[index];
                    return _buildCareerSuggestionItem(
                      index + 1,
                      suggestion['title'] as String,
                      suggestion['percentage'] as int,
                    );
                  } else {
                    // This is the last item, show the button
                    return Column(
                      children: [
                        const SizedBox(height: 30),
                        Center(
                          child: SizedBox(
                            width: 200,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Back to Dashboard',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareerSuggestionItem(int index, String title, int percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$index. ',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '$percentage%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[300],
            color: AppTheme.primaryColor,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
} 
