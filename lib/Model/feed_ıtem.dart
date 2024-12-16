class FeedItem {
  final String? content;
  final String? imageUrl;
  final User user;
  final int commentsCount;
  final int likesCount;
  final int retweetsCount;
  final bool isLocalMedia;
  final DateTime createdAt;
  List<String> labels;

  FeedItem({
    this.content,
    this.imageUrl,
    required this.user,
    this.commentsCount = 0,
    this.likesCount = 0,
    this.retweetsCount = 0,
    this.isLocalMedia = false,
    this.labels = const [],
    required this.createdAt,
  });
}

class User {
  final String fullName;
  final String imageUrl;
  final String userName;

  User(
      this.fullName,
      this.userName,
      this.imageUrl,
      );
}
