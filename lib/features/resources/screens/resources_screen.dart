import 'package:flutter/material.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:acumen/features/resources/models/resource_item.dart';
import 'package:acumen/features/resources/utils/resource_utils.dart';
import 'package:acumen/features/resources/widgets/file_type_icon.dart';
import 'package:acumen/features/resources/widgets/resource_preview_widget.dart';
import 'package:acumen/utils/app_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/features/chat/models/chat_message_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:acumen/features/resources/widgets/chat_list_widget.dart';
import 'package:acumen/features/resources/widgets/resource_community_chat_screen.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen>
    with SingleTickerProviderStateMixin {
  ResourceItem? _selectedResource;
  bool _isLoading = false;
  bool _canEdit = false;
  bool _showFullPreview = false;
  String? selectedConversationId;
  late TabController _tabController;
  List<Map<String, dynamic>> _allStudents = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllStudents();
  }

  Future<void> _loadAllStudents() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final authController = Provider.of<AuthController>(
        context,
        listen: false,
      );
      final students = await authController.getAllStudents();
      final currentUserId = authController.currentUser?.uid;
      final filteredStudents =
          students.where((student) => student['id'] != currentUserId).toList();
      setState(() {
        _allStudents = filteredStudents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        AppSnackbar.showError(
          context: context,
          message: 'Failed to load students: $e',
        );
      }
    }
  }

  void _showSoloChatOptions(String conversationId) {
    setState(() {
      selectedConversationId = conversationId;
    });
  }

  void _showDeleteOptions(String conversationId, dynamic conversation) {
    setState(() {
      selectedConversationId = conversationId;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedResource != null) {
      final resource = _selectedResource!;
      final canShowPreview = _canShowPreview(resource);
      _checkPermissions(resource);
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              setState(() {
                _selectedResource = null;
                _showFullPreview = false;
              });
            },
          ),
          title: const Text(
            'Resource Details',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            if (_canEdit)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                onPressed: () => _deleteResource(resource),
              ),
          ],
        ),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with resource type and icon
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        child: Row(
                          children: [
                            if (!canShowPreview)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: FileTypeIcon(
                                  type: resource.type,
                                  size: 40,
                                ),
                              ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    resource.resourceType,
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    resource.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // File preview for PDF and image
                      if (canShowPreview) ...[
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Preview',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  TextButton.icon(
                                    icon: Icon(
                                      _showFullPreview
                                          ? Icons.fullscreen_exit
                                          : Icons.fullscreen,
                                    ),
                                    label: Text(
                                      _showFullPreview ? 'Minimize' : 'Expand',
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _showFullPreview = !_showFullPreview;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ResourcePreviewWidget(
                                resource: resource,
                                height: _showFullPreview ? 500 : 250,
                                showControls: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                      // Resource details
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              resource.description,
                              style: const TextStyle(fontSize: 16, height: 1.5),
                            ),
                            const SizedBox(height: 24),
                            // Resource metadata
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow(
                                    'File Type',
                                    resource.type.toUpperCase(),
                                  ),
                                  const Divider(height: 24),
                                  _buildInfoRow(
                                    'Added by',
                                    resource.mentorName,
                                  ),
                                  const Divider(height: 24),
                                  _buildInfoRow(
                                    'Date Added',
                                    DateFormat(
                                      'MMMM dd, yyyy',
                                    ).format(resource.dateAdded),
                                  ),
                                  if (resource.fileName != null) ...[
                                    const Divider(height: 24),
                                    _buildInfoRow(
                                      'File Name',
                                      resource.fileName!,
                                    ),
                                  ],
                                  if (resource.sourceType == 'Chat' &&
                                      resource.chatName != null) ...[
                                    const Divider(height: 24),
                                    _buildInfoRow(
                                      'Source',
                                      'Chat with ${resource.chatName}',
                                    ),
                                  ],
                                  if (resource.sourceType == 'Community' &&
                                      resource.communityName != null) ...[
                                    const Divider(height: 24),
                                    _buildInfoRow(
                                      'Source',
                                      'Community "${resource.communityName}"',
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                            // Action buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildActionButton(
                                  icon: Icons.download_outlined,
                                  label: 'Download',
                                  color: Colors.blue,
                                  onPressed: () => _openResource(resource),
                                ),
                                _buildActionButton(
                                  icon: Icons.visibility_outlined,
                                  label: 'View',
                                  color: AppTheme.primaryColor,
                                  onPressed: () => _openResource(resource),
                                ),
                                _buildActionButton(
                                  icon: Icons.share_outlined,
                                  label: 'Share',
                                  color: Colors.green,
                                  onPressed: () => _shareResource(resource),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      );
    }

    // Tabbed interface for resources
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Resources',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'MY CHATS'), Tab(text: 'COMMUNITIES')],
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // MY CHATS TAB
          ChatListWidget(
            selectedConversationId: selectedConversationId,
            onShowSoloChatOptions: _showSoloChatOptions,
            onShowDeleteOptions: _showDeleteOptions,
          ),
          // COMMUNITIES TAB
          _buildCommunitiesTab(),
        ],
      ),
    );
  }

  void _checkPermissions(ResourceItem resource) {
    final authController = Provider.of<AuthController>(context, listen: false);
    final currentUser = authController.currentUser;
    final appUser = authController.appUser;
    if (currentUser != null && appUser != null) {
      setState(() {
        _canEdit =
            appUser.role == 'admin' ||
            (appUser.role == 'mentor' && resource.mentorId == currentUser.uid);
      });
    }
  }

  Future<void> _openResource(ResourceItem resource) async {
    if (resource.fileUrl == null) {
      AppSnackbar.showError(
        context: context,
        message: 'No file available for this resource',
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final url = Uri.parse(resource.fileUrl!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          AppSnackbar.showError(
            context: context,
            message: 'Could not open the file',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(
          context: context,
          message: 'Error opening resource: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _shareResource(ResourceItem resource) {
    AppSnackbar.showInfo(
      context: context,
      message: 'Sharing resource: ${resource.title}',
    );
  }

  Future<void> _deleteResource(ResourceItem resource) async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete this resource?'),
            content: Text(
              'Are you sure you want to delete "${resource.title}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    if (resource.fileUrl != null) {
                      try {
                        await FirebaseStorage.instance
                            .refFromURL(resource.fileUrl!)
                            .delete();
                      } catch (e) {}
                    }
                    await FirebaseFirestore.instance
                        .collection('resources')
                        .doc(resource.id)
                        .delete();
                    if (mounted) {
                      AppSnackbar.showSuccess(
                        context: context,
                        message: 'Resource deleted successfully',
                      );
                      setState(() {
                        _selectedResource = null;
                      });
                    }
                  } catch (e) {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                      AppSnackbar.showError(
                        context: context,
                        message: 'Failed to delete resource: $e',
                      );
                    }
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('DELETE'),
              ),
            ],
          ),
    );
  }

  bool _canShowPreview(ResourceItem resource) {
    final type = resource.type.toLowerCase();
    return (type == 'pdf' || type == 'image') && resource.fileUrl != null;
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunitiesTab() {
    final chatController = Provider.of<ChatController>(context);
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: chatController.getUserCommunitiesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: \\${snapshot.error}'));
        }
        final communities = snapshot.data ?? [];
        if (communities.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No communities yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Join a community or create a new one',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          itemCount: communities.length,
          itemBuilder: (context, index) {
            final community = communities[index];
            final isSelected = selectedConversationId == community['id'];
            final communityId = community['id'] as String;
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: chatController.getCommunityMediaMessagesStream(
                communityId,
              ),
              builder: (context, messagesSnapshot) {
                if (messagesSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }
                final mediaMessages = messagesSnapshot.data ?? [];
                if (mediaMessages.isEmpty) {
                  return const SizedBox.shrink();
                }
                return InkWell(
                  onLongPress: () {
                    _showDeleteOptions(communityId, community);
                  },
                  child: Container(
                    color:
                        isSelected
                            ? Colors.grey.withOpacity(0.1)
                            : Colors.transparent,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          (community['name'] as String)
                              .substring(0, 1)
                              .toUpperCase(),
                        ),
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              community['name'] as String,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.insert_drive_file,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                      subtitle: Text('${mediaMessages.length} media resources'),
                      trailing:
                          community['unreadCount'] != null &&
                                  (community['unreadCount'] as int) > 0
                              ? Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${community['unreadCount']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                              : null,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ResourceCommunityChatScreen(
                                  communityId: communityId,
                                  communityName: community['name'] as String,
                                  memberIds:
                                      (community['members'] as List<dynamic>)
                                          .cast<String>(),
                                  imageUrl: community['imageUrl'] as String?,
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
