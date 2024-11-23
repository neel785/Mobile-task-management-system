import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'local_notification.dart';
import 'login_screen.dart';
import 'notes_screen.dart';

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
      home: TaskManagementScreen(username: 'John Doe', toggleDarkMode: () {}),
    );
  }
}

class _TaskItem {
  final String id;
  final String name;
  final String category;
  bool isCompleted;
  DateTime lastUpdated;

  _TaskItem({
    required this.id,
    required this.name,
    required this.category,
    required this.isCompleted,
    required this.lastUpdated,
  });
}

class TaskManagementScreen extends StatefulWidget {
  final String username;
  final VoidCallback toggleDarkMode;

  TaskManagementScreen({
    required this.username,
    required this.toggleDarkMode,
  });

  @override
  _TaskManagementScreenState createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen> {
  String filterCategory = '';
  List<_TaskItem> tasks = [];
  List<CategoryItem> selectedCategoriesFilter = [];
  bool isDarkModeEnabled = false;
  bool _isMounted = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeLocalNotifications();
    _loadTasks();
  }

  void _initializeLocalNotifications() async {
    var initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> _updateTaskManuallyPrompt() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Manual Task Update'),
          content: Text('Are you sure you want to manually update tasks?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _updateAllTasksManually();
                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showCategoryFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Filter by Categories:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...buildCategoryCheckboxesForFilter(setState),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        filterCategory = selectedCategoriesFilter
                            .map((category) => category.name)
                            .join(', ');
                      });
                      Navigator.pop(context);
                    },
                    child: Text('Apply Filter'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  List<CheckboxListTile> buildCategoryCheckboxesForFilter(
      StateSetter setState) {
    return categoryItems.map((CategoryItem category) {
      return CheckboxListTile(
        title: Text(category.name),
        value: selectedCategoriesFilter.contains(category),
        onChanged: (bool? value) {
          setState(() {
            if (value != null) {
              if (value) {
                selectedCategoriesFilter.add(category);
              } else {
                selectedCategoriesFilter.remove(category);
              }
            }
          });
        },
      );
    }).toList();
  }

  Future<void> _updateTaskManually(_TaskItem task) async {
    try {
      await _firestore.collection('tasks').doc(task.id).update({
        'lastUpdated': DateTime.now(),
      });

      setState(() {
        task.lastUpdated = DateTime.now();
      });
    } catch (e) {
      print('Error updating task manually: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<_TaskItem> displayedTasks = tasks;

    if (selectedCategoriesFilter.isNotEmpty) {
      displayedTasks = tasks.where((task) {
        List<String> taskCategories = task.category.split(', ');
        return selectedCategoriesFilter.any((selectedCategory) =>
            taskCategories.contains(selectedCategory.name));
      }).toList();
    }

      return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
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
              icon: Icon(Icons.update),
              onPressed: () {
                _updateTaskManuallyPrompt();
              },
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => _openSettings(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Welcome, ${widget.username}!'),
                  SizedBox(height: 16),
                  Text(
                    'Task Categories',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _showAddTaskDialog();
                    },
                    child: SizedBox(
                      width: 210.0,
                      height: 50.0,
                      child: Center(
                        child: Text('Add Task'),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _navigateToTaskListPage(context);
                    },
                    child: SizedBox(
                      width: 210.0,
                      height: 50.0,
                      child: Center(
                        child: Text('View Tasks'),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('Filtered Tasks:'),
                  buildCategoryFilterChips(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showFilteredCategoryTasks(displayedTasks);
                        },
                        child: Text('Filtered Category Tasks'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _showAllTasks,
                        child: Text('All Tasks'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  FutureBuilder<List<_TaskItem>>(
                    future: _loadTasks(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error loading tasks: ${snapshot.error}');
                      } else {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: displayedTasks.length,
                          itemBuilder: (context, index) {
                            return TaskListTile(
                              task: displayedTasks[index],
                              onMarkChanged: _toggleMark,
                              onDeleteTask: _deleteTask,
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateAllTasksManually() async {
    try {
      for (var task in tasks) {
        await _updateTaskManually(task);
      }
    } catch (e) {
      print('Error updating tasks manually: $e');
    }
  }

  Future<void> _addTask(
      String taskName, List<CategoryItem> categories) async {
    try {
      final docRef = await _firestore.collection('tasks').add({
        'taskName': taskName,
        'category': categories.map((item) => item.name).join(', '),
        'isCompleted': true,
        'lastUpdated': DateTime.now(),
      });

      setState(() {
        tasks.insert(
          0,
          _TaskItem(
            id: docRef.id,
            name: taskName,
            category: categories.map((item) => item.name).join(', '),
            isCompleted: false,
            lastUpdated: DateTime.now(),
          ),
        );
      });

      _loadTasks();
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  void _showAddTaskDialog() {
    String newTask = '';
    List<CategoryItem> selectedCategories = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        newTask = value;
                      },
                      decoration: InputDecoration(labelText: 'Task Name'),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Select Task Categories:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 150,
                      child: ListView.builder(
                        itemCount: categoryItems.length,
                        itemBuilder: (context, index) {
                          return buildCategoryCheckboxTile(
                            categoryItems[index],
                            setState,
                            selectedCategories,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _addTask(newTask, selectedCategories);
                      },
                      child: Text('Save Task'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showFilteredCategoryTasks(List<_TaskItem> filteredTasks) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filtered Category Tasks'),
          content: Column(
            children: filteredTasks.map((task) {
              return ListTile(
                title: Text(task.name),
                subtitle: Text(task.category),
                trailing: Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) {
                    _toggleMark(task);
                    Navigator.pop(context);
                  },
                ),
              );
            }).toList(),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _toggleMark(_TaskItem task) async {
    try {
      print('Toggling mark for task: ${task.name}');
      await _firestore.collection('tasks').doc(task.id).update({
        'isCompleted': !task.isCompleted,
      });

      setState(() {
        task.isCompleted = !task.isCompleted;
      });

      showNotification(task.name, task.isCompleted);
    } catch (e) {
      print('Error toggling mark: $e');
    }
  }

  void _deleteTask(_TaskItem task) async {
    try {
      await _firestore.collection('tasks').doc(task.id).delete();

      setState(() {
        tasks.remove(task);
      });
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  void showNotification(String taskName, bool isCompleted) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      icon: '@mipmap/ic_launcher',
      importance: Importance.max,
      priority: Priority.high,
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    String notificationMessage = isCompleted
        ? 'Hooray! Task "$taskName" is completed!'
        : 'Please complete your task: "$taskName"';

    await flutterLocalNotificationsPlugin.show(
      0,
      'Task Status',
      notificationMessage,
      platformChannelSpecifics,
    );
  }

  void _showNotificationButtonPressed() {
    showNotification('Manually Triggered Task', false);
  }

  void _openSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isDarkModeEnabled = !isDarkModeEnabled;
                  });
                  Navigator.pop(context);
                },
                child: Text('Toggle Dark Mode'),
              ),
              ElevatedButton(
                onPressed: () {
                  _logOut(context);
                },
                child: Text('Logout'),
              ),
              ElevatedButton(
                onPressed: () {
                  _navigateToTaskListPage(context);
                },
                child: Text('View Tasks'),
              ),
              ElevatedButton(
                onPressed: () {
                  _navigateToNotesPage(context);
                },
                child: Text('View Notes'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildCategoryFilterChips() {
    return Wrap(
      spacing: 8.0,
      children: categoryItems.map((category) {
        return FilterChip(
          label: Text(category.name),
          selected: selectedCategoriesFilter.contains(category),
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                selectedCategoriesFilter.add(category);
              } else {
                selectedCategoriesFilter.remove(category);
              }
            });
          },
        );
      }).toList(),
    );
  }

  void _navigateToNotesPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotesScreen(),
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

  Future<void> _logOut(BuildContext context) async {
    try {
      if (_auth.currentUser != null) {
        await _auth.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      } else {
        print('User not signed in.');
      }
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

  Future<List<_TaskItem>> _loadTasks() async {
    try {
      final querySnapshot = await _firestore.collection('tasks').get();
      return querySnapshot.docs.map((doc) {
        return _TaskItem(
          id: doc.id,
          name: doc['taskName'],
          category: doc['category'],
          isCompleted: doc['isCompleted'],
          lastUpdated: doc['lastUpdated'].toDate(),
        );
      }).toList();
    } catch (e) {
      print('Error loading tasks: $e');
      return [];
    }
  }

  List<Widget> buildCategoryCheckboxes(StateSetter setState,
      List<CategoryItem> selectedCategories) {
    return categoryItems.map((CategoryItem category) {
      return ListTile(
        title: Text(category.name),
        leading: Checkbox(
          value: selectedCategories.contains(category),
          onChanged: (bool? value) {
            setState(() {
              if (value != null) {
                if (value) {
                  selectedCategories.add(category);
                } else {
                  selectedCategories.remove(category);
                }
              }
            });
          },
        ),
      );
    }).toList();
  }

  void _showAllTasks() {
    setState(() {
      selectedCategoriesFilter = [];
    });
  }

  ListTile buildCategoryCheckboxTile(CategoryItem category, StateSetter setState,
      List<CategoryItem> selectedCategories) {
    return ListTile(
      title: Text(category.name),
      leading: Checkbox(
        value: selectedCategories.contains(category),
        onChanged: (bool? value) {
          setState(() {
            if (value != null) {
              if (value) {
                selectedCategories.add(category);
              } else {
                selectedCategories.remove(category);
              }
            }
          });
        },
      ),
    );
  }
}

class TaskScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Screen'),
      ),
      body: Center(
        child: Text('This is the Task Screen'),
      ),
    );
  }
}

class TaskListTile extends StatelessWidget {
  final _TaskItem task;
  final Function(_TaskItem) onMarkChanged;
  final Function(_TaskItem) onDeleteTask;

  TaskListTile({
    required this.task,
    required this.onMarkChanged,
    required this.onDeleteTask,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(task.name),
      subtitle: Text(task.category),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: task.isCompleted,
            onChanged: (value) => onMarkChanged(task),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => onDeleteTask(task),
          ),
        ],
      ),
      onTap: () => onMarkChanged(task),
    );
  }
}

class TaskListPage extends StatelessWidget {
  final List<_TaskItem> tasks;

  TaskListPage({required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(tasks[index].name),
            subtitle: Text(tasks[index].category),
            trailing: Checkbox(
              value: tasks[index].isCompleted,
              onChanged: null,
            ),
          );
        },
      ),
    );
  }
}

class CategoryItem {
  final String name;
  final Color color;

  CategoryItem({required this.name, required this.color});
}

List<CategoryItem> categoryItems = [
  CategoryItem(name: 'Work', color: Colors.blue),
  CategoryItem(name: 'Health', color: Colors.green),
  CategoryItem(name: 'Personal', color: Colors.green),
  CategoryItem(name: 'Pay Bill', color: Colors.green),
  CategoryItem(name: 'shopping', color: Colors.green),
  CategoryItem(name: 'fitness', color: Colors.green),
  CategoryItem(name: 'study', color: Colors.green),
  CategoryItem(name: 'hobby', color: Colors.green),
];

class NoteItem {
  final String id;
  final String title;
  final String content;

  NoteItem({
    required this.id,
    required this.title,
    required this.content,
  });
}

class NotesScreen extends StatelessWidget {
  final List<NoteItem> notes = [
    NoteItem(
      id: '1',
      title: 'Note 1',
      content:
      "This is a reminder to buy groceries on the way home Don't forget to get milk, eggs, and bread. Also, check for any special discounts at the supermarket.",
    ),
    NoteItem(
        id: '2',
        title: 'Note 2',
        content:
        "Ideas for the upcoming project: brainstorm potential features, create a project timeline, and reach out to team members for collaboration."),
    NoteItem(
        id: '3',
        title: 'Note 3',
        content:
        "Personal goals for the month: complete at least two books, start a daily exercise routine, and learn a new recipe every week."),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(notes[index].title),
            subtitle: Text(notes[index].content),
          );
        },
      ),
    );
  }
}
