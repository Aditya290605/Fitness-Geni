import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';

/// Get Started welcome screen — shown to unauthenticated users.
///
/// Features a food image with diagonal green/white split background,
/// headline text, subtitle, and a slide-to-start bar that navigates
/// to the Login screen when swiped fully to the right.
class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen>
    with SingleTickerProviderStateMixin {
  // Premium Color Palette (matching auth screens)
  static const Color primaryGreen = Color(0xFF3D6B4A);

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // ===== TOP SECTION: Diagonal green/white split with image =====
            SizedBox(
              height: screenHeight * 0.55,
              width: double.infinity,
              child: Stack(
                children: [
                  // Diagonal green background
                  ClipPath(
                    clipper: _DiagonalClipper(),
                    child: Container(
                      decoration: const BoxDecoration(color: primaryGreen),
                    ),
                  ),

                  // Food image centered
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Image.asset(
                        'assets/images/getstarted.png',
                        width: screenWidth * 0.75,
                        height: screenHeight * 0.40,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ===== BOTTOM SECTION: Text + Slider =====
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 1),

                    // Headline
                    const Text(
                      'Get the Food\nRecipe more easier!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subtitle
                    const Text(
                      'Personalized AI-powered meal plans\ntailored to your fitness goals\nand dietary preferences.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9CA3AF),
                        height: 1.5,
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Slide-to-Start bar
                    _SlideToStartBar(
                      onSlideComplete: () {
                        context.go(AppConstants.routeLogin);
                      },
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
}

// ============================================================
// Diagonal Clipper — creates the angled green background
// ============================================================

class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Start at top-left
    path.lineTo(0, 0);
    // Go to top-right
    path.lineTo(size.width, 0);
    // Go down right side to ~60%
    path.lineTo(size.width, size.height * 0.55);
    // Diagonal line to bottom-left at ~85%
    path.lineTo(0, size.height * 0.85);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ============================================================
// Slide-to-Start Bar Widget
// ============================================================

class _SlideToStartBar extends StatefulWidget {
  final VoidCallback onSlideComplete;

  const _SlideToStartBar({required this.onSlideComplete});

  @override
  State<_SlideToStartBar> createState() => _SlideToStartBarState();
}

class _SlideToStartBarState extends State<_SlideToStartBar>
    with SingleTickerProviderStateMixin {
  static const Color accentOrange = Color(0xFFF5A623);
  static const double _knobSize = 60.0;
  static const double _trackHeight = 64.0;
  static const double _trackPadding = 4.0;

  double _dragPosition = 0.0;
  bool _completed = false;

  late AnimationController _snapBackController;
  late Animation<double> _snapBackAnimation;

  @override
  void initState() {
    super.initState();
    _snapBackController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _snapBackAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _snapBackController, curve: Curves.easeOut),
    );
    _snapBackController.addListener(() {
      setState(() {
        _dragPosition = _snapBackAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _snapBackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDrag = constraints.maxWidth - _knobSize - (_trackPadding * 2);

        return Container(
          height: _trackHeight,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(_trackHeight / 2),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // "Get Started" text — fades as user slides
              Center(
                child: Opacity(
                  opacity: (1 - (_dragPosition / maxDrag)).clamp(0.0, 1.0),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),

              // Draggable knob
              Positioned(
                left: _trackPadding + _dragPosition,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_completed) return;
                    setState(() {
                      _dragPosition = (_dragPosition + details.delta.dx).clamp(
                        0.0,
                        maxDrag,
                      );
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_completed) return;

                    if (_dragPosition >= maxDrag * 0.7) {
                      // Complete — snap to end and trigger callback
                      setState(() {
                        _dragPosition = maxDrag;
                        _completed = true;
                      });
                      Future.delayed(
                        const Duration(milliseconds: 200),
                        widget.onSlideComplete,
                      );
                    } else {
                      // Snap back to start
                      _snapBackAnimation =
                          Tween<double>(begin: _dragPosition, end: 0).animate(
                            CurvedAnimation(
                              parent: _snapBackController,
                              curve: Curves.easeOut,
                            ),
                          );
                      _snapBackController.forward(from: 0);
                    }
                  },
                  child: Container(
                    width: _knobSize,
                    height: _knobSize - (_trackPadding * 2),
                    decoration: BoxDecoration(
                      color: accentOrange,
                      borderRadius: BorderRadius.circular(
                        (_knobSize - _trackPadding * 2) / 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentOrange.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '>>>',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
