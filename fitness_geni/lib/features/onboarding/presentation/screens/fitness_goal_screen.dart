import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Premium fitness goal screen - Dark emerald green with glassmorphism
class FitnessGoalScreen extends StatefulWidget {
  final String? initialGoal;
  final Function(String) onGoalSelected;
  final VoidCallback? onBack;
  final bool isLoading;

  const FitnessGoalScreen({
    super.key,
    this.initialGoal,
    required this.onGoalSelected,
    this.onBack,
    this.isLoading = false,
  });

  @override
  State<FitnessGoalScreen> createState() => _FitnessGoalScreenState();
}

class _FitnessGoalScreenState extends State<FitnessGoalScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedGoal;
  late AnimationController _glowController;

  // Theme colors
  static const Color accentGreen = Color(0xFF4ADE80);
  static const Color accentGreenDark = Color(0xFF22C55E);

  @override
  void initState() {
    super.initState();
    _selectedGoal = widget.initialGoal;
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

          // Hero icon with glassmorphic circle
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
                  child: const Icon(
                    Icons.emoji_events,
                    size: 56,
                    color: accentGreen,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 28),

          // Title
          const Text(
            'Your Fitness Goal',
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
            "We'll create a personalized plan for you",
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.6),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Goal options
          _buildGlassOption(
            icon: Icons.trending_down,
            title: 'Lose Weight',
            subtitle: 'Reduce body fat & get leaner',
            value: 'Lose Weight',
          ),

          const SizedBox(height: 12),

          _buildGlassOption(
            icon: Icons.fitness_center,
            title: 'Build Muscle',
            subtitle: 'Gain strength & muscle mass',
            value: 'Build Muscle',
          ),

          const SizedBox(height: 12),

          _buildGlassOption(
            icon: Icons.balance,
            title: 'Stay Fit',
            subtitle: 'Maintain current fitness level',
            value: 'Stay Fit',
          ),

          const Spacer(),

          // Motivational text
          Center(
            child: Text(
              "You're almost there! 🎉",
              style: TextStyle(
                fontSize: 14,
                color: accentGreen.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 16),

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
                  label: 'Get Started',
                  isLoading: widget.isLoading,
                  onPressed: _selectedGoal != null && !widget.isLoading
                      ? () => widget.onGoalSelected(_selectedGoal!)
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
    final isSelected = _selectedGoal == value;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedGoal = value;
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

  Widget _buildGreenButton({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    final isEnabled = onPressed != null;
    return GestureDetector(
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
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF0D1F15),
                    ),
                  ),
                )
              : Text(
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
