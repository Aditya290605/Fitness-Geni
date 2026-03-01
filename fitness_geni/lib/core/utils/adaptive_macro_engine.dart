import 'dart:math';

import '../../features/home/domain/models/catalog_meal.dart';

/// Adaptive Macro Engine — v5 Production-Grade
///
/// A sequential constrained optimization system that:
/// 1. Computes goal-aware initial section targets with macro conservation
/// 2. Scores meals using asymmetric weighted deviation with directional amplification
/// 3. Reactively re-scores on user selection via deficit-driven dynamic weights
/// 4. Applies goal-aware macro skew penalties
/// 5. Ensures deterministic diversity via seed-based shuffling
class AdaptiveMacroEngine {
  // ──────────────────────────────────────────────
  // CONSTANTS (model parameters)
  // ──────────────────────────────────────────────

  /// Base importance weights per meal type (metabolic role)
  static const _baseWeights = {
    'breakfast': 1.0, // standard morning energy
    'lunch': 1.2, // highest activity period
    'snack': 0.4, // bridge, not primary fuel
    'dinner': 1.0, // recovery and satiation
  };

  /// Goal-specific micro-adjustments to base weights
  static const _goalAdjustments = {
    'weight_loss': {
      'breakfast': 0.0,
      'lunch': 0.0,
      'snack': -0.05,
      'dinner': 0.15,
    },
    'bulking': {'breakfast': 0.05, 'lunch': 0.15, 'snack': 0.0, 'dinner': 0.0},
    'muscle_gain': {
      'breakfast': 0.05,
      'lunch': 0.15,
      'snack': 0.0,
      'dinner': 0.0,
    },
    'gain_muscle': {
      'breakfast': 0.05,
      'lunch': 0.15,
      'snack': 0.0,
      'dinner': 0.0,
    },
  };

  /// Directional amplification multipliers
  static const _undershootMult = {
    'cal': 1.0,
    'prot': 1.3,
    'carb': 1.0,
    'fat': 0.9,
  };
  static const _overshootMult = {
    'cal': 1.3,
    'prot': 0.8,
    'carb': 1.1,
    'fat': 1.2,
  };

  /// Goal-aware ideal caloric ratio ranges for skew penalty
  static const _idealRanges = {
    'weight_loss': {
      'prot': [0.25, 0.40],
      'carb': [0.25, 0.45],
      'fat': [0.20, 0.35],
    },
    'bulking': {
      'prot': [0.20, 0.35],
      'carb': [0.40, 0.60],
      'fat': [0.15, 0.30],
    },
    'muscle_gain': {
      'prot': [0.20, 0.35],
      'carb': [0.40, 0.60],
      'fat': [0.15, 0.30],
    },
    'gain_muscle': {
      'prot': [0.20, 0.35],
      'carb': [0.40, 0.60],
      'fat': [0.15, 0.30],
    },
    'maintain': {
      'prot': [0.20, 0.35],
      'carb': [0.35, 0.55],
      'fat': [0.20, 0.35],
    },
    'maintenance': {
      'prot': [0.20, 0.35],
      'carb': [0.35, 0.55],
      'fat': [0.20, 0.35],
    },
  };

  static const _sections = ['breakfast', 'lunch', 'snack', 'dinner'];

  // ──────────────────────────────────────────────
  // ④⑤ INITIAL SECTION TARGETS + CONSERVATION
  // ──────────────────────────────────────────────

  /// Compute goal-aware initial section targets with macro conservation (INV-5).
  static Map<String, MacroBudget> computeInitialTargets(
    MacroBudget daily,
    String goal,
  ) {
    final goalKey = _normalizeGoal(goal);

    // Step A: Compute adjusted weights
    final adjustments =
        _goalAdjustments[goalKey] ??
        {'breakfast': 0.0, 'lunch': 0.0, 'snack': 0.0, 'dinner': 0.0};

    final adjustedWeights = <String, double>{};
    double totalWeight = 0;
    for (final t in _sections) {
      final w = (_baseWeights[t] ?? 1.0) + (adjustments[t] ?? 0.0);
      adjustedWeights[t] = w;
      totalWeight += w;
    }

    // Step B: Distribute macros proportionally (Σ = daily exactly)
    final targets = <String, MacroBudget>{};
    for (final t in _sections) {
      final share = adjustedWeights[t]! / totalWeight;
      targets[t] = MacroBudget(
        cal: daily.cal * share,
        prot: daily.prot * share,
        carbs: daily.carbs * share,
        fats: daily.fats * share,
      );
    }

    // Step C: Goal timing shifts
    final deltas = <String, Map<String, double>>{};

    if (goalKey == 'weight_loss') {
      final boost = targets['dinner']!.prot * 0.15;
      targets['dinner'] = MacroBudget(
        cal: targets['dinner']!.cal,
        prot: targets['dinner']!.prot * 1.15,
        carbs: targets['dinner']!.carbs,
        fats: targets['dinner']!.fats,
      );
      deltas['prot'] = {'dinner': boost};
    } else if (goalKey == 'bulking' ||
        goalKey == 'muscle_gain' ||
        goalKey == 'gain_muscle') {
      final boost = targets['lunch']!.carbs * 0.10;
      targets['lunch'] = MacroBudget(
        cal: targets['lunch']!.cal,
        prot: targets['lunch']!.prot,
        carbs: targets['lunch']!.carbs * 1.10,
        fats: targets['lunch']!.fats,
      );
      deltas['carbs'] = {'lunch': boost};
    }

    // Step D: Conservation redistribution (INV-5)
    for (final entry in deltas.entries) {
      final macroName = entry.key;
      final shiftedSections = entry.value;
      final totalDelta = shiftedSections.values.fold(0.0, (s, v) => s + v);

      // Sections that were NOT shifted for this macro
      final nonShifted = _sections
          .where((s) => !shiftedSections.containsKey(s))
          .toList();
      double totalNonShiftedMacro = 0;
      for (final s in nonShifted) {
        totalNonShiftedMacro += _getMacro(targets[s]!, macroName);
      }

      if (totalNonShiftedMacro > 0) {
        for (final s in nonShifted) {
          final currentVal = _getMacro(targets[s]!, macroName);
          final reduction = totalDelta * (currentVal / totalNonShiftedMacro);
          targets[s] = _setMacro(
            targets[s]!,
            macroName,
            currentVal - reduction,
          );
        }
      }
    }

    return targets;
  }

  // ──────────────────────────────────────────────
  // ⑥ WEIGHTS: DEFICIT + DIRECTIONAL + BOUNDED SPREAD
  // ──────────────────────────────────────────────

  /// Compute deficit ratios. Can be negative (overconsumption).
  static Map<String, double> computeDeficits(
    MacroBudget remaining,
    MacroBudget daily,
  ) {
    return {
      'cal': remaining.cal / max(daily.cal, 0.01),
      'prot': remaining.prot / max(daily.prot, 0.01),
      'carb': remaining.carbs / max(daily.carbs, 0.01),
      'fat': remaining.fats / max(daily.fats, 0.01),
    };
  }

  /// Compute directional effective deficit for weight amplification.
  static double _directionalDeficit(double deficit, String macro) {
    if (deficit >= 0) {
      return deficit.abs() * (_undershootMult[macro] ?? 1.0);
    } else {
      return deficit.abs() * (_overshootMult[macro] ?? 1.0);
    }
  }

  /// Dynamic factor: responds to progress AND actual imbalance severity.
  /// Uses log₂(1 + spread) for bounded contribution.
  static double computeDynamicFactor(
    int completedSelections,
    Map<String, double> deficits,
  ) {
    const baseFactor = 1.2;
    final progress = completedSelections / 3.0;

    // Directional effective deficits
    final effValues = [
      _directionalDeficit(deficits['cal']!, 'cal'),
      _directionalDeficit(deficits['prot']!, 'prot'),
      _directionalDeficit(deficits['carb']!, 'carb'),
      _directionalDeficit(deficits['fat']!, 'fat'),
    ];

    final spread = effValues.reduce(max) - effValues.reduce(min);
    // Bounded: log₂(1 + spread), max ≈ 1.58
    final spreadContribution = log(1 + spread) / ln2;

    return baseFactor * (1.0 + progress + spreadContribution);
  }

  /// Compute normalized weights with directional amplification and goal bias.
  /// Guarantees: Σ weights = 1.0 (INV-2), dominant deficit stays dominant.
  static Map<String, double> computeWeights(
    Map<String, double> deficits,
    String goal,
    int completedSelections,
  ) {
    final dynamicFactor = computeDynamicFactor(completedSelections, deficits);
    final goalKey = _normalizeGoal(goal);

    // Directional effective deficits → raw weights
    double wCal =
        1.0 + _directionalDeficit(deficits['cal']!, 'cal') * dynamicFactor;
    double wProt =
        1.0 + _directionalDeficit(deficits['prot']!, 'prot') * dynamicFactor;
    double wCarb =
        1.0 + _directionalDeficit(deficits['carb']!, 'carb') * dynamicFactor;
    double wFat =
        1.0 + _directionalDeficit(deficits['fat']!, 'fat') * dynamicFactor;

    // Goal bias (capped at 0.5 per addition)
    if (goalKey == 'weight_loss') {
      wProt += 0.5;
      wFat += 0.2;
    } else if (goalKey == 'bulking' ||
        goalKey == 'muscle_gain' ||
        goalKey == 'gain_muscle') {
      wCarb += 0.4;
      wCal += 0.3;
    }

    // Normalize (INV-2)
    final total = wCal + wProt + wCarb + wFat;
    return {
      'cal': wCal / total,
      'prot': wProt / total,
      'carb': wCarb / total,
      'fat': wFat / total,
    };
  }

  // ──────────────────────────────────────────────
  // ⑦ ADAPTIVE REJECTION BOUNDS
  // ──────────────────────────────────────────────

  /// Returns (lowerMultiplier, upperMultiplier) based on progress.
  static (double, double) rejectionBounds(int completedSelections) {
    final progress = completedSelections / 3.0;
    final upper = 2.0 - 0.5 * progress; // 2.0 → 1.5
    final lower = 0.2 + 0.2 * progress; // 0.2 → 0.4
    return (lower, upper);
  }

  // ──────────────────────────────────────────────
  // ⑧ STARVATION RECOVERY
  // ──────────────────────────────────────────────

  /// Get eligible candidates with deterministic starvation recovery.
  /// Returns (eligible list, recovery level 0-3).
  static (List<CatalogMeal>, int) getEligible(
    List<CatalogMeal> candidates,
    MacroBudget sectionTarget,
    int completedSelections,
  ) {
    final (lower, upper) = rejectionBounds(completedSelections);
    final targetCal = max(sectionTarget.cal, 0.01);

    // LEVEL 0: Full filtering
    var eligible = candidates
        .where(
          (m) =>
              m.calories >= targetCal * lower &&
              m.calories <= targetCal * upper,
        )
        .toList();
    if (eligible.length >= 4) return (eligible, 0);

    // LEVEL 1: Widen bounds by 50%
    final wideUpper = targetCal * (upper + 0.5);
    final wideLower = targetCal * max(0.1, lower - 0.1);
    eligible = candidates
        .where((m) => m.calories >= wideLower && m.calories <= wideUpper)
        .toList();
    if (eligible.length >= 4) return (eligible, 1);

    // LEVEL 2: Remove calorie filter entirely
    if (candidates.length >= 2) return (candidates, 2);

    // LEVEL 3: Not enough candidates at all
    return (candidates, 3);
  }

  // ──────────────────────────────────────────────
  // ⑨ UNIFIED SCORING (asymmetric)
  // ──────────────────────────────────────────────

  /// Compute asymmetric deviation for a single macro.
  static double _computeDeviation(
    double mealValue,
    double targetValue,
    String macro,
  ) {
    final denom = max(targetValue, 0.01); // INV-3
    final raw = (mealValue - targetValue) / denom;

    // Asymmetric penalties
    if (macro == 'cal' && raw > 0) return raw.abs() * 1.3; // cal overshoot
    if (macro == 'prot' && raw < 0) return raw.abs() * 1.25; // prot undershoot
    if (macro == 'fat' && raw > 0) return raw.abs() * 1.1; // fat overshoot
    return raw.abs();
  }

  /// Score a meal against a section target using weighted asymmetric deviation.
  /// Result ∈ [0.0, 1.0] (INV-1).
  static double scoreMeal(
    CatalogMeal meal,
    MacroBudget sectionTarget,
    Map<String, double> weights,
  ) {
    final error =
        weights['cal']! *
            _computeDeviation(
              meal.calories.toDouble(),
              sectionTarget.cal,
              'cal',
            ) +
        weights['prot']! *
            _computeDeviation(meal.protein, sectionTarget.prot, 'prot') +
        weights['carb']! *
            _computeDeviation(meal.carbs, sectionTarget.carbs, 'carb') +
        weights['fat']! *
            _computeDeviation(meal.fats, sectionTarget.fats, 'fat');

    return (1.0 - error).clamp(0.0, 1.0);
  }

  // ──────────────────────────────────────────────
  // ⑩ GOAL-AWARE MACRO SKEW PENALTY
  // ──────────────────────────────────────────────

  /// Compute macro skew penalty based on goal-specific ideal ranges.
  /// Result ∈ [0.0, 0.3] (INV-7).
  static double macroSkewPenalty(CatalogMeal meal, String goal) {
    final totalCal = max(meal.calories, 1).toDouble();
    final protR = (meal.protein * 4) / totalCal;
    final carbR = (meal.carbs * 4) / totalCal;
    final fatR = (meal.fats * 9) / totalCal;

    final goalKey = _normalizeGoal(goal);
    final ranges = _idealRanges[goalKey] ?? _idealRanges['maintain']!;

    final protExcess =
        max(0.0, protR - ranges['prot']![1]) +
        max(0.0, ranges['prot']![0] - protR);
    final carbExcess =
        max(0.0, carbR - ranges['carb']![1]) +
        max(0.0, ranges['carb']![0] - carbR);
    final fatExcess =
        max(0.0, fatR - ranges['fat']![1]) + max(0.0, ranges['fat']![0] - fatR);

    return min(0.3, protExcess + carbExcess + fatExcess);
  }

  // ──────────────────────────────────────────────
  // ⑪ DETERMINISTIC DIVERSITY
  // ──────────────────────────────────────────────

  /// Apply yesterday penalty, pool sizing, and deterministic shuffle.
  static List<ScoredMeal> diversify(
    List<ScoredMeal> scoredMeals,
    String userId,
    int sectionIndex,
    Set<String> yesterdayMealIds,
  ) {
    if (scoredMeals.isEmpty) return [];

    // Layer 1: Yesterday penalty (15% score reduction)
    for (final sm in scoredMeals) {
      if (yesterdayMealIds.contains(sm.meal.id)) {
        sm.score *= 0.85;
      }
    }

    // Sort descending by score
    scoredMeals.sort((a, b) => b.score.compareTo(a.score));

    // Layer 2: Dynamic pool = 60% of available (min 4)
    final poolSize = max(4, (scoredMeals.length * 0.6).ceil());
    final pool = scoredMeals.take(min(poolSize, scoredMeals.length)).toList();

    // Layer 3: Deterministic shuffle
    final seed = _generateSeed(userId, sectionIndex);
    final rng = Random(seed);
    pool.shuffle(rng);

    return pool.take(min(4, pool.length)).toList();
  }

  /// Generate deterministic seed from userId + today's date + section index.
  static int _generateSeed(String userId, int sectionIndex) {
    final date = DateTime.now().toIso8601String().split('T')[0];
    return '$userId-$date-$sectionIndex'.hashCode;
  }

  // ──────────────────────────────────────────────
  // FULL GENERATION: Score candidates for one section
  // ──────────────────────────────────────────────

  /// Score and select options for a single section.
  /// Returns (options, starvation level).
  static (List<ScoredMeal>, int) scoreSection({
    required List<CatalogMeal> candidates,
    required MacroBudget sectionTarget,
    required Map<String, double> weights,
    required String goal,
    required String userId,
    required int sectionIndex,
    required int completedSelections,
    required Set<String> yesterdayMealIds,
  }) {
    // ⑦⑧ Rejection + starvation recovery
    final (eligible, level) = getEligible(
      candidates,
      sectionTarget,
      completedSelections,
    );

    if (level == 3 && eligible.isEmpty) {
      return (<ScoredMeal>[], 3);
    }

    // ⑨⑩ Score + skew
    final scored = eligible.map((m) {
      final rawScore = scoreMeal(m, sectionTarget, weights);
      final skew = macroSkewPenalty(m, goal);
      return ScoredMeal(meal: m, score: rawScore * (1.0 - skew));
    }).toList();

    // ⑪ Diversity
    final options = diversify(scored, userId, sectionIndex, yesterdayMealIds);

    return (options, level);
  }

  // ──────────────────────────────────────────────
  // SECTION TARGET COMPUTATION (for re-scoring)
  // ──────────────────────────────────────────────

  /// Compute section target from remaining budget, clamped non-negative (INV-4).
  static MacroBudget computeSectionTarget(
    MacroBudget remaining,
    int remainingSections,
  ) {
    if (remainingSections <= 0) return MacroBudget.zero;
    return (remaining / remainingSections.toDouble()).clampNonNegative();
  }

  // ──────────────────────────────────────────────
  // HELPERS
  // ──────────────────────────────────────────────

  static String _normalizeGoal(String goal) {
    final g = goal.toLowerCase().trim();
    if (g.contains('loss') || g.contains('lose')) return 'weight_loss';
    if (g.contains('bulk') || g.contains('gain') || g.contains('muscle')) {
      return 'bulking';
    }
    return 'maintain';
  }

  static double _getMacro(MacroBudget b, String macro) {
    switch (macro) {
      case 'prot':
        return b.prot;
      case 'carbs':
        return b.carbs;
      case 'fats':
        return b.fats;
      case 'cal':
        return b.cal;
      default:
        return 0;
    }
  }

  static MacroBudget _setMacro(MacroBudget b, String macro, double value) {
    switch (macro) {
      case 'prot':
        return MacroBudget(
          cal: b.cal,
          prot: value,
          carbs: b.carbs,
          fats: b.fats,
        );
      case 'carbs':
        return MacroBudget(
          cal: b.cal,
          prot: b.prot,
          carbs: value,
          fats: b.fats,
        );
      case 'fats':
        return MacroBudget(
          cal: b.cal,
          prot: b.prot,
          carbs: b.carbs,
          fats: value,
        );
      case 'cal':
        return MacroBudget(
          cal: value,
          prot: b.prot,
          carbs: b.carbs,
          fats: b.fats,
        );
      default:
        return b;
    }
  }

  /// All section names in order.
  static List<String> get sections => _sections;
}
