import 'dart:async';
import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'location_service.dart';
import 'email_service.dart';
import 'storage_service.dart';

/// Background service that handles periodic location tracking and email sending
/// 
/// IMPORTANT PLATFORM LIMITATIONS:
/// - Android: Interval usually 15min-2h+, rarely exactly 60min
/// - iOS: background_fetch gives 30min-several hours, very unreliable
/// - Both platforms require battery optimization to be disabled
class BackgroundService {
  static const String taskName = 'locationTrackingTask';
  static const Duration minInterval = Duration(minutes: 50); // Minimum 50 minutes between sends

  /// Initialize the background service
  /// This should be called once when the app starts
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    // Register periodic task
    // Note: On Android, minimum interval is 15 minutes
    // On iOS, background_fetch is very unreliable
    await Workmanager().registerPeriodicTask(
      taskName,
      taskName,
      frequency: const Duration(minutes: 60),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      initialDelay: const Duration(minutes: 1), // Start after 1 minute
    );
  }

  /// Cancel the background task (if needed)
  static Future<void> cancel() async {
    await Workmanager().cancelByUniqueName(taskName);
  }
}

/// Callback dispatcher for workmanager
/// This MUST be a top-level function (not inside a class)
/// This runs in a separate isolate
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await _performLocationTracking();
      return Future.value(true);
    } catch (e) {
      // Silently fail - no notifications, no errors shown
      return Future.value(false);
    }
  });
}

/// Perform the actual location tracking and email sending
Future<void> _performLocationTracking() async {
  // Check if enough time has passed since last send
  final lastSendTime = await StorageService.getLastSendTime();
  if (lastSendTime != null) {
    final timeSinceLastSend = DateTime.now().difference(lastSendTime);
    if (timeSinceLastSend < BackgroundService.minInterval) {
      // Too soon, skip this execution
      return;
    }
  }

  // Check internet connectivity
  final connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    // No internet connection, skip
    return;
  }

  // Check location permissions
  final locationPermission = await Permission.location.status;
  if (!locationPermission.isGranted) {
    // Permission not granted, skip
    return;
  }

  // Check if location services are enabled
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services disabled, skip
    return;
  }

  // Get current location
  Position? position;
  try {
    position = await LocationService.getCurrentLocation();
  } catch (e) {
    // Failed to get location, skip silently
    return;
  }

  if (position == null) {
    return;
  }

  // Send email with location data
  final success = await EmailService.sendLocationUpdate(
    latitude: position.latitude,
    longitude: position.longitude,
    accuracy: position.accuracy,
    timestamp: position.timestamp,
  );

  // Save timestamp only if email was sent successfully
  if (success) {
    await StorageService.saveLastSendTime(DateTime.now());
  }
}

