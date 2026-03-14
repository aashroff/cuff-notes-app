import 'package:flutter/material.dart';

class ReferenceItem {
  final String letter;
  final String text;

  const ReferenceItem({required this.letter, required this.text});

  factory ReferenceItem.fromJson(Map<String, dynamic> json) => ReferenceItem(
        letter: json['letter'] as String,
        text: json['text'] as String,
      );
}

class ReferenceSection {
  final String id;
  final String title;
  final String subtitle;
  final Color color;
  final List<ReferenceItem> items;

  const ReferenceSection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.items,
  });

  factory ReferenceSection.fromJson(Map<String, dynamic> json) {
    final colorHex = (json['color'] as String).replaceFirst('#', '');
    return ReferenceSection(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      color: Color(int.parse('FF$colorHex', radix: 16)),
      items: (json['items'] as List<dynamic>)
          .map((i) => ReferenceItem.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}
