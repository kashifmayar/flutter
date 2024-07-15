import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PDFViewerPage extends StatelessWidget {
  final String url;

  PDFViewerPage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View PDF'),
      ),
      body: PDFView(
        filePath: url,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: false,
        onRender: (_pages) {
          print("PDF rendered: $_pages pages");
        },
        onError: (error) {
          print('Error: $error');
        },
        onPageError: (page, error) {
          print('Page error on page: $page, error: $error');
        },
        onViewCreated: (PDFViewController pdfViewController) {
          print("PDFView created");
        },
        onPageChanged: (int? page, int? total) {
          print('Page changed: $page/$total');
        },
      ),
    );
  }
}
