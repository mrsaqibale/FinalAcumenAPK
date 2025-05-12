class Mentor {
  final String name;
  final String message;
  final bool hasAvatar;
  final String gender;
  final String title;

  const Mentor({
    required this.name,
    required this.message,
    required this.hasAvatar,
    required this.gender,
    required this.title,
  });

  factory Mentor.fromJson(Map<String, dynamic> json) {
    return Mentor(
      name: json['name'] as String,
      message: json['message'] as String,
      hasAvatar: json['hasAvatar'] as bool,
      gender: json['gender'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'message': message,
      'hasAvatar': hasAvatar,
      'gender': gender,
      'title': title,
    };
  }
} 