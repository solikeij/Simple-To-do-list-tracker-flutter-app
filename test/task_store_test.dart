import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:finals_lab2/models/task.dart';
import 'package:finals_lab2/services/task_store.dart';

void main() {
  test('CRUD changes survive closing and reopening the box', () async {
    final directory = await Directory.systemTemp.createTemp('daylist_test_');
    Hive.init(directory.path);
      if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(TaskAdapter());
    try {
      var box = await Hive.openBox<Task>('tasks');
      var store = TaskStore(box);
      final key = await store.add(Task(title: 'Read notes', date: DateTime(2026, 10, 5), description: 'description value', category: 'category value', priority: 'priority value', time: 'time value', location: 'location value', reminderNote: 'reminderNote value', tags: 'tags value'));
      final secondKey = await store.add(Task(title: 'Keep this task', date: DateTime(2026, 10, 6)));
      await box.close();
      box = await Hive.openBox<Task>('tasks');
      store = TaskStore(box);
      expect(store.tasks.first.task.title, 'Read notes');
      expect(store.tasks.first.task.description, 'description value');
      expect(store.tasks.first.task.category, 'category value');
      expect(store.tasks.first.task.priority, 'priority value');
      expect(store.tasks.first.task.time, 'time value');
      expect(store.tasks.first.task.location, 'location value');
      expect(store.tasks.first.task.reminderNote, 'reminderNote value');
      expect(store.tasks.first.task.tags, 'tags value');
      final legacy = Task.fromMap({'title': 'Old task', 'date': '2026-10-05T00:00:00.000'});
      expect(legacy.description, isEmpty);
      expect(store.tasks.first.task.copyWith(isCompleted: true).tags, 'tags value');
      await store.update(key, Task(title: 'Review notes', date: DateTime(2026, 10, 7), isCompleted: true));
      await box.close();
      box = await Hive.openBox<Task>('tasks');
      store = TaskStore(box);
      final edited = store.tasks.singleWhere((entry) => entry.key == key).task;
      expect(edited.title, 'Review notes');
      expect(edited.date, DateTime(2026, 10, 7));
      expect(edited.isCompleted, isTrue);
      await store.delete(key);
      await box.close();
      box = await Hive.openBox<Task>('tasks');
      store = TaskStore(box);
      expect(store.tasks.single.key, secondKey);
      await store.clear();
      await box.close();
      box = await Hive.openBox<Task>('tasks');
      store = TaskStore(box);
      expect(store.tasks, isEmpty);
      await expectLater(store.add(Task(title: '  ', date: DateTime(2026))), throwsArgumentError);
    } finally {
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });
}
