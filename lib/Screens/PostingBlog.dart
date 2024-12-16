import 'package:hobby/Screens/Blogging.dart';
import 'package:flutter/material.dart';

class PostingBlog extends StatefulWidget {
  const PostingBlog({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PostingBlogState createState() => _PostingBlogState();
}

class _PostingBlogState extends State<PostingBlog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  void _submitPost() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in both the title and content')),
      );
      return;
    }

    final newPost = Article(
      title: _titleController.text,
      content: _contentController.text,
      author: 'hhalsancak',
      postedOn: 'just now',
      isLocalMedia: true,
    );

    Navigator.pop(context, newPost);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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




/*import 'package:yeninesil/Screens/Blogging.dart';
import 'package:flutter/material.dart';

class PostingBlog extends StatefulWidget {
  const PostingBlog({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _PostingBlogState createState() => _PostingBlogState();
}

class _PostingBlogState extends State<PostingBlog> {
  final TextEditingController _captionController = TextEditingController();

  void _submitPost() {
    final newPost = Article(
      content: "Eğer tıklamayı halledersek bu gözükecek...",
      isLocalMedia: true,
      title: _captionController.text,
      author: 'hhalsancak',
      postedOn: 'just now',
    );
    Navigator.pop(context, newPost);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[300],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Start typing your blog below:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _captionController,
              maxLines: 15,
              decoration: InputDecoration(
                hintText: "Let's start blogging",
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
