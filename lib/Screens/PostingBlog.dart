import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'package:hobby/Widgets/hobby_selection_dialog.dart';

class PostingBlog extends StatefulWidget {
  const PostingBlog({super.key});

  @override
  _PostingBlogState createState() => _PostingBlogState();
}

class _PostingBlogState extends State<PostingBlog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _selectedHobby; // Hobi seçimi için ekle

  // Firebase Instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Loading State
  bool _isLoading = false;

  Future<void> _sendNotification(String title, String author) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // Tüm kullanıcıları al
      final usersSnapshot = await _firestore.collection('users').get();

      for (var userDoc in usersSnapshot.docs) {
        // Kendine bildirim gönderme
        if (userDoc.id != currentUser.uid) {
          // Bildirim dokümanı oluştur
          await _firestore.collection('notifications').add({
            'recipientId': userDoc.id,
            'senderId': currentUser.uid,
            'senderName': author,
            'type': 'blog',
            'title': 'Yeni Blog Yazısı',
            'body': '$author yeni bir blog paylaştı: $title',
            'createdAt': FieldValue.serverTimestamp(),
            'read': false,
          });

          // FCM token'ı al ve bildirim gönder
          final userData = userDoc.data();
          if (userData['fcmToken'] != null) {
            await _firestore.collection('fcm_tokens').add({
              'token': userData['fcmToken'],
              'title': 'Yeni Blog Yazısı',
              'body': '$author yeni bir blog paylaştı: $title',
              'timestamp': FieldValue.serverTimestamp(),
            });
          }
        }
      }
      print('Bildirimler başarıyla gönderildi');
    } catch (e) {
      print('Bildirim gönderme hatası: $e');
    }
  }

  Future<void> _submitPost() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both the title and content'),
        ),
      );
      return;
    }

    if (_titleController.text.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title must be at least 5 characters')),
      );
      return;
    }

    if (_contentController.text.length < 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content must be at least 20 characters')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user
      final User? user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to post a blog')),
        );
        return;
      }

      // Fetch author details
      final String author = user.displayName ?? user.email ?? 'Unknown User';
      final String authorId = user.uid;

      // Add blog post to Firestore
      await _firestore.collection('blogs').add({
        'title': _titleController.text,
        'content': _contentController.text,
        'author': author,
        'authorId': authorId,
        'hobby': _selectedHobby, // Hobi bilgisini ekle
        'postedOn': DateTime.now().toIso8601String(),
      });

      // Blog ekledikten sonra bildirim gönder
      await _sendNotification(
        _titleController.text,
        user.displayName ?? 'Anonim',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Blog posted successfully!')),
      );

      // Clear text fields
      _titleController.clear();
      _contentController.clear();

      // Navigate back or to a blogs list page
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post blog: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            backgroundColor: Colors.deepPurple[300],
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(60.0),
              child: AppBar(
                centerTitle: true,
                title: const Text(
                  'H0B1',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.deepPurple,
                leading: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    // Add navigation drawer functionality
                  },
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter the title of your blog:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: "Enter blog title",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Enter the content of your blog:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _contentController,
                    maxLines: 15,
                    decoration: InputDecoration(
                      hintText: "Start writing your blog content",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final selectedHobbies = await showDialog<List<String>>(
                        context: context,
                        builder: (context) => const HobbySelectionDialog(),
                      );

                      if (selectedHobbies != null) {
                        setState(() {
                          _selectedHobby = selectedHobbies.isNotEmpty
                              ? selectedHobbies.first
                              : null;
                        });
                      }
                    },
                    child: Text(_selectedHobby != null
                        ? 'Seçilen Hobi: $_selectedHobby'
                        : 'Hobi Seç'),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Submit Blog'),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
