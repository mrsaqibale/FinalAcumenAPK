import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acumen/features/events/controllers/event_controller.dart';
import 'package:acumen/features/events/models/event_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:acumen/utils/app_snackbar.dart';

class AddEventController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final venueController = TextEditingController();
  
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(hours: 2));
  
  bool isLoading = false;
  final EventModel? eventToEdit;
  File? selectedImage;
  String? imageUrl;

  AddEventController({this.eventToEdit}) {
    if (eventToEdit != null) {
      titleController.text = eventToEdit!.title;
      descriptionController.text = eventToEdit!.description;
      venueController.text = eventToEdit!.venue;
      startDate = eventToEdit!.startDate;
      endDate = eventToEdit!.endDate;
      imageUrl = eventToEdit!.imageUrl;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    venueController.dispose();
    super.dispose();
  }

  Future<void> selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? startDate : endDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isStartDate ? DateTime.now() : startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );
      
      if (pickedTime != null) {
        final newDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        
        if (isStartDate) {
          startDate = newDateTime;
          if (endDate.isBefore(startDate)) {
            endDate = startDate.add(const Duration(hours: 2));
          }
        } else {
          endDate = newDateTime;
        }
        
        notifyListeners();
      }
    }
  }

  Future<void> pickImage(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        selectedImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      AppSnackbar.showError(
        context: context,
        message: 'Failed to pick image: ${e.toString()}',
      );
    }
  }

  Future<String?> _uploadImage() async {
    if (selectedImage == null) return imageUrl;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('event_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      await storageRef.putFile(selectedImage!);
      final url = await storageRef.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Future<bool> saveEvent(BuildContext context) async {
    if (!formKey.currentState!.validate()) return false;
    
    if (endDate.isBefore(startDate)) {
      AppSnackbar.showError(
        context: context,
        message: 'End date cannot be before start date',
      );
      return false;
    }
    
    isLoading = true;
    notifyListeners();
    
    try {
      final uploadedImageUrl = await _uploadImage();
      
      final eventData = {
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'venue': venueController.text.trim(),
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'createdAt': Timestamp.now(),
        'createdBy': 'admin',
        'isActive': true,
        'imageUrl': uploadedImageUrl,
      };
      
      if (eventToEdit != null) {
        await FirebaseFirestore.instance
            .collection('events')
            .doc(eventToEdit!.id)
            .update(eventData);
        
        AppSnackbar.showSuccess(
          context: context,
          message: 'Event updated successfully',
        );
      } else {
        final docRef = await FirebaseFirestore.instance
            .collection('events')
            .add(eventData);
            
        final eventController = Provider.of<EventController>(context, listen: false);
        final newEvent = EventModel(
          id: docRef.id,
          title: eventData['title'] as String,
          description: eventData['description'] as String,
          venue: eventData['venue'] as String,
          startDate: startDate,
          endDate: endDate,
          createdBy: eventData['createdBy'] as String,
          createdAt: DateTime.now(),
          isActive: true,
          imageUrl: uploadedImageUrl,
        );
        
        await eventController.loadEvents();
        
        AppSnackbar.showSuccess(
          context: context,
          message: 'Event created successfully',
        );
      }
      
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      
      AppSnackbar.showError(
        context: context,
        message: 'Failed to save event: ${e.toString()}',
      );
      return false;
    }
  }
} 