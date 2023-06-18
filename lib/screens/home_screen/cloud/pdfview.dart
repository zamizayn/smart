import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:smart_station/providers/CloudProvider/cloud_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfView extends StatelessWidget {
  final String pdfUrl;
  final String parent_folder_id;
  final String file_id;
  final String typeId;
  final String type;
  BuildContext ctx;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  PdfView(
      {super.key, required this.pdfUrl,
      required this.parent_folder_id,
      required this.file_id,
      required this.typeId,
      required this.type,
      required this.ctx});

  Future<void> _deletePdf() async {
    // Delete the image file from local storage
    /* final Directory directory = await getApplicationDocumentsDirectory();
    final String path = directory.path + "/image.jpg";
    await File(path).delete();*/
    var cloud = Provider.of<CloudProvider>(ctx, listen: false);
    cloud.deleteCloudFile(parent_folder_id, file_id, typeId, type, ctx);
  }

  Future<void> _downloadPdf() async {
    // Download the image and save it to local storage
    final http.Response response = await http.get(Uri.parse(pdfUrl));
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = '${directory.path}/document.pdf';
    final File file = File(path);
    await file.writeAsBytes(response.bodyBytes);

    // Save the image to gallery
    final result = await ImageGallerySaver.saveImage(file.readAsBytesSync());
    print('Image saved to gallery: $result');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Stack(
          children: [
            Container(
              color: Colors.grey,
            ),
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(splashBg),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            AppBar(
              title: const Text(''),
              actions: [
                PopupMenuButton(
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 1,
                      child: Text('Delete'),
                    ),
                    const PopupMenuItem(
                      value: 2,
                      child: Text('Download'),
                    ),
                  ],
                  onSelected: (value) {
                    print('Selected option: $value');
                    switch (value) {
                      case 1:
                        {
                          print('Delete');
                          _deletePdf();
                        }
                        break;

                      case 2:
                        {
                          print('Download');
                          _downloadPdf();
                        }
                        break;

                      default:
                        {
                          //statements;
                        }
                        break;
                    }
                  },
                ),
              ],
              backgroundColor:
                  Colors.transparent, // make the app bar transparent
              elevation: 0, // remove the app bar shadow
            ),
          ],
        ),
      ),
      body:  SfPdfViewer.network(
          pdfUrl,
          key: _pdfViewerKey,
        )
    );
  }
}
