import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Fitness goal selection screen - White theme with primaryGreen accents
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

class _FitnessGoalScreenState extends State<FitnessGoalScreen> {
  String? _selectedGoal;

  // Theme colors
  static const Color primaryGreen = Color(0xFF3D6B4A);
  static const Color lightGreenBg = Color(0xFFEDF5F0);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color cardBorder = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    _selectedGoal = widget.initialGoal;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),

          // Hero icon circle
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lightGreenBg,
                border: Border.all(color: primaryGreen.withOpacity(0.2)),
              ),
              child: const Icon(
                Icons.flag_outlined,
                size: 56,
                color: primaryGreen,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Title
          const Text(
            'Your Fitness Goal',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textDark,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          const Text(
            "What do you want to achieve?",
            style: TextStyle(fontSize: 15, color: textGrey, height: 1.4),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Goal options
          _buildOptionCard(
            icon: Icons.trending_down,
            title: 'Lose Weight',
            subtitle: 'Burn fat & get leaner',
            value: 'Lose Weight',
          ),

          const SizedBox(height: 12),

          _buildOptionCard(
            icon: Icons.fitness_center,
            title: 'Build Muscle',
            subtitle: 'Gain strength & mass',
            value: 'Build Muscle',
          ),

          const SizedBox(height: 12),

          _buildOptionCard(
            icon: Icons.favorite_outline,
            title: 'Stay Fit',
            subtitle: 'Maintain overall health',
            value: 'Stay Fit',
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
                child: _buildPrimaryButton(
                  label: widget.isLoading ? 'Saving...' : 'Get Started',
                  onPressed: (_selectedGoal != null && !widget.isLoading)
                      ? () => widget.onGoalSelected(_selectedGoal!)
                      : null,
                  isLoading: widget.isLoading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen.withOpacity(0.08) : lightGreenBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryGreen.withOpacity(0.6) : cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryGreen.withOpacity(0.15)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? primaryGreen : textGrey,
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
                      color: isSelected ? primaryGreen : textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: textGrey),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    final isEnabled = onPressed != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          color: isEnabled ? primaryGreen : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isEnabled ? Colors.white : textGrey,
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
          color: lightGreenBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryGreen.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: primaryGreen.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }
}
