import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/providers/ProfileProvider/profile_provider.dart';
import 'package:smart_station/utils/constants/urls.dart';
import 'package:http/http.dart' as http;

import '../../utils/constants/app_constants.dart';

class NewUserProfile extends StatefulWidget {
  const NewUserProfile({Key? key}) : super(key: key);

  @override
  State<NewUserProfile> createState() => _NewUserProfileState();
}

class _NewUserProfileState extends State<NewUserProfile> {
  File? _image;
  String profilePath = '';
  String hafPath = '';
  final TextEditingController _nameController = TextEditingController();

  void getProfilePic() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50.0), topRight: Radius.circular(50.0)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 8,
      builder: (context) {
        return SizedBox(
          height: 190,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          getImageSouce(ImageSource.camera);
                        },
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[100],
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                  child: Image(
                                image: AssetImage(cameraIcon),
                                width: 50,
                                height: 50,
                              )),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text('Camera')
                          ],
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          getImageSouce(ImageSource.gallery);
                        },
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[100],
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  color: Colors.green,
                                  size: 50,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text('Gallery')
                          ],
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<CroppedFile?> cropImage(File? imageFile) async {
    print('FILE===========> ${imageFile!.path}');
    var croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarColor: textGreen,
          toolbarTitle: 'Smart Station',
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings()
      ],
    );

    return croppedFile;
  }

  Future getImageSouce(ImageSource source) async {
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return null;

    final imageTemporary = File(image.path);
    File compressedImage = await FlutterNativeImage.compressImage(
      image.path,
      percentage: 80,
      quality: 100,
      // targetWidth: 600,
      // targetHeight: 300,
    );
    cropImage(compressedImage).then((value) {
      // print("VALUE ==========> ${value.}");
      File imgPath = File(value!.path);
      fileUpload(imgPath, authProvider.accessToken, authProvider.userId);
    });
    //
    setState(() {
      _image = imageTemporary;
    });
  }

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(splashBg),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * .08),
            Text(
              'Create your profile',
              style: TextStyle(
                fontSize: 24,
                color: textGreen,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Container(
              padding: const EdgeInsets.all(50),
              child: InkWell(
                onTap: () {
                  getProfilePic();
                },
                child: CircleAvatar(
                  // backgroundColor: Colors.red,
                  radius: 100,
                  child: CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    radius: 100,
                    backgroundImage: profilePath != ''
                        ? Image.network(profilePath,
                                width: 100, height: 100, fit: BoxFit.cover)
                            .image
                        : Image(
                            image: AssetImage(
                              defaultImage,
                            ),
                            fit: BoxFit.contain,
                            color: Colors.transparent,
                          ).image,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter your name',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textGreen,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.grey.shade400),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                          fillColor: Colors.grey[100],
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          hintText: 'Please enter your name'),
                    ),
                  ),
                  const SizedBox(height: 80),
                  Center(
                    child: SizedBox(
                      width: 90,
                      child: Image(
                        image: AssetImage(transpLogo),
                      ),
                    ),
                  ),
                  const SizedBox(height: 120),
                  Center(
                    child: SizedBox(
                      height: 40,
                      width: 140,
                      child: Consumer<ProfileProvider>(
                        builder: (context, pValue, child) {
                          return InkWell(
                            onTap: () {
                              if (_nameController.text.isNotEmpty) {
                                pValue.isLoading
                                    ? showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Container(
                                            child: SpinKitSpinningLines(
                                              color: rightGreen,
                                              size: 100,
                                            ),
                                          );
                                        },
                                      )
                                    : null;
                                pValue.addUser(
                                    image: hafPath.isNotEmpty
                                        ? hafPath
                                        : '',
                                    context: context,
                                    accessToken: authProvider.accessToken,
                                    name: _nameController.text,
                                    userId: authProvider.userId);
                              } else {
                                print('enter name');
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      textGreen,
                                      rightGreen,
                                    ]),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Center(
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void fileUpload(
    File? ftr,
    final String accessToken,
    final String userId,
  ) async {
    String url = '${AppUrls.appBaseUrl}/fileupload';

    try {
      var stream = http.ByteStream(ftr!.openRead());
      var length = await ftr.length();
      var request = http.MultipartRequest('POST', Uri.parse(url));
      var multipartFile =
          http.MultipartFile('file', stream, length, filename: ftr.path);

      request.fields['user_id'] = userId;
      request.fields['accessToken'] = accessToken;
      request.files.add(multipartFile);
      var resp = await request.send();
      resp.stream.transform(utf8.decoder).listen((event) {
        print('%%%%%%%%%%%%%%%%[TESTING]%%%%%%%%%%%%%%%%');
        print(event);
        print('%%%%%%%%%%%%%%%%[TESTING]%%%%%%%%%%%%%%%%');
        var finalData = jsonDecode(event);
        if (finalData['statuscode'] == 200) {
          setState(() {
            profilePath = finalData['filepath'];
            hafPath = finalData['path'];
            print(finalData['filepath']);
          });
        }
      });
    } on SocketException catch (_) {
      print('No Internet connection available!');
    } catch (e) {
      print(':::::: $e');
    }
  }
}
