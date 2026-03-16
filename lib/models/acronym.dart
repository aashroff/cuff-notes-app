class Acronym {
  final String acronym;
  final String meaning;
  final String context;

  const Acronym({
    required this.acronym,
    required this.meaning,
    required this.context,
  });

  factory Acronym.fromJson(Map<String, dynamic> json) => Acronym(
        acronym: json['acronym'] as String,
        meaning: json['meaning'] as String,
        context: json['context'] as String? ?? '',
      );
}
