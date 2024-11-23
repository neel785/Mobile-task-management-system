import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'task_management_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Management App',
      home: SplashScreen(), // Start with SplashScreen
    );
  }
}

class MyAppContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      themeMode: ThemeMode.system, // Default to system settings
      home: FutureBuilder(
        // Check if the user is already authenticated
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // or loading indicator
          } else {
            // If the user is authenticated, go to the TaskManagementScreen
            return snapshot.hasData
                ? TaskManagementScreen(username: snapshot.data!.email ?? '', toggleDarkMode: () {  },)
                : LoginScreen();
          }
        },
      ),
    );
  }
}
