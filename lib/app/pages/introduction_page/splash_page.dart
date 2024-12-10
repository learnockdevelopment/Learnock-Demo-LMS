import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:webinar/app/pages/introduction_page/intro_page.dart';
import 'package:webinar/app/pages/main_page/main_page.dart';
import 'package:webinar/app/pages/offline_page/internet_connection_page.dart';
import 'package:webinar/app/services/guest_service/guest_service.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/config/assets.dart';
import 'package:webinar/config/styles.dart';

class SplashPage extends StatefulWidget {
  static const String pageName = '/splash';
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));

    FlutterNativeSplash.remove();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      animationController.forward();

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
      backgroundColor: const Color(0xFFffffff),
      body: Container(
        width: getSize().width,
        height: getSize().height,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Spacer(),
            const SizedBox(height: 150),

            Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: AnimatedBuilder(
                    animation: animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1 + (1 * animationController.value), // Smaller pulse range for smoother effect
                        child: Opacity(
                          opacity: animationController.value, // Gradual appearance (step-by-step)
                          child: Image.asset(
                            AppAssets.logoPng,
                            width: 100,
                            height: 100,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 70),
            Text(
              appText.webinar,
              style: style24Bold().copyWith(color: Color(0xFF2e71b8)),
            ),
            const SizedBox(height: 10),

            const Spacer(),
            const Spacer(),
            const SizedBox(
              width: 35,
              child: LoadingIndicator(
                indicatorType: Indicator.ballBeat,
                colors: [Colors.white],
                strokeWidth: 100,
                backgroundColor: Colors.transparent,
                pathBackgroundColor: Colors.transparent,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
