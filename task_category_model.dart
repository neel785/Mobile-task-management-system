import "package:flutter/material.dart";

class TaskCategory {
  final String id;
  final String name;

  TaskCategory({required this.id, required this.name, required void Function() onRemoveCategory});

  // Factory method to create a TaskCategory instance from a map
  factory TaskCategory.fromMap(Map<String, dynamic> map) {
    return TaskCategory(
      id: map['id'],
      name: map['name'], onRemoveCategory: () {  },
    );
  }

  // Method to convert TaskCategory instance to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}
