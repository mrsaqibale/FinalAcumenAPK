import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:acumen/features/business/controllers/quiz_controller.dart';

class AddQuizScreen extends StatefulWidget {
  const AddQuizScreen({Key? key}) : super(key: key);

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<QuizQuestionData> _questions = [];
  bool _assignToAllStudents = true;
  List<String> _selectedStudents = [];
  int _questionsPerPage = 5;
  String? _videoUrl;
  int _watchTimeInMinutes = 0;
  bool _isLoading = false;
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questions.add(QuizQuestionData(
        question: '',
        options: ['', '', '', ''],
        correctOptionIndex: 0,
      ));
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final controller = QuizController.getInstance();
      final success = await controller.addQuiz({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'questions': _questions.map((q) => q.toMap()).toList(),
        'assignToAll': _assignToAllStudents,
        'selectedStudents': _selectedStudents,
        'questionsPerPage': _questionsPerPage,
        'videoUrl': _videoUrl,
        'watchTimeInMinutes': _watchTimeInMinutes,
      });
      
      if (mounted) {
        if (success) {
      Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save quiz')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: QuizController.getInstance(),
      child: Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'Add New Quiz',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quiz Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Quiz Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quiz title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Quiz Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Quiz Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quiz description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Video URL
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Video URL (Optional)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _videoUrl = value.isEmpty ? null : value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Watch Time
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Watch Time (minutes)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _watchTimeInMinutes = int.tryParse(value) ?? 0;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Questions Per Page
              Row(
                children: [
                  const Text('Questions Per Page: '),
                  const SizedBox(width: 16),
                  DropdownButton<int>(
                    value: _questionsPerPage,
                    items: [1, 2, 3, 4, 5, 10].map((value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _questionsPerPage = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Assign To
              const Text('Assign Quiz To:'),
              Row(
                children: [
                  Radio<bool>(
                    value: true,
                    groupValue: _assignToAllStudents,
                    onChanged: (value) {
                      setState(() {
                        _assignToAllStudents = value!;
                      });
                    },
                  ),
                  const Text('All Students'),
                  const SizedBox(width: 16),
                  Radio<bool>(
                    value: false,
                    groupValue: _assignToAllStudents,
                    onChanged: (value) {
                      setState(() {
                        _assignToAllStudents = value!;
                      });
                    },
                  ),
                  const Text('Select Students'),
                ],
              ),
              
              // Student Selection
              if (!_assignToAllStudents)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Students:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      // This would be populated with actual student data in a real app
                      CheckboxListTile(
                        title: const Text('John Doe'),
                        value: _selectedStudents.contains('john_doe'),
                        onChanged: (value) {
                          setState(() {
                            if (value!) {
                              _selectedStudents.add('john_doe');
                            } else {
                              _selectedStudents.remove('john_doe');
                            }
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Jane Smith'),
                        value: _selectedStudents.contains('jane_smith'),
                        onChanged: (value) {
                          setState(() {
                            if (value!) {
                              _selectedStudents.add('jane_smith');
                            } else {
                              _selectedStudents.remove('jane_smith');
                            }
                          });
                        },
                      ),
                      // More students would be added here
                    ],
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Questions Section
              const Text(
                'Quiz Questions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Question List
              ..._buildQuestionsList(),
              
              // Add Question Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton.icon(
                  onPressed: _addQuestion,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Question'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton(
            onPressed: _questions.isEmpty ? null : _saveQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              disabledBackgroundColor: Colors.grey,
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text(
              'Save Quiz',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildQuestionsList() {
    return _questions.asMap().entries.map((entry) {
      final index = entry.key;
      final question = entry.value;
      
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeQuestion(index),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: question.question,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the question';
                  }
                  return null;
                },
                onChanged: (value) {
                  question.question = value;
                },
              ),
              const SizedBox(height: 16),
              const Text('Options (click correct answer):'),
              const SizedBox(height: 8),
              ...List.generate(4, (optionIndex) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Radio<int>(
                        value: optionIndex,
                        groupValue: question.correctOptionIndex,
                        onChanged: (value) {
                          setState(() {
                            question.correctOptionIndex = value!;
                          });
                        },
                      ),
                      Expanded(
                        child: TextFormField(
                          initialValue: question.options[optionIndex],
                          decoration: InputDecoration(
                            labelText: 'Option ${optionIndex + 1}',
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter option ${optionIndex + 1}';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            question.options[optionIndex] = value;
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      );
    }).toList();
  }
}

class QuizQuestionData {
  String question;
  List<String> options;
  int correctOptionIndex;

  QuizQuestionData({
    required this.question,
    required this.options,
    required this.correctOptionIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
    };
  }
} 