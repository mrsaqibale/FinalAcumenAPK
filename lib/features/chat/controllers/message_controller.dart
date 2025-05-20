import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageController extends ChangeNotifier {
  // Media downloading state
  Map<String, bool> _isDownloading = {};
  Map<String, double> _downloadProgress = {};
  Map<String, bool> _isDownloaded = {};
  Map<String, String> _localFilePaths = {};
  
  // Voice player state
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingId;
  double _playbackProgress = 0;
  StreamSubscription? _playbackSubscription;
  
  // Message selection state
  bool _isSelectionMode = false;
  List<String> _selectedMessageIds = [];
  
  // Getters
  bool get isSelectionMode => _isSelectionMode;
  List<String> get selectedMessageIds => _selectedMessageIds;
  double get playbackProgress => _playbackProgress;
  String? get currentlyPlayingId => _currentlyPlayingId;
  
  // Check if a message is downloading
  bool isDownloading(String messageId) => _isDownloading[messageId] ?? false;
  
  // Get download progress for a message
  double getDownloadProgress(String messageId) => _downloadProgress[messageId] ?? 0;
  
  // Check if a message is downloaded
  bool isDownloaded(String messageId) => _isDownloaded[messageId] ?? false;
  
  // Get local file path for a message
  String? getLocalFilePath(String messageId) => _localFilePaths[messageId];
  
  // Check if a message is selected
  bool isSelected(String messageId) => _selectedMessageIds.contains(messageId);
  
  // Check if a message is playing
  bool isPlaying(String messageId) => _currentlyPlayingId == messageId && _audioPlayer.playing;
  
  MessageController() {
    _init();
  }
  
  Future<void> _init() async {
    // Load downloaded status from shared preferences
    await _loadDownloadedFilesInfo();
    
    // Set up audio player position listener
    _playbackSubscription = _audioPlayer.positionStream.listen((position) {
      if (_audioPlayer.duration != null) {
        _playbackProgress = position.inMilliseconds / _audioPlayer.duration!.inMilliseconds;
        notifyListeners();
      }
    });
    
    // Set up audio player completion listener
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _playbackProgress = 0;
        _currentlyPlayingId = null;
        notifyListeners();
      }
    });
  }
  
  // Load downloaded files info from shared preferences
  Future<void> _loadDownloadedFilesInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get downloaded files list
      final downloadedFiles = prefs.getStringList('downloadedFiles') ?? [];
      
      // Get file paths
      final Map<String, String> filePaths = {};
      for (final id in downloadedFiles) {
        final path = prefs.getString('filePath_$id');
        if (path != null) {
          filePaths[id] = path;
          
          // Check if file exists
          final file = File(path);
          if (await file.exists()) {
            _isDownloaded[id] = true;
            _localFilePaths[id] = path;
          } else {
            // File doesn't exist anymore, remove from downloaded list
            prefs.remove('filePath_$id');
          }
        }
      }
      
      // Save cleaned up list
      final validDownloadedFiles = _isDownloaded.keys.toList();
      await prefs.setStringList('downloadedFiles', validDownloadedFiles);
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading downloaded files info: $e');
      }
    }
  }
  
  // Save download info to shared preferences
  Future<void> _saveDownloadInfo(String messageId, String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get current downloaded files
      final downloadedFiles = prefs.getStringList('downloadedFiles') ?? [];
      
      // Add new file if not already in the list
      if (!downloadedFiles.contains(messageId)) {
        downloadedFiles.add(messageId);
        await prefs.setStringList('downloadedFiles', downloadedFiles);
      }
      
      // Save file path
      await prefs.setString('filePath_$messageId', filePath);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving download info: $e');
      }
    }
  }
  
  // Download media file
  Future<void> downloadMedia(String messageId, String url, String contentType) async {
    // Check if already downloading
    if (_isDownloading[messageId] == true) return;
    
    // Check if already downloaded
    if (_isDownloaded[messageId] == true) return;
    
    try {
      // Start download
      _isDownloading[messageId] = true;
      _downloadProgress[messageId] = 0;
      notifyListeners();
      
      // Get file extension from content type or URL
      String extension;
      if (contentType == 'image') {
        extension = url.contains('.png') ? 'png' : 'jpg';
      } else if (contentType == 'video') {
        extension = 'mp4';
      } else if (contentType == 'pdf') {
        extension = 'pdf';
      } else if (contentType == 'voice') {
        extension = 'm4a';
      } else if (contentType == 'presentation') {
        extension = url.contains('.ppt') ? 'ppt' : 'pptx';
      } else {
        extension = 'doc';
      }
      
      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${const Uuid().v4()}.$extension';
      final filePath = path.join(directory.path, fileName);
      
      // Create file
      final file = File(filePath);
      
      // Start download with progress tracking
      final storageRef = FirebaseStorage.instance.refFromURL(url);
      final downloadTask = storageRef.writeToFile(file);
      
      // Track progress
      downloadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        _downloadProgress[messageId] = snapshot.bytesTransferred / snapshot.totalBytes;
        notifyListeners();
      }, onError: (e) {
        // Handle error
        _isDownloading[messageId] = false;
        _downloadProgress.remove(messageId);
        notifyListeners();
        if (kDebugMode) {
          print('Error downloading file: $e');
        }
      });
      
      // Wait for download to complete
      await downloadTask;
      
      // Update downloaded status
      _isDownloaded[messageId] = true;
      _localFilePaths[messageId] = filePath;
      _isDownloading[messageId] = false;
      
      // Save download info
      await _saveDownloadInfo(messageId, filePath);
      
      notifyListeners();
    } catch (e) {
      // Reset states on error
      _isDownloading[messageId] = false;
      _downloadProgress.remove(messageId);
      notifyListeners();
      
      if (kDebugMode) {
        print('Error downloading media: $e');
      }
    }
  }
  
  // Open media file
  Future<void> openMedia(String messageId, String url, String contentType) async {
    // If not downloaded, start download
    if (_isDownloaded[messageId] != true) {
      await downloadMedia(messageId, url, contentType);
      return;
    }
    
    // File already downloaded, get path
    final filePath = _localFilePaths[messageId];
    if (filePath == null) return;
    
    // For voice messages, play audio
    if (contentType == 'voice') {
      await playVoiceMessage(messageId, filePath);
      return;
    }
    
    // For other types, return file path to be handled by UI
    return;
  }
  
  // Play voice message
  Future<void> playVoiceMessage(String messageId, String filePath) async {
    try {
      // If already playing this message, pause it
      if (_currentlyPlayingId == messageId && _audioPlayer.playing) {
        await _audioPlayer.pause();
        notifyListeners();
        return;
      }
      
      // If playing another message, stop it
      if (_currentlyPlayingId != null && _currentlyPlayingId != messageId) {
        await _audioPlayer.stop();
        _playbackProgress = 0;
      }
      
      // Set current playing ID
      _currentlyPlayingId = messageId;
      
      // If already loaded but paused, just resume
      if (_audioPlayer.processingState == ProcessingState.ready) {
        await _audioPlayer.play();
      } else {
        // Load and play audio
        await _audioPlayer.setFilePath(filePath);
        await _audioPlayer.play();
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error playing voice message: $e');
      }
    }
  }
  
  // Toggle message selection
  void toggleMessageSelection(String messageId) {
    if (!_isSelectionMode) {
      _isSelectionMode = true;
      _selectedMessageIds = [messageId];
    } else {
      if (_selectedMessageIds.contains(messageId)) {
        _selectedMessageIds.remove(messageId);
        
        // If no messages selected, exit selection mode
        if (_selectedMessageIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedMessageIds.add(messageId);
      }
    }
    
    notifyListeners();
  }
  
  // Clear message selection
  void clearSelection() {
    _isSelectionMode = false;
    _selectedMessageIds = [];
    notifyListeners();
  }
  
  // Delete selected messages
  Future<void> deleteSelectedMessages(String communityId) async {
    if (_selectedMessageIds.isEmpty) return;
    
    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();
      final messagesCollection = firestore.collection('community_messages');
      
      // Get current user ID
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;
      
      // Read messages first to check if user can delete them
      final messageSnapshots = await messagesCollection
          .where(FieldPath.documentId, whereIn: _selectedMessageIds)
          .get();
          
      for (final doc in messageSnapshots.docs) {
        final data = doc.data();
        // Only delete messages sent by current user
        if (data['senderId'] == currentUser.uid) {
          batch.delete(doc.reference);
        }
      }
      
      // Execute batch delete
      await batch.commit();
      
      // Clear selection
      clearSelection();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting messages: $e');
      }
      rethrow;
    }
  }
  
  // Copy selected messages to clipboard
  List<String> getSelectedMessagesText(List<Map<String, dynamic>> messages) {
    final List<String> textList = [];
    
    for (final id in _selectedMessageIds) {
      try {
        final message = messages.firstWhere((m) => m['id'] == id);
        if (message['text'] != null && message['text'].isNotEmpty) {
          textList.add(message['text']);
        }
      } catch (e) {
        // Message not found, skip
      }
    }
    
    return textList;
  }
  
  // Reply to message
  Future<void> replyToMessage(String communityId, String messageId, String replyText) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;
      
      // Get the message being replied to
      final messageDoc = await firestore
          .collection('community_messages')
          .doc(messageId)
          .get();
          
      if (!messageDoc.exists) return;
      
      final messageData = messageDoc.data()!;
      
      // Get user data
      final userData = await firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
          
      final userName = userData.exists 
          ? (userData.data()?['name'] as String?) ?? 'Unknown'
          : 'Unknown';
      
      // Create reply data
      await firestore.collection('community_messages').add({
        'communityId': communityId,
        'senderId': currentUser.uid,
        'senderName': userName,
        'text': replyText,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'reply',
        'replyToMessageId': messageId,
        'replyToSenderName': messageData['senderName'],
        'replyToText': messageData['text'],
      });
      
      // Update community's last message
      await firestore.collection('communities').doc(communityId).update({
        'lastMessage': 'Replied to a message: $replyText',
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
      
      // Clear selection
      clearSelection();
    } catch (e) {
      if (kDebugMode) {
        print('Error replying to message: $e');
      }
      rethrow;
    }
  }
  
  // Forward message
  Future<void> forwardMessage({
    required String messageId,
    required List<String> targetCommunityIds,
    required Map<String, dynamic> originalMessage,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;
      
      // Get user data
      final userData = await firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
          
      final userName = userData.exists 
          ? (userData.data()?['name'] as String?) ?? 'Unknown'
          : 'Unknown';
      
      // Forward to all target communities
      for (final communityId in targetCommunityIds) {
        // Create forwarded message
        await firestore.collection('community_messages').add({
          'communityId': communityId,
          'senderId': currentUser.uid,
          'senderName': userName,
          'text': originalMessage['text'] ?? '',
          'imageUrl': originalMessage['imageUrl'],
          'contentType': originalMessage['contentType'],
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'forwarded',
          'forwardedFromName': originalMessage['senderName'],
        });
        
        // Update community's last message
        await firestore.collection('communities').doc(communityId).update({
          'lastMessage': 'Forwarded a message',
          'lastMessageAt': FieldValue.serverTimestamp(),
        });
      }
      
      // Clear selection
      clearSelection();
    } catch (e) {
      if (kDebugMode) {
        print('Error forwarding message: $e');
      }
      rethrow;
    }
  }
  
  @override
  void dispose() {
    _playbackSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
} 