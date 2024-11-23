// task_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_item.dart';
import 'task_model.dart';
import 'task_provider.dart';



class TaskScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
        centerTitle: true,
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return ListView.builder(
            itemCount: taskProvider.tasks.length,
            itemBuilder: (context, index) {
              return TaskItem(
                task: taskProvider.tasks[index],
                onTaskChanged: (newTaskName) {
                  // Handle task name changes here if needed
                },
                onTaskCompleted: (isCompleted) {
                  // Handle task completion changes here if needed
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Provider.of<TaskProvider>(context, listen: false).addTask(TaskModel(taskName: 'New Task', category: ''));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
