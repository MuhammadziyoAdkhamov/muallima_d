import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../models/alphabet_letter.dart';
import '../../services/audio_service.dart';
import '../../widgets/floating_petals_background.dart';

class AlphabetScreen extends StatefulWidget {
  const AlphabetScreen({super.key});

  @override
  State<AlphabetScreen> createState() => _AlphabetScreenState();
}

class _AlphabetScreenState extends State<AlphabetScreen> {
  void _showLetterDetail(AlphabetLetter letter) {
    AudioService.instance.speak(letter.char);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final colors = Theme.of(context).colorScheme;

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1C2C) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pull handle
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Gap(20),

              // Harf bosh qismi
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEADBFF), Color(0xFFC7B3FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8272D8).withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        letter.char,
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5A44B0),
                        ),
                      ),
                    ),
                  ),
                  const Gap(16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        letter.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        'Tovush: [ ${letter.sound} ]',
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton.filledTonal(
                    iconSize: 28,
                    onPressed: () => AudioService.instance.speak(letter.char),
                    icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF8272D8)),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFEDE7F6),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),

              const Gap(24),

              // 4 xil yozilishi
              Text(
                'Harfning so‘zdagi 4 xil ko‘rinishi 🌸',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Gap(12),

              Row(
                children: [
                  _LetterFormCard(label: 'Oxirida', form: letter.finalForm),
                  const Gap(8),
                  _LetterFormCard(label: 'O‘rtasida', form: letter.medial),
                  const Gap(8),
                  _LetterFormCard(label: 'Boshida', form: letter.initial),
                  const Gap(8),
                  _LetterFormCard(label: 'Alohida', form: letter.isolated),
                ],
              ),

              const Gap(22),

              // Misol so'z
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF28243A) : const Color(0xFFF7F3FF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF8272D8).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 22)),
                    const Gap(14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Misol so‘z:',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          Text(
                            letter.exampleWord,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            letter.exampleMeaning,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up_outlined, color: Color(0xFF8272D8)),
                      onPressed: () {
                        // So'zning faqat arabcha qismini talaffuz qilish
                        final arabicOnly = letter.exampleWord.split('(').first.trim();
                        AudioService.instance.speak(arabicOnly);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Arab Alifbosi 🔤', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        centerTitle: true,
      ),
      body: FloatingPetalsBackground(
        showPetals: false,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF2E2346), const Color(0xFF221A38)]
                        : [const Color(0xFFEFE8FF), const Color(0xFFFCE7F3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFF8272D8).withValues(alpha: 0.25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8272D8).withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Text('🌸', style: TextStyle(fontSize: 28)),
                    Gap(12),
                    Expanded(
                      child: Text(
                        'Arab tilida 28 ta go‘zal harf bor. Har bir harfni bosib, uning talaffuzini eshitishingiz mumkin!',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF4C369B),
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
              const Gap(16),

              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.92,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: arabicAlphabet.length,
                itemBuilder: (context, index) {
                  final letter = arabicAlphabet[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF222032) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFD1C4E9).withValues(alpha: isDark ? 0.25 : 0.6),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? const Color(0xFF161424) : const Color(0xFFD1C4E9),
                          offset: const Offset(0, 3),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showLetterDetail(letter),
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              letter.char,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Amiri',
                                color: Color(0xFF7C3AED),
                              ),
                            ),
                            const Gap(2),
                            Text(
                              letter.name,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              letter.sound,
                              style: TextStyle(
                                fontSize: 9.5,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 25 * index),
                        duration: 300.ms,
                      )
                      .scale(
                        begin: const Offset(0.85, 0.85),
                        end: const Offset(1, 1),
                        curve: Curves.easeOutBack,
                      );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LetterFormCard extends StatelessWidget {
  const _LetterFormCard({required this.label, required this.form});

  final String label;
  final String form;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF252136) : const Color(0xFFF6F2FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF8272D8).withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          children: [
            Text(
              form,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8272D8),
              ),
            ),
            const Gap(4),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
