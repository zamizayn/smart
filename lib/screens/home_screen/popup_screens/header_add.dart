import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AccountProvider/account_provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/bottomSection.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/topSection.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:dotted_border/dotted_border.dart';

class HeaderAddScreen extends StatefulWidget {
  const HeaderAddScreen({Key? key}) : super(key: key);

  @override
  State<HeaderAddScreen> createState() => _HeaderAddScreenState();
}

class _HeaderAddScreenState extends State<HeaderAddScreen> {
  File? _image;
  var toastStatus=true;
  final _focusNode = FocusNode();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      print('sujinaaa');
          ScaffoldMessenger.of(context).clearSnackBars();

    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _nameController.dispose();
    super.dispose();
  }


  void getHeaderPic() {
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

  void showToast(String message) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final snackBar = SnackBar(
      width: MediaQuery.of(context).size.width - 50,
      content: Center(
        child: Text(message, style: const TextStyle(color: Colors.white)),
      ),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5), // transparent black
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );

    // Show the SnackBar
   if(toastStatus) {
     toastStatus = false;
     final snackBarController = scaffoldMessenger.showSnackBar(snackBar);

     // Listen for the SnackBar's closed event
     snackBarController.closed.then((reason) {
       toastStatus = true;
       print('SnackBar was closed with reason: $reason');
       // Do something when the SnackBar is hidden
     });

     // _nameController.addListener(() {
     //   print("ddd");
     //   scaffoldMessenger.clearSnackBars();
     //  // toastStatus = true;
     // });
   }
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
      final imageTemporary = File(value!.path);
    setState(() {
      _image = imageTemporary;
    });
    });
   
  }


  // Future getImageSouce(ImageSource source) async {
  //   final image = await ImagePicker().pickImage(source: source);
  //   if (image == null) return null;

  //   final imageTemporary = File(image.path);
  //   setState(() {
  //     this._image = imageTemporary;
  //   });
  // }
  FocusNode keyBoardFocus =FocusNode();
  @override
 // TextEditingController _nameController = TextEditingController();

  Widget build(BuildContext context) {
    var headerProvider = Provider.of<AccountProvider>(context, listen: false);
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body:
      SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
    child: SizedBox(
    height: MediaQuery.of(context).size.height,
    child:
      Stack(
        clipBehavior: Clip.none,
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
              children: const [
                BackButton(color: Colors.white),
                SizedBox(width: 10,),
                Text(
                  'Add Header',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Positioned(
          //   top: 60,
          //   right: 40,
          //   child: Padding(
          //     padding: EdgeInsets.symmetric(horizontal: 25),
          //     child: Container(
          //       width: MediaQuery.of(context).size.width / 1.2,
          //       height: MediaQuery.of(context).size.height / 3,
          //       // color: Colors.red,
          //       child: Column(
          //         children: [
          //           InkWell(
          //             //  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfile())),
          //             child: Row(
          //               children: [
          //                 SizedBox(width: 15),
          //               ],
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          Positioned(
            top: 180,
            child: SizedBox(

              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () {
                        getHeaderPic();
                      },
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(12),
                        dashPattern: const [8, 4],
                        strokeWidth: 2,
                        color: Colors.grey,
                        child: _image != null
                            ? Image.file(
                          _image!,
                          height: 150,
                          width: 330,
                          fit: BoxFit.contain,
                        )
                            : Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 100, vertical: 50),
                              child: Text(
                                'UPLOAD',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                      ),
                    ),
                  ),
                ],
                /* DottedBorder(
          borderType: BorderType.RRect,
          radius: Radius.circular(12),
          dashPattern: [8, 4],
          strokeWidth: 2,
          color: Colors.green

        ),*/
              ),
            ),
          ),
          Positioned(
            top: 400,
            left: 20,
            right: 20,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Focus(
                      focusNode: _focusNode,
                      child: TextFormField(
                        style: const TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        focusNode: keyBoardFocus,
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter header name',
                          hintStyle: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),


                  const SizedBox(height:90),
                  InkWell(
                    onTap: (){
                      print('text');
                      keyBoardFocus.unfocus();
                      print(_nameController.text)   ;
                      if( _nameController.text == '' || _image == null){
                        showToast('Select Header/Enter Header Name');
                      }
                      else if ( _nameController.text != '' && _image != null) {
                        print('sss');
                        const SnackBar(content: Text('Loading'));
                        headerProvider.uploadHeader(
                            authProvider.accessToken, authProvider.userId,
                            _nameController.text, _image, context);
                      }
                    },
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    child: Center(
                      child: SizedBox(
                        height: 50,
                        width: 170,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  textGreen,
                                  textGreen,
                                  rightGreen,
                                ]),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Center(
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                ],
              ),
            ),
          ),
          const Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: BottomSectionTransp(),
          )
        ],
      ),
    ),),

    );
  }
}
