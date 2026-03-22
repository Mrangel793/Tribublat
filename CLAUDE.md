# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**TribuLat / ParcheApp** — a Flutter social planning app (Android/iOS) where users create and join local events ("parches"). Backend is Firebase (Auth, Firestore, Messaging).

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Lint / static analysis
flutter analyze

# Format code
flutter format .

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Regenerate Freezed models (only when changing @freezed classes)
dart run build_runner build --delete-conflicting-outputs

# Clean build artifacts
flutter clean && flutter pub get
```

> **Warning:** The `.freezed.dart` files were generated manually because `build_runner` had environment issues. After any change to a `@freezed` class, regenerate with `build_runner` and verify the output. Do **not** upgrade dependency versions without checking cross-compatibility — several packages are pinned at specific versions due to breaking API changes.

## Architecture

The project follows **Clean Architecture** with feature-based vertical slicing under `lib/src/features/`. Each feature is divided into:

- `data/` — repositories, external data sources (Firebase)
- `domain/` — models, constants, business entities
- `presentation/` — screens, controllers (Riverpod), widgets

### State Management: Riverpod

All state is managed via `flutter_riverpod` + `hooks_riverpod`. Controllers use `@freezed` state objects. Central providers live in `lib/src/features/auth/provider/auth_provider.dart` and are scoped per feature.

Pattern for a controller:
```dart
// FooState is a @freezed class
final fooControllerProvider = StateNotifierProvider<FooController, FooState>((ref) {
  return FooController(ref.watch(someRepositoryProvider));
});
```

### Navigation: GoRouter (`lib/src/config/router/app_router.dart`)

- `/splash` → `/welcome` → `/login` or `/register`
- After successful registration: `/profile/step-1` → `/profile/step-2` → `/profile/step-3` → `/`
- `/` is `MainScreen` — 5-tab bottom nav (Feed, Explore, Create, Alerts, Profile)
- Role-protected routes (`/admin`, `/business/metrics`) use `RoleGuard` in `lib/src/config/router/guards/role_guard.dart`
- Redirect logic: unauthenticated users → `/login`; incomplete profile → `/profile/step-1`; completed profile blocks re-entry to `/profile/*`

### Firebase / Data Layer

- **Auth:** Email/password + Google Sign-In + Apple Sign-In via `AuthRepository`
- **Firestore:** Plans (`PlanModel`), Users (`UserModel`), Metrics (`PlanMetricsModel`)
- **Images:** Stored as **Base64 strings in Firestore** (no Firebase Storage currently). See `StorageService` and `Base64ImageWidget`.
- **Push Notifications:** `firebase_messaging`

### Key Domain Constants

- `lib/src/features/user/domain/interests_constants.dart` — interest categories
- `lib/src/features/plans/domain/` — plan categories, energy levels, and other enums

### Theme

Material Design 3, seed color `#9B59B6` (purple). Defined in the root `app.dart`. Dark theme colors in `lib/src/common/theme/dark_feed_colors.dart`.

## Dependency Version Constraints

These packages are pinned to specific versions — do **not** upgrade without verifying API compatibility:

| Package | Version | Reason |
|---|---|---|
| `google_sign_in` | `^6.2.1` | v7.x has incompatible API |
| `sign_in_with_apple` | `^6.1.2` | Linked to google_sign_in v6 |
| `image_cropper` | `^4.0.1` | v5.x has web platform issues |
| `google_places_flutter` | `^2.1.1` | v3.0.0 does not exist on pub.dev |
