import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acumen/features/events/controllers/event_controller.dart';
import 'package:acumen/features/events/models/event_model.dart';

class AddEventController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final venueController = TextEditingController();
  
  DateTime? startDate;
  DateTime? endDate;
  bool isLoading = false;
  final EventModel? eventToEdit;

  AddEventController({this.eventToEdit}) {
    if (eventToEdit != null) {
      titleController.text = eventToEdit!.title;
      descriptionController.text = eventToEdit!.description;
      venueController.text = eventToEdit!.venue;
      startDate = eventToEdit!.startDate;
      endDate = eventToEdit!.endDate;
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (startDate ?? DateTime.now()) : (endDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        final DateTime dateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );

        if (isStartDate) {
          startDate = dateTime;
          if (endDate != null && endDate!.isBefore(startDate!)) {
            endDate = startDate!.add(const Duration(hours: 1));
          }
        } else {
          endDate = dateTime;
        }
        notifyListeners();
      }
    }
  }

  Future<bool> saveEvent(BuildContext context) async {
    if (!formKey.currentState!.validate()) return false;
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and end dates')),
      );
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      final eventController = Provider.of<EventController>(context, listen: false);
      final event = EventModel(
        id: eventToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: titleController.text,
        description: descriptionController.text,
        venue: venueController.text,
        startDate: startDate!,
        endDate: endDate!,
        createdBy: eventToEdit?.createdBy ?? 'admin',
        createdAt: eventToEdit?.createdAt ?? DateTime.now(),
        isActive: eventToEdit?.isActive ?? true,
      );

      if (eventToEdit != null) {
        await eventController.updateEvent(event);
      } else {
        await eventController.createEvent(event);
      }

      // Check if end date is in the past - if so, immediately update event status
      if (endDate!.isBefore(DateTime.now())) {
        await eventController.checkForExpiredEvents(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(eventToEdit != null 
            ? 'Event updated successfully' 
            : 'Event created successfully'
          ),
          backgroundColor: Colors.green,
        ),
      );
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
} 