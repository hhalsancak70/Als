import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.productId,
  });

  Future<void> _addToCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('carts')
          .doc('${productId}_${user.uid}')
          .set({
        'userId': user.uid,
        'productId': productId,
        'title': product['title'],
        'price': product['price'],
        'imageUrl': product['imageUrl'],
        'addedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Sepete ekleme hatası: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('favorites')
        .doc('${productId}_${user.uid}');

    try {
      final doc = await docRef.get();
      if (doc.exists) {
        await docRef.delete();
      } else {
        await docRef.set({
          'userId': user.uid,
          'productId': productId,
          'title': product['title'],
          'price': product['price'],
          'imageUrl': product['imageUrl'],
          'addedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Favorilere ekleme hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürün Detayı'),
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('favorites')
                .doc('${productId}_${FirebaseAuth.instance.currentUser?.uid}')
                .snapshots(),
            builder: (context, snapshot) {
              final isFavorite = snapshot.hasData && snapshot.data!.exists;
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.deepPurple,
                ),
                onPressed: _toggleFavorite,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              product['imageUrl'],
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${product['price']} TL',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product['description'] ?? 'Açıklama bulunmuyor',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: _addToCart,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Sepete Ekle'),
        ),
      ),
    );
  }
}
