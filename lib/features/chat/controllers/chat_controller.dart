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
  static ChatController? _instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String? _error;
  List<ChatConversation> _conversations = [];
  List<ConversationModel> _availableCommunities = [];
  List<Map<String, dynamic>> _recentStudents = [];
  Map<String, List<ChatMessage>> _messagesCache = {};

  // Stream subscriptions for real-time updates
  StreamSubscription? _conversationsSubscription;
  Map<String, StreamSubscription> _messageSubscriptions = {};

  ChatController._();

  static ChatController getInstance() {
    _instance ??= ChatController._();
    return _instance!;
  }

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
      _conversationsSubscription = ChatService.getConversationsStream().listen((
        conversations,
      ) {
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
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        _conversations = [];
        notifyListeners();
        return;
      }

      // Fetch conversations from Firebase
      final firestoreConversations =
          await _firestore
              .collection('conversations')
              .where('members', arrayContains: currentUser.uid)
              .orderBy('lastMessageAt', descending: true)
              .get();

      List<ChatConversation> fetchedConversations = [];
      for (var doc in firestoreConversations.docs) {
        final data = doc.data();

        String participantId = '';
        List<String> members = List<String>.from(data['members'] ?? []);
        for (var memberId in members) {
          if (memberId != currentUser.uid) {
            participantId = memberId;
            break;
          }
        }

        if (participantId.isEmpty && !data['isGroup']) continue;
        if (data['isGroup'] && participantId.isEmpty && members.isNotEmpty) {
          participantId = members.first;
        }

        // Always fetch the other user's name for DMs
        String participantName = data['participantName'] ?? 'Unknown';
        String? participantImageUrl = data['participantImageUrl'];
        if (!(data['isGroup'] ?? false) && participantId.isNotEmpty) {
          try {
            final userDoc = await _firestore.collection('users').doc(participantId).get();
            if (userDoc.exists) {
              final userData = userDoc.data() as Map<String, dynamic>;
              participantName = userData['name'] ?? participantName;
              participantImageUrl = userData['photoUrl'] ?? participantImageUrl;
            }
          } catch (e) {
            // Ignore, fallback to Firestore data
          }
        }

        DateTime lastMessageTime = DateTime.now();
        if (data['lastMessageAt'] != null) {
          try {
            lastMessageTime = (data['lastMessageAt'] as Timestamp).toDate();
          } catch (e) {}
        }

        fetchedConversations.add(
          ChatConversation(
            id: doc.id,
            participantId: data['participantId'] ?? participantId,
            participantName: participantName,
            participantImageUrl: participantImageUrl,
            lastMessage: data['lastMessage'] ?? '',
            lastMessageTime: lastMessageTime,
            hasUnreadMessages: data['hasUnreadMessages'] ?? false,
            isGroup: data['isGroup'] ?? false,
            participantHasVerifiedSkills:
                data['participantHasVerifiedSkills'] ?? false,
          ),
        );
      }

      for (var conversation in fetchedConversations) {
        await ChatService.saveConversation(conversation);
      }
      _conversations = fetchedConversations;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading conversations from Firebase: $e');
      }
      _conversations = ChatService.getConversations();
    }
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
      _messageSubscriptions[conversationId] = ChatService.getMessagesStream(
        conversationId,
      ).listen((messages) {
        _messagesCache[conversationId] = messages;

        // Check for new messages and create notifications
        if (messages.isNotEmpty) {
          final latestMessage = messages.first;
          final conversation = getConversation(conversationId);

          if (conversation != null &&
              latestMessage.senderId !=
                  _auth.currentUser?.uid) {
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
    required String receiverId,
    String? imageUrl,
  }) async {
    try {
      final message = await ChatService.sendMessage(
        conversationId: conversationId,
        text: text,
        imageUrl: imageUrl,
        receiverId: receiverId,
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
    String? conversationId,
    bool participantHasVerifiedSkills = false,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User must be logged in to create a conversation');
      }

      // For one-to-one chats, use a deterministic ID
      final convId = isGroup 
              ? (conversationId ?? const Uuid().v4())
              : ChatService.getConversationId(currentUser.uid, participantId);

      // Check if conversation already exists in cache
      final existing = _conversations.firstWhere(
        (c) => c.id == convId,
        orElse: () => ChatService.getConversation(convId) ?? 
                ChatConversation(
                  id: '',
                  participantId: '',
                  participantName: '',
                  lastMessage: '',
                  lastMessageTime: DateTime.now(),
                  isGroup: false,
                  participantHasVerifiedSkills: false,
                ),
      );

      if (existing.id.isNotEmpty) {
        return existing;
      }

      // Create new conversation document
      final conversation = await ChatService.createConversation(
        participantId: participantId,
        participantName: participantName,
        participantImageUrl: participantImageUrl,
        isGroup: isGroup,
        conversationId: convId,
        participantHasVerifiedSkills: participantHasVerifiedSkills,
      );

      // Add to local cache
      _conversations.add(conversation);

      // Send initial welcome message
      await sendMessage(
        conversationId: convId,
        text: "Hi! Let's start chatting.",
        receiverId: participantId,
      );

      notifyListeners();
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

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        if (kDebugMode) {
          print('Cannot fetch communities: User is not authenticated');
        }
        return;
      }

      // Get all communities and filter those that the user is not a member of
      final communitiesSnapshot =
          await _firestore
              .collection('communities')
              .where('isPublic', isEqualTo: true)
              .get();

      final userCommunitiesSnapshot =
          await _firestore
              .collection('communities')
              .where('members', arrayContains: currentUser.uid)
              .get();

      // Extract the IDs of communities the user is already a member of
      final userCommunityIds =
          userCommunitiesSnapshot.docs.map((doc) => doc.id).toSet();

      // Filter out communities the user is already a member of
      _availableCommunities =
          communitiesSnapshot.docs
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
      await ChatService.joinCommunity(communityId: communityId, userId: userId);

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
      orElse:
          () => ConversationModel(
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
      print("DEBUG: Sending community message to community ID: $communityId");
      print("DEBUG: Message text: $text");
      print("DEBUG: File URL: $fileUrl, File Type: $fileType");

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get current user's data including verified skills status
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      final userData = userDoc.data() as Map<String, dynamic>;
      final hasVerifiedSkills = userData['hasVerifiedSkills'] ?? false;

      // Create a server timestamp
      final serverTimestamp = FieldValue.serverTimestamp();

      // Create message document with explicit timestamp
      final messageData = {
        'id': const Uuid().v4(),
        'text': text,
        'senderId': currentUser.uid,
        'senderName': userData['name'] ?? 'Unknown',
        'senderHasVerifiedSkills': hasVerifiedSkills,
        'timestamp': serverTimestamp,
        'createdAt': serverTimestamp, // Add a backup timestamp field
        'type': 'message',
        'fileUrl': fileUrl,
        'imageUrl':
            fileUrl, // Set imageUrl to be the same as fileUrl for backward compatibility
        'fileType': fileType,
        'contentType':
            fileType, // Set contentType to be the same as fileType for UI rendering
        'replyToMessageId': replyToMessageId,
        'replyToSenderName': replyToSenderName,
        'replyToText': replyToText,
        'forwardedFromName': forwardedFromName,
      };

      print(
        "DEBUG: Adding message to Firestore path: communities/$communityId/messages",
      );
      print("DEBUG: Message data: $messageData");

      // Add message to community
      await _firestore.collection('communities').doc(communityId).collection('messages').add(messageData);

      print("DEBUG: Message added successfully");

      // Update community's last message with explicit timestamp
      await _firestore.collection('communities').doc(communityId).update({
        'lastMessage': text,
        'lastMessageSender': userData['name'] ?? 'Unknown',
        'lastMessageAt': serverTimestamp,
        'updatedAt': serverTimestamp, // Add a backup timestamp field
      });

      print("DEBUG: Community last message updated");
    } catch (e) {
      print("DEBUG: Error sending community message: $e");
      if (kDebugMode) {
        print('Error sending community message: $e');
      }
      rethrow;
    }
  }

  // Get community messages stream
  Stream<List<Map<String, dynamic>>> getCommunityMessagesStream(
    String communityId,
  ) {
    print("DEBUG: Getting messages stream for community ID: $communityId");

    return ChatService.getCommunityMessagesStream(communityId).map((messages) {
      print("DEBUG: Received ${messages.length} messages from stream");
      if (messages.isNotEmpty) {
        print("DEBUG: Latest message: ${messages.last['text']}");
      }
      return messages;
    });
  }

  // Get communities the current user is a member of
  Stream<List<Map<String, dynamic>>> getUserCommunitiesStream() {
    return ChatService.getUserCommunitiesStream();
  }

  // Get community messages with only media content for resources tab
  Stream<List<Map<String, dynamic>>> getCommunityMediaMessagesStream(
    String communityId,
  ) {
    return ChatService.getCommunityMessagesStream(communityId).map(
      (messages) =>
          messages.where((message) {
            // Check if this message has media content
            final String contentType =
                message['contentType'] as String? ?? 'text';
            final String? imageUrl = message['imageUrl'] as String?;

            // Return only messages with media content (not text or voice)
            return (contentType != 'text' &&
                contentType != 'voice' &&
                imageUrl != null &&
                imageUrl.isNotEmpty);
          }).toList(),
    );
  }

  // Get solo chat messages with only media content for My Chats tab in resources
  Stream<List<ChatMessage>> getSoloMediaMessagesStream(String conversationId) {
    if (!_messageSubscriptions.containsKey(conversationId)) {
      // Return empty stream initially
      return Stream.value([]);
    }

    return ChatService.getMessagesStream(conversationId).map(
      (messages) =>
          messages.where((message) {
            // Check if this message has media content (fileUrl is not null)
            return message.fileUrl != null && message.fileUrl!.isNotEmpty;
          }).toList(),
    );
  }

  // Check if a conversation has any media messages
  Future<bool> conversationHasMediaMessages(String conversationId) async {
    try {
      print("DEBUG: Checking media messages for conversation $conversationId");

      // Query Firestore directly for messages with fileUrl
      final messagesSnapshot =
          await _firestore
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
      print(
        "DEBUG: Error checking media messages for conversation $conversationId: $e",
      );
      return false;
    }
  }

  String getConversationId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return ids.join('_');
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

  Future<void> reloadConversations() async {
    await _loadConversations();
  }

  Future<String> createOrGetDirectChat(String otherUserId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Sort user IDs to ensure consistent conversation ID
      final sortedIds = [currentUser.uid, otherUserId]..sort();
      final conversationId = sortedIds.join('_');

      // Check if conversation already exists
      final existingConversation = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (!existingConversation.exists) {
        // Get other user's data
        final otherUserDoc = await _firestore
            .collection('users')
            .doc(otherUserId)
            .get();

        if (!otherUserDoc.exists) {
          throw Exception('User not found');
        }

        final otherUserData = otherUserDoc.data()!;

        // Create new conversation
        await _firestore
            .collection('conversations')
            .doc(conversationId)
            .set({
          'members': [currentUser.uid, otherUserId],
          'participantId': otherUserId,
          'participantName': otherUserData['name'] ?? 'Unknown',
          'participantImageUrl': otherUserData['photoUrl'],
          'lastMessage': '',
          'lastMessageAt': FieldValue.serverTimestamp(),
          'isGroup': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return conversationId;
    } catch (e) {
      throw Exception('Failed to create or get direct chat: $e');
    }
  }
}
