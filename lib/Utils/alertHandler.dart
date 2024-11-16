import 'package:flutter/material.dart';

void showErrorAlertDialog(BuildContext context, String message,
    {String type = "Error!", VoidCallback? callbackFunction}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(type),
        content: Text(
          message,
          style: TextStyle(color: Colors.red),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Closes the dialog
              if (callbackFunction != null) {
                callbackFunction();
              }
            },
            child: Text("OK"),
          ),
        ],
      );
    },
  );
}

void showInfoAlertDialog(BuildContext context, String message,
    {String type = "Info!", VoidCallback? callbackFunction}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(type),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Closes the dialog
              if (callbackFunction != null) {
                callbackFunction();
              }
            },
            child: Text("OK"),
          ),
        ],
      );
    },
  );
}
