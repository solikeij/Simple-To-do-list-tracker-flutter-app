import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_store.dart';
import '../theme/app_theme.dart';

class TaskForm extends StatefulWidget {
  const TaskForm({super.key, required this.store, this.entry});
  final TaskStore store;
  final TaskEntry? entry;

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _category;
  late final TextEditingController _priority;
  late final TextEditingController _time;
  late final TextEditingController _location;
  late final TextEditingController _reminderNote;
  late final TextEditingController _tags;
  late DateTime _date;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.entry?.task.title ?? '');
    _description = TextEditingController(text: widget.entry?.task.description ?? '');
    _category = TextEditingController(text: widget.entry?.task.category ?? '');
    _priority = TextEditingController(text: widget.entry?.task.priority ?? '');
    _time = TextEditingController(text: widget.entry?.task.time ?? '');
    _location = TextEditingController(text: widget.entry?.task.location ?? '');
    _reminderNote = TextEditingController(text: widget.entry?.task.reminderNote ?? '');
    _tags = TextEditingController(text: widget.entry?.task.tags ?? '');
    final initial = widget.entry?.task.date ?? DateTime.now();
    _date = DateTime(initial.year, initial.month, initial.day);
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _category.dispose();
    _priority.dispose();
    _time.dispose();
    _location.dispose();
    _reminderNote.dispose();
    _tags.dispose();

    super.dispose();
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200, 12, 31),
    );
    if (selected != null && mounted) setState(() => _date = selected);
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final task = Task(
      title: _title.text.trim(),
      date: _date,
      description: _description.text.trim(),
      category: _category.text.trim(),
      priority: _priority.text.trim(),
      time: _time.text.trim(),
      location: _location.text.trim(),
      reminderNote: _reminderNote.text.trim(),
      tags: _tags.text.trim(),

      isCompleted: widget.entry?.task.isCompleted ?? false,
    );
    try {
      if (widget.entry == null) {
        await widget.store.add(task);
      } else {
        await widget.store.update(widget.entry!.key, task);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save this task. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.entry != null;
    return PopScope(
      canPop: !_saving,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.edit_calendar_outlined,
                      color: AppColors.teal, size: 34),
                  const SizedBox(height: 16),
                  Text(editing ? 'Edit task' : 'A little plan, a big step.',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const Text('Set a title and date. The extra details are optional.'),
                  const SizedBox(height: 24),
                  TextFormField(
                    key: const Key('taskTitle'),
                    controller: _title,
                    autofocus: true,
                    enabled: !_saving,
                    maxLength: 120,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Task title',
                      hintText: 'What would you like to do?',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Please enter a task title.'
                        : null,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _saving ? null : _pickDate,
                    icon: const Icon(Icons.calendar_today_outlined, size: 20),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(MaterialLocalizations.of(context)
                          .formatMediumDate(_date)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('descriptionField'),
                    controller: _description,
                    enabled: !_saving,
                    maxLength: 500,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'What needs to be done?',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('categoryField'),
                    controller: _category,
                    enabled: !_saving,
                    maxLength: 120,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      hintText: 'e.g. School, Work, Personal',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('priorityField'),
                    controller: _priority,
                    enabled: !_saving,
                    maxLength: 120,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      hintText: 'e.g. Low, Medium, High',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('timeField'),
                    controller: _time,
                    enabled: !_saving,
                    maxLength: 120,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      hintText: 'e.g. 14:30 or 2:30 PM',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('locationField'),
                    controller: _location,
                    enabled: !_saving,
                    maxLength: 120,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      hintText: 'e.g. Library or Online',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('reminderNoteField'),
                    controller: _reminderNote,
                    enabled: !_saving,
                    maxLength: 200,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Reminder note',
                      hintText: 'A note to yourself (no notification)',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('tagsField'),
                    controller: _tags,
                    enabled: !_saving,
                    maxLength: 120,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      labelText: 'Tags',
                      hintText: 'e.g. finals, flutter, study',
                      alignLabelWithHint: true,
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, semanticsLabel: _error),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    key: const Key('saveTask'),
                    onPressed: _saving ? null : _save,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(_saving
                          ? 'Saving…'
                          : editing ? 'Save changes' : 'Create task'),
                    ),
                  ),
                  TextButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
