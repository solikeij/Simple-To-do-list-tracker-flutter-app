import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/home_screen.dart';
import 'boxes.dart';
import 'models/task.dart';
import 'services/task_store.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    boxTasks = await openTaskBox();
    runApp(TaskApp(store: TaskStore(boxTasks)));
  } catch (_) {
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'We could not open your saved tasks. Please close the app '
                'and try again. Your saved data has not been cleared.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    ));
  }
}

class TaskApp extends StatelessWidget {
  const TaskApp({super.key, required this.store});
  final TaskStore store;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'De Matta Finals Lab 2',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: HomeScreen(store: store),
      );
}
