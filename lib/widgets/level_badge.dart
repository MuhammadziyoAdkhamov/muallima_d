import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/achievement.dart';

/// Darajani ko'rsatuvchi badge: emoji + raqam + nomi
class LevelBadge extends StatelessWidget {
  const LevelBadge({
    super.key,
    required this.xp,
    this.showLabel = true,
    this.size = 56,
  });

  final int xp;
  final bool showLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final info = LevelInfo.fromXp(xp);
    final colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8272D8), Color(0xFF6554B7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8272D8).withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              info.emoji,
              style: TextStyle(fontSize: size * 0.44),
            ),
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.8, 0.8),
              duration: 500.ms,
              curve: Curves.easeOutBack,
            ),
        if (showLabel) ...[
          const SizedBox(height: 6),
          Text(
            '${info.level}-daraja',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            info.title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
