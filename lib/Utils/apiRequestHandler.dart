import 'dart:convert';
import 'dart:io';
import 'package:epe_app/Utils/alertHandler.dart';
import 'package:epe_app/Utils/appConfig.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Function to simulate an alert (errorLoggers to console)
void alertFunction(String message) {
  CustomLogger.logInfo('ALERT: $message');
}

void logoutHandler(BuildContext context) {
  Navigator.of(context).pushNamedAndRemoveUntil(
    '/login', // Navigates to the base route
    (Route<dynamic> route) =>
        false, // Removes all previous routes from the stack
  );
  AppConfig.removeLocalStorageItem('authToken');
}

// Handle errors function// Map<int, Function(dynamic)> mapFunction
void handleErrors(BuildContext context, dynamic err,
    {bool log = true, bool alert = true}) {
  String logMessage = '';
  String alertMessage = '';

  // Check if the error has no response (network/server issue)
  if (err is Exception) {
    logMessage = "Network error or server is not responding: ${err.toString()}";
    alertMessage =
        "Network error or server is not responding. Please try again later.";
  } else if (err is String) {
    if (alert) {
      String error = 'System Error: $err';
      CustomLogger.logError(error);
      showErrorAlertDialog(context, error, type: "System Error!");
    }
  } else {
    // Assume `err` has a response property
    dynamic response = err['body'];
    dynamic statusCode = err['statusCode'];

    // Check if response exists
    if (response != null) {
      // Check if the response contains specific error details
      if (response['errors'] != null) {
        alertMessage = "Please fix the following errors:\n";
        response['errors'].forEach((key, value) {
          alertMessage += '$value\n';
        });
      } else if (response['message'] != null) {
        alertMessage = response['message']; // Message from server
      } else if (response['error'] != null) {
        alertMessage = response['error']; // Error message from server
      } else {
        alertMessage = "An unexpected error occurred. Please try again.";
      }

      logMessage =
          "Status: ${err["statusCode"]}  Error response: ${jsonEncode(response)}";

      // Log the error if log argument is true and logMessage exists
      if (log) {
        CustomLogger.logError(logMessage);
      }

      // Call the alertFunction if it exists and alertMessage has content
      if (alert) {
        showErrorAlertDialog(context, alertMessage, callbackFunction: () {
          if (statusCode == 503) {
            logoutHandler(context);
          }
        });
      } else {
        if (statusCode == 503) {
          logoutHandler(context);
        }
      }
    }
  }
}

// Type alias for error callback function
typedef ErrorCallback = void Function(dynamic error);

// Function to retrieve token from local storage
String? getTokenHeaders() {
  return AppConfig.getLocalStorageItem('authToken');
}

// GET request without token
Future<Map<String, dynamic>> getRequest(String url) async {
  url = AppConfig.baseUrl + url;

  dynamic response = await http.get(Uri.parse(url));

  dynamic bodyResponse = jsonDecode(response.body);

  return {"body": bodyResponse, "statusCode": response.statusCode};
}

// POST request without token
Future<Map<String, dynamic>> postRequest(
    String url, Map<String, dynamic>? body) async {
  url = AppConfig.baseUrl + url;

  dynamic response = await http.post(
    Uri.parse(url),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(body ?? {}),
  );

  dynamic bodyResponse = jsonDecode(response.body);

  return {"body": bodyResponse, "statusCode": response.statusCode};
}

// GET request with token in headers
Future<Map<String, dynamic>> getRequestWithToken(String url) async {
  url = AppConfig.baseUrl + url;

  String? token = getTokenHeaders();

  dynamic response = await http.get(
    Uri.parse(url),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "$token", // Assuming Bearer token is needed
    },
  );

  dynamic bodyResponse = jsonDecode(response.body);

  return {"body": bodyResponse, "statusCode": response.statusCode};
}

// POST request with token in headers
Future<Map<String, dynamic>> postRequestWithToken(
    String url, Map<String, dynamic>? body) async {
  url = AppConfig.baseUrl + url;

  String? token = getTokenHeaders();

  dynamic response = await http.post(
    Uri.parse(url),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "$token", // Assuming Bearer token is needed
    },
    body: jsonEncode(body ?? {}),
  );

  dynamic bodyResponse = jsonDecode(response.body);

  return {"body": bodyResponse, "statusCode": response.statusCode};
}

Future<Map<String, dynamic>> uploadImageHandler(
    String url, File imageFile) async {
  // Construct the request URL
  String apiUrl = AppConfig.baseUrl + url;

  // Create a multipart request
  final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

  // Add the image file to the request
  request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

  // Add headers including the token
  String? token = getTokenHeaders();
  request.headers.addAll({
    "Authorization": "$token",
  });

  // Send the request
  final response = await request.send();

  // Read the response body
  final responseBody = await http.Response.fromStream(response);

  // Parse the response body
  dynamic bodyResponse = jsonDecode(responseBody.body);

  return {"body": bodyResponse, "statusCode": response.statusCode};
}
