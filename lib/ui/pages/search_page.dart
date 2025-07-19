import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/app/configs/theme.dart';
import 'package:social_media_app/ui/bloc/post_cubit.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  
  final List<String> _recentSearches = [
    'travel photography',
    'food recipes',
    'fitness tips',
    'coding tutorials',
  ];
  
  final List<String> _trendingSearches = [
    '#summer2025',
    '#travelgoals',
    '#foodie',
    '#techtrends',
    '#fashionweek',
    '#fitness',
    '#photography',
    '#coding',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
      
      // Add to recent searches if not already there
      if (query.isNotEmpty && !_recentSearches.contains(query)) {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              suffixIcon: _isSearching
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _isSearching = false;
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
            ),
            onChanged: _handleSearch,
            onSubmitted: _handleSearch,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isSearching ? _buildSearchResults() : _buildSearchSuggestions(),
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_recentSearches.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Searches',
                    style: AppTheme.blackTextStyle.copyWith(
                      fontWeight: AppTheme.bold,
                      fontSize: 16,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _recentSearches.clear();
                      });
                    },
                    child: Text(
                      'Clear All',
                      style: TextStyle(color: AppColors.primaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Column(
                children: _recentSearches.map((search) => _buildSearchItem(search)).toList(),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              'Trending Searches',
              style: AppTheme.blackTextStyle.copyWith(
                fontWeight: AppTheme.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _trendingSearches.map((trend) => _buildTrendingItem(trend)).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Explore',
              style: AppTheme.blackTextStyle.copyWith(
                fontWeight: AppTheme.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            _buildExploreCategories(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchItem(String search) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.history, color: Colors.grey),
      title: Text(search),
      trailing: IconButton(
        icon: const Icon(Icons.close, color: Colors.grey, size: 16),
        onPressed: () {
          setState(() {
            _recentSearches.remove(search);
          });
        },
      ),
      onTap: () {
        _searchController.text = search;
        _handleSearch(search);
      },
    );
  }

  Widget _buildTrendingItem(String trend) {
    return GestureDetector(
      onTap: () {
        _searchController.text = trend;
        _handleSearch(trend);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          trend,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildExploreCategories() {
    final categories = [
      {'name': 'Photography', 'icon': Icons.camera_alt},
      {'name': 'Travel', 'icon': Icons.flight},
      {'name': 'Food', 'icon': Icons.restaurant},
      {'name': 'Fashion', 'icon': Icons.shopping_bag},
      {'name': 'Sports', 'icon': Icons.sports_basketball},
      {'name': 'Technology', 'icon': Icons.devices},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () {
            _searchController.text = category['name'] as String;
            _handleSearch(category['name'] as String);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.primaries[index % Colors.primaries.length].withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category['icon'] as IconData,
                  color: Colors.primaries[index % Colors.primaries.length],
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  category['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return BlocProvider(
      create: (context) => PostCubit()..getPosts(),
      child: BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          if (state is PostError) {
            return Center(child: Text(state.message));
          } else if (state is PostLoaded) {
            // Filter posts based on search query
            final filteredPosts = state.posts.where((post) {
              return post.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  post.caption.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();

            if (filteredPosts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'No results found for "$_searchQuery"',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Try searching with different keywords',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: filteredPosts.length,
              itemBuilder: (context, index) {
                final post = filteredPosts[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(post.imgProfile),
                  ),
                  title: Text(post.name),
                  subtitle: Text(post.caption),
                  trailing: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      post.picture,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  onTap: () {
                    // Navigate to post details
                  },
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}