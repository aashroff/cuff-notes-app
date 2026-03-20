import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/flashcard.dart';
import '../models/acronym.dart';
import '../services/statute_links.dart';
import '../theme/app_theme.dart';
import 'linked_text.dart';

/// Simplified flashcard with:
/// - Single tap to expand/collapse long text
/// - Double tap to flip between question and answer
class SimpleFlashcardWidget extends StatefulWidget {
  final Flashcard card;
  final Color topicColor;
  final bool showAnswer;
  final VoidCallback onTap;
  final List<Acronym> acronyms;

  const SimpleFlashcardWidget({
    super.key,
    required this.card,
    required this.topicColor,
    required this.showAnswer,
    required this.onTap,
    this.acronyms = const [],
  });

  @override
  State<SimpleFlashcardWidget> createState() => _SimpleFlashcardWidgetState();
}

class _SimpleFlashcardWidgetState extends State<SimpleFlashcardWidget> {
  bool _isExpanded = false;

  @override
  void didUpdateWidget(SimpleFlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset expansion when card changes or flips
    if (widget.card.id != oldWidget.card.id ||
        widget.showAnswer != oldWidget.showAnswer) {
      _isExpanded = false;
    }
  }

  void _handleTap() {
    setState(() => _isExpanded = !_isExpanded);
  }

  void _handleDoubleTap() {
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onDoubleTap: _handleDoubleTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: Container(
          key: ValueKey('${widget.showAnswer}_${widget.card.id}'),
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
              // Header row
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
                          color: i < widget.card.difficulty
                              ? widget.topicColor
                              : context.cardBg2,
                        ),
                      );
                    }),
                  ),
                  Text(
                    widget.showAnswer ? 'ANSWER' : 'QUESTION',
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

              // Content
              if (!widget.showAnswer)
                _buildTextContent(
                  context,
                  child: Text(
                    widget.card.question,
                    style: GoogleFonts.newsreader(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                    maxLines: _isExpanded ? null : 6,
                    overflow:
                        _isExpanded ? TextOverflow.visible : TextOverflow.fade,
                  ),
                )
              else
                _buildTextContent(
                  context,
                  child: LinkedText(
                    text: widget.card.answer,
                    acronyms: widget.acronyms,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.75,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),

              // Expand indicator
              if (!_isExpanded) ...[
                const SizedBox(height: 8),
                Center(
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: context.dimText.withValues(alpha: 0.5),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Statute badge
              _buildStatuteBadge(context),

              const SizedBox(height: 14),

              // Gesture hint
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: context.cardBg2,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _isExpanded
                        ? 'Tap to collapse  \u00b7  Double-tap to flip'
                        : 'Tap to expand  \u00b7  Double-tap to flip',
                    style: TextStyle(
                      fontSize: 10,
                      color: context.dimText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextContent(BuildContext context, {required Widget child}) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 250),
      crossFadeState:
          _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 160),
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.white,
                Colors.white.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.7, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: child,
        ),
      ),
      secondChild: child,
    );
  }

  Widget _buildStatuteBadge(BuildContext context) {
    final url = StatuteLinks.getUrl(widget.card.statute);
    return GestureDetector(
      onTap: url != null
          ? () {
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

/// Full 3D flip version (kept for reference but not actively used)
class FlashcardWidget extends StatefulWidget {
  final Flashcard card;
  final Color topicColor;
  final bool showAnswer;
  final VoidCallback onTap;
  final List<Acronym> acronyms;

  const FlashcardWidget({
    super.key,
    required this.card,
    required this.topicColor,
    required this.showAnswer,
    required this.onTap,
    this.acronyms = const [],
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
    if (widget.card.id != oldWidget.card.id) {
      _controller.reset();
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
      onDoubleTap: widget.onTap,
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUESTION  \u00b7  DOUBLE-TAP TO FLIP',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: context.dimText,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.card.question,
            style: GoogleFonts.newsreader(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ANSWER  \u00b7  DOUBLE-TAP TO FLIP',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: context.dimText,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            LinkedText(
              text: widget.card.answer,
              acronyms: widget.acronyms,
              style: TextStyle(
                fontSize: 14,
                height: 1.75,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
