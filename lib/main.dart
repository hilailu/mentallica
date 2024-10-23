import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    const CalendarPage(),
    const ContactsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
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