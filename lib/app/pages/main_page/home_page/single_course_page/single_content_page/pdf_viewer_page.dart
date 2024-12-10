import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:webinar/common/components.dart';

import '../../../../../widgets/floating dev id.dart';

class PdfViewerPage extends StatefulWidget {
  static const String pageName = '/pdf-viewer';
  const PdfViewerPage({super.key});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? title;
  String? path;

  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  PdfViewerController pdfViewerController = PdfViewerController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      try {
        final arguments = ModalRoute.of(context)!.settings.arguments as List?;
        if (arguments != null && arguments.length >= 2) {
          var rawPath = arguments[0] as String?;
          title = arguments[1] as String?;

          if (rawPath != null && rawPath.contains("drive.google.com")) {
            // Extract the file ID and form a direct link
            final fileId = RegExp(r'/d/([a-zA-Z0-9_-]+)')
                .firstMatch(rawPath)
                ?.group(1);
            path = "https://drive.google.com/uc?export=view&id=$fileId";
          } else {
            path = rawPath;
          }

          // //print debug information
          // ////print"Converted PDF Path: $path");
          // ////print"PDF Title: $title");
        } else {
          // ////print"Error: Arguments are missing or incomplete.");
        }
      } catch (e) {
        // ////print"Error in retrieving arguments: $e");
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: appbar(title: title ?? 'PDF File'),
        body: Stack(
          children: [
            // PDF viewer widget
            if (path != null && path!.isNotEmpty)
              SfPdfViewer.network(
                path!,
                key: _pdfViewerKey,
                controller: pdfViewerController,
              ),
             FloatingDeviceInfoWidget(),
          ],
        ),

      ),
    );
  }

  @override
  void dispose() {
    pdfViewerController.dispose();
    super.dispose();
  }
}
