import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/resources/models/resource_item.dart';
import 'package:acumen/features/resources/utils/resource_utils.dart';
import 'package:acumen/utils/app_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourcesTabController extends ChangeNotifier {
  String? selectedResourceId;
  bool isLoading = true;
  bool isAdmin = false;
  bool isMentor = false;
  String? currentUserId;
  String? selectedResourceTypeFilter;
  String selectedSourceFilter = 'All';

  Future<void> checkUserRole(BuildContext context) async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final currentUser = authController.currentUser;
    final appUser = authController.appUser;
    
    if (currentUser != null && appUser != null) {
      currentUserId = currentUser.uid;
      isAdmin = appUser.role == 'admin';
      isMentor = appUser.role == 'mentor';
      isLoading = false;
      notifyListeners();
    } else {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<ResourceItem>> fetchResources() async {
    List<ResourceItem> allResources = [];
    
    // Fetch from resources collection
    if (selectedSourceFilter == 'All' || selectedSourceFilter == 'Resources') {
      var resourcesQuery = FirebaseFirestore.instance
        .collection('resources')
        .orderBy('dateAdded', descending: true);
        
      if (selectedResourceTypeFilter != null && selectedResourceTypeFilter != 'All') {
        resourcesQuery = resourcesQuery.where('resourceType', isEqualTo: selectedResourceTypeFilter);
      }
      
      final snapshot = await resourcesQuery.get();
      final resources = snapshot.docs.map((doc) {
        ResourceItem item = ResourceItem.fromFirestore(doc);
        item.sourceType = 'Resource';
        return item;
      }).toList();
      
      allResources.addAll(resources);
    }
    
    // Fetch from solo chats
    if (selectedSourceFilter == 'All' || selectedSourceFilter == 'Chats') {
      var chatsQuery = FirebaseFirestore.instance
          .collection('chats')
          .where('participantIds', arrayContains: currentUserId);
      
      final chatSnapshot = await chatsQuery.get();
      
      for (var chatDoc in chatSnapshot.docs) {
        final messagesQuery = FirebaseFirestore.instance
            .collection('chats')
            .doc(chatDoc.id)
            .collection('messages')
            .orderBy('timestamp', descending: true);
        
        final messagesSnapshot = await messagesQuery.get();
        
        for (var messageDoc in messagesSnapshot.docs) {
          final data = messageDoc.data();
          if (data['fileUrl'] != null && data['fileUrl'] != '' && 
              ((data['type'] != 'text' && data['type'] != 'audio') ||
              ((data['fileType'] == 'image' || data['fileType'] == 'pdf')))) {
            final chatData = chatDoc.data();
            final otherParticipant = (chatData['participantIds'] as List)
                .firstWhere((id) => id != currentUserId, orElse: () => 'Unknown');
            
            final otherUserDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(otherParticipant)
                .get();
            
            String otherUserName = 'Unknown User';
            if (otherUserDoc.exists) {
              otherUserName = otherUserDoc.data()?['name'] ?? 'Unknown User';
            }
            
            ResourceItem resource = ResourceItem(
              id: messageDoc.id,
              title: data['fileName'] ?? data['mediaName'] ?? 'Shared File',
              description: data['text'] ?? 'File shared in chat',
              type: data['fileType'] ?? data['type'] ?? 'other',
              fileUrl: data['fileUrl'] ?? data['mediaUrl'],
              fileName: data['fileName'] ?? data['mediaName'],
              mentorId: data['senderId'] ?? data['userId'],
              mentorName: data['senderName'] ?? data['userName'] ?? 'Unknown',
              dateAdded: (data['timestamp'] as Timestamp).toDate(),
              resourceType: data['fileType'] != null ? data['fileType'].toString().toUpperCase() : (data['type'] ?? 'other').toUpperCase(),
              chatId: chatDoc.id,
              chatName: otherUserName,
              sourceType: 'Chat',
            );
            
            if (selectedResourceTypeFilter == null || 
                selectedResourceTypeFilter == 'All' || 
                selectedResourceTypeFilter == resource.resourceType) {
              allResources.add(resource);
            }
          }
        }
      }
    }
    
    // Fetch from communities
    if (selectedSourceFilter == 'All' || selectedSourceFilter == 'Communities') {
      var communitiesQuery = FirebaseFirestore.instance
          .collection('communities')
          .where('memberIds', arrayContains: currentUserId);
      
      final communitySnapshot = await communitiesQuery.get();
      
      for (var communityDoc in communitySnapshot.docs) {
        final messagesQuery = FirebaseFirestore.instance
            .collection('communities')
            .doc(communityDoc.id)
            .collection('messages')
            .orderBy('timestamp', descending: true);
        
        final messagesSnapshot = await messagesQuery.get();
        
        for (var messageDoc in messagesSnapshot.docs) {
          final data = messageDoc.data();
          if (data['fileUrl'] != null && data['fileUrl'] != '' && 
              ((data['type'] != 'text' && data['type'] != 'audio') ||
              ((data['fileType'] == 'image' || data['fileType'] == 'pdf')))) {
            final communityData = communityDoc.data();
            
            ResourceItem resource = ResourceItem(
              id: messageDoc.id,
              title: data['fileName'] ?? data['mediaName'] ?? 'Shared File',
              description: data['text'] ?? 'File shared in community',
              type: data['fileType'] ?? data['type'] ?? 'other',
              fileUrl: data['fileUrl'] ?? data['mediaUrl'],
              fileName: data['fileName'] ?? data['mediaName'],
              mentorId: data['senderId'] ?? data['userId'],
              mentorName: data['senderName'] ?? data['userName'] ?? 'Unknown',
              dateAdded: (data['timestamp'] as Timestamp).toDate(),
              resourceType: data['fileType'] != null ? data['fileType'].toString().toUpperCase() : (data['type'] ?? 'other').toUpperCase(),
              communityId: communityDoc.id,
              communityName: communityData['name'] ?? 'Unknown Community',
              sourceType: 'Community',
            );
            
            if (selectedResourceTypeFilter == null || 
                selectedResourceTypeFilter == 'All' || 
                selectedResourceTypeFilter == resource.resourceType) {
              allResources.add(resource);
            }
          }
        }
      }
    }
    
    // Sort by date
    allResources.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    return allResources;
  }

  Future<void> openResource(BuildContext context, ResourceItem resource) async {
    if (resource.fileUrl == null) {
      AppSnackbar.showError(context: context, message: 'No file available for this resource');
      return;
    }

    try {
      final url = Uri.parse(resource.fileUrl!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        AppSnackbar.showError(context: context, message: 'Could not open the file');
      }
    } catch (e) {
      AppSnackbar.showError(context: context, message: 'Error opening resource: $e');
    }
  }

  Future<void> editResource(BuildContext context, ResourceItem resource) async {
    final titleController = TextEditingController(text: resource.title);
    final descriptionController = TextEditingController(text: resource.description);
    String selectedType = resource.type;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Resource'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Resource Type',
                  border: OutlineInputBorder(),
                ),
                items: ['pdf', 'doc', 'link', 'video', 'image', 'other'].map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedType = value!;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await FirebaseFirestore.instance
            .collection('resources')
            .doc(resource.id)
            .update({
          'title': titleController.text.trim(),
          'description': descriptionController.text.trim(),
          'type': selectedType,
          'lastUpdated': Timestamp.now(),
        });
        
        AppSnackbar.showSuccess(context: context, message: 'Resource updated successfully');
      } catch (e) {
        AppSnackbar.showError(context: context, message: 'Failed to update resource: $e');
      }
    }
  }

  Future<void> deleteResource(BuildContext context, ResourceItem resource) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this resource?'),
        content: Text('Are you sure you want to delete "${resource.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        // Delete file from storage if exists
        if (resource.fileUrl != null) {
          try {
            await FirebaseStorage.instance.refFromURL(resource.fileUrl!).delete();
          } catch (e) {
            // File might not exist, continue with document deletion
          }
        }
        
        // Delete document from Firestore
        if (resource.sourceType == 'Resource') {
          await FirebaseFirestore.instance
              .collection('resources')
              .doc(resource.id)
              .delete();
        }
        
        AppSnackbar.showSuccess(context: context, message: 'Resource deleted successfully');
      } catch (e) {
        AppSnackbar.showError(context: context, message: 'Failed to delete resource: $e');
      }
    }
  }

  void shareResource(BuildContext context, ResourceItem resource) {
    AppSnackbar.showInfo(context: context, message: 'Sharing resource: ${resource.title}');
  }

  void showResourceDetails(BuildContext context, ResourceItem resource) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(resource.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Type: ${resource.resourceType}'),
              const SizedBox(height: 8),
              Text('Description: ${resource.description}'),
              const SizedBox(height: 8),
              Text('File Format: ${resource.type.toUpperCase()}'),
              const SizedBox(height: 8),
              Text('Added by: ${resource.mentorName}'),
              const SizedBox(height: 8),
              Text('Added on: ${ResourceUtils.formatDate(resource.dateAdded)}'),
              if (resource.fileName != null) ...[
                const SizedBox(height: 8),
                Text('File: ${resource.fileName}'),
              ],
              if (resource.sourceType == 'Chat') ...[
                const SizedBox(height: 8),
                Text('Source: Chat with ${resource.chatName}'),
              ],
              if (resource.sourceType == 'Community') ...[
                const SizedBox(height: 8),
                Text('Source: Community "${resource.communityName}"'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
          if (resource.fileUrl != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                openResource(context, resource);
              },
              child: const Text('OPEN'),
            ),
        ],
      ),
    );
  }

  void setSelectedResourceId(String? id) {
    selectedResourceId = id;
    notifyListeners();
  }

  void setResourceTypeFilter(String? type) {
    selectedResourceTypeFilter = type;
    notifyListeners();
  }

  void setSourceFilter(String source) {
    selectedSourceFilter = source;
    notifyListeners();
  }

  bool canEditResource(ResourceItem resource) {
    return isAdmin || 
        (isMentor && resource.mentorId == currentUserId) || 
        (resource.sourceType == 'Chat' && resource.mentorId == currentUserId) ||
        (resource.sourceType == 'Community' && resource.mentorId == currentUserId);
  }
} 