import 'package:flutter/material.dart';
import 'package:acumen/features/resources/models/resource_item.dart';
import 'package:acumen/features/resources/utils/resource_utils.dart';
import 'package:acumen/features/resources/widgets/file_type_icon.dart';
import 'package:acumen/features/resources/widgets/resource_preview_widget.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/utils/app_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ResourceDetailScreen extends StatefulWidget {
  final ResourceItem resource;
  
  const ResourceDetailScreen({
    super.key,
    required this.resource,
  });

  @override
  State<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends State<ResourceDetailScreen> {
  bool _isLoading = false;
  bool _canEdit = false;
  bool _showFullPreview = false;
  
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }
  
  void _checkPermissions() {
    final authController = Provider.of<AuthController>(context, listen: false);
    final currentUser = authController.currentUser;
    final appUser = authController.appUser;
    
    if (currentUser != null && appUser != null) {
      setState(() {
        _canEdit = appUser.role == 'admin' || 
                  (appUser.role == 'mentor' && widget.resource.mentorId == currentUser.uid);
      });
    }
  }

  Future<void> _openResource() async {
    if (widget.resource.fileUrl == null) {
      AppSnackbar.showError(context: context, message: 'No file available for this resource');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(widget.resource.fileUrl!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          AppSnackbar.showError(context: context, message: 'Could not open the file');
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context: context, message: 'Error opening resource: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _shareResource() {
    // Implement share functionality
    AppSnackbar.showInfo(context: context, message: 'Sharing resource: ${widget.resource.title}');
  }
  
  Future<void> _deleteResource() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this resource?'),
        content: Text('Are you sure you want to delete "${widget.resource.title}"? This action cannot be undone.'),
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
                // Delete file from storage if exists
                if (widget.resource.fileUrl != null) {
                  try {
                    await FirebaseStorage.instance.refFromURL(widget.resource.fileUrl!).delete();
                  } catch (e) {
                    // File might not exist, continue with document deletion
                  }
                }
                
                // Delete document from Firestore
                await FirebaseFirestore.instance
                    .collection('resources')
                    .doc(widget.resource.id)
                    .delete();
                
                if (mounted) {
                  AppSnackbar.showSuccess(context: context, message: 'Resource deleted successfully');
                  Navigator.pop(context); // Go back to previous screen
                }
              } catch (e) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                  AppSnackbar.showError(context: context, message: 'Failed to delete resource: $e');
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
  
  bool _canShowPreview() {
    final type = widget.resource.type.toLowerCase();
    return (type == 'pdf' || type == 'image') && widget.resource.fileUrl != null;
  }
  
  @override
  Widget build(BuildContext context) {
    final bool canShowPreview = _canShowPreview();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource Details', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          if (_canEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: _deleteResource,
            ),
        ],
      ),
      body: _isLoading 
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
                            type: widget.resource.type,
                            size: 40,
                          ),
                        ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.resource.resourceType,
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.resource.title,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Preview',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            TextButton.icon(
                              icon: Icon(_showFullPreview ? Icons.fullscreen_exit : Icons.fullscreen),
                              label: Text(_showFullPreview ? 'Minimize' : 'Expand'),
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
                          resource: widget.resource,
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
                        widget.resource.description,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
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
                            _buildInfoRow('File Type', widget.resource.type.toUpperCase()),
                            const Divider(height: 24),
                            _buildInfoRow('Added by', widget.resource.mentorName),
                            const Divider(height: 24),
                            _buildInfoRow(
                              'Date Added', 
                              DateFormat('MMMM dd, yyyy').format(widget.resource.dateAdded),
                            ),
                            if (widget.resource.fileName != null) ...[
                              const Divider(height: 24),
                              _buildInfoRow('File Name', widget.resource.fileName!),
                            ],
                            if (widget.resource.sourceType == 'Chat' && widget.resource.chatName != null) ...[
                              const Divider(height: 24),
                              _buildInfoRow('Source', 'Chat with ${widget.resource.chatName}'),
                            ],
                            if (widget.resource.sourceType == 'Community' && widget.resource.communityName != null) ...[
                              const Divider(height: 24),
                              _buildInfoRow('Source', 'Community "${widget.resource.communityName}"'),
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
                            onPressed: _openResource,
                          ),
                          _buildActionButton(
                            icon: Icons.visibility_outlined,
                            label: 'View',
                            color: AppTheme.primaryColor,
                            onPressed: _openResource,
                          ),
                          _buildActionButton(
                            icon: Icons.share_outlined,
                            label: 'Share',
                            color: Colors.green,
                            onPressed: _shareResource,
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
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
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
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 