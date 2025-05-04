# AGiXT Mobile

A life planning application that integrates with Even Realities G1 smart glasses, providing an AI-powered assistant experience.

![AGiXT Logo](assets/icons/agixt.png)

## Overview

AGiXT Mobile is a Flutter-based companion app designed to enhance the user experience of Even Realities G1 smart glasses. This application bridges the gap between AI-powered planning and wearable technology, offering users a seamless way to interact with their digital assistant through voice commands, display information directly on their glasses, and manage their daily schedules.

## Features

### 🔄 Bluetooth Connectivity
- Seamless pairing with Even Realities G1 smart glasses
- Auto-reconnection to previously paired devices
- Real-time bi-directional communication with both left and right glasses

### 🎤 Voice Recognition
- On-device speech recognition for multiple languages
- Real-time transcription display on glasses
- Speech-to-text processing that feeds into the AI assistant

### 📅 Calendar & Planning
- Integration with device calendars
- Smart scheduling and event management
- Display of upcoming events on glasses dashboard

### 📱 Notifications
- Forward phone notifications to glasses display
- Filter and prioritize notifications
- Custom appearance for different notification types

### 🌐 Translation
- Real-time translation between multiple languages
- Display of both original and translated text
- Support for over 10 languages including English, Chinese, Japanese, Russian, Korean, Spanish, French, German, Dutch, Norwegian, Danish, Swedish, Finnish, and Italian

### 📊 Dashboard
- Customizable dashboard layouts
- Time and weather information display
- Note management system
- Task and checklist tracking

## Supported Languages

AGiXT supports voice recognition in the following languages:
- English (US)
- Chinese
- Japanese
- Russian
- Korean
- Spanish
- French
- German
- Dutch
- Norwegian
- Danish
- Swedish
- Finnish
- Italian

## Getting Started

### Prerequisites
- Flutter SDK ^3.5.4
- iOS 13+ for iOS deployment
- Android API level 16+ for Android deployment
- Even Realities G1 smart glasses for full functionality

### Installation

1. Clone the repository:
```bash
git clone https://github.com/AGiXT/mobile.git
cd mobile
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

## Development

### Project Structure
- `lib/`: Main source code
  - `main.dart`: Application entry point
  - `models/`: Data models
  - `screens/`: UI screens
  - `services/`: Business logic and services
  - `utils/`: Utility functions
  - `widgets/`: Reusable UI components
- `ios/`: iOS-specific code including native Swift implementations
- `android/`: Android-specific code
- `assets/`: Images, icons, and other static resources

### Key Components

#### Bluetooth Manager
The heart of the application, responsible for scanning, connecting, and communicating with the G1 glasses.

#### Speech Recognition
Implemented natively in Swift for iOS, provides real-time speech-to-text capabilities with support for multiple languages.

#### Background Services
Ensures continuous connectivity with glasses and processes notifications even when the app is in the background.

## Usage

1. **Pair with G1 Glasses**: Navigate to the settings and scan for nearby G1 glasses
2. **Voice Commands**: Tap the microphone button and speak to activate voice recognition
3. **Dashboard Management**: Customize what information appears on your glasses display
4. **Calendar Integration**: Connect your calendar to see events directly on your glasses

## Privacy & Security

- Speech recognition is performed on-device for enhanced privacy
- Data transmission between the app and glasses is secured
- User preferences and settings are stored locally

## License

This project is licensed under the [LICENSE](LICENSE) file in the repository.

## Acknowledgments

- Even Realities for the G1 smart glasses platform
- Flutter team for the amazing cross-platform framework
- All contributors who have helped build and improve AGiXT
