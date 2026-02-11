# 🧬 Fitness Geni

<div align="center">
  <img src="assets/logo/logo.png" alt="Fitness Geni Logo" width="120" height="120">
</div>

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase">
  <img src="https://img.shields.io/badge/Riverpod-2D3748?style=for-the-badge&logo=riverpod&logoColor=white" alt="Riverpod">
  <img src="https://img.shields.io/badge/Gemini_AI-8E75B2?style=for-the-badge&logo=google&logoColor=white" alt="Gemini AI">
  <img src="https://img.shields.io/badge/Clean_Architecture-42A5F5?style=for-the-badge&logo=flutter&logoColor=white" alt="Clean Architecture">
  <img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" alt="MIT License">
</div>

<div align="center">
  <h3>An intelligent, AI-powered personal fitness companion built with Flutter</h3>
  <p>Track nutrition, workouts, and health metrics with a premium, intelligent experience powered by Google Gemini AI and Supabase.</p>
</div>

---

## 📋 Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Architecture](#-architecture)
- [Screenshots](#-screenshots)
- [Getting Started](#-getting-started)
- [Project Structure](#-project-structure)
- [AI Integration](#-ai-integration)
- [Contributing](#-contributing)
- [License](#-license)

## ✨ Features

### 🎯 Core Features
- **AI-Powered Insights**: Leveraging **Google Gemini** to provide intelligent health tips and customized recommendations.
- **Smart Nutrition Tracking**: visually track your daily meals—Breakfast, Lunch, and Dinner—with ease.
- **Health Connect Integration**: Automatically syncs steps, calories burned, and distance from **Apple Health** and **Health Connect**.
- **Visual Analytics**: Interactive graphs and charts to visualize your progress over time.
- **Goal Setting**: Set and track daily nutrition and fitness goals.

### 🔧 Technical Features
- **State Management**: Robust state management using **Riverpod** for predictable data flow.
- **Secure Authentication**: Seamless login and signup powered by **Supabase Auth**.
- **Offline Support**: Local caching strategies ensure data availability (using Shared Preferences/Secure Storage).
- **Responsive UI**: A stunning, dark-themed interface with glassmorphism and **Lottie** animations.

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| **Frontend** | Flutter 3.10+ (Dart) |
| **State Management** | Flutter Riverpod |
| **Backend** | Supabase (PostgreSQL, Auth, Edge Functions) |
| **AI Integration** | Google Generative AI (Gemini) |
| **Routing** | GoRouter |
| **Local Storage** | Shared Preferences, Flutter Secure Storage |
| **Charts** | FL Chart |
| **Animations** | Lottie |
| **Health Data** | Health, Permission Handler |

## 🏗️ Architecture

This application follows a **Feature-First Clean Architecture** to ensure scalability and maintainability:

```
lib/
├── core/                 # Core functionality (Constants, Theme, Utils)
├── features/             # Feature-based modules
│   ├── auth/             # Authentication (Login, Signup)
│   ├── home/             # Home Dashboard & Widgets
│   ├── fit/              # Fitness Tracking logic
│   ├── onboarding/       # User Onboarding flow
│   ├── profile/          # User Profile management
│   └── splash/           # App Splash Screen
├── shared/               # Shared widgets and logic
└── main.dart             # Application Entry Point
```

### 🔄 Data Flow

```mermaid
graph TD
    UI[Presentation Layer] --> Domain[Domain Layer]
    Domain --> Data[Data Layer]
    Data --> Remote[Supabase / API]
    Data --> Local[Local Storage]
    
    subgraph Features
        Auth[Authentication]
        Home[Home Dashboard]
        Fit[Fitness Tracking]
        Profile[User Profile]
    end
```

## 📱 Screenshots

<table>
  <tr>
    <td align="center">
      <img src="assets/images/placeholder_splash.png" width="200" alt="Splash Screen"/>
      <br/>
      <sub><b>Splash Screen</b></sub>
    </td>
    <td align="center">
      <img src="assets/images/placeholder_login.png" width="200" alt="Login"/>
      <br/>
      <sub><b>Authentication</b></sub>
    </td>
    <td align="center">
      <img src="assets/images/placeholder_onboarding.png" width="200" alt="Onboarding"/>
      <br/>
      <sub><b>Onboarding</b></sub>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="assets/images/placeholder_home.png" width="200" alt="Home Dashboard"/>
      <br/>
      <sub><b>Home Dashboard</b></sub>
    </td>
    <td align="center">
      <img src="assets/images/breakfast.png" width="200" alt="Breakfast Tracking"/>
      <br/>
      <sub><b>Nutrition: Breakfast</b></sub>
    </td>
    <td align="center">
      <img src="assets/images/lunch.png" width="200" alt="Lunch Tracking"/>
      <br/>
      <sub><b>Nutrition: Lunch</b></sub>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="assets/images/dinner.png" width="200" alt="Dinner Tracking"/>
      <br/>
      <sub><b>Nutrition: Dinner</b></sub>
    </td>
    <td align="center">
      <img src="assets/images/placeholder_stats.png" width="200" alt="Statistics"/>
      <br/>
      <sub><b>Health Statistics</b></sub>
    </td>
    <td align="center">
      <img src="assets/images/placeholder_profile.png" width="200" alt="Profile"/>
      <br/>
      <sub><b>User Profile</b></sub>
    </td>
  </tr>
</table>

> *Note: Please replace the placeholder images (Splash, Login, etc.) with actual screenshots from your application to complete the gallery.*

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.10.x or later)
- [Supabase Account](https://supabase.com/)
- [Gemini API Key](https://ai.google.dev/)

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/yourusername/fitness_geni.git
    cd fitness_geni
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Environment Configuration**
    Create a `.env` file in the root directory:
    ```env
    SUPABASE_URL=your_supabase_url
    SUPABASE_ANON_KEY=your_supabase_anon_key
    GEMINI_API_KEY=your_gemini_api_key
    ```

4.  **Run the application**
    ```bash
    flutter run
    ```

## � AI Integration

**Fitness Geni** uses **Google Gemini** to process user health data and provide actionable insights.
-   **input**: User's nutrition logs, activity levels, and goals.
-   **Process**: Gemini analyzes trends and compares them against health benchmarks.
-   **Output**: Personalized suggestions for meal improvements and workout adjustments.

## 🤝 Contributing

We welcome contributions! Please follow these steps:
1.  Fork the repository.
2.  Create a feature branch: `git checkout -b feature/AmazingFeature`.
3.  Commit your changes: `git commit -m 'Add some AmazingFeature'`.
4.  Push to the branch: `git push origin feature/AmazingFeature`.
5.  Open a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">
  <p>Made with ❤️ by <strong>Aditya Magar</strong></p>
  <p>If you found this project helpful, please consider giving it a ⭐ top right!</p>
</div>
