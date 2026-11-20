class TeacherErrorItem {
  final String wrong;
  final String correct;
  final List<String> options;
  final String reason;

  const TeacherErrorItem({
    required this.wrong,
    required this.correct,
    required this.options,
    required this.reason,
  });

  factory TeacherErrorItem.fromJson(Map<String, dynamic> json) {
    return TeacherErrorItem(
      wrong: json['wrong'] as String,
      correct: json['correct'] as String,
      options: (json['options'] as List<dynamic>).map((e) => e.toString()).toList(),
      reason: json['reason'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'wrong': wrong,
    'correct': correct,
    'options': options,
    'reason': reason,
  };
}

class TeacherExercise {
  final String id;
  final String studentName;
  final String studentAvatar;
  final String topic;
  final String arabicText;
  final List<TeacherErrorItem> errors;
  final int rewardCoins;

  const TeacherExercise({
    required this.id,
    required this.studentName,
    required this.studentAvatar,
    required this.topic,
    required this.arabicText,
    required this.errors,
    required this.rewardCoins,
  });

  List<String> get words => arabicText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

  factory TeacherExercise.fromJson(Map<String, dynamic> json, {String? id}) {
    return TeacherExercise(
      id: id ?? json['id'] as String? ?? json['studentName'].toString().toLowerCase(),
      studentName: json['studentName'] as String,
      studentAvatar: json['studentAvatar'] as String? ?? '🧕',
      topic: json['topic'] as String,
      arabicText: json['arabicText'] as String,
      errors: (json['errors'] as List<dynamic>)
          .map((e) => TeacherErrorItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      rewardCoins: (json['rewardCoins'] as num?)?.toInt() ?? 50,
    );
  }
}

class GiftItem {
  final String id;
  final String giftName;
  final int priceCoins;
  final String icon;
  final String description;

  const GiftItem({
    required this.id,
    required this.giftName,
    required this.priceCoins,
    required this.icon,
    required this.description,
  });

  factory GiftItem.fromJson(Map<String, dynamic> json) {
    return GiftItem(
      id: json['id'] as String? ?? json['giftName'].toString().toLowerCase().replaceAll(' ', '_'),
      giftName: json['giftName'] as String,
      priceCoins: (json['priceCoins'] as num).toInt(),
      icon: json['icon'] as String? ?? '🎁',
      description: json['description'] as String? ?? '',
    );
  }
}
