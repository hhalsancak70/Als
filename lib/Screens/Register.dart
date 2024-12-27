import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hobby/Screens/SignIn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        // Kullanıcı oluştur
        final UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Kullanıcı profilini güncelle
        await userCredential.user?.updateDisplayName(_nameController.text);

        // Firestore'da kullanıcı dokümanı oluştur
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': _nameController.text,
          'username': _usernameController.text,
          'email': _emailController.text,
          'createdAt': FieldValue.serverTimestamp(),
          'photoURL': null,
          'hobbies': [],
          'bio': '',
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kayıt başarılı!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignIn()),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kayıt başarısız: ${e.toString()}')),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            foregroundColor: Colors.white,
            title: const Text('Hobi dünyasına katıl'),
            backgroundColor: Colors.deepPurple,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen adınızı girin';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Ad Soyad',
                        prefixIcon: const Icon(Icons.person),
                        labelStyle: const TextStyle(color: Colors.deepPurple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.deepPurple),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen kullanıcı adı girin';
                        }
                        if (value.contains(' ')) {
                          return 'Kullanıcı adı boşluk içeremez';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Kullanıcı Adı',
                        prefixIcon: const Icon(Icons.alternate_email),
                        labelStyle: const TextStyle(color: Colors.deepPurple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.deepPurple),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen email adresinizi girin';
                        }
                        final bool emailValid = RegExp(
                          r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}",
                        ).hasMatch(value);
                        if (!emailValid) {
                          return 'Geçerli bir email adresi girin';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email),
                        labelStyle: const TextStyle(color: Colors.deepPurple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.deepPurple),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen şifrenizi girin';
                        }
                        if (value.length < 6) {
                          return 'Şifre en az 6 karakter olmalıdır';
                        }
                        return null;
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        prefixIcon: const Icon(Icons.lock),
                        labelStyle: const TextStyle(color: Colors.deepPurple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.deepPurple),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen şifrenizi tekrar girin';
                        }
                        if (value != _passwordController.text) {
                          return 'Şifreler eşleşmiyor';
                        }
                        return null;
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Şifre Tekrar',
                        prefixIcon: const Icon(Icons.lock_outline),
                        labelStyle: const TextStyle(color: Colors.deepPurple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.deepPurple),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: Text(
                        _isLoading ? 'Kaydediliyor...' : 'Kayıt Ol',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
