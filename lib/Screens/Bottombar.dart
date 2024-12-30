import 'package:flutter/material.dart';
import 'package:hobby/Screens/Blogging.dart';
import 'package:hobby/Screens/Home.dart';
import 'package:hobby/Screens/News.dart';
import 'package:hobby/Screens/Profile.dart';
import 'package:hobby/Screens/ShoppingScreen.dart';
import 'package:hobby/Screens/SettingsScreen.dart';
import 'package:hobby/Screens/MessagesScreen.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;
  bool _isExpanded = false; // Tracks the visibility of additional icons

  static final List<Widget> _pages = <Widget>[
    const HomeScreen(),
    const BloggingScreen(),
    const NewsScreen(),
    const ShoppingScreen(),
    const MessagesScreen(),
    const SettingsScreen(),
  ];

  void _onTappedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleGridView() {
    setState(() {
      _isExpanded = !_isExpanded; // Toggle visibility of additional icons
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Hobby'),
        backgroundColor: Colors.deepPurple[200],
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: const Icon(Icons.menu),
          ),
        ),
        actions: [
          // Mesajlaşma butonu
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {
              setState(() {
                _selectedIndex = 4; // MessagesScreen indeksi
              });
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.deepPurple[200],
        width: 250,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header
            Container(
              height: 75,
              color: Colors.deepPurple[200],
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.deepPurple[200],
                ),
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                child: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Menu',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            // Profile Item
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),

            // Settings Item
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                setState(() {
                  _selectedIndex = 5;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomAppBar(
        height: 60,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          color: Colors.deepPurple[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left-side icons (Home and Blog)
              if (_isExpanded) ...[
                IconButton(
                  icon: const Icon(Icons.home),
                  color: _selectedIndex == 0
                      ? Colors.deepOrange
                      : Colors.deepPurple,
                  onPressed: () => _onTappedIndex(0),
                ),
                IconButton(
                  icon: const Icon(Icons.article),
                  color: _selectedIndex == 1
                      ? Colors.deepOrange
                      : Colors.deepPurple,
                  onPressed: () => _onTappedIndex(1),
                ),
              ] else
                const SizedBox(width: 0), // Placeholder for spacing

              // Center image (circular)
              GestureDetector(
                onTap: _toggleGridView,
                child: ClipOval(
                  child: Image.asset(
                    'Images/Hobi.png', // Replace with your image path
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Right-side icons (News and Shopping)
              if (_isExpanded) ...[
                IconButton(
                  icon: const Icon(Icons.newspaper),
                  color: _selectedIndex == 2
                      ? Colors.deepOrange
                      : Colors.deepPurple,
                  onPressed: () => _onTappedIndex(2),
                ),
                IconButton(
                  icon: const Icon(Icons.shopping_bag),
                  color: _selectedIndex == 3
                      ? Colors.deepOrange
                      : Colors.deepPurple,
                  onPressed: () => _onTappedIndex(3),
                ),
              ] else
                const SizedBox(width: 0), // Placeholder for spacing
            ],
          ),
        ),
      ),
    );
  }
}
