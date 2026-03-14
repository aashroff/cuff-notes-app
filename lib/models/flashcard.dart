class Flashcard {
  final String id;
  final String question;
  final String answer;
  final String statute;
  final String subcategory;
  final int difficulty;
  final List<String> tags;

  const Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    required this.statute,
    required this.subcategory,
    this.difficulty = 1,
    this.tags = const [],
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      statute: json['statute'] as String,
      subcategory: json['subcategory'] as String? ?? '',
      difficulty: json['difficulty'] as int? ?? 1,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'answer': answer,
    'statute': statute,
    'subcategory': subcategory,
    'difficulty': difficulty,
    'tags': tags,
  };
}
