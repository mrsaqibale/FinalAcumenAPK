class CareerSuggestionModel {
  final String title;
  final String description;
  final int minScore;
  final int maxScore;
  final int percentage;

  CareerSuggestionModel({
    required this.title,
    required this.description,
    required this.minScore,
    required this.maxScore,
    this.percentage = 0,
  });

  factory CareerSuggestionModel.fromJson(Map<String, dynamic> json) {
    return CareerSuggestionModel(
      title: json['title'] as String,
      description: json['description'] as String,
      minScore: json['minScore'] as int,
      maxScore: json['maxScore'] as int,
      percentage: json['percentage'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'minScore': minScore,
      'maxScore': maxScore,
      'percentage': percentage,
    };
  }

  // Get default career suggestions
  static List<CareerSuggestionModel> getDefaultSuggestions() {
    return [];
  }

  // Calculate suggestion percentage based on score
  static int calculatePercentage(double score, int minScore, int maxScore) {
    if (score <= minScore) return 0;
    if (score >= maxScore) return 100;
    return ((score - minScore) / (maxScore - minScore) * 100).round();
  }
} 