class SrsState {
  final String cardId;
  final int level;
  final DateTime nextReview;
  final DateTime lastReviewed;
  final int timesReviewed;
  final int correctCount;

  static const List<int> intervals = [1, 3, 7, 14, 30, 60, 120];

  const SrsState({
    required this.cardId,
    this.level = 0,
    required this.nextReview,
    required this.lastReviewed,
    this.timesReviewed = 0,
    this.correctCount = 0,
  });

  bool get isMastered => level >= 3;

  /// quality: 0=again, 1=hard, 2=good, 3=easy
  SrsState review(int quality) {
    int newLevel = level;
    if (quality >= 2) {
      newLevel = (level + 1).clamp(0, intervals.length - 1);
    } else if (quality == 0) {
      newLevel = (level - 1).clamp(0, intervals.length - 1);
    }
    return SrsState(
      cardId: cardId,
      level: newLevel,
      nextReview: DateTime.now().add(Duration(days: intervals[newLevel])),
      lastReviewed: DateTime.now(),
      timesReviewed: timesReviewed + 1,
      correctCount: correctCount + (quality >= 2 ? 1 : 0),
    );
  }

  Map<String, dynamic> toJson() => {
    'cardId': cardId,
    'level': level,
    'nextReview': nextReview.toIso8601String(),
    'lastReviewed': lastReviewed.toIso8601String(),
    'timesReviewed': timesReviewed,
    'correctCount': correctCount,
  };

  factory SrsState.fromJson(Map<String, dynamic> json) => SrsState(
    cardId: json['cardId'] as String,
    level: json['level'] as int? ?? 0,
    nextReview: DateTime.parse(json['nextReview'] as String),
    lastReviewed: DateTime.parse(json['lastReviewed'] as String),
    timesReviewed: json['timesReviewed'] as int? ?? 0,
    correctCount: json['correctCount'] as int? ?? 0,
  );

  factory SrsState.initial(String cardId) => SrsState(
    cardId: cardId,
    nextReview: DateTime.now(),
    lastReviewed: DateTime.now(),
  );
}
