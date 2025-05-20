class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options,
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] as String,
      question: map['question'] as String,
      options: List<String>.from(map['options'] as List),
    );
  }
}

class QuizModel {
  static List<QuizQuestion> get defaultQuestions => [
    QuizQuestion(
      id: 'education',
      question: 'What is your highest level of Education?',
      options: [
        'High School',
        'Associate degree',
        'Bachelor\'s degree',
        'Graduate degree',
      ],
    ),
    QuizQuestion(
      id: 'interest',
      question: 'Which field interests you the most?',
      options: [
        'Technology',
        'Business & Finance',
        'Healthcare',
        'Arts & Design',
      ],
    ),
    QuizQuestion(
      id: 'skills',
      question: 'What skills are you most confident in?',
      options: [
        'Problem solving',
        'Communication',
        'Analysis',
        'Creativity',
      ],
    ),
    QuizQuestion(
      id: 'work_style',
      question: 'What work environment do you prefer?',
      options: [
        'Remote work',
        'Office setting',
        'Field work',
        'Flexible hours',
      ],
    ),
    QuizQuestion(
      id: 'goals',
      question: 'What are your career goals?',
      options: [
        'High salary',
        'Work-life balance',
        'Leadership positions',
        'Making a difference',
      ],
    ),
  ];
} 