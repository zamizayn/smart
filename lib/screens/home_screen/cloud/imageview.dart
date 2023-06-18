import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:smart_station/providers/CloudProvider/cloud_provider.dart';
import 'package:provider/provider.dart';

class ImageView extends StatelessWidget {
  final String imageUrl;
  final String parent_folder_id;
  final String file_id;
  final String typeId;
  final String type;
  BuildContext ctx;

  ImageView({super.key, required this.imageUrl,required this.parent_folder_id,required this.file_id,required this.typeId,required this.type,required this.ctx});

  Future<void> _deleteImage() async {
    // Delete the image file from local storage
    /* final Directory directory = await getApplicationDocumentsDirectory();
    final String path = directory.path + "/image.jpg";
    await File(path).delete();*/

    var cloud = Provider.of<CloudProvider>(ctx,listen: false);
    cloud.deleteCloudFile(parent_folder_id, file_id, typeId, type,ctx);
  }

  Future<String> _getLocalPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory!.path;
  }

  Future<void> _downloadFile() async {
    final path = await _getLocalPath();

  }


  Future<void> _downloadImage() async {
    // Download the image and save it to local storage
  /*  final http.Response response = await http.get(Uri.parse(imageUrl));
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = directory.path + "/image.jpg";
    final File file = File(path);
    await file.writeAsBytes(response.bodyBytes);

    // Save the image to gallery
    final result = await ImageGallerySaver.saveImage(file.readAsBytesSync());
    print("Image saved to gallery: $result");
*/
    try {
      // Download the image and save it to local storage
      final http.Response response = await http.get(Uri.parse(imageUrl));
      final Directory? downloadsDirectory = await getExternalStorageDirectory();
      final String directoryPath = downloadsDirectory?.path ?? ''  '/SmartStation Downloads';

      //final directoryPath = await _getLocalPath();

      final Directory directory = Directory(directoryPath);
      if (!directory.existsSync()) {
        directory.createSync();
      }
      final String path = '$directoryPath/image.jpg';
      final File file = File(path);
      await file.writeAsBytes(response.bodyBytes);

      // Save the image to gallery
      final result = await ImageGallerySaver.saveImage(file.readAsBytesSync());
      print('Image saved to gallery: $result');

      // Hide loading indicator
      Navigator.of(ctx).pop();
    } catch (e) {
      // Handle errors
      print('Error downloading image: $e');
      Navigator.of(ctx).pop();
      showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Unable to download image.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }








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
                    switch( value) {
                      case 1: {
                        print('Delete');
                        _deleteImage();
                      }
                      break;

                      case 2: {
                        print('Download');
                        _downloadImage();
                      }
                      break;

                      default: {
                        //statements;
                      }
                      break;
                    }
                  },
                ),
              ],
              backgroundColor: Colors.transparent, // make the app bar transparent
              elevation: 0, // remove the app bar shadow
            ),
          ],
          // AppBar(
          //   backgroundColor: Colors.grey,
          //   title: Text(""),
          //   actions: [
          //     PopupMenuButton(
          //       itemBuilder: (BuildContext context) => [
          //         PopupMenuItem(
          //           child: Text("Delete"),
          //           value: 1,
          //         ),
          //         PopupMenuItem(
          //           child: Text("Download"),
          //           value: 2,
          //         ),
          //
          //       ],
          //       onSelected: (value) {
          //         print("Selected option: $value");
          //         switch( value) {
          //           case 1: {
          //             print("Delete");
          //             _deleteImage();
          //           }
          //           break;
          //
          //           case 2: {
          //             print("Download");
          //             _downloadImage();
          //           }
          //           break;
          //
          //           default: {
          //             //statements;
          //           }
          //           break;
          //         }
          //       },
          //     ),
          //   ],
          // ),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
              // SizedBox(height: 20),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     ElevatedButton(
              //       onPressed: _deleteImage,
              //       child: Text("Delete"),
              //     ),
              //     SizedBox(width: 20),
              //     ElevatedButton(
              //       onPressed: _downloadImage,
              //       child: Text("Download"),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}