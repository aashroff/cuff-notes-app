import 'package:flutter/material.dart';
import 'flashcard.dart';

class Topic {
  final String id;
  final String title;
  final String icon;
  final Color color;
  final int version;
  final List<String> subcategories;
  final List<Flashcard> cards;

  const Topic({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    this.version = 1,
    this.subcategories = const [],
    this.cards = const [],
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    final colorHex = (json['color'] as String).replaceFirst('#', '');
    return Topic(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String,
      color: Color(int.parse('FF$colorHex', radix: 16)),
      version: json['version'] as int? ?? 1,
      subcategories: (json['subcategories'] as List<dynamic>?)?.cast<String>() ?? [],
      cards: (json['cards'] as List<dynamic>?)
              ?.map((c) => Flashcard.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  List<Flashcard> cardsForSub(String? sub) {
    if (sub == null) return cards;
    return cards.where((c) => c.subcategory == sub).toList();
  }
}
