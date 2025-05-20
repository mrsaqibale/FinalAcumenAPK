import 'package:flutter/material.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/utils/app_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

class AddResourceDialogWidget extends StatefulWidget {
  const AddResourceDialogWidget({super.key});

  @override
  State<AddResourceDialogWidget> createState() => _AddResourceDialogWidgetState();
}

class _AddResourceDialogWidgetState extends State<AddResourceDialogWidget> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedType = 'pdf';
  bool _isUploading = false;
  PlatformFile? _selectedFile;
  String? _fileUrl;
  String? _fileName;
  double _uploadProgress = 0.0;
  
  final List<String> _resourceTypes = ['pdf', 'doc', 'link', 'video', 'image', 'other'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'jpg', 'jpeg', 'png', 'mp4'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
          _fileName = _selectedFile!.name;
          
          // Set resource type based on file extension
          final extension = path.extension(_fileName!).toLowerCase().replaceAll('.', '');
          if (extension == 'pdf') {
            _selectedType = 'pdf';
          } else if (['doc', 'docx'].contains(extension)) {
            _selectedType = 'doc';
          } else if (['jpg', 'jpeg', 'png'].contains(extension)) {
            _selectedType = 'image';
          } else if (['mp4'].contains(extension)) {
            _selectedType = 'video';
          } else if (['ppt', 'pptx'].contains(extension)) {
            _selectedType = 'presentation';
          } else {
            _selectedType = 'other';
          }
        });
      }
    } catch (e) {
      AppSnackbar.showError(context: context, message: 'Error picking file: $e');
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final currentUser = Provider.of<AuthController>(context, listen: false).currentUser;
      if (currentUser == null) {
        AppSnackbar.showError(context: context, message: 'User not authenticated');
        return;
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('resources')
          .child(currentUser.uid)
          .child('${DateTime.now().millisecondsSinceEpoch}_${_selectedFile!.name}');

      UploadTask uploadTask;
      
      if (kIsWeb) {
        // Web platform
        uploadTask = storageRef.putData(
          _selectedFile!.bytes!,
          SettableMetadata(contentType: _selectedFile!.extension),
        );
      } else {
        // Mobile platform
        final file = File(_selectedFile!.path!);
        uploadTask = storageRef.putFile(file);
      }

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      // Wait for upload to complete
      await uploadTask;
      
      // Get download URL
      _fileUrl = await storageRef.getDownloadURL();
    } catch (e) {
      AppSnackbar.showError(context: context, message: 'Error uploading file: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _saveResource() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedType != 'link' && _selectedFile == null) {
      AppSnackbar.showError(context: context, message: 'Please select a file to upload');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload file if selected
      if (_selectedFile != null) {
        await _uploadFile();
      }

      final currentUser = Provider.of<AuthController>(context, listen: false).currentUser;
      final appUser = Provider.of<AuthController>(context, listen: false).appUser;
      
      if (currentUser == null || appUser == null) {
        AppSnackbar.showError(context: context, message: 'User not authenticated');
        return;
      }

      // Create resource document
      await FirebaseFirestore.instance.collection('resources').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'type': _selectedType,
        'fileUrl': _fileUrl,
        'fileName': _fileName,
        'dateAdded': Timestamp.now(),
        'mentorId': currentUser.uid,
        'mentorName': appUser.name,
        'mentorEmail': appUser.email,
      });

      if (mounted) {
        AppSnackbar.showSuccess(context: context, message: 'Resource added successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context: context, message: 'Error saving resource: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Resource'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Resource Type',
                  border: OutlineInputBorder(),
                ),
                items: _resourceTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_selectedType != 'link')
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _pickFile,
                  icon: const Icon(Icons.upload_file),
                  label: Text(_selectedFile == null ? 'Select File' : 'Change File'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                  ),
                ),
              if (_selectedFile != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Selected file: ${_selectedFile!.name}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
              if (_isUploading) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(value: _uploadProgress),
                const SizedBox(height: 8),
                Text(
                  'Uploading: ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUploading ? null : () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: _isUploading ? null : _saveResource,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
          ),
          child: _isUploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('SAVE'),
        ),
      ],
    );
  }
} 