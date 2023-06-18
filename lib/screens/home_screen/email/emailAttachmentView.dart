import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailAttachmentView extends StatelessWidget {
  final String pdfUrl;
  final String filetype;

  EmailAttachmentView(
      {super.key, required this.pdfUrl, required this.filetype});

  String notifiationName = '';
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  var filePath;
  Future<void> checkPermissionAndDownloadFile(
      String url, String filename, context) async {
    filename = Uri.parse(pdfUrl).pathSegments.last;
    notifiationName = filename;
    print(notifiationName);
    var status = await Permission.storage.status;
    print(status.isGranted);

    if (!status.isGranted) {
      status = await Permission.storage.request();
      print(status.isGranted);
      // if (status.isGranted) {
      //   await downloadFile(url, filename, context);
      //   showNotification(notifiationName, 'Download complete');
      //   // Handle permission denied case
      //   return;
      // }
    }
    if (status.isGranted) {
      print("granted");
      await downloadFile(url, filename, context);
      showNotification(notifiationName, 'Download complete');
      // Handle permission denied case
      return;
    }
  }

  Future<File> downloadFile(String url, String filename, context) async {
    final response = await http.get(Uri.parse(pdfUrl));
    final bytes = response.bodyBytes;
    final file = File('/storage/emulated/0/Download/$filename');
    await file.writeAsBytes(bytes);
    filePath = file.path;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloaded file to ${file.path}'),
      ),
    );
    return file;
  }

  Future<void> showNotification(String title, String body) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 66,
        channelKey: 'downloaded_pdf',
        title: title,
        body: body,
        payload: {'filePath': filePath},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff999999),
          leading: IconButton(
              onPressed: (() {
                Navigator.pop(context);
              }),
              icon: const Icon(Icons.arrow_back)),
          title: const Text(' Viewer'),
          elevation: 0,
          actions: [
            IconButton(
              onPressed: (() async {
                checkPermissionAndDownloadFile(pdfUrl, pdfUrl, context);
                // .then((value) {
                // //  showNotification(notifiationName, 'Download complete');
                // });
              }),
              icon: const Icon(Icons.download),
            ),
          ],
        ),
        body: filetype == '.pdf'
            ? SfPdfViewer.network(
                pdfUrl,
                key: _pdfViewerKey,
              )
            : Center(
                child: Image.network(
                  pdfUrl,
                  fit: BoxFit.cover,
                  height: 400,
                  width: 400,
                ),
              ));
  }
}
