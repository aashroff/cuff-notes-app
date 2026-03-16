import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/topic.dart';
import '../models/flashcard.dart';
import '../models/acronym.dart';
import '../models/srs_state.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/flashcard_widget.dart';
import '../widgets/srs_buttons.dart';

class StudyScreen extends StatefulWidget {
  final Topic topic;
  final String? subcategory;
  final StorageService storage;
  final List<Acronym> acronyms;

  const StudyScreen({
    super.key,
    required this.topic,
    this.subcategory,
    required this.storage,
    this.acronyms = const [],
  });

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  late List<Flashcard> _cards;
  int _currentIndex = 0;
  bool _showAnswer = false;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _cards = widget.topic.cardsForSub(widget.subcategory);
  }

  Flashcard get _currentCard => _cards[_currentIndex];

  void _flip() {
    HapticFeedback.lightImpact();
    setState(() => _showAnswer = !_showAnswer);
  }

  void _rate(int quality) {
    HapticFeedback.mediumImpact();
    final existing = widget.storage.getSrsState(_currentCard.id);
    final state = (existing ?? SrsState.initial(_currentCard.id)).review(quality);
    widget.storage.saveSrsState(state);

    if (_currentIndex < _cards.length - 1) {
      setState(() {
        _currentIndex++;
        _showAnswer = false;
      });
    } else {
      setState(() => _isComplete = true);
    }
  }

  void _restart() {
    setState(() {
      _currentIndex = 0;
      _showAnswer = false;
      _isComplete = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isComplete) return _buildCompleteScreen(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.subcategory ?? widget.topic.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: widget.topic.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.topic.icon,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const Spacer(),
                Text(
                  '${_currentIndex + 1}/${_cards.length}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    color: context.dimText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / _cards.length,
                minHeight: 3,
                backgroundColor: context.cardBg2,
                valueColor: AlwaysStoppedAnimation(widget.topic.color),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SimpleFlashcardWidget(
                      key: ValueKey('${_currentCard.id}_$_showAnswer'),
                      card: _currentCard,
                      topicColor: widget.topic.color,
                      showAnswer: _showAnswer,
                      onTap: _flip,
                      acronyms: widget.acronyms,
                    ),
                    const SizedBox(height: 16),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _showAnswer
                          ? SrsRatingButtons(
                              key: const ValueKey('srs'),
                              onRate: _rate,
                            )
                          : const SizedBox.shrink(key: ValueKey('empty')),
                    ),
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

  Widget _buildCompleteScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('\ud83c\udf89', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 20),
              Text(
                'Deck Complete!',
                style: GoogleFonts.newsreader(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You\'ve reviewed all ${_cards.length} cards in this set.\nKeep practising to build long-term retention.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.mutedText,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: _restart,
                    icon: const Icon(Icons.replay_rounded, size: 18),
                    label: const Text('Review Again'),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Home'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
