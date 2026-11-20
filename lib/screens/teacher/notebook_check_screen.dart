import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/local_learning_store.dart';
import '../../models/teacher_models.dart';
import '../../services/audio_service.dart';

class NotebookCheckScreen extends StatefulWidget {
  const NotebookCheckScreen({
    super.key,
    required this.exercise,
    required this.store,
    required this.onCompleted,
  });

  final TeacherExercise exercise;
  final LocalLearningStore store;
  final VoidCallback onCompleted;

  @override
  State<NotebookCheckScreen> createState() => _NotebookCheckScreenState();
}

class _NotebookCheckScreenState extends State<NotebookCheckScreen> {
  // Map of fixed errors: wrong_word -> correct_word
  final Map<String, String> _fixedErrors = {};
  bool _isGraded = false;

  int get _totalErrors => widget.exercise.errors.length;
  int get _fixedCount => _fixedErrors.length;
  bool get _isAllFixed => _fixedCount >= _totalErrors;

  TeacherErrorItem? _findErrorForWord(String rawWord) {
    // Strip punctuation or compare directly
    final cleanWord = rawWord.trim();
    for (final err in widget.exercise.errors) {
      if (err.wrong == cleanWord || cleanWord.contains(err.wrong)) {
        return err;
      }
    }
    return null;
  }

  void _onWordTap(String word) {
    if (_isGraded) return;

    final error = _findErrorForWord(word);
    if (error == null) {
      // Word is grammatically correct!
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu so‘zda xato yo‘q, Muallima! Boshqa so‘zlarni ko‘zdan kechiring 🌸'),
          duration: Duration(milliseconds: 1400),
          backgroundColor: Color(0xFF5D4037),
        ),
      );
      return;
    }

    if (_fixedErrors.containsKey(error.wrong)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bu xatoni allaqachon to‘g‘riladingiz: ${error.correct} ✨'),
          duration: const Duration(milliseconds: 1400),
        ),
      );
      return;
    }

    _showCorrectionSheet(error);
  }

  void _showCorrectionSheet(TeacherErrorItem error) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFCFAF7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF0EE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF3C7C5)),
                  ),
                  child: const Row(
                    children: [
                      Text('✏️', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 4),
                      Text(
                        'Xato topildi!',
                        style: TextStyle(
                          color: Color(0xFFB94A48),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(sheetContext),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'O‘quvchi xatosi: "${error.wrong}"',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Qizil qalamingiz bilan to‘g‘ri qoidani belgilang:',
              style: TextStyle(fontSize: 13, color: Color(0xFF7A6453)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),

            // Options
            ...error.options.map((option) {
              final isCorrectOption = option == error.correct;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(sheetContext);
                    if (isCorrectOption) {
                      setState(() {
                        _fixedErrors[error.wrong] = error.correct;
                      });
                      _showRuleDialog(error);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bu variant mos kelmaydi. Qaytadan urinib ko‘ring! ✏️'),
                          backgroundColor: Color(0xFFB94A48),
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFDFCDBA), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        option,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A3525),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F2E8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEADBCC)),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Izoh: ${error.reason}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6D4C41)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRuleDialog(TeacherErrorItem error) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFFCFAF7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Text('💮', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Text(
              'To‘g‘ri tuzatildi!',
              style: TextStyle(
                fontFamily: 'serif',
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E7E34),
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${error.wrong} ➔ ${error.correct}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              error.reason,
              style: const TextStyle(fontSize: 14, color: Color(0xFF5D4037), height: 1.4),
            ),
          ],
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF4A3525),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Tushunarli ✏️', style: TextStyle(color: Color(0xFFF7D984))),
          ),
        ],
      ),
    );
  }

  void _applyGrade() async {
    setState(() => _isGraded = true);
    await widget.store.markExerciseCompleted(
      widget.exercise.id,
      widget.exercise.rewardCoins,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFFAF7F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        title: const Center(
          child: Text(
            '👑 Ofarin, Muallima! 👑',
            style: TextStyle(
              fontFamily: 'serif',
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A3525),
              fontSize: 20,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFB94A48), width: 3),
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFFFDF0EE),
              ),
              child: const Text(
                'TEKSHIRILDI: A+ (A\'LO)',
                style: TextStyle(
                  color: Color(0xFFB94A48),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${widget.exercise.studentName}ning daftari tekshirildi. Shogirdingiz xatosini anglab yetdi!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF5D4037), height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3ECE1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4AF37)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    '+${widget.exercise.rewardCoins} Muallima Tangasi!',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFFC59B27),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF4A3525),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              Navigator.pop(context); // dialog
              widget.onCompleted();
              Navigator.pop(context); // return to teacher home
            },
            child: const Text(
              'Idoraga qaytish ☕',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF7D984)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final words = widget.exercise.words;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1B1622) : const Color(0xFFFAF6F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '${widget.exercise.studentName}ning daftari',
          style: const TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Arabcha audio o‘qilishi',
            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF8C6D53)),
            onPressed: () => AudioService.instance.speak(widget.exercise.arabicText),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(widget.exercise.studentAvatar, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.exercise.topic,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDark ? Colors.white : const Color(0xFF3E2723),
                        ),
                      ),
                      Text(
                        'Xatolar: $_fixedCount / $_totalErrors ta to‘g‘rilandi',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF8C6D53)),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3ECE1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD4AF37)),
                ),
                child: Row(
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '+${widget.exercise.rewardCoins}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC59B27),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ───────── DAFTAR QOG'OZI KARTASI ─────────
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF262030) : const Color(0xFFFFFDF9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? const Color(0xFF433654) : const Color(0xFFEADBCE),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Banner instruction
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF0EE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF3C7C5)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('✏️', style: TextStyle(fontSize: 14)),
                          SizedBox(width: 6),
                          Text(
                            'Qizil qalam: Xato so‘zni bosing va to‘g‘rilang',
                            style: TextStyle(
                              color: Color(0xFFB94A48),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Arabic Words wrap
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: words.map((rawWord) {
                          final clean = rawWord.trim();
                          final error = _findErrorForWord(clean);
                          final isFixed = error != null && _fixedErrors.containsKey(error.wrong);

                          return InkWell(
                            onTap: () => _onWordTap(rawWord),
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isFixed
                                    ? const Color(0xFFEAF7ED)
                                    : (isDark ? const Color(0xFF332B40) : const Color(0xFFF9F5EE)),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isFixed
                                      ? Colors.green.shade400
                                      : error != null
                                          ? const Color(0xFFE2C4A2)
                                          : const Color(0xFFEADBCE),
                                  width: isFixed ? 2 : 1.2,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isFixed) ...[
                                    Text(
                                      _fixedErrors[error.wrong]!,
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                        fontFamily: 'Amiri',
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                  ],
                                  Text(
                                    rawWord,
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: isFixed
                                          ? const Color(0xFFB94A48)
                                          : (isDark ? Colors.white : const Color(0xFF3E2723)),
                                      decoration: isFixed ? TextDecoration.lineThrough : null,
                                      decorationColor: const Color(0xFFB94A48),
                                      decorationThickness: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Sound button
                    TextButton.icon(
                      onPressed: () => AudioService.instance.speak(widget.exercise.arabicText),
                      icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF7A6453)),
                      label: const Text(
                        'Jumlani to‘liq tinglash 🔊',
                        style: TextStyle(color: Color(0xFF7A6453), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // Muhr Stamp Overlay
              if (_isGraded)
                Positioned(
                  top: 20,
                  left: 20,
                  child: Transform.rotate(
                    angle: -0.25,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFB94A48), width: 3),
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFB94A48).withValues(alpha: 0.1),
                      ),
                      child: const Text(
                        '💮 TEKSHIRDI: DILNAVOZ',
                        style: TextStyle(
                          color: Color(0xFFB94A48),
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // ───────── MUHR BOSISH VA BAHOLASH TUGMASI ─────────
          FilledButton.icon(
            onPressed: (_isAllFixed && !_isGraded) ? _applyGrade : null,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB94A48),
              disabledBackgroundColor: isDark ? const Color(0xFF332B40) : const Color(0xFFE2D8CC),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            icon: const Icon(Icons.verified_rounded, color: Color(0xFFF7D984)),
            label: Text(
              _isGraded
                  ? 'Baho qo‘yildi (A\'lo) 💮'
                  : _isAllFixed
                      ? 'Muhr bosish: A\'lo (A+) baho 💮'
                      : 'Hali xatolar qolgan ($_fixedCount/$_totalErrors)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: (_isAllFixed && !_isGraded) ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
