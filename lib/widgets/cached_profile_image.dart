import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/services/image_cache_service.dart';
import 'package:shimmer/shimmer.dart';

class CachedProfileImage extends StatefulWidget {
  final String? imageUrl;
  final File? imageFile;
  final double size;
  final double radius;
  final Color placeholderColor;
  final Color backgroundColor;
  final IconData placeholderIcon;
  final double placeholderSize;
  final VoidCallback? onTap;
  final BoxFit fit;

  const CachedProfileImage({
    super.key,
    this.imageUrl,
    this.imageFile,
    this.size = 120.0,
    this.radius = 60.0,
    this.placeholderColor = AppTheme.primaryColor,
    this.backgroundColor = Colors.white,
    this.placeholderIcon = FontAwesomeIcons.user,
    this.placeholderSize = 40.0,
    this.onTap,
    this.fit = BoxFit.cover,
  });

  @override
  State<CachedProfileImage> createState() => _CachedProfileImageState();
}

class _CachedProfileImageState extends State<CachedProfileImage> {
  bool _isLoading = true;
  Uint8List? _imageBytes;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(CachedProfileImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl || oldWidget.imageFile != widget.imageFile) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (widget.imageFile != null) {
      setState(() {
        _isLoading = false;
        _hasError = false;
      });
      return;
    }

    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    // Check if we already have it in the cache (synchronous)
    final cachedImage = ImageCacheService.getCachedImageSync(widget.imageUrl);
    if (cachedImage != null) {
      setState(() {
        _imageBytes = cachedImage;
        _isLoading = false;
        _hasError = false;
      });
      return;
    }

    // Otherwise load from network
    setState(() => _isLoading = true);
    
    try {
      final imageBytes = await ImageCacheService.getImage(widget.imageUrl);
      if (mounted) {
        setState(() {
          _imageBytes = imageBytes;
          _isLoading = false;
          _hasError = imageBytes == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipOval(
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    // If we have a file, show it directly
    if (widget.imageFile != null) {
      return Image.file(
        widget.imageFile!,
        fit: widget.fit,
        width: widget.size,
        height: widget.size,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }

    // If loading, show shimmer
    if (_isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: widget.size,
          height: widget.size,
          color: Colors.white,
        ),
      );
    }

    // If we have cached bytes, show them
    if (_imageBytes != null && !_hasError) {
      return Image.memory(
        _imageBytes!,
        fit: widget.fit,
        width: widget.size,
        height: widget.size,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }

    // If we have a URL but no cached bytes yet, try to load from network
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty && !_hasError) {
      return Image.network(
        widget.imageUrl!,
        fit: widget.fit,
        width: widget.size,
        height: widget.size,
        loadingBuilder: (_, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: widget.size,
              height: widget.size,
              color: Colors.white,
            ),
          );
        },
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }

    // Fallback to placeholder
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.size,
      height: widget.size,
      color: widget.backgroundColor,
      child: Center(
        child: Icon(
          widget.placeholderIcon,
          size: widget.placeholderSize,
          color: widget.placeholderColor,
        ),
      ),
    );
  }
} 