import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

/// Stable Hive keys identify tasks even when the visible list is filtered.
class TaskEntry {
  const TaskEntry(this.key, this.task);
  final int key;
  final Task task;
}

class TaskStore {
  TaskStore(this.box);
  final Box<Task> box;

  List<TaskEntry> get tasks {
    final entries = box.keys.map((key) {
      return TaskEntry(key as int, box.get(key)!);
    }).toList();
    entries.sort((a, b) {
      final dateOrder = a.task.date.compareTo(b.task.date);
      return dateOrder != 0 ? dateOrder : a.key.compareTo(b.key);
    });
    return entries;
  }

  void _validate(Task task) {
    if (task.title.trim().isEmpty) {
      throw ArgumentError('Task title cannot be empty.');
    }
  }

  Future<int> add(Task task) async {
    _validate(task);
    return box.add(task.copyWith(title: task.title.trim()));
  }

  Future<void> update(int key, Task task) async {
    _validate(task);
    if (!box.containsKey(key)) throw StateError('Task no longer exists.');
    await box.put(key, task.copyWith(title: task.title.trim()));
  }

  Future<void> clear() async {
    await box.clear();
  }

  Future<void> delete(int key) => box.delete(key);
}
