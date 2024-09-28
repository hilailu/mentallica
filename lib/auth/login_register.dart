import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool visible = false;

  String role = "Patient";
  String? errorMessage = "";
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(email: _controllerEmail.text, password: _controllerPassword.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(email: _controllerEmail.text, password: _controllerPassword.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _entryField(String title, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: title,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _errorMessage() {
    return errorMessage == ""
        ? const SizedBox.shrink()
        : Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        errorMessage!,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: isLogin ? signIn : signUp,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        isLogin ? "Login" : "Register",
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
        });
      },
      child: Text(
        isLogin ? "Register instead" : "Login instead",
        style: const TextStyle(fontSize: 14, color: Colors.blueAccent),
      ),
    );
  }

  Widget _roleSelection() {
    return Visibility(
      visible: !isLogin,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: ListTile(
              title: const Text('Patient', style: TextStyle(fontSize: 20)),
              leading: Radio<String>(
                value: 'Patient',
                groupValue: role,
                onChanged: (String? value) {
                  setState(() {
                    role = value!;
                  });
                },
              ),
            ),
          ),
          Flexible(
            child: ListTile(
              title: const Text('Doctor', style: TextStyle(fontSize: 18)),
              leading: Radio<String>(
                value: 'Doctor',
                groupValue: role,
                onChanged: (String? value) {
                  setState(() {
                    role = value!;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void route() {
    User? user = FirebaseAuth.instance.currentUser;
    var kk = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        if (documentSnapshot.get('role') == "Doctor") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>  HomePage(),
            ),
          );
        }else{
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>  HomePage(),
            ),
          );
        }
      } else {
      setState(() {
        errorMessage = "Document doesn't exist";
      });
      }
    });
  }

  void signIn() async {
    try {
      Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      route();
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  void signUp() async {
    const CircularProgressIndicator();
    await Auth()
          .createUserWithEmailAndPassword(email: _controllerEmail.text, password: _controllerPassword.text)
          .then((value) => {postDetailsToFirestore()})
          .catchError((e) { errorMessage = e;});
  }

  void postDetailsToFirestore() async {
    var user = Auth().currentUser;
    CollectionReference ref = FirebaseFirestore.instance.collection('users');
    ref.doc(user!.uid).set({'email': _controllerEmail.text, 'role': role});
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 100,
                child: Icon(isLogin ? Icons.login : Icons.person_add_alt_1, size: 75),
              ),
              const SizedBox(height: 20),
              Text(
                isLogin ? "Login" : "Register",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _roleSelection(),
              _entryField("Email", _controllerEmail),
              _entryField("Password", _controllerPassword, isPassword: true),
              _errorMessage(),
              const SizedBox(height: 10),
              _submitButton(),
              _loginOrRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }
}
