import 'package:flutter/material.dart';
import 'package:acumen/features/resources/models/resource_item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ResourcePreviewWidget extends StatefulWidget {
  final ResourceItem resource;
  final double height;
  final bool showControls;

  const ResourcePreviewWidget({
    super.key,
    required this.resource,
    required this.height,
    this.showControls = false,
  });

  @override
  State<ResourcePreviewWidget> createState() => _ResourcePreviewWidgetState();
}

class _ResourcePreviewWidgetState extends State<ResourcePreviewWidget> {
  bool _isLoading = false;
  String? _localPdfPath;

  @override
  void initState() {
    super.initState();
    if (widget.resource.type.toLowerCase() == 'pdf' && widget.resource.fileUrl != null) {
      _loadPdf();
    }
  }

  Future<void> _loadPdf() async {
    if (widget.resource.fileUrl == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(widget.resource.fileUrl!));
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/${widget.resource.fileName ?? 'document.pdf'}');
        await file.writeAsBytes(response.bodyBytes);
        
        if (mounted) {
          setState(() {
            _localPdfPath = file.path;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load PDF');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.resource.fileUrl == null) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text('No preview available'),
        ),
      );
    }

    if (_isLoading) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (widget.resource.type.toLowerCase() == 'pdf') {
      if (_localPdfPath == null) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text('Failed to load PDF'),
          ),
        );
      }

      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: PDFView(
            filePath: _localPdfPath!,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            pageSnap: true,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
            onError: (error) {
              debugPrint('Error loading PDF: $error');
            },
          ),
        ),
      );
    }

    if (widget.resource.type.toLowerCase() == 'image') {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: widget.resource.fileUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text('Preview not available for this file type'),
      ),
    );
  }
} 