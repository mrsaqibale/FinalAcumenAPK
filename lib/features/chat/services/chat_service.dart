import 'dart:math';
import 'dart:async';
import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/chat/models/chat_conversation_model.dart';
import 'package:acumen/features/chat/models/chat_message_model.dart';
import 'package:acumen/features/chat/models/conversation_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

class ChatService {
  static const String _conversationsBoxName = 'conversations';
  static const String _messagesBoxName = 'messages';
  
  static Box<ChatConversation>? _conversationsBox;
  static Map<String, Box<ChatMessage>> _messageBoxes = {};
  
  // Firestore references for community chats
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _communitiesCollection = _firestore.collection('communities');
  static final CollectionReference _communityMessagesCollection = _firestore.collection('community_messages');
  static final CollectionReference _usersCollection = _firestore.collection('users');
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static Future<void> init() async {
    // Register Hive adapters
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ChatMessageAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ChatConversationAdapter());
    }
    
    // Open conversations box
    _conversationsBox = await Hive.openBox<ChatConversation>(_conversationsBoxName);
    
    // Pre-load all conversation message boxes
    for (final conversation in _conversationsBox!.values) {
      final boxName = '$_messagesBoxName-${conversation.id}';
      _messageBoxes[conversation.id] = await Hive.openBox<ChatMessage>(boxName);
    }
  }
  
  // Get all conversations
  static List<ChatConversation> getConversations() {
    if (_conversationsBox == null) return [];
    
    final conversations = _conversationsBox!.values.toList();
    // Sort by last message time (newest first)
    conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    return conversations;
  }
  
  // Get conversation by ID
  static ChatConversation? getConversation(String id) {
    if (_conversationsBox == null) return null;
    return _conversationsBox!.get(id);
  }
  
  // Get conversation by participant ID
  static ChatConversation? getConversationByParticipant(String participantId) {
    if (_conversationsBox == null) return null;
    
    try {
      return _conversationsBox!.values.firstWhere((c) => c.participantId == participantId);
    } catch (e) {
      return null;
    }
  }
  
  // Create or update a conversation
  static Future<ChatConversation> saveConversation(ChatConversation conversation) async {
    if (_conversationsBox == null) {
      throw Exception('ChatService not initialized');
    }
    
    await _conversationsBox!.put(conversation.id, conversation);
    
    // Ensure message box exists for this conversation
    if (!_messageBoxes.containsKey(conversation.id)) {
      final boxName = '$_messagesBoxName-${conversation.id}';
      _messageBoxes[conversation.id] = await Hive.openBox<ChatMessage>(boxName);
    }
    
    return conversation;
  }
  
  // Delete a conversation
  static Future<void> deleteConversation(String conversationId) async {
    if (_conversationsBox == null) return;
    
    await _conversationsBox!.delete(conversationId);
    
    // Also delete the message box
    if (_messageBoxes.containsKey(conversationId)) {
      await _messageBoxes[conversationId]!.clear();
      await _messageBoxes[conversationId]!.close();
      await Hive.deleteBoxFromDisk('$_messagesBoxName-$conversationId');
      _messageBoxes.remove(conversationId);
    }
  }
  
  // Get messages for a conversation
  static List<ChatMessage> getMessages(String conversationId) {
    if (!_messageBoxes.containsKey(conversationId)) return [];
    
    final messages = _messageBoxes[conversationId]!.values.toList();
    // Sort by timestamp (oldest first for UI display)
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return messages;
  }
  
  // Save a message
  static Future<ChatMessage> saveMessage(String conversationId, ChatMessage message) async {
    if (!_messageBoxes.containsKey(conversationId)) {
      final boxName = '$_messagesBoxName-$conversationId';
      _messageBoxes[conversationId] = await Hive.openBox<ChatMessage>(boxName);
    }
    
    await _messageBoxes[conversationId]!.put(message.id, message);
    
    // Update the conversation's last message
    final conversation = getConversation(conversationId);
    if (conversation != null) {
      final updatedConversation = conversation.copyWith(
        lastMessage: message.text,
        lastMessageTime: message.timestamp,
        hasUnreadMessages: !message.isMine,
      );
      await saveConversation(updatedConversation);
    }
    
    return message;
  }
  
  // Mark all messages in a conversation as read
  static Future<void> markConversationAsRead(String conversationId) async {
    if (!_messageBoxes.containsKey(conversationId)) return;
    
    // Mark all messages as read
    final messages = _messageBoxes[conversationId]!.values.toList();
    for (final message in messages) {
      if (!message.isRead && !message.isMine) {
        final updatedMessage = message.copyWith(isRead: true);
        await _messageBoxes[conversationId]!.put(message.id, updatedMessage);
      }
    }
    
    // Update the conversation
    final conversation = getConversation(conversationId);
    if (conversation != null && conversation.hasUnreadMessages) {
      final updatedConversation = conversation.copyWith(hasUnreadMessages: false);
      await saveConversation(updatedConversation);
    }
  }
  
  // Create a new conversation with a user
  static Future<ChatConversation> createConversation({
    required String participantId,
    required String participantName,
    String? participantImageUrl,
    bool isGroup = false,
  }) async {
    if (_conversationsBox == null) {
      throw Exception('ChatService not initialized');
    }
    
    // Check if conversation already exists
    final existing = getConversationByParticipant(participantId);
    if (existing != null) {
      return existing;
    }
    
    // Create new conversation
    final conversationId = const Uuid().v4();
    final conversation = ChatConversation(
      id: conversationId,
      participantId: participantId,
      participantName: participantName,
      participantImageUrl: participantImageUrl,
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      isGroup: isGroup,
    );
    
    // Create message box
    final boxName = '$_messagesBoxName-$conversationId';
    _messageBoxes[conversationId] = await Hive.openBox<ChatMessage>(boxName);
    
    // Save conversation
    await saveConversation(conversation);
    
    return conversation;
  }
  
  // Send a message in a conversation
  static Future<ChatMessage> sendMessage({
    required String conversationId,
    required String text,
    String? imageUrl,
  }) async {
    if (!_messageBoxes.containsKey(conversationId)) {
      throw Exception('Conversation not found');
    }
    
    final message = ChatMessage(
      id: const Uuid().v4(),
      senderId: 'current_user', // Assume current user is sending
      receiverId: getConversation(conversationId)?.participantId ?? '',
      text: text,
      timestamp: DateTime.now(),
      imageUrl: imageUrl,
    );
    
    // Save the message
    await saveMessage(conversationId, message);
    
    return message;
  }
  
  // Clear all chat data
  static Future<void> resetData() async {
    // Close all message boxes
    for (final box in _messageBoxes.values) {
      await box.clear();
      await box.close();
    }
    _messageBoxes.clear();
    
    // Clear conversations box
    if (_conversationsBox != null) {
      await _conversationsBox!.clear();
    }
  }
  
  // Community Chat Methods
  
  // Get real-time stream of conversations
  static Stream<List<ChatConversation>> getConversationsStream() {
    if (_conversationsBox == null) return Stream.value([]);
    
    // Create a stream controller
    final StreamController<List<ChatConversation>> controller = StreamController<List<ChatConversation>>();
    
    // Listen to box changes
    _conversationsBox!.watch().listen((_) {
      // When box changes, emit new list of sorted conversations
      final conversations = _conversationsBox!.values.toList();
      conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      controller.add(conversations);
    });
    
    // Add initial data
    final conversations = _conversationsBox!.values.toList();
    conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    controller.add(conversations);
    
    return controller.stream;
  }
  
  // Get real-time stream of messages for a conversation
  static Stream<List<ChatMessage>> getMessagesStream(String conversationId) {
    if (!_messageBoxes.containsKey(conversationId)) {
      // Return empty stream initially
      return Stream.value([]);
    }
    
    final StreamController<List<ChatMessage>> controller = StreamController<List<ChatMessage>>();
    
    // Listen to box changes
    _messageBoxes[conversationId]!.watch().listen((_) {
      // When box changes, emit new list of sorted messages
      final messages = _messageBoxes[conversationId]!.values.toList();
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      controller.add(messages);
    });
    
    // Add initial data
    final messages = _messageBoxes[conversationId]!.values.toList();
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    controller.add(messages);
    
    return controller.stream;
  }
  
  // Get community messages stream
  static Stream<List<Map<String, dynamic>>> getCommunityMessagesStream(String communityId) {
    return _communityMessagesCollection
        .where('communityId', isEqualTo: communityId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id,
              ...data,
            };
          }).toList();
        });
  }

  // Get recent students (registered in the last 30 days)
  static Future<List<Map<String, dynamic>>> getRecentStudents() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final timestamp = Timestamp.fromDate(thirtyDaysAgo);
    
    final snapshot = await _usersCollection
        .where('role', isEqualTo: 'student')
        .where('createdAt', isGreaterThanOrEqualTo: timestamp)
        .orderBy('createdAt', descending: true)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'name': data['name'] ?? 'Unknown',
        'rollNumber': data['rollNo']?.toString() ?? '',
        'email': data['email'] ?? '',
        'createdAt': data['createdAt'] != null 
            ? (data['createdAt'] as Timestamp).toDate() 
            : DateTime.now(),
      };
    }).toList();
  }

  // Create a new community
  static Future<void> createCommunity({
    required String name,
    String? description,
    required List<String> memberIds,
    String? imageUrl,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User must be logged in to create a community');
    }
    
    // Add creator to members if not already included
    if (!memberIds.contains(currentUser.uid)) {
      memberIds.add(currentUser.uid);
    }
    
    // Get creator data
    final creatorData = await _usersCollection.doc(currentUser.uid).get();
    final creatorName = (creatorData.data() as Map<String, dynamic>)['name'] ?? 'Unknown';
    
    // Add mentor-only to description if not already there
    String finalDescription = description ?? '';
    if (!finalDescription.contains('mentor-only')) {
      finalDescription = finalDescription.isEmpty 
          ? 'mentor-only community' 
          : '$finalDescription (mentor-only)';
    }
    
    // Create community document
    final communityRef = await _communitiesCollection.add({
      'name': name,
      'description': finalDescription,
      'members': memberIds,
      'createdBy': currentUser.uid,
      'creatorName': creatorName,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessage': 'Community created',
      'isGroup': true,
      'mentorOnly': true, // Only mentors can send messages
    });
    
    // Add a welcome message
    await _communityMessagesCollection.add({
      'communityId': communityRef.id,
      'senderId': currentUser.uid,
      'senderName': creatorName,
      'text': 'Welcome to the new community! Only mentors can send messages here.',
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'system',
    });
  }

  // Send a message to community
  static Future<void> sendCommunityMessage({
    required String communityId,
    required String text,
    String? imageUrl,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User must be logged in to send a message');
    }
    
    // Get user data
    final userData = await _usersCollection.doc(currentUser.uid).get();
    final userName = (userData.data() as Map<String, dynamic>)['name'] ?? 'Unknown';
    
    // Add message
    await _communityMessagesCollection.add({
      'communityId': communityId,
      'senderId': currentUser.uid,
      'senderName': userName,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'message',
    });
    
    // Update community's last message
    await _communitiesCollection.doc(communityId).update({
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  }

  // Get communities the current user is a member of
  static Stream<List<Map<String, dynamic>>> getUserCommunitiesStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }
    
    return _communitiesCollection
        .where('members', arrayContains: currentUser.uid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id,
              ...data,
            };
          }).toList();
        });
  }
  
  // Get available communities that user can join
  static Future<List<ConversationModel>> getAvailableCommunities() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return [];
    }
    
    // Get all communities
    final snapshot = await _communitiesCollection.get();
    
    List<ConversationModel> availableCommunities = [];
    
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final List<dynamic> members = data['members'] ?? [];
      
      // Only show communities user is not already a member of
      if (!members.contains(currentUser.uid)) {
        availableCommunities.add(ConversationModel.fromFirestore(doc));
      }
    }
    
    return availableCommunities;
  }
  
  // Join a community
  static Future<void> joinCommunity({
    required String communityId,
    required String userId,
  }) async {
    await _communitiesCollection.doc(communityId).update({
      'members': FieldValue.arrayUnion([userId]),
    });
  }
  
  // Leave a community
  static Future<void> leaveCommunity({
    required String communityId,
    required String userId,
  }) async {
    await _communitiesCollection.doc(communityId).update({
      'members': FieldValue.arrayRemove([userId]),
    });
  }
  
  // Update community members (for teachers)
  static Future<void> updateCommunityMembers({
    required String communityId,
    required List<String> memberIds,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User must be logged in to update community members');
    }
    
    // Make sure the teacher is still a member
    if (!memberIds.contains(currentUser.uid)) {
      memberIds.add(currentUser.uid);
    }
    
    await _communitiesCollection.doc(communityId).update({
      'members': memberIds,
    });
  }
  
  // Get all students (for adding members to communities)
  static Future<List<Map<String, dynamic>>> getAllStudents() async {
    final snapshot = await _firestore.collection('users')
        .where('isTeacher', isEqualTo: false)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] ?? 'Unknown',
        'rollNumber': data['rollNumber'],
        'email': data['email'],
      };
    }).toList();
  }
} 