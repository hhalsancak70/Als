import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _currentUser = FirebaseAuth.instance.currentUser;
  late String _chatId;

  @override
  void initState() {
    super.initState();
    _chatId = _getChatId(_currentUser!.uid, widget.otherUserId);
  }

  String _getChatId(String uid1, String uid2) {
    final ids = [uid1, uid2];
    ids.sort();
    return ids.join('_');
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text;
    _messageController.clear();

    try {
      // Gönderen kullanıcı bilgilerini al
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();
      final userData = userDoc.data();

      // Alıcı kullanıcının FCM tokenını al
      final recipientDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.otherUserId)
          .get();
      final recipientData = recipientDoc.data();
      final recipientToken = recipientData?['fcmToken'];

      final chatRef =
          FirebaseFirestore.instance.collection('chats').doc(_chatId);
      final messageRef = chatRef.collection('messages').doc();

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final chatDoc = await transaction.get(chatRef);

        if (!chatDoc.exists) {
          transaction.set(chatRef, {
            'participants': [_currentUser.uid, widget.otherUserId],
            'lastMessage': message,
            'lastMessageTime': FieldValue.serverTimestamp(),
            'unreadCount': 1,
          });
        } else {
          transaction.update(chatRef, {
            'lastMessage': message,
            'lastMessageTime': FieldValue.serverTimestamp(),
            'unreadCount': FieldValue.increment(1),
          });
        }

        transaction.set(messageRef, {
          'senderId': _currentUser.uid,
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });
      });

      // Bildirim dokümanı oluştur
      await FirebaseFirestore.instance.collection('notifications').add({
        'recipientId': widget.otherUserId,
        'senderId': _currentUser.uid,
        'senderName': userData?['username'] ?? 'Anonim',
        'type': 'message',
        'title': 'Yeni Mesaj',
        'body': message,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
        'fcmToken': recipientToken, // FCM token'ı ekle
        'chatId': _chatId, // Sohbet ID'sini ekle
      });
    } catch (e) {
      print('Mesaj gönderme hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mesaj gönderilemedi')),
        );
      }
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(_chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        messages[index].data() as Map<String, dynamic>;
                    final isMe = message['senderId'] == _currentUser?.uid;

                    final timestamp = message['timestamp'];
                    final messageTime = timestamp is Timestamp
                        ? timestamp.toDate()
                        : DateTime.now();

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.deepPurple : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['message'],
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              _formatTime(messageTime),
                              style: TextStyle(
                                fontSize: 12,
                                color: isMe ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Mesaj yazın...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
