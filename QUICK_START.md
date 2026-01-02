# Quick Start Guide

## 1. Install Dependencies

```bash
flutter pub get
```

## 2. Configure Email Service

Edit `lib/services/email_service.dart`:

```dart
// Change target email
static const String _targetEmail = 'your-email@example.com';

// Option 1: Use EmailJS (recommended for testing)
static const String _emailJSServiceId = 'YOUR_SERVICE_ID';
static const String _emailJSTemplateId = 'YOUR_TEMPLATE_ID';
static const String _emailJSPublicKey = 'YOUR_PUBLIC_KEY';
static const bool _useEmailJS = true; // Set to true

// OR Option 2: Use Custom API
static const String _customApiUrl = 'https://your-api.com/send-email';
static const String _customApiKey = 'YOUR_API_KEY';
static const bool _useCustomApi = true; // Set to true
```

## 3. Add Gallery Images

1. Add 12-20 images to `assets/images/` directory
2. Use names like: `nature_1.jpg`, `city_1.jpg`, etc.
3. Or update `_imagePaths` in `lib/main.dart` to match your filenames

## 4. Run the App

```bash
flutter run
```

## 5. Grant Permissions (CRITICAL)

### Android:
1. **Location Permission:** Select "Allow all the time" (not "While using app")
2. **Battery Optimization:** Settings → Apps → [App] → Battery → Unrestricted

### iOS:
1. **Location Permission:** Settings → Privacy → Location → [App] → Always
2. **Background App Refresh:** Settings → General → Background App Refresh → ON

## 6. Test Background Execution

1. Close the app completely
2. Wait 15-60 minutes (Android) or 30+ minutes (iOS)
3. Check your email inbox for location updates

## Important Notes

- ⚠️ **Android:** Real interval is usually 15min-2h+, rarely exactly 60min
- ⚠️ **iOS:** Background location is extremely unreliable, may not work at all
- ⚠️ **Both:** Battery optimization must be disabled for reliable background execution
- ⚠️ **Email:** You MUST configure an email service before the app can send updates

## Troubleshooting

**No location updates?**
- Check battery optimization is disabled
- Verify "Always" location permission (not "While using")
- Ensure internet connection is available
- Check email service is properly configured

**iOS not working?**
- This is expected - iOS background location is heavily restricted
- App may stop working after force-close or device restart
- Consider this a known limitation

## Next Steps

- Read `README.md` for detailed documentation
- Read `PLATFORM_SETUP.md` for platform-specific instructions
- Read `PROJECT_STRUCTURE.md` for code organization

