import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _taglineController;
  late AnimationController _fadeOutController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _cuffSlide;
  late Animation<double> _notesSlide;
  late Animation<double> _taglineOpacity;
  late Animation<double> _tagline2Opacity;
  late Animation<double> _lineWidth;
  late Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();

    // Logo animation: 0 - 1200ms
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _cuffSlide = Tween<double>(begin: -30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.1, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _notesSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _lineWidth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Tagline animation: starts after logo
    _taglineController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _taglineController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _tagline2Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _taglineController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    // Fade out everything
    _fadeOutController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeIn),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _taglineController.forward();
    await Future.delayed(const Duration(milliseconds: 2000));
    _fadeOutController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    widget.onComplete();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _taglineController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _logoController,
        _taglineController,
        _fadeOutController,
      ]),
      builder: (context, _) {
        return Opacity(
          opacity: _fadeOut.value,
          child: Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF0B0E13),
                          const Color(0xFF101622),
                        ]
                      : [
                          const Color(0xFFF4F5F9),
                          const Color(0xFFE8EAF4),
                        ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Shield icon ──
                  Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.shield_outlined,
                          size: 36,
                          color: primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── CuffNotes title ──
                  Opacity(
                    opacity: _logoOpacity.value,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.translate(
                          offset: Offset(_cuffSlide.value, 0),
                          child: Text(
                            'Cuff',
                            style: GoogleFonts.newsreader(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: primary,
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(_notesSlide.value, 0),
                          child: Text(
                            'Notes',
                            style: GoogleFonts.newsreader(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Animated line divider ──
                  SizedBox(
                    width: 160,
                    child: FractionallySizedBox(
                      widthFactor: _lineWidth.value,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primary.withValues(alpha: 0.0),
                              primary,
                              primary.withValues(alpha: 0.0),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── "By Specials..." ──
                  Opacity(
                    opacity: _taglineOpacity.value,
                    child: Transform.translate(
                      offset: Offset(0, 8 * (1 - _taglineOpacity.value)),
                      child: Text(
                        'By Humberside Specials...',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFF8892A8)
                              : const Color(0xFF666E84),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // ── "For Everyone" ──
                  Opacity(
                    opacity: _tagline2Opacity.value,
                    child: Transform.translate(
                      offset: Offset(0, 8 * (1 - _tagline2Opacity.value)),
                      child: Text(
                        'For Everyone',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: primary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
