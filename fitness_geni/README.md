# Fitness Geni 🧞‍♂️

> **Tagline**: *"Simple fitness & diet guidance"*

Fitness Geni is an **AI-powered personal fitness and nutrition companion** built with **Flutter**. It leverages **Google Gemini AI** to act as a virtual nutritionist, generating highly personalized daily meal plans based on individual user profiles. Taking into account granular data points like weight, height, age, gender, exact diet type, and specific fitness goals (e.g., Weight Loss, Bulking, Maintaining), the app generates specific, actionable recipes with accurately calculated macronutrients. 

Beyond diet, Fitness Geni serves as a holistic health dashboard by integrating directly with native device health platforms (**Apple HealthKit** for iOS and **Google Health Connect** for Android) to persistently track physical activity, syncing diet and exercise into one unified experience.

---

## 📱 Current State of the App

**Version:** MVP v1.0.0+1
**Platform:** Cross-platform mobile (Flutter supporting iOS + Android)
**Architecture:** Feature-first modular architecture utilizing `Riverpod` for robust state management and `GoRouter` for deep-linkable and auth-aware routing.
**Status:** Core MVP features are fully implemented, thoroughly integrated with the **Supabase** backend (PostgreSQL + Auth), and the **Google Gemini AI** service.

### Features Implemented & Currently Working:

1. **Secure Authentication Flow**: 
   - Email and Password Sign Up / Log In powered by `supabase_flutter`.
   - Secure session persistence utilizing `flutter_secure_storage`.
   - Automatic routing protection that prevents unauthenticated access to the main app.

2. **Comprehensive 6-Step Onboarding Flow**: 
   - Collects essential physiological and preference metrics: Gender, Age, Weight (kg), Height (cm), Diet Type (Veg/Non-Veg), and Fitness Goal.
   - Utilizes a custom `NutritionCalculator` utility to calculate BMI and formulate precise, scientifically-backed daily target macros (Calories, Protein, Carbs, Fats) entirely on-device before persisting to the database.

3. **Advanced AI Meal Planning (The "Home" Flow)**:
   - Deep integration with `google_generative_ai` API to generate bespoke daily meal plans outlining Breakfast, Lunch, and Dinner.
   - **Generation Modes:** 
     - *"Surprise Me"*: Gemini creates a fully balanced day of meals aligning perfectly with the user's macro goals.
     - *"Ingredient-based"*: Users input what they already have in their fridge (min 5 ingredients), and Gemini constructs recipes around those items to reduce food waste and cost.
   - **Outputs:** Granular recipes including exact ingredients, step-by-step preparation instructions, and highly estimated nutritional breakdowns per meal.
   - **Interactive Tracking:** Users check off individual meals as "Done". This action interactively updates their daily consumed nutrition charts in real-time.

4. **Holistic Fitness & Health Dashboard (The "Fit" Flow)**:
   - Integrates `health` (v12) package to read daily Steps, active Calories Burned, and Distance walked/run directly from HealthKit / Health Connect.
   - **Visualizations:**
     - **"Perfect Days" Heatmap:** A visual calendar showing days where the user successfully logged all 3 meals (green squares indicating success).
     - **Weekly Activity Chart:** A dynamic bar chart (via `fl_chart`) visualizing the last 7 days of step history.
     - **Macro Rings:** Circular percent indicators showing progress against daily Protein, Carb, and Fat targets.

5. **Smart Local Reminders**:
   - Utilizes `flutter_local_notifications` combined with `timezone` data to schedule dynamic local push reminders for morning, afternoon, and night meals. Features fallback duplication protection so users aren't spammed.

---

## 🚦 Application Workflows in Detail

### 1. Authentication & Onboarding Pipeline
- **App Launch Strategy:** The root `GoRouter` setup (`/lib/core/router/auth_redirect.dart`) listens to Supabase auth state changes. The Splash screen checks the session:
  - No active session ➡️ Redirect to **`/login`** or **`/signup`**.
  - Active session exists BUT the `profiles` table is empty for that `user_id` ➡️ Redirect to **`/onboarding`**.
  - Active session + populated profile ➡️ Redirect to **`/main`** (Home Tab).
- **Onboarding Execution:** A 6-page interactive `PageView` collects biological data. On the final step, the app calculates the daily BMR and macro splits (Protein/Carb/Fat).
  - **DB Transaction:** A Supabase `.upsert()` or `.update()` is executed on the **`profiles`** table to save `gender`, `age`, `height`, `weight`, `diet_type`, `goal`, and the exact calculated `daily_targets`.

### 2. AI Meal Generation Engine
- **Trigger:** On the Home Tab, if the database shows no plan for the current date (`DateTime.now()`), an empty state is shown prompting the user to "Create Meals".
- **AI Processing (`GeminiService.generateMeals()`):**
  - A highly structured prompt is compiled containing the user's profile and macro targets.
  - The API is instructed to enforce strict JSON output formatting.
  - Instructions mandate a budget-friendly, quick preparation (under 20 mins) approach, heavily favoring simple Indian cuisine.
  - Calorie distribution is explicitly requested to be roughly split 30% Breakfast, 40% Lunch, 30% Dinner.
- **Data Persistence (`MealService.saveMeals()`):**
  Once the user reviews the AI output on the "Meals Preview" screen and taps save:
  1. **Get/Create Plan:** Checks the **`daily_plans`** table for a row matching `user_id` and `date=today`. Creates it if missing.
  2. **Cleanup:** Hard deletes any pre-existing junction rows in **`daily_plan_meals`** attached to this `daily_plan_id` (handling cases where a user regenerates a plan).
  3. **Reset Trackers:** Updates the **`daily_plans`** row to reset `consumed_calories`, `consumed_protein`, `consumed_carbs`, `consumed_fats` down to `0`.
  4. **Catalog Check:** Loops through the 3 new AI meals. It checks the **`meals`** table to see if that exact recipe name + time slot already exists. If it does not exist, it executes an `INSERT` saving the `name`, `ingredients`, `recipe_steps`, and `macros` to create a permanent record.
  5. **Link:** Inserts a new row in the **`daily_plan_meals`** junction table linking the mapped `meal_id` to the `daily_plan_id`, setting `is_completed = false`.

### 3. Live Meal Tracking Mechanism
- **User Action:** On the Home Screen, the user taps the checkbox next to a specific meal card (e.g., "Chicken Salad - Lunch").
- **DB Transaction Execution (`MealService.markMealDone`):**
  1. **Status Update:** Updates the specific row in **`daily_plan_meals`**, setting `is_completed = true` (or `false` if untoggled) and injecting a `completed_at` timestamp.
  2. **Atomic Tallying (RPC):** Executes a custom Supabase Stored Procedure (RPC) named **`increment_daily_nutrition`** (or `decrement_daily_nutrition`).
     - *Why RPC?* To prevent race conditions, the RPC takes the specific macro integers of that exact meal and adds them directly inside the PostgreSQL database to the `consumed_*` accumulators living on the **`daily_plans`** row.
- **Reactive UI:** The `flutter_riverpod` providers listen for these success callbacks, immediately refreshing local state to animate the progress rings and update the pie charts seamlessly.

### 4. Historical Statistics & Heatmap Flow
- **Feature:** The "Fit Tab" serves as a historical record.
- **DB Transaction Execution (`StatsHistoryService.fetchAllHistory`):**
  - Executes a complex relational `.select()` query spanning three tables. 
  - Starts at **`daily_plans`**, joins data from **`daily_plan_meals`**, and fetches inner details from the **`meals`** catalog.
  - Filters strictly by `user_id` and bounds the query between the date the account was created (`accountCreatedAt`) and `today`.
  - **Data Processing:** The Dart code maps this massive object into a clean `List<DailyHistory>`. 
  - **Rendering:** The heatmap logic iterates through this list. If the `totalMeals` (usually 3) equals `completedMeals` for a given date, that calendar square is painted bright green, gamifying consistency.

---

## 🗄️ Database Architecture & Schema Glossary

The backend relies completely on PostgreSQL managed via **Supabase**. Below is the table architecture outlining exactly what data lives where and how the app interacts with it:

### 1. `profiles` Table
- **Purpose**: The central source of truth for a user's physical metrics and app settings.
- **Key Columns**: `id` (UUID from Auth), `email`, `weight`, `height`, `age`, `gender`, `diet_type`, `goal`, `daily_targets` (JSON).
- **Interaction Patterns**:
  - `INSERT` triggered automatically via `supabase.auth.signUp()`.
  - `UPDATE` heavily during onboarding to store calculated metrics.
  - `SELECT` on app boot to populate the global `ProfileProvider`.

### 2. `meals` Table (The Recipe Catalog)
- **Purpose**: A centralized, deduplicated library of all unique meals generated by Gemini. This prevents the database from bloating with identical text blob recipes if multiple users get the same suggestion.
- **Key Columns**: `id`, `name`, `meal_time` (morning/afternoon/night), `ingredients` (Text Array), `recipe_steps` (Text Array), `calories`, `protein`, `carbs`, `fats`.
- **Interaction Patterns**:
  - `INSERT` only fires if the AI generates a novel meal name not currently in the catalog.
  - `SELECT` heavily used to hydrate the expansive `MealDetailSheet` UI.

### 3. `daily_plans` Table
- **Purpose**: The tracking hub for a single user on a single day. Think of this as the daily shopping cart for calories.
- **Key Columns**: `id`, `user_id`, `date` (YYYY-MM-DD), `consumed_calories`, `consumed_protein`, `consumed_carbs`, `consumed_fats`.
- **Interaction Patterns**:
  - `INSERT` generated silently when a user opens the app on a new day or generates meal plans.
  - `UPDATE` (via RPC) the macro tallies are exclusively mutated via the Supabase stored procedures `increment_daily_nutrition` and `decrement_daily_nutrition` to enforce thread safety.

### 4. `daily_plan_meals` Table (The Junction)
- **Purpose**: Resolves the many-to-many relationship. It links a specific `meal_id` from the catalog to a specific `daily_plan_id` on a specific day, tracking completion.
- **Key Columns**: `id`, `daily_plan_id`, `meal_id`, `meal_time`, `is_completed`, `completed_at`.
- **Interaction Patterns**:
  - `INSERT` 3 distinct rows are inserted immediately after a user accepts their AI generated daily plan.
  - `UPDATE` flips `is_completed` boolean back and forth as the user interacts with checkboxes in the UI.
  - `DELETE` wipes rows cleanly if the user abandons their current plan and opts to "Regenerate Meals" for the same active day.

---

## 🛠️ Complete Technology Stack

| Category | Package/Technology | Purpose |
|----------|-------------------|---------|
| **Core Framework** | `flutter` | UI rendering engine & framework (Dart). |
| **State Management** | `flutter_riverpod` (^2.6.1) | Reactive state, dependency injection, caching. |
| **Routing** | `go_router` (^14.6.2) | Declarative, URL-aware routing with Auth guards. |
| **Backend / DB** | `supabase_flutter` (^2.0.0) | Handles Auth session, Postgres DB interactions, edge functions. |
| **AI Integration** | `google_generative_ai` (^0.4.6) | Connects directly to Gemini models for meal generation. |
| **Device Hardware** | `health` (^12.0.0) | Abstracts iOS HealthKit and Android Health Connect reading. |
| **Permissions** | `permission_handler` (^12.0.1) | Manages OS-level prompts for Health data and notifications. |
| **Notifications** | `flutter_local_notifications` | Schedules local repeating reminders strictly on-device. |
| **Time Mapping** | `timezone` & `flutter_timezone` | Assures scheduled notifications trigger correctly globally. |
| **Data Viz** | `fl_chart` (^0.69.2) | Renders the complex 7-day bar charts and graphics. |
| **Animations** | `lottie` (^3.1.0) | Parses JSON animations for loading screens to improve UX. |
| **UI Components** | `introduction_screen`, `wheel_picker`, `percent_indicator` | Prebuilt battle-tested widgets to speed up MVP dev. |
| **Security** | `flutter_secure_storage` | Encrypts Supabase local sessions and tokens. |
| **Build Tools** | `freezed`, `json_serializable` | Generates immutable data classes and `fromJson`/`toJson` mappers. |

> *This document was generated to provide total architectural and feature clarity. All described paths, database relationships, and RPC logic directly reflect the current production-ready codebase found within the `lib/` directory.*
