import 'package:flutter/material.dart';
import 'package:hobby/Screens/PostingBlog.dart';
import 'package:hobby/Screens/BlogDetailScreen.dart';

class BloggingScreen extends StatefulWidget {
  const BloggingScreen({super.key});

  @override
  State<BloggingScreen> createState() => _BloggingScreenState();
}

class _BloggingScreenState extends State<BloggingScreen> {
  final List<Article> _articles = [];

  void _addNewPost(Article newPost) {
    setState(() {
      _articles.insert(0, newPost);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _articles.isEmpty
          ? const Center(
              child: Text(
                'No blogs yet. Click the "+" button to add one!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _articles.length,
              itemBuilder: (context, index) {
                final item = _articles[index];
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
                                  item.title.isNotEmpty
                                      ? item.title
                                      : 'No Title',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "${item.author} · ${item.postedOn}",
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
  final String title;
  final String content;
  final String author;
  final String postedOn;
  final bool isLocalMedia;

  Article({
    required this.title,
    required this.content,
    required this.author,
    required this.isLocalMedia,
    required this.postedOn,
  });
}
