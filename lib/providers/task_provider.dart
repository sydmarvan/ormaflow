import 'package:flutter/foundation.dart';
import '../models/task.dart';

// ──────────────────────────────────────────────
//  TaskProvider
//  Single source of truth for all task state.
//  Consumed via Provider.of<TaskProvider>(context)
//  or context.watch<TaskProvider>() / context.read<TaskProvider>().
// ──────────────────────────────────────────────

class TaskProvider extends ChangeNotifier {
  TaskProvider() {
    _tasks = _seedTasks();
  }

  // ── Internal state ───────────────────────────

  late List<Task> _tasks;
  final List<Task> _trashTasks = [];

  // ── Public read-only accessors ────────────────

  /// All active tasks (ordered by insertion / creation time).
  List<Task> get tasks => List.unmodifiable(_tasks);

  /// All deleted tasks in the trash.
  List<Task> get trashTasks => List.unmodifiable(_trashTasks);

  /// Only tasks that are not yet completed.
  List<Task> get pendingTasks =>
      _tasks.where((t) => !t.isCompleted).toList();

  /// Only tasks that have been marked as done.
  List<Task> get completedTasks =>
      _tasks.where((t) => t.isCompleted).toList();

  /// Number of pending (incomplete) tasks.
  int get pendingCount => pendingTasks.length;

  // ── Mutations ─────────────────────────────────

  /// Add a new [task] to the list.
  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  /// Toggle the [isCompleted] state of the task with [id].
  void toggleTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    _tasks[index].isCompleted = !_tasks[index].isCompleted;
    notifyListeners();
  }

  /// Remove the task with [id] from the list completely.
  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _trashTasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  /// Move task to trash
  void moveToTrash(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _trashTasks.add(_tasks[index]);
      _tasks.removeAt(index);
      notifyListeners();
    }
  }

  /// Restore task from trash
  void restoreTask(String id) {
    final index = _trashTasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks.add(_trashTasks[index]);
      _trashTasks.removeAt(index);
      notifyListeners();
    }
  }

  /// Replace all fields of an existing task (matched by id).
  void updateTask(Task updated) {
    final index = _tasks.indexWhere((t) => t.id == updated.id);
    if (index == -1) return;
    _tasks[index] = updated;
    notifyListeners();
  }

  /// Remove all completed tasks.
  void clearCompleted() {
    _tasks.removeWhere((t) => t.isCompleted);
    notifyListeners();
  }

  // ── Seed data ─────────────────────────────────

  /// Returns the 4 placeholder tasks shown in the design screenshot.
  static List<Task> _seedTasks() {
    return [
      Task(
        id: 'task_001',
        title: 'Buy ingredients for Pizza',
        time: '09:00 AM',
        type: TaskType.manual,
      ),
      Task(
        id: 'task_002',
        title: 'Pay the electricity bill',
        time: '11:30 AM',
        type: TaskType.manual,
      ),
      Task(
        id: 'task_003',
        title: 'Note: Idea for Mom\'s birthday gift',
        time: '02:15 PM',
        type: TaskType.voice,
      ),
      Task(
        id: 'task_004',
        title: 'Scan recipe from magazine',
        time: '04:00 PM',
        type: TaskType.image,
      ),
    ];
  }
}
