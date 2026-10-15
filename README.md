# Notes Management

A Flutter notes app for capturing, organizing, and managing personal notes. Notes
are grouped into customizable categories, with Firebase providing authentication
and cloud storage.

## App preview

![Notes Management app screens](assets/img/Untitled.png)

## Features

- Create an account and sign in with email and password or Google.
- Require email verification for email-based accounts.
- Reset a forgotten password by email.
- Create, edit, and delete notes, including rich-text formatting and links.
- Organize notes into categories with a type, symbol, and accent color.
- Filter categories by type and browse notes across categories.
- Switch between light and dark themes; the theme preference is saved locally.
- Manage the account, including signing out and deleting account data.
- Store user, category, and note data in Cloud Firestore with owner-based access
  rules.

## Built with

- [Flutter](https://flutter.dev/) and Dart
- [Firebase Authentication](https://firebase.google.com/products/auth)
- [Cloud Firestore](https://firebase.google.com/products/firestore)
- [Flutter Quill](https://pub.dev/packages/flutter_quill) for rich-text editing

## Requirements

- Flutter SDK compatible with the Dart constraint in `pubspec.yaml`
- A Firebase project with Authentication and Cloud Firestore enabled
- Platform tooling for the target you want to run (for example, Android Studio
  for Android)

## Getting started

1. Clone this repository and open its root directory:

   ```bash
   git clone https://github.com/KottiMahdi/Notes-Flutter.git
   cd Notes-Flutter
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Configure Firebase for your Firebase project. Enable Email/Password and
   Google sign-in providers in Firebase Authentication, create a Cloud Firestore
   database, and configure the platforms you intend to run. If needed, use the
   [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup) to generate
   `lib/firebase_options.dart`.

4. Deploy the Firestore rules from this repository:

   ```bash
   firebase deploy --only firestore:rules
   ```

5. Run the app on a connected device or emulator:

   ```bash
   flutter run
   ```

## Validation

Run the analyzer and test suite from the project root:

```bash
flutter analyze
flutter test
```

## Project layout

```text
lib/
  controllers/    Application logic for authentication, categories, and notes
  core/           Shared utilities, widgets, and error handling
  models/         User, category, and note data models
  services/       Firebase and local preference integrations
  views/          Authentication, category, notes, and settings screens
assets/img/       App images and the README screenshot
```

## Android release builds

Release signing uses a local keystore at
`android/release/upload-keystore.jks`, which is excluded from source control.
Create `android/key.properties` from `android/key.properties.example` and add
the credentials for that keystore:

```properties
storeFile=release/upload-keystore.jks
storePassword=YOUR_KEYSTORE_PASSWORD
keyAlias=YOUR_KEY_ALIAS
keyPassword=YOUR_KEY_PASSWORD
```

For CI, provide `ANDROID_KEYSTORE_FILE`, `ANDROID_KEYSTORE_PASSWORD`,
`ANDROID_KEY_ALIAS`, and `ANDROID_KEY_PASSWORD` as protected secrets. The
release build does not fall back to the debug signing key.

Build the Android release artifacts with:

```bash
flutter build apk --release
flutter build appbundle --release
```
