import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hobby/Screens/BlogDetailScreen.dart';
import 'package:hobby/Screens/Blogging.dart';

class UserBlogsScreen extends StatelessWidget {
  final String userId;

  const UserBlogsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bloglar'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('blogs')
            .where('authorId', isEqualTo: userId)
            .orderBy('postedOn', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final blogs = snapshot.data?.docs ?? [];

          if (blogs.isEmpty) {
            return const Center(child: Text('Henüz blog yazısı yok'));
          }

          return ListView.builder(
            itemCount: blogs.length,
            itemBuilder: (context, index) {
              final blog = blogs[index].data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlogDetailScreen(
                        article: Article(
                          id: blogs[index].id,
                          authorId: blog['authorId'] ?? '',
                          title: blog['title'] ?? '',
                          content: blog['content'] ?? '',
                          author: blog['username'] ?? 'Anonim',
                          authorPhotoURL: blog['authorPhotoURL'],
                          postedOn: (blog['postedOn'] as Timestamp)
                              .toDate()
                              .toIso8601String(),
                          isLocalMedia: false,
                        ),
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(blog['title'] ?? ''),
                    subtitle: Text(
                      blog['content'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
