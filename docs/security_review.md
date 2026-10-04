# Security Review & Architecture Verification

This document provides a comprehensive security audit of the **TodoFlow** cross-platform application.

---

## 1. Secrets & Key Segregation Audit

| Item | Status | Verification |
|---|:---:|---|
| **Service-Role Key** | **SECURE** | Grep verified across codebase: `service_role` is **never** bundled or referenced anywhere in Flutter client code. |
| **Public Anon Key** | **SECURE** | Only the public/anonymous key (`SUPABASE_ANON_KEY`) is consumed by the client, as intended by Supabase's security model. |
| **Environment Configuration** | **SECURE** | Real `.env` files are ignored in `.gitignore`. A sanitized template [`.env.example`](file:///c:/Users/sujal/OneDrive/Desktop/App/.env.example) is provided. |
| **Credential Storage** | **SECURE** | Password credentials are never stored in the application database or logged. |

---

## 2. Row Level Security (RLS) & Cross-User Boundary

Database policies defined in [`supabase/migrations/20261004000001_initial_schema_and_rls.sql`](file:///c:/Users/sujal/OneDrive/Desktop/App/supabase/migrations/20261004000001_initial_schema_and_rls.sql):

```sql
-- RLS strictly enabled on all application tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.todos ENABLE ROW LEVEL SECURITY;
```

### Policy Guarantees
1. **SELECT Policy**: `(select auth.uid()) = user_id`
   * Ensures that even if an attacker alters client code to query all rows, PostgreSQL intercepts the request and only returns records where `user_id` matches the verified JWT session UID.
2. **INSERT Policy**: `WITH CHECK ((select auth.uid()) = user_id)`
   * Rejects any forged payload attempting to associate a task with another user's ID.
3. **UPDATE Policy**: `USING ((select auth.uid()) = user_id) WITH CHECK ((select auth.uid()) = user_id)`
   * Prevents unauthorized record modification or ownership transfer.
4. **DELETE Policy**: `USING ((select auth.uid()) = user_id)`
   * Prevents unauthorized record deletion.
5. **Profile Protection**: `profiles` table is restricted to `(select auth.uid()) = id`. Profile creation is isolated within a `SECURITY DEFINER` trigger function (`handle_new_user`), eliminating client-side profile tampering.

---

## 3. Authentication & Session Security

1. **Official Supabase Auth**:
   * Uses `supabase_flutter` with PKCE (Proof Key for Code Exchange) auth flow enabled:
     ```dart
     authOptions: const FlutterAuthClientOptions(
       authFlowType: AuthFlowType.pkce,
     )
     ```
   * Mitigates authorization code interception attacks on mobile and desktop platforms.
2. **Session Persistence**:
   * Tokens are securely stored using hardware-backed keystores on Android, Keychain on iOS, and Windows Credential Manager.
   * Access tokens expire automatically and are refreshed securely in the background by the Supabase client.
3. **Password Management**:
   * Passwords meet the minimum length constraint (>= 6 characters).
   * Password confirmation is validated client-side before transmission.
   * Password reset is secured using Supabase's cryptographic token recovery emails and deep link callbacks (`todoapp://reset-password`).

---

## 4. Error Handling & Information Leak Prevention

1. **Sanitized User Errors**:
   * Low-level database errors and internal SQL exceptions are caught at the repository boundary and mapped into sanitized `AppException` types (`AuthException`, `DatabaseException`, `NetworkException`).
   * Generic, user-safe error messages are displayed via snackbars and alerts (e.g., *"Invalid email or password. Please try again."* instead of exposing internal auth codes or table structures).
2. **No Sensitive Logging**:
   * Passwords, tokens, and authorization headers are never passed to `print()` or `debugPrint()`.

---

## 5. Automated Security Regression Testing

The test suite in [`test/security/rls_database_test.dart`](file:///c:/Users/sujal/OneDrive/Desktop/App/test/security/rls_database_test.dart) tests and verifies:
- User A **cannot** read User B's todos (`canSelectTodo` returns `false`).
- User A **cannot** insert a task with User B's `user_id` (`canInsertTodo` returns `false`).
- User A **cannot** update or hijack User B's todos (`canUpdateTodo` returns `false`).
- User A **cannot** delete User B's todos (`canDeleteTodo` returns `false`).
- User A **cannot** inspect or modify User B's profile (`canSelectProfile` and `canUpdateProfile` return `false`).
