// task_list_page.dart
import 'package:flutter/material.dart';

class TaskListPage extends StatelessWidget {
  final List<String> tasks;

  TaskListPage({required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          // Split the task string to get the task name and category
          List<String> taskInfo = tasks[index].split(' - ');
          String taskName = taskInfo[0];
          String category = taskInfo.length > 1 ? taskInfo[1] : 'No Category';

          return ListTile(
            title: Text(taskName),
            subtitle: Text('Category: $category'),
          );
        },
      ),
    );
  }
}
