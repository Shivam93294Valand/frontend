import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/app/configs/theme.dart';
import 'package:social_media_app/app/resources/constant/named_routes.dart';
import 'package:social_media_app/data/post_model.dart';
import 'package:social_media_app/ui/bloc/post_cubit.dart';
import 'package:social_media_app/ui/widgets/custom_bottom_sheet_comments.dart';

import 'clip_status_bar.dart';

class CardPost extends StatelessWidget {
  final PostModel post;

  const CardPost({required this.post, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 460,
      margin: const EdgeInsets.only(bottom: 24),
      child: Stack(
        children: [
          _buildImageCover(),
          _buildImageGradient(),
          _buildFloatingInteractionSidebar(context),
          // Add name/profile at top left
          Positioned(
            top: 16,
            left: 16,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    post.imgProfile,
                    width: 28,
                    height: 28,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  post.name,
                  style: AppTheme.whiteTextStyle.copyWith(
                    fontSize: 14,
                    fontWeight: AppTheme.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 4,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildItemPublisher(context),
        ],
      ),
    );
  }
  
  Widget _buildFloatingInteractionSidebar(BuildContext context) {
    return Positioned(
      right: 10,
      top: 80,
      bottom: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFloatingIcon("assets/images/ic_heart.png", post.like, context, 
            onTap: () {
              // Find the post index in the list
              final state = context.read<PostCubit>().state;
              if (state is PostLoaded) {
                final index = state.posts.indexWhere((p) => 
                  p.picture == post.picture && p.caption == post.caption);
                if (index != -1) {
                  context.read<PostCubit>().likePost(index);
                  
                  // Show reaction animation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You liked this post'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              }
            }
          ),
          _buildFloatingIcon("assets/images/ic_message.png", post.comment, context,
            onTap: () {
              // Find the post index in the list
              final state = context.read<PostCubit>().state;
              if (state is PostLoaded) {
                final index = state.posts.indexWhere((p) => 
                  p.picture == post.picture && p.caption == post.caption);
                if (index != -1) {
                  // Navigate to post detail page
                  Navigator.pushNamed(
                    context,
                    NamedRoutes.postDetailScreen,
                    arguments: {
                      'post': post,
                      'postIndex': index,
                    },
                  );
                } else {
                  customBottomSheetComments(context);
                }
              } else {
                customBottomSheetComments(context);
              }
            }
          ),
          _buildFloatingIcon("assets/images/ic_bookmark.png", "Save", context,
            onTap: () {
              // Show bookmark confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Post saved'),
                  duration: Duration(seconds: 1),
                ),
              );
            }
          ),
          _buildFloatingIcon("assets/images/ic_send.png", post.share, context,
            onTap: () {
              // Find the post index in the list
              final state = context.read<PostCubit>().state;
              if (state is PostLoaded) {
                final index = state.posts.indexWhere((p) => 
                  p.picture == post.picture && p.caption == post.caption);
                if (index != -1) {
                  context.read<PostCubit>().sharePost(index);
                  
                  // Show share dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sharing post...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              }
            }
          ),
        ],
      ),
    );
  }
  
  Widget _buildFloatingIcon(String icon, String text, BuildContext context, {VoidCallback? onTap}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: ColorfulClipStatusBar(
            color: AppColors.primaryColor,
            child: Container(
              height: 40,
              width: 40,
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                icon,
                width: 20,
                height: 20,
                color: AppColors.whiteColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: AppTheme.whiteTextStyle.copyWith(
            fontSize: 12,
            fontWeight: AppTheme.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildInteractionItem(String icon, String text, BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: icon == "assets/images/ic_message.png"
              ? () => customBottomSheetComments(context)
              : () {},
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.whiteColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Image.asset(
              icon,
              width: 20,
              height: 20,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: AppTheme.whiteTextStyle.copyWith(
            fontSize: 12,
            fontWeight: AppTheme.bold,
          ),
        ),
      ],
    );
  }

  Align _buildImageGradient() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.2),
              Colors.black.withOpacity(0.6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCover() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Stack(children: [
        BlurHash(
          imageFit: BoxFit.cover,
          hash: post.pictureHash,
        ),
        Image.network(
          post.picture,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SizedBox(
                height: 55,
                width: 55,
                child: CircularProgressIndicator(
                  color: Colors.white.withOpacity(0.8),
                  strokeWidth: 1.2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        )
      ]),
    );
  }

  Container _buildItemPublisher(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 18, right: 40, bottom: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            post.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.whiteTextStyle.copyWith(
              fontSize: 12,
              fontWeight: AppTheme.regular,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            post.hashtags.join(" "),
            style: AppTheme.whiteTextStyle.copyWith(
              color: AppColors.greenColor,
              fontSize: 12,
              fontWeight: AppTheme.medium,
            ),
          ),
        ],
      ),
    );
  }

  _itemStatus(String icon, String text, BuildContext context) => [
    GestureDetector(
      onTap: icon == "assets/images/ic_message.png"
          ? () => customBottomSheetComments(context)
          : () {},
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: AppColors.whiteColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(30),
          image: DecorationImage(
            scale: 2.3,
            image: AssetImage(icon),
          ),
        ),
      ),
    ),
    const SizedBox(height: 4),
    Text(
      text,
      style: AppTheme.whiteTextStyle.copyWith(
        fontSize: 12,
        fontWeight: AppTheme.regular,
      ),
    ),
  ];
}
