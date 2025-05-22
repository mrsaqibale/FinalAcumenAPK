import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/chat/models/chat_conversation_model.dart';
import 'package:acumen/features/chat/models/chat_message_model.dart';
import 'package:acumen/features/chat/models/conversation_model.dart';
import 'package:acumen/features/chat/services/chat_service.dart';
import 'package:acumen/features/notification/controllers/notification_controller.dart';
import 'package:acumen/features/business/controllers/quiz_results_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class ChatController extends ChangeNotifier {
  bool _isLoading = true;
  String? _error;
  List<ChatConversation> _conversations = [];
  List<ConversationModel> _availableCommunities = [];
  List<Map<String, dynamic>> _recentStudents = [];
  Map<String, List<ChatMessage>> _messagesCache = {};
  
  // Stream subscriptions for real-time updates
  StreamSubscription? _conversationsSubscription;
  Map<String, StreamSubscription> _messageSubscriptions = {};
  
  // Firestore references
  final _firestore = FirebaseFirestore.instance;
  final _usersCollection = FirebaseFirestore.instance.collection('users');
  final _communitiesCollection = FirebaseFirestore.instance.collection('communities');
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ChatConversation> get conversations => _conversations;
  List<ConversationModel> get availableCommunities => _availableCommunities;
  List<Map<String, dynamic>> get recentStudents => _recentStudents;
  
  // Get a specific conversation by ID
  ChatConversation? getConversation(String id) {
    try {
      return _conversations.firstWhere((conversation) => conversation.id == id);
    } catch (e) {
      return ChatService.getConversation(id);
    }
  }
  
  ChatController() {
    _initializeChat();
  }
  
  Future<void> _initializeChat() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Load conversations with real-time updates
      await _loadConversations();
      
      // Setup real-time subscription for conversations
      _conversationsSubscription = ChatService.getConversationsStream().listen((conversations) {
        _conversations = conversations;
        notifyListeners();
      });
      
      // Load recent students
      await loadRecentStudents();
      
      _isLoading = false;
      _error = null;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      if (kDebugMode) {
        print('Error initializing chat: $e');
      }
    } finally {
      notifyListeners();
    }
  }
  
  // Load all conversations
  Future<void> _loadConversations() async {
    _conversations = ChatService.getConversations();
    notifyListeners();
  }
  
  // Load recent students (registered in the last 30 days)
  Future<void> loadRecentStudents() async {
    try {
      _recentStudents = await ChatService.getRecentStudents();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading recent students: $e');
      }
    }
  }
  
  // Get messages for a conversation with real-time updates
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    // Setup real-time listener if not already set up
    if (!_messageSubscriptions.containsKey(conversationId)) {
      _messageSubscriptions[conversationId] = ChatService.getMessagesStream(conversationId).listen((messages) {
        _messagesCache[conversationId] = messages;
        
        // Check for new messages and create notifications
        if (messages.isNotEmpty) {
          final latestMessage = messages.first;
          final conversation = getConversation(conversationId);
          
          if (conversation != null && 
              latestMessage.senderId != FirebaseAuth.instance.currentUser?.uid) {
            // Create notification for new message
            _createMessageNotification(
              conversation: conversation,
              message: latestMessage,
            );
          }
        }
        
        notifyListeners();
      });
    }
    
    // Try to get from cache first
    if (_messagesCache.containsKey(conversationId)) {
      return _messagesCache[conversationId]!;
    }
    
    // Load from service
    final messages = await ChatService.getMessages(conversationId);
    _messagesCache[conversationId] = messages;
    
    // Mark conversation as read
    await markConversationAsRead(conversationId);
    
    return messages;
  }
  
  // Create notification for new message
  void _createMessageNotification({
    required ChatConversation conversation,
    required ChatMessage message,
  }) {
    try {
      final notificationController = Provider.of<NotificationController>(
        navigatorKey.currentContext!,
        listen: false,
      );
      
      notificationController.addMessageNotification(
        senderName: conversation.participantName,
        message: message.text,
        senderId: message.senderId,
        conversationId: conversation.id,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error creating message notification: $e');
      }
    }
  }
  
  // Send a message
  Future<void> sendMessage({
    required String conversationId,
    required String text,
    String? imageUrl,
  }) async {
    try {
      final message = await ChatService.sendMessage(
        conversationId: conversationId,
        text: text,
        imageUrl: imageUrl,
      );
      
      // Update cache
      if (_messagesCache.containsKey(conversationId)) {
        _messagesCache[conversationId]!.add(message);
      }
      
      // Reload conversations to update last message
      await _loadConversations();
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }
      rethrow;
    }
  }
  
  // Mark a conversation as read
  Future<void> markConversationAsRead(String conversationId) async {
    try {
      await ChatService.markConversationAsRead(conversationId);
      
      // Update conversations list
      await _loadConversations();
    } catch (e) {
      if (kDebugMode) {
        print('Error marking conversation as read: $e');
      }
    }
  }
  
  // Create a new conversation
  Future<ChatConversation> createConversation({
    required String participantId,
    required String participantName,
    String? participantImageUrl,
    bool isGroup = false,
  }) async {
    try {
      final conversation = await ChatService.createConversation(
        participantId: participantId,
        participantName: participantName,
        participantImageUrl: participantImageUrl,
        isGroup: isGroup,
      );
      
      // Reload conversations
      await _loadConversations();
      
      return conversation;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating conversation: $e');
      }
      rethrow;
    }
  }
  
  // Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      await ChatService.deleteConversation(conversationId);
      
      // Remove from cache
      _messagesCache.remove(conversationId);
      
      // Reload conversations
      await _loadConversations();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting conversation: $e');
      }
      rethrow;
    }
  }

  // Create a new community with real-time support
  Future<bool> createCommunity({
    required String name,
    String? description,
    required List<String> memberIds,
    String? imageUrl,
    bool isPublic = false,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await ChatService.createCommunity(
        name: name,
        description: description,
        memberIds: memberIds,
        imageUrl: imageUrl,
        isPublic: isPublic,
      );
      
      // No need to manually reload as subscription will handle it
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print('Error creating community: $e');
      }
      return false;
    }
  }
  
  // Fetch communities that the user can join
  Future<void> fetchAvailableCommunities() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (kDebugMode) {
          print('Cannot fetch communities: User is not authenticated');
        }
        return;
      }
      
      // Get all communities and filter those that the user is not a member of
      final communitiesSnapshot = await FirebaseFirestore.instance
          .collection('communities')
          .where('isPublic', isEqualTo: true)
          .get();
      
      final userCommunitiesSnapshot = await FirebaseFirestore.instance
          .collection('communities')
          .where('members', arrayContains: currentUser.uid)
          .get();
      
      // Extract the IDs of communities the user is already a member of
      final userCommunityIds = userCommunitiesSnapshot.docs.map((doc) => doc.id).toSet();
      
      // Filter out communities the user is already a member of
      _availableCommunities = communitiesSnapshot.docs
          .where((doc) => !userCommunityIds.contains(doc.id))
          .map((doc) => ConversationModel.fromFirestore(doc))
          .toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching available communities: $e');
      }
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Join a community
  Future<bool> joinCommunity({
    required String communityId,
    required String userId,
  }) async {
    try {
      await ChatService.joinCommunity(
        communityId: communityId,
        userId: userId,
      );
      
      // Reload conversations and available communities
      await _loadConversations();
      await fetchAvailableCommunities();
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error joining community: $e');
      }
      return false;
    }
  }
  
  // Leave a community
  Future<bool> leaveCommunity({
    required String communityId,
    required String userId,
  }) async {
    try {
      await ChatService.leaveCommunity(
        communityId: communityId,
        userId: userId,
      );
      
      // Reload conversations
      await _loadConversations();
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error leaving community: $e');
      }
      return false;
    }
  }
  
  // Update community members (for teachers)
  Future<bool> updateCommunityMembers({
    required String communityId,
    required List<String> memberIds,
  }) async {
    try {
      await ChatService.updateCommunityMembers(
        communityId: communityId,
        memberIds: memberIds,
      );
      
      // Reload conversations
      await _loadConversations();
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating community members: $e');
      }
      return false;
    }
  }
  
  // Check if user can create communities (mentors only)
  bool canCreateCommunities(BuildContext context) {
    final authController = Provider.of<AuthController>(context, listen: false);
    return authController.appUser?.role == 'mentor';
  }
  
  // Check if user is community creator
  bool isCreator(String communityId, BuildContext context) {
    final authController = Provider.of<AuthController>(context, listen: false);
    final userId = authController.currentUser?.uid;
    if (userId == null) return false;
    
    final community = availableCommunities.firstWhere(
      (c) => c.id == communityId,
      orElse: () => ConversationModel(
        id: '',
        name: '',
        members: [],
        createdBy: '',
        createdAt: DateTime.now(),
        lastMessageAt: DateTime.now(),
        isGroup: true,
      ),
    );
    
    return community.createdBy == userId;
  }
  
  // Check if user is a mentor
  bool isMentor(BuildContext context) {
    final authController = Provider.of<AuthController>(context, listen: false);
    return authController.appUser?.role == 'mentor';
  }

  // Send a message to community
  Future<void> sendCommunityMessage({
    required String communityId,
    required String text,
    String? fileUrl,
    String? fileType,
    String? replyToMessageId,
    String? replyToSenderName,
    String? replyToText,
    String? forwardedFromName,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      // Get current user's data including verified skills status
      final userDoc = await _usersCollection.doc(currentUser.uid).get();
      final userData = userDoc.data() as Map<String, dynamic>;
      final hasVerifiedSkills = userData['hasVerifiedSkills'] ?? false;
      
      // Create message document
      final messageData = {
        'id': const Uuid().v4(),
        'text': text,
        'senderId': currentUser.uid,
        'senderName': userData['name'] ?? 'Unknown',
        'senderHasVerifiedSkills': hasVerifiedSkills,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'message',
        'fileUrl': fileUrl,
        'fileType': fileType,
        'replyToMessageId': replyToMessageId,
        'replyToSenderName': replyToSenderName,
        'replyToText': replyToText,
        'forwardedFromName': forwardedFromName,
      };
      
      // Add message to community
      await _communitiesCollection
          .doc(communityId)
          .collection('messages')
          .add(messageData);
      
      // Update community's last message
      await _communitiesCollection.doc(communityId).update({
        'lastMessage': text,
        'lastMessageSender': userData['name'] ?? 'Unknown',
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error sending community message: $e');
      }
      rethrow;
    }
  }
  
  // Get community messages stream
  Stream<List<Map<String, dynamic>>> getCommunityMessagesStream(String communityId) {
    return ChatService.getCommunityMessagesStream(communityId);
  }
  
  // Get communities the current user is a member of
  Stream<List<Map<String, dynamic>>> getUserCommunitiesStream() {
    return ChatService.getUserCommunitiesStream();
  }
  
  // Get community messages with only media content for resources tab
  Stream<List<Map<String, dynamic>>> getCommunityMediaMessagesStream(String communityId) {
    return ChatService.getCommunityMessagesStream(communityId)
        .map((messages) => messages.where((message) {
              // Check if this message has media content
              final String contentType = message['contentType'] as String? ?? 'text';
              final String? imageUrl = message['imageUrl'] as String?;
              
              // Return only messages with media content (not text or voice)
              return (contentType != 'text' && contentType != 'voice' && 
                     imageUrl != null && imageUrl.isNotEmpty);
            }).toList());
  }
  
  // Get solo chat messages with only media content for My Chats tab in resources
  Stream<List<ChatMessage>> getSoloMediaMessagesStream(String conversationId) {
    if (!_messageSubscriptions.containsKey(conversationId)) {
      // Return empty stream initially
      return Stream.value([]);
    }
    
    return ChatService.getMessagesStream(conversationId)
        .map((messages) => messages.where((message) {
              // Check if this message has media content (fileUrl is not null)
              return message.fileUrl != null && message.fileUrl!.isNotEmpty;
            }).toList());
  }
  
  // Check if a conversation has any media messages
  Future<bool> conversationHasMediaMessages(String conversationId) async {
    try {
      print("DEBUG: Checking media messages for conversation $conversationId");
      
      // Query Firestore directly for messages with fileUrl
      final messagesSnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .doc(conversationId)
          .collection('messages')
          .where('fileUrl', isNotEqualTo: null)
          .limit(1)
          .get();

      final hasMedia = messagesSnapshot.docs.isNotEmpty;
      print("DEBUG: Conversation $conversationId has media: $hasMedia");
      
      if (hasMedia) {
        print("DEBUG: Found media message in conversation $conversationId");
      }
      
      return hasMedia;
    } catch (e) {
      print("DEBUG: Error checking media messages for conversation $conversationId: $e");
      return false;
    }
  }

  // Create or get existing one-to-one conversation
  Future<ChatConversation?> createOneToOneConversation({
    required String participantId,
    required String participantName,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (kDebugMode) {
          print('Error creating conversation: User is not authenticated');
        }
        return null;
      }
      
      // Check if conversation already exists
      for (var conversation in _conversations) {
        if (!conversation.isGroup && conversation.participantId == participantId) {
          return conversation;
        }
      }

      // Create a new conversation
      return await createConversation(
        participantId: participantId,
        participantName: participantName,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error creating one-to-one conversation: $e');
      }
      return null;
    }
  }

  @override
  void dispose() {
    // Cancel all subscriptions
    _conversationsSubscription?.cancel();
    for (var subscription in _messageSubscriptions.values) {
      subscription.cancel();
    }
    super.dispose();
  }
} 