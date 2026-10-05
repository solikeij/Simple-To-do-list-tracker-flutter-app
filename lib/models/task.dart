import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
class Task {
  const Task({
    required this.title,
    required this.date,
    this.isCompleted = false,
    this.description = '',
    this.category = '',
    this.priority = '',
    this.time = '',
    this.location = '',
    this.reminderNote = '',
    this.tags = '',

  });

  @HiveField(0)
  final String title;
  @HiveField(1)
  final DateTime date;
  @HiveField(2, defaultValue: false)
  final bool isCompleted;
  @HiveField(3, defaultValue: '')
  final String description;
  @HiveField(4, defaultValue: '')
  final String category;
  @HiveField(5, defaultValue: '')
  final String priority;
  @HiveField(6, defaultValue: '')
  final String time;
  @HiveField(7, defaultValue: '')
  final String location;
  @HiveField(8, defaultValue: '')
  final String reminderNote;
  @HiveField(9, defaultValue: '')
  final String tags;


  Map<String, dynamic> toMap() => {
        'title': title,
        'date': date.toIso8601String(),
        'isCompleted': isCompleted,
        'description': description,
        'category': category,
        'priority': priority,
        'time': time,
        'location': location,
        'reminderNote': reminderNote,
        'tags': tags,

      };

  factory Task.fromMap(Map<dynamic, dynamic> map) => Task(
        title: map['title'] as String,
        date: DateTime.parse(map['date'] as String),
        isCompleted: map['isCompleted'] as bool? ?? false,
        description: map['description'] as String? ?? '',
        category: map['category'] as String? ?? '',
        priority: map['priority'] as String? ?? '',
        time: map['time'] as String? ?? '',
        location: map['location'] as String? ?? '',
        reminderNote: map['reminderNote'] as String? ?? '',
        tags: map['tags'] as String? ?? '',

      );

  Task copyWith({String? title, DateTime? date, bool? isCompleted, String? description, String? category, String? priority, String? time, String? location, String? reminderNote, String? tags}) => Task(
        title: title ?? this.title,
        date: date ?? this.date,
        isCompleted: isCompleted ?? this.isCompleted,
        description: description ?? this.description,
        category: category ?? this.category,
        priority: priority ?? this.priority,
        time: time ?? this.time,
        location: location ?? this.location,
        reminderNote: reminderNote ?? this.reminderNote,
        tags: tags ?? this.tags,

      );
}
