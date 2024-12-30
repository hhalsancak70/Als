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

  // Loading State
  bool _isLoading = false;

  Future<void> _submitBlog() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Kullanıcı oturum açmamış');

      // Kullanıcı bilgilerini Firestore'dan al
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data();

      // Blog bilgilerini kaydet
      await FirebaseFirestore.instance.collection('blogs').add({
        'authorId': user.uid,
        'username': userData?['username'] ?? 'Anonim',
        'title': _titleController.text,
        'content': _contentController.text,
        'hobby': _selectedHobby,
        'postedOn': FieldValue.serverTimestamp(),
        'authorPhotoURL': userData?['photoURL'] ??
            user.photoURL, // Profil fotoğrafını da ekle
        'likes': 0,
        'comments': 0,
      });

      // Tüm kullanıcılara bildirim gönder
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      for (var userDoc in usersSnapshot.docs) {
        if (userDoc.id != user.uid) {
          await FirebaseFirestore.instance.collection('notifications').add({
            'recipientId': userDoc.id,
            'senderId': user.uid,
            'senderName': userData?['username'] ?? 'Anonim',
            'type': 'blog',
            'title': 'Yeni Blog Yazısı',
            'body':
                '${userData?['username'] ?? 'Anonim'} yeni bir blog paylaştı',
            'createdAt': FieldValue.serverTimestamp(),
            'read': false,
          });
        }
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Blog başarıyla paylaşıldı')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Blog paylaşılırken hata oluştu: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                      onPressed: _submitBlog,
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
