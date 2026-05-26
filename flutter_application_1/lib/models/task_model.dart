import 'package:flutter_application_1/models/task_enums.dart';

class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.categoryId,
    required this.dueDate,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final String categoryId;
  final DateTime dueDate;
  final DateTime createdAt;

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: (json['_id'] ?? json['id']).toString(),
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      status: TaskStatus.fromApi(json['status'] as String? ?? 'PENDING'),
      priority: TaskPriority.fromApi(json['priority'] as String? ?? 'MEDIUM'),
      categoryId: (json['categoryId'] ?? '').toString(),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'].toString())
          : DateTime.now().add(const Duration(days: 7)),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toApiJson() {
    return {
      'title': title,
      if (description.isNotEmpty) 'description': description,
      'status': status.apiValue,
      'priority': priority.apiValue,
      'categoryId': categoryId,
      'dueDate': dueDate.toIso8601String(),
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? categoryId,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
