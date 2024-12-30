import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileScreen extends StatelessWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data?.data() as Map<String, dynamic>?;
          if (userData == null) {
            return const Center(child: Text('Kullanıcı bulunamadı'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profil bilgileri
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(
                          userData['photoURL'] ??
                              'assets/Images/default_avatar.png',
                        ),
                        onBackgroundImageError: (_, __) =>
                            const AssetImage('Images/default_avatar.png'),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userData['name'] ?? 'İsimsiz Kullanıcı',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userData['bio'] ?? 'Henüz bir biyografi eklenmemiş',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                // Gönderiler
                SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.5, // Sabit yükseklik ver
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .where('userId', isEqualTo: userId)
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Hata: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final posts = snapshot.data?.docs ?? [];

                      if (posts.isEmpty) {
                        return const Center(child: Text('Henüz gönderi yok'));
                      }

                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                        ),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post =
                              posts[index].data() as Map<String, dynamic>;
                          return Image.network(
                            post['imageUrl'],
                            fit: BoxFit.cover,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
