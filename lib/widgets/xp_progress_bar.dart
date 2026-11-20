import 'package:flutter/material.dart';

import '../../models/achievement.dart';

/// Joriy level ichidagi XP progressi
class XpProgressBar extends StatelessWidget {
  const XpProgressBar({
    super.key,
    required this.xp,
    this.height = 10,
    this.showLabel = true,
  });

  final int xp;
  final double height;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final info = LevelInfo.fromXp(xp);
    final progress = info.progressForXp(xp);
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(height),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOut,
            builder: (context, value, child) => LinearProgressIndicator(
              value: value,
              minHeight: height,
              backgroundColor: colors.surfaceContainerHigh,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8272D8)),
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$xp XP',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${info.maxXp} XP',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
