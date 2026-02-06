class MoodLog {
  final int id;
  final DateTime date;
  final int mood;
  final String? note;

  const MoodLog({
    required this.id,
    required this.date,
    required this.mood,
    this.note,
  });

  MoodLog copyWith({
    int? id,
    DateTime? date,
    int? mood,
    String? note,
  }) {
    return MoodLog(
      id: id ?? this.id,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      note: note ?? this.note,
    );
  }

  /// Get emoji based on mood value
  String get emoji {
    if (mood >= 1 && mood <= 3) {
      return '😞';
    } else if (mood >= 4 && mood <= 7) {
      return '😐';
    } else {
      return '😊';
    }
  }

  /// Static method to get emoji for any mood value
  static String getEmojiForMood(int mood) {
    if (mood >= 1 && mood <= 3) {
      return '😞';
    } else if (mood >= 4 && mood <= 7) {
      return '😐';
    } else {
      return '😊';
    }
  }

  /// Get color based on mood value (gradient from red → yellow → green)
  /// Returns RGB color as integers
  ({int r, int g, int b}) get color {
    if (mood >= 1 && mood <= 5) {
      // Red (211,47,47) → Yellow (255,214,0)
      final t = (mood - 1) / 4; // 0.0 to 1.0
      final r = (211 + (255 - 211) * t).round();
      final g = (47 + (214 - 47) * t).round();
      final b = (47 + (0 - 47) * t).round();
      return (r: r, g: g, b: b);
    } else {
      // Yellow (255,214,0) → Green (67,160,71)
      final t = (mood - 6) / 4; // 0.0 to 1.0
      final r = (255 + (67 - 255) * t).round();
      final g = (214 + (160 - 214) * t).round();
      final b = (0 + (71 - 0) * t).round();
      return (r: r, g: g, b: b);
    }
  }
}
