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
    print('[DEBUG] Loading messages for conversation: ' + conversationId);
    try {
      final chatController = Provider.of<ChatController>(
        context,
        listen: false,
      );
      final messages = await chatController.getMessages(conversationId);
      print(
        '[DEBUG] Loaded \\${messages.length} messages for conversation: ' +
            conversationId,
      );

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
      print('[DEBUG] Error loading messages: ' + e.toString());
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
    print(
      '[DEBUG] Attempting to send message: ' + text + ' to ' + conversationId,
    );
    if (text.trim().isEmpty) {
      print('[DEBUG] Message is empty, aborting send.');
      return;
    }

    messageController.clear();

    try {
      final chatController = Provider.of<ChatController>(
        context,
        listen: false,
      );
      final conversation = chatController.getConversation(conversationId);
      if (conversation == null) {
        print('[DEBUG] Conversation not found for id: ' + conversationId);
        AppSnackbar.showError(
          context: context,
          message: 'Conversation not found',
        );
        return;
      }
      await chatController.sendMessage(
        conversationId: conversationId,
        text: text,
        receiverId: conversation.participantId,
      );
      print('[DEBUG] Message sent successfully to ' + conversationId);

      // Scroll to bottom after sending
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      print('[DEBUG] Error sending message: ' + e.toString());
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
