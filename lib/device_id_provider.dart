import 'package:flutter/material.dart';

class DeviceIdProvider extends ChangeNotifier {
  String _deviceId = '';

  String get deviceId => _deviceId;

  void setDeviceId(String deviceId) {
    _deviceId = deviceId;
    notifyListeners(); // Notify listeners to rebuild widgets depending on the device ID
  }
}

