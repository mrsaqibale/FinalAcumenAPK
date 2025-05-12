import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

class ImageCacheService {
  static const String _boxName = 'image_cache';
  static Box<String>? _box;
  
  // Initialize Hive and open the box
  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }
  
  // Check if image exists in cache (synchronous)
  static bool hasImageInCache(String? url) {
    if (url == null || url.isEmpty || _box == null) return false;
    return _box!.containsKey(url);
  }
  
  // Get cached image synchronously (without network fetch)
  static Uint8List? getCachedImageSync(String? url) {
    if (url == null || url.isEmpty || _box == null) return null;
    
    final cachedData = _box!.get(url);
    if (cachedData != null) {
      try {
        return base64Decode(cachedData);
      } catch (e) {
        debugPrint('Error decoding cached image: $e');
      }
    }
    
    return null;
  }
  
  // Get image from cache or network
  static Future<Uint8List?> getImage(String? url) async {
    if (url == null || url.isEmpty) return null;
    
    // Try to get from cache first
    final cachedImage = await _getCachedImage(url);
    if (cachedImage != null) {
      return cachedImage;
    }
    
    // If not in cache, fetch from network and cache it
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final imageBytes = response.bodyBytes;
        await _cacheImage(url, imageBytes);
        return imageBytes;
      }
    } catch (e) {
      debugPrint('Error fetching image: $e');
    }
    
    return null;
  }
  
  // Get image from cache
  static Future<Uint8List?> _getCachedImage(String url) async {
    if (_box == null) return null;
    
    final cachedData = _box!.get(url);
    if (cachedData != null) {
      try {
        return base64Decode(cachedData);
      } catch (e) {
        debugPrint('Error decoding cached image: $e');
      }
    }
    
    return null;
  }
  
  // Cache image
  static Future<void> _cacheImage(String url, Uint8List imageBytes) async {
    if (_box == null) return;
    
    try {
      final base64Image = base64Encode(imageBytes);
      await _box!.put(url, base64Image);
    } catch (e) {
      debugPrint('Error caching image: $e');
    }
  }
  
  // Clear cache
  static Future<void> clearCache() async {
    if (_box == null) return;
    await _box!.clear();
  }
  
  // Clear specific image from cache
  static Future<void> removeFromCache(String url) async {
    if (_box == null) return;
    await _box!.delete(url);
  }
} 