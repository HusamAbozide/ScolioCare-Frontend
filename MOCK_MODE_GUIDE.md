# Mock Mode Guide - Testing UI Without Backend

## What Changed
✅ Enabled mock mode in `lib/core/api/api_config.dart`
```dart
static const bool useMockMode = true;  // Changed from false to true
```

## How to Use

### 1. Sign In (Mock Mode)
- Open the app
- Click "Sign In"
- Enter **any email and password** (doesn't matter)
- Example:
  - Email: `test@test.com`
  - Password: `password`
- The app will simulate a successful login after 1 second
- You'll be logged in as `mock-user-123`

### 2. Register (Mock Mode)
- Click "Sign Up" or "Register"
- Fill in any information
- The app will simulate a successful registration
- You'll be automatically logged in

### 3. What Works in Mock Mode
All UI screens work and show mock data:
- ✅ Login/Register
- ✅ Dashboard with sample data
- ✅ Exercise programs with mock exercises
- ✅ Progress tracking with sample charts
- ✅ Scan history with mock scans
- ✅ Scoliometer measurements
- ✅ Chatbot (shows UI, mock responses)
- ✅ Notifications with sample notifications
- ✅ Reports generation
- ✅ Settings and preferences
- ✅ Profile viewing/editing
- ✅ Rewards catalog
- ✅ Legal documents (terms, privacy, etc.)

### 4. What Doesn't Work in Mock Mode
- ❌ Real data persistence (closes when app restarts)
- ❌ Real image upload and AI analysis
- ❌ Real-time data sync
- ❌ Push notifications
- ❌ PDF download (will generate but not persist)

### 5. Testing the UI

**Login Screen:**
```
Email: anything@example.com
Password: anything
```
Click Sign In → Wait 1 second → Dashboard appears

**Try These Journeys:**
1. Login → Dashboard → Scan → View mock results
2. Login → Exercises → View exercise list
3. Login → Progress → View charts
4. Login → Settings → Rewards → View rewards
5. Login → Settings → Privacy Policy → View legal docs
6. Login → Notifications → View notifications
7. Login → Profile → View/Edit profile

## How to Switch Back to Real Backend

When your backend is running, change this line back:

**File:** `lib/core/api/api_config.dart`
```dart
static const bool useMockMode = false;  // Change to false
```

Then hot restart the app or rebuild.

## Current Configuration

**Mock Mode:** ✅ ENABLED  
**Base URL:** `http://localhost:8081` (not used in mock mode)  
**Timeout:** 30 seconds (not used in mock mode)

## Next Steps

1. ✅ **Hot restart the app** (press `R` in terminal or restart from IDE)
2. ✅ Try logging in with any credentials
3. ✅ Explore all UI screens
4. ✅ Test all features visually
5. ⚠️ When backend is ready, set `useMockMode = false`

## Notes

- Mock mode simulates 1-second delays for realistic feel
- Mock data is predefined in each service
- All screens are fully functional UI-wise
- State management works normally
- Navigation works normally
- Theme/settings persist locally

## Troubleshooting

**If you still see "No Internet Connection":**
1. Hot restart the app (not hot reload)
2. Verify `useMockMode = true` in `api_config.dart`
3. Check console for any errors
4. Try stopping and starting the app completely

**If login doesn't work:**
- Press any button, wait 1 second
- Should navigate to dashboard
- Check console for errors

**If screens are empty:**
- Normal! Mock mode provides sample data
- Some screens might have less data than real backend
- This is expected for UI testing

---

**Status:** ✅ Mock mode is now ENABLED. The app will work without backend!
