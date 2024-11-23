// task_item.dart
import 'package:flutter/material.dart';
import 'task_model.dart';

class TaskItem extends StatefulWidget {
  final TaskModel task;
  final Function(String) onTaskChanged;
  final Function(bool) onTaskCompleted;

  TaskItem({
    required this.task,
    required this.onTaskChanged,
    required this.onTaskCompleted,
  });

  @override
  _TaskItemState createState() => _TaskItemState();

  void onCompleted(isCompleted) {}
}

class _TaskItemState extends State<TaskItem> {
  bool isSelected = false;
  bool isAlertDialogOpen = false; // New variable to track dialog state

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDarkMode ? Colors.grey[800] : null,
      child: ListTile(
        title: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: isAlertDialogOpen
                  ? null // Disable checkbox when dialog is open
                  : (value) {
                setState(() {
                  isSelected = value ?? false;
                  widget.onTaskCompleted(isSelected);
                });
              },
            ),
            Expanded(
              child: Text(
                widget.task.taskName,
                style: TextStyle(
                  color: _getTextColor(widget.task.category, isDarkMode),
                  fontWeight: _getFontWeight(widget.task.category),
                ),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit, color: isDarkMode ? Colors.white : null),
          onPressed: () {
            _showEditDialog(context);
          },
        ),
      ),
    );
  }

  Color _getTextColor(String category, bool isDarkMode) {
    if (isCategorySelected(category)) {
      return isDarkMode ? Colors.green : Colors.blue; // Change colors as needed
    } else {
      return isDarkMode ? Colors.white : Colors.black;
    }
  }

  FontWeight _getFontWeight(String category) {
    if (isCategorySelected(category)) {
      return FontWeight.bold;
    } else {
      return FontWeight.normal;
    }
  }

  bool isCategorySelected(String category) {
    // Specify your selected categories here (work, health, personal, paybill)
    List<String> selectedCategories = ['work', 'health', 'personal', 'paybill'];
    return selectedCategories.contains(category);
  }

  void _showEditDialog(BuildContext context) {
    isAlertDialogOpen = true; // Set dialog state to open

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Task'),
          // ... rest of your dialog content
          actions: [
            ElevatedButton(
              onPressed: () {
                // Handle your edit logic here
                isAlertDialogOpen = false; // Set dialog state to closed
                Navigator.pop(context);
              },
              child: Text('Save Changes'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      isAlertDialogOpen = false; // Set dialog state to closed when complete
    });
  }
}
