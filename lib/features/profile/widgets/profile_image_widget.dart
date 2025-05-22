import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:acumen/theme/app_colors.dart';
import 'package:acumen/widgets/cached_profile_image.dart';
import '../screens/profile_image_viewer_screen.dart';

class ProfileImageWidget extends StatelessWidget {
  final double topPosition;
  final VoidCallback? onCameraTap;
  final String? imageUrl;
  final File? imageFile;
  final bool showCameraIcon;

  const ProfileImageWidget({
    super.key,
    required this.topPosition,
    this.onCameraTap,
    this.imageUrl,
    this.imageFile,
    this.showCameraIcon = false,
  });

  void _handleImageTap(BuildContext context) {
    if (imageUrl != null || imageFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileImageViewerScreen(
            imageUrl: imageUrl ?? '',
            imageFile: imageFile,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Center(
        child: showCameraIcon && onCameraTap != null
            ? Stack(
          clipBehavior: Clip.none,
          children: [
            CachedProfileImage(
              imageUrl: imageUrl,
              imageFile: imageFile,
              size: 120,
              onTap: () => _handleImageTap(context),
            ),
            Positioned(
              right: -10,
              bottom: -10,
              child: GestureDetector(
                onTap: onCameraTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    FontAwesomeIcons.camera,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
              )
            : CachedProfileImage(
                imageUrl: imageUrl,
                imageFile: imageFile,
                size: 120,
                onTap: () => _handleImageTap(context),
        ),
      ),
    );
  }
} 