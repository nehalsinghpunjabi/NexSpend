# NexSpend — Day 1

## Run the Flutter app

1. Create a Supabase project and enable Google under **Authentication → Providers**.
2. Apply [`supabase/migrations/20260714000000_create_profiles.sql`](supabase/migrations/20260714000000_create_profiles.sql) in the Supabase SQL editor. It creates and backfills `public.profiles`, enables RLS, and provisions profiles for future Auth users.
3. Add `com.nexspend.nexspend://login-callback/` to Supabase Authentication URL Configuration.
4. Configure Android/iOS OAuth client credentials with Google, including the platform callback settings required by Supabase.
5. The root `.env` file supplies the Flutter runtime settings. Run:

```powershell
cd frontend
flutter run --dart-define-from-file=../.env
```

The included VS Code launch configuration loads this same local `.env` file automatically. Without those defines, the app still launches and displays onboarding, but Google sign-in is intentionally unavailable.

### Web OAuth callback

For Flutter web, NexSpend returns to the browser origin rather than the mobile
custom URI scheme. Add the exact deployed web origin to **Authentication → URL
Configuration → Redirect URLs**. For local development, allow the local URL
shown by `flutter run -d chrome` (for example `http://localhost:8080`). The
Google provider's redirect URI remains the Supabase callback URL, not the local
Flutter URL.

## Run the backend shell

```powershell
cd backend
python -m pip install -r requirements.txt
uvicorn app.main:app --reload
```
