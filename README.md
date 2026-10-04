# TodoFlow - Cross-Platform Todo Application (Flutter + Supabase)

A production-grade, secure, cross-platform Todo application engineered with **Flutter**, **Dart**, and **Supabase** for **Android**, **iOS**, and **Windows**.

---

## Architecture & Design Highlights

- **Clean Layered Architecture**: Clear separation of UI (Widgets) → State Management (Cubit/Bloc) → Abstract Repositories → Supabase Data Layer.
- **Supabase Authentication**: Session persistence, refresh tokens, PKCE authorization flow, and password recovery.
- **Row Level Security (RLS)**: Enforced directly within PostgreSQL policies (`auth.uid() = user_id`), mathematically guaranteeing tenant isolation.
- **Responsive Material 3 UI**: Adapts smoothly from mobile touch screens (Bottom Navigation) to desktop (Windows `NavigationRail` and keyboard shortcuts).
- **Task Management**: Full CRUD, Status (`TODO`, `IN_PROGRESS`, `COMPLETED`), Priority tiers (`LOW`, `MEDIUM`, `HIGH`), due dates with overdue indicators, dynamic categories, search, filtering, and sorting.

---

## Complete Setup & Installation Guide

### 1. Installing Flutter
1. Download the Flutter SDK (version 3.19+ recommended) from [flutter.dev](https://docs.flutter.dev/get-started/install).
2. Extract the SDK to a folder (e.g., `C:\src\flutter` on Windows).
3. Add the `flutter\bin` directory to your system `PATH` environment variable.
4. Verify your installation by opening a new terminal and running:
   ```bash
   flutter doctor
   ```

---

### 2. Creating & Configuring Your Supabase Project
1. Log in to [supabase.com](https://supabase.com) and click **"New Project"**.
2. Choose your organization, name the project (e.g., `TodoFlow`), select a database password, and select your preferred region.
3. Wait for the project initialization to complete.

---

### 3. Getting Your Supabase Project URL & Anon Key
1. In your Supabase Dashboard, click on **Project Settings** (gear icon in the sidebar).
2. Go to **API**.
3. Under **Project URL**, copy the `URL` (e.g. `https://xyzcompany.supabase.co`).
4. Under **Project API keys**, copy the `anon` / `public` key.
   > ⚠️ **CRITICAL SECURITY NOTE**: NEVER copy or use the `service_role` secret key in Flutter. Only use the `anon` key.

---

### 4. Configuring Application Environment (`.env`)
1. In the root directory of this repository, copy the example environment file:
   ```bash
   cp .env.example .env
   ```
2. Open `.env` and paste your project credentials:
   ```ini
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

---

### 5. Applying Database Migrations
1. In your Supabase Dashboard, navigate to the **SQL Editor** tab.
2. Click **"New Query"**.
3. Copy the entire contents of [`supabase/migrations/20261004000001_initial_schema_and_rls.sql`](file:///c:/Users/sujal/OneDrive/Desktop/App/supabase/migrations/20261004000001_initial_schema_and_rls.sql).
4. Paste it into the SQL Editor and click **Run**.
5. This will automatically create:
   - Enums: `todo_status`, `todo_priority`
   - Tables: `public.profiles`, `public.todos`
   - Triggers: Automated profile creation on signup (`handle_new_user`), timestamping on updates, completion status synchronizer
   - Performance indexes on `user_id`, `status`, `priority`, and `due_date`
   - Strict Row Level Security policies preventing cross-user access

---

### 6. Running the Flutter Application
1. Install dependencies:
   ```bash
   flutter pub get
   ```
2. Launch the app on your connected device or emulator:
   ```bash
   flutter run
   ```

---

### 7. Running the Automated Test Suite
Run the test suite including validation tests, state cubit tests, and multi-tenant RLS isolation tests:
```bash
# Run static analysis
flutter analyze

# Run all automated tests
flutter test
```

---

### 8. Android Setup & Deep Linking
- **Internet Permission**: Enabled in `android/app/src/main/AndroidManifest.xml`.
- **Password Recovery Deep Link**: An intent filter is pre-configured for `todoapp://reset-password`.
- In your Supabase Dashboard under **Authentication -> URL Configuration -> Redirect URLs**, add:
  ```
  todoapp://reset-password
  ```

---

### 9. iOS Setup
- **URL Scheme**: Pre-configured in `ios/Runner/Info.plist` under `CFBundleURLTypes` with identifier `todoapp`.
- In Supabase Dashboard under **Authentication -> URL Configuration**, ensure `todoapp://reset-password` is in the allowed redirect list.

---

### 10. Windows Desktop Setup
- Ensure Visual Studio with the **"Desktop development with C++"** workload is installed.
- To run specifically on Windows Desktop:
  ```bash
  flutter run -d windows
  ```
- **Desktop Features**:
  - Automatically switches to `NavigationRail` layout.
  - Shortcut <kbd>Ctrl</kbd> + <kbd>N</kbd>: Create a new task.
  - Shortcut <kbd>Ctrl</kbd> + <kbd>F</kbd>: Focus search field.

---

## Security Model Overview

- **Row Level Security (RLS)**: Cryptographically verified user isolation via PostgreSQL policies.
- **Zero Client Credential Storage**: Passwords are never stored on device.
- **No Leaked Secrets**: The `service_role` key is strictly prohibited and absent from the entire repository.
- **Data Protection**: Deleting an account initiates a database cascade purge of all user tasks and profiles.
