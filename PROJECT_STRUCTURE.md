# Project Structure

## Overview

This Flutter application tracks user location in the background and sends updates via email approximately every hour. The UI shows only a gallery of images with no tracking-related elements.

## File Structure

```
hourly_location_tracker/
├── android/                          # Android platform files
│   ├── app/
│   │   ├── build.gradle             # Android app build configuration
│   │   └── src/main/
│   │       ├── AndroidManifest.xml  # Android permissions and configuration
│   │       └── kotlin/.../MainActivity.kt
│   ├── build.gradle                 # Android project build configuration
│   ├── settings.gradle              # Gradle settings
│   └── gradle.properties            # Gradle properties
│
├── ios/                              # iOS platform files
│   └── Runner/
│       ├── Info.plist               # iOS permissions and background modes
│       └── AppDelegate.swift        # iOS app delegate
│
├── lib/                              # Dart source code
│   ├── main.dart                    # App entry point + Gallery UI
│   └── services/
│       ├── background_service.dart  # WorkManager integration & background logic
│       ├── location_service.dart    # Location permission & retrieval
│       ├── email_service.dart       # Email sending via HTTP API
│       └── storage_service.dart     # Last send timestamp storage
│
├── assets/
│   └── images/                      # Gallery images (add your images here)
│       └── README.md                # Image requirements
│
├── pubspec.yaml                     # Flutter dependencies
├── analysis_options.yaml            # Linter configuration
├── README.md                        # Main documentation
├── PLATFORM_SETUP.md                # Platform-specific setup instructions
└── PROJECT_STRUCTURE.md             # This file
```

## Key Files Explained

### `lib/main.dart`
- **Purpose:** App entry point and gallery UI
- **Features:**
  - Initializes background service on app start
  - Displays grid gallery of images (3 columns)
  - Full-screen zoomable image viewer using photo_view
  - No location/tracking UI elements

### `lib/services/background_service.dart`
- **Purpose:** Background location tracking orchestration
- **Features:**
  - Initializes WorkManager for periodic tasks
  - Top-level callback dispatcher for background execution
  - Checks time interval (50+ minutes)
  - Checks connectivity, permissions, location services
  - Coordinates location retrieval and email sending

### `lib/services/location_service.dart`
- **Purpose:** Location permission and retrieval
- **Features:**
  - Requests location permissions
  - Gets current location with best accuracy
  - Handles permission and service checks

### `lib/services/email_service.dart`
- **Purpose:** Send location updates via email
- **Features:**
  - Configurable email service (EmailJS or custom API)
  - Formats email with location, timestamp, device info, battery
  - Handles device information retrieval
  - **IMPORTANT:** Must configure email service credentials

### `lib/services/storage_service.dart`
- **Purpose:** Store last successful send timestamp
- **Features:**
  - Uses SharedPreferences for simple storage
  - Tracks when last email was sent successfully

### `android/app/src/main/AndroidManifest.xml`
- **Purpose:** Android permissions and configuration
- **Contains:**
  - Location permissions (foreground + background)
  - Network permissions
  - Background execution permissions
  - WorkManager configuration

### `ios/Runner/Info.plist`
- **Purpose:** iOS permissions and background modes
- **Contains:**
  - Location permission descriptions
  - Background modes (fetch, location)

## Dependencies

All dependencies are listed in `pubspec.yaml`:

- **geolocator:** Location tracking
- **permission_handler:** Permission management
- **workmanager:** Background task scheduling
- **connectivity_plus:** Network connectivity checking
- **http:** HTTP requests for email API
- **shared_preferences:** Local storage
- **photo_view:** Zoomable image gallery
- **device_info_plus:** Device information
- **battery_plus:** Battery level

## Configuration Required

1. **Email Service:** Configure in `lib/services/email_service.dart`
   - Set `_targetEmail` to your email address
   - Choose EmailJS or custom API
   - Add credentials

2. **Images:** Add 12-20 images to `assets/images/`
   - Update `_imagePaths` in `lib/main.dart` if using different names

3. **Android Package Name:** Update in `android/app/build.gradle`
   - Change `applicationId` if needed

4. **iOS Bundle Identifier:** Update in Xcode project settings

## Background Execution Flow

1. App launches → `main.dart` calls `BackgroundService.initialize()`
2. WorkManager registers periodic task (60 min frequency)
3. When task executes:
   - Check if 50+ minutes passed since last send
   - Check internet connectivity
   - Check location permissions
   - Check location services enabled
   - Get current location
   - Send email via configured service
   - Save timestamp if successful
4. All operations are silent (no UI updates, no notifications)

## Platform Limitations

See `README.md` and `PLATFORM_SETUP.md` for detailed platform limitations and setup requirements.

