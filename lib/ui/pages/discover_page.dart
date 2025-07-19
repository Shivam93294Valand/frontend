import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/data/reel_model.dart';
import 'package:video_player/video_player.dart';
import 'dart:convert';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final PageController _pageController = PageController();
  List<ReelModel> _reels = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialReels();
  }

  Future<void> _loadInitialReels() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String response = await rootBundle.loadString('assets/json/data_reels.json');
      final List<dynamic> data = json.decode(response);
      final List<ReelModel> newReels = data.map((item) => ReelModel.fromJson(item)).toList();
      
      setState(() {
        _reels = newReels;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreReels() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate loading more data by duplicating existing reels
    await Future.delayed(const Duration(seconds: 1));
    
    try {
      final String response = await rootBundle.loadString('assets/json/data_reels.json');
      final List<dynamic> data = json.decode(response);
      final List<ReelModel> newReels = data.map((item) {
        final Map<String, dynamic> modifiedItem = Map<String, dynamic>.from(item);
        modifiedItem['id'] = '${item['id']}_${_page}';
        return ReelModel.fromJson(modifiedItem);
      }).toList();
      
      setState(() {
        _reels.addAll(newReels);
        _isLoading = false;
        _page++;
        // Simulate end of data after 5 pages
        _hasMore = _page < 5;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading && _reels.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                
                // Load more reels when approaching the end
                if (index > _reels.length - 3) {
                  _loadMoreReels();
                }
              },
              itemCount: _reels.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _reels.length) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                return _buildReelItem(_reels[index], index);
              },
            ),
    );
  }

  Widget _buildReelItem(ReelModel reel, int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image/video
        Container(
          width: double.infinity,
          height: double.infinity,
          child: Image.network(
            reel.mediaUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[900],
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[900],
                child: const Center(
                  child: Icon(
                    Icons.error,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              );
            },
          ),
        ),
        
        // Gradient overlay
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.transparent,
                Colors.black45,
              ],
            ),
          ),
        ),

        // Top app bar
        Positioned(
          top: MediaQuery.of(context).padding.top,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Discover',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right side actions
        Positioned(
          right: 10,
          bottom: 100,
          child: Column(
            children: [
              _buildActionButton(Icons.favorite, reel.likes, Colors.red),
              const SizedBox(height: 20),
              _buildActionButton(Icons.chat_bubble, reel.comments, Colors.white),
              const SizedBox(height: 20),
              _buildActionButton(Icons.send, reel.shares, Colors.white),
              const SizedBox(height: 20),
              _buildActionButton(Icons.bookmark_border, '', Colors.white),
              const SizedBox(height: 20),
              _buildActionButton(Icons.more_horiz, '', Colors.white),
            ],
          ),
        ),

        // User info and caption
        Positioned(
          left: 16,
          right: 80,
          bottom: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                          child: Image.network(
                            reel.userImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey,
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '@${reel.username}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Follow',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Caption
              Text(
                reel.caption,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // Hashtags
              Wrap(
                children: reel.hashtags.map((hashtag) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    hashtag,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),

      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color iconColor) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.black26,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 28,
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}