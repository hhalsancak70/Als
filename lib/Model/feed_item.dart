class PostUser {
  final String name;
  final String id;
  final String? imageUrl;

  PostUser(this.name, this.id, this.imageUrl);

  String get fullName => name;
  String get userName => name;
}

class FeedItem {
  final String id;
  final PostUser user;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isLocalMedia;

  FeedItem({
    required this.id,
    required this.user,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    this.isLocalMedia = false,
  });
}
