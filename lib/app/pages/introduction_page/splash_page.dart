import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:webinar/common/utils/app_text.dart';
import '../../../common/common.dart';
import '../../../common/data/app_data.dart';
import '../../../config/assets.dart';
import '../../services/guest_service/guest_service.dart';
import '../main_page/main_page.dart';
import '../offline_page/internet_connection_page.dart';
import 'intro_page.dart';

class SplashPage extends StatefulWidget {
  static const String pageName = '/splash';
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController animationController;
  late AnimationController opacityController; // Ensure this is initialized

  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));

    opacityController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    opacityController
      ..repeat(reverse: true);

    FlutterNativeSplash.remove();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      animationController.forward();
      opacityController.forward(); // Start the opacity animation

      Timer(const Duration(seconds: 3), () async {
        final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());

        if (connectivityResult.contains(ConnectivityResult.none)) {
          nextRoute(InternetConnectionPage.pageName, isClearBackRoutes: true);
        } else {
          String token = await AppData.getAccessToken();

          if (mounted) {
            if (token.isEmpty) {
              bool isFirst = await AppData.getIsFirst();

              if (isFirst) {
                nextRoute(IntroPage.pageName, isClearBackRoutes: true);
              } else {
                nextRoute(MainPage.pageName, isClearBackRoutes: true);
              }
            } else {
              nextRoute(MainPage.pageName, isClearBackRoutes: true);
            }
          }
        }
      });
    });

    GuestService.config();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
            color: Color(0xFFffffff),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Lottie.asset(
              'assets/lottie.json',
              width: 300,
              height: 300,
              fit: BoxFit.contain,
            ),
            space(60),

            Positioned(
              bottom: 30,
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  Image.asset(
                    AppAssets.logoPng,  // Your logo image
                    width: 150,
                    height: 150,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    opacityController.dispose(); // Dispose opacityController as well
    super.dispose();
  }
}
