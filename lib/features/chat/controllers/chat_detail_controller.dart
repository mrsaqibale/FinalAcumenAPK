import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/features/chat/models/chat_message_model.dart';
import 'package:acumen/utils/app_snackbar.dart';

class ChatDetailController extends ChangeNotifier {
  final String conversationId;
  final AuthController authController;
  final ChatController chatController;
  
  List<ChatMessage> messages = [];
  Map<String, bool> typingUsers = {};
  Map<String, bool> onlineUsers = {};
  Map<String, double> uploadProgress = {};
  Map<String, bool> uploadComplete = {};
  Map<String, String> tempMessageIds = {};
  
  StreamSubscription? _typingSubscription;
  StreamSubscription? _onlineSubscription;
  StreamSubscription? _messagesSubscription;
  
  bool isLoading = true;
  
  ChatDetailController({
    required this.conversationId,
    required this.authController,
    required this.chatController,
  }) {
    _initialize();
  }
  
  void _initialize() {
    _loadMessages();
    _setupTypingListener();
    _setupOnlineStatusListener();
    _updateUserOnlineStatus(true);
  }
  
  Future<void> _setupTypingListener() async {
    final currentUserId = authController.currentUser?.uid;
    if (currentUserId == null) return;
    
    _typingSubscription = FirebaseFirestore.instance
        .collection('chats')
        .doc(conversationId)
        .collection('typing')
        .snapshots()
        .listen((snapshot) {
      typingUsers = {};
      for (var doc in snapshot.docs) {
        if (doc.id != currentUserId) {
          typingUsers[doc.id] = doc.data()['isTyping'] ?? false;
        }
      }
      notifyListeners();
    });
  }
  
  Future<void> _setupOnlineStatusListener() async {
    final conversation = chatController.getConversation(conversationId);
    if (conversation == null) return;
    
    List<String> memberIds = [conversation.participantId];
    
    _onlineSubscription = FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: memberIds)
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        onlineUsers[doc.id] = doc.data()['isOnline'] ?? false;
      }
      notifyListeners();
    });
  }
  
  Future<void> _updateUserOnlineStatus(bool isOnline) async {
    final currentUserId = authController.currentUser?.uid;
    if (currentUserId == null) return;
    
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp()
      });
    } catch (e) {
      // Handle error
    }
  }
  
  Future<void> updateTypingStatus(bool isTyping) async {
    final currentUserId = authController.currentUser?.uid;
    if (currentUserId == null) return;
    
    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(conversationId)
          .collection('typing')
          .doc(currentUserId)
          .set({
        'isTyping': isTyping,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Handle error
    }
  }
  
  Future<void> _loadMessages() async {
    isLoading = true;
    notifyListeners();

    try {
      _messagesSubscription = FirebaseFirestore.instance
          .collection('chats')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        messages = snapshot.docs.map((doc) {
          final data = doc.data();
          DateTime messageTime;
          try {
            messageTime = data['timestamp'] != null 
              ? (data['timestamp'] as Timestamp).toDate()
              : DateTime.now();
          } catch (e) {
            messageTime = DateTime.now();
          }
          
          return ChatMessage(
            id: doc.id,
            text: data['text'] ?? '',
            senderId: data['senderId'] ?? '',
            receiverId: data['receiverId'] ?? '',
            timestamp: messageTime,
            isRead: data['isRead'] ?? false,
            fileUrl: data['fileUrl'],
            fileName: data['fileName'],
            fileType: data['type'],
          );
        }).toList();
        
        isLoading = false;
        notifyListeners();
        _markMessagesAsRead();
      }, onError: (error) {
        isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _markMessagesAsRead() async {
    final currentUserId = authController.currentUser?.uid;
    if (currentUserId == null) return;
    
    final batch = FirebaseFirestore.instance.batch();
    bool hasBatchOperations = false;
    
    for (var message in messages) {
      if (!message.isRead && message.senderId != currentUserId) {
        final messageRef = FirebaseFirestore.instance
            .collection('chats')
            .doc(conversationId)
            .collection('messages')
            .doc(message.id);
            
        batch.update(messageRef, {'isRead': true});
        hasBatchOperations = true;
      }
    }
    
    if (hasBatchOperations) {
      await batch.commit();
    }
  }
  
  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;
    
    final currentUser = authController.currentUser;
    final conversation = chatController.getConversation(conversationId);
    
    if (currentUser == null || conversation == null) return;
    
    final messageData = {
      'text': text,
      'senderId': currentUser.uid,
      'senderName': authController.appUser?.name ?? 'Unknown',
      'receiverId': conversation.participantId,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'type': 'text',
    };
    
    try {
      await updateTypingStatus(false);
      
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(conversationId)
          .collection('messages')
          .add(messageData);
    
      await FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationId)
          .update({
        'lastMessage': text,
        'lastMessageSender': currentUser.uid,
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Handle error
    }
  }
  
  Future<void> uploadFile(File file, String type, String fileName, BuildContext context) async {
    final currentUser = authController.currentUser;
    final conversation = chatController.getConversation(conversationId);
    
    if (currentUser == null || conversation == null) return;
    
    final tempId = const Uuid().v4();
    
    try {
      final uuid = const Uuid().v4();
      final extension = fileName.split('.').last;
      final storagePath = 'chats/$conversationId/$uuid.$extension';
      
      final tempMessage = ChatMessage(
        id: tempId,
        text: type == 'audio' ? 'Voice message' : 'Sending file: $fileName',
        senderId: currentUser.uid,
        receiverId: conversation.participantId,
        timestamp: DateTime.now(),
        isRead: false,
        fileUrl: file.path,
        fileName: fileName,
        fileType: type,
      );
      
      tempMessageIds[tempId] = tempId;
      uploadProgress[tempId] = 0;
      uploadComplete[tempId] = false;
      messages = [tempMessage, ...messages];
      notifyListeners();
      
      // Verify file exists and is readable
      if (!await file.exists()) {
        throw Exception('File not found or inaccessible');
      }
      
      // Check if file size is reasonable (< 20MB)
      final fileSize = await file.length();
      if (fileSize > 20 * 1024 * 1024) {
        throw Exception('File is too large (max 20MB)');
      }
      
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      
      // Retry logic for uploads
      int retryCount = 0;
      const maxRetries = 3;
      UploadTask? uploadTask;
      
      while (retryCount < maxRetries) {
        try {
          uploadTask = storageRef.putFile(
            file,
            SettableMetadata(
              contentType: _getContentType(fileName, type),
              cacheControl: 'public, max-age=31536000',
            ),
          );
          
          uploadTask.snapshotEvents.listen((taskSnapshot) {
            switch (taskSnapshot.state) {
              case TaskState.running:
                final progress = taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
                uploadProgress[tempId] = progress;
                notifyListeners();
                break;
              case TaskState.success:
                uploadComplete[tempId] = true;
                notifyListeners();
                break;
              case TaskState.error:
              case TaskState.canceled:
                // Don't remove the message yet, let the retry logic handle it
                if (retryCount >= maxRetries - 1) {
                  messages.removeWhere((msg) => msg.id == tempId);
                  tempMessageIds.remove(tempId);
                  uploadProgress.remove(tempId);
                  uploadComplete.remove(tempId);
                  notifyListeners();
                  AppSnackbar.showError(context: context, message: 'Failed to upload file');
                }
                break;
              default:
                break;
            }
          });
          
          final snapshot = await uploadTask;
          final downloadUrl = await snapshot.ref.getDownloadURL();
          
          final conversationDoc = await FirebaseFirestore.instance
              .collection('conversations')
              .doc(conversationId)
              .get();
          
          final messageData = {
            'text': type == 'audio' ? 'Voice message' : 'Sent a file: $fileName',
            'senderId': currentUser.uid,
            'senderName': authController.appUser?.name ?? 'Unknown',
            'receiverId': conversation.participantId,
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
            'type': type,
            'fileUrl': downloadUrl,
            'fileName': fileName,
          };
          
          await FirebaseFirestore.instance
              .collection('chats')
              .doc(conversationId)
              .collection('messages')
              .add(messageData);
          
          if (conversationDoc.exists) {
            await FirebaseFirestore.instance
                .collection('conversations')
                .doc(conversationId)
                .update({
              'lastMessage': type == 'audio' ? 'Voice message' : 'Sent a file: $fileName',
              'lastMessageSender': currentUser.uid,
              'lastMessageAt': FieldValue.serverTimestamp(),
            });
          }
          
          messages.removeWhere((msg) => msg.id == tempId);
          tempMessageIds.remove(tempId);
          uploadProgress.remove(tempId);
          uploadComplete.remove(tempId);
          notifyListeners();
          
          // Successfully uploaded, break out of retry loop
          break;
        } catch (e) {
          retryCount++;
          if (retryCount >= maxRetries) {
            throw e; // Rethrow after max retries
          }
          
          // Wait before retrying (exponential backoff)
          await Future.delayed(Duration(seconds: retryCount * 2));
          
          // Update UI to show retry attempt
          if (retryCount < maxRetries) {
            final index = messages.indexWhere((msg) => msg.id == tempId);
            if (index >= 0) {
              messages[index] = ChatMessage(
                id: tempId,
                text: 'Retrying upload (${retryCount}/$maxRetries)...',
                senderId: currentUser.uid,
                receiverId: conversation.participantId,
                timestamp: DateTime.now(),
                isRead: false,
                fileUrl: file.path,
                fileName: fileName,
                fileType: type,
              );
              uploadProgress[tempId] = 0;
              notifyListeners();
            }
          }
        }
      }
    } catch (e) {
      // Clean up any temporary messages
      messages.removeWhere((msg) => msg.id == tempId);
      tempMessageIds.remove(tempId);
      uploadProgress.remove(tempId);
      uploadComplete.remove(tempId);
      notifyListeners();
      
      AppSnackbar.showError(context: context, message: 'Failed to upload file: ${e.toString().split(":").first}');
    }
  }
  
  String _getContentType(String fileName, String type) {
    final extension = fileName.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'mp3':
        return 'audio/mpeg';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'zip':
        return 'application/zip';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'xls':
      case 'xlsx':
        return 'application/vnd.ms-excel';
      case 'ppt':
      case 'pptx':
        return 'application/vnd.ms-powerpoint';
      default:
        return 'application/octet-stream';
    }
  }
  
  @override
  void dispose() {
    _typingSubscription?.cancel();
    _onlineSubscription?.cancel();
    _messagesSubscription?.cancel();
    updateTypingStatus(false);
    _updateUserOnlineStatus(false);
    super.dispose();
  }
} 