import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'task_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: TaskManagementScreen(username: 'John Doe'),
    );
  }
}

class TaskManagementScreen extends StatefulWidget {
  final String username;

  TaskManagementScreen({required this.username});

  @override
  _TaskManagementScreenState createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen> {
  bool isDarkModeEnabled = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Management'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logOut(context),
          ),
          Switch(
            value: isDarkModeEnabled,
            onChanged: (value) {
              setState(() {
                isDarkModeEnabled = value;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () => _navigateToTaskListPage(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome, ${widget.username}!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Task Categories',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _showAddTaskDialog(context),
                child: Text('Add Task'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _navigateToTaskListPage(context),
                child: Text('View Tasks'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToTaskListPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskListPage(tasks: tasks),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    String newTask = '';
    String selectedCategory = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  newTask = value;
                },
                decoration: InputDecoration(labelText: 'Task Name'),
              ),
              SizedBox(height: 16),
              Text(
                'Select Task Category:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ListTile(
                title: Text('Work'),
                onTap: () {
                  setState(() {
                    selectedCategory = 'Work';
                  });
                  Navigator.pop(context);
                  _addTask(newTask, selectedCategory);
                },
              ),
              ListTile(
                title: Text('Health'),
                onTap: () {
                  setState(() {
                    selectedCategory = 'Health';
                  });
                  Navigator.pop(context);
                  _addTask(newTask, selectedCategory);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _addTask(String newTask, String selectedCategory) {
    setState(() {
      tasks.add('$newTask - $selectedCategory');
    });

    // Store task in Cloud Firestore
    _firestore.collection('tasks').add({
      'taskName': newTask,
      'category': selectedCategory,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Store tasks locally
    _saveTasksLocally();
  }

  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedTasks = prefs.getStringList('tasks');
    if (storedTasks != null) {
      setState(() {
        tasks = storedTasks;
      });
    }
  }

  void _saveTasksLocally() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('tasks', tasks);
  }

  Future<void> _logOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pop(context);
    } catch (e) {
      print('Error during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
