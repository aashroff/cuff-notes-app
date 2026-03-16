import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/acronym.dart';
import '../theme/app_theme.dart';

/// Renders text with known acronyms highlighted and tappable.
/// Tapping an acronym shows a bottom sheet with the full meaning.
class LinkedText extends StatelessWidget {
  final String text;
  final List<Acronym> acronyms;
  final TextStyle? style;

  const LinkedText({
    super.key,
    required this.text,
    required this.acronyms,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (acronyms.isEmpty) {
      return Text(text, style: style);
    }

    // Build a map of acronym strings to their data for quick lookup
    final acronymMap = <String, Acronym>{};
    for (final a in acronyms) {
      acronymMap[a.acronym] = a;
    }

    // Sort by length descending so longer acronyms match first
    // e.g. "ASBCPA" matches before "ASB"
    final sortedKeys = acronymMap.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    // Build regex that matches any known acronym as a whole word
    final pattern = sortedKeys
        .map((k) => RegExp.escape(k))
        .join('|');
    final regex = RegExp('\\b($pattern)\\b');

    // Split text into spans
    final spans = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      // Add plain text before this match
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: style,
        ));
      }

      // Add highlighted acronym
      final matched = match.group(0)!;
      final acronym = acronymMap[matched]!;
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: _AcronymChip(
          acronym: acronym,
          textStyle: style,
        ),
      ));

      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: style,
      ));
    }

    return Text.rich(
      TextSpan(children: spans),
    );
  }
}

class _AcronymChip extends StatelessWidget {
  final Acronym acronym;
  final TextStyle? textStyle;

  const _AcronymChip({required this.acronym, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDefinition(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
        ),
        child: Text(
          acronym.acronym,
          style: (textStyle ?? const TextStyle()).copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showDefinition(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: context.dimText.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Acronym badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  acronym.acronym,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Full meaning
              Text(
                acronym.meaning,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              if (acronym.context.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  acronym.context,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.mutedText,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
