import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class TermsPage extends StatefulWidget {
  static const pageName = '/terms';  // Route name for TermsPage

  final String url;

  const TermsPage({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  _TermsPageState createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  late InAppWebViewController _webViewController;
  bool _isLoading = true; // To control loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(widget.url),  // Use WebUri here
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStart: (controller, url) {
                setState(() {
                  _isLoading = true; // Show loading indicator when the page starts loading
                });
              },
              onLoadStop: (controller, url) {
                setState(() {
                  _isLoading = false; // Hide loading indicator when the page is fully loaded
                });
              },
              onLoadError: (controller, url, code, message) {
                setState(() {
                  _isLoading = false; // Hide loading indicator even on error
                });
                // Handle load error here (e.g., show an error message)
              },
            ),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(), // Loading spinner
              ),
          ],
        ),
      ),
    );
  }
}
