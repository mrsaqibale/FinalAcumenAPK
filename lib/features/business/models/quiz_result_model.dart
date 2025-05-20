class QuizResultModel {
  final String userId;
  final String userName;
  final String userEmail;
  final Map<String, dynamic> answers;
  final double score;
  final int correctAnswers;
  final int totalQuestions;
  final List<Map<String, dynamic>> questionDetails;
  final DateTime date;
  final String? assignedBy;

  QuizResultModel({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.answers,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.questionDetails,
    required this.date,
    this.assignedBy,
  });

  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    return QuizResultModel(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      answers: Map<String, dynamic>.from(json['answers'] as Map),
      score: (json['score'] as num).toDouble(),
      correctAnswers: json['correctAnswers'] as int,
      totalQuestions: json['totalQuestions'] as int,
      questionDetails: List<Map<String, dynamic>>.from(
        (json['questionDetails'] as List).map((x) => Map<String, dynamic>.from(x))
      ),
      date: DateTime.parse(json['date'] as String),
      assignedBy: json['assignedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'answers': answers,
      'score': score,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'questionDetails': questionDetails,
      'date': date.toIso8601String(),
      'assignedBy': assignedBy,
    };
  }

  // Create anonymous quiz result
  factory QuizResultModel.anonymous({
    required Map<String, dynamic> answers,
    required double score,
    required int correctAnswers,
    required int totalQuestions,
    required List<Map<String, dynamic>> questionDetails,
    String? assignedBy,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return QuizResultModel(
      userId: 'anonymous_$timestamp',
      userName: 'Anonymous User',
      userEmail: 'anonymous@example.com',
      answers: answers,
      score: score,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      questionDetails: questionDetails,
      date: DateTime.now(),
      assignedBy: assignedBy,
    );
  }
} 