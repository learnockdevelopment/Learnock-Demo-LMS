import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webinar/common/data/app_data.dart';
import '../../../../../../common/utils/constants.dart';
import '../../../../../widgets/floating dev id.dart';

class WebViewPage extends StatefulWidget {
  static const String pageName = '/web-view';
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  bool isFullscreen = false;
  bool backPressedOnce = false;
  bool isShow = false;
  bool showOverlay = false; // For the dark overlay
  String? url;
  String token = '';
  bool showExitMessage = false;

  InAppWebViewSettings settings = InAppWebViewSettings(
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: false,
    iframeAllow: "camera; microphone",
    mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
    javaScriptEnabled: true,
  );

  CookieManager cookieManager = CookieManager.instance();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      url = (ModalRoute.of(context)!.settings.arguments as List)[0];
      token = await AppData.getAccessToken();

      if (token.isNotEmpty) {
        cookieManager.setCookie(
          url: WebUri(url!),
          name: 'XSRF-TOKEN',
          value: token,
          domain: Constants.dommain.replaceAll('https://', ''),
          isHttpOnly: true,
          isSecure: true,
          path: '/',
          expiresDate: DateTime.now()
              .add(const Duration(hours: 2))
              .millisecondsSinceEpoch,
        );

        cookieManager.setCookie(
            url: WebUri(url!),
            name: 'webinar_session',
            value: token,
            domain: Constants.dommain.replaceAll('https://', ''),
            isHttpOnly: true,
            isSecure: true,
            path: '/',
            expiresDate: DateTime.now()
                .add(const Duration(hours: 2))
                .millisecondsSinceEpoch,
            sameSite: HTTPCookieSameSitePolicy.LAX);
      }

      isShow = true;
      setState(() {});

      await [
        Permission.camera,
        Permission.microphone,
      ].request();
    });

    // Set the status bar and navigation bar color here
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black, // Set the status bar color to black
      systemNavigationBarColor: Colors.black, // Set the navigation bar color to black
      systemNavigationBarIconBrightness: Brightness.light, // Icons white for navigation bar
    ));
  }

  Future<void> load() async {
    var headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
      'Accept': 'application/json',
    };

    if (!(url?.startsWith('http') ?? false)) {
      await webViewController?.loadData(data: url ?? '');
    } else {
      await webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri(url ?? ''), headers: headers),
      );
    }
  }

  void toggleFullscreen() {
    setState(() {
      isFullscreen = !isFullscreen;
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);

    });
  }

  Future<bool> handleBackPress() async {
    if (isFullscreen) {
      setState(() {
        isFullscreen = false;
      });
      return false;
    } else if (!backPressedOnce) {
      setState(() {
        showExitMessage = true;
      });
      backPressedOnce = true;

      // Show SnackBar with exit message
      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(content: Text('Click again to exit video')),
      );

      // Wait for 2 seconds before allowing another back press
      await Future.delayed(Duration(seconds: 2));
      setState(() {
        backPressedOnce = false;
        showExitMessage = false;
      });

      return false;
    } else {
      Navigator.of(context).pop();
      return true;
    }
  }
  void toggleOverlay(bool show) {
    setState(() {
      showOverlay = show;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: handleBackPress,
      child: GestureDetector(
        onDoubleTap: toggleFullscreen,
        child: Scaffold(
          backgroundColor: Colors.black, // Set background color here
          body: isShow
              ? Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 5),
                ),
                child: InAppWebView(

                  key: webViewKey,
                  initialSettings: settings,
                  onWebViewCreated: (controller) async {
                    webViewController = controller;
                    load();
                  },
                  onPermissionRequest: (controller, request) async {
                    return PermissionResponse(
                      resources: request.resources,
                      action: PermissionResponseAction.GRANT,
                    );
                  },
                  onLoadStop: (controller, url) async {
                    await controller.evaluateJavascript(source: """
    // Set the background color of the body to black
    document.body.style.backgroundColor = 'black';
    
    // Set iframe background color to black
    var iframes = document.getElementsByTagName('iframe');
    for (var i = 0; i < iframes.length; i++) {
      iframes[i].style.backgroundColor = 'black';
      iframes[i].style.position = 'absolute';  // Make iframe fill screen
      iframes[i].style.top = '0';
      iframes[i].style.left = '0';
      iframes[i].style.width = '100%';
      iframes[i].style.height = '100%';
    }
    
    // Ensure videos fill the screen
    var videos = document.getElementsByTagName('video');
    for (var i = 0; i < videos.length; i++) {
      videos[i].controls = false;
      videos[i].setAttribute('disabled', 'true');
      videos[i].autoplay = false;
      videos[i].muted = true;
      videos[i].style.position = 'absolute';
      videos[i].style.top = '0';
      videos[i].style.left = '0';
      videos[i].style.width = '100%'; // Make video fill the screen
      videos[i].style.height = '100%'; // Make video fill the screen
    }
    
    // Disable fullscreen in iframes
    var iframes = document.getElementsByTagName('iframe');
    for (var i = 0; i < iframes.length; i++) {
      // Block fullscreen on the iframe itself
      iframes[i].sandbox = 'allow-scripts'; // Ensures that the iframe cannot request fullscreen
      iframes[i].setAttribute('allowfullscreen', 'false');
      iframes[i].setAttribute('webkitallowfullscreen', 'false');
      iframes[i].setAttribute('mozallowfullscreen', 'false');
iframes[i].setAttribute('onEnterFullscreen', 'false');
      
      // Override fullscreen API for iframe
      iframes[i].contentWindow.document.documentElement.requestFullscreen = function() {
        console.log("Fullscreen is disabled for this iframe.");
      };
    }

    // Prevent zooming (disable zoom scale changes)
    var metaViewport = document.querySelector('meta[name="viewport"]');
    if (metaViewport) {
      metaViewport.setAttribute('content', 'width=device-width, initial-scale=1.0, user-scalable=no');
    } else {
      var newMeta = document.createElement('meta');
      newMeta.setAttribute('name', 'viewport');
      newMeta.setAttribute('content', 'width=device-width, initial-scale=1.0, user-scalable=no');
      document.getElementsByTagName('head')[0].appendChild(newMeta);
    }

    // Listen for fullscreen change and exit fullscreen if entered
    document.addEventListener('fullscreenchange', function() {
      if (document.fullscreenElement) {
        document.exitFullscreen();
      }
    });

    // Block "onRequestFocus" behavior
    window.addEventListener('focus', function(e) {
      e.preventDefault();
      console.log('Request focus blocked');
    });

    // Block "onZoomScaleChanged" behavior
    window.addEventListener('resize', function() {
      console.log('Zoom scale change blocked');
    });

    // Detect orientation change and exit fullscreen if in landscape mode
    window.addEventListener('orientationchange', function() {
      if (window.orientation === 90 || window.orientation === -90) {
        // Exit fullscreen on landscape orientation
        if (document.fullscreenElement) {
          document.exitFullscreen();
        }
      }
    });
  
  
  """);

                    // Add JavaScript handlers for preventing fullscreen
                    controller.addJavaScriptHandler(
                      handlerName: 'onEnterFullscreen',
                      callback: (args) {
                        return null;  // Simply return null to prevent fullscreen request
                      },
                    );

                    // You can also handle zoom or scale events directly in Flutter if needed:
                    controller.addJavaScriptHandler(
                      handlerName: 'onZoomScaleChanged',
                      callback: (args) {
                        return null; // Return null to prevent zoom scale changes
                      },
                    );
                  },
                  onEnterFullscreen: (controller) {
                    setState(() {
                      isFullscreen = true;
                    });
                    toggleOverlay(true);
                  },
                  onExitFullscreen: (controller) {
                    setState(() {
                      isFullscreen = false;
                    });
                    toggleOverlay(false);
                  },
                ),
              ),
              if (showOverlay)
                Positioned.fill(
                  child: Container(
                    color: Colors.black,
                  ),
                ),
              Positioned(
                top: 40,
                left: 10,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: handleBackPress,
                ),
              ),
           FloatingDeviceInfoWidget(),
            ],
          )
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    webViewController?.dispose();
    super.dispose();
  }
}