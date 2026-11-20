import 'package:flutter/material.dart';

import '../../data/local_learning_store.dart';
import '../../widgets/floating_petals_background.dart';
import '../achievements/achievements_screen.dart';
import '../words/words_screen.dart';
import 'today_tab.dart';

class LearningHomePage extends StatefulWidget {
  const LearningHomePage({
    super.key,
    required this.store,
    required this.onThemeToggle,
  });

  final LocalLearningStore store;
  final VoidCallback onThemeToggle;

  @override
  State<LearningHomePage> createState() => _LearningHomePageState();
}

class _LearningHomePageState extends State<LearningHomePage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FloatingPetalsBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  TodayTab(
                    store: widget.store,
                    onThemeToggle: widget.onThemeToggle,
                    onRefresh: () => setState(() {}),
                  ),
                  WordsScreen(
                    learnedWordIds: widget.store.learnedWordIds,
                    onBookmarkChanged: () => setState(() {}),
                  ),
                  AchievementsScreen(
                    store: widget.store,
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          backgroundColor: isDark
              ? const Color(0xFF1A1628).withValues(alpha: 0.95)
              : const Color(0xFFFDF8FF).withValues(alpha: 0.95),
          indicatorColor: isDark
              ? const Color(0xFF5B21B6).withValues(alpha: 0.5)
              : const Color(0xFFE9D5FF),
          selectedIndex: _selectedTab,
          onDestinationSelected: (index) {
            setState(() => _selectedTab = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.wb_sunny_outlined),
              selectedIcon: Icon(Icons.wb_sunny_rounded),
              label: 'Bugun',
            ),
            NavigationDestination(
              icon: Icon(Icons.style_outlined),
              selectedIcon: Icon(Icons.style_rounded),
              label: "So'zlar",
            ),
            NavigationDestination(
              icon: Icon(Icons.emoji_events_outlined),
              selectedIcon: Icon(Icons.emoji_events_rounded),
              label: 'Yutuqlar',
            ),
          ],
        ),
      ),
    );
  }
}
