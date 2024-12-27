import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductPostingScreen extends StatefulWidget {
  const ProductPostingScreen({super.key});

  @override
  State<ProductPostingScreen> createState() => _ProductPostingScreenState();
}

class _ProductPostingScreenState extends State<ProductPostingScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitProduct() async {
    if (_selectedImage == null ||
        _titleController.text.isEmpty ||
        _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Kullanıcı oturum açmamış');

      // Resmi yükle
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child('products/$fileName');
      await ref.putFile(_selectedImage!);
      final imageUrl = await ref.getDownloadURL();

      // Ürün bilgilerini kaydet
      await FirebaseFirestore.instance.collection('products').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'imageUrl': imageUrl,
        'sellerId': user.uid,
        'sellerName': user.displayName ?? 'Anonim',
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ürün başarıyla eklendi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ürün eklenirken hata oluştu: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ürün Ekle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedImage != null)
              Stack(
                children: [
                  Image.file(
                    _selectedImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => setState(() => _selectedImage = null),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galeriden Seç'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Fotoğraf Çek'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Ürün Adı',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Fiyat (TL)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitProduct,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Ürünü Yayınla'),
            ),
          ],
        ),
      ),
    );
  }
}
