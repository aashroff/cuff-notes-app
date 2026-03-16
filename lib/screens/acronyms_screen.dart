import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/acronym.dart';
import '../theme/app_theme.dart';

class AcronymsScreen extends StatefulWidget {
  final List<Acronym> acronyms;

  const AcronymsScreen({super.key, required this.acronyms});

  @override
  State<AcronymsScreen> createState() => _AcronymsScreenState();
}

class _AcronymsScreenState extends State<AcronymsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  List<Acronym> get _filtered {
    if (_query.isEmpty) return widget.acronyms;
    final q = _query.toLowerCase();
    return widget.acronyms
        .where((a) =>
            a.acronym.toLowerCase().contains(q) ||
            a.meaning.toLowerCase().contains(q) ||
            a.context.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acronym Glossary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search acronyms...',
                prefixIcon: Icon(Icons.search, color: context.dimText),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  '${results.length} acronym${results.length != 1 ? "s" : ""}',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.dimText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final a = results[index];
                final isFirst = index == 0;
                final prevLetter = isFirst
                    ? ''
                    : results[index - 1].acronym[0].toUpperCase();
                final currentLetter = a.acronym[0].toUpperCase();
                final showHeader = currentLetter != prevLetter;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Alphabet header
                    if (showHeader && _query.isEmpty) ...[
                      if (!isFirst) const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6, top: 4),
                        child: Text(
                          currentLetter,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],

                    // Acronym card
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Acronym badge
                          Container(
                            constraints: const BoxConstraints(minWidth: 60),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              a.acronym,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Meaning and context
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.meaning,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                  ),
                                ),
                                if (a.context.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    a.context,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.mutedText,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
