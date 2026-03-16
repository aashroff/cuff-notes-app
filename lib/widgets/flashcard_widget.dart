import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/flashcard.dart';
import '../services/statute_links.dart';
import '../theme/app_theme.dart';

class FlashcardWidget extends StatefulWidget {
  final Flashcard card;
  final Color topicColor;
  final bool showAnswer;
  final VoidCallback onTap;

  const FlashcardWidget({
    super.key,
    required this.card,
    required this.topicColor,
    required this.showAnswer,
    required this.onTap,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void didUpdateWidget(FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showAnswer != oldWidget.showAnswer) {
      if (widget.showAnswer) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
    // Reset animation when card changes
    if (widget.card.id != oldWidget.card.id) {
      _controller.reset();
      _showFront = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final isFront = angle < pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isFront ? _buildFront(context) : _buildBack(context),
          );
        },
      ),
    );
  }

  Widget _buildFront(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 280),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDifficultyAndLabel(context, 'QUESTION'),
          const SizedBox(height: 16),
          Text(
            widget.card.question,
            style: GoogleFonts.newsreader(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatuteBadge(context),
        ],
      ),
    );
  }

  Widget _buildBack(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 280),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDifficultyAndLabel(context, 'ANSWER'),
            const SizedBox(height: 16),
            Text(
              widget.card.answer,
              style: TextStyle(
                fontSize: 14,
                height: 1.75,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatuteBadge(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyAndLabel(BuildContext context, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: List.generate(3, (i) {
            return Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(right: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < widget.card.difficulty
                    ? widget.topicColor
                    : context.cardBg2,
              ),
            );
          }),
        ),
        Text(
          '$label  \u00b7  TAP TO FLIP',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: context.dimText,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildStatuteBadge(BuildContext context) {
    final url = StatuteLinks.getUrl(widget.card.statute);
    return GestureDetector(
      onTap: url != null
          ? () {
              // Stop the card flip from triggering
              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: widget.topicColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.card.statute,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: widget.topicColor,
              ),
            ),
            if (url != null) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.open_in_new_rounded,
                size: 12,
                color: widget.topicColor.withValues(alpha: 0.7),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Simplified version without full 3D flip, uses crossfade
class SimpleFlashcardWidget extends StatelessWidget {
  final Flashcard card;
  final Color topicColor;
  final bool showAnswer;
  final VoidCallback onTap;

  const SimpleFlashcardWidget({
    super.key,
    required this.card,
    required this.topicColor,
    required this.showAnswer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: Container(
          key: ValueKey(showAnswer),
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 280),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(3, (i) {
                      return Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.only(right: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < card.difficulty
                              ? topicColor
                              : context.cardBg2,
                        ),
                      );
                    }),
                  ),
                  Text(
                    '${showAnswer ? "ANSWER" : "QUESTION"}  \u00b7  TAP TO FLIP',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: context.dimText,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (!showAnswer)
                Text(
                  card.question,
                  style: GoogleFonts.newsreader(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                )
              else
                Text(
                  card.answer,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.75,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              const SizedBox(height: 16),
              Builder(builder: (context) {
                final url = StatuteLinks.getUrl(card.statute);
                return GestureDetector(
                  onTap: url != null
                      ? () {
                          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                        }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: topicColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          card.statute,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: topicColor,
                          ),
                        ),
                        if (url != null) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.open_in_new_rounded,
                            size: 12,
                            color: topicColor.withValues(alpha: 0.7),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
