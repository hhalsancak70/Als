import 'package:flutter/material.dart';
import 'package:hobby/Screens/PostingScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hobby/Model/feed_item.dart'; // PostUser sınıfı için import
import 'package:hobby/Screens/PhotoCommentScreen.dart';
import 'package:hobby/Screens/UserProfileScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _selectedHobbyFilter;

  // Sınıf seviyesinde hobi listesini tanımlayalım
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

  Stream<List<FeedItem>> _getFeedItems() {
    Query<Map<String, dynamic>> query = _firestore.collection('posts');

    if (_selectedHobbyFilter != null && _selectedHobbyFilter != 'all') {
      query = query
          .where('hobby', isEqualTo: _selectedHobbyFilter)
          .orderBy('createdAt', descending: true);
    } else {
      query = query.orderBy('createdAt', descending: true);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FeedItem(
          id: doc.id,
          user: PostUser(
            data['userName'],
            data['userId'],
            data['userImage'],
          ),
          content: data['content'],
          imageUrl: data['imageUrl'],
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          likesCount: data['likesCount'] ?? 0,
          commentsCount: data['commentsCount'] ?? 0,
          isLiked: false,
        );
      }).toList();
    });
  }

  // Helper function to calculate time difference.
  String _getTimeDifference(DateTime createdAt) {
    final now = DateTime.now();
    final duration = now.difference(createdAt);

    if (duration.inSeconds < 60) {
      return '${duration.inSeconds} second${duration.inSeconds > 1 ? 's' : ''} ago';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''} ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''} ago';
    } else if (duration.inDays < 7) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''} ago';
    } else {
      return '${(duration.inDays / 7).floor()} week${(duration.inDays / 7).floor() > 1 ? 's' : ''} ago';
    }
  }

  // Beğeni işlemi
  Future<void> _toggleLike(String postId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final postRef = _firestore.collection('posts').doc(postId);
    final likeRef = _firestore.collection('likes').doc('${postId}_$userId');

    try {
      final likeDoc = await likeRef.get();
      if (likeDoc.exists) {
        // Beğeniyi kaldır
        await likeRef.delete();
        await postRef.update({
          'likesCount': FieldValue.increment(-1),
        });
      } else {
        // Beğeni ekle
        await likeRef.set({
          'userId': userId,
          'postId': postId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await postRef.update({
          'likesCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      print('Beğeni hatası: $e');
    }
  }

  // Yorum ekleme dialog'u
  Future<void> _showCommentDialog(String postId) async {
    final TextEditingController commentController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yorum Yap'),
        content: TextField(
          controller: commentController,
          decoration: const InputDecoration(
            hintText: 'Yorumunuzu yazın...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              if (commentController.text.trim().isNotEmpty) {
                await _addComment(postId, commentController.text);
                if (!mounted) return;
                Navigator.pop(context);
              }
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  // Yorum ekleme işlemi
  Future<void> _addComment(String postId, String comment) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('post_comments').add({
        'postId': postId,
        'userId': user.uid,
        'userName': user.displayName ?? 'Anonim',
        'userImage': user.photoURL,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('posts').doc(postId).update({
        'commentsCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Yorum ekleme hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hobby',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple.shade50,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Hobi filtreleri
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
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
                    selectedColor: Colors.deepPurple.shade200,
                    checkmarkColor: Colors.white,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.deepPurple,
                    ),
                  ),
                );
              },
            ),
          ),

          // Post listesi
          Expanded(
            child: StreamBuilder<List<FeedItem>>(
              stream: _getFeedItems(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final feedItems = snapshot.data ?? [];

                if (feedItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.post_add, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz gönderi yok',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView.builder(
                    itemCount: feedItems.length,
                    padding: const EdgeInsets.only(top: 8),
                    itemBuilder: (context, index) {
                      final item = feedItems[index];
                      return _buildPostCard(item);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PostingScreen()),
          );
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPostCard(FeedItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kullanıcı bilgileri
          ListTile(
            leading: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UserProfileScreen(userId: item.user.id),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  item.user.imageUrl ?? 'assets/Images/default_avatar.png',
                ),
                onBackgroundImageError: (_, __) =>
                    const AssetImage('Images/default_avatar.png'),
              ),
            ),
            title: Text(
              item.user.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(_getTimeDifference(item.createdAt)),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {}, // Menü için
            ),
          ),

          // İçerik
          if (item.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(item.content),
            ),

          // Fotoğraf
          if (item.imageUrl != null)
            Container(
              constraints: const BoxConstraints(
                maxHeight: 400,
              ),
              width: double.infinity,
              child: Image.network(
                item.imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.deepPurple),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.grey,
                        size: 50,
                      ),
                    ),
                  );
                },
                cacheWidth: 800, // Resim önbelleğe alınırken boyutunu sınırla
              ),
            ),

          // Etkileşim butonları
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Beğeni butonu
                Row(
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('likes')
                          .doc(
                              '${item.id}_${FirebaseAuth.instance.currentUser?.uid}')
                          .snapshots(),
                      builder: (context, snapshot) {
                        final isLiked =
                            snapshot.hasData && snapshot.data!.exists;
                        return IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: Colors.deepPurple,
                          ),
                          onPressed: () => _toggleLike(item.id),
                        );
                      },
                    ),
                    Text(
                      '${item.likesCount}',
                      style: const TextStyle(color: Colors.deepPurple),
                    ),
                  ],
                ),

                // Yorum butonu
                TextButton.icon(
                  onPressed: () => _showCommentDialog(item.id),
                  icon: const Icon(Icons.comment_outlined,
                      color: Colors.deepPurple),
                  label: Text(
                    '${item.commentsCount} Yorum',
                    style: const TextStyle(color: Colors.deepPurple),
                  ),
                ),

                // Yorumları görüntüle butonu
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoCommentScreen(
                          postId: item.id,
                          imageUrl: item.imageUrl!,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility, color: Colors.deepPurple),
                  label: const Text(
                    'Yorumları Gör',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
