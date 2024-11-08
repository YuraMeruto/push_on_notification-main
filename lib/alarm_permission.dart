import 'package:flutter/services.dart';

class AlarmPermission {
  static const platform = MethodChannel('com.example.exact_alarm/permissions');

  static Future<void> requestExactAlarmPermission() async {
    try {
      await platform.invokeMethod('requestExactAlarmPermission');
    } on PlatformException catch (e) {
      print("Error requesting exact alarm permission: ${e.message}");
    }
  }
}
