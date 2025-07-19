import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/app/configs/theme.dart';
import 'package:social_media_app/app/resources/constant/named_routes.dart';
import 'package:social_media_app/ui/bloc/post_cubit.dart';
import 'package:social_media_app/ui/widgets/card_post.dart';
import 'package:social_media_app/ui/widgets/clip_status_bar.dart';
import 'package:social_media_app/ui/widgets/stories_section.dart';

import '../widgets/custom_app_bar.dart';

class HomePage extends StatefulWidget {
  final String username;
  
  const HomePage({Key? key, this.username = 'User'}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _showBottomNav = true;
  double _lastOffset = 0;
  
  void _showPostOptions(BuildContext context, dynamic post, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Post'),
              onTap: () {
                Navigator.pop(context);
                _showEditPostDialog(context, post, index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Post', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void _showEditPostDialog(BuildContext context, dynamic post, int index) {
    final TextEditingController captionController = TextEditingController(text: post.caption);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Post'),
          content: TextField(
            controller: captionController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: "What's on your mind?",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<PostCubit>().editPost(
                  index,
                  captionController.text,
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post updated'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<PostCubit>().deletePost(index);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post deleted'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection.toString() == 'ScrollDirection.reverse') {
      if (_showBottomNav) setState(() => _showBottomNav = false);
    } else if (_scrollController.position.userScrollDirection.toString() == 'ScrollDirection.forward') {
      if (!_showBottomNav) setState(() => _showBottomNav = true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _buildCustomAppBar(context),
                  const SizedBox(height: 18),
                  const StoriesSection(),
                  const SizedBox(height: 16),
                  BlocBuilder<PostCubit, PostState>(
                    builder: (context, state) {
                      if (state is PostInitial) {
                        // Initialize posts if not already done
                        context.read<PostCubit>().getPosts();
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is PostError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(state.message),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => context.read<PostCubit>().getPosts(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      } else if (state is PostLoaded) {
                        return Column(
                          children: state.posts.asMap().entries.map((entry) {
                            final index = entry.key;
                            final post = entry.value;
                            return GestureDetector(
                              onTap: () {
                                // Navigate to post detail page
                                Navigator.pushNamed(
                                  context,
                                  NamedRoutes.postDetailScreen,
                                  arguments: {
                                    'post': post,
                                    'postIndex': index,
                                  },
                                );
                              },
                              onLongPress: () {
                                // Show post options (edit/delete) if it's the user's post
                                if (post.name == widget.username) {
                                  _showPostOptions(context, post, index);
                                }
                              },
                              child: CardPost(post: post),
                            );
                          }).toList(),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          _buildBackgroundGradient(),
          if (_showBottomNav) _buildBottomNavBar(),
        ],
      ),
    );
  }

  Container _buildBottomNavBar() {
    return Container(
      width: double.infinity,
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(right: 16, left: 16, bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Builder(builder: (context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildItemBottomNavBar(context, "assets/images/ic_home.png", "Home", true),
            _buildItemBottomNavBar(context,
                "assets/images/ic_discorvery.png", "Reels", false),
            _buildAddButton(context),
            _buildItemBottomNavBar(context, "assets/images/ic_inbox.png", "Chat", false),
            _buildItemBottomNavBar(context,
                "assets/images/ic_profile.png", "You", false),
          ],
        );
      }),
    );
  }
  
  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, NamedRoutes.createPostScreen);
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: AppColors.blackColor,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildItemBottomNavBar(BuildContext context, String icon, String title, bool selected) {
    return GestureDetector(
      onTap: () {
        if (title == "You") {
          Navigator.pushNamed(context, NamedRoutes.profileScreen);
        } else if (title == "Reels") {
          Navigator.pushNamed(context, NamedRoutes.reelsScreen);
        } else if (title == "Chat") {
          Navigator.pushNamed(context, NamedRoutes.chatScreen);
        }
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            selected
                ? ColorfulClipStatusBar(
                    color: AppColors.primaryColor,
                    child: Container(
                      width: 30,
                      height: 30,
                      padding: const EdgeInsets.all(5),
                      child: Image.asset(
                        icon,
                        width: 20,
                        height: 20,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  )
                : Image.asset(
                    icon,
                    width: 24,
                    height: 24,
                    color: AppColors.blackColor,
                  ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTheme.blackTextStyle.copyWith(
                fontWeight: selected ? AppTheme.bold : AppTheme.medium,
                fontSize: 10,
                color: selected ? AppColors.primaryColor : AppColors.blackColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildBackgroundGradient() => SizedBox.shrink();

  CustomAppBar _buildCustomAppBar(BuildContext context) {
    return CustomAppBar(
      child: Row(
        children: [
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.blackColor.withOpacity(0.2),
                  blurRadius: 35,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/ic_logo.png',
              width: 40,
              height: 40,
            ),
          ),
          const SizedBox(width: 12),
          Image.asset("assets/images/ic_notification.png",
              width: 24, height: 24),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, NamedRoutes.searchScreen),
            child: Image.asset("assets/images/ic_search.png", width: 24, height: 24),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(NamedRoutes.profileScreen),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                color: AppColors.backgroundColor,
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryColor,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blackColor.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      image: const DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(
                          "assets/images/img_profile.jpeg",
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, NamedRoutes.profileScreen);
                    },
                    child: Row(
                      children: [
                        Text(
                          widget.username,
                          style: AppTheme.blackTextStyle
                              .copyWith(fontWeight: AppTheme.bold, fontSize: 12),
                        ),
                        const SizedBox(width: 2),
                        Image.asset(
                          "assets/images/ic_checklist.png",
                          width: 16,
                          color: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
