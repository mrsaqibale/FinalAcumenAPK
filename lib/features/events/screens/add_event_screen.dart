import 'package:acumen/features/events/controllers/add_event_controller.dart';
import 'package:acumen/features/events/controllers/event_controller.dart';
import 'package:acumen/features/events/models/event_model.dart';
import 'package:acumen/features/events/widgets/add_event_widgets.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class AddEventScreen extends StatelessWidget {
  final EventModel? eventToEdit;

  const AddEventScreen({
    super.key,
    this.eventToEdit,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddEventController(eventToEdit: eventToEdit),
      child: const _AddEventScreenContent(),
    );
  }
}

class _AddEventScreenContent extends StatelessWidget {
  const _AddEventScreenContent();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddEventController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: Text(
          controller.eventToEdit != null ? 'Edit Event' : 'Add New Event',
          style: const TextStyle(
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Container(
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AddEventWidgets.buildSectionTitle('Event Image'),
                const SizedBox(height: 16),
                // Event image picker
                Center(
                  child: GestureDetector(
                    onTap: () => controller.pickImage(context),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: controller.selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                controller.selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : controller.eventToEdit?.imageUrl != null && controller.eventToEdit!.imageUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    controller.eventToEdit!.imageUrl!,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 40,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap to add event image',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                AddEventWidgets.buildSectionTitle('Event Details'),
                const SizedBox(height: 20),
                AddEventWidgets.buildTextField(
                  controller: controller.titleController,
                  label: 'Event Title',
                  hint: 'Enter event title',
                  icon: Icons.title,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter event title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AddEventWidgets.buildTextField(
                  controller: controller.descriptionController,
                  label: 'Description',
                  hint: 'Enter event description',
                  icon: Icons.description,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter event description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AddEventWidgets.buildTextField(
                  controller: controller.venueController,
                  label: 'Venue',
                  hint: 'Enter event venue',
                  icon: Icons.location_on,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter event venue';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                AddEventWidgets.buildSectionTitle('Event Schedule'),
                const SizedBox(height: 20),
                AddEventWidgets.buildDatePicker(
                  context: context,
                  label: 'Start Date & Time',
                  value: controller.startDate,
                  onTap: () => controller.selectDate(context, true),
                ),
                const SizedBox(height: 16),
                AddEventWidgets.buildDatePicker(
                  context: context,
                  label: 'End Date & Time',
                  value: controller.endDate,
                  onTap: () => controller.selectDate(context, false),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.isLoading 
                      ? null 
                      : () async {
                          if (await controller.saveEvent(context)) {
                            Navigator.pop(context);
                            
                            final eventController = Provider.of<EventController>(context, listen: false);
                            await eventController.loadEvents();
                            
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.adminDashboard,
                              arguments: {'initialTab': 3},
                            );
                          }
                        },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: controller.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          controller.eventToEdit != null ? 'Update Event' : 'Create Event',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 