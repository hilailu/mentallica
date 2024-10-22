import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mentallica/tests/tests_page.dart';
import 'articles/articles_page.dart';
import 'contacts/contacts_page.dart';
import 'firebase_options.dart';

import 'auth/profile_page.dart';
import 'home_page.dart';
import 'journal/calendar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mentallica',
      theme: ThemeData(
        primaryColor: Colors.white,
        fontFamily: GoogleFonts.nunito().fontFamily,
        colorScheme: ColorScheme.fromSeed(
            background: Colors.white,
            seedColor: Colors.white),
        useMaterial3: true,
      ),
      //home: const MainPage(),
      //home: const Home(),
      home: const AppMainPage(),
    );
  }
}


class AppMainPage extends StatefulWidget {
  const AppMainPage({super.key});

  @override
  _AppMainPageState createState() => _AppMainPageState();
}

class _AppMainPageState extends State<AppMainPage> {
  int _currentIndex = 0; // Track the current selected tab

  // List of pages for each tab
  final List<Widget> _pages = [
    HomePage(), // Page 0
    const CalendarPage(), // Page 1
    const ContactsPage(), // Page 2
    const ProfilePage(), // Page 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Display the currently selected page
      body: _pages[_currentIndex],

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Set the currently selected index
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the index when an item is clicked
          });
        },
        items: const [
          BottomNavigationBarItem(
            backgroundColor: Color(0xFF8BACA5),
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            backgroundColor: Color(0xFF8BACA5),
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            backgroundColor: Color(0xFF8BACA5),
            icon: Icon(Icons.map),
            label: 'Doctors',
          ),
          BottomNavigationBarItem(
            backgroundColor: Color(0xFF8BACA5),
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
/*
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const CalendarPage(),
    const TestsPage(),
    const ArticlesPage(),
    const ContactsPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentallica'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Tests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Articles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}*/