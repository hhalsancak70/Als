import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hobby/Screens/PostingBlog.dart';
import 'package:hobby/Screens/BlogDetailScreen.dart';

class BloggingScreen extends StatefulWidget {
  const BloggingScreen({super.key});

  @override
  State<BloggingScreen> createState() => _BloggingScreenState();
}

class _BloggingScreenState extends State<BloggingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedHobbyFilter;

  final List<Map<String, String>> _defaultHobbies = [
    {'id': 'all', 'name': 'Tümü'},
    {'id': 'football', 'name': 'Futbol'},
    {'id': 'cinema', 'name': 'Sinema'},
    {'id': 'economy', 'name': 'Ekonomi'},
    {'id': 'music', 'name': 'Müzik'},
    {'id': 'technology', 'name': 'Teknoloji'},
    {'id': 'travel', 'name': 'Seyahat'},
    {'id': 'cooking', 'name': 'Yemek Yapma'},
    {'id': 'reading', 'name': 'Kitap Okuma'},
    {'id': 'gaming', 'name': 'Oyun'},
    {'id': 'sports', 'name': 'Spor'},
  ];

  Stream<List<Article>> _fetchBlogPosts() {
    Query<Map<String, dynamic>> query = _firestore.collection('blogs');

    if (_selectedHobbyFilter != null && _selectedHobbyFilter != 'all') {
      query = query
          .where('hobby', isEqualTo: _selectedHobbyFilter)
          .orderBy('postedOn', descending: true);
    } else {
      query = query.orderBy('postedOn', descending: true);
    }

    return query.snapshots().map((snapshot) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Hobi filtreleri
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _defaultHobbies.length,
              itemBuilder: (context, index) {
                final hobby = _defaultHobbies[index];
                final isSelected = _selectedHobbyFilter == hobby['id'];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(hobby['name']!),
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedHobbyFilter = selected ? hobby['id'] : null;
                      });
                    },
                    selectedColor: Colors.deepPurple.shade100,
                    checkmarkColor: Colors.deepPurple,
                  ),
                );
              },
            ),
          ),
          // Blog listesi
          Expanded(
            child: StreamBuilder<List<Article>>(
              stream: _fetchBlogPosts(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final articles = snapshot.data ?? [];

                if (articles.isEmpty) {
                  return const Center(child: Text('Henüz blog yazısı yok'));
                }

                return ListView.builder(
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final item = articles[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BlogDetailScreen(article: item),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Yazar: ${item.author}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.content,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PostingBlog(),
            ),
          );
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
