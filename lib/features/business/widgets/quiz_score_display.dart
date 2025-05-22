import 'package:flutter/material.dart';

class QuizScoreDisplay extends StatelessWidget {
  final double score;
  final double size;
  final double strokeWidth;
  final bool showLabel;

  const QuizScoreDisplay({
    super.key,
    required this.score,
    this.size = 120,
    this.strokeWidth = 10,
    this.showLabel = true,
  });

  Color _getScoreColor() {
    if (score >= 90) return Colors.green;
    if (score >= 75) return Colors.blue;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  width: size,
                  height: size,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: strokeWidth,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor()),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${score.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: size * 0.3,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(),
                      ),
                    ),
                    if (showLabel)
                      Text(
                        'Score',
                        style: TextStyle(
                          fontSize: size * 0.15,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 16),
          Text(
            _getScoreMessage(),
            style: TextStyle(
              fontSize: 16,
              color: _getScoreColor(),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  String _getScoreMessage() {
    if (score >= 90) return 'Excellent!';
    if (score >= 75) return 'Great job!';
    if (score >= 60) return 'Good effort!';
    return 'Keep practicing!';
  }
} 