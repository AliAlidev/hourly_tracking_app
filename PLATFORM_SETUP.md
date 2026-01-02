# Platform-Specific Setup Instructions

## Android Configuration

### Required AndroidManifest.xml Entries

The following permissions and configurations are already included in `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Location Permissions -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

<!-- Network -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- Background Execution -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

<!-- Battery Optimization Bypass -->
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
```

### User Actions Required (CRITICAL)

1. **Location Permissions:**
   - On first launch, user must grant location permission
   - User MUST select "Allow all the time" (not "While using app")
   - Go to: Settings → Apps → Hourly Location Tracker → Permissions → Location → Allow all the time

2. **Battery Optimization (MOST IMPORTANT):**
   - User MUST disable battery optimization for the app
   - Method 1: Settings → Apps → Hourly Location Tracker → Battery → Unrestricted
   - Method 2: Settings → Battery → Battery Optimization → Find app → Don't optimize
   - Without this, background tasks will be severely restricted

3. **Background App Refresh:**
   - Ensure background app refresh is enabled in system settings

### Expected Behavior

- **Minimum interval:** 15 minutes (Android system limitation)
- **Typical interval:** 15 minutes to 2+ hours
- **Rarely:** Exactly 60 minutes
- Background execution is heavily throttled by Android's battery optimization

## iOS Configuration

### Required Info.plist Entries

The following entries are already included in `ios/Runner/Info.plist`:

```xml
<!-- Location Permissions -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to track your position.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs location access to track your position in the background.</string>

<!-- Background Modes -->
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>location</string>
</array>
```

### User Actions Required (CRITICAL)

1. **Location Permissions:**
   - User MUST grant "Always" location permission (not "While Using App")
   - Go to: Settings → Privacy → Location Services → Hourly Location Tracker → Always

2. **Background App Refresh:**
   - Enable: Settings → General → Background App Refresh → ON
   - Enable specifically for this app: Settings → [App Name] → Background App Refresh → ON

### Expected Behavior

- **Extremely unreliable** - iOS heavily restricts background location
- **Typical interval:** 30 minutes to several hours (if it works at all)
- **Will likely stop working:**
  - After app is force-closed
  - After device is restarted
  - After a few days of inactivity
  - If device is in low power mode

### App Store Considerations

⚠️ **WARNING:** Apple frequently rejects apps that:
- Track location continuously without clear user benefit
- Don't show location-related UI
- Appear to be tracking users without explicit purpose

This app may face App Store review challenges due to its background location tracking nature.

## Testing Background Execution

### Android Testing

1. Grant all permissions
2. Disable battery optimization
3. Close the app completely
4. Wait 15-60 minutes
5. Check email inbox for location updates

### iOS Testing

1. Grant "Always" location permission
2. Enable Background App Refresh
3. Close the app (don't force-close)
4. Wait 30+ minutes
5. Check email inbox (may not receive updates)

## Troubleshooting

### Android: No location updates

- ✅ Check battery optimization is disabled
- ✅ Verify "Allow all the time" location permission
- ✅ Ensure device has internet connection
- ✅ Check WorkManager logs: `adb logcat | grep WorkManager`

### iOS: No location updates

- ✅ Check "Always" location permission (not "While Using")
- ✅ Verify Background App Refresh is enabled
- ✅ Don't force-close the app
- ✅ iOS background location is inherently unreliable - this is expected

## Production Considerations

1. **Android:** Consider implementing a foreground service with persistent notification for better reliability
2. **iOS:** Consider adding location-related UI to pass App Store review
3. **Both:** Implement retry logic and exponential backoff
4. **Both:** Add analytics to track actual update frequency
5. **Both:** Consider server-side scheduling as alternative to device-side background tasks

