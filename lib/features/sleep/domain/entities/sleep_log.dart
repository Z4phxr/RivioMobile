class SleepLog {
  final int id;
  final DateTime start;
  final DateTime end;
  final Duration duration;
  final DateTime sleepDate;

  const SleepLog({
    required this.id,
    required this.start,
    required this.end,
    required this.duration,
    required this.sleepDate,
  });

  SleepLog copyWith({
    int? id,
    DateTime? start,
    DateTime? end,
    Duration? duration,
    DateTime? sleepDate,
  }) {
    return SleepLog(
      id: id ?? this.id,
      start: start ?? this.start,
      end: end ?? this.end,
      duration: duration ?? this.duration,
      sleepDate: sleepDate ?? this.sleepDate,
    );
  }

  /// Format duration as "Xh Ym" (e.g., "8h 30m")
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }
}
