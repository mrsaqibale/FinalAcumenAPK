import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';

/// WhatsApp-style message components for various types of content
class MessageComponents {
  // Media Download Widget (Images, Videos, Documents)
  static Widget mediaDownloadWidget({
    required BuildContext context,
    required String url,
    required String contentType,
    required bool isCurrentUser,
    required VoidCallback onTap,
    String? fileName,
    bool isDownloaded = false,
    bool isDownloading = false,
    double? downloadProgress,
  }) {
    final Color textColor = isCurrentUser ? Colors.white : Colors.black87;
    final Color iconColor = isCurrentUser ? Colors.white : AppTheme.primaryColor;
    
    // Icon based on content type
    IconData contentIcon = contentType == 'image' 
        ? Icons.image
        : contentType == 'video'
            ? Icons.videocam
            : contentType == 'pdf'
                ? Icons.picture_as_pdf
                : contentType == 'presentation'
                    ? Icons.slideshow
                    : Icons.insert_drive_file;
    
    // For images and videos
    if (contentType == 'image' || contentType == 'video') {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.black.withOpacity(0.1),
          ),
          constraints: BoxConstraints(
            maxHeight: 200,
            maxWidth: MediaQuery.of(context).size.width * 0.65,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Image/Video Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: contentType == 'image'
                  ? CachedNetworkImage(
                      imageUrl: url,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade300,
                        child: Center(
                          child: isDownloading 
                              ? _buildProgressIndicator(downloadProgress ?? 0)
                              : const Icon(Icons.image, color: Colors.white),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.error, color: Colors.white),
                      ),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : Container(
                      color: Colors.black,
                      width: double.infinity,
                      child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 50)),
                    ),
              ),
              
              // Download overlay (if not downloaded)
              if (!isDownloaded && !isDownloading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.download,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              
              // Progress indicator (if downloading)
              if (isDownloading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: _buildProgressIndicator(downloadProgress ?? 0),
                    ),
                  ),
                ),
                
              // Content type indicator
              if (contentType == 'video')
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.videocam, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text('Video', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    
    // For documents and other file types
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.white.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCurrentUser ? Colors.white.withOpacity(0.3) : Colors.grey.shade300,
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.65,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Document icon
            Icon(contentIcon, color: iconColor, size: 30),
            const SizedBox(width: 12),
            
            // File details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName ?? contentType.toUpperCase(),
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Download status
                  if (isDownloading)
                    LinearProgressIndicator(
                      value: downloadProgress,
                      backgroundColor: isCurrentUser 
                          ? Colors.white.withOpacity(0.3) 
                          : Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCurrentUser ? Colors.white : AppTheme.primaryColor,
                      ),
                    )
                  else
                    Text(
                      isDownloaded ? 'Tap to open' : 'Tap to download',
                      style: TextStyle(
                        color: isCurrentUser 
                            ? Colors.white.withOpacity(0.7) 
                            : Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            
            // Download icon
            if (!isDownloaded && !isDownloading)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.download,
                  color: iconColor,
                  size: 24,
                ),
              )
            else if (isDownloaded)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.check_circle,
                  color: iconColor,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // Voice Message Player Widget
  static Widget voiceMessageWidget({
    required BuildContext context,
    required String url,
    required bool isCurrentUser,
    required bool isPlaying,
    required double playbackProgress,
    required Duration duration,
    required VoidCallback onPlayPause,
    required bool isDownloaded,
    required bool isDownloading,
    double? downloadProgress,
  }) {
    final Color bgColor = isCurrentUser ? AppTheme.primaryColor : Colors.grey.shade200;
    
    final minutes = (duration.inSeconds / 60).floor();
    final seconds = duration.inSeconds % 60;
    final durationText = '$minutes:${seconds.toString().padLeft(2, '0')}';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.65,
        minHeight: 60,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Download button
          if (isDownloading)
            SizedBox(
              width: 32,
              height: 32,
              child: _buildProgressIndicator(downloadProgress ?? 0),
            )
          else if (!isDownloaded)
            GestureDetector(
              onTap: onPlayPause, // Will trigger download
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrentUser ? Colors.white : AppTheme.primaryColor,
                ),
                child: Icon(
                  Icons.download,
                  color: isCurrentUser ? AppTheme.primaryColor : Colors.white,
                  size: 18,
                ),
              ),
            )
          else
            GestureDetector(
              onTap: onPlayPause,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrentUser ? Colors.white : AppTheme.primaryColor,
                ),
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: isCurrentUser ? AppTheme.primaryColor : Colors.white,
                  size: 18,
                ),
              ),
            ),
            
          const SizedBox(width: 12),
          
          // Waveform/progress
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 24,
                    child: isDownloaded
                        ? _buildWaveform(context, playbackProgress, isCurrentUser)
                        : Center(
                            child: LinearProgressIndicator(
                              value: isDownloading ? downloadProgress : null,
                              backgroundColor: isCurrentUser 
                                  ? Colors.white.withOpacity(0.3) 
                                  : Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isCurrentUser ? Colors.white : AppTheme.primaryColor,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 4),
                
                // Duration text
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    isDownloaded ? durationText : 'Tap to download',
                    style: TextStyle(
                      fontSize: 12,
                      color: isCurrentUser 
                          ? Colors.white.withOpacity(0.7) 
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Message Selection Widget
  static Widget selectionOverlay({
    required bool isSelected,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onLongPress: onTap,
      child: Stack(
        children: [
          child,
          if (isSelected)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  // Message Options Menu
  static void showMessageOptions({
    required BuildContext context,
    required Map<String, dynamic> message,
    required bool isCurrentUser,
    required Function(String action) onAction,
  }) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          Offset.zero,
          overlay.size.bottomRight(Offset.zero),
        ),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'reply',
          child: Row(
            children: [
              Icon(Icons.reply, color: Colors.blue),
              SizedBox(width: 8),
              Text('Reply'),
            ],
          ),
        ),
        if (isCurrentUser) ...[
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, color: Colors.orange),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete'),
              ],
            ),
          ),
        ],
        PopupMenuItem(
          value: 'copy',
          child: Row(
            children: [
              Icon(Icons.content_copy, color: Colors.grey),
              SizedBox(width: 8),
              Text('Copy'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'forward',
          child: Row(
            children: [
              Icon(Icons.forward, color: Colors.green),
              SizedBox(width: 8),
              Text('Forward'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        onAction(value);
      }
    });
  }
  
  // Copy message to clipboard
  static void copyMessageToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }
  
  // Helper method to create circular progress indicator
  static Widget _buildProgressIndicator(double value) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            value: value,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            backgroundColor: Colors.white.withOpacity(0.3),
            strokeWidth: 3,
          ),
        ),
        Text(
          '${(value * 100).round()}%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  // Helper method to create a waveform-like visualization
  static Widget _buildWaveform(BuildContext context, double progress, bool isCurrentUser) {
    final int totalBars = 20;
    final Color activeColor = isCurrentUser ? Colors.white : AppTheme.primaryColor;
    final Color inactiveColor = isCurrentUser 
        ? Colors.white.withOpacity(0.3) 
        : Colors.grey.shade300;
    
    // Create a more structured waveform pattern
    final List<double> barHeights = [
      0.4, 0.5, 0.7, 0.6, 0.5, 
      0.6, 0.8, 0.6, 0.5, 0.7,
      0.5, 0.6, 0.8, 0.7, 0.5,
      0.6, 0.5, 0.4, 0.6, 0.5
    ];
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Row(
        children: List.generate(totalBars, (index) {
          final isActive = index <= progress * totalBars;
          
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Container(
                height: barHeights[index] * 24,
                decoration: BoxDecoration(
                  color: isActive ? activeColor : inactiveColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
} 