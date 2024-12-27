import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhotoCommentScreen extends StatelessWidget {
  final String postId;
  final String imageUrl;

  const PhotoCommentScreen({
    super.key,
    required this.postId,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yorumlar')),
      body: Column(
        children: [
          // Fotoğraf
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Yorumlar
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(postId)
                  .collection('comments')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Henüz yorum yapılmamış'));
                }

                final comments = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment =
                        comments[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: comment['userImage'] != null
                            ? NetworkImage(comment['userImage'])
                            : null,
                      ),
                      title: Text(comment['userName'] ?? 'Anonim'),
                      subtitle: Text(comment['comment'] ?? ''),
                    );
                  },
                );
              },
            ),
          ),
          // Yorum yazma alanı
          _CommentInput(postId: postId),
        ],
      ),
    );
  }
}

class _CommentInput extends StatefulWidget {
  final String postId;

  const _CommentInput({required this.postId});

  @override
  State<_CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<_CommentInput> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitComment() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Kullanıcı oturum açmamış');

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .update({
        'commentsCount': FieldValue.increment(1),
      });

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add({
        'userId': user.uid,
        'userName': user.displayName ?? 'Anonim',
        'userImage': user.photoURL,
        'comment': _controller.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      _controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yorum gönderilemedi: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
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
                hintText: 'Yorum yazın...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            onPressed: _isLoading ? null : _submitComment,
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
