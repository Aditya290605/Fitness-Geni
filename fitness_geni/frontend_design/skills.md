---
name: fitness-geni-ui
description: Create distinctive, production-grade Flutter interfaces for Fitness Geni with premium aesthetics, calm motivation, and zero generic AI design patterns. Use this skill when building Flutter screens, widgets, dashboards, flows, or styling UI components.
license: Complete terms in LICENSE.txt
---

This skill guides Antigravity to design and implement **distinctive, premium-quality Flutter UIs** for **Fitness Geni**, a health and nutrition tracking app.  
The goal is to avoid generic Material UI, template-like layouts, and “AI-looking” design, while delivering **clean, calm, and motivating interfaces** that feel handcrafted and production-ready.

The user provides UI requirements such as a screen, flow, widget, or feature. Context may include user goals, health data, or technical constraints.

---

## Design Thinking

Before writing Flutter code, Antigravity must **commit to a clear aesthetic and emotional direction**.

### 1. Purpose
- What does this screen help the user achieve?
- Is the user checking progress, logging food, or reviewing insights?
- What is the *one thing* the user should feel after using this screen?

Fitness Geni exists to **reduce friction and anxiety around health tracking**.

---

### 2. Tone (Fitness Geni Specific)

Choose a strong but calm aesthetic direction such as:
- Soft premium minimalism
- Clean wellness-inspired design
- Calm, coach-like, non-aggressive fitness UI
- Modern health-tech with warmth

Avoid:
- Gym-heavy, aggressive visuals
- Dark, intimidating analytics dashboards
- Loud colors or excessive motion

---

### 3. Constraints
- Framework: **Flutter**
- Performance-first (low widget rebuilds)
- Responsive across small and large screens
- Accessible and readable
- Maintainable code structure

---

### 4. Differentiation

Fitness Geni must be **memorable through clarity**, not flash.

Ask:
- What detail makes this screen feel *thoughtfully designed*?
- Is it the spacing, progress visualization, animation restraint, or color discipline?

**CRITICAL**: Commit to a direction and execute it with precision.  
A calm UI done perfectly is more premium than a flashy UI done halfway.

---

## Flutter Aesthetics Guidelines (Mandatory)

### Typography
- Use system fonts only (Flutter default)
- Strong hierarchy:
  - Large, bold numbers for progress
  - Medium-weight section titles
  - Light supporting labels
- Numbers must be instantly readable
- Avoid dense text blocks

---

### Color & Theme
- White or near-white background
- One dominant color per screen
- Fitness Geni palette:
  - Green → completion, success, health
  - Orange → meals, energy
  - Blue → hydration, balance
- Use opacity instead of adding new colors
- All colors must come from `ThemeData`

Avoid:
- Random accent colors
- High-contrast aggressive palettes

---

### Spatial Composition
- Vertical flow
- Card-based grouping
- Generous padding
- Rounded corners (16–20)
- Use spacing instead of borders
- Prefer calm symmetry with slight asymmetry for interest

---

### Motion & Feedback
- Motion must feel **rewarding, not decorative**
- Subtle animations for:
  - Progress updates
  - Screen entry
  - Completion moments
- No flashy transitions
- Prefer implicit animations where possible

---

## Flutter Implementation Rules

### Required Practices
- Use `Scaffold` + `SafeArea`
- Centralize styles in `ThemeData`
- Modular widgets (no giant build methods)
- Prefer `const` constructors
- Use `Expanded` and `Flexible` properly
- Clean widget trees

### Forbidden Practices
- Deep widget nesting
- Hardcoded sizes everywhere
- Inline colors and text styles
- Overuse of shadows
- Copy-paste UI patterns

---

## Fitness Geni UI Intent Patterns

### Home / Dashboard
- Daily calorie progress first
- Remaining intake clearly visible
- Progress visualization is the hero
- User should feel: *“I’m on track.”*

### Meal Logging
- Minimal steps
- Visual-first cards
- No complex forms
- Fast completion feedback

### Progress & Insights
- Visual trends over raw numbers
- Calm analytics
- No information overload
- Encourage consistency, not perfection

### Settings / Profile
- Clean list-based layout
- No visual noise
- Easy scanning

---

## UI Creation Workflow (Strict)

Antigravity must always follow this order:

