import 'package:flutter/material.dart';
import 'package:acumen/features/profile/models/user_model.dart';
import 'user_card.dart';

class UserCardExample extends StatelessWidget {
  final List<UserModel> users;
  final Function(UserModel)? onUserTap;

  const UserCardExample({
    super.key,
    required this.users,
    this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final user = users[index];
        return UserCard(
          user: user,
          onTap: onUserTap != null ? () => onUserTap!(user) : null,
        );
      },
    );
  }
}

// Example of how to use:
/*
  final userController = Provider.of<UserController>(context);
  
  return Scaffold(
    appBar: AppBar(title: const Text('Verified Users')),
    body: UserCardExample(
      users: userController.users.where((user) => user.hasVerifiedSkills == true).toList(),
    ),
  );
*/ 