import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileScreen extends StatelessWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanıcı Profili'),
        backgroundColor: Colors.deepPurple.shade50,
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, userSnapshot) {
          if (userSnapshot.hasError) {
            return Center(child: Text('Hata: ${userSnapshot.error}'));
          }

          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
          if (userData == null) {
            return const Center(child: Text('Kullanıcı bulunamadı'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profil fotoğrafı
                Hero(
                  tag: 'profile-$userId',
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(
                      userData['photoURL'] ??
                          'assets/Images/default_avatar.png',
                    ),
                    onBackgroundImageError: (_, __) =>
                        const AssetImage('Images/default_avatar.png'),
                  ),
                ),
                const SizedBox(height: 16),

                // Kullanıcı adı
                Text(
                  userData['name'] ?? 'İsimsiz Kullanıcı',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Kullanıcı bilgileri
                Text(
                  userData['email'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                if (userData['bio'] != null &&
                    userData['bio'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      userData['bio'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                const SizedBox(height: 24),

                // Hobiler
                if (userData['hobbies'] != null &&
                    (userData['hobbies'] as List).isNotEmpty) ...[
                  const Text(
                    'İlgi Alanları',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (userData['hobbies'] as List)
                        .map((hobby) => Chip(
                              label: Text(hobby),
                              backgroundColor: Colors.deepPurple.shade100,
                              labelStyle: const TextStyle(color: Colors.white),
                            ))
                        .toList(),
                  ),
                ],

                const SizedBox(height: 24),

                // Gönderiler
                const Text(
                  'Gönderiler',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Kullanıcının gönderileri
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('posts')
                      .where('userId', isEqualTo: userId)
                      .orderBy('createdAt', descending: true)
                      .get(),
                  builder: (context, postsSnapshot) {
                    if (postsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!postsSnapshot.hasData ||
                        postsSnapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Henüz gönderi yok'),
                        ),
                      );
                    }

                    final posts = postsSnapshot.data!.docs;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post =
                            posts[index].data() as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () {
                            // Gönderi detayına git
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(post['imageUrl']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
