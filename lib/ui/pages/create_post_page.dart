import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/app/configs/theme.dart';
import 'package:social_media_app/data/post_model.dart';
import 'package:social_media_app/ui/bloc/post_cubit.dart';
import 'package:video_player/video_player.dart';

enum PostVisibility {
  public,
  friends,
  private,
}

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({Key? key}) : super(key: key);

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _hashtagController = TextEditingController();
  File? _mediaFile;
  bool _isVideo = false;
  VideoPlayerController? _videoController;
  List<String> _hashtags = [];
  List<String> _mentions = [];
  PostVisibility _visibility = PostVisibility.public;
  bool _isUploading = false;

  @override
  void dispose() {
    _captionController.dispose();
    _hashtagController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    
    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
        _isVideo = false;
      });
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(
      source: source,
      maxDuration: const Duration(minutes: 5),
    );
    
    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
        _isVideo = true;
      });
      
      _videoController = VideoPlayerController.file(_mediaFile!)
        ..initialize().then((_) {
          setState(() {});
          _videoController!.play();
          _videoController!.setLooping(true);
        });
    }
  }

  void _addHashtag() {
    final hashtag = _hashtagController.text.trim();
    if (hashtag.isNotEmpty) {
      if (!hashtag.startsWith('#')) {
        setState(() {
          _hashtags.add('#$hashtag');
        });
      } else {
        setState(() {
          _hashtags.add(hashtag);
        });
      }
      _hashtagController.clear();
    }
  }

  void _removeHashtag(String hashtag) {
    setState(() {
      _hashtags.remove(hashtag);
    });
  }

  void _extractMentions() {
    final text = _captionController.text;
    final mentionRegex = RegExp(r'@(\w+)');
    final matches = mentionRegex.allMatches(text);
    
    setState(() {
      _mentions = matches.map((match) => match.group(0)!).toList();
    });
  }

  void _submitPost() {
    if (_captionController.text.isEmpty && _mediaFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add some content to your post'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    // Extract mentions from caption
    _extractMentions();

    // In a real app, you would upload the media file to a server
    // and get back a URL. For this demo, we'll use a placeholder URL.
    final String mediaUrl = _mediaFile != null 
        ? 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=500&q=60'
        : '';

    // Create a new post
    final newPost = PostModel(
      name: 'Sajon.co',
      imgProfile: 'assets/images/img_profile.jpeg',
      picture: mediaUrl,
      pictureHash: '',
      caption: _captionController.text,
      hashtags: _hashtags,
      like: '0',
      comment: '0',
      share: '0',
    );

    // Add the post to the feed
    context.read<PostCubit>().addPost(newPost);

    // Show success message and navigate back
    Future.delayed(const Duration(seconds: 1), () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Create Post',
          style: AppTheme.blackTextStyle.copyWith(
            fontWeight: AppTheme.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _isUploading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _submitPost,
                  child: Text(
                    'Post',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfo(),
            _buildCaptionInput(),
            if (_mediaFile != null) _buildMediaPreview(),
            _buildHashtagInput(),
            _buildHashtagList(),
            _buildVisibilitySelector(),
            const Divider(),
            _buildMediaOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryColor,
                width: 2,
              ),
              image: const DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(
                  "assets/images/img_profile.jpeg",
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Sajon.co",
                    style: AppTheme.blackTextStyle.copyWith(
                      fontWeight: AppTheme.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Image.asset(
                    "assets/images/ic_checklist.png",
                    width: 16,
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _buildVisibilityText(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityText() {
    IconData icon;
    String text;
    
    switch (_visibility) {
      case PostVisibility.public:
        icon = Icons.public;
        text = 'Public';
        break;
      case PostVisibility.friends:
        icon = Icons.people;
        text = 'Friends';
        break;
      case PostVisibility.private:
        icon = Icons.lock;
        text = 'Only me';
        break;
    }
    
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildCaptionInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: _captionController,
        maxLines: 5,
        decoration: const InputDecoration(
          hintText: "What's on your mind?",
          border: InputBorder.none,
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildMediaPreview() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _isVideo
                ? _videoController != null && _videoController!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      )
                    : const Center(child: CircularProgressIndicator())
                : Image.file(
                    _mediaFile!,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _mediaFile = null;
                  _isVideo = false;
                  _videoController?.dispose();
                  _videoController = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHashtagInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _hashtagController,
              decoration: const InputDecoration(
                hintText: "Add hashtag",
                prefixIcon: Icon(Icons.tag),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _addHashtag,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildHashtagList() {
    return _hashtags.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _hashtags.map((hashtag) {
                return Chip(
                  label: Text(hashtag),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => _removeHashtag(hashtag),
                  backgroundColor: Colors.grey.shade200,
                );
              }).toList(),
            ),
          );
  }

  Widget _buildVisibilitySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Post Visibility',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildVisibilityOption(
                icon: Icons.public,
                text: 'Public',
                value: PostVisibility.public,
              ),
              const SizedBox(width: 16),
              _buildVisibilityOption(
                icon: Icons.people,
                text: 'Friends',
                value: PostVisibility.friends,
              ),
              const SizedBox(width: 16),
              _buildVisibilityOption(
                icon: Icons.lock,
                text: 'Only me',
                value: PostVisibility.private,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityOption({
    required IconData icon,
    required String text,
    required PostVisibility value,
  }) {
    final isSelected = _visibility == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _visibility = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primaryColor : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? AppColors.primaryColor : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaOptions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add to your post',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMediaOption(
                icon: Icons.photo,
                color: Colors.green,
                text: 'Photo',
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              _buildMediaOption(
                icon: Icons.camera_alt,
                color: Colors.blue,
                text: 'Camera',
                onTap: () => _pickImage(ImageSource.camera),
              ),
              _buildMediaOption(
                icon: Icons.videocam,
                color: Colors.red,
                text: 'Video',
                onTap: () => _pickVideo(ImageSource.gallery),
              ),
              _buildMediaOption(
                icon: Icons.person,
                color: Colors.purple,
                text: 'Tag People',
                onTap: () {
                  // Show tag people dialog
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaOption({
    required IconData icon,
    required Color color,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}