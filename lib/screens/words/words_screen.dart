import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/word.dart';
import '../../data/word_database.dart';
import '../../services/audio_service.dart';

class WordsScreen extends StatefulWidget {
  const WordsScreen({
    super.key,
    required this.learnedWordIds,
    this.onBookmarkChanged,
  });

  final Set<String> learnedWordIds;
  final VoidCallback? onBookmarkChanged;

  @override
  State<WordsScreen> createState() => _WordsScreenState();
}

class _WordsScreenState extends State<WordsScreen> {
  String _selectedTopic = 'all';
  String _searchQuery = '';
  Set<String> _bookmarkedIds = {};
  final TextEditingController _searchController = TextEditingController();

  static const _topics = [
    ('all', 'Hammasi', '📖'),
    ('family', 'Oila', '👨‍👩‍👧'),
    ('greetings', 'Salom', '👋'),
    ('numbers', 'Raqamlar', '🔢'),
    ('nature', 'Tabiat', '🌿'),
    ('time', 'Vaqt', '⏰'),
    ('ktb', 'Kitob', '📚'),
  ];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('bookmarkedWordIds') ?? [];
    if (mounted) setState(() => _bookmarkedIds = ids.toSet());
  }

  Future<void> _toggleBookmark(String wordId) async {
    setState(() {
      if (_bookmarkedIds.contains(wordId)) {
        _bookmarkedIds.remove(wordId);
      } else {
        _bookmarkedIds.add(wordId);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bookmarkedWordIds', _bookmarkedIds.toList());
    widget.onBookmarkChanged?.call();
  }

  List<Word> get _filtered {
    return wordDatabase.where((w) {
      final topicMatch = _selectedTopic == 'all' || w.topic == _selectedTopic;
      final q = _searchQuery.toLowerCase();
      final searchMatch =
          q.isEmpty ||
          w.arabic.contains(q) ||
          w.meaning.toLowerCase().contains(q) ||
          w.transliteration.toLowerCase().contains(q);
      return topicMatch && searchMatch;
    }).toList();
  }

  void _openDetail(Word word) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WordDetailSheet(
        word: word,
        isLearned: widget.learnedWordIds.contains(word.id),
        isBookmarked: _bookmarkedIds.contains(word.id),
        onBookmarkToggle: () => _toggleBookmark(word.id),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final filtered = _filtered;

    return CustomScrollView(
      slivers: [
        // Sticky header
        SliverAppBar(
          pinned: true,
          floating: true,
          expandedHeight: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          title: Text(
            "So'zlar olami",
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(120),
            child: Column(
              children: [
                // Qidiruv
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: "Arab yoki o'zbek tilida qidirish...",
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: colors.surfaceContainerHigh,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
                // Mavzu filtri
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _topics.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final (topic, label, emoji) = _topics[i];
                      final selected = _selectedTopic == topic;
                      return FilterChip(
                        selected: selected,
                        label: Text('$emoji $label'),
                        onSelected: (_) =>
                            setState(() => _selectedTopic = topic),
                        selectedColor: const Color(0xFF8272D8)
                            .withValues(alpha: 0.18),
                        checkmarkColor: const Color(0xFF8272D8),
                        labelStyle: TextStyle(
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.normal,
                          color: selected
                              ? const Color(0xFF6554B7)
                              : colors.onSurface,
                        ),
                        side: BorderSide(
                          color: selected
                              ? const Color(0xFF8272D8)
                              : colors.outlineVariant,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        // So'zlar soni
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
          sliver: SliverToBoxAdapter(
            child: Text(
              '${filtered.length} ta so\'z',
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
          ),
        ),
        // So'zlar listi
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          sliver: filtered.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Column(
                      children: [
                        const Text('🔍', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          "Hech narsa topilmadi",
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (_, index) {
                    final word = filtered[index];
                    return _WordCard(
                          word: word,
                          isLearned: widget.learnedWordIds.contains(word.id),
                          isBookmarked: _bookmarkedIds.contains(word.id),
                          onTap: () => _openDetail(word),
                          onBookmark: () => _toggleBookmark(word.id),
                        )
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: index * 40),
                          duration: 350.ms,
                        )
                        .slideX(
                          begin: 0.08,
                          end: 0,
                          delay: Duration(milliseconds: index * 40),
                          duration: 350.ms,
                          curve: Curves.easeOut,
                        );
                  },
                ),
        ),
      ],
    );
  }
}

// ─────────────── _WordCard ───────────────
class _WordCard extends StatelessWidget {
  const _WordCard({
    required this.word,
    required this.isLearned,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmark,
  });

  final Word word;
  final bool isLearned;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD1C4E9).withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8272D8).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Mavzu emojisi
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE8FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(word.emoji, style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            word.arabic,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontSize: 24,
                              fontFamily: 'Amiri',
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4C1D95),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isLearned)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1FAE5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '✓',
                                style: TextStyle(
                                  color: Color(0xFF059669),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '[ ${word.transliteration} ] · ${word.meaning}',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ildiz: ${word.root}',
                        style: const TextStyle(
                          color: Color(0xFF8272D8),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                // Audio icon
                IconButton(
                  icon: const Icon(
                    Icons.volume_up_outlined,
                    color: Color(0xFF8272D8),
                    size: 20,
                  ),
                  tooltip: 'Talaffuz',
                  onPressed: () => AudioService.instance.speak(word.arabic),
                ),
                // Bookmark icon
                IconButton(
                  icon: Icon(
                    isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: isBookmarked
                        ? const Color(0xFF8272D8)
                        : colors.onSurfaceVariant,
                  ),
                  onPressed: onBookmark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────── _WordDetailSheet ───────────────
class _WordDetailSheet extends StatefulWidget {
  const _WordDetailSheet({
    required this.word,
    required this.isLearned,
    required this.isBookmarked,
    required this.onBookmarkToggle,
  });

  final Word word;
  final bool isLearned;
  final bool isBookmarked;
  final VoidCallback onBookmarkToggle;

  @override
  State<_WordDetailSheet> createState() => _WordDetailSheetState();
}

class _WordDetailSheetState extends State<_WordDetailSheet> {
  late bool _bookmarked;

  @override
  void initState() {
    super.initState();
    _bookmarked = widget.isBookmarked;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final word = widget.word;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Arab yozuvi
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8272D8), Color(0xFF6554B7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text(
                          word.arabic,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 56,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          duration: 400.ms,
                          curve: Curves.easeOut,
                        ),
                    const SizedBox(height: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => AudioService.instance.speak(word.arabic),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.volume_up_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Talaffuzi: [ ${word.transliteration} ]',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Ma'lumotlar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: '🗣️',
                      label: "O'zbekcha ma'no",
                      value: word.meaning,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: '🌱',
                      label: 'Ildiz (root)',
                      value: word.root,
                      valueStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8272D8),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: word.emoji,
                      label: 'Mavzu',
                      value: word.topicUz,
                    ),
                    if (widget.isLearned) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          children: [
                            Text('✓', style: TextStyle(fontSize: 18)),
                            SizedBox(width: 10),
                            Text(
                              "Bu so'z o'rganilgan!",
                              style: TextStyle(
                                color: Color(0xFF059669),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    // Tugmalar
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() => _bookmarked = !_bookmarked);
                              widget.onBookmarkToggle();
                            },
                            icon: Icon(
                              _bookmarked
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                            ),
                            label: Text(_bookmarked ? 'Saqlangan' : "Saqlash"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _bookmarked
                                  ? const Color(0xFF8272D8)
                                  : null,
                              side: BorderSide(
                                color: _bookmarked
                                    ? const Color(0xFF8272D8)
                                    : colors.outline,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              minimumSize: const Size(0, 48),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "«${word.meaning}» darsga qo'shildi! 📚",
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_rounded),
                            label: const Text("Darsga qo'shish"),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF8272D8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              minimumSize: const Size(0, 48),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final String icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style:
                      valueStyle ??
                      Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
