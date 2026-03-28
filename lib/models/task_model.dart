import 'tag_model.dart';

class Task {
  final int? id;
  final String title;
  final String? description;
  final bool isDone;
  final String? deadline;
  final String? createdAt;
  final String? updatedAt;
  final List<Tag> tags;

  Task({
    this.id,
    required this.title,
    this.description,
    this.isDone = false,
    this.deadline,
    this.createdAt,
    this.updatedAt,
    this.tags = const [],
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isDone: json['isDone'] ?? false,
      deadline: json['deadline'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      tags: json['tags'] != null
          ? (json['tags'] as List).map((t) => Tag.fromJson(t)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isDone': isDone,
      'deadline': deadline,
      'tags': tags.map((t) => t.toJson()).toList(),
    };
  }
}