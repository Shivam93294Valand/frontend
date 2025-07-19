class ReelModel {
  final String id;
  final String username;
  final String userImage;
  final String mediaUrl;
  final String mediaType; // 'image' or 'video'
  final String caption;
  final List<String> hashtags;
  final String likes;
  final String comments;
  final String shares;
  final String views;
  final String? userId;
  final DateTime? createdAt;

  const ReelModel({
    required this.id,
    required this.username,
    required this.userImage,
    required this.mediaUrl,
    required this.mediaType,
    required this.caption,
    required this.hashtags,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.views,
    this.userId,
    this.createdAt,
  });

  factory ReelModel.fromJson(Map<String, dynamic> json) => ReelModel(
    id: json['id'],
    username: json['username'],
    userImage: json['userImage'],
    mediaUrl: json['mediaUrl'],
    mediaType: json['mediaType'],
    caption: json['caption'],
    hashtags: List<String>.from(json["hashtags"].map((x) => x)),
    likes: json['likes'],
    comments: json['comments'],
    shares: json['shares'],
    views: json['views'],
  );

  // Factory method for backend data
  factory ReelModel.fromBackend(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return ReelModel(
      id: json['_id'] ?? json['id'] ?? '',
      username: user['username'] ?? 'Unknown',
      userImage: user['profilePicture'] ?? 'https://images.unsplash.com/photo-1494790108755-2616b68e5eb7?w=150&h=150&fit=crop&crop=face',
      mediaUrl: json['mediaUrl'] ?? '',
      mediaType: json['mediaType'] ?? 'video',
      caption: json['caption'] ?? '',
      hashtags: List<String>.from(json['hashtags'] ?? []),
      likes: (json['likesCount'] ?? json['likes']?.length ?? 0).toString(),
      comments: (json['commentsCount'] ?? json['comments']?.length ?? 0).toString(),
      shares: (json['shares'] ?? 0).toString(),
      views: (json['views'] ?? 0).toString(),
      userId: json['user']?['_id'] ?? json['user']?['id'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'userImage': userImage,
    'mediaUrl': mediaUrl,
    'mediaType': mediaType,
    'caption': caption,
    'hashtags': hashtags,
    'likes': likes,
    'comments': comments,
    'shares': shares,
    'views': views,
  };
}
