# Google Play MVP Scope

## Objective
Ship a secure and stable first release of the personal notes app by focusing only on the core user flows that matter most for launch: authentication, categories, notes, and release readiness.

The main goal is to keep the app simple, production-safe, and Google Play ready without expanding into feature bloat before the first public release.

---

## 1) In Scope for MVP
These are the features that belong in the first release:

- Email/password authentication
- Google sign-in
- Password reset flow
- Email verification gate before use
- Category create, read, update, delete
- Note create, read, update, delete within each category
- Session restore on app launch
- Sign-out flow
- Loading and error states for all major actions

### MVP user story
A user can sign up or log in, create personal note categories, add notes inside them, and use the app reliably without breaking data isolation or security.

---

## 2) Out of Scope for MVP
These features should be explicitly deferred until after the first Play Store release:

- Sharing and collaboration
- Real-time multi-user sync
- Rich text editing
- Reminders and task scheduling
- Attachments or media uploads
- Advanced search and filtering
- Theming overhaul / UI redesign
- Offline-first feature expansion

These items belong in the product backlog, not in the initial release.

---

## 3) Release Blockers to Fix First
Before launching to Google Play, these issues must be addressed:

1. Production Android signing
   - Replace debug signing with a proper release keystore.
   - Confirm the app generates a signed release AAB.

2. Firestore security rules
   - Add and deploy rules that restrict access to each user’s own data.
   - Validate category and note ownership across multiple accounts.

3. Data protection and privacy
   - Prepare a privacy policy.
   - Match the Play Console Data Safety form to the app’s actual data usage.

4. Test coverage
   - Replace the default starter test with app-specific tests.
   - Validate auth and CRUD flows.

5. Manifest and config checks
   - Confirm the release manifest includes required permissions.
   - Verify Firebase and Android package identity are aligned.

---

## 4) Implementation Roadmap

### Phase 1: Lock MVP boundaries
- Keep the release scope to auth + categories + notes + session handling.
- Defer sharing, rich text, attachments, search, reminder features, and broader redesigns.

### Phase 2: Release-blocker fixes
- Configure production Android signing.
- Add Firestore rules to repo and deploy them.
- Validate ownership checks for categories and notes.
- Confirm play-ready manifest and Firebase config values.

### Phase 3: Product hardening
- Add app-specific tests.
- Improve validation and error messaging.
- Normalize user record storage to UID-based ownership patterns.
- Strengthen session restoration and auth-state handling.

### Phase 4: Play Console readiness
- Prepare privacy policy and Data Safety declarations.
- Verify package ID, Firebase mapping, and artifact metadata.
- Run a final real-device QA check before internal testing.

### Phase 5: Post-launch backlog
- Real-time sync improvements
- Offline-first UX enhancements
- Pin/favorite notes
- Backup/export
- Search and tag features
- Collaboration features

---

## 5) Relevant Files
- [lib/main.dart](lib/main.dart) — app bootstrap, initial route selection, and auth gate
- [lib/controllers/auth_controller.dart](lib/controllers/auth_controller.dart) — email/password, Google sign-in, reset, sign-out
- [lib/controllers/category_controller.dart](lib/controllers/category_controller.dart) — category CRUD logic
- [lib/controllers/note_controller.dart](lib/controllers/note_controller.dart) — note CRUD logic
- [lib/views/auth/login_view.dart](lib/views/auth/login_view.dart) — login screen
- [lib/views/auth/login_form.dart](lib/views/auth/login_form.dart) — email login form and validation
- [lib/views/auth/register_view.dart](lib/views/auth/register_view.dart) — sign-up screen
- [lib/views/auth/register_form.dart](lib/views/auth/register_form.dart) — sign-up form and verification trigger
- [lib/views/auth/forgot_password_view.dart](lib/views/auth/forgot_password_view.dart) — reset password screen
- [lib/views/home/home_view.dart](lib/views/home/home_view.dart) — category dashboard and sign-out
- [lib/views/categories/add_category_view.dart](lib/views/categories/add_category_view.dart) — add category screen
- [lib/views/categories/update_category_view.dart](lib/views/categories/update_category_view.dart) — edit category screen
- [lib/views/notes/note_list_view.dart](lib/views/notes/note_list_view.dart) — notes list screen
- [lib/views/notes/add_note_view.dart](lib/views/notes/add_note_view.dart) — add note screen
- [lib/views/notes/edit_note_view.dart](lib/views/notes/edit_note_view.dart) — edit note screen
- [android/app/build.gradle](android/app/build.gradle) — Android release signing configuration
- [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml) — manifest permissions and app config
- [firebase.json](firebase.json) — Firebase deployment configuration
- [test/widget_test.dart](test/widget_test.dart) — app test replacement target
- [pubspec.yaml](pubspec.yaml) — dependency cleanup and release validation

---

## 6) Verification Checklist
Before the app is submitted to Google Play, complete all of the following:

1. Build a release AAB and confirm it is signed with a production keystore.
2. Deploy Firestore rules from the repo and test cross-account access denial.
3. Validate the auth flow:
   - register
   - verify email
   - login
   - Google sign-in
   - password reset
   - sign-out
   - app restart session restore
4. Validate CRUD flow:
   - create category
   - update category
   - delete category
   - create note
   - update note
   - delete note
   - confirm user isolation between accounts
5. Run analyzer and tests successfully.
6. Complete privacy policy and Data Safety requirements in Google Play Console.

---

## 7) Final Decision
- Included in MVP: secure core note-taking with simple authentication and personal data isolation.
- Excluded from MVP: advanced productivity features and collaboration shortcuts.
- Recommended sequencing: security, Android release readiness, and test hardening before any product expansion.

This keeps the app focused, launchable, and much safer for a first Google Play release.
