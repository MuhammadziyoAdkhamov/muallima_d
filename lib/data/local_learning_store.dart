import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalLearningStore {
  LocalLearningStore(this._preferences);

  final SharedPreferences _preferences;

  String get learnerName {
    final savedName = _preferences.getString('learnerName');
    return savedName == null || savedName == 'Do‘stim' ? 'Malikam' : savedName;
  }

  bool get isDarkMode => _preferences.getBool('isDarkMode') ?? false;

  int get totalXp => _preferences.getInt('totalXp') ?? 0;

  int get mistakeCount => _preferences.getInt('mistakeCount') ?? 0;

  int get streakDays {
    final lastStudy = _preferences.getString('lastStudyDate');
    if (lastStudy == null) return 0;
    final daysSinceLastStudy = _dateOnly(_today())
        .difference(DateTime.parse(lastStudy))
        .inDays;
    return daysSinceLastStudy >= 0 && daysSinceLastStudy <= 1
        ? _preferences.getInt('streakDays') ?? 0
        : 0;
  }

  bool get completedToday =>
      _preferences.getString('lastStudyDate') == _dateKey(_today());

  Set<String> get learnedWordIds =>
      (_preferences.getStringList('learnedWordIds') ?? <String>[]).toSet();

  Set<String> get completedTodayWordIds {
    if (!completedToday) return <String>{};
    return (_preferences.getStringList('completedTodayWordIds') ?? <String>[])
        .toSet();
  }

  Set<String> get bookmarkedWordIds =>
      (_preferences.getStringList('bookmarkedWordIds') ?? <String>[]).toSet();

  Future<void> toggleBookmark(String wordId) async {
    final bookmarks = bookmarkedWordIds;
    if (bookmarks.contains(wordId)) {
      bookmarks.remove(wordId);
    } else {
      bookmarks.add(wordId);
    }
    await _preferences.setStringList('bookmarkedWordIds', bookmarks.toList());
  }

  static const String defaultLoveLetter =
      'Mehribonim, Malikam! 🌸\n\n'
      'Bu ilovani senga bo‘lgan eng samimiy va ezgu tuyg‘ularim bilan yaratdim. '
      'Arab tili — qalblarga huzur bag‘ishlovchi, nozik va ma’noli tildir.\n\n'
      'Har safar yangi bir so‘zni o‘rganganingda tabassuming menga eng katta baxt. '
      'Ilm olishda aslo charchama, qiyin tuyulsa ham esda tutki, men har bir qadamingda seni qo‘llab-quvvatlayman va sen bilan faxrlanaman!\n\n'
      'O‘zingni ehtiyot qil, mening eng aziz insonim! 💜✨';

  String get letterText =>
      _preferences.getString('customLetterText') ?? defaultLoveLetter;

  Future<void> setLetterText(String text) =>
      _preferences.setString('customLetterText', text.trim());

  int get totalMinutesStudied =>
      _preferences.getInt('totalMinutesStudied') ?? 0;

  Future<void> addStudyMinutes(int minutes) async {
    await _preferences.setInt(
      'totalMinutesStudied',
      totalMinutesStudied + minutes,
    );
  }

  Set<String> get dueWordIds {
    final today = _dateKey(_today());
    return _reviewSchedule.entries
        .where((entry) => entry.value.compareTo(today) <= 0)
        .map((entry) => entry.key)
        .toSet();
  }

  Map<String, String> get scheduledReviewDates =>
      Map<String, String>.unmodifiable(_reviewSchedule);

  bool studiedOn(DateTime date) =>
      (_preferences.getStringList('studyDates') ?? <String>[]).contains(
        _dateKey(date),
      );

  Future<void> setLearnerName(String name) =>
      _preferences.setString('learnerName', name.trim());

  Future<void> setDarkMode(bool isDarkMode) =>
      _preferences.setBool('isDarkMode', isDarkMode);

  Future<void> recordMistake(String wordId) async {
    final schedule = _reviewSchedule;
    schedule[wordId] = _dateKey(
      _dateOnly(_today()).add(const Duration(days: 1)),
    );
    await _preferences.setInt('mistakeCount', mistakeCount + 1);
    await _preferences.setString('reviewSchedule', jsonEncode(schedule));
  }

  Future<void> resolveReview(String wordId) async {
    final schedule = _reviewSchedule..remove(wordId);
    await _preferences.setString('reviewSchedule', jsonEncode(schedule));
  }

  Future<bool> completeSession(
    Iterable<String> wordIds, {
    int xpReward = 20,
    int studyMinutes = 0,
  }) async {
    final today = _dateKey(_today());
    final completedWords = wordIds.toSet();
    final learned = learnedWordIds..addAll(completedWords);
    await _preferences.setStringList('learnedWordIds', learned.toList());

    if (completedToday) return false;

    await _preferences.setStringList(
      'completedTodayWordIds',
      completedWords.toList(),
    );

    final lastStudy = _preferences.getString('lastStudyDate');
    final previousStreak = streakDays;
    final daysSinceLastStudy = lastStudy == null
        ? -1
        : _dateOnly(_today()).difference(DateTime.parse(lastStudy)).inDays;
    final nextStreak = daysSinceLastStudy == 1
        ? previousStreak + 1
        : daysSinceLastStudy == 0
        ? previousStreak
        : 1;

    final studyDates = (_preferences.getStringList('studyDates') ?? <String>[])
      ..add(today);
    final recentDates = studyDates.toSet().toList()..sort();
    if (recentDates.length > 60) {
      recentDates.removeRange(0, recentDates.length - 60);
    }

    await _preferences.setString('lastStudyDate', today);
    await _preferences.setStringList('studyDates', recentDates);
    await _preferences.setInt('streakDays', nextStreak);
    await _preferences.setInt('totalXp', totalXp + xpReward);
    if (studyMinutes > 0) {
      await _preferences.setInt(
        'totalMinutesStudied',
        totalMinutesStudied + studyMinutes,
      );
    }
    return true;
  }

  // ─── Muallima Dilnavoz (Ustozlik & Sovg'alar) ────────────────────────
  int get teacherCoins => _preferences.getInt('teacherCoins') ?? 250;

  Future<void> addTeacherCoins(int amount) async {
    await _preferences.setInt('teacherCoins', teacherCoins + amount);
  }

  Set<String> get completedExerciseIds =>
      (_preferences.getStringList('completedExerciseIds') ?? <String>[]).toSet();

  Future<void> markExerciseCompleted(String exerciseId, int coinsReward) async {
    final list = completedExerciseIds;
    list.add(exerciseId);
    await _preferences.setStringList('completedExerciseIds', list.toList());
    await addTeacherCoins(coinsReward);
  }

  Set<String> get orderedGiftIds =>
      (_preferences.getStringList('orderedGiftIds') ?? <String>[]).toSet();

  Future<bool> orderGift(String giftId, int price) async {
    if (teacherCoins < price) return false;
    await _preferences.setInt('teacherCoins', teacherCoins - price);
    final list = orderedGiftIds;
    list.add(giftId);
    await _preferences.setStringList('orderedGiftIds', list.toList());
    return true;
  }

  Map<String, String> get _reviewSchedule {
    final encoded = _preferences.getString('reviewSchedule');
    if (encoded == null) return <String, String>{};

    final decoded = jsonDecode(encoded);
    if (decoded is! Map<String, dynamic> ||
        decoded.values.any((value) => value is! String)) {
      throw const FormatException('Saqlangan takrorlash jadvali noto‘g‘ri.');
    }

    return decoded.map((key, value) => MapEntry(key, value as String));
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
