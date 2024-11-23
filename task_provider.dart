// task_provider.dart
import 'package:flutter/foundation.dart';
import 'package:untitled2/task_model.dart';

class TaskProvider extends ChangeNotifier {
  List<TaskModel> tasks = [];

  void addTask(TaskModel task) {
    tasks.add(task);
    notifyListeners();
  }

  void updateTaskCompletion(int index, bool isCompleted) {
    tasks[index].isCompleted = isCompleted;
    notifyListeners();
  }
}
