import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:intl/intl.dart';

import '../services/guest_service/guest_service.dart';

class FloatingDeviceInfoWidget extends StatefulWidget {
  final Color backgroundColor;

  const FloatingDeviceInfoWidget({Key? key, this.backgroundColor = Colors.white}) : super(key: key);

  @override
  _FloatingDeviceInfoWidgetState createState() => _FloatingDeviceInfoWidgetState();
}

class _FloatingDeviceInfoWidgetState extends State<FloatingDeviceInfoWidget> {
  late String deviceId;
  double posX = 100;
  double posY = 100;
  Random random = Random();
  Timer? timer;
  Size? screenSize;
  Color textColor = Colors.black;
  bool showWatermark = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
    _initializePosition();

    _fetchConfig();
    _checkAndUpdateTextColor(widget.backgroundColor);
  }

  @override
  void initState() {
    super.initState();
    getDeviceId();
    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      _randomlyReposition();
    });
  }

  Future<void> _fetchConfig() async {
    try {
      final response = await GuestService.systemsettings();
      ////print"Config response: $response");  // Debug: //print entire config response

      if (response != null && response['data'] != null) {
        final watermarkEnabled = response['data']['security_settings']['mobile_watermark_enabled'];
        ////print"Watermark enabled status: $watermarkEnabled (${watermarkEnabled.runtimeType})");  // //print the type for debugging

        if (mounted) {
          setState(() {
            showWatermark = watermarkEnabled == 1 || watermarkEnabled == '1';
            ////print"showWatermark set to: $showWatermark");  // Confirm if showWatermark is set correctly
          });
        }
      }
    } catch (e) {
      ////print"Failed to load config: $e");
    }
  }

  Future<void> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    String id;

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      id = androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      id = iosInfo.identifierForVendor ?? 'Unknown Device ID';
    } else {
      id = 'Unknown Device ID';
    }

    if (mounted) {
      setState(() {
        deviceId = id;
      });
    }
  }

  void _initializePosition() {
    if (screenSize != null) {
      setState(() {
        posX = random.nextDouble() * (screenSize!.width - 150);
        posY = random.nextDouble() * (screenSize!.height - 70);
        posX = posX.clamp(0.0, screenSize!.width - 150);
        posY = posY.clamp(0.0, screenSize!.height - 70);
      });
    }
  }

  void _randomlyReposition() {
    if (screenSize != null && mounted) {
      setState(() {
        posX = random.nextDouble() * (screenSize!.width - 150);
        posY = random.nextDouble() * (screenSize!.height - 70);
        posX = posX.clamp(0.0, screenSize!.width - 150);
        posY = posY.clamp(0.0, screenSize!.height - 70);
      });
    }
  }

  void _checkAndUpdateTextColor(Color backgroundColor) {
    int brightness = (backgroundColor.red + backgroundColor.green + backgroundColor.blue) ~/ 3;
    setState(() {
      textColor = brightness < 128 ? Colors.white : Colors.black;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      width: screenSize?.width ?? double.infinity,  // Ensure a valid width
      height: screenSize?.height ?? double.infinity,  // Ensure a valid height
      child: Stack(
        children: [
          if (showWatermark)
            Positioned(
              left: posX,
              top: posY,
              child: Container(
                width: 150,
                height: 70,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildText(deviceId, textColor),
                      SizedBox(height: 0),
                      _buildText(DateFormat('yyyy/MM/dd').format(DateTime.now()), textColor),
                      SizedBox(height: 0),
                      _buildText(DateFormat('HH:mm:ss a').format(DateTime.now()), textColor),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildText(String text, Color textColor) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
