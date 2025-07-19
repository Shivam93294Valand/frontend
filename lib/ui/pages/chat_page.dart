import 'package:flutter/material.dart';
import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/app/configs/theme.dart';
import 'package:social_media_app/ui/pages/chat_detail_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Sample chat data
  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'Emma Watson',
      'profileImage': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8cHJvZmlsZXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=500&q=60',
      'lastMessage': 'Hey, how are you doing?',
      'time': '2m ago',
      'unread': 2,
      'isOnline': true,
    },
    {
      'name': 'John Smith',
      'profileImage': 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8M3x8cHJvZmlsZXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=500&q=60',
      'lastMessage': 'I just saw your post! Amazing 🔥',
      'time': '15m ago',
      'unread': 0,
      'isOnline': true,
    },
    {
      'name': 'Sarah Johnson',
      'profileImage': 'https://images.unsplash.com/photo-1619895862022-09114b41f16f?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Nnx8cHJvZmlsZXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=500&q=60',
      'lastMessage': 'Are you coming to the event tonight?',
      'time': '1h ago',
      'unread': 1,
      'isOnline': false,
    },
    {
      'name': 'Michael Brown',
      'profileImage': 'https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTB8fHByb2ZpbGV8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60',
      'lastMessage': 'Thanks for your help yesterday!',
      'time': '2h ago',
      'unread': 0,
      'isOnline': false,
    },
    {
      'name': 'Jessica Davis',
      'profileImage': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTJ8fHByb2ZpbGV8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60',
      'lastMessage': 'Did you see the new feature update?',
      'time': '3h ago',
      'unread': 3,
      'isOnline': true,
    },
    {
      'name': 'David Wilson',
      'profileImage': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTZ8fHByb2ZpbGV8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60',
      'lastMessage': 'Let\'s catch up this weekend',
      'time': '1d ago',
      'unread': 0,
      'isOnline': false,
    },
    {
      'name': 'Amanda Taylor',
      'profileImage': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MjB8fHByb2ZpbGV8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60',
      'lastMessage': 'I loved your recent photos!',
      'time': '2d ago',
      'unread': 0,
      'isOnline': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Messages',
          style: AppTheme.blackTextStyle.copyWith(
            fontWeight: AppTheme.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square, color: AppColors.primaryColor),
            onPressed: () {
              // Create new message
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildConversationsSection(),
          Expanded(
            child: _buildChatsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conversations',
            style: AppTheme.blackTextStyle.copyWith(
              fontWeight: AppTheme.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTabButton('Active', true),
              const SizedBox(width: 16),
              _buildTabButton('Request', false),
              const Spacer(),
              Icon(
                Icons.tune,
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, bool isActive) {
    return GestureDetector(
      onTap: () {
        // Handle tab selection
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primaryColor : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: _isSearching ? AppColors.primaryColor : Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (value) {
                  setState(() {
                    _isSearching = value.isNotEmpty;
                  });
                },
              ),
            ),
            if (_isSearching)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() {
                    _isSearching = false;
                  });
                },
                child: const Icon(Icons.close, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatsList() {
    return ListView.builder(
      itemCount: _chats.length,
      itemBuilder: (context, index) {
        final chat = _chats[index];
        return _buildChatItem(chat);
      },
    );
  }

  Widget _buildGroupsList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group,
            size: 80,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Groups Yet',
            style: AppTheme.blackTextStyle.copyWith(
              fontWeight: AppTheme.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a group to chat with multiple friends',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Create new group
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Create Group'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(chat: chat),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(chat['profileImage']),
              ),
              if (chat['isOnline'])
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat['name'],
                  style: AppTheme.blackTextStyle.copyWith(
                    fontWeight: chat['unread'] > 0 ? AppTheme.bold : AppTheme.medium,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  chat['lastMessage'],
                  style: TextStyle(
                    color: chat['unread'] > 0 ? Colors.black87 : Colors.grey,
                    fontWeight: chat['unread'] > 0 ? FontWeight.w500 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                chat['time'],
                style: TextStyle(
                  color: chat['unread'] > 0 ? AppColors.primaryColor : Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              if (chat['unread'] > 0)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    chat['unread'].toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
        ),
      ),
    );
  }
}