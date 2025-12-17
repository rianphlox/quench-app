# 💧 Quench - Hydration Tracking App

A beautiful and intuitive Flutter mobile application designed to help users track their daily water intake and maintain healthy hydration habits.

## ✨ Features

### Core Functionality
- **Daily Water Tracking**: Log water intake with preset volumes (50ml to 750ml) or custom amounts
- **Animated Progress**: Beautiful wave animation showing daily hydration progress
- **Smart Reminders**: Customizable local notifications to remind users to stay hydrated
- **Streak Counter**: Track consecutive days of meeting hydration goals
- **Achievement System**: Unlock badges for reaching milestones

### User Experience
- **Splash Screen**: Engaging animated entry point with motivational quotes
- **Onboarding Flow**: Smooth introduction for new users
- **Dark/Light Themes**: "Midnight" dark theme with seamless switching
- **Aqua Color Scheme**: Consistent cyan/blue theming throughout the app
- **Responsive Design**: Optimized layouts for various screen sizes

### Insights & Analytics
- **Calendar View**: Visual representation of daily hydration patterns
- **Progress Charts**: Track intake trends over time
- **Hydration Coach**: Personalized tips and encouragement
- **Goal Management**: Adjustable daily water intake targets

## 🛠️ Tech Stack

- **Framework**: Flutter 3.9.2+
- **State Management**: Provider pattern
- **Local Storage**: SQLite database with SharedPreferences
- **Notifications**: Flutter Local Notifications with timezone support
- **Animations**: Wave progress, confetti celebrations, staggered animations
- **UI Libraries**:
  - `flutter_svg` for vector graphics
  - `cached_network_image` for optimized image loading
  - `flutter_staggered_animations` for smooth transitions
  - `confetti` for celebration effects

## 📱 Installation

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart SDK
- Android Studio / VS Code
- Android device or emulator

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/rianphlox/quench-app.git
   cd quench-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building APK

For production builds with split APKs:
```bash
flutter build apk --split-per-abi
```

This generates optimized APKs for different architectures:
- `app-armeabi-v7a-release.apk` (ARM 32-bit)
- `app-arm64-v8a-release.apk` (ARM 64-bit) - **Recommended**
- `app-x86_64-release.apk` (Intel 64-bit)

## 🎨 Design Philosophy

Quench embraces a clean, aqua-themed design that:
- Uses consistent cyan/blue colors (#06b6d4) throughout the interface
- Implements water-drop iconography and wave animations
- Prioritizes accessibility with clear typography and intuitive navigation
- Provides delightful micro-interactions to encourage daily usage

## 📊 Project Structure

```
lib/
├── constants/          # App-wide constants and theme definitions
├── models/            # Data models (UserSettings, WaterLog, Badge)
├── screens/           # UI screens (Home, Settings, Insights, etc.)
├── services/          # Business logic (Storage, Notifications, Audio)
├── widgets/           # Reusable UI components
└── utils/            # Utility functions and helpers
```

## 🔧 Configuration

### Notification Permissions
The app includes properly configured Android manifest entries for:
- POST_NOTIFICATIONS permission
- WAKE_LOCK for reliable scheduling
- Boot receivers for persistent reminders

### Storage
- **SQLite**: Water intake logs and historical data
- **SharedPreferences**: User settings and preferences
- **Automatic cleanup**: Manages storage efficiently

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with Flutter's powerful cross-platform framework
- Icons and illustrations from various open-source projects
- Inspired by modern hydration tracking methodologies

---

**Made with 💙 by Qubators**

*Stay hydrated, stay healthy!* 💧