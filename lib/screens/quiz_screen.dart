import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/topic.dart';
import '../models/flashcard.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class QuizScreen extends StatefulWidget {
  final List<Topic> topics;
  final StorageService storage;

  const QuizScreen({super.key, required this.topics, required this.storage});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _random = Random();
  late List<({Flashcard card, Topic topic})> _allCards;

  int _correct = 0;
  int _total = 0;
  int _streak = 0;
  int _bestStreak = 0;

  late ({Flashcard card, Topic topic}) _currentQuestion;
  late List<({Flashcard card, Topic topic})> _options;
  String? _selectedId;
  bool _answered = false;
  String? _expandedOptionId;

  @override
  void initState() {
    super.initState();
    _allCards = [];
    for (final topic in widget.topics) {
      for (final card in topic.cards) {
        _allCards.add((card: card, topic: topic));
      }
    }
    _generateQuestion();
  }

  void _generateQuestion() {
    final shuffled = List.of(_allCards)..shuffle(_random);
    _currentQuestion = shuffled.first;
    final others = shuffled
        .where((c) => c.card.id != _currentQuestion.card.id)
        .take(3)
        .toList();
    _options = [...others, _currentQuestion]..shuffle(_random);
    _selectedId = null;
    _answered = false;
    _expandedOptionId = null;
  }

  void _answer(({Flashcard card, Topic topic}) option) {
    if (_answered) return;
    HapticFeedback.mediumImpact();
    final isCorrect = option.card.id == _currentQuestion.card.id;
    setState(() {
      _selectedId = option.card.id;
      _answered = true;
      _total++;
      if (isCorrect) {
        _correct++;
        _streak++;
        if (_streak > _bestStreak) _bestStreak = _streak;
      } else {
        _streak = 0;
      }
    });
  }

  void _next() {
    setState(() {
      _generateQuestion();
    });
  }

  /// Extracts the first sentence from the answer for a compact preview
  String _firstSentence(String text) {
    // Split on period followed by space or end, but not on things like "s.24" or "s.1(1)"
    final cleaned = text.replaceAll(RegExp(r's\.(\d)'), 'sSECTION\$1');
    final idx = cleaned.indexOf(RegExp(r'\.\s'));
    if (idx > 0 && idx < 150) {
      return '${text.substring(0, idx + 1)}';
    }
    if (text.length > 120) {
      // Fall back to word boundary near 120 chars
      final spaceIdx = text.lastIndexOf(' ', 120);
      return '${text.substring(0, spaceIdx > 60 ? spaceIdx : 120)}...';
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final pct = _total > 0 ? (_correct / _total * 100).round() : 0;
    final pctColor = _total > 0
        ? (_correct / _total >= 0.7 ? context.success : context.danger)
        : context.dimText;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quickfire Quiz',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // ── Compact score bar ──
            const SizedBox(height: 8),
            Row(
              children: [
                // Score pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '$_correct/$_total',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '\u{1F525} $_streak',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: context.warning,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '$pct%',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: pctColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Scrollable content ──
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Question card ──
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(_currentQuestion.topic.icon,
                                    style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _currentQuestion.topic.color
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    _currentQuestion.topic.title,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: _currentQuestion.topic.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _currentQuestion.card.question,
                              style: GoogleFonts.newsreader(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Options ──
                    ...List.generate(_options.length, (i) {
                      final opt = _options[i];
                      final isSelected = _selectedId == opt.card.id;
                      final isCorrectOption =
                          opt.card.id == _currentQuestion.card.id;

                      Color borderColor = context.borderColor;
                      Color bgColor = context.cardBg;
                      if (_answered) {
                        if (isCorrectOption) {
                          borderColor = context.success;
                          bgColor = context.success.withValues(alpha: 0.06);
                        } else if (isSelected) {
                          borderColor = context.danger;
                          bgColor = context.danger.withValues(alpha: 0.06);
                        }
                      }
                      // Highlight when held
                      final isHeld = _expandedOptionId == opt.card.id;
                      if (!_answered && isHeld) {
                        borderColor = Theme.of(context).colorScheme.primary.withValues(alpha: 0.5);
                        bgColor = Theme.of(context).colorScheme.primary.withValues(alpha: 0.04);
                      }

                      // Show full answer for correct option after answering,
                      // or when long-pressed before answering
                      final showFull =
                          (_answered && isCorrectOption) || (!_answered && isHeld);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () => _answer(opt),
                          onLongPress: _answered
                              ? null
                              : () {
                                  HapticFeedback.lightImpact();
                                  setState(() {
                                    _expandedOptionId = opt.card.id;
                                  });
                                },
                          onLongPressEnd: _answered
                              ? null
                              : (_) {
                                  setState(() {
                                    _expandedOptionId = null;
                                  });
                                },
                          child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: borderColor,
                                  width: _answered &&
                                          (isCorrectOption || isSelected)
                                      ? 1.5
                                      : 1,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Letter/check badge
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: _answered && isCorrectOption
                                          ? context.success
                                              .withValues(alpha: 0.12)
                                          : _answered && isSelected
                                              ? context.danger
                                                  .withValues(alpha: 0.12)
                                              : context.cardBg2,
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      _answered && isCorrectOption
                                          ? '\u2713'
                                          : _answered && isSelected
                                              ? '\u2717'
                                              : String.fromCharCode(65 + i),
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: _answered && isCorrectOption
                                            ? context.success
                                            : _answered && isSelected
                                                ? context.danger
                                                : context.dimText,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Statute reference - prominent
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: opt.topic.color
                                                .withValues(alpha: 0.08),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            opt.card.statute,
                                            style: GoogleFonts.jetBrainsMono(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: opt.topic.color,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Answer text
                                        AnimatedCrossFade(
                                          firstChild: Text(
                                            _firstSentence(opt.card.answer),
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              height: 1.5,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                          ),
                                          secondChild: Text(
                                            opt.card.answer,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: showFull
                                                  ? FontWeight.w500
                                                  : FontWeight.w400,
                                              height: 1.6,
                                              color: showFull
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                  : context.mutedText,
                                            ),
                                          ),
                                          crossFadeState: showFull
                                              ? CrossFadeState.showSecond
                                              : CrossFadeState.showFirst,
                                          duration:
                                              const Duration(milliseconds: 300),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      );
                    }),

                    // ── Hold hint ──
                    if (!_answered)
                      Padding(
                        padding: const EdgeInsets.only(top: 2, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.touch_app_outlined,
                                size: 13, color: context.dimText),
                            const SizedBox(width: 4),
                            Text(
                              'Hold an option to preview the full answer',
                              style: TextStyle(
                                fontSize: 11,
                                color: context.dimText,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ── Next button ──
                    if (_answered) ...[
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _next,
                          icon: const Icon(Icons.arrow_forward_rounded,
                              size: 18),
                          label: const Text('Next Question'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
