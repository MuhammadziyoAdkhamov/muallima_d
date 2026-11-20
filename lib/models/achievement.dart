class LevelInfo {
  final int level;
  final String title;
  final String emoji;
  final int minXp;
  final int maxXp;

  const LevelInfo({
    required this.level,
    required this.title,
    required this.emoji,
    required this.minXp,
    required this.maxXp,
  });

  static LevelInfo fromXp(int xp) {
    if (xp < 100) {
      return const LevelInfo(
        level: 1,
        title: 'Yangi talaba',
        emoji: '🌱',
        minXp: 0,
        maxXp: 100,
      );
    }
    if (xp < 300) {
      return const LevelInfo(
        level: 2,
        title: 'Izlanuvchi',
        emoji: '📖',
        minXp: 100,
        maxXp: 300,
      );
    }
    if (xp < 700) {
      return const LevelInfo(
        level: 3,
        title: "So'z ustozi",
        emoji: '⭐',
        minXp: 300,
        maxXp: 700,
      );
    }
    if (xp < 1500) {
      return const LevelInfo(
        level: 4,
        title: 'Arab ovozi',
        emoji: '🎯',
        minXp: 700,
        maxXp: 1500,
      );
    }
    return const LevelInfo(
      level: 5,
      title: 'Ustoz',
      emoji: '👑',
      minXp: 1500,
      maxXp: 9999,
    );
  }

  /// Progress within the current level (0.0 – 1.0)
  double progressForXp(int xp) {
    if (maxXp == minXp) return 1.0;
    final clamped = (xp - minXp).clamp(0, maxXp - minXp);
    return clamped / (maxXp - minXp);
  }
}
