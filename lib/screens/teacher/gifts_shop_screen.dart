import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/local_learning_store.dart';
import '../../data/teacher_database.dart';
import '../../models/teacher_models.dart';

class GiftsShopScreen extends StatefulWidget {
  const GiftsShopScreen({super.key, required this.store});

  final LocalLearningStore store;

  @override
  State<GiftsShopScreen> createState() => _GiftsShopScreenState();
}

class _GiftsShopScreenState extends State<GiftsShopScreen> {
  void _orderGift(GiftItem gift) async {
    final success = await widget.store.orderGift(gift.id, gift.priceCoins);
    if (!mounted) return;

    if (success) {
      setState(() {});
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFFFAF7F2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Text(gift.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Muborak bo‘lsin! 🎉',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Siz "${gift.giftName}" sovg‘asini muvaffaqiyatli xarid qildingiz! ✨\n\n'
            'Buyurtmangiz darhol Adminga yuborildi. Tez orada sizga yetkaziladi, azizam! 🌸',
            style: const TextStyle(color: Color(0xFF5D4037), fontSize: 15, height: 1.4),
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4A3525),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Rahmat! ☕', style: TextStyle(color: Color(0xFFF7D984))),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tangalar yetarli emas! Yana ${gift.priceCoins - widget.store.teacherCoins} ta tanga kerak. Daftarlarni tekshiring! ✏️',
          ),
          backgroundColor: const Color(0xFFB94A48),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coins = widget.store.teacherCoins;
    final orderedIds = widget.store.orderedGiftIds;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1B1622) : const Color(0xFFFAF6F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Sovg‘alar Do‘koni 🎁',
          style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2234) : const Color(0xFFF2E9DE),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD4AF37)),
            ),
            child: Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  '$coins tanga',
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A3525), Color(0xFF2E1F14)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('☕', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(
                      'Muallima Mehnatining Mukofoti',
                      style: TextStyle(
                        color: Colors.amber.shade200,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Yig‘ilgan tangalaringizni o‘zingiz yoqtirgan real sovg‘alarga almashtiring. Har bir sovg‘a siz uchun muhabbat bilan tayyorlanadi! 💖',
                  style: TextStyle(color: Color(0xFFE2D6CA), fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0),

          const SizedBox(height: 20),

          ...initialGiftsList.asMap().entries.map((entry) {
            final idx = entry.key;
            final gift = entry.value;
            final isOrdered = orderedIds.contains(gift.id);
            final canAfford = coins >= gift.priceCoins;
            final progress = (coins / gift.priceCoins).clamp(0.0, 1.0);

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF262030) : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isOrdered
                      ? Colors.green.shade400
                      : canAfford
                          ? const Color(0xFFD4AF37)
                          : const Color(0xFFEADBCE),
                  width: canAfford ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F2EA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE3D4C3)),
                        ),
                        child: Center(
                          child: Text(gift.icon, style: const TextStyle(fontSize: 28)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gift.giftName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark ? Colors.white : const Color(0xFF3E2723),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              gift.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey.shade400 : const Color(0xFF7A6453),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Text('🪙', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 4),
                              Text(
                                '${gift.priceCoins}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFFC59B27),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          isOrdered
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.green.shade200),
                                  ),
                                  child: Text(
                                    'Buyurtma berilgan ✨',
                                    style: TextStyle(
                                      color: Colors.green.shade800,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                )
                              : FilledButton(
                                  onPressed: canAfford ? () => _orderGift(gift) : null,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF4A3525),
                                    disabledBackgroundColor: const Color(0xFFE8DFC8),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(
                                    canAfford ? 'Xarid qilish' : 'Yana biroz',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: canAfford ? const Color(0xFFF7D984) : Colors.brown.shade300,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                  if (!isOrdered) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: const Color(0xFFF3ECE1),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC59B27)),
                      borderRadius: BorderRadius.circular(6),
                      minHeight: 5,
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 100 + idx * 70)).slideY(begin: 0.1, end: 0);
          }),
        ],
      ),
    );
  }
}
