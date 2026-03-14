import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SrsRatingButtons extends StatelessWidget {
  final void Function(int quality) onRate;

  const SrsRatingButtons({super.key, required this.onRate});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'How well did you know this?',
          style: TextStyle(fontSize: 12, color: context.dimText),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _button(context, 'Again', '1d', 0, context.danger),
            const SizedBox(width: 6),
            _button(context, 'Hard', '3d', 1, context.warning),
            const SizedBox(width: 6),
            _button(context, 'Good', '7d', 2, context.success),
            const SizedBox(width: 6),
            _button(context, 'Easy', '14d', 3, Theme.of(context).colorScheme.primary),
          ],
        ),
      ],
    );
  }

  Widget _button(BuildContext context, String label, String interval, int quality, Color color) {
    return Expanded(
      child: Material(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onRate(quality),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  interval,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: color.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
