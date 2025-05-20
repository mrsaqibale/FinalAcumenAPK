import 'dart:io';
import 'package:flutter/material.dart';
import 'package:acumen/features/chat/models/chat_message_model.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/utils/app_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:cross_file/cross_file.dart';

class ChatMessageItem extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;
  final bool isTempMessage;
  final double? uploadProgress;
  final bool? isUploadComplete;

  const ChatMessageItem({
    super.key,
    required this.message,
    required this.isMine,
    this.isTempMessage = false,
    this.uploadProgress,
    this.isUploadComplete,
  });

  @override
  Widget build(BuildContext context) {
    if ((message.fileType == null || message.fileType == 'text') && !isTempMessage) {
      return _buildTextMessage();
    }

    if (isTempMessage) {
      return _buildTempMessage(context);
    }

    return _buildFileMessage(context);
  }

  Widget _buildTextMessage() {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMine ? AppTheme.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isMine ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 10,
                color: isMine ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTempMessage(BuildContext context) {
    final progress = uploadProgress ?? 0.0;
    final isComplete = isUploadComplete ?? false;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.fileType == 'image')
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(message.fileUrl ?? ''),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 50, color: Colors.white54),
                      ),
                    ),
                  ),
                  CircularProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white54,
                    color: AppTheme.primaryColor,
                    strokeWidth: 5,
                  ),
                  if (isComplete)
                    const Icon(Icons.check_circle, color: Colors.green, size: 40)
                ],
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      message.fileType == 'pdf' ? Icons.picture_as_pdf :
                      message.fileType == 'video' ? Icons.video_library :
                      message.fileType == 'audio' ? Icons.audio_file :
                      message.fileType == 'zip' ? Icons.folder_zip :
                      Icons.insert_drive_file,
                      color: Colors.grey[700],
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 120,
                      child: Text(
                        message.fileName ?? 'File',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: isComplete
                          ? const Icon(Icons.check_circle, color: Colors.green, size: 24)
                          : CircularProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[300],
                              color: AppTheme.primaryColor,
                              strokeWidth: 2,
                            ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 4),
            Text(
              'Uploading... ${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileMessage(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isMine ? AppTheme.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.fileType == 'image')
              _buildImageMessage(context)
            else if (message.fileType == 'audio')
              _buildAudioMessage(context)
            else if (message.fileType == 'video')
              _buildVideoMessage(context)
            else
              _buildDocumentMessage(context),
            const SizedBox(height: 4),
            if (message.text.isNotEmpty && message.text != 'Voice message' && !message.text.contains('Sent a file'))
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: isMine ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isMine ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  if (isMine) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.isRead ? Icons.done_all : Icons.done,
                      size: 12,
                      color: message.isRead ? Colors.white : Colors.white70,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageMessage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: GestureDetector(
        onTap: () {
          if (message.fileUrl == null) return;
          
          _openImageViewer(context);
        },
        child: Hero(
          tag: message.id,
          child: CachedNetworkImage(
            imageUrl: message.fileUrl!,
            width: 200,
            height: 150,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 200,
              height: 150,
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              width: 200,
              height: 150,
              color: Colors.grey[300],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    'Image not available',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  TextButton(
                    onPressed: () {
                      if (message.fileUrl != null) {
                        try {
                          launchUrl(Uri.parse(message.fileUrl!));
                        } catch (e) {
                          AppSnackbar.showError(
                            context: context, 
                            message: 'Could not open image: $e'
                          );
                        }
                      }
                    },
                    child: const Text('Try opening in browser'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openImageViewer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenImageViewer(
          imageUrl: message.fileUrl!,
          messageId: message.id,
          fileName: message.fileName ?? 'image.jpg',
        ),
      ),
    );
  }

  Widget _buildAudioMessage(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (message.fileUrl != null) {
          try {
            final url = Uri.parse(message.fileUrl!);
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            } else {
              AppSnackbar.showError(context: context, message: 'Cannot open file');
            }
          } catch (e) {
            AppSnackbar.showError(context: context, message: 'Error opening file: $e');
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMine ? Colors.white24 : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_circle_fill,
              color: isMine ? Colors.white : AppTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Voice Message',
              style: TextStyle(
                color: isMine ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoMessage(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (message.fileUrl != null) {
          try {
            final url = Uri.parse(message.fileUrl!);
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            } else {
              AppSnackbar.showError(context: context, message: 'Cannot open video');
            }
          } catch (e) {
            AppSnackbar.showError(context: context, message: 'Error opening video: $e');
          }
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 200,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: const Center(
                child: Icon(Icons.video_library, color: Colors.white54, size: 40),
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentMessage(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (message.fileUrl != null) {
          try {
            final url = Uri.parse(message.fileUrl!);
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            } else {
              AppSnackbar.showError(context: context, message: 'Cannot open file');
            }
          } catch (e) {
            AppSnackbar.showError(context: context, message: 'Error opening file: $e');
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMine ? Colors.white24 : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              message.fileType == 'pdf' ? Icons.picture_as_pdf :
              message.fileType == 'zip' ? Icons.folder_zip :
              Icons.insert_drive_file,
              color: isMine ? Colors.white : AppTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 120,
              child: Text(
                message.fileName ?? 'File',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isMine ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;
  final String messageId;
  final String fileName;

  const _FullScreenImageViewer({
    required this.imageUrl,
    required this.messageId,
    required this.fileName,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: _isLoading ? null : () => _downloadImage(context),
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _isLoading ? null : () => _shareImage(context),
          ),
          IconButton(
            icon: const Icon(Icons.forward, color: Colors.white),
            onPressed: _isLoading ? null : () => _forwardImage(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4,
              child: Hero(
                tag: widget.messageId,
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.broken_image, size: 80, color: Colors.white70),
                        const SizedBox(height: 16),
                        const Text(
                          'Failed to load high-resolution image',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            launchUrl(Uri.parse(widget.imageUrl));
                          },
                          child: const Text('Open in Browser'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _downloadImage(BuildContext context) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Download the image
      final response = await http.get(Uri.parse(widget.imageUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image');
      }
      
      // Get temporary directory to save the file
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/${widget.fileName}';
      
      // Write the file
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      
      // Share the image instead of saving to gallery
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Check out this image!',
      );
      
      setState(() {
        _isLoading = false;
      });
      
      if (!context.mounted) return;
      AppSnackbar.showSuccess(
        context: context,
        message: 'Image shared successfully',
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (!context.mounted) return;
      AppSnackbar.showError(
        context: context,
        message: 'Failed to share image: $e',
      );
    }
  }

  Future<void> _shareImage(BuildContext context) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Download the image first
      final response = await http.get(Uri.parse(widget.imageUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image for sharing');
      }
      
      // Get temporary directory to save the file
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/${widget.fileName}';
      
      // Write the file
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      
      // Share the image
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Check out this image!',
      );
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (!context.mounted) return;
      AppSnackbar.showError(
        context: context,
        message: 'Failed to share image: $e',
      );
    }
  }

  void _forwardImage(BuildContext context) {
    // This would be implemented to forward the image to another chat
    // You'll need to add the forward functionality based on your app's architecture
    AppSnackbar.showInfo(
      context: context,
      message: 'Forward functionality to be implemented',
    );
    
    // Example of what this might look like:
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (_) => ForwardMessageScreen(
    //       messageType: 'image',
    //       messageContent: widget.imageUrl,
    //       fileName: widget.fileName,
    //     ),
    //   ),
    // );
  }
} 