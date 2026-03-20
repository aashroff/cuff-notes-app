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

  void _toggleExpand(String cardId) {
    setState(() {
      if (_expandedOptionId == cardId) {
        _expandedOptionId = null;
      } else {
        _expandedOptionId = cardId;
      }
    });
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

  String _getFirstSentence(String text) {
    final match = RegExp(r'[.!?]').firstMatch(text);
    if (match != null && match.start < 120) {
      return text.substring(0, match.start + 1);
    }
    if (text.length <= 80) return text;
    return text.substring(0, 80);
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
            // ── Score bar ──
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SCORE',
                            style: TextStyle(
                                fontSize: 9,
                                color: context.dimText,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w600)),
                        Text(
                          '$_correct/$_total',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('STREAK',
                            style: TextStyle(
                                fontSize: 9,
                                color: context.dimText,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w600)),
                        Text(
                          '\ud83d\udd25 $_streak',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: context.warning,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '$pct%',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: pctColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Question ──
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(_currentQuestion.topic.icon,
                                    style: const TextStyle(fontSize: 18)),
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
                            const SizedBox(height: 14),
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
                    const SizedBox(height: 8),

                    // Gesture hint
                    if (!_answered)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: context.cardBg2,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Tap to preview  \u00b7  Double-tap to answer',
                            style: TextStyle(
                              fontSize: 10,
                              color: context.dimText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),

                    // ── Options ──
                    ...List.generate(_options.length, (i) {
                      final opt = _options[i];
                      final isSelected = _selectedId == opt.card.id;
                      final isCorrectOption =
                          opt.card.id == _currentQuestion.card.id;
                      final isExpanded = _expandedOptionId == opt.card.id;

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
                      } else if (isExpanded) {
                        borderColor = Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.4);
                      }

                      final fullText = opt.card.answer;
                      final firstSentence = _getFirstSentence(fullText);
                      final hasMore = firstSentence.length < fullText.length;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _answered
                                ? null
                                : () => _toggleExpand(opt.card.id),
                            onDoubleTap:
                                _answered ? null : () => _answer(opt),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
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
                                  // Letter badge
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: _answered && isCorrectOption
                                          ? context.success
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
                                        Text(
                                          opt.card.statute,
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 10,
                                            color: isExpanded && !_answered
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : context.dimText,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        AnimatedCrossFade(
                                          duration:
                                              const Duration(milliseconds: 200),
                                          crossFadeState:
                                              (isExpanded || _answered)
                                                  ? CrossFadeState.showSecond
                                                  : CrossFadeState.showFirst,
                                          firstChild: Text(
                                            firstSentence +
                                                (hasMore ? '...' : ''),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              height: 1.4,
                                            ),
                                          ),
                                          secondChild: Text(
                                            fullText,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                        if (hasMore &&
                                            !isExpanded &&
                                            !_answered) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'Tap to read more',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: context.dimText
                                                  .withValues(alpha: 0.6),
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (hasMore && !_answered)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Icon(
                                        isExpanded
                                            ? Icons.keyboard_arrow_up_rounded
                                            : Icons
                                                .keyboard_arrow_down_rounded,
                                        size: 18,
                                        color: context.dimText
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

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
