# 🏋️‍♂️ Gym Training App — FitMax Pro

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Backend-orange?logo=firebase)
![License](https://img.shields.io/badge/License-MIT-green)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)

A **modern fitness management app** built with **Flutter** to help users **plan workouts, track nutrition, monitor progress, and stay motivated** with a supportive fitness community.

---

## ✨ Features

- **🏃 Workout Management** — Plan, track, and analyze your training sessions.
- **🥗 Nutrition Tracking** — Log meals and monitor macros.
- **📈 Progress Monitoring** — Visual charts & analytics.
- **💬 Social Features** — Share progress & join discussions.
- **🔐 Secure Authentication** — Sign-up & login with Firebase.
- **🤖 AI Chat Assistant** — Get personalized advice.
- **📷 Barcode/Food Scanning** — Quick meal logging via scan.
- **🔔 Notifications** — Stay on track with reminders.

---

## 📸 Screenshots

| Home Screen | Workout Plan | Nutrition Log |
|-------------|--------------|---------------|
| ![Home](screenshots/home.png) | ![Workout](screenshots/workout.png) | ![Nutrition](screenshots/nutrition.png) |

> *(Replace images with your actual screenshots inside a `/screenshots` folder.)*

---

## 🛠 Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **State Management:** Provider / Riverpod
- **Backend & Auth:** Firebase Authentication
- **Database:** Hive / SQLite
- **Push Notifications:** Firebase Cloud Messaging (FCM)
- **AI Chat:** OpenAI API integration
- **Barcode Scanner:** `flutter_barcode_scanner`

---

## 📂 Full Folder Structure

```
fitmax_pro/
│
├── android/                # Native Android code & Gradle configs
├── assets/                 # Images, icons, fonts
│   ├── fonts/
│   ├── icons/
│   └── images/
├── ios/                    # Native iOS code & configs
├── lib/
│   ├── main.dart           # App entry point
│   ├── constants/          # App constants & theme colors
│   ├── models/             # Data models (User, Workout, Nutrition)
│   ├── providers/          # State management providers
│   ├── screens/            # UI screens
│   │   ├── auth/           # Login, Signup, Forgot Password
│   │   ├── dashboard/      # Home, Stats, Progress
│   │   ├── workout/        # Workout plans, detail, tracking
│   │   ├── nutrition/      # Meal logging, barcode scan
│   │   ├── community/      # Social features, chat
│   │   └── settings/       # Profile, preferences
│   ├── services/           # Firebase, API, AI Chat, Notifications
│   ├── utils/              # Helpers, validators
│   └── widgets/            # Reusable UI components
├── screenshots/            # App preview images for README
├── test/                   # Unit & widget tests
├── pubspec.yaml            # Flutter dependencies
├── LICENSE                 # License file
└── README.md               # Project documentation
```

---

## 🚀 Getting Started

### 1️⃣ Clone the Repository
```bash
git clone https://github.com/yohabay/fitmax_pro
cd fitmax_pro
```

### 2️⃣ Install Dependencies
```bash
flutter pub get
```

### 3️⃣ Run the App
Ensure you have an emulator or device connected:
```bash
flutter run
```

---

## 📱 Usage

1. **Sign up / log in** to your fitness dashboard.
2. **Select a workout plan** based on your goals.
3. **Track workouts & log meals** daily.
4. **Review progress reports** and analytics.
5. **Engage with the community** for motivation.

---

## 📅 Roadmap

- [ ] Dark mode support
- [ ] Custom workout builder
- [ ] Wearable device integration (smartwatch)
- [ ] Multi-language AI chat
- [ ] Offline mode tracking

---

## 🤝 Contributing

We welcome contributions!  
Please read our [CONTRIBUTING.md](CONTRIBUTING.md) before making pull requests.

---

## 📜 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## 📬 Support & Contact

💡 **Have questions or feedback?**
- 📧 Email: `support@fitmaxpro.com`
- 🐙 GitHub Issues: [Open here](https://github.com/yohabay/fitmax_pro/issues)

---

> ⚡ *Built with Flutter — Driven by passion for fitness & technology.*
