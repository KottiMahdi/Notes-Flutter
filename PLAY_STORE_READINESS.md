# Google Play Readiness Report

Audit basis: the Flutter application source, Android manifest and Gradle files,
Firebase configuration, Firestore rules, and declared dependencies in this
repository. This document describes observed behavior only; it is not legal
advice and does not replace the Play Console Data safety questionnaire.

## Ready

- Android application ID is `com.blockNote.app`.
- The Android Firebase client in `android/app/google-services.json` uses the
  same package ID and project `myapp-e91fb` as `lib/firebase_options.dart`.
- The Android label is `Notes` and the manifest points to the generated
  launcher icon resource `@mipmap/ic_launcher`.
- The manifest declares no runtime permissions. Cleartext traffic is disabled.
- The release merged manifest verifies package `com.blockNote.app`,
  `targetSdkVersion 36`, `versionCode 1`, and `versionName 1.0.0`.
- Firebase Authentication supports email/password and Google Sign-In. Email
  verification is required before an email/password session is accepted.
- Firestore rules restrict user profiles, categories, and nested notes to the
  authenticated owner. Rules must still be verified with the Firebase Emulator
  or deployed-project tests before release.
- No Analytics, Crashlytics, AdMob, device-information, attribution, or
  third-party tracking package is declared or used in application code.
- The release dependency graph contributes Firebase Dynamic Links components,
  but no application code invokes Dynamic Links; verify whether this unused
  transitive SDK should be removed before final submission.
- Release builds require an explicitly configured upload keystore and do not
  fall back to debug signing.
- `flutter analyze` passes and the Flutter test suite passes in the audited
  workspace.

## Data Inventory

| Data | Observed processing | Purpose | Collection | Sharing | Required | Security and deletion |
| --- | --- | --- | --- | --- | --- | --- |
| Email address | Firebase Auth account; copied to `Users/{uid}.Email` | Account sign-in, verification, and password reset | Yes | Firebase processes it; no app-controlled ad/analytics sharing observed | Required for email/password auth; Google identity may supply an email | Firebase Auth and owner-only Firestore rules. No in-app account deletion flow was found. |
| Firebase Auth UID | Auth identity and `Users/{uid}.uid` | Identify the signed-in owner | Yes | Firebase service processing; not exposed to other app users by rules | Required | Used in ownership checks and Firestore rules. Deletion requires removing the Auth user and related records. |
| Google account identity | Google Sign-In credential and Firebase Auth provider identity | Optional Google authentication | Yes, only when Google Sign-In is used | Google and Firebase process the sign-in exchange; no separate app database copy was observed | Optional | Managed by Google/Firebase authentication. Account deletion implications still apply. |
| Username | `Users/{uid}.Username` | Display/profile data entered during registration | Yes for email registration | Firebase Firestore; owner-only access | Required by the registration form | Owner-only Firestore rules. Delete with the user profile. |
| Notes | `categories/{categoryId}/note/{noteId}.note` | User-created note content | Yes when a user creates notes | Firebase Firestore; owner-only access | Optional feature data | Owner UID is stored and enforced by rules. Delete with the account or when the user deletes the note. |
| Categories | `categories/{categoryId}.name` | Organize notes | Yes when a user creates categories | Firebase Firestore; owner-only access | Optional feature data | Owner UID is stored and enforced by rules. Delete with the account or when the user deletes the category. |
| Firebase-generated metadata | Firestore `createdAt` server timestamp on user profile; Firebase service logs may also exist | Record profile creation and operate Firebase services | Yes | Firebase processes service metadata | Service-generated | Retention and deletion of provider logs are controlled by Firebase terms/settings and need console review. |
| Device/application information | No direct collection code or device-info SDK observed | None in app code | Not observed in app code | No app-controlled sharing observed | N/A | Verify Play's automatic SDK disclosures against the final dependency graph and Firebase console. |
| Analytics/crash data | No Analytics or Crashlytics dependency or initialization observed | None | Not observed | No app-controlled sharing observed | N/A | Do not declare analytics or crash collection unless it is enabled outside this repository. |

## Privacy Policy Content Requirements

The published policy should identify the developer/controller and contact
address, explain the email/password and optional Google authentication flows,
describe the profile, category, and note data stored in Firebase, explain the
owner-based Firestore access controls, identify Firebase and Google as service
providers where applicable, state retention and deletion procedures, explain
verification and password-reset emails, describe children/age handling, and
provide a method for privacy requests and policy updates.

The app now provides an account deletion action from the home screen. The
policy must explain that deletion removes the Firebase Auth account, the user
profile, owned categories, and nested notes. The developer must still define
retention exceptions, failure handling, and any Firebase provider log
retention before publishing a deletion promise.

## Needs Configuration

- Set the final Play version name and monotonically increasing version code;
  the current release is `1.0.0` / `1`.
- Reconfirm that target SDK 36 remains within the current Play requirement at
  submission time.
- Confirm the release keystore, alias, certificate fingerprints, and Play App
  Signing setup. The repository contains a local upload keystore, but the
  credentials and Play enrollment cannot be verified from source.
- Complete Firebase Console configuration for the production Android package,
  email templates, authorized domains, Google provider, and Firestore rules.
- Complete Play Console Data safety, App content, target audience, content
  rating, app access, and account-deletion declarations using the final build.
- Verify the merged release manifest and transitive SDK behavior before the
  Data safety submission.

## Needs Legal/Content

- Final privacy policy URL and the developer identity/contact details.
- Data retention periods and the operational process for failed or incomplete
  deletion requests, including Firebase provider logs.
- Terms of service, support contact, age/children position, and regional
  privacy rights language where applicable.
- Accurate declarations for Firebase/Google provider processing based on the
  production Firebase project settings, not only this source tree.

## Blockers

1. **Firestore rules lack an emulator-backed security test in this repository.**
   Controller tests use `FakeFirebaseFirestore`; add and run Firebase Emulator
  rules tests before treating authorization as release evidence. This is a
  release-assurance gap, not a claim that Play will execute the rules tests.

## External Services and Permissions

- Firebase Authentication: email/password, email verification, password reset,
  and Google provider.
- Cloud Firestore: profile, category, and note storage.
- Google Sign-In: optional authentication provider.
- No ads, analytics, crash reporting, storage, messaging, location, contacts,
  camera, microphone, or calendar integration was found.
- No explicit Android runtime permission is declared by the application
  manifest.