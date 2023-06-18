import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:smart_station/providers/GroupProvider/group_provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import '../../../providers/ProfileProvider/profile_provider.dart';
import '../../../utils/constants/urls.dart';
import '../home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class CreateGroupScreen2 extends StatefulWidget {
  List memberData;

  CreateGroupScreen2({Key? key, required this.memberData}) : super(key: key);

  @override
  State<CreateGroupScreen2> createState() => _CreateGroupScreen2State();
}

class _CreateGroupScreen2State extends State<CreateGroupScreen2> {
  final TextEditingController _textEditingController = TextEditingController();

  bool show = false;
  File? _image;
  FocusNode focusNode = FocusNode();
  String? fullPath;
  String? halfPath;
  bool loader = false;

  final IO.Socket _socket = IO.io(AppUrls.appSocketUrl,
      IO.OptionBuilder().setTransports(['websocket']).build());

  _connectSocket() {
    _socket.connect();
    _socket.onConnect((data) => print('Connection established'));
    _socket.onConnectError((data) => print('Connect Error $data'));
    _socket.onDisconnect((data) => print('Socket.IO disconneted'));
  }

  _destroySocket() {
    _socket.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print("sdhdghsghdsgshgd");
    // print(widget.memberData);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.of(context).size.height * 0.1),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.black38,
            automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Row(
                  children: [
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon:
                            const Icon(Icons.arrow_back, color: Colors.white)),
                    const Text(
                      'New Group',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(_textEditingController.text.isNotEmpty) {
            _createGroup(context);
          }
          else{
             showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Required'),
              content: Text('Group name required.'),
              actions: <Widget>[
                TextButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
          }
        },
        backgroundColor: Colors.green,
        child: const Icon(
          Icons.arrow_forward,
          size: 35,
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(splashBg), fit: BoxFit.fill)),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.18,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (_image != null)
                        InkWell(
                          onTap: () {
                            getProfilePic();
                          },
                          child: CircleAvatar(
                              maxRadius: 28,
                              backgroundColor: Colors.grey[400],
                              backgroundImage: Image.file(_image!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover)
                                  .image),
                        ),
                      if (_image == null)
                        InkWell(
                          onTap: () {
                            getProfilePic();
                          },
                          child: Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[400],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Image.asset(cameraIcon),
                            ),
                          ),
                        ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TextField(
                          controller: _textEditingController,
                          onChanged: (value) {
                            // search(value);
                          },
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: () {
                                  focusNode.unfocus();
                                  focusNode.canRequestFocus = false;
                                  setState(() {
                                    show = !show;
                                  });
                                },
                                icon: ImageIcon(
                                  AssetImage(smileIcon),
                                  color: rightGreen,
                                  size: 30,
                                )),
                            border: InputBorder.none,
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: rightGreen, width: 1),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: rightGreen, width: 2),
                            ),
                            hintText: 'Group Name Here...',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Provide a group subject and optional group icon',
                    style: TextStyle(fontSize: 15),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: 290,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.grey,
              width: double.infinity,
              height: 30,
            ),
          ),
          Positioned(
            top: 320,
            left: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Text(
                  'Participants: ${widget.memberData.length}',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: GridView.builder(
                    itemCount: widget.memberData.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5),
                    itemBuilder: ((context, index) {
                      // return Text("hi");
                      return Column(
                        children: [
                          Card(
                            child: CircleAvatar(
                                maxRadius: 25,
                                backgroundImage: NetworkImage(
                                    widget.memberData[index].profilePic)),
                          ),
                          Text(
                            widget.memberData[index].name,
                            style: const TextStyle(fontSize: 8),
                          )
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          show
              ? Align(alignment: Alignment.bottomCenter, child: emojiPicker())
              : Container(),
        ],
      ),
    );
  }

  Widget emojiPicker() {
    return SizedBox(
      height: 250,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          print(emoji);
          setState(() {
            _textEditingController.text =
                _textEditingController.text + emoji.emoji;
          });
        },
      ),
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

    var auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      loader = true;
    });
    if (loader) {
      SpinKitSpinningLines(color: textGreen);
    }
    final imageTemporary = File(image.path);
    // String url = "${AppUrls.appBaseUrl}fileupload";
   File compressedImage = await FlutterNativeImage.compressImage(
      image.path,
      percentage: 80,
      quality: 100,
    );
    cropImage(compressedImage).then((value) async {
      var auth = Provider.of<AuthProvider>(context, listen: false);
      var profile = Provider.of<ProfileProvider>(context, listen: false);
      File imgPath = File(value!.path);
      //croppedImage = File(value.path);
      String url = '${AppUrls.appBaseUrl}/fileupload';

      
        var stream = http.ByteStream(imgPath.openRead());
        var length = await imgPath.length();
        var request = http.MultipartRequest('POST', Uri.parse(url));
        var multipartFile =
            http.MultipartFile('file', stream, length, filename: imgPath.path);
        // print('$userId\n$accessToken\n$multipartFile');
        request.fields['user_id'] = auth.userId;
        request.fields['accessToken'] = auth.accessToken;
        request.files.add(multipartFile);
        var resp = await request.send();
        resp.stream.transform(utf8.decoder).listen((event) {
          print('#############################');
          print(event.runtimeType);
          print(event);
          print('#############################');
          var finalData = jsonDecode(event);
          print("finaldata-----------${finalData}");
           fullPath = finalData['filepath'];
      halfPath = finalData['path'];
      print('svsvdffff');
      print(halfPath);
          // setState(() {
          //   isloading = false;
          // });
          // _profilePic = finalData['data']['profile_pic'];
          // notifyListeners();
         

     
      setState(() {
      _image = File(value.path);
      });
    });
    //    String url = '${AppUrls.appBaseUrl}fileupload';
    // var stream = http.ByteStream(File(value!.path).openRead());
    // var length = await File(image.path).length();
    // var request = http.MultipartRequest('POST', Uri.parse(url));
    // var multipartFile = http.MultipartFile('file', stream, length,
    //     filename: File(image.path).path);
    // request.fields['user_id'] = auth.userId;
    // request.fields['accessToken'] = auth.accessToken;
    // request.files.add(multipartFile);
    // var resp = await request.send();

    // resp.stream.transform(utf8.decoder).listen((event) {
    //   var afterResult;
    //   print(event);
    //   afterResult = jsonDecode(event);
    //   fullPath = afterResult['filepath'];
    //   halfPath = afterResult['path'];
    //   print('svsvdffff');
    //   print(halfPath);
    // });
    // setState(() {
    //   _image = File(value.path);
    //   loader = false;
    // });
    });
   
  }
    void getProfilePic() {
    //var profile = Provider.of<ProfileProvider>(context, listen: false);
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
  _createGroup(contexts) {
    List<String> userId = [];
    var groupP = Provider.of<GroupProvider>(contexts, listen: false);
    var auth = Provider.of<AuthProvider>(contexts, listen: false);
    var uid = auth.userId;
    var aTok = auth.accessToken;
    for (var element in widget.memberData) {
      userId.add(element.userId);
    }

    var joined = userId.join(',');

    var body = {
      'user_id': auth.userId,
      'accessToken': auth.accessToken,
      'group_name': _textEditingController.text,
      'members': joined,
      'group_profile': halfPath
    };
    print(body);
    if (_socket.connected) {
      _socket.emit('create_group', {
        'user_id': auth.userId,
        'accessToken': auth.accessToken,
        'group_name': _textEditingController.text,
        'members': joined,
        'group_profile': halfPath
      });
      _socket.on('create_group', (data) {
        _destroySocket();
        print('======================[JOINED1]========================');
        print(data);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      });
    } else {
      _connectSocket();
      _socket.emit('create_group', {
        'user_id': auth.userId,
        'accessToken': auth.accessToken,
        'group_name': _textEditingController.text,
        'members': joined,
        'group_profile': halfPath
      });
      _socket.on('create_group', (data) {
        _destroySocket();
        print('======================[JOINED2]========================');
        print(data);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      });
    }

    // print(groupP.resMessage);
    // var jsonData = jsonDecode(groupP.resMessage);
    // // print("jsondata");
    // print(jsonData);
  }
}
