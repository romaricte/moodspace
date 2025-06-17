import 'package:uuid/uuid.dart';

class MoodEntry {
  final String id;
  final DateTime date;
  final double moodScore; // Score de 0 à 1 (0 = très mauvaise humeur, 1 = excellente humeur)
  final String? note;
  final String? imagePath;
  final List<String> tags;

  MoodEntry({
    String? id,
    required this.date,
    required this.moodScore,
    this.note,
    this.imagePath,
    List<String>? tags,
  }) : 
    id = id ?? const Uuid().v4(),
    tags = tags ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'moodScore': moodScore,
      'note': note,
      'imagePath': imagePath,
      'tags': tags,
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'],
      date: DateTime.parse(json['date']),
      moodScore: json['moodScore'],
      note: json['note'],
      imagePath: json['imagePath'],
      tags: List<String>.from(json['tags']),
    );
  }

  MoodEntry copyWith({
    String? id,
    DateTime? date,
    double? moodScore,
    String? note,
    String? imagePath,
    List<String>? tags,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      moodScore: moodScore ?? this.moodScore,
      note: note ?? this.note,
      imagePath: imagePath ?? this.imagePath,
      tags: tags ?? this.tags,
    );
  }
} 