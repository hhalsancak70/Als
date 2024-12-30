import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hobby/Screens/ChatScreen.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Mesaj'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data?.docs
                  .where((doc) => doc.id != currentUser?.uid)
                  .toList() ??
              [];

          if (users.isEmpty) {
            return const Center(child: Text('Kullanıcı bulunamadı'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final userId = users[index].id;
              final userName = userData['username'] ?? 'Anonim';
              final userImage = userData['photoURL'];

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: userImage != null
                      ? NetworkImage(userImage)
                      : const AssetImage('Images/default_avatar.png')
                          as ImageProvider,
                ),
                title: Text(userName),
                subtitle: Text(userData['email'] ?? ''),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        otherUserId: userId,
                        otherUserName: userName,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
