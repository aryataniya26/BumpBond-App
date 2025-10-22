import 'package:hive/hive.dart';

part 'journal_entry.g.dart';

@HiveType(typeId: 0)
class JournalEntry extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String content;

  @HiveField(2)
  String? imagePath;

  @HiveField(3)
  String? audioPath;

  @HiveField(4)
  DateTime createdAt;

  JournalEntry({
    required this.title,
    required this.content,
    this.imagePath,
    this.audioPath,
    required this.createdAt,
  });
}
