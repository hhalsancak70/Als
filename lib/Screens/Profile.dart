import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hobby/Widgets/hobby_selection_dialog.dart';
import 'package:hobby/Screens/UserBlogsScreen.dart';
import 'package:hobby/Screens/UserPostsScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<Map<String, dynamic>> _getUserStats() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    // Kullanıcının post sayısını al
    final postsQuery = await _firestore
        .collection('posts')
        .where('userId', isEqualTo: user.uid)
        .get();

    // Kullanıcının blog sayısını al
    final blogsQuery = await _firestore
        .collection('blogs')
        .where('authorId', isEqualTo: user.uid)
        .get();

    return {
      'postCount': postsQuery.docs.length,
      'blogCount': blogsQuery.docs.length,
      'email': user.email,
      'displayName': user.displayName ?? 'İsimsiz Kullanıcı',
      'photoURL': user.photoURL ?? 'https://via.placeholder.com/150',
    };
  }

  Future<void> _updateProfilePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isLoading = true);

      // Firebase Storage'a fotoğrafı yükle
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child(_auth.currentUser!.uid);

      await storageRef.putFile(File(image.path));
      final photoURL = await storageRef.getDownloadURL();

      // Kullanıcı profilini güncelle
      await _auth.currentUser!.updatePhotoURL(photoURL);

      // Firestore'da kullanıcı bilgilerini güncelle
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'photoURL': photoURL,
      });

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil fotoğrafı güncellendi')),
        );
      }
    } catch (e) {
      print('Fotoğraf yükleme hatası: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  Future<void> _updateUserHobbies() async {
    try {
      final selectedHobbies = await showDialog<List<String>>(
        context: context,
        builder: (context) => const HobbySelectionDialog(),
      );

      if (selectedHobbies != null) {
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({
          'hobbies': selectedHobbies,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hobiler güncellendi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: FutureBuilder<Map<String, dynamic>>(
            future: _getUserStats(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Hata: ${snapshot.error}'));
              }

              final stats = snapshot.data ?? {};

              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundImage: NetworkImage(stats['photoURL']),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.deepPurple,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: _updateProfilePhoto,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    itemProfile(
                        'İsim', stats['displayName'], CupertinoIcons.person),
                    const SizedBox(height: 10),
                    itemProfile('Email', stats['email'], CupertinoIcons.mail),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              offset: const Offset(0, 5),
                              color: Colors.deepOrange.withOpacity(.2),
                              spreadRadius: 2,
                              blurRadius: 10)
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserPostsScreen(
                                      userId: _auth.currentUser!.uid),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Text(
                                  '${stats['postCount']}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text('Gönderi'),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserBlogsScreen(
                                      userId: _auth.currentUser!.uid),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Text(
                                  '${stats['blogCount']}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text('Blog'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Profil düzenleme sayfasına yönlendirme yapılabilir
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(15),
                        ),
                        child: const Text('Profili Düzenle'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _auth.signOut();
                          // Çıkış yapıldıktan sonra giriş sayfasına yönlendir
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(15),
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Çıkış Yap'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _updateUserHobbies,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(15),
                      ),
                      child: const Text('Hobileri Düzenle'),
                    ),
                  ],
                ),
              );
            },
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
    );
  }

  Widget itemProfile(String title, String subtitle, IconData iconData) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              offset: const Offset(0, 5),
              color: Colors.deepOrange.withOpacity(.2),
              spreadRadius: 2,
              blurRadius: 10)
        ],
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Icon(iconData),
        trailing: Icon(Icons.arrow_forward, color: Colors.grey.shade400),
        tileColor: Colors.white,
      ),
    );
  }
}
