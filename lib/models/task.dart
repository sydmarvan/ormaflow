import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

// ──────────────────────────────────────────────
//  TaskType enum
//  Represents how the task was originally captured.
// ──────────────────────────────────────────────

enum TaskType {
  manual,
  voice,
  image;

  /// Human-readable label shown in the UI.
  String get label {
    switch (this) {
      case TaskType.manual:
        return 'Manual';
      case TaskType.voice:
        return 'Voice';
      case TaskType.image:
        return 'Image';
    }
  }

  /// Icon that represents this task type.
  IconData get icon {
    switch (this) {
      case TaskType.manual:
        return Symbols.edit_note;
      case TaskType.voice:
        return Symbols.mic;
      case TaskType.image:
        return Symbols.image_search;
    }
  }
}

// ──────────────────────────────────────────────
//  Task model
// ──────────────────────────────────────────────

class Task {
  Task({
    required this.id,
    required this.title,
    this.content = '',
    required this.time,
    required this.type,
    this.isCompleted = false,
  });

  /// Unique identifier (UUID string or auto-incremented key).
  final String id;

  /// Short description / title of the task.
  final String title;

  /// Detailed content or body of the note.
  final String content;

  /// Human-readable time string, e.g. "09:00 AM".
  final String time;

  /// How the task was captured.
  final TaskType type;

  /// Whether the task has been marked done.
  bool isCompleted;

  // ── Convenience factory ──────────────────────

  /// Returns a copy of this task with the given fields replaced.
  Task copyWith({
    String? id,
    String? title,
    String? content,
    String? time,
    TaskType? type,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      time: time ?? this.time,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  String toString() =>
      'Task(id: $id, title: $title, time: $time, type: ${type.label}, '
      'isCompleted: $isCompleted)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
