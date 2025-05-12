import 'package:acumen/features/mentors/controllers/mentor_controller.dart';
import 'package:acumen/features/mentors/models/mentor_model.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/widgets/mentors/mentor_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class MentorsScreen extends StatelessWidget {
  const MentorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'Mentors',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Consumer<MentorController>(
                builder: (context, mentorController, child) {
                  if (mentorController.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (mentorController.error != null) {
                    return Center(
                      child: Text('Error: ${mentorController.error}'),
                    );
                  }

                  final mentors = mentorController.mentors;

                  if (mentors.isEmpty) {
                    return const Center(
                      child: Text(
                        'No mentors available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    itemCount: mentors.length,
                    itemBuilder: (context, index) {
                      final mentor = mentors[index];
                      return MentorCardWidget(mentor: mentor);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
