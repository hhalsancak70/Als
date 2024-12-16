import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hobby/Screens/PostingScreen.dart';
import 'package:hobby/Model/feed_ıtem.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List of feed items (initial data).
  final List<FeedItem> _feedItems = [
    FeedItem(
      content: "A programmer’s favorite excuse: It works, don’t touch it!",
      user: _users[0],
      imageUrl: "https://picsum.photos/id/1000/960/540",
      likesCount: 100,
      commentsCount: 10,
      createdAt: DateTime.now().subtract(const Duration(minutes: 0)),
    ),
  ];

  // Function to add a new feed item.
  void _addNewPost(FeedItem newPost) {
    setState(() {
      _feedItems.insert(0, newPost); // Add the new post to the top of the feed.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.deepPurple[50],
          constraints: const BoxConstraints(maxWidth: 500),
          child: ListView.separated(
            itemCount: _feedItems.length,
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
            itemBuilder: (BuildContext context, int index) {
              final item = _feedItems[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AvatarImage(item.user.imageUrl),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: RichText(
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: item.user.fullName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black),
                                      ),
                                      TextSpan(
                                        text: " @${item.user.userName}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Text('· ${_getTimeDifference(item.createdAt)}',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Icon(Icons.more_horiz),
                              )
                            ],
                          ),
                          if (item.content != null) Text(item.content!),
                          if (item.imageUrl != null)
                            Container(
                              height: 250,
                              margin: const EdgeInsets.only(top: 8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: item.isLocalMedia
                                      ? FileImage(File(item.imageUrl!))
                                      : NetworkImage(item.imageUrl!)
                                          as ImageProvider,
                                ),
                              ),
                            ),
                          // Buttons below the image
                          const SizedBox(
                              height: 8), // Spacing between image and buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.favorite_border),
                                onPressed: () {
                                  // Handle like button press
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("daha kodlamadık baba")),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.comment_outlined),
                                onPressed: () {
                                  // Handle comment button press
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("daha kodlamadık baba")),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.send_outlined),
                                onPressed: () {
                                  // Handle send button press
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("daha kodlamadık baba")),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final FeedItem? newPost = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PostingScreen(),
            ),
          );

          if (newPost != null) {
            _addNewPost(newPost);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  final String url;
  const _AvatarImage(this.url);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: NetworkImage(url),
        ),
      ),
    );
  }
}

// Dummy user list for testing purposes.
final List<User> _users = [
  User(
    "John Doe",
    "john_doe",
    "https://picsum.photos/id/1062/80/80",
  ),
  User(
    "Jane Doe",
    "jane_doe",
    "https://picsum.photos/id/1066/80/80",
  ),
];
