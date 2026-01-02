import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for getting current location
/// 
/// Handles permissions and location retrieval with best available accuracy
class LocationService {
  /// Request location permissions
  /// Returns true if permission is granted
  static Future<bool> requestPermissions() async {
    // Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Request location permission
    final permission = await Permission.location.request();
    
    // For Android 10+, also request background location
    if (await Permission.location.isGranted) {
      final backgroundPermission = await Permission.locationAlways.request();
      return backgroundPermission.isGranted;
    }

    return permission.isGranted;
  }

  /// Get current location with best available accuracy
  /// Returns null if location cannot be obtained
  static Future<Position?> getCurrentLocation() async {
    try {
      // Check permissions
      final locationPermission = await Permission.location.status;
      if (!locationPermission.isGranted) {
        return null;
      }

      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Get current position with best accuracy
      // Timeout after 30 seconds
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 30),
      );

      return position;
    } catch (e) {
      // Silently fail - return null
      return null;
    }
  }

  /// Check if location permissions are granted
  static Future<bool> hasPermissions() async {
    final permission = await Permission.location.status;
    return permission.isGranted;
  }
}

