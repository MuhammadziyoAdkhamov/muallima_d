import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../data/local_learning_store.dart';
import '../../data/word_database.dart';
import '../../models/achievement.dart';
import '../../widgets/floating_petals_background.dart';
import '../../widgets/level_badge.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/xp_progress_bar.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key, required this.store});

  final LocalLearningStore store;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLevel = LevelInfo.fromXp(store.totalXp);
    final learnedCount = store.learnedWordIds.length;
    final totalWords = wordDatabase.length;

    return FloatingPetalsBackground(
      showPetals: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        children: [
        // ─── Title ───────────────────────────────────────────────
        Text(
          'Yutuqlar & Natijalar 🏆',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ).animate().fadeIn(duration: 300.ms),
        const Gap(6),
        Text(
          'Har bir kichik intilish — kelajakdagi katta natija!',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: colors.onSurfaceVariant),
        ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

        const Gap(22),

        // ─── Level Card ──────────────────────────────────────────
        Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8272D8), Color(0xFF6554B7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8272D8).withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      LevelBadge(xp: store.totalXp, showLabel: false, size: 56),
                      const Gap(14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daraja: ${currentLevel.title}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${store.totalXp} / ${currentLevel.maxXp} XP',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(8),
                      Text(
                        currentLevel.emoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ],
                  ),
                  const Gap(18),
                  XpProgressBar(xp: store.totalXp),
                ],
              ),
            )
            .animate()
            .fadeIn(delay: 150.ms, duration: 400.ms)
            .slideY(begin: 0.08, end: 0),

        const Gap(24),

        // ─── Asosiy statistika kartalari ─────────────────────────
        Text(
          'Statistika 📊',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const Gap(12),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            StatCard(
              icon: '🔥',
              value: '${store.streakDays} kun',
              label: 'Ketma-ketlik',
              color: const Color(0xFFEE8B52),
            ),
            StatCard(
              icon: '📖',
              value: '$learnedCount ta',
              label: 'O‘rganilgan so‘z',
              color: const Color(0xFF8272D8),
            ),
            StatCard(
              icon: '⚡',
              value: '${store.totalXp} XP',
              label: 'Jamg‘arilgan ball',
              color: const Color(0xFFF59E0B),
            ),
            StatCard(
              icon: '⏱️',
              value: '${store.totalMinutesStudied} daq',
              label: 'O‘rganish vaqti',
              color: const Color(0xFF10B981),
            ),
          ],
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

        const Gap(24),

        _WeeklySummaryCard(store: store),

        const Gap(24),

        // ─── Medallar va Nishonlar (Badges) ──────────────────────
        Text(
          'Medallar & Nishonlar 🎖️',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const Gap(12),

        _BadgeTile(
          icon: '🌱',
          title: 'Ilk qadam',
          description: 'Birinchi darsni muvaffaqiyatli tamomlash',
          isUnlocked: store.totalXp >= 20,
        ),
        const Gap(10),
        _BadgeTile(
          icon: '🔥',
          title: 'Olovli intilish',
          description: '3 kunlik uzluksiz o‘rganish',
          isUnlocked: store.streakDays >= 3,
        ),
        const Gap(10),
        _BadgeTile(
          icon: '📖',
          title: 'So‘z xazinasi',
          description: 'Kamida 15 ta arabcha so‘zni o‘zlashtirish',
          isUnlocked: learnedCount >= 15,
        ),
        const Gap(10),
        _BadgeTile(
          icon: '👑',
          title: 'Arab tili malikasi',
          description: 'Barcha mavzulardagi barcha so‘zlarni zabt etish',
          isUnlocked: learnedCount >= totalWords,
        ),

        const Gap(24),

        // ─── Love & Motivation Note ──────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF231F33) : const Color(0xFFFAF5FF),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFF8272D8).withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            children: [
              const Text('🌸 ✨ 🌷', style: TextStyle(fontSize: 24)),
              const Gap(10),
              Text(
                'Har bir qadaming bilan faxrlanaman!',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF8272D8),
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(6),
              Text(
                'Ilm olish — eng nurli yo‘l. O‘zingga ishongin, sen har qanday qiyin narsani go‘zal uddalay olasan 💜',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
      ],
    ),
  );
}
}

class _WeeklySummaryCard extends StatelessWidget {
  const _WeeklySummaryCard({required this.store});

  static const _weeklyGoal = 5;
  static const _dayLabels = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];

  final LocalLearningStore store;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final monday = todayDate.subtract(Duration(days: today.weekday - 1));
    final weekDates = List.generate(
      7,
      (index) => monday.add(Duration(days: index)),
    );
    final studiedDays = weekDates.where(store.studiedOn).length;
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF2F7), Color(0xFFF2EEFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE7DDFC).withValues(alpha: 0.9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌷', style: TextStyle(fontSize: 24)),
              const Gap(10),
              const Expanded(
                child: Text(
                  'Haftalik hisobot',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '$studiedDays / $_weeklyGoal kun',
                style: const TextStyle(
                  color: Color(0xFF765FCA),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const Gap(6),
          Text(
            studiedDays >= _weeklyGoal
                ? 'Haftalik maqsadingni uddalading — barakalla! ✨'
                : 'Har bir kichik qadam qadrlidir. O‘zingga qulay sur’atda davom et.',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const Gap(14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (studiedDays / _weeklyGoal).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF9B83E8),
              ),
            ),
          ),
          const Gap(14),
          Row(
            children: [
              for (var index = 0; index < weekDates.length; index++)
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: store.studiedOn(weekDates[index])
                              ? const Color(0xFF8272D8)
                              : Colors.white.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          border: weekDates[index] == todayDate
                              ? Border.all(
                                  color: const Color(0xFF8272D8),
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Icon(
                          store.studiedOn(weekDates[index])
                              ? Icons.check_rounded
                              : Icons.circle,
                          size: store.studiedOn(weekDates[index]) ? 17 : 5,
                          color: store.studiedOn(weekDates[index])
                              ? Colors.white
                              : colors.outline,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        _dayLabels[index],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: weekDates[index] == todayDate
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: weekDates[index] == todayDate
                              ? colors.primary
                              : colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms, duration: 400.ms);
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.isUnlocked,
  });

  final String icon;
  final String title;
  final String description;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnlocked
              ? const Color(0xFF8272D8).withValues(alpha: 0.3)
              : colors.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? const Color(0xFFEDE8FF)
                  : (isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.04)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Opacity(
                opacity: isUnlocked ? 1.0 : 0.4,
                child: Text(icon, style: const TextStyle(fontSize: 24)),
              ),
            ),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: isUnlocked ? null : colors.onSurfaceVariant,
                      ),
                    ),
                    if (isUnlocked) ...[
                      const Gap(6),
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF10B981),
                        size: 16,
                      ),
                    ],
                  ],
                ),
                const Gap(3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant.withValues(
                      alpha: isUnlocked ? 0.9 : 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isUnlocked)
            const Icon(
              Icons.lock_outline_rounded,
              size: 20,
              color: Colors.grey,
            ),
        ],
      ),
    );
  }
}
