# Rivio Mobile - Habit, Mood & Sleep Tracker

![Flutter](https://img.shields.io/badge/Flutter-3.24-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.2-0175C2?logo=dart)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-success)

Cross-platform mobile application for tracking daily habits, sleep quality, and mood. Built with Flutter and designed to work with the [Rivio Django REST API backend](https://github.com/Z4phxr/HabbitTracker).

**Backend**: Django + PostgreSQL (Railway)  
**Frontend**: Flutter + Riverpod

---

## Overview

Rivio Mobile is a production-ready Flutter application that enables users to track and visualize their daily habits, sleep patterns, and emotional well-being. The app operates as a thin client, with all business logic and data persistence handled by the backend API.

**Key Characteristics:**
- Frontend-only architecture (no local database)
- Secure JWT authentication with automatic token refresh
- Environment-based configuration (development/production)
- Material Design 3 with custom theming
- Real-time synchronization with backend API


## Features

- **Habit Tracking**: Create, edit, and monitor daily habits with completion tracking
- **Sleep Logging**: Record sleep duration and quality metrics
- **Mood Monitoring**: Track emotional states with visual representations
- **User Authentication**: Secure registration and login with JWT tokens
- **Data Visualization**: Charts and graphs using fl_chart
- **Multi-Theme Support**: Light, dark, and custom theme variants
- **Offline Handling**: Graceful error handling for connectivity issues
- **Account Management**: Profile settings, PIN security, account deletion


## Architecture

### Technology Stack

| Component | Technology |
|-----------|-----------|
| Framework | Flutter 3.24+ |
| Language | Dart 3.2+ |
| State Management | Riverpod 2.6+ |
| HTTP Client | Dio 5.4+ |
| Navigation | go_router 17.1+ |
| Secure Storage | flutter_secure_storage 10.0+ |
| Charts | fl_chart 1.1+ |
| Configuration | flutter_dotenv 6.0+ |



## Security
### Token Management

- Access tokens stored in platform-specific secure storage (Keychain on iOS, Keystore on Android)
- Automatic token refresh on 401 responses via Dio interceptors
- Tokens cleared on logout and account deletion

### Network Security

- HTTPS enforced for production via network security configuration
- Certificate validation for all requests
- Sensitive data sanitization in debug logs

### Build Security

- ProGuard/R8 obfuscation enabled for release builds
- Debug logging stripped from release builds
- No hardcoded secrets or API keys


## Development

### Running Tests

```bash
# Run unit tests
flutter test test/unit/

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

### Code Generation

This project does not use code generation (`build_runner`, `freezed`, etc.). All models use manual serialization.

### Linting

Static analysis is configured via `analysis_options.yaml`:

```bash
flutter analyze --fatal-infos --fatal-warnings
```

---

### IOS compatability

Fully compatible, but im not paying $99


### Note from the dev

I don’t usually build mobile apps, but I live by one thought:  
If you want it, you build it.
And I really DID want a personalized mobile app. So I built it (insted of sleeping <3)

