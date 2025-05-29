import 'dart:async';
import 'dart:io';
import 'package:acumen/features/chat/models/chat_conversation_model.dart';
import 'package:acumen/features/chat/models/chat_message_model.dart';
import 'package:acumen/features/chat/models/conversation_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  static final CollectionReference _communitiesCollection = _firestore
      .collection('communities');
  static final CollectionReference _communityMessagesCollection = _firestore
      .collection('community_messages');
  static final CollectionReference _usersCollection = _firestore.collection(
    'users',
  );
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
    _conversationsBox = await Hive.openBox<ChatConversation>(
      _conversationsBoxName,
    );

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
    conversations.sort(
      (a, b) => b.lastMessageTime.compareTo(a.lastMessageTime),
    );
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
      return _conversationsBox!.values.firstWhere(
        (c) => c.participantId == participantId,
      );
    } catch (e) {
      return null;
    }
  }

  // Create or update a conversation
  static Future<ChatConversation> saveConversation(
    ChatConversation conversation,
  ) async {
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

    // Delete from Firestore
    try {
      // Delete conversation document
      await FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationId)
          .delete();
      // Delete all messages in the subcollection (if exists)
      final messagesCollection = FirebaseFirestore.instance
          .collection('chats')
          .doc(conversationId)
          .collection('messages');
      final messagesSnapshot = await messagesCollection.get();
      for (var doc in messagesSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      if (kDebugMode)
        print('Error deleting conversation/messages from Firestore: $e');
    }

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
  static Future<ChatMessage> saveMessage(
    String conversationId,
    ChatMessage message,
  ) async {
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
      final updatedConversation = conversation.copyWith(
        hasUnreadMessages: false,
      );
      await saveConversation(updatedConversation);
    }
  }

  // Create a new conversation with a user
  static Future<ChatConversation> createConversation({
    required String participantId,
    required String participantName,
    String? participantImageUrl,
    bool isGroup = false,
    String? conversationId,
  }) async {
    if (_conversationsBox == null) {
      throw Exception('ChatService not initialized');
    }
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User must be logged in to create a conversation');
    }
    // Always use unique chatroom ID for one-to-one chats
    final convId =
        isGroup
            ? (conversationId ?? const Uuid().v4())
            : getConversationId(currentUser.uid, participantId);
    // Check if conversation already exists
    final existing = getConversation(convId);
    if (existing != null) {
      return existing;
    }
    // For one-to-one chats, always set participantId/Name to the OTHER user
    String otherUserId = participantId;
    String otherUserName = participantName;
    String? otherUserImageUrl = participantImageUrl;
    if (!isGroup) {
      if (participantId == currentUser.uid) {
        // Defensive: shouldn't happen, but if it does, swap to the other user
        otherUserId = currentUser.uid;
        otherUserName = currentUser.displayName ?? 'Unknown';
        otherUserImageUrl = currentUser.photoURL;
      }
    }
    // Create new conversation
    final conversation = ChatConversation(
      id: convId,
      participantId: otherUserId,
      participantName: otherUserName,
      participantImageUrl: otherUserImageUrl,
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      isGroup: isGroup,
      participantHasVerifiedSkills: false,
    );
    try {
      // Create conversation in Firebase
      await _firestore.collection('conversations').doc(convId).set({
        'id': convId,
        'members': [currentUser.uid, otherUserId],
        'participantId': otherUserId,
        'participantName': otherUserName,
        'participantImageUrl': otherUserImageUrl,
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessageSender': '',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': currentUser.uid,
        'isGroup': isGroup,
        'hasUnreadMessages': false,
        'participantHasVerifiedSkills': false,
      });
      // Create message box
      final boxName = '$_messagesBoxName-$convId';
      _messageBoxes[convId] = await Hive.openBox<ChatMessage>(boxName);
      // Save conversation locally
      await saveConversation(conversation);
      print("DEBUG: Created new conversation with ID: $convId");
      return conversation;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating conversation in Firebase: $e');
      }
      // Still try to save locally as fallback
      final boxName = '$_messagesBoxName-$convId';
      _messageBoxes[convId] = await Hive.openBox<ChatMessage>(boxName);
      await saveConversation(conversation);
      return conversation;
    }
  }

  // Helper to generate a unique conversation ID for two users
  static String getConversationId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return ids.join('_');
  }

  // Send a message in a conversation (old logic)
  static Future<ChatMessage> sendMessage({
    required String conversationId,
    required String text,
    required String receiverId,
    String? imageUrl,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final message = ChatMessage(
      id: time,
      senderId: currentUser.uid,
      receiverId: receiverId,
      text: text,
      timestamp: DateTime.now(),
      isRead: false,
      fileUrl: imageUrl,
      fileName: null,
      fileType: imageUrl == null ? 'text' : 'image',
    );
    // Store in Firestore (old structure)
    try {
      print(
        '[DEBUG] Sending message to Firestore: chats/$conversationId/messages/$time',
      );
      print(
        '[DEBUG] Message data: \\${message.text} from \\${message.senderId} to \\${message.receiverId}',
      );
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(conversationId)
          .collection('messages')
          .doc(time)
          .set({
            'id': message.id,
            'text': message.text,
            'senderId': message.senderId,
            'receiverId': message.receiverId,
            'timestamp': message.timestamp,
            'isRead': message.isRead,
            'fileUrl': message.fileUrl,
            'fileName': message.fileName,
            'fileType': message.fileType,
          });
      print('[DEBUG] Message sent successfully.');
    } catch (e) {
      print('[ERROR] Failed to send message: \\${e.toString()}');
      rethrow;
    }
    return message;
  }

  // Get all messages for a conversation
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
    String otherUserId,
  ) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final conversationId = getConversationId(currentUser!.uid, otherUserId);

    return FirebaseFirestore.instance
        .collection('chats/$conversationId/messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
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
    final StreamController<List<ChatConversation>> controller =
        StreamController<List<ChatConversation>>();

    // Listen to box changes
    _conversationsBox!.watch().listen((_) {
      // When box changes, emit new list of sorted conversations
      final conversations = _conversationsBox!.values.toList();
      conversations.sort(
        (a, b) => b.lastMessageTime.compareTo(a.lastMessageTime),
      );
      controller.add(conversations);
    });

    // Add initial data
    final conversations = _conversationsBox!.values.toList();
    conversations.sort(
      (a, b) => b.lastMessageTime.compareTo(a.lastMessageTime),
    );
    controller.add(conversations);

    return controller.stream;
  }

  // Get real-time stream of messages for a conversation
  static Stream<List<ChatMessage>> getMessagesStream(String conversationId) {
    final StreamController<List<ChatMessage>> controller =
        StreamController<List<ChatMessage>>();
    print('[DEBUG] Listening for messages in chats/$conversationId/messages');
    FirebaseFirestore.instance
        .collection('chats')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen(
          (snapshot) {
            try {
              print(
                '[DEBUG] Received \\${snapshot.docs.length} messages from Firestore for conversation $conversationId',
              );
              // Convert Firestore documents to ChatMessage objects
              final messages =
                  snapshot.docs.map((doc) {
                    final data = doc.data();

                    DateTime messageTime;
                    try {
                      messageTime =
                          data['timestamp'] != null
                              ? (data['timestamp'] as Timestamp).toDate()
                              : DateTime.now();
                    } catch (e) {
                      messageTime = DateTime.now();
                    }

                    // Create message object
                    final message = ChatMessage(
                      id: doc.id,
                      senderId: data['senderId'] ?? '',
                      receiverId: data['receiverId'] ?? '',
                      text: data['text'] ?? '',
                      timestamp: messageTime,
                      isRead: data['isRead'] ?? false,
                      fileUrl: data['fileUrl'],
                      fileName: data['fileName'],
                      fileType: data['type'],
                    );

                    // Save to local cache for offline access
                    if (_messageBoxes.containsKey(conversationId)) {
                      _messageBoxes[conversationId]!.put(message.id, message);
                    }

                    return message;
                  }).toList();

              // Sort by timestamp (oldest first)
              messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

              // Emit sorted messages
              controller.add(messages);
            } catch (e) {
              print('[ERROR] Error in message stream: \\${e.toString()}');
              // If there's an error with Firebase, fall back to local cache
              if (_messageBoxes.containsKey(conversationId)) {
                final localMessages =
                    _messageBoxes[conversationId]!.values.toList();
                localMessages.sort(
                  (a, b) => a.timestamp.compareTo(b.timestamp),
                );
                controller.add(localMessages);
              } else {
                controller.add([]);
              }
            }
          },
          onError: (e) {
            print(
              '[ERROR] Error in Firebase message stream: \\${e.toString()}',
            );
            // If there's an error with Firebase, fall back to local cache
            if (_messageBoxes.containsKey(conversationId)) {
              final localMessages =
                  _messageBoxes[conversationId]!.values.toList();
              localMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
              controller.add(localMessages);
            } else {
              controller.add([]);
            }
          },
        );

    // Initial data - use local cache while waiting for Firebase
    if (_messageBoxes.containsKey(conversationId)) {
      final messages = _messageBoxes[conversationId]!.values.toList();
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      controller.add(messages);
    } else {
      controller.add([]);
    }

    return controller.stream;
  }

  // Get community messages stream
  static Stream<List<Map<String, dynamic>>> getCommunityMessagesStream(
    String communityId,
  ) {
    print(
      '[DEBUG] Listening for community messages in communities/$communityId/messages',
    );
    return _firestore
        .collection('communities')
        .doc(communityId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          print(
            '[DEBUG] Received \\${snapshot.docs.length} community messages from Firestore for community $communityId',
          );
          final messages =
              snapshot.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return {'id': doc.id, ...data};
              }).toList();

          print("DEBUG: ChatService - Processed ${messages.length} messages");
          return messages;
        });
  }

  // Get recent students (registered in the last 30 days)
  static Future<List<Map<String, dynamic>>> getRecentStudents() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      final usersQuery =
          await _usersCollection
              .where('role', isEqualTo: 'student')
              .where('isActive', isEqualTo: true) // Only active users
              .where('createdAt', isGreaterThan: thirtyDaysAgo)
              .orderBy('createdAt', descending: true)
              .limit(20)
              .get();

      return usersQuery.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown',
          'email': data['email'] ?? '',
          'photoUrl': data['photoUrl'],
          'role': data['role'] ?? 'student',
        };
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting recent students: $e');
      }
      return [];
    }
  }

  // Get all users for chat (filtered by active status)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final usersQuery =
          await _usersCollection
              .where('isActive', isEqualTo: true) // Only active users
              .orderBy('name')
              .limit(50)
              .get();

      return usersQuery.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown',
          'email': data['email'] ?? '',
          'photoUrl': data['photoUrl'],
          'role': data['role'] ?? 'student',
        };
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting all users: $e');
      }
      return [];
    }
  }

  // Create a new community
  static Future<void> createCommunity({
    required String name,
    String? description,
    required List<String> memberIds,
    String? imageUrl,
    bool isPublic = false,
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
    final creatorName =
        (creatorData.data() as Map<String, dynamic>)['name'] ?? 'Unknown';

    // Add mentor-only to description if not already there and it's not a public community
    String finalDescription = description ?? '';
    if (!isPublic && !finalDescription.contains('mentor-only')) {
      finalDescription =
          finalDescription.isEmpty
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
      'mentorOnly':
          !isPublic, // Only mentors can send messages in private communities
      'isPublic': isPublic, // Whether students can join this community
    });

    // Add a welcome message
    await _firestore
        .collection('communities')
        .doc(communityRef.id)
        .collection('messages')
        .add({
          'senderId': currentUser.uid,
          'senderName': creatorName,
          'text':
              isPublic
                  ? 'Welcome to the new community! Students can join this community.'
                  : 'Welcome to the new community! Only mentors can send messages here.',
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'system',
        });
  }

  // Upload media file to Firebase Storage
  static Future<String> uploadMediaFile({
    required File file,
    required String path,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User must be logged in to upload media');
    }

    try {
      // Create a storage reference for the file
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child(path)
          .child(fileName);

      // Upload the file
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});

      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading media: $e');
      }
      throw Exception('Failed to upload media: $e');
    }
  }

  // Send a message to community
  static Future<void> sendCommunityMessage({
    required String communityId,
    required String text,
    String? imageUrl,
    String? contentType,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User must be logged in to send a message');
    }
    // Get user data
    final userData = await _usersCollection.doc(currentUser.uid).get();
    final userName =
        (userData.data() as Map<String, dynamic>)['name'] ?? 'Unknown';
    final hasVerifiedSkills =
        (userData.data() as Map<String, dynamic>)['hasVerifiedSkills'] ?? false;
    try {
      print(
        '[DEBUG] Sending community message to Firestore: communities/$communityId/messages',
      );
      print(
        '[DEBUG] Community message data: \\${text} from \\${currentUser.uid}',
      );
      await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('messages')
          .add({
            'senderId': currentUser.uid,
            'senderName': userName,
            'senderHasVerifiedSkills': hasVerifiedSkills,
            'text': text,
            'imageUrl': imageUrl,
            'contentType': contentType ?? (imageUrl != null ? 'image' : 'text'),
            'timestamp': FieldValue.serverTimestamp(),
            'type': 'message',
          });
      print('[DEBUG] Community message sent successfully.');
    } catch (e) {
      print('[ERROR] Failed to send community message: \\${e.toString()}');
      rethrow;
    }
    // Update community's last message with appropriate description based on content type
    String lastMessage = text;
    if (text.isEmpty && contentType != null) {
      lastMessage =
          contentType == 'image'
              ? 'Sent an image'
              : contentType == 'video'
              ? 'Sent a video'
              : contentType == 'pdf'
              ? 'Sent a PDF document'
              : contentType == 'presentation'
              ? 'Sent a presentation'
              : contentType == 'voice'
              ? 'Sent a voice message'
              : 'Sent a file';
    }

    await _communitiesCollection.doc(communityId).update({
      'lastMessage': lastMessage,
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
            return {'id': doc.id, ...data};
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
    final snapshot =
        await _firestore
            .collection('users')
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
