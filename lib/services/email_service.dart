import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'dart:convert';

/// Service for sending location updates via email
/// 
/// IMPORTANT: Configure your email service credentials below
/// Options: EmailJS, SendGrid, Mailgun, or custom SMTP API
class EmailService {
  // ============================================
  // CONFIGURE YOUR EMAIL SERVICE HERE
  // ============================================
  
  /// Target email address where location updates will be sent
  static const String _targetEmail = 'tracking@example.com';
  
  /// EmailJS Configuration (Option 1 - Recommended for testing)
  /// Sign up at https://www.emailjs.com/
  static const String _emailJSServiceId = 'YOUR_SERVICE_ID';
  static const String _emailJSTemplateId = 'YOUR_TEMPLATE_ID';
  static const String _emailJSPublicKey = 'YOUR_PUBLIC_KEY';
  static const bool _useEmailJS = false; // Set to true to use EmailJS
  
  /// Custom API Configuration (Option 2)
  /// Set up your own email API endpoint
  static const String _customApiUrl = 'https://your-api.com/send-email';
  static const String _customApiKey = 'YOUR_API_KEY';
  static const bool _useCustomApi = false; // Set to true to use custom API
  
  // ============================================

  /// Send location update via email
  /// Returns true if email was sent successfully
  static Future<bool> sendLocationUpdate({
    required double latitude,
    required double longitude,
    required double accuracy,
    required DateTime timestamp,
  }) async {
    try {
      // Get device information
      final deviceInfo = await _getDeviceInfo();
      final batteryLevel = await _getBatteryLevel();

      // Format email content
      final subject = _formatSubject(deviceInfo, timestamp);
      final body = _formatBody(
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
        timestamp: timestamp,
        deviceInfo: deviceInfo,
        batteryLevel: batteryLevel,
      );

      // Send email using configured service
      if (_useEmailJS) {
        return await _sendViaEmailJS(subject, body);
      } else if (_useCustomApi) {
        return await _sendViaCustomApi(subject, body);
      } else {
        // No email service configured
        // In production, you MUST configure one of the above options
        return false;
      }
    } catch (e) {
      // Silently fail - no error notifications
      return false;
    }
  }

  /// Format email subject
  static String _formatSubject(String deviceInfo, DateTime timestamp) {
    final dateStr = '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
    return 'Location Update - $deviceInfo - $dateStr';
  }

  /// Format email body
  static String _formatBody({
    required double latitude,
    required double longitude,
    required double accuracy,
    required DateTime timestamp,
    required String deviceInfo,
    required String batteryLevel,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Location Update');
    buffer.writeln('===============');
    buffer.writeln('');
    buffer.writeln('Device: $deviceInfo');
    buffer.writeln('Timestamp: ${timestamp.toIso8601String()}');
    buffer.writeln('');
    buffer.writeln('Coordinates:');
    buffer.writeln('  Latitude: $latitude');
    buffer.writeln('  Longitude: $longitude');
    buffer.writeln('  Accuracy: ${accuracy.toStringAsFixed(2)} meters');
    buffer.writeln('');
    buffer.writeln('Battery: $batteryLevel');
    
    return buffer.toString();
  }

  /// Send email via EmailJS
  static Future<bool> _sendViaEmailJS(String subject, String body) async {
    try {
      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'service_id': _emailJSServiceId,
          'template_id': _emailJSTemplateId,
          'user_id': _emailJSPublicKey,
          'template_params': {
            'to_email': _targetEmail,
            'subject': subject,
            'message': body,
          },
        }),
      ).timeout(const Duration(seconds: 30));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Send email via custom API
  static Future<bool> _sendViaCustomApi(String subject, String body) async {
    try {
      final url = Uri.parse(_customApiUrl);
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_customApiKey',
        },
        body: jsonEncode({
          'to': _targetEmail,
          'subject': subject,
          'body': body,
        }),
      ).timeout(const Duration(seconds: 30));

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  /// Get device information
  static Future<String> _getDeviceInfo() async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final deviceInfo = await deviceInfoPlugin.deviceInfo;
      
      if (deviceInfo is AndroidDeviceInfo) {
        return '${deviceInfo.brand} ${deviceInfo.model} (${deviceInfo.id})';
      } else if (deviceInfo is IosDeviceInfo) {
        return '${deviceInfo.name} ${deviceInfo.model} (${deviceInfo.identifierForVendor ?? 'unknown'})';
      }
      
      return 'Unknown Device';
    } catch (e) {
      return 'Unknown Device';
    }
  }

  /// Get battery level
  static Future<String> _getBatteryLevel() async {
    try {
      final battery = Battery();
      final batteryLevel = await battery.batteryLevel;
      return '$batteryLevel%';
    } catch (e) {
      return 'N/A';
    }
  }
}

