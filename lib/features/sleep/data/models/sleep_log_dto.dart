import '../../domain/entities/sleep_log.dart';

class SleepLogDto {
  final int id;
  final DateTime start;
  final DateTime end;
  final Duration duration;
  final DateTime sleepDate;

  const SleepLogDto({
    required this.id,
    required this.start,
    required this.end,
    required this.duration,
    required this.sleepDate,
  });

  factory SleepLogDto.fromJson(Map<String, dynamic> json) {
    return SleepLogDto(
      id: json['id'] as int,
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      duration: _parseDuration(json['duration'] as String),
      sleepDate: DateTime.parse(json['sleep_date'] as String),
    );
  }

  static Duration _parseDuration(String duration) {
    // Parse HH:MM:SS format
    final parts = duration.split(':');
    return Duration(
      hours: int.parse(parts[0]),
      minutes: int.parse(parts[1]),
      seconds: int.parse(parts[2]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'duration': _formatDuration(duration),
      'sleep_date': _formatDate(sleepDate),
    };
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  SleepLog toEntity() => SleepLog(
    id: id,
    start: start,
    end: end,
    duration: duration,
    sleepDate: sleepDate,
  );
}

class SleepLogCreateRequest {
  final DateTime start;
  final DateTime end;

  const SleepLogCreateRequest({required this.start, required this.end});

  Map<String, dynamic> toJson() {
    return {'start': start.toIso8601String(), 'end': end.toIso8601String()};
  }
}
