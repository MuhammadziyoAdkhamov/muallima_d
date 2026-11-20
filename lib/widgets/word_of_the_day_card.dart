import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../services/audio_service.dart';

class DailySpecialWord {
  final String arabic;
  final String transliteration;
  final String meaning;
  final String emoji;
  final String description;

  const DailySpecialWord({
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.emoji,
    required this.description,
  });
}

const List<DailySpecialWord> dailyWordsList = [
  DailySpecialWord(
    arabic: 'حُبّ',
    transliteration: 'hubb',
    meaning: 'Muhabbat / Sevgi',
    emoji: '💜',
    description: 'Eng pok va go‘zal tuyg‘u — mehr va muhabbatdir.',
  ),
  DailySpecialWord(
    arabic: 'نُور',
    transliteration: 'nuur',
    meaning: 'Nur / Yorug‘lik',
    emoji: '✨',
    description: 'Ilm va yaxshilik inson qalbini nurga to‘ldiradi.',
  ),
  DailySpecialWord(
    arabic: 'جَمَال',
    transliteration: 'jamaal',
    meaning: 'Go‘zallik',
    emoji: '🌸',
    description: 'Haqiqiy go‘zallik — qalb pokligi va latofatidadir.',
  ),
  DailySpecialWord(
    arabic: 'رَحْمَة',
    transliteration: 'rahma',
    meaning: 'Mehribonlik / Rahmat',
    emoji: '🕊️',
    description: 'Boshqalarga ko‘rsatilgan mehr qalbga xotirjamlik beradi.',
  ),
  DailySpecialWord(
    arabic: 'قَلْب',
    transliteration: 'qalb',
    meaning: 'Qalb / Yurak',
    emoji: '💖',
    description: 'Qalb ezgu niyatlar bilan yanada yorishadi.',
  ),
  DailySpecialWord(
    arabic: 'زَهْرَة',
    transliteration: 'zahra',
    meaning: 'Gul / Chechak',
    emoji: '🌷',
    description: 'Tabassum xuddi ochilgan gul kabi atrofni quvontiradi.',
  ),
  DailySpecialWord(
    arabic: 'سَلَام',
    transliteration: 'salaam',
    meaning: 'Tinchlik / Omonlik',
    emoji: '🌿',
    description: 'Tinchlik va xotirjamlik — eng buyuk ne’mat.',
  ),
  DailySpecialWord(
    arabic: 'أَمَل',
    transliteration: 'amal',
    meaning: 'Umid',
    emoji: '🌅',
    description: 'Ertangi kunga bo‘lgan ezgu umid qanot bag‘ishlaydi.',
  ),
  DailySpecialWord(
    arabic: 'صَبْر',
    transliteration: 'sabr',
    meaning: 'Sabr / Matonat',
    emoji: '💎',
    description: 'Sabr — har qanday qiyinchilikni yenguvchi oltin kalit.',
  ),
  DailySpecialWord(
    arabic: 'سَعَادَة',
    transliteration: 'sa‘aada',
    meaning: 'Baxt / Saodat',
    emoji: '🌟',
    description: 'Kichik quvonchlar ulkan saodat poydevoridir.',
  ),
  DailySpecialWord(
    arabic: 'بَرَكَة',
    transliteration: 'baraka',
    meaning: 'Baraka',
    emoji: '🌾',
    description: 'Ezgulik bilan qilingan har ishda baraka bo‘ladi.',
  ),
  DailySpecialWord(
    arabic: 'حَيَاة',
    transliteration: 'hayaat',
    meaning: 'Hayot',
    emoji: '🍃',
    description: 'Hayot — mehr ulashish uchun berilgan eng oliy tuhfa.',
  ),
  DailySpecialWord(
    arabic: 'وَفَاء',
    transliteration: 'vafaa’',
    meaning: 'Vafo / Sadoqat',
    emoji: '💍',
    description: 'Vafo va sadoqat — rishtalarni mustahkam qiluvchi gavhar.',
  ),
  DailySpecialWord(
    arabic: 'فَرَح',
    transliteration: 'farah',
    meaning: 'Quvonch / Shodlik',
    emoji: '🎀',
    description: 'Qalbingiz doimo xushnudlik va quvonchga to‘lsin.',
  ),
];

class WordOfTheDayCard extends StatefulWidget {
  const WordOfTheDayCard({super.key});

  @override
  State<WordOfTheDayCard> createState() => _WordOfTheDayCardState();
}

class _WordOfTheDayCardState extends State<WordOfTheDayCard> {
  bool _isLiked = false;

  DailySpecialWord get _todayWord {
    final dayIndex = DateTime.now().day % dailyWordsList.length;
    return dailyWordsList[dayIndex];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final word = _todayWord;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2C2442), const Color(0xFF1E1A30)]
              : [const Color(0xFFF9F5FF), const Color(0xFFF0E8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFF8272D8).withValues(alpha: 0.22),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8272D8).withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Yuqori belgi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8272D8).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(word.emoji, style: const TextStyle(fontSize: 14)),
                      const Gap(6),
                      const Flexible(
                        child: Text(
                          'Kunning nuri 🌸',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7A65CC),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: _isLiked ? Colors.pinkAccent : Colors.grey,
                    ).animate(target: _isLiked ? 1 : 0).scale(
                      duration: 350.ms,
                      curve: Curves.elasticOut,
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.2, 1.2),
                    ),
                    onPressed: () {
                      setState(() => _isLiked = !_isLiked);
                    },
                  ),
                  const Gap(6),
                  IconButton(
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF8272D8)),
                    onPressed: () => AudioService.instance.speak(word.arabic),
                  ),
                ],
              ),
            ],
          ),

          const Gap(14),

          // Arabcha so'z va ma'nosi
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word.arabic,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7159C1),
                        height: 1.2,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      '[ ${word.transliteration} ]  •  ${word.meaning}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Gap(10),

          Text(
            word.description,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.35,
              color: isDark ? const Color(0xFFD6CEEE) : const Color(0xFF6B5B95),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
