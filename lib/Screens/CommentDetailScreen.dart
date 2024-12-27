import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentDetailScreen extends StatelessWidget {
  final String commentId;
  final String blogId;

  const CommentDetailScreen({
    super.key,
    required this.commentId,
    required this.blogId,
  });

  // Yardımcı fonksiyonu sınıf seviyesine taşı
  DateTime _getDateTime(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();

    try {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      } else if (timestamp is DateTime) {
        return timestamp;
      } else if (timestamp is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else if (timestamp is String) {
        return DateTime.parse(timestamp);
      }
    } catch (e) {
      print('Timestamp dönüşüm hatası: $e');
    }

    return DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yorum Detayları')),
      body: Column(
        children: [
          // Ana yorum
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('blog_comments')
                .doc(commentId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text('Yorum bulunamadı'));
              }

              final data = snapshot.data!.data();
              if (data == null) return const SizedBox();

              final comment = data as Map<String, dynamic>;
              return CommentCard(
                userName: comment['userName'] ?? 'Anonim',
                userImage: comment['userImage'],
                comment: comment['comment'] ?? '',
                createdAt: _getDateTime(comment['createdAt']),
                isMainComment: true,
              );
            },
          ),

          // Alt yorumlar
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('blog_comments')
                  .doc(commentId)
                  .collection('replies')
                  .orderBy('createdAt', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final reply = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    return CommentCard(
                      userName: reply['userName'] ?? 'Anonim',
                      userImage: reply['userImage'],
                      comment: reply['comment'] ?? '',
                      createdAt: _getDateTime(reply['createdAt']),
                      isMainComment: false,
                    );
                  },
                );
              },
            ),
          ),

          // Yorum yazma alanı
          _ReplyInput(commentId: commentId),
        ],
      ),
    );
  }
}

class CommentCard extends StatelessWidget {
  final String userName;
  final String? userImage;
  final String comment;
  final DateTime createdAt;
  final bool isMainComment;

  const CommentCard({
    super.key,
    required this.userName,
    this.userImage,
    required this.comment,
    required this.createdAt,
    this.isMainComment = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(
        left: isMainComment ? 8 : 32,
        right: 8,
        top: 8,
        bottom: 8,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      userImage != null ? NetworkImage(userImage!) : null,
                  radius: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  _getTimeAgo(createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays}g';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}s';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}d';
    } else {
      return 'şimdi';
    }
  }
}

class _ReplyInput extends StatefulWidget {
  final String commentId;

  const _ReplyInput({required this.commentId});

  @override
  State<_ReplyInput> createState() => _ReplyInputState();
}

class _ReplyInputState extends State<_ReplyInput> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitReply() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Kullanıcı oturum açmamış');

      await FirebaseFirestore.instance
          .collection('blog_comments')
          .doc(widget.commentId)
          .collection('replies')
          .add({
        'userId': user.uid,
        'userName': user.displayName ?? 'Anonim',
        'userImage': user.photoURL,
        'comment': _controller.text.trim(),
        'createdAt': Timestamp.now(),
      });

      _controller.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yanıt gönderilemedi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Yanıtınızı yazın...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isLoading ? null : _submitReply,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
