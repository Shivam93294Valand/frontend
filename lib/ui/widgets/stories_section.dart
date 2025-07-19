import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/app/configs/theme.dart';
import 'package:social_media_app/data/story_model.dart';
import 'package:social_media_app/ui/bloc/story_cubit.dart';
import 'package:social_media_app/ui/widgets/story_viewer.dart';
import 'package:social_media_app/ui/widgets/story_upload_page.dart';

class StoriesSection extends StatelessWidget {
  const StoriesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StoryCubit()..getStories(),
      child: BlocConsumer<StoryCubit, StoryState>(
        listener: (context, state) {
          if (state is StoryUploaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Story uploaded successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is StoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is StoryError) {
            return Container(
              height: 110,
              margin: const EdgeInsets.only(bottom: 16),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message, style: const TextStyle(color: Colors.red)),
                    TextButton(
                      onPressed: () => context.read<StoryCubit>().getStories(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is StoryLoaded) {
            return _buildStoriesList(context, state.stories);
          } else if (state is StoryUploading) {
            return Container(
              height: 110,
              margin: const EdgeInsets.only(bottom: 16),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Uploading story...'),
                  ],
                ),
              ),
            );
          } else {
            return Container(
              height: 110,
              margin: const EdgeInsets.only(bottom: 16),
              child: const Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }

  Widget _buildStoriesList(BuildContext context, List<StoryModel> stories) {
    // Group stories by user for better organization
    final Map<String, List<StoryModel>> groupedStories = {};
    for (final story in stories) {
      if (!groupedStories.containsKey(story.username)) {
        groupedStories[story.username] = [];
      }
      groupedStories[story.username]!.add(story);
    }

    final usernames = groupedStories.keys.toList();
    
    // Check if "Your story" exists in the list
    bool hasYourStory = usernames.contains('Your story');

    return Container(
      height: 110,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: usernames.length + (hasYourStory ? 0 : 1), // Add 1 for "Your story" if it doesn't exist
        itemBuilder: (context, index) {
          // First item is always "Your story" or "Add story"
          if (index == 0) {
            if (hasYourStory) {
              // Show existing "Your story" with add button
              final userStories = groupedStories['Your story']!;
              final hasUnwatchedStories = userStories.any((story) => !story.isWatched);
              return _buildYourStoryItem(context, userStories.first, hasUnwatchedStories, userStories.length);
            } else {
              // Show add story button
              return _buildAddStoryButton(context);
            }
          } else {
            // Show other users' stories
            final adjustedIndex = hasYourStory ? index : index - 1;
            final username = usernames[adjustedIndex];
            if (username == 'Your story') {
              // Skip "Your story" as it's already shown as the first item
              return const SizedBox.shrink();
            }
            
            final userStories = groupedStories[username]!;
            final hasUnwatchedStories = userStories.any((story) => !story.isWatched);
            
            return GestureDetector(
              onTap: () {
                final storyIndex = stories.indexWhere((s) => s.username == username);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<StoryCubit>(),
                      child: StoryViewer(stories: stories, initialIndex: storyIndex),
                    ),
                  ),
                );
              },
              child: _buildStoryItem(context, userStories.first, hasUnwatchedStories, userStories.length),
            );
          }
        },
      ),
    );
  }

  Widget _buildAddStoryButton(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12, left: 4),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<StoryCubit>(),
                    child: const StoryUploadPage(),
                  ),
                ),
              );
            },
            child: Stack(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.greyColor.withOpacity(0.3), width: 2),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.whiteColor,
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(35),
                      child: Image.asset(
                        'assets/images/img_profile.jpeg',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your story',
            style: AppTheme.blackTextStyle.copyWith(
              fontSize: 12,
              fontWeight: AppTheme.medium,
              color: AppColors.blackColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Widget _buildYourStoryItem(BuildContext context, StoryModel story, bool hasUnwatchedStories, int storyCount) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12, left: 4),
      child: Column(
        children: [
          Stack(
            children: [
              // Story circle with gradient or border
              GestureDetector(
                onTap: () {
                  // View your story
                  final stories = (context.read<StoryCubit>().state as StoryLoaded).stories;
                  final storyIndex = stories.indexWhere((s) => s.username == 'Your story');
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<StoryCubit>(),
                        child: StoryViewer(stories: stories, initialIndex: storyIndex),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 70,
                  height: 70,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: hasUnwatchedStories
                        ? LinearGradient(
                            colors: [
                              AppColors.primaryColor,
                              AppColors.secondaryColor,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    border: !hasUnwatchedStories
                        ? Border.all(color: AppColors.greyColor, width: 2)
                        : null,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.whiteColor,
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(35),
                      child: _buildStoryPreview(story),
                    ),
                  ),
                ),
              ),
              
              // Add button
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<StoryCubit>(),
                          child: const StoryUploadPage(),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
              
              // Story type indicator
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _getStoryTypeColor(story.type),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Icon(
                    _getStoryTypeIcon(story.type),
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
              
              // Multiple stories indicator
              if (storyCount > 1)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$storyCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Your story',
            style: AppTheme.blackTextStyle.copyWith(
              fontSize: 12,
              fontWeight: AppTheme.medium,
              color: hasUnwatchedStories
                  ? AppColors.blackColor
                  : AppColors.greyColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStoryItem(BuildContext context, StoryModel story, bool hasUnwatchedStories, int storyCount) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 70,
                height: 70,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: hasUnwatchedStories
                      ? LinearGradient(
                          colors: [
                            AppColors.primaryColor,
                            AppColors.secondaryColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  border: !hasUnwatchedStories
                      ? Border.all(color: AppColors.greyColor, width: 2)
                      : null,
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.whiteColor,
                    shape: BoxShape.circle,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: _buildStoryPreview(story),
                  ),
                ),
              ),
              // Story type indicator
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _getStoryTypeColor(story.type),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Icon(
                    _getStoryTypeIcon(story.type),
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
              // Multiple stories indicator
              if (storyCount > 1)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$storyCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            story.username,
            style: AppTheme.blackTextStyle.copyWith(
              fontSize: 12,
              fontWeight: AppTheme.medium,
              color: hasUnwatchedStories
                  ? AppColors.blackColor
                  : AppColors.greyColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStoryPreview(StoryModel story) {
    switch (story.type) {
      case StoryType.text:
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: story.backgroundColor != null
                ? Color(int.parse(story.backgroundColor!.substring(1), radix: 16) + 0xFF000000)
                : AppColors.primaryColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              story.textContent?.split(' ').first ?? 'Text',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      case StoryType.image:
      case StoryType.video:
      default:
        if (story.userProfileImage.startsWith('assets')) {
          return Image.asset(
            story.userProfileImage,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            cacheWidth: 120, // Add cache size to prevent image disposal issues
          );
        } else {
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.greyColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                story.userProfileImage,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                cacheWidth: 120, // Add cache size to prevent image disposal issues
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.greyColor.withOpacity(0.3),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.greyColor,
                      size: 30,
                    ),
                  );
                },
              ),
            ),
          );
        }
    }
  }

  Color _getStoryTypeColor(StoryType type) {
    switch (type) {
      case StoryType.video:
        return Colors.red;
      case StoryType.text:
        return Colors.blue;
      case StoryType.image:
      default:
        return Colors.green;
    }
  }

  IconData _getStoryTypeIcon(StoryType type) {
    switch (type) {
      case StoryType.video:
        return Icons.play_arrow;
      case StoryType.text:
        return Icons.text_fields;
      case StoryType.image:
      default:
        return Icons.photo;
    }
  }
}