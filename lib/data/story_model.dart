enum StoryType { image, video, text }

class StoryAnnotation {
  final String id;
  final String type; // 'text', 'sticker', 'emoji', 'drawing'
  final double x;
  final double y;
  final String content;
  final Map<String, dynamic>? style; // color, size, font, etc.

  StoryAnnotation({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.content,
    this.style,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'x': x,
    'y': y,
    'content': content,
    'style': style,
  };

  factory StoryAnnotation.fromJson(Map<String, dynamic> json) => StoryAnnotation(
    id: json['id'],
    type: json['type'],
    x: json['x'],
    y: json['y'],
    content: json['content'],
    style: json['style'],
  );
}

class StoryModel {
  final String id;
  final String username;
  final String userProfileImage;
  final String? mediaUrl; // image or video URL
  final StoryType type;
  final String? textContent;
  final List<String> hashtags;
  final List<StoryAnnotation> annotations;
  final DateTime createdAt;
  final Duration? videoDuration;
  bool isWatched;
  final String? backgroundColor; // for text-only stories

  StoryModel({
    required this.id,
    required this.username,
    required this.userProfileImage,
    this.mediaUrl,
    required this.type,
    this.textContent,
    this.hashtags = const [],
    this.annotations = const [],
    required this.createdAt,
    this.videoDuration,
    this.isWatched = false,
    this.backgroundColor,
  });

  bool get isExpired => DateTime.now().difference(createdAt).inHours >= 24;
  
  String get imageUrl => userProfileImage; // For backward compatibility

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'userProfileImage': userProfileImage,
    'mediaUrl': mediaUrl,
    'type': type.toString(),
    'textContent': textContent,
    'hashtags': hashtags,
    'annotations': annotations.map((a) => a.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'videoDuration': videoDuration?.inSeconds,
    'isWatched': isWatched,
    'backgroundColor': backgroundColor,
  };

  factory StoryModel.fromJson(Map<String, dynamic> json) => StoryModel(
    id: json['id'],
    username: json['username'],
    userProfileImage: json['userProfileImage'],
    mediaUrl: json['mediaUrl'],
    type: StoryType.values.firstWhere((e) => e.toString() == json['type']),
    textContent: json['textContent'],
    hashtags: List<String>.from(json['hashtags'] ?? []),
    annotations: (json['annotations'] as List?)?.map((a) => StoryAnnotation.fromJson(a)).toList() ?? [],
    createdAt: DateTime.parse(json['createdAt']),
    videoDuration: json['videoDuration'] != null ? Duration(seconds: json['videoDuration']) : null,
    isWatched: json['isWatched'] ?? false,
    backgroundColor: json['backgroundColor'],
  );
}