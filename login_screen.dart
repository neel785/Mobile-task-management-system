import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'task_management_screen.dart';
import 'task_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/logo.png', // Replace with your logo image path
                    height: 80, // Adjust the height as needed
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.green), // Change label text color
                    ),
                    style: TextStyle(color: Colors.blue), // Change input text color
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.green), // Change label text color
                    ),
                    style: TextStyle(color: Colors.black), // Change input text color
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _login(context),
                    child: Text('Login'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue, // Set your desired color here
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NextPage(), // Replace with your desired next page
                        ),
                      );
                    },
                    child: Text('Next Page'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.orange, // Set your desired color here
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _login(BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TaskManagementScreen(username: 'John Doe', toggleDarkMode: () { })),
      );
    } catch (e) {
      print('Login failed: $e');
      // You can show an error message to the user if needed
    }
  }
}

class NextPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Next Page'),
      ),
      body: Center(
        child: Text('This is the next page.'),
      ),
    );
  }
}

