enum QuestionType { mcq, flashcard, typeAnswer }

class Question {
  final String id; // word id
  final String arabic;
  final String transliteration;
  final String correctAnswer;
  final List<String> options; // MCQ uchun 4 ta variant
  final QuestionType type;
  final String root;

  const Question({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.correctAnswer,
    required this.options,
    required this.type,
    required this.root,
  });
}
