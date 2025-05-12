import 'package:acumen/features/assignments/controllers/assignment_controller.dart';
import 'package:acumen/features/auth/models/user_model.dart';
import 'package:acumen/features/courses/models/course_model.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:acumen/utils/app_snackbar.dart';

class CreateAssignmentScreen extends StatefulWidget {
  final CourseModel course;

  const CreateAssignmentScreen({
    super.key,
    required this.course,
  });

  @override
  State<CreateAssignmentScreen> createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxPointsController = TextEditingController(text: '100');
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  List<String> _selectedStudentIds = [];
  bool _assignToAllStudents = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _maxPointsController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate),
      );
      if (time != null) {
        setState(() {
          _dueDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveAssignment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final assignmentController = Provider.of<AssignmentController>(context, listen: false);
      final currentUser = Provider.of<UserModel>(context, listen: false);

      await assignmentController.createAssignment(
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _dueDate,
        courseId: widget.course.id,
        courseName: widget.course.name,
        teacherId: currentUser.id,
        teacherName: currentUser.name,
        assignedToStudentIds: _assignToAllStudents ? [] : _selectedStudentIds,
        maxPoints: int.parse(_maxPointsController.text),
      );

      if (mounted) {
        AppSnackbar.showSuccess(
          context: context,
          message: 'Assignment created successfully',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      AppSnackbar.showError(
        context: context,
        message: 'Error creating assignment: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showStudentSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Students'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.course.studentIds.length,
            itemBuilder: (context, index) {
              final studentId = widget.course.studentIds[index];
              // In a real app, you would fetch student names
              final studentName = 'Student ${index + 1}';
              return CheckboxListTile(
                title: Text(studentName),
                value: _selectedStudentIds.contains(studentId),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedStudentIds.add(studentId);
                    } else {
                      _selectedStudentIds.remove(studentId);
                    }
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedStudentIds = List.from(widget.course.studentIds);
              });
              Navigator.pop(context);
            },
            child: const Text('SELECT ALL'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedStudentIds = [];
              });
              Navigator.pop(context);
            },
            child: const Text('CLEAR ALL'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'Create Assignment',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Course: ${widget.course.name}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _maxPointsController,
                        decoration: const InputDecoration(
                          labelText: 'Maximum Points',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter maximum points';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Due Date'),
                        subtitle: Text(
                          DateFormat('EEEE, MMMM d, yyyy - h:mm a').format(_dueDate),
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: _selectDueDate,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const Divider(),
                      const SizedBox(height: 16),
                      const Text(
                        'Assign to:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RadioListTile<bool>(
                        title: const Text('All students in this course'),
                        value: true,
                        groupValue: _assignToAllStudents,
                        onChanged: (value) {
                          setState(() {
                            _assignToAllStudents = value!;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<bool>(
                        title: const Text('Specific students'),
                        value: false,
                        groupValue: _assignToAllStudents,
                        onChanged: (value) {
                          setState(() {
                            _assignToAllStudents = value!;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (!_assignToAllStudents) ...[
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _showStudentSelectionDialog,
                          icon: const Icon(Icons.people),
                          label: Text(
                            _selectedStudentIds.isEmpty
                                ? 'Select Students'
                                : '${_selectedStudentIds.length} Students Selected',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveAssignment,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Create Assignment',
                  style: TextStyle(fontSize: 16),
                ),
        ),
      ),
    );
  }
} 