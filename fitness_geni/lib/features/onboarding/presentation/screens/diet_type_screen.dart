import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Diet preference screen - White theme with primaryGreen accents
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

class _DietTypeScreenState extends State<DietTypeScreen> {
  String? _selectedDiet;

  // Theme colors
  static const Color primaryGreen = Color(0xFF3D6B4A);
  static const Color lightGreenBg = Color(0xFFEDF5F0);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color cardBorder = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    _selectedDiet = widget.initialDietType;
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
              child: Image.asset(
                'assets/images/meal.png',
                width: 56,
                height: 56,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Title
          const Text(
            'Your Diet Preference',
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
            "We'll recommend meals based on your choice",
            style: TextStyle(fontSize: 15, color: textGrey, height: 1.4),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Diet options
          _buildOptionCard(
            icon: Icons.eco,
            title: 'Vegetarian',
            subtitle: 'Plant-based with dairy & eggs',
            value: 'Vegetarian',
          ),

          const SizedBox(height: 12),

          _buildOptionCard(
            icon: Icons.restaurant,
            title: 'Non-Vegetarian',
            subtitle: 'Includes meat & fish',
            value: 'Non-Vegetarian',
          ),

          const SizedBox(height: 12),

          _buildOptionCard(
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
                child: _buildPrimaryButton(
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

  Widget _buildOptionCard({
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

  Widget _buildPrimaryButton({required String label, VoidCallback? onPressed}) {
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
          child: Text(
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
