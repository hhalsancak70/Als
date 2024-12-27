import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import
import 'package:hobby/Screens/PostingBlog.dart';
import 'package:hobby/Screens/BlogDetailScreen.dart';

class BloggingScreen extends StatefulWidget {
  const BloggingScreen({super.key});

  @override
  State<BloggingScreen> createState() => _BloggingScreenState();
}

class _BloggingScreenState extends State<BloggingScreen> {
  // Firebase Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch blog posts from Firestore
  Stream<List<Article>> _fetchBlogPosts() {
    return _firestore
        .collection('blogs')
        .orderBy('postedOn', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Article(
          id: doc.id,
          authorId: data['authorId'] ?? '',
          title: data['title'] ?? '',
          content: data['content'] ?? '',
          author: data['author'] ?? 'Anonim',
          postedOn: data['postedOn'] ?? DateTime.now().toIso8601String(),
          isLocalMedia: false,
        );
      }).toList();
    });
  }

  // Add new post to Firestore
  void _addNewPost(Article newPost) {
    setState(() {
      _firestore.collection('blogs').add({
        'title': newPost.title,
        'content': newPost.content,
        'author': newPost.author,
        'postedOn': newPost.postedOn,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Article>>(
        stream: _fetchBlogPosts(), // Stream of blog posts from Firestore
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading blogs.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No blogs yet. Click the "+" button to add one!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final articles = snapshot.data!;

          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final item = articles[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlogDetailScreen(article: item),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title.isNotEmpty ? item.title : 'No Title',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.author.isNotEmpty
                                    ? item.author
                                    : 'Yazar Belirtilmemiş',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.postedOn,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icons.bookmark_border_rounded,
                                  Icons.share,
                                  Icons.more_vert
                                ].map((e) {
                                  return InkWell(
                                    onTap: () {
                                      // Define actions for each icon
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Icon(e, size: 20),
                                    ),
                                  );
                                }).toList(),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Article? newPost = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PostingBlog(),
            ),
          );
          if (newPost != null) {
            _addNewPost(newPost);
          }
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Article {
  final String id;
  final String authorId;
  final String title;
  final String content;
  final String author;
  final String postedOn;
  final bool isLocalMedia;

  Article({
    required this.id,
    required this.authorId,
    required this.title,
    required this.content,
    required this.author,
    required this.postedOn,
    required this.isLocalMedia,
  });
}
