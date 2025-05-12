import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:acumen/theme/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileImageViewerScreen extends StatelessWidget {
  final String imageUrl;
  final File? imageFile;

  const ProfileImageViewerScreen({
    super.key,
    required this.imageUrl,
    this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: PhotoView(
          imageProvider: imageFile != null 
              ? FileImage(imageFile!) 
              : NetworkImage(imageUrl) as ImageProvider,
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          loadingBuilder: (context, event) => const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(
              FontAwesomeIcons.user,
              size: 100,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
} 