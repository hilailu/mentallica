import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _emailController.text = user!.email ?? '';
      _fetchUserName();
    }
  }

  Future<void> _fetchUserName() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (userDoc.exists) {
      _nameController.text = userDoc.get('name') ?? 'Пользователь';
    }
  }

  Future<void> _updateUserDetails() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'name': _nameController.text,
        'email': _emailController.text,
      });

      await user!.updateEmail(_emailController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Профиль успешно обновлен.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка при обновлении профиля: $e")),
      );
    }
  }

  Future<void> _deleteProfile() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).delete();
      await user!.delete();
      await Auth().signOut();

      Navigator.pushReplacementNamed(context, '/login');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Профиль успешно удален.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка при удалении профиля: $e")),
      );
    }
  }

  Future<void> signOut() async {
    await Auth().signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _userId() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Имя',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            prefixIcon: const Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Почта',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            prefixIcon: const Icon(Icons.email),
          ),
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: _deleteProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(Icons.delete, color: Colors.white),
              label: const Text("Удалить профиль"),
            ),
            ElevatedButton.icon(
              onPressed: _updateUserDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text("Сохранить"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _signOutButton() {
    return ElevatedButton.icon(
      onPressed: signOut,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      icon: const Icon(Icons.logout, color: Colors.white),
      label: const Text("Выйти"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Профиль",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _userId(),
              const SizedBox(height: 30),
              _signOutButton(),
            ],
          ),
        ),
      ),
    );
  }
}
