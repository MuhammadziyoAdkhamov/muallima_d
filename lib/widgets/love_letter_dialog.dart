import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../data/local_learning_store.dart';

class LoveLetterDialog extends StatefulWidget {
  const LoveLetterDialog({super.key, required this.store});

  final LocalLearningStore store;

  static Future<void> show(BuildContext context, LocalLearningStore store) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => LoveLetterDialog(store: store),
    );
  }

  @override
  State<LoveLetterDialog> createState() => _LoveLetterDialogState();
}

class _LoveLetterDialogState extends State<LoveLetterDialog> {
  bool _isEditing = false;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.store.letterText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveLetter() async {
    await widget.store.setLetterText(_controller.text);
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1A2C) : const Color(0xFFFCF9FF),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: const Color(0xFFE2D6FF),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8272D8).withValues(alpha: 0.3),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Yuqori konvert va gul
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFE3EC), Color(0xFFEADAFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('💌', style: TextStyle(fontSize: 32)),
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
              const Gap(14),

              Text(
                'Malikamga maktub 🌸',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF7A65CC),
                    ),
                textAlign: TextAlign.center,
              ),
              const Gap(4),
              const Text(
                'Yurakdan chiqqan eng ezgu tilaklar',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const Gap(18),

              // Maktub matni qutisi
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF272338)
                      : const Color(0xFFFFF7FA),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFFFFDDE8).withValues(alpha: 0.6),
                  ),
                ),
                child: _isEditing
                    ? TextField(
                        controller: _controller,
                        maxLines: 8,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: isDark ? Colors.white : const Color(0xFF4A3E6D),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Maktubingizni yozing...',
                        ),
                      )
                    : Text(
                        _controller.text,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.55,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFFEDE8F5)
                              : const Color(0xFF43346A),
                        ),
                      ),
              ),

              const Gap(20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      if (_isEditing) {
                        _saveLetter();
                      } else {
                        setState(() => _isEditing = true);
                      }
                    },
                    icon: Icon(
                      _isEditing ? Icons.check_rounded : Icons.edit_outlined,
                      size: 18,
                      color: const Color(0xFF8272D8),
                    ),
                    label: Text(
                      _isEditing ? 'Saqlash' : 'Tahrirlash',
                      style: const TextStyle(
                        color: Color(0xFF8272D8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF8272D8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Yopish 💜',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
