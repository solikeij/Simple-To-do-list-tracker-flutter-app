import 'package:hive/hive.dart';
import 'models/task.dart';

// Equivalent to the reference sample's boxPersons, typed for our task model.
late Box<Task> boxTasks;

/// Converts the earlier map records before opening the same box as Box<Task>.
/// Existing keys are retained. Already converted records are left unchanged,
/// allowing conversion to resume if a previous startup was interrupted.
Future<Box<Task>> openTaskBox({String name = 'taskBox'}) async {
  final legacy = await Hive.openBox<dynamic>(name);
  try {
    // Validate all records before writing any changes.
    final converted = <int, Task>{};
    for (final key in legacy.keys) {
      if (key is! int) throw StateError('Unexpected task key: $key');
      final value = legacy.get(key);
      if (value is Task) continue;
      if (value is! Map) throw StateError('Unrecognized saved task at $key');
      converted[key] = Task.fromMap(value);
    }
    if (converted.isNotEmpty) await legacy.putAll(converted);
    await legacy.flush();
  } finally {
    await legacy.close();
  }
  return Hive.openBox<Task>(name);
}
