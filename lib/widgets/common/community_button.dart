import 'package:acumen/features/chat/screens/chats_screen.dart';

import 'package:flutter/material.dart';


class CommunityButton extends StatelessWidget {
  const CommunityButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatsScreen(initialTabIndex: 1),
          ),
        );
      },
      child: const Text('Go to Community Chats'),
    );
  }
} 
