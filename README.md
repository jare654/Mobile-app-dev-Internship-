# PulseNews — Flutter News Reader App

> **Mobile-app-dev-Internship- | Addis Ababa University**

---

## 1. Student Information

| Field | Details |
|---|---|
| **Name** | Yared Bekele |
| **Course** | Mobile Application Development — 4th Year, Semester 2 |
| **Instructor** | Abel Tadesse |

---

## 2. App Description

**PulseNews** is a production-grade Flutter news reader application. It has been expanded into a comprehensive 5-tab ecosystem:

- **Home Screen** — Top global headlines with varied placeholder support.
- **Explore Tab** — Staggered grid of 7+ news categories (Business, Tech, Science, etc.).
- **Search Tab** — Integrated debounced keyword search across all global sources.
- **Saved Tab** — Persistent article bookmarks using `shared_preferences`.
- **Settings Tab** — Regional configuration, Cache management, and Profile details.

**Key Enhancements:**
- **Persistent Bookmarks** — Save articles for later; bookmarks survive app restarts.
- **Robust In-App Reader** — Fixed WebView initialization issues with cross-platform fallbacks.
- **Varied Visuals** — Implemented seed-based placeholder images for articles missing media.
- **Polished UI** — Staggered animations and improved tab navigation.

---

## 3. Architecture

The app follows a strict **3-layer clean architecture**:

```
Presentation (Screens / Widgets)
        ↓  reads state from
State Layer (NewsProvider — ChangeNotifier)
        ↓  calls typed methods on
Service Layer (NewsApiService — owns all HTTP logic)
        ↓  communicates with
External API (newsapi.org)
```

Key patterns:
- `NewsApiService` is the **only** file that imports `package:http`
- All async errors are caught in `NewsProvider` and surfaced as typed messages
- Screens use `Consumer<NewsProvider>` — never call async functions in `build()`

---

## 4. Running the App Locally

### Prerequisites
- Flutter SDK `>=3.0.0`
- A free NewsAPI developer key from [https://newsapi.org/register](https://newsapi.org/register)

### Setup Steps

```bash
# 1. Clone the repository
git clone https://github.com/jare654/Mobile-app-dev-Internship-.git
cd Mobile-app-dev-Internship-

# 2. Setup your .env file
# Create assets/.env and add:
# NEWS_API_KEY=your_actual_key_here

# 3. Install dependencies
flutter pub get

# 4. Run the app
flutter run
```

> **⚠ Security:** The `assets/.env` file is excluded from version control via `.gitignore`.  
> **Never commit your actual API key.**

### Building a Release APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## 5. API Endpoints Used

| # | Method | Endpoint | Purpose |
|---|---|---|---|
| 1 | `GET` | `/v2/top-headlines?country={cc}&pageSize=20&page={n}` | Fetch paginated top headlines by country |
| 2 | `GET` | `/v2/everything?q={query}&pageSize=20&sortBy=publishedAt` | Full-text keyword search |

**Base URL:** `https://newsapi.org`  
**Authentication:** `X-Api-Key` header (preferred over query parameter)  
**Timeout:** 10 seconds on all requests  
**URI construction:** `Uri.https()` — no string concatenation  

---

## 6. Recent Fixes & Improvements

- **WebView Initialization**: Fixed the `WebViewPlatform.instance != null` assertion failure by implementing explicit platform-specific initialization in `main.dart` and `web_view_screen.dart`.
- **Varied Placeholders**: Replaced static placeholders with a seed-based `picsum.photos` service to ensure articles without images still look unique.
- **Settings Screen**: Updated profile name to **Yared Bekele**.
- **Build Fix**: Upgraded `workmanager` to `^0.9.0` to resolve Kotlin compilation errors during APK generation.

---

## 7. Packages Used

| Package | Version | Purpose |
|---|---|---|
| `http` | `^1.2.1` | All HTTP networking |
| `webview_flutter` | `^4.9.0` | In-app article reading |
| `workmanager` | `^0.9.0` | Background tasks |
| `flutter_dotenv` | `^5.2.1` | Secure API key management |
| `provider` | `^6.1.2` | State management |
| `cached_network_image` | `^3.3.1` | Efficient image loading |

---

*PulseNews — Addis Ababa University · School of IT & Engineering*
