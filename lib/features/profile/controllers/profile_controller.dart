import 'package:flutter/material.dart';
import '../repositories/profile_repository.dart';

class ProfileController extends ChangeNotifier {
  final ProfileRepository _repository;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _userData;
  String? _profileImageUrl;

  ProfileController({ProfileRepository? repository})
      : _repository = repository ?? ProfileRepository();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userData => _userData;
  String? get profileImageUrl => _profileImageUrl;

  Future<void> loadUserData() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _userData = await _repository.loadUserData();
      _profileImageUrl = await _repository.getProfileImageUrl();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _userData = null;
    _errorMessage = null;
    _profileImageUrl = null;
    super.dispose();
  }
} 