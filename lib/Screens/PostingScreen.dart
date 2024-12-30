import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hobby/Widgets/hobby_selection_dialog.dart';

class PostingScreen extends StatefulWidget {
  const PostingScreen({super.key});

  @override
  _PostingScreenState createState() => _PostingScreenState();
}

class _PostingScreenState extends State<PostingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _captionController = TextEditingController();
  File? _selectedMedia;
  String? _selectedHobby;
  bool _isLoading = false;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _pickMedia(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedMedia = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitPost() async {
    if (_selectedMedia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir fotoğraf seçin.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Mevcut kullanıcı bilgilerini al
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Kullanıcı oturum açmamış');
      }

      // Kullanıcı bilgilerini Firestore'dan al
      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      final userData = userDoc.data();

      // Firebase Storage'a medyayı yükle
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('posts/$fileName');
      await ref.putFile(_selectedMedia!);
      String downloadUrl = await ref.getDownloadURL();

      // Firestore'a post bilgilerini kaydet
      await _firestore.collection('posts').add({
        'userId': currentUser.uid,
        'userName': userData?['username'] ?? 'Anonim',
        'userImage': userData?['photoURL'] ?? currentUser.photoURL,
        'content': _captionController.text,
        'imageUrl': downloadUrl,
        'hobby': _selectedHobby,
        'createdAt': FieldValue.serverTimestamp(),
        'likesCount': 0,
        'commentsCount': 0,
      });

      // Tüm kullanıcılara bildirim gönder
      final usersSnapshot = await _firestore.collection('users').get();
      for (var userDoc in usersSnapshot.docs) {
        if (userDoc.id != currentUser.uid) {
          // Kendine bildirim gönderme
          await _firestore.collection('notifications').add({
            'recipientId': userDoc.id,
            'senderId': currentUser.uid,
            'senderName': userData?['username'] ?? 'Anonim',
            'type': 'post',
            'title': 'Yeni Fotoğraf',
            'body':
                '${userData?['username'] ?? 'Anonim'} yeni bir fotoğraf paylaştı',
            'createdAt': FieldValue.serverTimestamp(),
            'read': false,
          });
        }
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gönderi başarıyla paylaşıldı')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gönderi paylaşılırken hata oluştu: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gönderi Oluştur'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _captionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Write a caption...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_selectedMedia != null)
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(_selectedMedia!),
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _selectedMedia = null;
                            });
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _pickMedia(ImageSource.gallery),
                        icon: const Icon(Icons.photo),
                        label: const Text("Add Photo"),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _pickMedia(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("Take Photo"),
                      ),
                    ],
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
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitPost,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Post'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
