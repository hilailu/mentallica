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
      _nameController.text = userDoc.get('name') ?? 'User';
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
        const SnackBar(content: Text("Profile updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $e")),
      );
    }
  }

  Future<void> _deleteProfile() async {
    try {
      // Delete user data from Firestore
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).delete();

      // Delete user from Firebase Auth
      await user!.delete();

      // Sign out the user and navigate to login page
      await Auth().signOut();

      // Navigate to login/registration screen
      Navigator.pushReplacementNamed(context, '/login');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting profile: $e")),
      );
    }
  }

  Future<void> signOut() async {
    await Auth().signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _userId() {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: _deleteProfile,
    style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Delete Profile"),
            ),
            ElevatedButton(
              onPressed: _updateUserDetails,
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
        style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
      child: const Text("Sign out"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _userId(),
            const SizedBox(height: 20),
            _signOutButton(),
          ],
        ),
      ),
    );
  }
}
