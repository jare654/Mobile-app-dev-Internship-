# Internship Property App

An **Offline-First Property Listing Mobile Application** built with Flutter. This project demonstrates handling complex state, local caching, and synchronization in unstable network conditions.

## 🚀 Features

- **Offline-First Architecture**: View cached properties even when offline.
- **Optimistic UI**: Immediate feedback for user actions like favoriting.
- **Action Queueing**: Favorites and inquiries are queued while offline and automatically synced when the connection is restored.
- **Multi-lingual Support**: Supports both English and Amharic.
- **Dark Mode**: Fully supports system-wide dark mode.
- **Real-time Connectivity Awareness**: Visual indicators (banners and badges) for sync status and connection state.
- **Comprehensive Filtering**: Filter properties by location, price range, and bedrooms.

## 🛠 Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (Latest Stable)
- **State Management**: [Riverpod](https://riverpod.dev) (ChangeNotifierProvider pattern for centralized control)
- **Architecture**: Layered MVVM with Repository Pattern
- **Local Storage**: 
  - **Drift (SQLite)**: For structured property and action data.
  - **Hive**: For lightweight key-value storage and fallback.
- **Networking**: [Dio](https://pub.dev/packages/dio) with Interceptors
- **Localization**: Custom localization system for EN/AM.

## 🏗 Architecture Overview

The project follows a clear separation of concerns:

- **UI Layer (`lib/screens`, `lib/widgets`)**: Lean widgets focused on presentation.
- **State Layer (`lib/state`)**: `AppController` manages the application state and business logic.
- **Data Layer (`lib/data`)**: Repositories handle the logic of switching between remote (Dio) and local (Drift/Hive) sources.
- **Core Layer (`lib/core`)**: Entities, network clients, and shared utilities.

## 🚦 Getting Started

### Prerequisites
- Flutter SDK (>= 3.11.0)
- Android Studio / VS Code with Flutter extension

### Installation
1. **Download the APK**: You can download the latest production build from the [Releases](https://github.com/jare654/Mobile-app-dev-Internship-/releases/tag/v1.0.0) page.
2. Clone the repository.
3. Run `flutter pub get` to fetch dependencies.
4. Run `flutter run` to start the application.

### Running Tests
Execute the following command to run unit tests:
```bash
flutter test
```

## 📸 Screenshots
*(Add screenshots or video link here as per submission requirements)*
