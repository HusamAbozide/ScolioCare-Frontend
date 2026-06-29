# Mock Mode - Development Without Backend

## ✅ Current Status: MOCK MODE ENABLED

The app is now configured to work **without a real backend** for testing the UI and flows.

---

## 🎯 What's Changed

### Before (causing error):
- App tried to connect to `https://api.scoliocare.app/v1`
- Got "No internet connection" error
- Could not test the app

### Now (working):
- **Mock Mode is ENABLED** in `lib/core/api/api_config.dart`
- Login/Register use fake data
- You can test all UI flows
- Data is simulated locally

---

## 🧪 Testing the App

### 1. Sign In
- **Email:** Type anything (e.g., `test@example.com`)
- **Password:** Type anything (e.g., `password123`)
- Click **Sign In**
- ✅ You'll be logged in with mock data after 1 second

### 2. Register
- Fill in any details
- Accept the disclaimer
- Click **Create Account**
- ✅ Account created with mock data

### 3. What Works in Mock Mode:
- ✅ Login screen
- ✅ Register screen
- ✅ Token storage (locally)
- ✅ Navigation to profile setup
- ✅ UI flows and animations

### 4. What Doesn't Work (Expected):
- ❌ Real API calls
- ❌ Actual data persistence beyond local storage
- ❌ Server-side validation
- ❌ AI analysis (needs real backend)
- ❌ Image upload (needs real backend)

---

## 🔧 Switching Between Mock and Real Backend

### To ENABLE Mock Mode (current):
In `lib/core/api/api_config.dart`:
```dart
static const bool useMockMode = true;  // ← Mock data
```

### To DISABLE Mock Mode (when backend is ready):
```dart
static const bool useMockMode = false;  // ← Real API calls
```

Then update the base URL:
```dart
static const String baseUrl = 'http://YOUR_BACKEND_IP:PORT/v1';
// Example: 'http://192.168.1.100:8080/v1'
// Or: 'https://your-domain.com/api/v1'
```

---

## 📱 Testing Now

1. **Stop the app** if it's running
2. **Hot restart** (press `r` in terminal or click restart button)
3. Try logging in with any email/password
4. You should see a 1-second loading, then success!

---

## 🔍 Mock Data Details

When you login with mock mode:
- **User ID:** `mock-user-123`
- **Email:** Whatever you typed
- **Access Token:** Generated timestamp-based mock token
- **Refresh Token:** Generated timestamp-based mock token

These tokens are stored locally and will work for testing navigation and UI flows.

---

## ⚠️ Important Notes

1. **Mock mode is for UI testing only** - No real data is saved to a backend
2. **Data resets on app restart** - Local tokens persist, but no server-side data
3. **Perfect for frontend development** - Test all screens and flows
4. **Switch to real backend** when it's deployed

---

## 🚀 Next Steps

### When Your Backend is Ready:

1. Set `useMockMode = false` in `api_config.dart`
2. Update `baseUrl` to your actual backend URL
3. Ensure your backend endpoints match the spec
4. Test real API integration

### For Now (Testing UI):

- ✅ Test login/register flows
- ✅ Test navigation
- ✅ Test profile setup screens
- ✅ Test all UI elements and animations
- ✅ Test error handling (can manually trigger in code)

---

## 💡 Pro Tips

**Testing Different Scenarios:**

You can modify the mock response in `auth_service.dart` to test:
- Different user types
- Various email formats
- Different timestamps

**Simulating Errors:**

Add a throw statement in mock mode to test error handling:
```dart
if (ApiConfig.useMockMode) {
  await Future.delayed(const Duration(seconds: 1));
  throw Exception('Test error message');  // Test error flow
}
```

---

## 📞 Need Help?

If you still see errors after hot restart:
1. **Full restart** the app (stop and run again)
2. **Clear app data** on the device/emulator
3. Check console for any other error messages

Enjoy testing! 🎉
