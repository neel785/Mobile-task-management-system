// task_model.dart

class TaskModel {
  final String taskName;
  bool isCompleted;
  String category;

  TaskModel({
    required this.taskName,
    this.isCompleted = false,
    required this.category,
  });
}