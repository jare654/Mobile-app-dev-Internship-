# Technical Decisions

This document outlines the architectural and technical choices made during the development of the Intern Property App.

## 1. State Management: Riverpod
**Choice**: `flutter_riverpod` using a `ChangeNotifierProvider` for the `AppController`.

**Justification**:
- **Centralized Logic**: `AppController` acts as a single source of truth for the application state (authentication, connectivity, properties, and favorites).
- **Testability**: Riverpod's `ProviderScope` allows for easy overriding of providers with mocks during testing.
- **Performance**: Riverpod handles dependency injection and state updates efficiently, ensuring only relevant widgets rebuild.
- **Scalability**: While the project currently uses a single controller for simplicity, Riverpod easily allows splitting into smaller, feature-specific providers as the app grows.

## 2. Offline-First Approach & Sync Strategy
**Local Storage**:
- **Drift (SQLite)** is used for structured data (Property, PendingAction) because it provides powerful querying and transaction support.
- **Hive** is used for simple key-value pairs (Theme, Language, User preferences) and as a fallback for the property store to ensure robustness.

**Sync Logic**:
- **Optimistic UI**: When a user favorites a property, the UI updates immediately. The action is persisted locally and queued for remote sync.
- **Action Queueing**: User actions performed offline (favoriting, sending inquiries) are stored as `PendingAction` objects in the local database.
- **Connectivity Trigger**: The app monitors connection changes. When transitioning from offline to online, it automatically triggers the `_syncPendingActions` routine in the `AppController`.
- **Retry Mechanism**: Failed sync attempts increment a retry counter. Actions are retried up to 3 times before requiring manual intervention or further logic.

## 3. Architecture Scalability
The project follows a **Layered MVVM (Model-View-ViewModel)** architecture:
- **Separation of Concerns**: Business logic is completely detached from the UI, residing in the `AppController` and Repositories.
- **Repository Pattern**: Abstract interfaces for repositories allow swapping data sources (e.g., from a mock API to a real REST API) without touching the UI or State layers.
- **Modular Core**: Shared logic, network clients, and localization are centralized in the `core` folder for reusability across features.

## 4. Main Challenges & Solutions
- **Challenge: Robust SQLite Initialization**: SQLite initialization can occasionally fail on certain devices/platforms.
  - **Solution**: Implemented a factory pattern (`DriftStoreFactory`) that falls back to `Hive` if `Drift` fails to open, ensuring the app remains functional.
- **Challenge: Optimistic State Consistency**: Managing local state vs. remote state during sync.
  - **Solution**: Used a "Queue & Clear" strategy where pending actions are cleared only after a successful property refresh from the remote source, ensuring the local view remains consistent with the server.
- **Challenge: Multi-lingual Support**: Ensuring the UI supports LTR/RTL and dynamic language switching without app restarts.
  - **Solution**: Developed a custom `AppStrings` class integrated with the `AppController` to provide reactive localization.

## 5. Potential Improvements
- **Real Background Sync**: Integrate `workmanager` or `background_fetch` for syncing even when the app is terminated.
- **Granular Error Handling**: Implement specific UI feedback for different types of network errors (404, 500, etc.) via Dio interceptors.
- **Pagination**: Implement infinite scrolling in the `PropertyListScreen` to handle larger datasets efficiently.
