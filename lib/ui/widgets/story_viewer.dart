import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:social_media_app/data/story_model.dart';
import 'package:social_media_app/ui/bloc/story_cubit.dart';

class StoryViewer extends StatefulWidget {
  final List<StoryModel> stories;
  final int initialIndex;

  const StoryViewer({Key? key, required this.stories, this.initialIndex = 0}) : super(key: key);

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> with TickerProviderStateMixin {
  late int currentIndex;
  late int currentUserIndex;
  VideoPlayerController? _videoController;
  Timer? _progressTimer;
  double _progress = 0;
  bool _isPaused = false;
  bool _showUI = true;
  Timer? _hideUITimer;
  
  // Group stories by user
  late List<List<StoryModel>> _groupedStories;
  late List<String> _usernames;
  
  static const Duration storyDuration = Duration(seconds: 5);
  static const Duration hideUIDelay = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _groupStoriesByUser();
    _findInitialPosition();
    _startStory();
    _startHideUITimer();
  }

  void _groupStoriesByUser() {
    final Map<String, List<StoryModel>> grouped = {};
    
    for (final story in widget.stories) {
      if (!grouped.containsKey(story.username)) {
        grouped[story.username] = [];
      }
      grouped[story.username]!.add(story);
    }
    
    _usernames = grouped.keys.toList();
    _groupedStories = _usernames.map((username) => grouped[username]!).toList();
  }

  void _findInitialPosition() {
    final initialStory = widget.stories[widget.initialIndex];
    
    for (int userIdx = 0; userIdx < _groupedStories.length; userIdx++) {
      final userStories = _groupedStories[userIdx];
      for (int storyIdx = 0; storyIdx < userStories.length; storyIdx++) {
        if (userStories[storyIdx].id == initialStory.id) {
          currentUserIndex = userIdx;
          currentIndex = storyIdx;
          return;
        }
      }
    }
    
    currentUserIndex = 0;
    currentIndex = 0;
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _progressTimer?.cancel();
    _hideUITimer?.cancel();
    super.dispose();
  }

  void _startStory() async {
    _progressTimer?.cancel();
    _progress = 0;
    _isPaused = false;
    
    final story = _getCurrentStory();
    
    // Mark story as watched
    context.read<StoryCubit>().watchStory(story.id);
    
    if (story.type == StoryType.video && story.mediaUrl != null) {
      _videoController?.dispose();
      
      if (story.mediaUrl!.startsWith('http')) {
        _videoController = VideoPlayerController.network(story.mediaUrl!);
      } else {
        _videoController = VideoPlayerController.file(File(story.mediaUrl!));
      }
      
      await _videoController!.initialize();
      setState(() {});
      
      _videoController!.play();
      _videoController!.setLooping(false);
      
      _videoController!.addListener(() {
        if (_videoController!.value.position >= _videoController!.value.duration) {
          _nextStory();
        }
      });
    } else {
      _videoController?.dispose();
      _videoController = null;
      
      if (!_isPaused) {
        _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
          if (!_isPaused) {
            setState(() {
              _progress += 50 / storyDuration.inMilliseconds;
              if (_progress >= 1) {
                _progress = 1;
                timer.cancel();
                _nextStory();
              }
            });
          }
        });
      }
    }
    setState(() {});
  }

  StoryModel _getCurrentStory() {
    return _groupedStories[currentUserIndex][currentIndex];
  }

  List<StoryModel> _getCurrentUserStories() {
    return _groupedStories[currentUserIndex];
  }

  void _nextStory() {
    final currentUserStories = _getCurrentUserStories();
    
    if (currentIndex < currentUserStories.length - 1) {
      // Next story from same user
      setState(() {
        currentIndex++;
      });
      _startStory();
    } else {
      // Next user's stories
      if (currentUserIndex < _groupedStories.length - 1) {
        setState(() {
          currentUserIndex++;
          currentIndex = 0;
        });
        _startStory();
      } else {
        // End of all stories
        Navigator.of(context).pop();
      }
    }
  }

  void _prevStory() {
    if (currentIndex > 0) {
      // Previous story from same user
      setState(() {
        currentIndex--;
      });
      _startStory();
    } else {
      // Previous user's stories
      if (currentUserIndex > 0) {
        setState(() {
          currentUserIndex--;
          currentIndex = _groupedStories[currentUserIndex].length - 1;
        });
        _startStory();
      } else {
        // Beginning of all stories
        Navigator.of(context).pop();
      }
    }
  }

  void _pauseStory() {
    setState(() {
      _isPaused = true;
    });
    _progressTimer?.cancel();
    _videoController?.pause();
  }

  void _resumeStory() {
    setState(() {
      _isPaused = false;
    });
    if (_videoController != null) {
      _videoController!.play();
    } else {
      _startStory();
    }
  }

  void _toggleUI() {
    setState(() {
      _showUI = !_showUI;
    });
    if (_showUI) {
      _startHideUITimer();
    }
  }

  void _startHideUITimer() {
    _hideUITimer?.cancel();
    _hideUITimer = Timer(hideUIDelay, () {
      if (mounted) {
        setState(() {
          _showUI = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final story = _getCurrentStory();
    final currentUserStories = _getCurrentUserStories();
    
    return GestureDetector(
      onTap: _toggleUI,
      onLongPressStart: (_) => _pauseStory(),
      onLongPressEnd: (_) => _resumeStory(),
      onTapUp: (details) {
        final width = MediaQuery.of(context).size.width;
        if (details.localPosition.dx < width / 3) {
          _prevStory();
        } else if (details.localPosition.dx > width * 2 / 3) {
          _nextStory();
        }
      },
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          // Swipe right - previous user
          if (currentUserIndex > 0) {
            setState(() {
              currentUserIndex--;
              currentIndex = 0;
            });
            _startStory();
          }
        } else if (details.primaryVelocity! < 0) {
          // Swipe left - next user
          if (currentUserIndex < _groupedStories.length - 1) {
            setState(() {
              currentUserIndex++;
              currentIndex = 0;
            });
            _startStory();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Story content
            Center(
              child: _buildStoryContent(story),
            ),
            
            // Story annotations overlay
            ..._buildAnnotations(story),
            
            // UI overlay
            if (_showUI) ...[
              // Progress indicators
              Positioned(
                top: 40,
                left: 16,
                right: 16,
                child: Row(
                  children: List.generate(currentUserStories.length, (index) {
                    return Expanded(
                      child: Container(
                        height: 3,
                        margin: EdgeInsets.only(right: index < currentUserStories.length - 1 ? 4 : 0),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: index < currentIndex 
                              ? 1.0 
                              : index == currentIndex 
                                  ? (_videoController != null && _videoController!.value.isInitialized)
                                      ? _videoController!.value.position.inMilliseconds / _videoController!.value.duration.inMilliseconds
                                      : _progress
                                  : 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              
              // User info
              Positioned(
                top: 60,
                left: 16,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: story.userProfileImage.startsWith('assets')
                            ? Image.asset(story.userProfileImage, fit: BoxFit.cover)
                            : Image.network(story.userProfileImage, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _getTimeAgo(story.createdAt),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Close button
              Positioned(
                top: 50,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              
              // Pause indicator
              if (_isPaused)
                const Center(
                  child: Icon(
                    Icons.pause_circle_filled,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
              
              // Navigation hints
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (currentUserIndex > 0 || currentIndex > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '← Previous',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Hold to pause',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                    if (currentUserIndex < _groupedStories.length - 1 || currentIndex < currentUserStories.length - 1)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Next →',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Hashtags
              if (story.hashtags.isNotEmpty)
                Positioned(
                  bottom: 50,
                  left: 16,
                  right: 16,
                  child: Wrap(
                    spacing: 8,
                    children: story.hashtags.map((hashtag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        hashtag,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    )).toList(),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStoryContent(StoryModel story) {
    switch (story.type) {
      case StoryType.video:
        if (_videoController == null || !_videoController!.value.isInitialized) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        return AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        );
        
      case StoryType.text:
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: story.backgroundColor != null
                ? Color(int.parse(story.backgroundColor!.substring(1), radix: 16) + 0xFF000000)
                : Colors.black,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                story.textContent ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
        
      case StoryType.image:
      default:
        if (story.mediaUrl == null) return Container();
        
        if (story.mediaUrl!.startsWith('assets')) {
          return Image.asset(story.mediaUrl!, fit: BoxFit.contain);
        } else if (story.mediaUrl!.startsWith('http')) {
          return Image.network(story.mediaUrl!, fit: BoxFit.contain);
        } else {
          return Image.file(File(story.mediaUrl!), fit: BoxFit.contain);
        }
    }
  }

  List<Widget> _buildAnnotations(StoryModel story) {
    return story.annotations.map((annotation) {
      return Positioned(
        left: annotation.x * MediaQuery.of(context).size.width,
        top: annotation.y * MediaQuery.of(context).size.height,
        child: Container(
          padding: const EdgeInsets.all(4),
          child: _buildAnnotationContent(annotation),
        ),
      );
    }).toList();
  }

  Widget _buildAnnotationContent(StoryAnnotation annotation) {
    switch (annotation.type) {
      case 'text':
        return Text(
          annotation.content,
          style: TextStyle(
            color: Color(int.parse(annotation.style?['color']?.substring(1) ?? 'FFFFFF', radix: 16) + 0xFF000000),
            fontSize: annotation.style?['fontSize'] ?? 18.0,
            fontWeight: annotation.style?['fontWeight'] == 'bold' ? FontWeight.bold : FontWeight.normal,
            shadows: [
              Shadow(
                offset: const Offset(1, 1),
                blurRadius: 2,
                color: Colors.black.withOpacity(0.7),
              ),
            ],
          ),
        );
      case 'sticker':
      case 'emoji':
        return Text(
          annotation.content,
          style: TextStyle(fontSize: annotation.style?['size'] ?? 30.0),
        );
      default:
        return Text(annotation.content);
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
} 