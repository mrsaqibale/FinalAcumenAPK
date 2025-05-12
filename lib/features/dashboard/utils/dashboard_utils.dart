/// Utility functions for the dashboard feature
class DashboardUtils {
  /// Capitalizes the first letter of each word in a string
  /// 
  /// Example:
  /// ```dart
  /// capitalizeName("john doe") // returns "John Doe"
  /// capitalizeName("MARY JANE") // returns "Mary Jane"
  /// capitalizeName("robert SMITH") // returns "Robert Smith"
  /// ```
  static String capitalizeName(String name) {
    if (name.isEmpty) return name;
    return name.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
} 