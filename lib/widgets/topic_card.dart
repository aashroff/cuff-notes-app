import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/topic.dart';
import '../theme/app_theme.dart';

class TopicCard extends StatelessWidget {
  final Topic topic;
  final int masteredCount;
  final int reviewedCount;
  final bool isExpanded;
  final VoidCallback onTap;
  final void Function(String? subcategory) onStudy;

  const TopicCard({
    super.key,
    required this.topic,
    required this.masteredCount,
    required this.reviewedCount,
    required this.isExpanded,
    required this.onTap,
    required this.onStudy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main topic row
        Material(
          color: context.cardBg,
          borderRadius: isExpanded
              ? const BorderRadius.vertical(top: Radius.circular(14))
              : BorderRadius.circular(14),
          child: InkWell(
            borderRadius: isExpanded
                ? const BorderRadius.vertical(top: Radius.circular(14))
                : BorderRadius.circular(14),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: isExpanded
                    ? const BorderRadius.vertical(top: Radius.circular(14))
                    : BorderRadius.circular(14),
                border: Border.all(color: context.borderColor),
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: topic.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(topic.icon, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  // Title and stats
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic.title,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              '${topic.cards.length} cards',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                color: context.dimText,
                              ),
                            ),
                            if (masteredCount > 0) ...[
                              Text(' \u00b7 ', style: TextStyle(color: context.dimText, fontSize: 11)),
                              Text(
                                '$masteredCount mastered',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  color: context.success,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (reviewedCount > 0) ...[
                          const SizedBox(height: 5),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: masteredCount / topic.cards.length,
                              minHeight: 3,
                              backgroundColor: context.cardBg2,
                              valueColor: AlwaysStoppedAnimation(topic.color),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Expand arrow
                  AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: context.dimText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Expanded subcategories
        if (isExpanded)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
              border: Border.all(color: context.borderColor),
              // Remove top border to blend with header
            ),
            child: Column(
              children: [
                // Study All button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => onStudy(null),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      'Study All ${topic.cards.length} Cards',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Subcategory buttons
                ...topic.subcategories.map((sub) {
                  final count = topic.cardsForSub(sub).length;
                  return Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: SizedBox(
                      width: double.infinity,
                      child: Material(
                        color: context.cardBg2,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => onStudy(sub),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    sub,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$count',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 11,
                                    color: context.dimText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }
}
