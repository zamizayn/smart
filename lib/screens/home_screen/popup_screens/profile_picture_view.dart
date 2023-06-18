import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/topSection.dart';
import 'package:smart_station/utils/constants/app_constants.dart';

import '../../../providers/AuthProvider/auth_provider.dart';
import '../../../providers/ProfileProvider/profile_provider.dart';
class ProfilePictureView extends StatefulWidget {
  final profilePic;
  const ProfilePictureView({super.key,required this.profilePic});

  @override
  State<ProfilePictureView> createState() => _ProfilePictureViewState();
}

class _ProfilePictureViewState extends State<ProfilePictureView> {
  @override
    File? _image;
  String? halfPath;
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
          height: 230,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Profile photo',style: TextStyle(fontSize: 20),),
                            InkWell(onTap: (){
                              var auth = Provider.of<AuthProvider>(context, listen: false);
                              var profile = Provider.of<ProfileProvider>(context, listen: false);
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: SizedBox(
                                      width: MediaQuery.of(context).size.width/1.5,
                                      child: const Text('Remove profile photo?')),
                                    actions: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.of(context).pop(); // Dismiss dialog
                                        },
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        child: const Text('Cancel',style: TextStyle(color: Colors.green))),
                                      ),
                                      const SizedBox(width: 5,),
                                      InkWell(
                                          onTap: () {
                                            profile.removeProfilePicture(
                                                accessTok: auth.accessToken, 
                                                userId: auth.userId
                                                );
                                                setState(() {
                                                  
                                                });
                                            Navigator.of(context).pop(); // Dismiss dialog
                                            },
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            child: const Text('Remove',style: TextStyle(color: Colors.green),)),
                                          ),
                                          const SizedBox(width: 10,)
                                        ],
                                      )
                                    ],
                                  );
                                }
                              );
                            },
                             child:ImageIcon(AssetImage(trashIcon),color: Colors.grey[600],size: 30,))
                          ],
                        ),
                        const Spacer(),
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
                        child: Image(image: AssetImage(cameraIcon),width: 50,height: 50,)
                        ),
                        ),
                            const SizedBox(height: 10,),
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
                             const SizedBox(height: 10,),
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
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return null;

    File compressedImage = await FlutterNativeImage.compressImage(
      image.path,
      percentage: 80,
      quality: 100,
    );
    cropImage(compressedImage).then((value) {
      var auth = Provider.of<AuthProvider>(context, listen: false);
      var profile = Provider.of<ProfileProvider>(context, listen: false);
      File imgPath = File(value!.path);
      profile.fileUpload(imgPath, auth.accessToken,auth.userId, context);
      profile.updateProfilePicture(imgPath, auth.accessToken, auth.userId, context);
      setState(() {
        _image = imgPath;
        halfPath = profile.halfPath;
        print('halfpath===================$halfPath');
      });
    });
     

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
           const TopSection(),
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(splashBg), fit: BoxFit.fill)),
            ),
                        Positioned(
              top: 40,
              left: 0,
              right: 20,

              child: Row(
                children: [
                  const BackButton(color: Colors.white),
                  const Text(
                    'Profile photo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),

                  ),
                  const Spacer(),
                 IconButton(
                  onPressed: (){
                    getProfilePic();
                  },
                  icon: const Icon(Icons.edit,color: Colors.white,))
                ],
              ),
            ),

          Center(
            child: Container(
              padding: const EdgeInsets.all(10),
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
              child: widget.profilePic==''?
              Image.asset(defaultImage)
              : Image.network(widget.profilePic, fit: BoxFit.fitWidth),
            ),
          ),
        ],
      ),
    );
  }
}