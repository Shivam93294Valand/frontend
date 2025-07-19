import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/app/configs/theme.dart';
import 'package:social_media_app/data/post_model.dart';
import 'package:social_media_app/ui/bloc/post_cubit.dart';
import 'package:social_media_app/ui/widgets/card_post.dart';

class PostDetailPage extends StatefulWidget {
  final PostModel post;
  final int postIndex;

  const PostDetailPage({
    Key? key,
    required this.post,
    required this.postIndex,
  }) : super(key: key);

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  bool _isBookmarked = false;
  String _selectedReaction = '';
  final List<String> _reactions = ['👍', '❤️', '😂', '😮', '😢', '😡'];
  bool _showReactions = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isBookmarked ? 'Post saved' : 'Post unsaved'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showReactionSelector() {
    setState(() {
      _showReactions = !_showReactions;
    });
  }

  void _selectReaction(String reaction) {
    setState(() {
      _selectedReaction = reaction;
      _showReactions = false;
    });
    
    // Update like count
    context.read<PostCubit>().likePost(widget.postIndex);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You reacted with $reaction'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;
    
    // Add comment
    context.read<PostCubit>().commentOnPost(widget.postIndex, _commentController.text);
    
    // Clear input
    _commentController.clear();
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comment added'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _sharePost() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing post...'),
        duration: Duration(seconds: 1),
      ),
    );
    
    // Update share count
    context.read<PostCubit>().sharePost(widget.postIndex);
  }

  void _showEditDeleteMenu() {
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
                _showEditPostDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Post', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation();
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

  void _showEditPostDialog() {
    final TextEditingController captionController = TextEditingController(text: widget.post.caption);
    
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
                  widget.postIndex,
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

  void _showDeleteConfirmation() {
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
                context.read<PostCubit>().deletePost(widget.postIndex);
                Navigator.pop(context); // Go back to previous screen
                
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Post',
          style: AppTheme.blackTextStyle.copyWith(
            fontWeight: AppTheme.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: _showEditDeleteMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Post content
                  CardPost(post: widget.post),
                  
                  // Reactions section
                  _buildReactionsSection(),
                  
                  // Comments section
                  _buildCommentsSection(),
                ],
              ),
            ),
          ),
          
          // Comment input
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildReactionsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '${widget.post.like} likes',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.post.comment} comments',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.post.share} shares',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildReactionButton(),
              _buildActionButton(
                icon: Icons.comment_outlined,
                label: 'Comment',
                onTap: () {
                  // Focus on comment input
                  FocusScope.of(context).requestFocus(FocusNode());
                  _commentController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _commentController.text.length),
                  );
                },
              ),
              _buildActionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                onTap: _sharePost,
              ),
              _buildActionButton(
                icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                label: 'Save',
                onTap: _toggleBookmark,
              ),
            ],
          ),
          if (_showReactions) _buildReactionSelector(),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildReactionButton() {
    return InkWell(
      onTap: () {
        if (_selectedReaction.isEmpty) {
          // If no reaction yet, like the post
          _selectReaction('👍');
        } else {
          // If already reacted, show reaction selector
          _showReactionSelector();
        }
      },
      onLongPress: _showReactionSelector,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Text(
              _selectedReaction.isEmpty ? '👍' : _selectedReaction,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 4),
            Text(
              _selectedReaction.isEmpty ? 'Like' : 'Liked',
              style: TextStyle(
                color: _selectedReaction.isEmpty ? Colors.grey[600] : AppColors.primaryColor,
                fontWeight: _selectedReaction.isEmpty ? FontWeight.normal : FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _reactions.map((reaction) {
          return GestureDetector(
            onTap: () => _selectReaction(reaction),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _selectedReaction == reaction ? AppColors.primaryColor.withOpacity(0.1) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Text(
                reaction,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final bool isActive = (label == 'Save' && _isBookmarked) || 
                         (label == 'Like' && _selectedReaction.isNotEmpty);
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? AppColors.primaryColor : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primaryColor : Colors.grey[600],
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection() {
    // This would typically be populated from a database
    // For demo purposes, we'll show some sample comments
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comments',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          _buildCommentItem(
            username: 'John Smith',
            profileImage: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8M3x8cHJvZmlsZXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=500&q=60',
            comment: 'Great post! 👍',
            timeAgo: '2h ago',
          ),
          _buildCommentItem(
            username: 'Sarah Johnson',
            profileImage: 'https://images.unsplash.com/photo-1619895862022-09114b41f16f?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Nnx8cHJvZmlsZXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=500&q=60',
            comment: 'Love this! Where was this taken?',
            timeAgo: '1h ago',
          ),
          _buildCommentItem(
            username: 'Michael Brown',
            profileImage: 'https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTB8fHByb2ZpbGV8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60',
            comment: 'Amazing view! 😍',
            timeAgo: '30m ago',
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem({
    required String username,
    required String profileImage,
    required String comment,
    required String timeAgo,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(profileImage),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(comment),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Like',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Reply',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage('assets/images/img_profile.jpeg'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.send,
              color: AppColors.primaryColor,
            ),
            onPressed: _addComment,
          ),
        ],
      ),
    );
  }
}