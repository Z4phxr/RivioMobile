import '../../domain/entities/mood_log.dart';

class MoodLogDto {
  final int id;
  final DateTime date;
  final int mood;
  final String? note;

  const MoodLogDto({
    required this.id,
    required this.date,
    required this.mood,
    this.note,
  });

  factory MoodLogDto.fromJson(Map<String, dynamic> json) {
    return MoodLogDto(
      id: json['id'] as int,
      // Backend sometimes returns date, sometimes doesn't (on create/update)
      // Use a sentinel date when missing so the provider can correct it
      date: (json['date'] != null && (json['date'] as String).isNotEmpty)
          ? DateTime.parse(json['date'] as String)
          : DateTime(0),
      mood: json['mood'] as int,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': _formatDate(date),
      'mood': mood,
      if (note != null) 'note': note,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  MoodLog toEntity() => MoodLog(id: id, date: date, mood: mood, note: note);
}

class MoodLogCreateRequest {
  final DateTime date;
  final int mood;
  final String? note;

  const MoodLogCreateRequest({
    required this.date,
    required this.mood,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': _formatDate(date),
      'mood': mood,
      if (note != null) 'note': note,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
