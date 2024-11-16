import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  // Static instance variables
  static late String remoteAddr;
  static late String? authToken;
  static late String baseUrl;
  static late String fileBaseUrl;
  static late String fcmToken;

  static late String appVersion;

  static String appUpdateDate = 'October 2024';

  static PackageInfo? packageInfo;
  static SharedPreferences? preferences;

  // Static async initialization function
  static Future<void> initializeAppInformation() async {
    packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo!.version;

    // Load environment-dependent address
    remoteAddr = dotenv.env['REMOTE_ADDRESS']!;

    // Initialize SharedPreferences
    preferences = await SharedPreferences.getInstance();
    if (kDebugMode) {
      baseUrl = '${dotenv.env['LOCAL_ADDRESS']}/';
    } else {
      baseUrl = '${dotenv.env['REMOTE_ADDRESS']}/';
    }

    fileBaseUrl = '${baseUrl}files/';

    String? token = getLocalStorageItem('authToken');

    authToken = token;
  }

  // Static methods for SharedPreferences
  static Future<void> setLocalStorageItem(String key, String val) async {
    await preferences!.setString(key, val);
  }

  static String? getLocalStorageItem(String key) {
    return preferences!.getString(key);
  }

  static void removeLocalStorageItem(String key) {
    preferences!.remove(key);
  }

  static String? getAuthToken() {
    if (authToken != null) {
      return authToken;
    } else {
      return null;
    }
  }
}

class CustomLogger {
  // Create a logger instance
  static final Logger _logger = Logger();

  // Method to log messages based on the environment
  static void logDebug(String message) {
    if (kDebugMode) {
      _logger.d(message); // Log debug messages only in debug mode
    }
  }

  static void logInfo(String message) {
    if (kDebugMode) {
      _logger.i(message); // Log info messages only in debug mode
    }
  }

  static void logWarning(String message) {
    if (kDebugMode) {
      _logger.w(message); // Log warning messages only in debug mode
    }
  }

  static void logError(String message) {
    if (kDebugMode) {
      _logger.e(message); // Log error messages only in debug mode
    }
  }
}
