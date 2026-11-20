import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../data/local_learning_store.dart';
import '../../data/word_database.dart';
import '../../models/achievement.dart';
import '../../models/question.dart';
import '../../models/word.dart';
import '../../widgets/floating_petals_background.dart';
import '../../widgets/love_letter_dialog.dart';
import '../../widgets/word_of_the_day_card.dart';
import '../alphabet/alphabet_screen.dart';
import '../lesson/lesson_screen.dart';
import '../teacher/teacher_home_screen.dart';

class TodayTab extends StatefulWidget {
  const TodayTab({
    super.key,
    required this.store,
    required this.onThemeToggle,
    required this.onRefresh,
  });

  final LocalLearningStore store;
  final VoidCallback onThemeToggle;
  final VoidCallback onRefresh;

  @override
  State<TodayTab> createState() => _TodayTabState();
}

class _TodayTabState extends State<TodayTab> {
  static const _encouragementQuotes = [
    'Har bir o‘rganilgan so‘z — qalbga ochilgan yangi nurdir 🌸',
    'Kichik qadamlar buyuk marralarga olib boradi. Sen buni uddalaysan! ✨',
    'Arab tili — nozik va go‘zal til. O‘rganishda davom et, azizam! 🌿',
    'Bugun o‘zing uchun 10 daqiqa ajratganingning o‘zi katta yutuq! 💜',
    'Sabr va intilish har qanday orzuni ro‘yobga chiqaradi 🌷',
  ];

  Future<void> _editName() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _NameDialog(initialName: widget.store.learnerName),
    );

    if (name == null || name.isEmpty) return;
    await widget.store.setLearnerName(name);
    if (mounted) {
      setState(() {});
      widget.onRefresh();
    }
  }

  void _showReviewNotebook() {
    final reviewDates = widget.store.scheduledReviewDates;
    final dueIds = widget.store.dueWordIds;
    final words =
        wordDatabase.where((word) => reviewDates.containsKey(word.id)).toList()
          ..sort((first, second) {
            final firstIsDue = dueIds.contains(first.id);
            final secondIsDue = dueIds.contains(second.id);
            if (firstIsDue != secondIsDue) return firstIsDue ? -1 : 1;
            return reviewDates[first.id]!.compareTo(reviewDates[second.id]!);
          });

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: 0.72,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Qiyin so‘zlar daftarim',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Yopish',
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              Text(
                words.isEmpty
                    ? 'Xato qilish — o‘rganishning bir qismi. Hozircha takrorlash so‘zi yo‘q.'
                    : '${dueIds.length} ta so‘z takrorlashga tayyor.',
                style: TextStyle(
                  color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                ),
              ),
              const Gap(12),
              Expanded(
                child: words.isEmpty
                    ? const Center(
                        child: Text('Bugun hammasi yaxshi ketmoqda 🌷'),
                      )
                    : ListView.separated(
                        itemCount: words.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final word = words[index];
                          final isDue = dueIds.contains(word.id);
                          final reviewDate = reviewDates[word.id]!;

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            title: Text(
                              word.meaning,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              isDue
                                  ? 'Bugun takrorlash mumkin'
                                  : 'Takrorlash sanasi: $reviewDate',
                            ),
                            leading: Text(
                              word.arabic,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                fontSize: 24,
                                color: Color(0xFF8272D8),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            trailing: Icon(
                              isDue
                                  ? Icons.replay_circle_filled_rounded
                                  : Icons.schedule_rounded,
                              color: isDue
                                  ? const Color(0xFF8272D8)
                                  : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openLesson({String? topicFilter, bool reviewOnly = false}) {
    List<Question> questions;

    if (reviewOnly) {
      final dueIds = widget.store.dueWordIds;
      final dueWords = wordDatabase
          .where((w) => dueIds.contains(w.id))
          .toList();
      if (dueWords.isEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: const Text(
                'Hozircha takrorlashga tayyor so‘z yo‘q. Hammasi ajoyib! 🌱',
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          );
        return;
      }
      questions = generateQuestions(dueWords, distractorPool: wordDatabase);
    } else if (topicFilter != null) {
      final topicWords = wordDatabase
          .where((w) => w.topic == topicFilter)
          .toList();
      questions = generateQuestions(topicWords, distractorPool: wordDatabase);
    } else {
      final dailyWords = _nextDailyWords();
      if (dailyWords.isEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Bugungi vazifa bajarildi — ertaga davom etamiz! 🌱',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        return;
      }
      questions = generateQuestions(dailyWords, distractorPool: wordDatabase);
    }

    questions.shuffle();
    final sessionQuestions = questions.take(8).toList();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LessonScreen(
          store: widget.store,
          questions: sessionQuestions,
          isReview: reviewOnly,
          onComplete: () {
            if (mounted) {
              Navigator.of(context).pop();
              setState(() {});
              widget.onRefresh();
            }
          },
        ),
      ),
    );
  }

  List<Word> _nextDailyWords() {
    if (widget.store.completedToday) return <Word>[];

    final dueWords = wordDatabase
        .where((word) => widget.store.dueWordIds.contains(word.id))
        .take(2)
        .toList();
    final dueIds = dueWords.map((word) => word.id).toSet();
    final learnedIds = widget.store.learnedWordIds;
    final newWords = wordDatabase
        .where(
          (word) =>
              !learnedIds.contains(word.id) &&
              !dueIds.contains(word.id) &&
              !widget.store.dueWordIds.contains(word.id),
        )
        .toList();
    if (newWords.isEmpty) return dueWords;

    final currentTopic = newWords.first.topic;
    final topicWords = newWords
        .where((word) => word.topic == currentTopic)
        .take(6 - dueWords.length)
        .toList();
    return [...dueWords, ...topicWords];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    final level = LevelInfo.fromXp(widget.store.totalXp);
    final todayQuote =
        _encouragementQuotes[DateTime.now().day % _encouragementQuotes.length];
    final dailyWords = _nextDailyWords();
    final completedTodayWordCount = widget.store.completedTodayWordIds.length;
    final dailyWordCount = widget.store.completedToday
        ? completedTodayWordCount
        : dailyWords.length;

    return FloatingPetalsBackground(
      showPetals: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          // ─── Header ──────────────────────────────────────────────
          Row(
            children: [
              GestureDetector(
                    onTap: _editName,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEADBFF), Color(0xFFC7B3FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8272D8)
                                .withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🌷', style: TextStyle(fontSize: 28)),
                      ),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    duration: 1800.ms,
                    curve: Curves.easeInOut,
                    begin: const Offset(1, 1),
                    end: const Offset(1.08, 1.08),
                  ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Assalomu alaykum, ${widget.store.learnerName}! 🌸',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Gap(6),
                        GestureDetector(
                          onTap: _editName,
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: Color(0xFF8272D8),
                          ),
                        ),
                      ],
                    ),
                    const Gap(2),
                    Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${level.emoji} ${level.title}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                          ),
                        ),
                        Text(
                          '•',
                          style: TextStyle(color: colors.outlineVariant),
                        ),
                        Text(
                          '${widget.store.totalXp} XP',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: isDark ? 'Yorug‘ rejim' : 'Qorong‘i rejim',
                onPressed: widget.onThemeToggle,
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),

          const Gap(16),

          // ─── Romantik Tezkor Tugmalar (Maktub & Alifbo) ──────────
          Row(
            children: [
              Expanded(
                child: Material(
                  color: isDark
                      ? const Color(0xFF282035)
                      : const Color(0xFFFFF0F5),
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    onTap: () => LoveLetterDialog.show(context, widget.store),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFFFC0D3).withValues(alpha: 0.6),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('💌', style: TextStyle(fontSize: 18)),
                          Gap(8),
                          Flexible(
                            child: Text(
                              'Senga maktub 🌸',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFC24177),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(10),
              Expanded(
                child: Material(
                  color: isDark
                      ? const Color(0xFF232035)
                      : const Color(0xFFF3EFFF),
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AlphabetScreen()),
                    ),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFF8272D8)
                              .withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🔤', style: TextStyle(fontSize: 18)),
                          Gap(8),
                          Flexible(
                            child: Text(
                              'Alifbo xazinasi',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF6B56BE),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 350.ms),

          const Gap(16),

          // ─── Daily Lesson Card ───────────────────────────────────
          _DailyLessonCard(
                completed: widget.store.completedToday,
                learnerName: widget.store.learnerName,
                hasTask: widget.store.completedToday || dailyWords.isNotEmpty,
                goalCount: dailyWordCount,
                completedCount: widget.store.completedToday
                    ? dailyWordCount
                    : 0,
                onTap: widget.store.completedToday || dailyWords.isEmpty
                    ? null
                    : () => _openLesson(),
              )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideY(begin: 0.1, end: 0),

          const Gap(16),

          _ReviewSection(
            dueCount: widget.store.dueWordIds.length,
            onTap: () => _openLesson(reviewOnly: true),
            onShowNotebook: _showReviewNotebook,
          ),

          const Gap(20),

          // ─── Streak Card ─────────────────────────────────────────
          _StreakCard(
            isDark: isDark,
            store: widget.store,
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

          const Gap(16),

          // ─── Muallima Dilnavoz VIP Idorasi Card ───────────────────
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TeacherHomeScreen(store: widget.store),
                ),
              ).then((_) => widget.onRefresh());
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A3525), Color(0xFF2D1E17)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F2EA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD4AF37)),
                    ),
                    child: const Center(
                      child: Text('☕', style: TextStyle(fontSize: 26)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            const Text(
                              'Muallima Idorasi',
                              style: TextStyle(
                                fontFamily: 'serif',
                                color: Color(0xFFFAF7F2),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4AF37),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Feynman ✏️',
                                style: TextStyle(
                                  color: Color(0xFF2D1E17),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Shogirdlar daftarlaridagi xatolarni qizil qalam bilan tuzating va sovg‘alar yuting!',
                          style: TextStyle(color: Color(0xFFD4C3B3), fontSize: 12, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD4AF37),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF2D1E17),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 50.ms, duration: 400.ms).slideY(begin: 0.08, end: 0),

          const Gap(16),

          // ─── Kunning Go'zal So'zi ────────────────────────────────
          const WordOfTheDayCard()
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideY(begin: 0.08, end: 0),

          const Gap(18),

          // ─── Sweet Encouragement Card ────────────────────────────
          _SweetQuoteCard(
            quote: todayQuote,
            isDark: isDark,
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

          const Gap(24),

          // ─── Mavzular bo'yicha darslar ───────────────────────────
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 4,
            children: [
              Text(
                'Mavzular olami ✨',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                '${wordDatabase.length} so‘z',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const Gap(12),

          _TopicsGrid(
            learnedIds: widget.store.learnedWordIds,
            onSelectTopic: (topic) => _openLesson(topicFilter: topic),
          ),

          const Gap(18),

          // ─── Shaxsiy yo'l (Progress) ─────────────────────────────
          _JourneyProgressCard(
            isDark: isDark,
            progress: widget.store.learnedWordIds.length / wordDatabase.length,
            learnedCount: widget.store.learnedWordIds.length,
            goalCount: wordDatabase.length,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.isDark, required this.store});

  final bool isDark;
  final LocalLearningStore store;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final monday = todayDate.subtract(Duration(days: today.weekday - 1));
    const weekdayLabels = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFE0D2), Color(0xFFFFCCBA)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('🔥', style: TextStyle(fontSize: 26)),
                ),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.streakDays == 0
                          ? 'Bugun yangi odat boshlaymiz!'
                          : '${store.streakDays} kunlik ketma-ketlik!',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const Gap(2),
                    Text(
                      store.completedToday
                          ? 'Bugungi qadam bajarildi — ajoyib natija! ✨'
                          : 'Har kungi kichik qadam katta mo‘jiza yaratadi.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(16),
          Row(
            children: [
              for (var i = 0; i < weekdayLabels.length; i++)
                Expanded(
                  child: _DayDot(
                    day: weekdayLabels[i],
                    done: store.studiedOn(monday.add(Duration(days: i))),
                    today: monday.add(Duration(days: i)) == todayDate,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({required this.day, required this.done, this.today = false});

  final String day;
  final bool done;
  final bool today;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = done ? const Color(0xFF8272D8) : colors.surfaceContainerHigh;

    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: today
                ? Border.all(color: const Color(0xFF8272D8), width: 2.5)
                : null,
          ),
          child: Icon(
            done ? Icons.check_rounded : Icons.circle,
            size: done ? 18 : 6,
            color: done
                ? Colors.white
                : colors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
        const Gap(6),
        Text(
          day,
          style: TextStyle(
            fontSize: 11,
            fontWeight: today ? FontWeight.w800 : FontWeight.w500,
            color: today ? colors.primary : colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _DailyLessonCard extends StatelessWidget {
  const _DailyLessonCard({
    required this.completed,
    required this.learnerName,
    required this.hasTask,
    required this.goalCount,
    required this.completedCount,
    required this.onTap,
  });

  final bool completed;
  final String learnerName;
  final bool hasTask;
  final int goalCount;
  final int completedCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8272D8), Color(0xFFA191F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8272D8).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      completed ? '✓ Bajarildi' : '✨ Bugungi tavsiya',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text('🌸', style: TextStyle(fontSize: 20)),
            ],
          ),
          const Gap(14),
          Text(
            completed
                ? 'Ajoyib ish, $learnerName! 💜'
                : hasTask
                ? 'Yangi so‘zlar sayohati'
                : 'Bugun dam olish kuni',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(6),
          Text(
            completed
                ? 'Bugungi marra zabt etildi. Ertaga davom etamiz.'
                : hasTask
                ? 'Har kungi kichik qadam bilan arab tilini oson o‘rganamiz.'
                : 'Bugun yangi so‘z qolmadi. Dam olib, ertaga davom etamiz.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 14,
              height: 1.35,
            ),
          ),
          if (completed || hasTask) ...[
            const Gap(16),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  completed && goalCount == 0
                      ? 'Bugungi vazifa bajarildi'
                      : '$completedCount / $goalCount ta so‘z',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  completed ? 'Ajoyib! ✨' : 'Bugungi maqsad',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Gap(8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: completed ? 1 : 0,
                minHeight: 6,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFFE59A),
                ),
              ),
            ),
          ],
          const Gap(18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.style_rounded,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const Gap(5),
                  Text(
                    '$goalCount ta so‘z',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
              if (goalCount > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      color: Color(0xFFFFE59A),
                      size: 18,
                    ),
                    const Gap(4),
                    Text(
                      '+${goalCount * 20} XP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              FilledButton(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6E5DC6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                    ),
                    child: Text(
                      completed
                          ? 'Bajarildi ✓'
                          : hasTask
                          ? 'Boshlash ✨'
                          : 'Ertaga davom',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  )
                  .animate(
                    target: (!completed && hasTask) ? 1 : 0,
                    onPlay: (ctrl) => ctrl.repeat(reverse: true),
                  )
                  .scale(
                    duration: 1200.ms,
                    begin: const Offset(1, 1),
                    end: const Offset(1.04, 1.04),
                    curve: Curves.easeInOut,
                  ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SweetQuoteCard extends StatelessWidget {
  const _SweetQuoteCard({required this.quote, required this.isDark});

  final String quote;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF26213A) : const Color(0xFFF3EFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF8272D8).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💌', style: TextStyle(fontSize: 22)),
          const Gap(12),
          Expanded(
            child: Text(
              quote,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xFFDCD6F7)
                    : const Color(0xFF5E4EAC),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicsGrid extends StatelessWidget {
  const _TopicsGrid({required this.learnedIds, required this.onSelectTopic});

  final Set<String> learnedIds;
  final ValueChanged<String> onSelectTopic;

  static const _topics = [
    (
      id: 'family',
      title: 'Oila',
      emoji: '👨‍👩‍👧',
      count: 10,
      color: Color(0xFFF3E8FF),
    ),
    (
      id: 'greetings',
      title: 'Salomlashish',
      emoji: '👋',
      count: 8,
      color: Color(0xFFE0F2FE),
    ),
    (
      id: 'numbers',
      title: 'Raqamlar',
      emoji: '🔢',
      count: 10,
      color: Color(0xFFFEF3C7),
    ),
    (
      id: 'nature',
      title: 'Tabiat',
      emoji: '🌿',
      count: 10,
      color: Color(0xFFDCFCE7),
    ),
    (
      id: 'time',
      title: 'Vaqt',
      emoji: '⏰',
      count: 10,
      color: Color(0xFFFFE4E6),
    ),
    (
      id: 'ktb',
      title: 'Kitob ildizi',
      emoji: '📚',
      count: 5,
      color: Color(0xFFEDE9FE),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.25,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _topics.length,
      itemBuilder: (context, index) {
        final topic = _topics[index];
        final topicWords = wordDatabase
            .where((w) => w.topic == topic.id)
            .toList();
        final learnedInTopic = topicWords
            .where((w) => learnedIds.contains(w.id))
            .length;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Material(
          color: isDark ? const Color(0xFF222030) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () => onSelectTopic(topic.id),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: topic.color.withValues(
                            alpha: isDark ? 0.25 : 0.8,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          topic.emoji,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      Text(
                        '$learnedInTopic/${topic.count}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${topic.count} ta so‘z',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({
    required this.dueCount,
    required this.onTap,
    required this.onShowNotebook,
  });

  final int dueCount;
  final VoidCallback onTap;
  final VoidCallback onShowNotebook;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0E3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.replay_rounded,
                    color: Color(0xFFE08B50),
                  ),
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Takrorlash vaqti',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        dueCount == 0
                            ? 'Hammasi o‘zlashtirilgan, zo‘r! 🌱'
                            : '$dueCount ta so‘z esga tushiriladi',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(8),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                TextButton.icon(
                  onPressed: onShowNotebook,
                  icon: const Icon(Icons.menu_book_rounded, size: 18),
                  label: const Text('Qiyin so‘zlar'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF8272D8),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: dueCount > 0 ? onTap : null,
                  icon: const Icon(Icons.replay_rounded, size: 18),
                  label: const Text('Takrorlash'),
                  style: FilledButton.styleFrom(
                    foregroundColor: const Color(0xFF765FCA),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _JourneyProgressCard extends StatelessWidget {
  const _JourneyProgressCard({
    required this.isDark,
    required this.progress,
    required this.learnedCount,
    required this.goalCount,
  });

  final bool isDark;
  final double progress;
  final int learnedCount;
  final int goalCount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF39334E)
                      : const Color(0xFFF0ECFF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.route_rounded,
                  color: Color(0xFF8170D4),
                ),
              ),
              const Gap(12),
              const Expanded(
                child: Text(
                  'Umumiy o‘zlashtirish',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF8170D4),
                ),
              ),
            ],
          ),
          const Gap(14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: const Color(0xFFEDEAF3),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF8D7BE0),
              ),
            ),
          ),
          const Gap(10),
          Text(
            '$learnedCount / $goalCount ta so‘z yodlandi',
            style: TextStyle(
              fontSize: 12,
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.initialName});

  final String initialName;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialName,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: [
          Text('🌷 ', style: TextStyle(fontSize: 24)),
          Text('Ismingni kirit', style: TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ilovada senga qanday murojaat qilaylik?',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const Gap(12),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 24,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Isming yoki erkalash nomi',
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Bekor qilish'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF8272D8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text('Saqlash'),
        ),
      ],
    );
  }
}
