# 🧬 Fitness Geni

<div align="center">
  <img src="fitness_geni/assets/logo/logo.png" alt="Fitness Geni Logo" width="220" height="220">
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
      <img src="https://i.postimg.cc/PrpMnL2Z/Simulator-Screenshot-i-Phone-16e-2026-02-11-at-09-23-40.png" width="200" alt="Splash Screen"/>
      <br/>
      <sub><b>Splash Screen</b></sub>
    </td>
    <td align="center">
      <img src="https://i.postimg.cc/fTGfzwPJ/Simulator-Screenshot-i-Phone-16e-2026-02-11-at-09-23-42.png" width="200" alt="Login"/>
      <br/>
      <sub><b>Sign In</b></sub>
    </td>
    <td align="center">
      <img src="https://i.postimg.cc/DzgrP1wy/Simulator-Screenshot-i-Phone-16e-2026-02-11-at-09-25-25.png" width="200" alt="Onboarding"/>
      <br/>
      <sub><b>Sign up</b></sub>
    </td>
    <td align="center">
      <img src="https://i.postimg.cc/NMCRWYTh/Simulator-Screenshot-i-Phone-16e-2026-02-11-at-09-25-54.png" width="200" alt="Onboarding"/>
      <br/>
      <sub><b>Enter your weight</b></sub>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://i.postimg.cc/zv9KGj0W/Simulator-Screenshot-i-Phone-16e-2026-02-11-at-09-25-59.png" width="200" alt="Splash Screen"/>
      <br/>
      <sub><b>Enter height</b></sub>
    </td>
    <td align="center">
      <img src="https://i.postimg.cc/m2H76vgp/Simulator-Screenshot-i-Phone-16e-2026-02-11-at-09-26-02.png" width="200" alt="Login"/>
      <br/>
      <sub><b>Age</b></sub>
    </td>
    <td align="center">
      <img src="https://i.postimg.cc/0yGD97mC/Simulator-Screenshot-i-Phone-16e-2026-02-11-at-09-26-10.png" width="200" alt="Onboarding"/>
      <br/>
      <sub><b>Enter diet type</b></sub>
    </td>
    <td align="center">
      <img src="https://i.postimg.cc/MTHQ04L7/Simulator-Screenshot-i-Phone-16e-2026-02-11-at-09-26-15.png" width="200" alt="Onboarding"/>
      <br/>
      <sub><b>Set your goals</b></sub>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://i.postimg.cc/c1VFHMK5/Simulator-Screenshot-i-Phone-16e-2026-02-11-at-09-26-18.png" width="200" alt="Login"/>
      <br/>
      <sub><b>Generate new meals</b></sub>
    </td>
    <td align="center">
      <img src="https://i.postimg.cc/3JmnD4mg/Simulator-Screenshot-i-Phone-16e-2026-02-11-at-09-26-36.png" width="200" alt="Onboarding"/>
      <br/>
      <sub><b>Add your ingridents</b></sub>
    </td>
    <td align="center">
      <img src="https://i.postimg.cc/fLVvWJD6/Simulator-Screenshot-i-Phone-16e-2026-02-11-at-09-26-48.png" width="200" alt="Onboarding"/>
      <br/>
      <sub><b>Let Ai decide</b></sub>
    </td>
     <td align="center">
      <img src="https://i.postimg.cc/hvxbx6Jr/Simulator-Screenshot-i-Phone-16e-2026-02-11-at-09-26-52.png" width="200" alt="Splash Screen"/>
      <br/>
      <sub><b>Wait while meals generated</b></sub>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://i.postimg.cc/hPW0gD6G/Simulator-Screenshot-i-Phone-16e-2026-02-11-at-09-27-26.png" width="200" alt="Login"/>
      <br/>
      <sub><b>Preview meals</b></sub>
    </td>
    <td align="center">
      <img src="https://i.postimg.cc/13M0ppt8/Simulator-Screenshot-i-Phone-16e-2026-02-11-at-09-27-29.png" width="200" alt="Onboarding"/>
      <br/>
      <sub><b>Meals details</b></sub>
    </td>
    <td align="center">
      <img src="https://i.postimg.cc/YSs1PMQt/Simulator-Screenshot-i-Phone-16e-2026-02-11-at-09-27-38.png" width="200" alt="Onboarding"/>
      <br/>
      <sub><b>Home screen with daily track</b></sub>
    </td>
    <td align="center">
      <img src="https://i.postimg.cc/RhrwMdPP/Simulator-Screenshot-i-Phone-16e-2026-02-11-at-09-27-47.png" width="200" alt="Splash Screen"/>
      <br/>
      <sub><b>Track daily progress</b></sub>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://i.postimg.cc/XqwdX5mG/Simulator-Screenshot-i-Phone-16e-2026-02-11-at-09-27-55.png" width="200" alt="Login"/>
      <br/>
      <sub><b>Also track steps, daily protein intake</b></sub>
    </td>
    <td align="center">
      <img src="https://i.postimg.cc/zDWndmv8/Simulator-Screenshot-i-Phone-16e-2026-02-11-at-09-26-30.png" width="200" alt="Onboarding"/>
      <br/>
      <sub><b>Profile screen</b></sub>
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
