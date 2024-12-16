import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hobby/Model/feed_ıtem.dart';

class PostingScreen extends StatefulWidget {
  const PostingScreen({super.key});

  @override
  _PostingScreenState createState() => _PostingScreenState();
}

class _PostingScreenState extends State<PostingScreen> {
  File? _selectedMedia;
  String? _selectedHobby; // Selected hobby
  final TextEditingController _captionController = TextEditingController();

  Future<void> _pickMedia(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedMedia = File(pickedFile.path);
      });
    }
  }

  void _submitPost() {
    if (_selectedMedia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a photo to post.'),
        ),
      );
      return;
    }
    if (_selectedHobby == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a hobby for the post.'),
        ),
      );
      return;
    }

    final newPost = FeedItem(
      user: User(
        "John Doe",
        "john_doe",
        "https://via.placeholder.com/80",
      ),
      content: "${_captionController.text}\n\nHobby: $_selectedHobby",
      imageUrl: _selectedMedia!.path,
      isLocalMedia: true,
      createdAt: DateTime.now(),
    );

    Navigator.pop(context, newPost);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
              Stack(
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(_selectedMedia!),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _selectedMedia = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickMedia(ImageSource.gallery),
                  icon: const Icon(Icons.photo),
                  label: const Text("Add Photo"),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _pickMedia(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Take Photo"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // DropdownButton for selecting hobbies
            Row(
              children: [
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text("Select Hobby"),
                    value: _selectedHobby,
                    items: ["Cinema", "Football", "Economy"]
                        .map((hobby) => DropdownMenuItem(
                              value: hobby,
                              child: Text(hobby),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedHobby = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _submitPost,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
