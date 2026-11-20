import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/local_learning_store.dart';
import '../../data/teacher_database.dart';
import '../../models/teacher_models.dart';
import 'gifts_shop_screen.dart';
import 'notebook_check_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key, required this.store});

  final LocalLearningStore store;

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  void _openCheckScreen(TeacherExercise exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotebookCheckScreen(
          exercise: exercise,
          store: widget.store,
          onCompleted: () => setState(() {}),
        ),
      ),
    ).then((_) => setState(() {}));
  }

  void _openGiftsShop() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GiftsShopScreen(store: widget.store),
      ),
    ).then((_) => setState(() {}));
  }

  void _showAdminOrdersDialog() {
    final orderedIds = widget.store.orderedGiftIds;
    final orderedGifts =
        initialGiftsList.where((g) => orderedIds.contains(g.id)).toList();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFFAF7F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Text('🛡️', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Text(
              'Admin Nazorati',
              style: TextStyle(
                fontFamily: 'serif',
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dilnavoz xonimning sovg‘a buyurtmalari:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
            ),
            const SizedBox(height: 10),
            if (orderedGifts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Hozircha yangi buyurtmalar yo‘q. Tangalar yig‘ilmoqda 🌸'),
              )
            else
              ...orderedGifts.map(
                (g) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDFCDBA)),
                  ),
                  child: Row(
                    children: [
                      Text(g.icon, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          g.giftName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Kutilmoqda 🎁',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yopish', style: TextStyle(color: Color(0xFF4A3525))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coins = widget.store.teacherCoins;
    final completedIds = widget.store.completedExerciseIds;
    final completedCount = completedIds.length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1B1622) : const Color(0xFFFAF6F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Muallima Idorasi ☕',
          style: TextStyle(
            fontFamily: 'serif',
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A3525),
          ),
        ),
        actions: [
          // Admin icon
          IconButton(
            tooltip: 'Admin Nazorat Paneli',
            icon: const Icon(Icons.shield_outlined, color: Color(0xFF8C6D53)),
            onPressed: _showAdminOrdersDialog,
          ),
          // Coins indicator
          InkWell(
            onTap: _openGiftsShop,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              margin: const EdgeInsets.only(right: 14, top: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2234) : const Color(0xFFF2E9DE),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD4AF37)),
              ),
              child: Row(
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 15)),
                  const SizedBox(width: 6),
                  Text(
                    '$coins',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC59B27),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ───────── Kofe & Tillarang Muallima Banneri ─────────
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A3525), Color(0xFF2D1E17)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Text('👑', style: TextStyle(fontSize: 12)),
                          SizedBox(width: 6),
                          Text(
                            'Oliy Toifali Ustoz',
                            style: TextStyle(
                              color: Color(0xFFF7D984),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text('☕✨', style: TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Xush kelibsiz, Muallima Dilnavoz xonim!',
                  style: TextStyle(
                    fontFamily: 'serif',
                    color: Color(0xFFFAF7F2),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Bugun virtual shogirdlaringiz sizning adolatli bahoingizni kutmoqda. Qizil qalamingiz bilan xatolarni tuzating!',
                  style: TextStyle(color: Color(0xFFD4C3B3), fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniStat('⭐ 5.0', 'Ustozlik Reytingi'),
                      Container(width: 1, height: 24, color: Colors.white24),
                      _buildMiniStat('🪙 $coins', 'Muallima Tangasi'),
                      Container(width: 1, height: 24, color: Colors.white24),
                      _buildMiniStat('$completedCount / 5', 'Tekshirildi'),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0),

          const SizedBox(height: 24),

          // ───────── SOVG'ALAR DO'KONI TEASER ─────────
          InkWell(
            onTap: _openGiftsShop,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF262030) : const Color(0xFFF7F2EA),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD4AF37)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('🎁', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sovg‘alar Do‘koni',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF4A3525),
                          ),
                        ),
                        Text(
                          'Tangalaringizni shokolad, kofe va kinoga almashtiring',
                          style: TextStyle(fontSize: 11, color: Colors.brown.shade400),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFC59B27)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('📚', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text(
                    'Shogirdlar Daftarlari (5 ta vazifa)',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                ],
              ),
              Text(
                '$completedCount ta tayyor',
                style: const TextStyle(fontSize: 12, color: Color(0xFF8C6D53), fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ───────── DAFTARLAR RO'YXATI ─────────
          ...initialTeacherExercises.asMap().entries.map((entry) {
            final idx = entry.key;
            final ex = entry.value;
            final isDone = completedIds.contains(ex.id);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF262030) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDone ? Colors.green.shade300 : const Color(0xFFEADBCE),
                  width: isDone ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F2EA),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE3D4C3)),
                  ),
                  child: Center(
                    child: Text(ex.studentAvatar, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      '${ex.studentName}ning daftari',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    if (isDone) ...[
                      const SizedBox(width: 6),
                      const Text('💮 A\'lo', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 3),
                    Text(
                      ex.topic,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF7A6453)),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      ex.arabicText,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 16,
                        color: Color(0xFF4A3525),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                trailing: FilledButton(
                  onPressed: () => _openCheckScreen(ex),
                  style: FilledButton.styleFrom(
                    backgroundColor: isDone ? Colors.green.shade50 : const Color(0xFF4A3525),
                    foregroundColor: isDone ? Colors.green.shade800 : const Color(0xFFF7D984),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: Text(
                    isDone ? 'Ko‘rish' : 'Tekshirish ✏️',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 80 + idx * 60)).slideY(begin: 0.08, end: 0);
          }),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFF7D984),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Color(0xFFD4C3B3), fontSize: 11),
        ),
      ],
    );
  }
}
