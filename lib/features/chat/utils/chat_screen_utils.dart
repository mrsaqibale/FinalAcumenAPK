import 'package:flutter/material.dart';
import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/features/chat/models/chat_message_model.dart';
import 'package:acumen/utils/app_snackbar.dart';
import 'package:provider/provider.dart';

class ChatScreenUtils {
  static Future<List<ChatMessage>> loadMessages(
    BuildContext context,
    String conversationId,
    ScrollController scrollController,
  ) async {
    try {
      final chatController = Provider.of<ChatController>(context, listen: false);
      final messages = await chatController.getMessages(conversationId);
      
      // Scroll to bottom after messages load
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
      
      return messages;
    } catch (e) {
      AppSnackbar.showError(
        context: context,
        message: 'Error loading messages: $e',
      );
      rethrow;
    }
  }

  static Future<void> sendMessage(
    BuildContext context,
    String conversationId,
    String text,
    TextEditingController messageController,
    ScrollController scrollController,
  ) async {
    if (text.trim().isEmpty) return;

    messageController.clear();

    try {
      final chatController = Provider.of<ChatController>(context, listen: false);
      await chatController.sendMessage(
        conversationId: conversationId,
        text: text,
      );
      
      // Scroll to bottom after sending
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      AppSnackbar.showError(
        context: context,
        message: 'Error sending message: $e',
      );
    }
  }

  static void scrollToBottom(ScrollController scrollController) {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
} 