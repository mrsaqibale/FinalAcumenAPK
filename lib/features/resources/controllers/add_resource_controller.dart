import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/utils/app_snackbar.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

class AddResourceController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkController = TextEditingController();

  String selectedResourceType = 'Course Syllabus';
  String selectedFileType = 'pdf';
  bool isUploading = false;
  PlatformFile? selectedFile;
  String? fileUrl;
  String? fileName;
  double uploadProgress = 0.0;

  final List<String> resourceTypes = [
    'Course Syllabus',
    'Assignment',
    'Announcement',
    'Lecture Notes',
    'MCQs',
    'Study Guide',
    'Presentation',
    'Reference Material',
    'Practice Test',
    'Tutorial',
    'Other'
  ];

  final List<String> fileTypes = ['pdf', 'doc', 'link', 'video', 'image', 'presentation', 'other'];

  void setResourceType(String value) {
    selectedResourceType = value;
    notifyListeners();
  }

  void setFileType(String value) {
    selectedFileType = value;
    notifyListeners();
  }

  Future<void> pickFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'jpg', 'jpeg', 'png', 'mp4', 'zip'],
      );
      if (result != null) {
        selectedFile = result.files.first;
        fileName = selectedFile!.name;
        // Set file type based on extension
        final extension = path.extension(fileName!).toLowerCase().replaceAll('.', '');
        if (extension == 'pdf') {
          selectedFileType = 'pdf';
        } else if (['doc', 'docx'].contains(extension)) {
          selectedFileType = 'doc';
        } else if (['jpg', 'jpeg', 'png'].contains(extension)) {
          selectedFileType = 'image';
        } else if (['mp4'].contains(extension)) {
          selectedFileType = 'video';
        } else if (['ppt', 'pptx'].contains(extension)) {
          selectedFileType = 'presentation';
        } else if (['zip'].contains(extension)) {
          selectedFileType = 'other';
        }
        notifyListeners();
      }
    } catch (e) {
      AppSnackbar.showError(context: context, message: 'Error picking file: $e');
    }
  }

  Future<void> uploadFile(BuildContext context) async {
    if (selectedFile == null) return;
    isUploading = true;
    uploadProgress = 0.0;
    notifyListeners();
    try {
      final currentUser = Provider.of<AuthController>(context, listen: false).currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('resources')
          .child(currentUser.uid)
          .child('${DateTime.now().millisecondsSinceEpoch}_${selectedFile!.name}');
      UploadTask uploadTask;
      if (kIsWeb) {
        if (selectedFile!.bytes == null) {
          throw Exception('File bytes are null');
        }
        uploadTask = storageRef.putData(
          selectedFile!.bytes!,
          SettableMetadata(contentType: selectedFile!.extension),
        );
      } else {
        if (selectedFile!.path == null) {
          throw Exception('File path is null');
        }
        final file = File(selectedFile!.path!);
        if (!await file.exists()) {
          throw Exception('File does not exist at path: ${selectedFile!.path}');
        }
        uploadTask = storageRef.putFile(file);
      }
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        notifyListeners();
      });
      final snapshot = await uploadTask;
      fileUrl = await storageRef.getDownloadURL();
    } catch (e) {
      AppSnackbar.showError(context: context, message: 'Error uploading file: $e');
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  Future<void> saveResource(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    if (selectedFileType == 'link') {
      if (linkController.text.trim().isEmpty) {
        AppSnackbar.showError(context: context, message: 'Please enter a valid URL');
        return;
      }
      fileUrl = linkController.text.trim();
      fileName = 'External Link';
    } else if (selectedFile == null) {
      AppSnackbar.showError(context: context, message: 'Please select a file to upload');
      return;
    }
    isUploading = true;
    notifyListeners();
    try {
      final currentUser = Provider.of<AuthController>(context, listen: false).currentUser;
      final appUser = Provider.of<AuthController>(context, listen: false).appUser;
      if (currentUser == null || appUser == null) {
        throw Exception('User not authenticated');
      }
      if (selectedFileType != 'link' && selectedFile != null) {
        await uploadFile(context);
      }
      await FirebaseFirestore.instance.collection('resources').add({
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'resourceType': selectedResourceType,
        'type': selectedFileType,
        'fileUrl': fileUrl,
        'fileName': fileName ?? selectedFile?.name,
        'dateAdded': Timestamp.now(),
        'mentorId': currentUser.uid,
        'mentorName': appUser.name,
        'mentorEmail': appUser.email,
      });
      AppSnackbar.showSuccess(context: context, message: 'Resource added successfully');
      Navigator.pop(context);
    } catch (e) {
      AppSnackbar.showError(context: context, message: 'Error saving resource: $e');
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
    super.dispose();
  }
} 