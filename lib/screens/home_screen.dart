import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/task_store.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../widgets/task_form.dart';

enum TaskFilter { all, active, completed }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.store});
  final TaskStore store;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TaskFilter _filter = TaskFilter.all;
  final Set<int> _busyKeys = {};

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _openForm([TaskEntry? entry]) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TaskForm(store: widget.store, entry: entry),
    );
    if (saved == true) {
      _message(entry == null ? 'Task added.' : 'Task updated.');
    }
  }

  Future<void> _toggle(TaskEntry entry) async {
    if (_busyKeys.contains(entry.key)) return;
    setState(() => _busyKeys.add(entry.key));
    try {
      await widget.store.update(entry.key,
          entry.task.copyWith(isCompleted: !entry.task.isCompleted));
    } catch (_) {
      _message('Could not update the task. Please try again.');
    } finally {
      if (mounted) setState(() => _busyKeys.remove(entry.key));
    }
  }

  Future<void> _delete(TaskEntry entry) async {
    if (_busyKeys.contains(entry.key)) return;
    setState(() => _busyKeys.add(entry.key));
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete this task?'),
          content: Text('“${entry.task.title}” will be removed from your list.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep task')),
            FilledButton(onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete')),
          ],
        ),
      );
      if (confirmed == true) {
        await widget.store.delete(entry.key);
        _message('Task deleted.');
      }
    } catch (_) {
      _message('Could not delete the task. Please try again.');
    } finally {
      if (mounted) setState(() => _busyKeys.remove(entry.key));
    }
  }

  Future<void> _clearAll() async {
    if (widget.store.box.isEmpty) {
      _message('There are no tasks to delete.');
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete all tasks?'),
        content: const Text('This removes every task, including completed tasks. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete all')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await widget.store.clear();
      _message('All tasks deleted.');
    } catch (_) {
      _message('Could not delete all tasks. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          Icon(Icons.check_circle, color: AppColors.teal),
          SizedBox(width: 10),
          Text('Personal To-do list tracker', style: TextStyle(fontWeight: FontWeight.w800,
              letterSpacing: -0.6)),
        ]),
        actions: [
          IconButton(
            tooltip: 'Delete all tasks',
            onPressed: _clearAll,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
          const Padding(padding: EdgeInsets.only(right: 20),
              child: Tooltip(message: 'Tasks are saved on this device',
                  child: Icon(Icons.offline_pin_outlined, color: AppColors.paper))),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('New task'),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ValueListenableBuilder<Box<Task>>(
              valueListenable: widget.store.box.listenable(),
              builder: (context, box, _) {
                final all = widget.store.tasks;
                final completed = all.where((e) => e.task.isCompleted).length;
                final visible = all.where((e) => switch (_filter) {
                  TaskFilter.all => true,
                  TaskFilter.active => !e.task.isCompleted,
                  TaskFilter.completed => e.task.isCompleted,
                }).toList();
                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(MaterialLocalizations.of(context)
                                .formatFullDate(DateTime.now()).toUpperCase(),
                                style: const TextStyle(fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.1, color: AppColors.paper)),
                            const SizedBox(height: 10),
                            const Text('Make room for\nwhat matters.',
                                style: TextStyle(fontSize: 36, height: 1.12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1.3, color: AppColors.paper)),
                            const SizedBox(height: 12),
                            const Text('One task at a time. Learning persistence with discipline.',
                                style: TextStyle(color: AppColors.paper)),
                            const SizedBox(height: 24),
                            _ProgressCard(total: all.length, completed: completed),
                            const SizedBox(height: 28),
                            Row(children: [
                              const Expanded(child: Text('Your tasks',
                                  style: TextStyle(fontSize: 22,
                                      fontWeight: FontWeight.w700))),
                              Text('${visible.length} tasks',
                                  style: const TextStyle(color: AppColors.paper)),
                            ]),
                            const SizedBox(height: 12),
                            Wrap(spacing: 8, runSpacing: 8, children: [
                              for (final filter in TaskFilter.values)
                                ChoiceChip(
                                  label: Text(switch (filter) {
                                    TaskFilter.all => 'All',
                                    TaskFilter.active => 'Active',
                                    TaskFilter.completed => 'Completed',
                                  }),
                                  selected: _filter == filter,
                                  showCheckmark: false,
                                  selectedColor: AppColors.blue,
                                  backgroundColor: AppColors.navy,
                                  labelStyle: const TextStyle(color: AppColors.paper),
                                  onSelected: (_) => setState(() => _filter = filter),
                                ),
                            ]),
                            const SizedBox(height: 12),
                            const Text('Tap a task to edit · Swipe left to delete',
                                style: TextStyle(fontSize: 12, color: AppColors.paper)),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    if (visible.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
                          child: Column(children: [
                            Icon(_filter == TaskFilter.completed
                                ? Icons.task_alt : Icons.edit_note_rounded,
                                size: 58, color: AppColors.teal),
                            const SizedBox(height: 16),
                            Text(all.isEmpty ? 'A fresh start.' : 'Nothing here just yet.',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Text(all.isEmpty
                                ? 'Add your first task and give your day a little direction.'
                                : _filter == TaskFilter.active
                                    ? 'You’re all caught up. Take a well-earned breath.'
                                    : 'Completed tasks will appear here.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: AppColors.paper)),
                          ]),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((context, index) {
                            final entry = visible[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Dismissible(
                                key: ValueKey(entry.key),
                                direction: _busyKeys.contains(entry.key)
                                    ? DismissDirection.none : DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 24),
                                  decoration: BoxDecoration(color: AppColors.navy,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: const Icon(Icons.delete_outline, color: AppColors.paper),
                                ),
                                confirmDismiss: (_) async {
                                  // Hive removes the row only after a successful write.
                                  // Cancel the gesture's own removal so failures keep the row.
                                  await _delete(entry);
                                  return false;
                                },
                                child: _taskCard(entry),
                              ),
                            );
                          }, childCount: visible.length),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 110)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _taskCard(TaskEntry entry) {
    final task = entry.task;
    final busy = _busyKeys.contains(entry.key);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final overdue = !task.isCompleted && task.date.isBefore(today);
    final dateLabel = MaterialLocalizations.of(context).formatMediumDate(task.date);
    return Material(
      color: task.isCompleted ? AppColors.blue.withAlpha(90) : AppColors.navy,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.paper.withAlpha(35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: busy ? null : () => _openForm(entry),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Checkbox(
              value: task.isCompleted,
              activeColor: AppColors.teal,
              semanticLabel: 'Mark ${task.title} ${task.isCompleted ? 'active' : 'completed'}',
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              onChanged: busy ? null : (_) => _toggle(entry),
            ),
            const SizedBox(width: 4),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(task.title, style: TextStyle(fontSize: 16,
                  fontWeight: FontWeight.w600,
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  color: task.isCompleted ? AppColors.paper.withAlpha(170) : AppColors.paper)),
              const SizedBox(height: 8),
              Text('${task.isCompleted ? 'Completed' : overdue ? 'Overdue' : 'Scheduled'} · $dateLabel',
                  style: const TextStyle(fontSize: 12, color: AppColors.paper)),
            ])),
            PopupMenuButton<String>(
              enabled: !busy,
              tooltip: 'Task options',
              onSelected: (action) {
                if (action == 'edit') {
                  _openForm(entry);
                } else {
                  _delete(entry);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit task')),
                PopupMenuItem(value: 'delete', child: Text('Delete task')),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.total, required this.completed});
  final int total;
  final int completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(begin: Alignment.topLeft,
            end: Alignment.bottomRight, colors: [AppColors.navy, AppColors.blue]),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('SMALL STEPS. REAL PROGRESS.', style: TextStyle(
            color: AppColors.paper, letterSpacing: 1.2, fontSize: 10,
            fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Text('${total - completed} tasks to go', style: const TextStyle(
            color: AppColors.paper, fontSize: 28, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('$completed of $total completed',
            style: const TextStyle(color: AppColors.paper, fontSize: 13)),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : completed / total,
            minHeight: 7,
            color: AppColors.teal,
            backgroundColor: AppColors.paper.withAlpha(40),
            semanticsLabel: 'Task completion',
            semanticsValue: '$completed of $total tasks completed',
          ),
        ),
      ]),
    );
  }
}
