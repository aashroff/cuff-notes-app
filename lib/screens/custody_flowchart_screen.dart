import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CustodyFlowchartScreen extends StatefulWidget {
  const CustodyFlowchartScreen({super.key});

  @override
  State<CustodyFlowchartScreen> createState() => _CustodyFlowchartScreenState();
}

class _CustodyFlowchartScreenState extends State<CustodyFlowchartScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  int _currentStep = -1;
  bool _autoPlay = false;

  static const _steps = [
    _FlowStep(
      number: '1',
      title: 'Notify Custody',
      description: 'En-route to custody, contact XH (control) to the relevant custody know that you\'re on your way. This allows the custody sergeant to prepare.',
      sideNote: null,
      icon: '🚔',
      color: Color(0xFF3B82F6),
    ),
    _FlowStep(
      number: '2',
      title: 'Record Times',
      description: 'Record the time of arrest and the time of arrival at the station. These are critical for the detention clock.',
      sideNote: 'Holding cell? Search the room first before placing the prisoner inside!',
      icon: '📝',
      color: Color(0xFFE05252),
    ),
    _FlowStep(
      number: '3',
      title: 'Present to Custody Sergeant',
      description: 'Present the circumstances of the arrest, the offence(s), and the necessity criteria to the custody sergeant.\n\nThe custody sergeant decides whether to authorise detention.',
      sideNote: 'Handcuffs? You decide! Dynamic risk assessment based on the prisoner\'s behaviour.',
      icon: '👮',
      color: Color(0xFF6B8AEE),
    ),
    _FlowStep(
      number: '4',
      title: 'S54 PACE Search',
      description: 'Conduct a search under s54 PACE. Must be same sex.\n\nProcedure: WAND - SEARCH - WAND\n\nRemove belts, watches, jewellery (unless you need the fire brigade!). Place items out of reach on the custody desk.',
      sideNote: 'Farrier technique for shoes: block the foot nearest to you, get the prisoner to lift their other foot. Ready to catch low down.',
      icon: '🔍',
      color: Color(0xFFD4A853),
    ),
    _FlowStep(
      number: '5',
      title: 'Cell Procedure',
      description: 'Before placing prisoner in the cell:\n\n\u2022 Check the cell is safe\n\u2022 Check the buzzer works\n\u2022 Provide a new blanket\n\u2022 Shoes in the cubby hole\n\nShut the door and check via the hatch.',
      sideNote: 'Never place a prisoner in an unchecked cell.',
      icon: '🔒',
      color: Color(0xFF7C5CBF),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
      _controller.forward(from: 0);
    }
  }

  void _prevStep() {
    if (_currentStep > -1) {
      setState(() => _currentStep--);
      _controller.forward(from: 0);
    }
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _controller.forward(from: 0);
  }

  void _toggleAutoPlay() async {
    setState(() => _autoPlay = !_autoPlay);
    if (_autoPlay) {
      _currentStep = -1;
      for (int i = 0; i <= _steps.length - 1; i++) {
        if (!_autoPlay) break;
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted || !_autoPlay) break;
        setState(() => _currentStep = i);
        _controller.forward(from: 0);
        await Future.delayed(const Duration(seconds: 3));
      }
      if (mounted) setState(() => _autoPlay = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custody Flowchart',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _autoPlay ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: _autoPlay
                  ? const Color(0xFFD4A853)
                  : Theme.of(context).colorScheme.primary,
            ),
            onPressed: _toggleAutoPlay,
            tooltip: _autoPlay ? 'Pause' : 'Auto-play',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Golden rule banner ──
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE07B39).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFE07B39).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Text('👁', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Someone is ALWAYS watching the prisoner!',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE07B39),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Step progress bar ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(_steps.length, (i) {
                final isActive = i <= _currentStep;
                final isCurrent = i == _currentStep;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _goToStep(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.only(
                          right: i < _steps.length - 1 ? 4 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? _steps[i].color.withValues(alpha: 0.15)
                            : isActive
                                ? _steps[i].color.withValues(alpha: 0.06)
                                : context.cardBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCurrent
                              ? _steps[i].color
                              : isActive
                                  ? _steps[i].color.withValues(alpha: 0.3)
                                  : context.borderColor,
                          width: isCurrent ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _steps[i].icon,
                            style: TextStyle(
                                fontSize: isActive ? 18 : 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Step ${_steps[i].number}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 7,
                              fontWeight: FontWeight.w700,
                              color: isActive
                                  ? _steps[i].color
                                  : context.dimText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 16),

          // ── Current step card ──
          Expanded(
            child: _currentStep >= 0 && _currentStep < _steps.length
                ? _buildStepCard(_steps[_currentStep])
                : _buildIntroCard(),
          ),

          // ── Navigation ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Row(
              children: [
                if (_currentStep > -1)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _prevStep,
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: Text(_currentStep == 0 ? 'Intro' : 'Previous'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                if (_currentStep > -1 && _currentStep < _steps.length - 1)
                  const SizedBox(width: 8),
                if (_currentStep < _steps.length - 1)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _nextStep,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: Text(_currentStep == -1 ? 'Start' : 'Next'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                if (_currentStep == _steps.length - 1)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Done'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF34D399),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🔒', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'Custody Flowchart',
                style: GoogleFonts.newsreader(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Step-by-step guide to booking in a prisoner',
                style: TextStyle(fontSize: 14, color: context.mutedText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Steps overview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE07B39).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE07B39).withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._steps.map((s) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: s.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  s.number,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: s.color,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                s.title,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tap Start or press play to walk through each step.',
                style: TextStyle(
                  fontSize: 12,
                  color: context.dimText,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(_FlowStep step) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final slideIn = Tween<double>(begin: 30, end: 0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
        );
        final fadeIn = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0, 0.6, curve: Curves.easeOut),
          ),
        );

        return Opacity(
          opacity: fadeIn.value,
          child: Transform.translate(
            offset: Offset(0, slideIn.value),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Main card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: step.color.withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: step.color.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: step.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  step.number,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: step.color,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Step ${step.number} of ${_steps.length}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.dimText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Title
                          Row(
                            children: [
                              Text(step.icon,
                                  style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  step.title,
                                  style: GoogleFonts.newsreader(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Description
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: context.cardBg2,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              step.description,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Side note
                    if (step.sideNote != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4A853)
                              .withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFD4A853)
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('\ud83d\udca1',
                                style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                step.sideNote!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.mutedText,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // WAND note on search step
                    if (_currentStep == 3) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: context.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WAND Technique',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFD4A853),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Can be set to vibrate or beep. If it picks something up: STOP, check, RESUME.\n\nYou\'re "painting the prisoner green" \u2014 systematic sweeping motions covering the entire body.',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.mutedText,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FlowStep {
  final String number;
  final String title;
  final String description;
  final String? sideNote;
  final String icon;
  final Color color;

  const _FlowStep({
    required this.number,
    required this.title,
    required this.description,
    this.sideNote,
    required this.icon,
    required this.color,
  });
}
