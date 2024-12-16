import 'package:flutter/material.dart';
import 'package:hobby/Model/new_model.dart';

class NewsDetail extends StatelessWidget {
  final NewsModel newsModel;
  const NewsDetail({super.key, required this.newsModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Details'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            // Article Title
            Text(
              newsModel.title ?? 'Title not available',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Author
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "By ${newsModel.author ?? 'Unknown Author'}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Header Image
            if (newsModel.urlToImage != null &&
                newsModel.urlToImage!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  newsModel.urlToImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              )
            else
              const SizedBox.shrink(),
            const SizedBox(height: 10),

            // Interactive Elements (Likes, Comments, Share)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.thumb_up, color: Colors.deepPurple),
                      onPressed: () {
                        // Add like functionality here
                      },
                    ),
                    const Text("34 Likes"),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.comment, color: Colors.deepPurple),
                      onPressed: () {
                        // Add comments functionality here
                      },
                    ),
                    const Text("8 Comments"),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.deepPurple),
                  onPressed: () {
                    // Add share functionality here
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Article Content
            if (newsModel.content != null && newsModel.content!.isNotEmpty)
              Text(
                newsModel.content!,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
              )
            else
              const Text(
                'Content not available.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            const SizedBox(height: 10),

            // Article Description
            if (newsModel.description != null &&
                newsModel.description!.isNotEmpty)
              Text(
                newsModel.description!,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
              )
            else
              const Text(
                'Description not available.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
          ],
        ),
      ),
    );
  }
}
