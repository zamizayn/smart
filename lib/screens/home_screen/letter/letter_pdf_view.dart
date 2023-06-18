import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class LetterPdfView extends StatefulWidget {
  final pdf;
  const LetterPdfView({super.key, required this.pdf});

  @override
  State<LetterPdfView> createState() => _LetterPdfViewState();
}

class _LetterPdfViewState extends State<LetterPdfView> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100.0),
          child: AppBar(
            backgroundColor: const Color(0xff999999),
            title: const Text('Letter'),
          ),
        ),
        body: SfPdfViewer.network(
          widget.pdf,
          key: _pdfViewerKey,
        ));
  }
}
