import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:finals_lab2/boxes.dart';
import 'package:finals_lab2/models/task.dart';

void main() {
  test('old task maps migrate with keys and details preserved', () async {
    final directory = await Directory.systemTemp.createTemp('task_migration_');
    Hive.init(directory.path);
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(TaskAdapter());
    try {
      final oldBox = await Hive.openBox<dynamic>('migration');
      await oldBox.put(7, {
        'title': 'Old task', 'date': '2026-10-05T00:00:00.000',
        'description': 'Keep my notes', 'isCompleted': true,
      });
      await oldBox.close();
      var box = await openTaskBox(name: 'migration');
      expect(box.get(7)!.description, 'Keep my notes');
      expect(box.get(7)!.tags, isEmpty);
      expect(box.get(7)!.isCompleted, isTrue);
      await box.close();
      box = await openTaskBox(name: 'migration');
      expect(box.length, 1);
      expect(box.get(7)!.title, 'Old task');
    } finally {
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });
}
