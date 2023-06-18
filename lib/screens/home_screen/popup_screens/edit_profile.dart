import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/providers/ProfileProvider/profile_provider.dart';
import 'package:smart_station/screens/home_screen/popup_screens/profile_picture_view.dart';
import '../../../utils/constants/app_constants.dart';
//import 'package:image_cropper/image_cropper.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  File? _image;
  String? halfPath;
  void getProfilePic() {
    var profile = Provider.of<ProfileProvider>(context, listen: false);

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
                      const Text(
                        'Profile photo',
                        style: TextStyle(fontSize: 20),
                      ),
                      profile.profileHalfPath == 'uploads/default/profile.png'
                          ? const SizedBox()
                          : InkWell(
                              onTap: () {
                                var auth = Provider.of<AuthProvider>(context,
                                    listen: false);
                                var profile = Provider.of<ProfileProvider>(
                                    context,
                                    listen: false);
                                Navigator.pop(context);
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        content: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.5,
                                            child: const Text(
                                                'Remove profile photo?')),
                                        actions: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  Navigator.of(context)
                                                      .pop(); // Dismiss dialog
                                                },
                                                child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: const Text('Cancel',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.green))),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    profile
                                                        .removeProfilePicture(
                                                            accessTok: auth
                                                                .accessToken,
                                                            userId:
                                                                auth.userId);
                                                  });
                                                  Navigator.of(context)
                                                      .pop(); // Dismiss dialog
                                                },
                                                child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: const Text(
                                                      'Remove',
                                                      style: TextStyle(
                                                          color: Colors.green),
                                                    )),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              )
                                            ],
                                          )
                                        ],
                                      );
                                    });
                              },
                              child: ImageIcon(AssetImage(trashIcon),
                                  color: Colors.grey[600], size: 30),
                            )
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
      profile.fileUpload(imgPath, auth.accessToken, auth.userId, context);
      //  profile.updateProfilePicture(imgPath, auth.accessToken, auth.userId, context);
      setState(() {
        _image = imgPath;
        halfPath = profile.halfPath;
        print('halfpath===================$halfPath');
      });
    });
  }

  // Future getImageSouce(ImageSource source) async {
  //   final image = await ImagePicker().pickImage(source: source);
  //   if (image == null) return null;

  //   final imageTemporary = File(image.path);
  //   final String path=image.path;
  //   var auth = Provider.of<AuthProvider>(context, listen: false);
  //   var profile = Provider.of<ProfileProvider>(context, listen: false);
  //   var status= profile.fileUpload(imageTemporary, auth.accessToken,auth.userId, context);
  //   print("fileUpload1----------${profile.halfPath}");

  //   setState(() {
  //    this._image = imageTemporary;
  //    this.halfPath = profile.halfPath;
  //    print("halfpath===================${this.halfPath}");
  //   });
  // }
  TextEditingController emailEditController = TextEditingController();
  TextEditingController nameEditController = TextEditingController();
  TextEditingController aboutEditController = TextEditingController();
  var emailValidate = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  var profile;
  var auth;
  String fileName = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var auth = Provider.of<AuthProvider>(context, listen: false);
    var profile = Provider.of<ProfileProvider>(context, listen: false);
    print('--------------------halfPath');
    print('---${profile.profileHalfPath}');
    fileName = profile.profileHalfPath;
    nameEditController.text = profile.nameController.text;
    emailEditController.text = profile.emailController.text;
    aboutEditController.text = profile.aboutController.text;

    profile.getProfile(accessTok: auth.accessToken, userId: auth.userId);
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    return Consumer<ProfileProvider>(
      builder: (context, profile, child) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize:
                const Size.fromHeight(80.0), // Set the height of the app bar
            child: Container(
              color: Colors.black38,
              child: Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Row(
                  children: const [
                    BackButton(color: Colors.white),
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(splashBg), fit: BoxFit.fill)),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 120,
                  ),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: CircleAvatar(
                      // backgroundColor: Colors.red,
                      backgroundColor: Colors.transparent,
                      radius: 65,
                      child: Stack(
                        children: [
                          InkWell(
                            onTap: () async {
                              String refresh = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfilePictureView(
                                          profilePic:
                                              profile.profilePic.toString())));
                              if (refresh == 'Refresh') {
                                setState(() {
                                  print('inside setstate');
                                  profile.getProfile(
                                      accessTok: auth.accessToken,
                                      userId: auth.userId);
                                });
                              }
                            },
                            child: CircleAvatar(
                              radius: 65,
                              backgroundColor: Colors.transparent,
                              backgroundImage: _image != null
                                  ? Image.file(_image!,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover)
                                      .image
                                  : Image.network(
                                      profile.profilePic,
                                      fit: BoxFit.contain,
                                    ).image,
                            ),
                          ),
                          Positioned(
                            right: 1,
                            bottom: 1,
                            child: InkWell(
                              onTap: () {
                                getProfilePic();
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.mail,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 1.4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'User mail',
                                    style: TextStyle(
                                        color: textGreen,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    profile.companyMail,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        // Divider(),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Phone',
                                    style: TextStyle(
                                        color: textGreen,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  profile.phNumber,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            )
                          ],
                        ),
                        // Divider()
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(
                    thickness: 2,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter your name',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 55,
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.black12,
                          ),
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {});
                            },
                            maxLength: 25,
                            controller: nameEditController,
                            decoration: InputDecoration(
                              suffix: SizedBox(
                                  width: 30,
                                  child: Center(
                                      child: Text(
                                          '${25 - nameEditController.text.length}'))),
                              counterText: '',
                              fillColor: Colors.grey[100],
                              filled: true,
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'Enter your email',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 55,
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.black12,
                          ),
                          child: TextFormField(
                            controller: emailEditController,
                            onFieldSubmitted: (value) {
                              if (emailValidate
                                  .hasMatch(emailEditController.text)) {
                                setState(() {
                                  // _selectedChips.add(_toController.text.toString().trim());
                                  // profile.emailController.clear();
                                });
                              } else {
                                setState(() {
                                  profile.emailController.clear();
                                });
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  duration: Duration(milliseconds: 1000),
                                  content: Text(
                                      'Please enter a valid email address'),
                                ));
                              }
                            },
                            decoration: InputDecoration(
                              fillColor: Colors.grey[100],
                              filled: true,
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'About',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 55,
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.black12,
                          ),
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {});
                            },
                            onTap: () {
                              aboutEditController.selection = TextSelection(
                                  baseOffset: 0,
                                  extentOffset:
                                      aboutEditController.text.length);
                            },
                            maxLength: 140,
                            controller: aboutEditController,
                            decoration: InputDecoration(
                              suffix: SizedBox(
                                  width: 30,
                                  child: Center(
                                      child: Text(
                                          '${140 - aboutEditController.text.length}'))),
                              counterText: '',
                              fillColor: Colors.grey[100],
                              filled: true,
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                  Column(
                    children: [
                      SizedBox(
                        width: 70,
                        child: Image(
                          image: AssetImage(transpLogo),
                        ),
                      ),
                      const SizedBox(height: 60),
                      InkWell(
                        onTap: () {
                          if (nameEditController.text == '' &&
                              aboutEditController.text == '') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                width: MediaQuery.of(context).size.width - 50,
                                content: const Center(
                                    child: Text(
                                  "Name and about can't be empty",
                                  style: TextStyle(color: Colors.white),
                                )),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor:
                                    const Color.fromRGBO(0, 0, 0, 0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            );
                          } else if (nameEditController.text == '') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                width: MediaQuery.of(context).size.width - 50,
                                content: const Center(
                                    child: Text(
                                  "Name can't be empty",
                                  style: TextStyle(color: Colors.white),
                                )),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor:
                                    const Color.fromRGBO(0, 0, 0, 0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            );
                          } else if (emailEditController.text == '') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                width: MediaQuery.of(context).size.width - 50,
                                content: const Center(
                                    child: Text(
                                  "Email can't be empty",
                                  style: TextStyle(color: Colors.white),
                                )),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor:
                                    const Color.fromRGBO(0, 0, 0, 0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            );
                          } else if (aboutEditController.text == '') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                width: MediaQuery.of(context).size.width - 50,
                                content: const Center(
                                    child: Text(
                                  "About can't be empty",
                                  style: TextStyle(color: Colors.white),
                                )),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor:
                                    const Color.fromRGBO(0, 0, 0, 0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            );
                          } else if (emailValidate
                                  .hasMatch(emailEditController.text) ||
                              emailEditController.text == '') {
                            halfPath == null
                                ? profile.editUser(
                                    userId: auth.userId,
                                    accessToken: auth.accessToken,
                                    name: nameEditController.text,
                                    email: emailEditController.text,
                                    about: aboutEditController.text,
                                    profile_pic: profile.profileHalfPath,
                                    context: context,
                                  )
                                : profile.editUser(
                                    userId: auth.userId,
                                    accessToken: auth.accessToken,
                                    name: nameEditController.text,
                                    email: emailEditController.text,
                                    about: aboutEditController.text,
                                    profile_pic: profile.halfPath,
                                    context: context,
                                  );
                          } else {
                            setState(() {
                              profile.emailController.clear();
                            });
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              duration: Duration(milliseconds: 1000),
                              content:
                                  Text('Please enter a valid email address'),
                            ));
                          }
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 2,
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
                                'Update',
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
}
