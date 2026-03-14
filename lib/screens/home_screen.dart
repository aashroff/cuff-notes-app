import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/topic.dart';
import '../models/flashcard.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/topic_card.dart';
import '../main.dart' show themeModeNotifier;
import 'study_screen.dart';
import 'quiz_screen.dart';
import 'pocket_reference_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppState appState;

  const HomeScreen({super.key, required this.appState});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showStats = false;
  final Set<String> _expandedTopics = {};

  // Shorthand accessors
  AppState get _app => widget.appState;
  List<Topic> get _topics => _app.topics;

  List<({Flashcard card, Topic topic})> get _searchResults {
    if (_searchQuery.length < 2) return [];
    final q = _searchQuery.toLowerCase();
    final results = <({Flashcard card, Topic topic})>[];
    for (final topic in _topics) {
      for (final card in topic.cards) {
        if (card.question.toLowerCase().contains(q) ||
            card.answer.toLowerCase().contains(q) ||
            card.statute.toLowerCase().contains(q)) {
          results.add((card: card, topic: topic));
        }
      }
    }
    return results;
  }

  void _navigateToStudy(Topic topic, String? subcategory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudyScreen(
          topic: topic,
          subcategory: subcategory,
          storage: _app.storage,
        ),
      ),
    ).then((_) {
      _app.notifyListeners(); // Refresh stats on return
    });
  }

  void _navigateToQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          topics: _topics,
          storage: _app.storage,
        ),
      ),
    ).then((_) {
      _app.notifyListeners();
    });
  }

  void _navigateToReference() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketReferenceScreen(sections: _app.references),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _app,
      builder: (context, _) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // ── App Bar ──
              SliverAppBar(
                floating: true,
                title: Row(
                  children: [
                    Text(
                      'Cuff',
                      style: GoogleFonts.newsreader(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Notes',
                      style: GoogleFonts.newsreader(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      _showStats ? Icons.analytics : Icons.analytics_outlined,
                      color: _showStats
                          ? Theme.of(context).colorScheme.primary
                          : context.mutedText,
                    ),
                    onPressed: () => setState(() => _showStats = !_showStats),
                  ),
                  IconButton(
                    icon: Icon(
                      Theme.of(context).brightness == Brightness.dark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                      color: context.mutedText,
                    ),
                    onPressed: () {
                      if (themeModeNotifier.value == ThemeMode.system) {
                        themeModeNotifier.value =
                            Theme.of(context).brightness == Brightness.dark
                                ? ThemeMode.light
                                : ThemeMode.dark;
                      } else if (themeModeNotifier.value == ThemeMode.dark) {
                        themeModeNotifier.value = ThemeMode.light;
                      } else {
                        themeModeNotifier.value = ThemeMode.dark;
                      }
                    },
                  ),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Stats Panel ──
                    if (_showStats) ...[
                      const SizedBox(height: 8),
                      _buildStatsPanel(context),
                    ],

                    // ── Search ──
                    const SizedBox(height: 14),
                    TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search legislation, offences, statutes...',
                        prefixIcon: Icon(Icons.search, color: context.dimText),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),

                    // ── Search Results ──
                    if (_searchQuery.length > 1) ...[
                      const SizedBox(height: 10),
                      Text(
                        '${_searchResults.length} result${_searchResults.length != 1 ? "s" : ""}',
                        style: TextStyle(fontSize: 11, color: context.dimText),
                      ),
                      const SizedBox(height: 6),
                      ..._searchResults
                          .take(10)
                          .map((r) => _buildSearchResult(context, r)),
                    ],

                    // ── Main Content (hidden during search) ──
                    if (_searchQuery.length <= 1) ...[
                      const SizedBox(height: 18),
                      _buildSectionHeader('Quick Actions'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                              child: _buildQuickAction(
                            context,
                            icon: Icons.bolt_rounded,
                            title: 'Quickfire',
                            subtitle: 'Random quiz across all topics',
                            isPrimary: true,
                            onTap: _navigateToQuiz,
                          )),
                          const SizedBox(width: 8),
                          Expanded(
                              child: _buildQuickAction(
                            context,
                            icon: Icons.bookmark_outline_rounded,
                            title: 'Reference',
                            subtitle: 'Mnemonics & quick-ref',
                            isPrimary: false,
                            onTap: _navigateToReference,
                          )),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader(
                          'Legislation Areas \u00b7 ${_app.totalCards} cards'),
                      const SizedBox(height: 10),
                      ..._topics.map((topic) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: TopicCard(
                              topic: topic,
                              masteredCount: _app.masteredForTopic(topic),
                              reviewedCount: _app.reviewedForTopic(topic),
                              isExpanded: _expandedTopics.contains(topic.id),
                              onTap: () => setState(() {
                                if (_expandedTopics.contains(topic.id)) {
                                  _expandedTopics.remove(topic.id);
                                } else {
                                  _expandedTopics.add(topic.id);
                                }
                              }),
                              onStudy: (sub) => _navigateToStudy(topic, sub),
                            ),
                          )),
                      const SizedBox(height: 80),
                    ],
                  ]),
                ),
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: 0,
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home'),
              NavigationDestination(
                  icon: Icon(Icons.bolt_outlined),
                  selectedIcon: Icon(Icons.bolt),
                  label: 'Quickfire'),
              NavigationDestination(
                  icon: Icon(Icons.bookmark_outline),
                  selectedIcon: Icon(Icons.bookmark),
                  label: 'Reference'),
            ],
            onDestinationSelected: (i) {
              if (i == 1) _navigateToQuiz();
              if (i == 2) _navigateToReference();
            },
          ),
        );
      },
    );
  }

  Widget _buildStatsPanel(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PROGRESS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: context.dimText,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _statItem(
                    context, '\ud83d\udcc7', '${_app.totalCards}', 'Cards'),
                _statItem(
                    context, '\u2705', '${_app.totalReviewed}', 'Reviewed'),
                _statItem(
                    context, '\ud83c\udfc6', '${_app.totalMastered}', 'Mastered'),
              ],
            ),
            if (_app.totalReviewed > 0) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mastery',
                      style: TextStyle(fontSize: 11, color: context.dimText)),
                  Text(
                    '${(_app.totalMastered / _app.totalCards * 100).round()}%',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: _app.totalMastered / _app.totalCards,
                  minHeight: 5,
                  backgroundColor: context.cardBg2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statItem(
      BuildContext context, String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: context.cardBg2,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(label,
                style: TextStyle(fontSize: 10, color: context.dimText)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: context.dimText,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isPrimary ? Theme.of(context).colorScheme.primary : context.cardBg,
      borderRadius: BorderRadius.circular(16),
      elevation: isPrimary ? 4 : 0,
      shadowColor: isPrimary
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
          : Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isPrimary ? null : Border.all(color: context.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28, color: isPrimary ? Colors.white : null),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isPrimary ? Colors.white : null,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isPrimary
                      ? Colors.white.withValues(alpha: 0.8)
                      : context.dimText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResult(
    BuildContext context,
    ({Flashcard card, Topic topic}) result,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _navigateToStudy(result.topic, result.card.subcategory),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: result.topic.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    result.topic.title,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: result.topic.color,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  result.card.question,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  result.card.statute,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: context.dimText,
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
