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
      query = query.where('hobby', isEqualTo: _selectedHobbyFilter);
    }

    query = query.orderBy('postedOn', descending: true);

    return query.snapshots().map((snapshot) {
      List<Article> articles = snapshot.docs.map((doc) {
        final data = doc.data();
        DateTime dateTime;

        final timestamp = data['postedOn'];
        if (timestamp is Timestamp) {
          dateTime = timestamp.toDate();
        } else if (timestamp is String) {
          try {
            dateTime = DateTime.parse(timestamp);
          } catch (e) {
            dateTime = DateTime.now();
          }
        } else {
          dateTime = DateTime.now();
        }

        return Article(
          id: doc.id,
          authorId: data['authorId'] ?? '',
          title: data['title'] ?? '',
          content: data['content'] ?? '',
          author: data['username'] ?? data['author'] ?? 'Anonim',
          authorPhotoURL: data['authorPhotoURL'] ?? data['photoURL'],
          postedOn: dateTime.toIso8601String(),
          isLocalMedia: false,
        );
      }).toList();

      articles.sort((a, b) =>
          DateTime.parse(b.postedOn).compareTo(DateTime.parse(a.postedOn)));

      return articles;
    });
  }

  String _getTimeAgo(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'şimdi';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} dakika önce';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} saat önce';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} gün önce';
      } else {
        return '${(difference.inDays / 7).floor()} hafta önce';
      }
    } catch (e) {
      return 'bilinmiyor';
    }
  }

  Future<void> _refreshBlogs() async {
    setState(() {
      // Stream'i yeniden oluştur
      _fetchBlogPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshBlogs,
        child: Column(
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
                    physics: const AlwaysScrollableScrollPhysics(),
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _getTimeAgo(item.postedOn),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundImage: item.authorPhotoURL !=
                                              null
                                          ? NetworkImage(item.authorPhotoURL!)
                                          : const AssetImage(
                                                  'Images/default_avatar.png')
                                              as ImageProvider,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Yazar: ${item.author}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
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
  final String? authorPhotoURL;
  final String postedOn;
  final bool isLocalMedia;

  Article({
    required this.id,
    required this.authorId,
    required this.title,
    required this.content,
    required this.author,
    this.authorPhotoURL,
    required this.postedOn,
    required this.isLocalMedia,
  });
}
