import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hobby/Screens/Blogging.dart';
import 'package:hobby/Screens/CommentDetailScreen.dart';

class BlogDetailScreen extends StatefulWidget {
  final Article article;

  const BlogDetailScreen({super.key, required this.article});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      await _firestore.collection('blog_comments').add({
        'blogId': widget.article.id,
        'userId': _currentUser?.uid,
        'userName': _currentUser?.displayName ?? 'Anonim',
        'comment': _commentController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Blog yazarına bildirim gönder
      await _firestore.collection('notifications').add({
        'recipientId': widget.article.authorId,
        'senderId': _currentUser?.uid,
        'senderName': _currentUser?.displayName ?? 'Anonim',
        'type': 'comment',
        'title': 'Yeni Yorum',
        'body':
            '${_currentUser?.displayName ?? 'Anonim'} blogunuza yorum yaptı',
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });

      _commentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yorum eklenirken hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.article.title)),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Blog içeriği
                  Text(widget.article.content),
                  const Divider(height: 32),
                  const Text('Yorumlar',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  // Yorumlar listesi
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('blog_comments')
                        .where('blogId', isEqualTo: widget.article.id)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Hata: ${snapshot.error}');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final comment = snapshot.data!.docs[index];
                          return CommentWidget(
                            comment: comment,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CommentDetailScreen(
                                    commentId: comment.id,
                                    blogId: widget.article.id,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Yorum ekleme alanı
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Yorum yaz...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommentWidget extends StatelessWidget {
  final DocumentSnapshot comment;
  final Function() onTap;

  const CommentWidget({
    super.key,
    required this.comment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(comment['userName']),
            subtitle: Text(comment['comment']),
            trailing: IconButton(
              icon: const Icon(Icons.reply),
              onPressed: onTap,
            ),
          ),
          // Alt yorumları göster
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('comment_replies')
                .where('parentCommentId', isEqualTo: comment.id)
                .orderBy('createdAt')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();

              return Padding(
                padding: const EdgeInsets.only(left: 32.0),
                child: Column(
                  children: snapshot.data!.docs.map((reply) {
                    return ListTile(
                      title: Text(reply['userName']),
                      subtitle: Text(reply['comment']),
                      dense: true,
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
