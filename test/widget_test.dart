import 'package:finals_lab2/models/task.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:finals_lab2/main.dart';
import 'package:finals_lab2/services/task_store.dart';

void main() {
  testWidgets('validate, add, edit and swipe-delete a task', (tester) async {
    late Directory directory;
    late Box<Task> box;
    await tester.runAsync(() async {
      directory = await Directory.systemTemp.createTemp('daylist_widget_');
      Hive.init(directory.path);
      if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(TaskAdapter());
      box = await Hive.openBox<Task>('widget_tasks');
    });
    addTearDown(() async {
      await Hive.close();
      await directory.delete(recursive: true);
    });
    await tester.pumpWidget(TaskApp(store: TaskStore(box)));
    await tester.tap(find.text('New task'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('saveTask')));
    await tester.tap(find.byKey(const Key('saveTask')));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a task title.'), findsOneWidget);
    expect(Theme.of(tester.element(find.byType(Scaffold).first)).brightness, Brightness.dark);
    expect(find.byType(TextFormField), findsNWidgets(8));
    await tester.ensureVisible(find.byKey(const Key('taskTitle')));
    await tester.enterText(find.byKey(const Key('taskTitle')), 'Finish lab');
    await tester.runAsync(() async {
      await tester.ensureVisible(find.byKey(const Key('saveTask')));
    await tester.tap(find.byKey(const Key('saveTask')));
      await box.flush();
    });
    await tester.pumpAndSettle();
    expect(find.text('Finish lab'), findsOneWidget);
    await tester.ensureVisible(find.text('Finish lab'));
    await tester.tap(find.text('Finish lab'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('taskTitle')));
    await tester.enterText(find.byKey(const Key('taskTitle')), 'Submit lab');
    await tester.runAsync(() async {
      await tester.ensureVisible(find.byKey(const Key('saveTask')));
    await tester.tap(find.byKey(const Key('saveTask')));
      await box.flush();
    });
    await tester.pumpAndSettle();
    expect(find.text('Submit lab'), findsOneWidget);
    await tester.ensureVisible(find.byType(Dismissible));
    await tester.drag(find.byType(Dismissible), const Offset(-700, 0));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.text('Delete'));
      await box.flush();
    });
    await tester.pumpAndSettle();
    expect(find.text('Submit lab'), findsNothing);
    expect(box.isEmpty, isTrue);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
