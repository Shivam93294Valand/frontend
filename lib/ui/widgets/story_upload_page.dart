import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/data/story_model.dart';
import 'package:social_media_app/ui/bloc/story_cubit.dart';
import 'package:video_player/video_player.dart';

class StoryUploadPage extends StatefulWidget {
  const StoryUploadPage({Key? key}) : super(key: key);

  @override
  State<StoryUploadPage> createState() => _StoryUploadPageState();
}

class _StoryUploadPageState extends State<StoryUploadPage> {
  File? _mediaFile;
  StoryType _storyType = StoryType.text;
  String _textContent = '';
  String _backgroundColor = '#FF6B6B';
  List<String> _hashtags = [];
  List<StoryAnnotation> _annotations = [];
  VideoPlayerController? _videoController;
  
  final TextEditingController _textController = TextEditingController();
  final picker = ImagePicker();
  bool _isDrawingMode = false;
  bool _isTextMode = false;
  bool _isStickerMode = false;
  
  final List<String> _backgroundColors = [
    '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7',
    '#DDA0DD', '#98D8C8', '#F7DC6F', '#BB8FCE', '#85C1E9'
  ];
  
  final List<String> _stickers = ['😀', '😍', '🔥', '💯', '👍', '❤️', '🎉', '✨', '🌟', '💪'];

  @override
  void dispose() {
    _videoController?.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(ImageSource source, {bool isVideo = false}) async {
    final pickedFile = await (isVideo
        ? picker.pickVideo(source: source, maxDuration: const Duration(seconds: 30))
        : picker.pickImage(source: source));
    
    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
        _storyType = isVideo ? StoryType.video : StoryType.image;
      });
      
      if (isVideo) {
        _initializeVideoPlayer();
      }
    }
  }

  void _initializeVideoPlayer() async {
    if (_mediaFile != null && _storyType == StoryType.video) {
      _videoController = VideoPlayerController.file(_mediaFile!)
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  void _addTextAnnotation(String text, Offset position) {
    final annotation = StoryAnnotation(
      id: 'text_${DateTime.now().millisecondsSinceEpoch}',
      type: 'text',
      x: position.dx / MediaQuery.of(context).size.width,
      y: position.dy / MediaQuery.of(context).size.height,
      content: text,
      style: {
        'color': '#FFFFFF',
        'fontSize': 18.0,
        'fontWeight': 'bold',
      },
    );
    
    setState(() {
      _annotations.add(annotation);
    });
  }

  void _addStickerAnnotation(String sticker, Offset position) {
    final annotation = StoryAnnotation(
      id: 'sticker_${DateTime.now().millisecondsSinceEpoch}',
      type: 'sticker',
      x: position.dx / MediaQuery.of(context).size.width,
      y: position.dy / MediaQuery.of(context).size.height,
      content: sticker,
      style: {'size': 30.0},
    );
    
    setState(() {
      _annotations.add(annotation);
    });
  }

  List<String> _extractHashtags(String text) {
    final regex = RegExp(r'#\w+');
    return regex.allMatches(text).map((match) => match.group(0)!).toList();
  }

  void _submitStory() {
    final hashtags = _extractHashtags(_textContent);
    
    final story = StoryModel(
      id: 'story_${DateTime.now().millisecondsSinceEpoch}',
      username: 'You',
      userProfileImage: 'assets/images/img_profile.jpeg',
      type: _storyType,
      mediaUrl: _mediaFile?.path,
      textContent: _textContent.isNotEmpty ? _textContent : null,
      backgroundColor: _storyType == StoryType.text ? _backgroundColor : null,
      hashtags: hashtags,
      annotations: _annotations,
      createdAt: DateTime.now(),
      videoDuration: _videoController?.value.duration,
    );

    context.read<StoryCubit>().addStory(story);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Create Story', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: (_mediaFile != null || _textContent.isNotEmpty) ? _submitStory : null,
            child: Text(
              'Share',
              style: TextStyle(
                color: (_mediaFile != null || _textContent.isNotEmpty) 
                    ? Colors.blue 
                    : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTapUp: (details) {
                if (_isTextMode) {
                  _showTextDialog(details.localPosition);
                } else if (_isStickerMode) {
                  _showStickerPicker(details.localPosition);
                }
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _storyType == StoryType.text 
                      ? Color(int.parse(_backgroundColor.substring(1), radix: 16) + 0xFF000000)
                      : Colors.black,
                ),
                child: Stack(
                  children: [
                    // Media content
                    if (_storyType == StoryType.image && _mediaFile != null)
                      Center(child: Image.file(_mediaFile!, fit: BoxFit.contain)),
                    if (_storyType == StoryType.video && _videoController != null && _videoController!.value.isInitialized)
                      Center(child: AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      )),
                    if (_storyType == StoryType.text)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            _textContent.isNotEmpty ? _textContent : 'Tap to add text',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    
                    // Annotations overlay
                    ..._annotations.map((annotation) => Positioned(
                      left: annotation.x * MediaQuery.of(context).size.width,
                      top: annotation.y * MediaQuery.of(context).size.height,
                      child: GestureDetector(
                        onTap: () => _removeAnnotation(annotation.id),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: annotation.type == 'text'
                              ? Text(
                                  annotation.content,
                                  style: TextStyle(
                                    color: Color(int.parse(annotation.style?['color']?.substring(1) ?? 'FFFFFF', radix: 16) + 0xFF000000),
                                    fontSize: annotation.style?['fontSize'] ?? 18.0,
                                    fontWeight: annotation.style?['fontWeight'] == 'bold' ? FontWeight.bold : FontWeight.normal,
                                  ),
                                )
                              : Text(
                                  annotation.content,
                                  style: TextStyle(fontSize: annotation.style?['size'] ?? 30.0),
                                ),
                        ),
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Text input
                if (_storyType == StoryType.text || _mediaFile != null)
                  TextField(
                    controller: _textController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Add text, hashtags, emojis...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _textContent = value;
                      });
                    },
                  ),
                
                const SizedBox(height: 16),
                
                // Background colors (for text stories)
                if (_storyType == StoryType.text)
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _backgroundColors.length,
                      itemBuilder: (context, index) {
                        final color = _backgroundColors[index];
                        return GestureDetector(
                          onTap: () => setState(() => _backgroundColor = color),
                          child: Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Color(int.parse(color.substring(1), radix: 16) + 0xFF000000),
                              shape: BoxShape.circle,
                              border: _backgroundColor == color
                                  ? Border.all(color: Colors.white, width: 3)
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Tool buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (_mediaFile == null)
                      _buildToolButton(Icons.photo, 'Photo', () => _pickMedia(ImageSource.gallery)),
                    if (_mediaFile == null)
                      _buildToolButton(Icons.videocam, 'Video', () => _pickMedia(ImageSource.gallery, isVideo: true)),
                    if (_mediaFile == null)
                      _buildToolButton(Icons.text_fields, 'Text', () => setState(() => _storyType = StoryType.text)),
                    
                    if (_mediaFile != null || _storyType == StoryType.text)
                      _buildToolButton(
                        Icons.text_format, 
                        'Add Text', 
                        () => setState(() => _isTextMode = !_isTextMode),
                        isActive: _isTextMode,
                      ),
                    if (_mediaFile != null || _storyType == StoryType.text)
                      _buildToolButton(
                        Icons.emoji_emotions, 
                        'Stickers', 
                        () => setState(() => _isStickerMode = !_isStickerMode),
                        isActive: _isStickerMode,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(IconData icon, String label, VoidCallback onTap, {bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? Colors.blue : Colors.grey.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  void _showTextDialog(Offset position) {
    showDialog(
      context: context,
      builder: (context) {
        String text = '';
        return AlertDialog(
          title: const Text('Add Text'),
          content: TextField(
            autofocus: true,
            onChanged: (value) => text = value,
            decoration: const InputDecoration(hintText: 'Enter text...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (text.isNotEmpty) {
                  _addTextAnnotation(text, position);
                }
                Navigator.pop(context);
                setState(() => _isTextMode = false);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showStickerPicker(Offset position) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _stickers.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  _addStickerAnnotation(_stickers[index], position);
                  Navigator.pop(context);
                  setState(() => _isStickerMode = false);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(_stickers[index], style: const TextStyle(fontSize: 30)),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _removeAnnotation(String id) {
    setState(() {
      _annotations.removeWhere((annotation) => annotation.id == id);
    });
  }
} 