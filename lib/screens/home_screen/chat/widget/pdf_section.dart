import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ChatPdfView extends StatefulWidget {
  final pdf;
  final fileName;
  const ChatPdfView({super.key, required this.pdf, required this.fileName});

  @override
  State<ChatPdfView> createState() => _ChatPdfViewState();
}

class _ChatPdfViewState extends State<ChatPdfView> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100.0),
          child: AppBar(
            backgroundColor: const Color(0xff999999),
            title: Text(widget.fileName),
          ),
        ),
        body: SfPdfViewer.network(
          widget.pdf,
          key: _pdfViewerKey,
        ));
  }
}
