import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:acumen/theme/app_colors.dart';
import 'package:acumen/features/dashboard/utils/dashboard_utils.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DashboardHeader extends StatelessWidget {
  final String username;

  const DashboardHeader({
    super.key,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      width: double.infinity,
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text(
              'Error loading user data',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textLight,
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hello!',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  DashboardUtils.capitalizeName(username),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final name = userData['name'] as String? ?? username;
          final hasVerifiedSkills = userData['hasVerifiedSkills'] as bool? ?? false;

          return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hello!',
            style: TextStyle(
              fontSize: 18,
                  color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 5),
              Row(
                children: [
          Text(
                DashboardUtils.capitalizeName(name),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
            ),
                  ),
                  if (hasVerifiedSkills)
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Icon(
                        FontAwesomeIcons.solidCircleCheck,
                        color: Colors.blue,
                        size: 16,
                      ),
                    ),
                ],
          ),
        ],
          );
        },
      ),
    );
  }
} 