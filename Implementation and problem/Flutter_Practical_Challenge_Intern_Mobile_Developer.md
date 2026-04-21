


## Flutter Practical Challenge: Intern Mobile
## Developer
## Project Overview
Build an Offline-First Property Listing Mobile Application using Flutter. The application should
function reliably under unstable or no internet connectivity. This challenge evaluates your ability to
handle architecture, state management, and offline behavior rather than visual perfection.
Tech Stack (Required)
● Framework: Flutter (latest stable)
● Architecture: Clean Architecture or MVVM
● State Management: Riverpod, Bloc/Cubit, or Provider (must justify choice)
● Local Storage: Hive, Drift, or SQLite
● Networking: Dio or http
## User Roles
- Guest User: View and filter published properties.
- Logged-in User: Save favorites and send inquiry messages (offline capable).
## Property Model
Each property must include:
## Page | 1


● ID, Title, and Description
● Location and Price
● Multiple Image URLs
● Status (Published/Archived)
## ● Last Updated Timestamp
## Core Requirements
● Offline-first behavior: Data must be cached for offline viewing.
● Action Queueing: User actions (like favoriting) should sync automatically when back online.
● Network Awareness: Real-time UI feedback for connection status.
● Optimistic UI: Update the UI immediately before the server confirms the action.
● State Handling: Proper loading, empty, and error states throughout the app.
## Screens Required
## ● Property List Screen
## ● Property Detail Screen
## ● Favorites Screen
## ● Profile / Settings Screen
● Offline Indicator UI (Banner or icon showing sync status)
## Architecture & Design
The app must have a clear separation of UI, State, Business Logic, and Data layers.
● Use Repositories for data handling.
● Implement Dependency Injection (DI).
● Keep widgets lean and avoid "bloated" logic within the UI.
## Page | 2



Bonus Features (Optional)
● Unit tests for core business logic.
## ● Custom Network Interceptors.
● Background sync simulation.
● Dark mode support.
## Submission Requirements
- Technical Decision Document: A short write-up explaining your state management choice,
offline sync approach, architecture scalability, and main challenges.
- GitHub Repository: Clean code with a clear commit history.
- Build: APK file or Flutter Web build.
- Documentation: README with setup instructions and architecture overview.
- Media: Short demo video (2–3 minutes) or detailed screenshots.
Time Limit: 5 days. Focus on clarity and correctness; avoid over-engineering.


## Page | 3