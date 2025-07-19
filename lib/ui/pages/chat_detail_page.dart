import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';
import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/app/configs/theme.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';

class ChatDetailPage extends StatefulWidget {
  final Map<String, dynamic> chat;

  const ChatDetailPage({Key? key, required this.chat}) : super(key: key);

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Image and Video Picker
  final ImagePicker _picker = ImagePicker();

  // Voice recording variables
  FlutterSoundRecorder? _audioRecorder;
  FlutterSoundPlayer? _audioPlayer;
  bool _isRecording = false;
  bool _isRecorderReady = false;
  bool _isPlayerReady = false;
  String? _recordedFilePath;
  bool _isPlaying = false;
  String? _currentlyPlayingPath;
  // Recording timer variables
  Timer? _recordingTimer;
  int _recordingDuration = 0; // in seconds

  // Sample messages data
  List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hi! Nice to meet you 😊',
      'time': '12:15 AM',
      'isMe': false,
    },
    {
      'text': 'Nice to meet you too 😊',
      'time': '12:16 AM',
      'isMe': true,
      'status': 'read',
    },
    {
      'text': 'What is your favorite place?',
      'time': '12:17 AM',
      'isMe': false,
    },
    {
      'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300&h=400&fit=crop',
      'text': 'My Favorite place is mountain 🏔️',
      'time': '12:19 AM',
      'isMe': true,
      'status': 'delivered',
    },
    {
      'text': 'Beautiful view! 😍',
      'time': '12:20 AM',
      'isMe': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAudio();
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _recordingTimer?.cancel();
    _closeAudio();
    super.dispose();
  }
  
  Future<void> _initializeAudio() async {
    _audioRecorder = FlutterSoundRecorder();
    _audioPlayer = FlutterSoundPlayer();
    
    await _audioRecorder!.openRecorder();
    await _audioPlayer!.openPlayer();
    
    setState(() {
      _isRecorderReady = true;
      _isPlayerReady = true;
    });
  }
  
  Future<void> _closeAudio() async {
    if (_audioRecorder != null) {
      await _audioRecorder!.closeRecorder();
    }
    if (_audioPlayer != null) {
      await _audioPlayer!.closePlayer();
    }
  }
  
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }
  
  Future<void> _startRecording() async {
    if (!_isRecorderReady) return;
    
    // Request microphone permission
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Microphone permission is required to record audio')),
      );
      return;
    }
    
    // Create a temporary file path
    final directory = Directory.systemTemp;
    final filePath = '${directory.path}/voice_message_${DateTime.now().millisecondsSinceEpoch}.aac';
    
    await _audioRecorder!.startRecorder(
      toFile: filePath,
      codec: Codec.aacADTS,
    );
    
    // Start the recording timer
    _recordingDuration = 0;
    _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration++;
      });
    });
    
    setState(() {
      _isRecording = true;
      _recordedFilePath = filePath;
    });
  }
  
  Future<void> _stopRecording() async {
    if (!_isRecorderReady || !_isRecording) return;
    
    await _audioRecorder!.stopRecorder();
    
    // Stop the recording timer
    _recordingTimer?.cancel();
    
    setState(() {
      _isRecording = false;
      _recordingDuration = 0;
    });
    
    // Add voice message to chat
    if (_recordedFilePath != null) {
      setState(() {
        _messages.add({
          'voiceMessage': _recordedFilePath,
          'time': _formatCurrentTime(),
          'isMe': true,
          'status': 'sent',
        });
      });
      _scrollToBottom();
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'text': _messageController.text.trim(),
          'time': _formatCurrentTime(),
          'isMe': true,
          'status': 'sent',
        });
      });
      _messageController.clear();
      _scrollToBottom();
    }
  }
  
  Future<void> _pickAndSendImage() async {
    await _pickMedia(ImageSource.gallery, 'image');
  }

  Future<void> _pickAndSendVideo() async {
    await _pickMedia(ImageSource.gallery, 'video');
  }

  Future<void> _pickMedia(ImageSource source, String mediaType) async {
    try {
      final XFile? media;
      if (mediaType == 'image') {
        media = await _picker.pickImage(
          source: source,
          imageQuality: 80,
        );
      } else {
        media = await _picker.pickVideo(
          source: source,
          maxDuration: const Duration(minutes: 2),
        );
      }
      
if (media != null) {
        final path = media.path;
        setState(() {
          _messages.add({
            mediaType: path,
            'time': _formatCurrentTime(),
            'isMe': true,
            'status': 'sent',
          });
        });
        _scrollToBottom();
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image')),
      );
    }
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    String period = now.hour >= 12 ? 'PM' : 'AM';
    int hour = now.hour > 12 ? now.hour - 12 : now.hour;
    hour = hour == 0 ? 12 : hour;
    return '	${hour}:${now.minute.toString().padLeft(2, '0')} $period';
  }
  
  String _formatRecordingTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  Future<void> _toggleVoicePlayback(String voiceMessagePath) async {
    if (!_isPlayerReady) return;
    
    if (_isPlaying && _currentlyPlayingPath == voiceMessagePath) {
      // Stop the current playback
      await _audioPlayer!.stopPlayer();
      setState(() {
        _isPlaying = false;
        _currentlyPlayingPath = null;
      });
    } else {
      // Stop any currently playing audio first
      if (_isPlaying) {
        await _audioPlayer!.stopPlayer();
      }
      
      // Start playing the selected voice message
      try {
        await _audioPlayer!.startPlayer(
          fromURI: voiceMessagePath,
          whenFinished: () {
            setState(() {
              _isPlaying = false;
              _currentlyPlayingPath = null;
            });
          },
        );
        
        setState(() {
          _isPlaying = true;
          _currentlyPlayingPath = voiceMessagePath;
        });
      } catch (e) {
        print('Error playing voice message: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing voice message')),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.blackTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(widget.chat['profileImage']),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chat['name'],
                    style: TextStyle(
                      color: AppColors.blackTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    '3 km from you',
                    style: TextStyle(
                      color: AppColors.greyTextColor,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call, color: AppColors.blackTextColor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.videocam, color: AppColors.blackTextColor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: AppColors.blackTextColor),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Date separator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Today',
              style: TextStyle(
                color: AppColors.greyTextColor,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['isMe'] ?? false;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(widget.chat['profileImage']),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Handle image and text as separate elements
                Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    // Image container (if image exists)
                    if (message['image'] != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            message['image'],
                            width: 200,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    // Text container (if text exists)
                    if (message['text'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.primaryColor : const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          message['text'],
                          style: TextStyle(
                            color: isMe ? Colors.white : AppColors.blackTextColor,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    // Voice message container (if voice message exists)
                    if (message['voiceMessage'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.primaryColor : const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => _toggleVoicePlayback(message['voiceMessage']),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isMe ? Colors.white.withOpacity(0.2) : AppColors.primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  (_isPlaying && _currentlyPlayingPath == message['voiceMessage']) 
                                    ? Icons.pause 
                                    : Icons.play_arrow,
                                  color: isMe ? Colors.white : AppColors.primaryColor,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.keyboard_voice,
                              color: isMe ? Colors.white.withOpacity(0.7) : AppColors.greyTextColor,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Voice message',
                              style: TextStyle(
                                color: isMe ? Colors.white.withOpacity(0.9) : AppColors.blackTextColor,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message['time'],
                      style: TextStyle(
                        color: AppColors.greyTextColor,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    if (isMe && message['status'] != null) ...[
                      const SizedBox(width: 4),
                      _buildStatusIcon(message['status']),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(widget.chat['profileImage']), // You can replace this with current user's image
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReelPreview(Map<String, dynamic> message) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Background image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              message['image'],
              width: 250,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          // Gradient overlay
          Container(
            width: 250,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          // Bottom content
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username
                Text(
                  message['username'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                // Description text
                if (message['text'] != null)
                  Text(
                    message['text'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                // Engagement stats
                Row(
                  children: [
                    _buildStatItem(Icons.favorite, message['likes'] ?? 0),
                    const SizedBox(width: 16),
                    _buildStatItem(Icons.chat_bubble, message['comments'] ?? 0),
                    const SizedBox(width: 16),
                    _buildStatItem(Icons.share, message['shares'] ?? 0),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, int count) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          _formatCount(count),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1).replaceAll('.0', '')}k';
    }
    return count.toString();
  }

  Widget _buildStatusIcon(String status) {
    IconData iconData;
    Color iconColor;
    
    switch (status.toLowerCase()) {
      case 'sent':
        iconData = Icons.check;
        iconColor = AppColors.greyTextColor;
        break;
      case 'delivered':
        iconData = Icons.done_all;
        iconColor = AppColors.greyTextColor;
        break;
      case 'read':
        iconData = Icons.done_all;
        iconColor = AppColors.primaryColor;
        break;
      default:
        iconData = Icons.check;
        iconColor = AppColors.greyTextColor;
    }
    
    return Icon(
      iconData,
      size: 14,
      color: iconColor,
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(
                        color: AppColors.blackTextColor,
                        fontFamily: 'Poppins',
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(
                          color: AppColors.greyTextColor,
                          fontFamily: 'Poppins',
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  // Recording timer display
                  if (_isRecording) ...
                    [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatRecordingTime(_recordingDuration),
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  IconButton(
                    icon: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: _isRecording ? Colors.red : AppColors.greyTextColor,
                    ),
                    onPressed: _isRecorderReady ? _toggleRecording : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Video picker button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.greyTextColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.image, color: Colors.white),
  onPressed: _pickAndSendVideo,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
