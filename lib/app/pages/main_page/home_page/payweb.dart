import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class CustomWebViewPage extends StatefulWidget {
  final String url;
  final Map<String, String> headers;

  const CustomWebViewPage({
    Key? key,
    required this.url,
    required this.headers,
  }) : super(key: key);

  @override
  _CustomWebViewPageState createState() => _CustomWebViewPageState();
}

class _CustomWebViewPageState extends State<CustomWebViewPage> {
  late InAppWebViewController _webViewController;

  // Update the return type to return NavigationActionPolicy
  Future<NavigationActionPolicy> _shouldOverrideUrlLoading(
      InAppWebViewController controller, NavigationAction action) async {
    String url = action.request.url.toString();

    // Check if the URL matches your custom scheme
    if (url.startsWith("academyapp://payment-success")) {
      // Close the WebView and prevent the navigation
      Navigator.pop(context);
      return NavigationActionPolicy.CANCEL;  // Return CANCEL to stop loading
    }
    if (url == "https://learnockgroup.com/cart/voucher/validate") {
      // Reload the WebView when the specified URL appears
      await controller.reload();
      return NavigationActionPolicy.CANCEL; // Prevent navigation to this URL
    }
    // Allow the URL to be loaded if it doesn't match the custom scheme
    return NavigationActionPolicy.ALLOW;  // Allow normal navigation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(widget.url),  // Use WebUri here
            headers: widget.headers,
          ),
          onWebViewCreated: (controller) {
            _webViewController = controller;
          },
          shouldOverrideUrlLoading: _shouldOverrideUrlLoading,  // Intercept URL loading
          onTitleChanged: (controller, title) {
            // Check if the title contains "Cart is empty!" and close WebView
            if (title != null && title.contains("Cart is empty!")) {
              Navigator.pop(context); // Close WebView if title matches
            }
          },
          onLoadStop: (controller, url) {
            ////print"Loaded: $url");
          },
          onLoadError: (controller, url, code, message) {
            ////print"Error loading: $url, Code: $code, Message: $message");
          },
        ),
      ),
    );
  }

}
