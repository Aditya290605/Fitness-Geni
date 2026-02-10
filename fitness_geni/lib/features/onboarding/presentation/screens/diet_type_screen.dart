import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Premium diet preference screen - Dark emerald green with glassmorphism
class DietTypeScreen extends StatefulWidget {
  final String? initialDietType;
  final Function(String) onDietTypeSelected;
  final VoidCallback? onBack;

  const DietTypeScreen({
    super.key,
    this.initialDietType,
    required this.onDietTypeSelected,
    this.onBack,
  });

  @override
  State<DietTypeScreen> createState() => _DietTypeScreenState();
}

class _DietTypeScreenState extends State<DietTypeScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedDiet;
  late AnimationController _glowController;

  // Theme colors
  static const Color accentGreen = Color(0xFF4ADE80);
  static const Color accentGreenDark = Color(0xFF22C55E);

  @override
  void initState() {
    super.initState();
    _selectedDiet = widget.initialDietType;
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),

          // Hero image with glassmorphic circle
          Center(
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                    border: Border.all(
                      color: accentGreen.withOpacity(
                        0.2 + _glowController.value * 0.2,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentGreen.withOpacity(
                          0.15 + _glowController.value * 0.15,
                        ),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/meal.png',
                    width: 56,
                    height: 56,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 28),

          // Title
          const Text(
            'Your Diet Preference',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            "We'll recommend meals based on your choice",
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.6),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Diet options
          _buildGlassOption(
            icon: Icons.eco,
            title: 'Vegetarian',
            subtitle: 'Plant-based with dairy & eggs',
            value: 'Vegetarian',
          ),

          const SizedBox(height: 12),

          _buildGlassOption(
            icon: Icons.restaurant,
            title: 'Non-Vegetarian',
            subtitle: 'Includes meat & fish',
            value: 'Non-Vegetarian',
          ),

          const SizedBox(height: 12),

          _buildGlassOption(
            icon: Icons.spa,
            title: 'Vegan',
            subtitle: 'Purely plant-based',
            value: 'Vegan',
          ),

          const Spacer(),

          // Button Row
          Row(
            children: [
              if (widget.onBack != null) ...[
                Expanded(
                  child: _buildOutlineButton(
                    label: 'Previous',
                    onPressed: widget.onBack!,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: _buildGreenButton(
                  label: 'Continue',
                  onPressed: _selectedDiet != null
                      ? () => widget.onDietTypeSelected(_selectedDiet!)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = _selectedDiet == value;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedDiet = value;
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isSelected
                  ? accentGreen.withOpacity(0.12)
                  : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? accentGreen.withOpacity(0.6)
                    : Colors.white.withOpacity(0.1),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: accentGreen.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accentGreen.withOpacity(0.2)
                        : Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? accentGreen
                        : Colors.white.withOpacity(0.6),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected
                              ? accentGreen
                              : Colors.white.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.45),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [accentGreen, accentGreenDark],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accentGreen.withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreenButton({required String label, VoidCallback? onPressed}) {
    final isEnabled = onPressed != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          gradient: isEnabled
              ? const LinearGradient(colors: [accentGreen, accentGreenDark])
              : null,
          color: isEnabled ? null : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: accentGreen.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isEnabled
                  ? const Color(0xFF0D1F15)
                  : Colors.white.withOpacity(0.3),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlineButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }
}
