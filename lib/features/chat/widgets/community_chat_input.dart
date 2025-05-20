import 'package:acumen/features/chat/controllers/chat_input_controller.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

class CommunityChatInput extends StatefulWidget {
  final Function({String? text, File? mediaFile, String? mediaType, bool isOptimistic}) onSendMessage;
  final bool isLoading;
  final bool canSendMessages;

  const CommunityChatInput({
    Key? key,
    required this.onSendMessage,
    required this.isLoading,
    required this.canSendMessages,
  }) : super(key: key);

  @override
  State<CommunityChatInput> createState() => _CommunityChatInputState();
}

class _CommunityChatInputState extends State<CommunityChatInput> {
  final TextEditingController _messageController = TextEditingController();
  bool _showMediaOptions = false;
  File? _selectedFile;
  String? _selectedFileType;
  final ImagePicker _imagePicker = ImagePicker();

  // Record audio state
  late AudioRecorder _audioRecorder;
  bool _isRecording = false;
  String? _recordingPath;
  Timer? _recordingTimer;
  int _recordingDuration = 0;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _recordingTimer?.cancel();
    if (_isRecording) {
      _audioRecorder.stop().then((_) {
        _audioRecorder.dispose();
      });
    } else {
      _audioRecorder.dispose();
    }
    super.dispose();
  }

  void _handleSend() {
    final text = _messageController.text.trim();
    
    if (text.isEmpty && _selectedFile == null) return;

    // Send message optimistically (show immediately)
    widget.onSendMessage(
      text: text.isNotEmpty ? text : null,
      mediaFile: _selectedFile,
      mediaType: _selectedFileType,
      isOptimistic: true, // Add this flag to indicate optimistic update
    );
    
    // Clear the input
    _messageController.clear();
    setState(() {
      _selectedFile = null;
      _selectedFileType = null;
    });
  }

  void _toggleMediaOptions() {
    setState(() {
      _showMediaOptions = !_showMediaOptions;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedFile = File(pickedFile.path);
          _selectedFileType = 'image';
          _showMediaOptions = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _pickVideo() async {
    try {
      final pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedFile = File(pickedFile.path);
          _selectedFileType = 'video';
          _showMediaOptions = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking video: $e')),
      );
    }
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'txt'],
      );
      
      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _selectedFileType = result.files.single.extension == 'pdf' ? 'pdf' : 
                             (result.files.single.extension == 'ppt' || result.files.single.extension == 'pptx') ? 'presentation' :
                             'document';
          _showMediaOptions = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking document: $e')),
      );
    }
  }

  Future<void> _recordVoice() async {
    try {
      setState(() {
        _showMediaOptions = false;
      });
      
      // Request permission
      final hasPermission = await _audioRecorder.hasPermission();
      if (hasPermission) {
        // Get temp directory
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/voice_message_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        // Start recording
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: filePath,
        );
        
        setState(() {
          _isRecording = true;
          _recordingPath = filePath;
          _recordingDuration = 0;
        });
        
        // Start timer to track recording duration
        _recordingTimer?.cancel();
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) {
            setState(() {
              _recordingDuration++;
            });
          }
        });
        
        // Show recording UI as a modal bottom sheet with fixed-height layout
        await showModalBottomSheet(
          context: context,
          isDismissible: false,
          enableDrag: false,
          isScrollControlled: true,
          builder: (context) => Material(
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
                            await _stopRecording(false);
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
                            await _stopRecording(true);
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.send, color: Colors.white),
                          label: const Text('Send'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
      await _stopRecording(false);
    }
  }
  
  Future<void> _stopRecording(bool sendMessage) async {
    if (!_isRecording) return;
    
    try {
      _recordingTimer?.cancel();
      _recordingTimer = null;
      
      final path = await _audioRecorder.stop();
      if (mounted) {
        setState(() {
          _isRecording = false;
          _recordingDuration = 0;
        });
        
        if (sendMessage && path != null) {
          final voiceFile = File(path);
          setState(() {
            _selectedFile = voiceFile;
            _selectedFileType = 'voice';
          });
          
          // Send voice message optimistically
          widget.onSendMessage(
            mediaFile: voiceFile,
            mediaType: 'voice',
            isOptimistic: true,
          );
          
          // Clear the selection
          setState(() {
            _selectedFile = null;
            _selectedFileType = null;
          });
        }
      }
    } catch (e) {
      print('Error stopping recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error stopping recording: $e')),
        );
        setState(() {
          _isRecording = false;
          _recordingDuration = 0;
        });
      }
    }
  }

  Widget _buildSelectedFilePreview() {
    if (_selectedFile == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _selectedFileType == 'image'
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_selectedFile!, fit: BoxFit.cover),
                  )
                : Icon(
                    _selectedFileType == 'video'
                        ? Icons.videocam
                        : _selectedFileType == 'pdf'
                            ? Icons.picture_as_pdf
                            : _selectedFileType == 'presentation'
                                ? Icons.slideshow
                                : Icons.insert_drive_file,
                    size: 30,
                    color: AppTheme.primaryColor,
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _selectedFile!.path.split('/').last,
              style: const TextStyle(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              setState(() {
                _selectedFile = null;
                _selectedFileType = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMediaOptions() {
    if (!_showMediaOptions) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildMediaButton(
              icon: Icons.photo,
              label: 'Gallery',
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            _buildMediaButton(
              icon: Icons.camera_alt,
              label: 'Camera',
              onTap: () => _pickImage(ImageSource.camera),
            ),
            _buildMediaButton(
              icon: Icons.videocam,
              label: 'Video',
              onTap: _pickVideo,
            ),
            _buildMediaButton(
              icon: Icons.mic,
              label: 'Voice',
              onTap: _recordVoice,
            ),
            _buildMediaButton(
              icon: Icons.picture_as_pdf,
              label: 'Document',
              onTap: _pickDocument,
            ),
            _buildMediaButton(
              icon: FontAwesomeIcons.link,
              label: 'Link',
              onTap: () {
                _messageController.text += 'https://';
                setState(() {
                  _showMediaOptions = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.canSendMessages) {
      return Container(
        padding: const EdgeInsets.all(12),
        alignment: Alignment.center,
        color: Colors.grey.shade100,
        child: const Text(
          'Only mentors can send messages in this community',
          style: TextStyle(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildSelectedFilePreview(),
        _buildMediaOptions(),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.add_circle_outline,
                  color: AppTheme.primaryColor,
                  size: 26,
                ),
                onPressed: _toggleMediaOptions,
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 5,
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: AppTheme.primaryColor,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: widget.isLoading ? null : _handleSend,
                  customBorder: const CircleBorder(),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 24,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 
 
 