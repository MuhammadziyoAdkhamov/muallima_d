class Word {
  final String id;
  final String arabic;
  final String transliteration;
  final String meaning;
  final String root;
  final String topic; // 'family', 'numbers', 'nature', 'time', 'greetings', 'ktb'
  final String topicUz; // O'zbekcha mavzu nomi
  final String emoji;

  const Word({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.root,
    required this.topic,
    required this.topicUz,
    required this.emoji,
  });
}
