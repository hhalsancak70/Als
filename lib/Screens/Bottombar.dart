import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hobby/Screens/Blogging.dart';
import 'package:hobby/Screens/Home.dart';
import 'package:hobby/Screens/Intro.dart';
import 'package:hobby/Screens/News.dart';
import 'package:hobby/Screens/Shopping.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    ShoppingScreen(),
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
        title: const Text('H0B1'),
        backgroundColor: Colors.deepPurple[50],
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: const Icon(Icons.menu),
          ),
        ),
        actions: [
          // Add the logout button to the top right
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.deepPurple),
            onPressed: () async {
              // Clear Firebase session (sign out)
              await FirebaseAuth.instance.signOut();

              // Clear stored credentials from SharedPreferences
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              await prefs.remove('email');
              await prefs.remove('password');
              await prefs.remove('remember_me');

              // Navigate to the SignIn or IntroPage
              if (!mounted) return; // Ensures context is still valid
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const IntroPage()),
              );
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
            // Smaller Drawer Header with reduced space
            Container(
              height: 75, // Adjust the height to your preference
              color: Colors.deepPurple[200],
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.deepPurple[200],
                ),
                margin: EdgeInsets
                    .zero, // Remove any margin around the DrawerHeader
                padding: EdgeInsets.zero, // Adjust padding as needed
                child: const Align(
                  alignment: Alignment.center, // Align text to the bottom-left
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
                // Handle Profile navigation here
                Navigator.pop(context);
              },
            ),
            // Hobbies Item with Expansion
            ExpansionTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Hobbies'),
              children: [
                ListTile(
                  title: const Text('All Hobbies'),
                  onTap: () {
                    // Handle All Hobbies navigation
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Football'),
                  onTap: () {
                    // Handle Football navigation
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Cinema'),
                  onTap: () {
                    // Handle Cinema navigation
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Economy'),
                  onTap: () {
                    // Handle Economy navigation
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            // Settings Item
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // Handle Settings navigation here
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



/*import 'package:flutter/material.dart';
import 'package:hobby/Screens/Blogging.dart';
import 'package:hobby/Screens/Home.dart';
import 'package:hobby/Screens/News.dart';
import 'package:hobby/Screens/Shopping.dart';

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
    ShoppingScreen(),
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
        title: const Text('H0B1'),
        backgroundColor: Colors.deepPurple[50],
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: const Icon(Icons.menu),
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.deepPurple[200],
        width: 250,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Smaller Drawer Header with reduced space
            Container(
              height: 75, // Adjust the height to your preference
              color: Colors.deepPurple[200],
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.deepPurple[200],
                ),
                margin: EdgeInsets
                    .zero, // Remove any margin around the DrawerHeader
                padding: EdgeInsets.zero, // Adjust padding as needed
                child: const Align(
                  alignment: Alignment.center, // Align text to the bottom-left
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
                // Handle Profile navigation here
                Navigator.pop(context);
              },
            ),
            // Hobbies Item with Expansion
            ExpansionTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Hobbies'),
              children: [
                ListTile(
                  title: const Text('All Hobbies'),
                  onTap: () {
                    // Handle All Hobbies navigation
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Football'),
                  onTap: () {
                    // Handle Football navigation
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Cinema'),
                  onTap: () {
                    // Handle Cinema navigation
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Economy'),
                  onTap: () {
                    // Handle Economy navigation
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            // Settings Item
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // Handle Settings navigation here
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
*/