# 🧪 ScolioCare - Quick-Start Testing Guide

## 📋 Overview

This guide will help you test all the backend-integrated features that have been implemented. Currently running in **MOCK MODE** (no real backend required).

---

## ✅ What's Been Integrated

### Module 1: Authentication ✅
- Email/Password login
- Registration
- Token storage
- Error handling

### Module 2: Profile Management ✅
- Profile data structure
- Update vitals
- Assessment submission

### Module 3: AI Imaging ✅
- Image upload flow
- Analysis trigger
- Status polling

### Module 4: Exercise Module ✅
- Exercise loading
- Plan retrieval
- Log submission
- Streak tracking

---

## 🚀 Testing Checklist

### 1️⃣ Authentication Flow (5 minutes)

#### **Test Login**
1. Launch the app
2. You'll see the Welcome/Onboarding screen
3. Navigate to Login screen
4. **Try these credentials:**
   - Email: `test@scoliocare.com`
   - Password: `password123`
5. Click **Sign In**
6. ✅ **Expected:** 
   - Shows loading spinner (1 second)
   - Successfully logs in
   - Navigates to Profile Setup

#### **Test Registration**
1. From Login screen, click **Sign Up**
2. Fill in:
   - Full Name: `John Doe`
   - Email: `john.doe@test.com`
   - Password: `test1234`
   - Confirm password: `test1234`
3. ✅ Check the disclaimer checkbox
4. Click **Create Account**
5. ✅ **Expected:**
   - Loading spinner appears
   - Account created
   - Navigates to Profile Setup

#### **Test Error Handling**
1. Try logging in without filling fields
2. ✅ **Expected:** Validation errors appear
3. Try password < 6 characters
4. ✅ **Expected:** "Password must be at least 6 characters"

---

### 2️⃣ Profile Setup Flow (3 minutes)

#### **Test Profile Navigation**
1. After login/register, you're on Profile Setup
2. Navigate through the 6 steps
3. **Fill in sample data:**
   - DOB: Select any date
   - Gender: Select one
   - Height: `170 cm`
   - Weight: `65 kg`
   - Activity Level: Slide to any position
   - Weakness Areas: Select 2-3 areas

4. ✅ **Expected:**
   - Progress bar updates (1/6, 2/6, etc.)
   - Can go back/forward
   - Data persists when navigating

#### **Test Profile Completion**
1. Complete all 6 steps
2. Click **Finish/Continue**
3. ✅ **Expected:** 
   - Navigates to Dashboard
   - (Mock mode: profile saved locally)

---

### 3️⃣ Dashboard Display (2 minutes)

#### **Test Dashboard Layout**
1. Check all sections are visible:
   - ✅ Header with user name
   - ✅ Notification bell icon
   - ✅ Latest scan card
   - ✅ **16px spacing between sections** (new!)
   - ✅ Quick Actions (4 buttons)
   - ✅ Scoliometer card
   - ✅ Today's Exercises
   - ✅ Daily Reminder card

2. Test Quick Action buttons:
   - Click **Scan** → navigates to Image Capture
   - Click **Scoliometer** → navigates to Scoliometer
   - Click **Exercises** → navigates to Exercise Program
   - Click **Progress** → navigates to Progress Tracking

---

### 4️⃣ Image Capture Flow (3 minutes)

#### **Test Image Selection**
1. From Dashboard, click **Scan** or navigate to Image Capture
2. Try different body views:
   - Front
   - Back (primary for scoliosis)
   - Left
   - Right
   - Forward Bend

3. **Test Camera:**
   - Click **Take Photo**
   - ✅ **Expected:** Camera opens (requires camera permission)
   - Take a photo
   - Review the preview

4. **Test Gallery:**
   - Click **Choose from Gallery**
   - Select an image
   - ✅ **Expected:** Image preview shows

#### **Test Upload (Mock Mode)**
1. After selecting an image, click **Upload**
2. ✅ **Expected (Mock Mode):**
   - Shows "Upload not available in mock mode" or similar
   - (Real backend: would upload and trigger analysis)

---

### 5️⃣ Exercise Module (4 minutes)

#### **Test Exercise List**
1. Navigate to **Exercise Program** screen
2. ✅ **Check:** 
   - Exercise categories displayed (Strength, Stretch, Posture, Breathe)
   - Each exercise shows:
     - Name
     - Duration
     - Reps
     - Difficulty badge

#### **Test Exercise Completion**
1. Click on an exercise card
2. Mark as complete (if toggle available)
3. ✅ **Expected:**
   - Visual feedback (checkmark/color change)
   - Progress percentage updates

#### **Test Exercise Details**
1. Click on an exercise name
2. ✅ **Expected:**
   - Shows full instructions
   - Video link button
   - Sets/Reps details
   - Precautions

---

### 6️⃣ Settings & Profile (2 minutes)

#### **Test Settings Access**
1. Navigate to **Settings** (from bottom nav or menu)
2. ✅ **Check all sections:**
   - Profile information
   - Notification settings
   - Privacy & Data settings
   - Language preference
   - Account management

#### **Test Profile Viewing**
1. Navigate to **Profile** screen
2. ✅ **Check displays:**
   - User name
   - Email
   - Profile picture placeholder
   - Medical information
   - Weakness areas

---

### 7️⃣ Navigation Testing (2 minutes)

#### **Test Bottom Navigation**
1. Test all bottom nav tabs:
   - 🏠 **Home** (Dashboard)
   - 📊 **Progress** (Tracking)
   - 💪 **Exercises**
   - 💬 **Chat** (Chatbot)
   - ⚙️ **Settings**

2. ✅ **Expected:**
   - Smooth transitions
   - Active tab highlighted
   - Content updates

#### **Test Back Navigation**
1. Navigate deep into the app
2. Use back button
3. ✅ **Expected:** 
   - Proper back stack
   - Returns to previous screen

---

## 🐛 Known Limitations (Mock Mode)

### ❌ What DOESN'T Work Yet:
1. **Real API Calls** - Mock mode only
2. **Image Upload to Server** - Local only
3. **AI Analysis** - No real processing
4. **Data Persistence** - Resets on app restart (except tokens)
5. **Push Notifications** - Not configured
6. **PDF Reports** - Not generated
7. **Real Exercise Plans** - Using default data

### ✅ What DOES Work:
1. **All UI flows and navigation**
2. **Form validation**
3. **Loading states**
4. **Error handling**
5. **Token storage** (local)
6. **State management**
7. **Animations and transitions**

---

## 🎯 Testing Scenarios

### Scenario 1: New User Onboarding
**Time: 5-7 minutes**
1. Open app fresh (clear data if needed)
2. Go through onboarding slides
3. Accept disclaimer
4. Register new account
5. Complete profile setup
6. Submit initial assessment
7. Land on dashboard

✅ **Success Criteria:**
- No crashes
- All screens load
- Data flows through
- Reaches dashboard

---

### Scenario 2: Returning User Login
**Time: 2-3 minutes**
1. Close and reopen app
2. Login with existing credentials
3. Check if token persists
4. Verify data is available

✅ **Success Criteria:**
- Login works immediately
- Previous data visible
- Smooth login flow

---

### Scenario 3: Exercise Workflow
**Time: 5 minutes**
1. Login
2. Navigate to exercises
3. Browse exercise library
4. View exercise details
5. Mark some as complete
6. Check progress updates

✅ **Success Criteria:**
- Exercises load
- Details show correctly
- Completion tracking works
- Progress updates

---

### Scenario 4: Image Capture Flow
**Time: 3 minutes**
1. Login
2. Go to Image Capture
3. Test camera permission
4. Take/select image
5. Review image preview
6. Attempt upload (mock)

✅ **Success Criteria:**
- Camera opens
- Image preview works
- UI responds appropriately
- Mock mode message shows

---

## 📊 Performance Testing

### Load Times (Target)
- **App Launch:** < 2 seconds
- **Login:** < 1 second (mock mode)
- **Screen Transitions:** < 300ms
- **Image Preview:** < 500ms

### Memory Usage
- **Idle:** < 100MB
- **With Images:** < 200MB
- **No memory leaks** on navigation

---

## 🔧 Troubleshooting

### Issue: Login shows "No internet connection"
**Solution:** 
- Ensure `useMockMode = true` in `lib/core/api/api_config.dart`
- Hot restart the app
- Clear app data and try again

### Issue: App crashes on login
**Solution:**
- Check console for error messages
- Verify all dependencies are installed: `flutter pub get`
- Clean and rebuild: `flutter clean && flutter run`

### Issue: Images not showing
**Solution:**
- Check camera/gallery permissions
- Ensure assets are in `pubspec.yaml`
- Verify image paths are correct

### Issue: Navigation not working
**Solution:**
- Check route names in `main.dart`
- Verify all screens are registered
- Check for typos in route names

### Issue: State not updating
**Solution:**
- Verify providers are properly initialized
- Check `notifyListeners()` is called
- Ensure `Consumer` or `Provider.of()` is used in UI

---

## 📱 Testing on Different Devices

### Android Emulator
```bash
flutter run -d emulator-5554
```

### iOS Simulator (Mac only)
```bash
flutter run -d iPhone
```

### Physical Device
```bash
flutter run -d <device-id>
# Get device ID: flutter devices
```

---

## 🎨 UI/UX Testing Checklist

### Visual Testing
- [ ] Colors match design (primary, secondary)
- [ ] Fonts are consistent
- [ ] Icons display correctly
- [ ] Images load properly
- [ ] Spacing is uniform (16px between sections ✅)
- [ ] Cards have proper elevation/shadows

### Interaction Testing
- [ ] Buttons respond on tap
- [ ] Forms validate properly
- [ ] Scrolling is smooth
- [ ] Gestures work (swipe, pinch)
- [ ] Loading indicators show
- [ ] Error messages are clear

### Responsiveness Testing
- [ ] Works on different screen sizes
- [ ] Portrait orientation works
- [ ] Landscape orientation works (if supported)
- [ ] Text scales appropriately
- [ ] Images scale without distortion

---

## 📝 Test Results Template

Use this to track your testing:

```markdown
## Test Session: [Date]

### Environment
- Device: [Android/iOS]
- Screen Size: [e.g., 6.1", 1080x2400]
- Flutter Version: [flutter --version]
- Mock Mode: [ON/OFF]

### Results

#### Authentication ✅/❌
- Login: ✅
- Register: ✅
- Error Handling: ✅
- Notes: _____________

#### Profile Setup ✅/❌
- Navigation: ✅
- Data Entry: ✅
- Validation: ✅
- Notes: _____________

#### Dashboard ✅/❌
- Layout: ✅
- Quick Actions: ✅
- Spacing: ✅
- Notes: _____________

#### Exercises ✅/❌
- Load: ✅
- Details: ✅
- Completion: ✅
- Notes: _____________

#### Navigation ✅/❌
- Bottom Nav: ✅
- Screen Transitions: ✅
- Back Navigation: ✅
- Notes: _____________

### Issues Found
1. [Issue description]
2. [Issue description]

### Performance
- Load Time: ___ms
- Memory Usage: ___MB
- FPS: ___ (target: 60)

### Overall Rating: ⭐⭐⭐⭐⭐
```

---

## 🚀 Next Steps After Testing

### When Testing Completes Successfully:
1. ✅ Document any bugs found
2. ✅ Note UI/UX improvements needed
3. ✅ Prepare for real backend integration
4. ✅ Plan remaining module implementation

### To Enable Real Backend:
1. Set `useMockMode = false` in `api_config.dart`
2. Update `baseUrl` to your backend URL
3. Ensure backend is running
4. Re-test all flows
5. Handle any backend-specific issues

---

## 💡 Pro Tips

1. **Test on Real Device:** Emulators don't show real performance
2. **Test with Poor Network:** Simulate slow connections
3. **Test Edge Cases:** Empty states, max length inputs, special characters
4. **Test Accessibility:** Screen readers, font scaling
5. **Test Dark Mode:** If implemented
6. **Clear App Data:** Test fresh install experience
7. **Test Offline Mode:** What happens with no connection?

---

## 📞 Need Help?

If you encounter issues:
1. Check the error console
2. Review `BACKEND_INTEGRATION_STATUS.md`
3. Check `MOCK_MODE_GUIDE.md`
4. Check Flutter doctor: `flutter doctor -v`
5. Clean and rebuild: `flutter clean && flutter run`

---

## ✨ Happy Testing!

Remember: The goal is to find issues early. Report everything you see, no matter how small!

**Test Coverage Target:** 80%+ of integrated features
**Bug Severity Levels:** Critical, High, Medium, Low
**Testing Time Estimate:** 30-45 minutes for full suite

---

Last Updated: 2025
Version: 1.0 (Mock Mode)
