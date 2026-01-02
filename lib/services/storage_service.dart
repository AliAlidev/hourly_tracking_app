import 'package:shared_preferences/shared_preferences.dart';

/// Service for storing last send timestamp
/// Uses SharedPreferences for simple key-value storage
class StorageService {
  static const String _lastSendTimeKey = 'last_send_time';

  /// Get the timestamp of the last successful email send
  /// Returns null if no previous send recorded
  static Future<DateTime?> getLastSendTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampString = prefs.getString(_lastSendTimeKey);
      
      if (timestampString == null) {
        return null;
      }
      
      return DateTime.parse(timestampString);
    } catch (e) {
      return null;
    }
  }

  /// Save the timestamp of the last successful email send
  static Future<void> saveLastSendTime(DateTime timestamp) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSendTimeKey, timestamp.toIso8601String());
    } catch (e) {
      // Silently fail
    }
  }

  /// Clear the stored timestamp (for testing/reset)
  static Future<void> clearLastSendTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastSendTimeKey);
    } catch (e) {
      // Silently fail
    }
  }
}

