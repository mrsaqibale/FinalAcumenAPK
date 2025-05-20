import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:provider/provider.dart';

class ChatInputController extends ChangeNotifier {
  final TextEditingController messageController = TextEditingController();
  final ImagePicker imagePicker = ImagePicker();
  late final AudioRecorder audioRecorder;
  
  bool _showMediaOptions = false;
  bool _isRecording = false;
  bool _isLoading = false;
  File? _selectedFile;
  String? _selectedFileType;
  String? _recordingPath;
  Timer? _recordingTimer;
  int _recordingDuration = 0;

  bool get showMediaOptions => _showMediaOptions;
  bool get isRecording => _isRecording;
  bool get isLoading => _isLoading;
  File? get selectedFile => _selectedFile;
  String? get selectedFileType => _selectedFileType;
  int get recordingDuration => _recordingDuration;

  ChatInputController() {
    audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    messageController.dispose();
    _recordingTimer?.cancel();
    if (_isRecording) {
      audioRecorder.stop().then((_) {
        audioRecorder.dispose();
      });
    } else {
      audioRecorder.dispose();
    }
    super.dispose();
  }

  void toggleMediaOptions() {
    _showMediaOptions = !_showMediaOptions;
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source, BuildContext context) async {
    try {
      final pickedFile = await imagePicker.pickImage(
        source: source,
        imageQuality: 70,
      );
      
      if (pickedFile != null) {
        _selectedFile = File(pickedFile.path);
        _selectedFileType = 'image';
        _showMediaOptions = false;
        notifyListeners();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> pickVideo(BuildContext context) async {
    try {
      final pickedFile = await imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      
      if (pickedFile != null) {
        _selectedFile = File(pickedFile.path);
        _selectedFileType = 'video';
        _showMediaOptions = false;
        notifyListeners();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking video: $e')),
      );
    }
  }

  Future<void> pickDocument(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'txt'],
      );
      
      if (result != null) {
        _selectedFile = File(result.files.single.path!);
        _selectedFileType = result.files.single.extension == 'pdf' ? 'pdf' : 
                           (result.files.single.extension == 'ppt' || result.files.single.extension == 'pptx') ? 'presentation' :
                           'document';
        _showMediaOptions = false;
        notifyListeners();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking document: $e')),
      );
    }
  }

  Future<void> recordVoice(BuildContext context, Function({String? text, File? mediaFile, String? mediaType, bool isOptimistic}) onSendMessage) async {
    try {
      _showMediaOptions = false;
      notifyListeners();
      
      // Request permission
      final hasPermission = await audioRecorder.hasPermission();
      if (hasPermission) {
        // Get temp directory
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/voice_message_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        // Start recording
        await audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: filePath,
        );
        
        _isRecording = true;
        _recordingPath = filePath;
        _recordingDuration = 0;
        notifyListeners();
        
        // Start timer to track recording duration
        _recordingTimer?.cancel();
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          _recordingDuration++;
          notifyListeners();
        });
        
        // Show recording UI as a modal bottom sheet
        await showModalBottomSheet(
          context: context,
          isDismissible: false,
          enableDrag: false,
          isScrollControlled: true,
          builder: (context) => _buildRecordingModal(context, onSendMessage),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission denied')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error recording audio: $e')),
      );
      await stopRecording(false);
    }
  }

  Future<void> stopRecording(bool sendMessage, {Function({String? text, File? mediaFile, String? mediaType, bool isOptimistic})? onSendMessage}) async {
    if (!_isRecording) return;
    
    try {
      _recordingTimer?.cancel();
      _recordingTimer = null;
      
      final path = await audioRecorder.stop();
      _isRecording = false;
      _recordingDuration = 0;
      notifyListeners();
      
      if (sendMessage && path != null && onSendMessage != null) {
        final voiceFile = File(path);
        _selectedFile = voiceFile;
        _selectedFileType = 'voice';
        notifyListeners();
        
        // Send voice message optimistically
        onSendMessage(
          mediaFile: voiceFile,
          mediaType: 'voice',
          isOptimistic: true,
        );
        
        // Clear the selection
        _selectedFile = null;
        _selectedFileType = null;
        notifyListeners();
      }
    } catch (e) {
      print('Error stopping recording: $e');
      _isRecording = false;
      _recordingDuration = 0;
      notifyListeners();
    }
  }

  void clearSelection() {
    _selectedFile = null;
    _selectedFileType = null;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Widget _buildRecordingModal(BuildContext context, Function({String? text, File? mediaFile, String? mediaType, bool isOptimistic}) onSendMessage) {
    return Material(
      child: Container(
        height: 200,
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).padding.bottom + 20,
        ),
        child: Column(
          children: [
            Text(
              'Recording Voice Message',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: StreamBuilder<int>(
                stream: Stream.periodic(const Duration(seconds: 1), (i) => i + 1)
                    .takeWhile((_) => _isRecording),
                initialData: 0,
                builder: (context, snapshot) {
                  final duration = snapshot.data ?? 0;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '${(duration ~/ 60).toString().padLeft(2, '0')}:${(duration % 60).toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(width: 10),
                      Text('Recording...', style: TextStyle(color: Colors.grey)),
                    ],
                  );
                },
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 120,
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await stopRecording(false);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.red,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  width: 120,
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await stopRecording(true, onSendMessage: onSendMessage);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: const Text('Send'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 