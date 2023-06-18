import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/providers/ChatDetailProvider/chatdetail_provider.dart';
import 'package:smart_station/screens/home_screen/chat/api/individual_chat_section.dart';
import 'package:smart_station/screens/home_screen/chat/conversation_info.dart';
import 'package:smart_station/screens/home_screen/chat/forward_screen.dart';
import 'package:smart_station/screens/home_screen/chat/liveMap.dart';
import 'package:smart_station/screens/home_screen/chat/widget/audioSending.dart';
import 'package:smart_station/screens/home_screen/chat/widget/audioSendingNoRply.dart';
import 'package:smart_station/screens/home_screen/chat/widget/chat%20bubble/chat_bubble.dart';
import 'package:smart_station/screens/home_screen/chat/widget/documentSending.dart';
import 'package:smart_station/screens/home_screen/chat/widget/documentSendingNoRply.dart';
import 'package:smart_station/screens/home_screen/chat/widget/imageSending.dart';
import 'package:smart_station/screens/home_screen/chat/widget/imageSendingNoRply.dart';
import 'package:smart_station/screens/home_screen/chat/widget/media_screen/media_home.dart';
import 'package:smart_station/screens/home_screen/chat/widget/videoSending.dart';
import 'package:smart_station/screens/home_screen/chat/widget/videoSendingNoRply.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:video_compress/video_compress.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:share_plus/share_plus.dart';
import '../../callAndNotification/videoCalling.dart';
import 'models/individualChat/messageModel.dart';
import '../../../providers/UserProvider/user_provider.dart';
import '../../../utils/constants/urls.dart';
import '../../callAndNotification/calling.dart';
import 'package:path_provider/path_provider.dart';

class NewConversation extends StatefulWidget {
  NewConversation(
      {Key? key, required this.rId, required this.toFcm, required this.roomId})
      : super(key: key);

  String rId;
  String toFcm;
  String roomId;

  @override
  State<NewConversation> createState() => _NewConversationState();
}

class _NewConversationState extends State<NewConversation> {
  AudioPlayer audioPlayer = AudioPlayer();
  DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  DateFormat dateFormat2 = DateFormat('dd/MM/yyyy hh:mm a');
  Duration duration = const Duration();
  FocusNode focusNode = FocusNode();
  String? fullPath;
  String? halfPath;
  String? fileType;
  bool isBlocked = false;
  bool isDeleteEveryone = false;
  bool isMuted = false;
  bool isSender = false;
  bool isChecked = false;
  bool blockWorks = false;
  bool reportWorks = false;
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  final ItemScrollController itemScrollController = ItemScrollController();
  bool longPress = false;
  late GoogleMapController mapController;
  bool menuTap = false;
  List<String> messageId = [];
  String? msgTyp;
  bool playing = false;
  List<String> popUpItems = [
    'View contact',
    'Media, links, and docs',
    'Search',
    'Mute notificaitons',
    'More'
  ];

  Duration position = const Duration();
  final recorder = FlutterSoundRecorder();
  String? replyId;
  String? replyMsg;
  bool rply = false;
  String? senderId;
  bool show = false;
  bool sndBtn = false;
  bool pauseRec = false;
  bool isRec = false;
  String? sndName;
  bool starred = false;
  StreamController<IndividualChatModel> streamController =
      StreamController<IndividualChatModel>();

  String? thumbPath;
  bool typing = false;
  String? userId;
  String? userStatus;
  String sharedText = '';
  List<String> voicePlay = [];
  bool vwe = false;
  File? audPath;

  final TextEditingController _controller = TextEditingController();
  final int _currentIndex = 0;
  final ImagePicker _picker = ImagePicker();
  final GlobalKey _popupMenuButtonKey = GlobalKey();
  late VideoPlayerController _videoPlayerController;

  final IO.Socket _socket = IO.io(AppUrls.appSocketUrl,
      IO.OptionBuilder().setTransports(['websocket']).build());

  _connectSocket() {
    _socket.connect();
    _socket.onConnect((data) => print('Connection established'));
    _socket.onConnectError((data) => print('Connect Error $data'));
    _socket.onDisconnect((data) => print('Socket.IO disconneted'));
  }

  _destroySocket() {
    _socket.disconnect();
    streamController.close();
  }

  @override
  void dispose() {
    // _destroySocket();
    // streamController.close();
    recorder.closeRecorder();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    userId = auth.userId;
    print('---------------------------------');
    print(widget.rId);
    print(widget.toFcm);
    print('------------------------------------');
    _connectSocket();
    socketFunction();
    procedureFunction();
    initRecorder();
    super.initState();
  }

  socketFunction() async {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
    };
    if (_socket.connected) {
      _socket.on('message_delivered', (data) => null);
      _socket.emit('message_delivered', {
        "user_id": auth.userId,
        "accessToken": auth.accessToken,
        "room": widget.roomId
      });
      _socket.emit('read', {'sid': auth.userId, 'rid': widget.rId, 'room': ""});
      _socket.on('room_notification', (data) {
        print('======================[JOINED]========================');
        _socket.emit(
            'room_chat_list_details', {'sid': auth.userId, 'rid': widget.rId});

        _socket.on('typing_individual_room', (data) {
          print('TYPING DATA ==> $data');
          if (data['typing'] == '1' && data['user_id'] != auth.userId) {
            print("C USER ==> ${auth.userId} T USER ==>${data['user_id']}");
            setState(() {
              typing = true;
            });
          } else {
            setState(() {
              typing = false;
            });
          }
        });

        _socket.on('online_users', (data) {
          print('SDDFDFDFDFDFDFDFDFDFDFDF');
          print(data);
          print('SDDFDFDFDFDFDFDFDFDFDFDF');
          if (data['online_status'] == '1') {
            setState(() {
              userStatus = 'online';
            });
          } else {
            var dt = data['last_seen'].toString();
            final now = DateTime.now();
            String formatter = DateFormat('dd/MM/yyyy hh:mm a').format(now);
            DateTime dateTime = DateTime.parse(dt);
            String formattedDate = dateFormat2.format(dateTime);
            print('QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ');
            print(formattedDate);
            print('QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ');
            setState(() {
              userStatus = formattedDate;
            });
          }
        });

        _socket.on('message', (data) async {
          _socket.on('read', (data) => null);
          _socket.emit(
              'read', {'sid': auth.userId, 'rid': widget.rId, 'room': ''});
          var finalData = IndividualChatModel.fromJson(data);
          if (streamController.isClosed) {
            streamController = StreamController();
            streamController.onListen;
            streamController.add(finalData);
          } else {
            streamController.add(finalData);
          }
        });
      });
    } else {
      _connectSocket();
      _socket.on('room_notification', (data) {
        _socket.emit(
            'room_chat_list_details', {'sid': auth.userId, 'rid': widget.rId});

        _socket.on('typing_individual_room', (data) {
          print('TYPING DATA ==> $data');
          if (data['typing'] == '1' && data['user_id'] != auth.userId) {
            print("C USER ==> ${auth.userId} T USER ==>${data['user_id']}");
            // setState(() {
            // });
            typing = true;
          } else {
            // setState(() {
            // });
            typing = false;
          }
        });

        _socket.on('online_users', (data) {
          print('SDDFDFDFDFDFDFDFDFDFDFDF');
          print(data);
          print('SDDFDFDFDFDFDFDFDFDFDFDF');
          if (data['online_status'] == '1') {
            userStatus = 'online';
          } else {
            String dt = data['last_seen'].toString();
            final now = new DateTime.now();
            String formatter = DateFormat('dd/MM/yyyy hh:mm a').format(now);
            DateTime dateTime = DateTime.parse(dt);
            String formattedDate = dateFormat2.format(dateTime);
            print('QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ');
            print(formattedDate);
            print('QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ');
            userStatus = 'Last seen ${formattedDate}';
          }
        });

        _socket.on('message', (data) async {
          print('ENTER');
          var finalData = IndividualChatModel.fromJson(data);
          if (streamController.isClosed) {
            streamController = StreamController();
            streamController.onListen;
            streamController.add(finalData);
          } else {
            streamController.add(finalData);
          }
        });
        _socket.on('message_delivered', (data) => null);
        _socket.emit('message_delivered', {
          "user_id": auth.userId,
          "accessToken": auth.accessToken,
          "room": widget.roomId
        });
      });
      _socket.emit('room', {'sid': auth.userId, 'rid': widget.rId});
    }
  }

  getValue(mId, mData, sId, sName, mTyp) {
    if (longPress) {
      setState(() {
        longPress = false;
        messageId = [];
      });
    }
    print('::::::[DATA]::::::');
    print(mId);
    print(mData);
    print(sId);
    print(sName);
    print('::::::[DATA]::::::');
    setState(() {
      rply = true;
      replyMsg = mData;
      replyId = mId;
      senderId = sId;
      sndName = sName;
      msgTyp = mTyp;
    });
    print('::::::::::AFTR SETTING:::::::::::::');
    print(replyId);
    print('::::::::::AFTR SETTING:::::::::::::');
  }

  // void exportChat(String messageList) async {
  //   List expData = jsonDecode(messageList);
  //   List dts = [];
  //   String passdData = '';
  //   expData.forEach((element) {
  //     final now = new DateTime.now();
  //     String formatter = DateFormat('dd MM yyyy').format(now);
  //     DateTime dateTime =
  //         DateTime.parse(element['datetime']); //messageList[index].date;
  //     String formattedDate = dateFormat2.format(dateTime);
  //     String expMsg = formattedDate + '  -  ' + ' ' + element['message'];
  //     dts.add(expMsg);
  //   });
  //   passdData = jsonEncode(dts);
  //   print(passdData);
  //   DateTime now = DateTime.now();
  //   String formattedDate = DateFormat('yyyyMMddkkmm').format(now);
  //   // Parse the JSON string to a list of messages
  //   // final List<dynamic> messages = jsonDecode(messageList);
  //
  //   // Get the user's downloads directory
  //   final directory = await getDownloadsDirectory();
  //   final file = File('/storage/emulated/0/Download/chat${formattedDate}.txt');
  //   await file.writeAsString(passdData).then((value) async {
  //     await AwesomeNotifications().createNotification(
  //       content: NotificationContent(
  //         id: 66,
  //         channelKey: 'downloaded_pdf',
  //         title: '/storage/emulated/0/Download/chatchat${formattedDate}.txt',
  //         body: 'Download Completed',
  //       ),
  //     );
  //   });
  //
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('Downloaded file to ${file.path}'),
  //     ),
  //   );
  // }
  void exportChat(String messageList) async {
    List expData = jsonDecode(messageList);
    print(expData);
    List dts = [];
    String passdData = '';
    IOSink sink;
    expData.forEach((element) {
      final now = new DateTime.now();
      String formatter = DateFormat('dd MM yyyy').format(now);
      DateTime dateTime =
          DateTime.parse(element['datetime']); //messageList[index].date;
      String formattedDate = dateFormat2.format(dateTime);
      String expMsg = formattedDate + '  -  ' + ' ' + element['message'];
      dts.add(expMsg);
    });

    // passdData = jsonEncode(dts);
    // print(passdData);
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('ddMMyyyyHHmmss').format(now);
    String downloadName = formattedDate + ".txt";
    // Parse the JSON string to a list of messages
    // final List<dynamic> messages = jsonDecode(messageList);

    // Get the user's downloads directory
    if (Platform.isAndroid) {
      final directory = await getDownloadsDirectory();
      final file =
          File('/storage/emulated/0/Download/chat${formattedDate}.txt');
      // await file.writeAsString(passdData).then((value) async {
      //   await AwesomeNotifications().createNotification(
      //     content: NotificationContent(
      //       id: 66,
      //       channelKey: 'downloaded_pdf',
      //       title: '/storage/emulated/0/Download/chatchat${formattedDate}.txt',
      //       body: 'Download Completed',
      //     ),
      //   );
      // });
          if (file.existsSync()) {
               file.deleteSync();
           }
           file.createSync();

       sink = await file.openWrite(mode: FileMode.append);
      for (int i = 0; i < dts.length; i++) {
        // await file.writeAsString("${dts[i]}\n", mode: FileMode.append);
        sink.write("${dts[i]}\n");
      }
      await AwesomeNotifications().createNotification(
          content: NotificationContent(
        id: 66,
        channelKey: "downloaded_pdf",
        title: '/storage/emulated/0/Download/chatchat${formattedDate}.txt',
        body: 'Download Completed',
      ));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloaded file to ${file.path}'),
        ),
      );
      sink.close();
    } else {
      var directory = await getApplicationDocumentsDirectory();
      // final file = File(
      //     '/storage/emulated/0/Download/chat${formattedDate}.txt');
      final file = File("${directory.path}/$downloadName");
      await file.writeAsString(passdData).then((value) async {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 66,
            channelKey: 'downloaded_pdf',
            title: '/storage/emulated/0/Download/chatchat${formattedDate}.txt',
            body: 'Download Completed',
          ),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloaded file to ${file.path}'),
        ),
      );
    }
  }

  Future<String> getDownloadsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future record() async {
    await recorder.startRecorder(toFile: 'audioRecord');
  }

  Future stop(status, toSend) async {
    final path = await recorder.stopRecorder();

    if (toSend) {
      print(toSend);
      print(recorder.isRecording);
      await recorder.deleteRecord(fileName: path!);
      if (status) {
        setState(() {
          rply = false;
          pauseRec = false;
        });
      } else {
        setState(() {
          rply = false;
          pauseRec = false;
        });
      }
    } else {
      final audioPath = File(path!);

      print('AUDIO PATH:::::::::::::::::::::> $audioPath');

      if (audioPath != null) {
        var auth = Provider.of<AuthProvider>(context, listen: false);
        var url = Uri.parse('${AppUrls.appBaseUrl}fileupload');
        final file = audioPath.path.toString();
        final request = http.MultipartRequest('POST', url);
        var stream = http.ByteStream(File(file).openRead());
        var length = await File(file).length();
        var multipartFile = http.MultipartFile('file', stream, length,
            filename: File(file).path);
        request.fields['user_id'] = auth.userId;
        request.fields['accessToken'] = auth.accessToken;
        request.files.add(multipartFile);
        var resp = await request.send();

        resp.stream.transform(utf8.decoder).listen((event) {
          print('EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE');
          print(event);
          print('EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE');

          var body = {
            'sid': auth.userId,
            'rid': widget.rId,
            'message': jsonDecode(event)['path'],
            'type': 'voice',
          };

          var rplyBody = {
            'sid': auth.userId,
            'rid': widget.rId,
            'message': jsonDecode(event)['path'],
            'message_id': replyId,
            'type': 'voice',
          };
          if (status) rply = false;
          _socket.emit('message', status ? rplyBody : body);
        });
      }
    }
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }

    await recorder.openRecorder();

    recorder.setSubscriptionDuration(
      const Duration(milliseconds: 500),
    );
  }

  procedureFunction() {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    getIndividualInfo(auth.userId, auth.accessToken, widget.rId).then((value) {
      if (value.data.mute.muteStatus == 1) {
        setState(() {
          isMuted = true;
        });
      } else {
        setState(() {
          isMuted = false;
        });
      }

      if (value.data.userBlockStatus == 1) {
        setState(() {
          isBlocked = true;
        });
      } else {
        setState(() {
          isBlocked = false;
        });
      }
    });

    if (_socket.disconnected) {
      _socket.connect();
    }
  }

  getFocus() {
    print('TAPPED');
    if (show) {
      setState(() {
        show = false;
      });
    }

    if (vwe) {
      setState(() {
        vwe = false;
      });
    }
  }

  Widget emojiPicker() {
    return SizedBox(
      height: 250,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          print(emoji);
          setState(() {
            _controller.text = _controller.text + emoji.emoji;
          });
          if (_controller.text.length > 0) {
            setState(() {
              sndBtn = true;
            });
          } else {
            setState(() {
              sndBtn = true;
            });
          }
        },
      ),
    );
  }

  Widget bottomContainer() {
    return Container(
      height: 250,
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xff835EB5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          getImage(ImageSource.camera).then((value) {
                            isUploading = true;
                            compressImage(value);
                          });
                        },
                        icon: const Icon(Icons.camera,
                            color: Colors.white, size: 30),
                      ),
                    ),
                  ),
                  const Text('Camera'),
                ],
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xfff48fb1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          getImage(ImageSource.gallery).then((value) {
                            compressImage(value);
                          });
                        },
                        icon: const Icon(Icons.image,
                            color: Colors.white, size: 30),
                      ),
                    ),
                  ),
                  const Text('Gallery'),
                ],
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xffE68C78),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: IconButton(
                        onPressed: () async {
                          getAudioFile();
                        },
                        icon: const Icon(Icons.audiotrack,
                            color: Colors.white, size: 30),
                      ),
                    ),
                  ),
                  const Text('Audio'),
                ],
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xff85146B),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          getVideo(ImageSource.camera);
                        },
                        icon: const Icon(Icons.videocam,
                            color: Colors.white, size: 30),
                      ),
                    ),
                  ),
                  const Text('Video'),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xff835EB5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          getFile();
                        },
                        icon: const Icon(Icons.file_copy,
                            color: Colors.white, size: 30),
                      ),
                    ),
                  ),
                  const Text('Document'),
                ],
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xff835EB5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          getVideo(ImageSource.gallery);
                        },
                        icon: const Icon(Icons.video_camera_back_rounded,
                            color: Colors.white, size: 30),
                      ),
                    ),
                  ),
                  const Text('Gallery'),
                ],
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xff85146B),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => LiveMap(
                              chatType: 'single',
                              recId: widget.rId,
                            ),
                          ));
                        },
                        icon: const Icon(Icons.location_on,
                            color: Colors.white, size: 30),
                      ),
                    ),
                  ),
                  const Text('Location')
                ],
              ),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  // color: Color(0xff85146B),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.videocam,
                        color: Colors.transparent, size: 30),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget slider() {
    return Slider.adaptive(
      activeColor: Colors.white,
      inactiveColor: Colors.grey,
      min: 0.0,
      value: position.inSeconds.toDouble(),
      max: duration.inSeconds.toDouble(),
      onChanged: (double value) {
        setState(() {
          audioPlayer.seek(Duration(seconds: value.toInt()));
        });
      },
    );
  }

  Widget sliderDummy() {
    return Slider.adaptive(
      activeColor: Colors.white,
      inactiveColor: Colors.white,
      secondaryActiveColor: Colors.white,
      min: 0.0,
      value: 0.0,
      max: 0.0,
      onChanged: (double value) {},
    );
  }

  static Future<CroppedFile?> cropImage(File? imageFile) async {
    print('FILE===========> ${imageFile!.path}');
    var croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 50,
      cropStyle: CropStyle.rectangle,
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

  Future compressImage(imgFile) async {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    File compressedImage = await FlutterNativeImage.compressImage(imgFile.path,
        percentage: 50, quality: 80);

    cropImage(compressedImage).then((value) async {
      File imgPath = File(value!.path);
      String url = '${AppUrls.appBaseUrl}fileupload';
      var stream = new http.ByteStream(File(imgPath.path).openRead());
      var length = await File(imgPath.path).length();
      var request = new http.MultipartRequest('POST', Uri.parse(url));
      var multipartFile = http.MultipartFile('file', stream, length,
          filename: File(imgPath.path).path);
      request.fields['user_id'] = auth.userId;
      request.fields['accessToken'] = auth.accessToken;
      request.files.add(multipartFile);
      var resp = await request.send();

      resp.stream.transform(utf8.decoder).listen((event) async {
        var afterResult;
        afterResult = jsonDecode(event);
        fullPath = afterResult['filepath'];
        halfPath = afterResult['path'];
        setState(() {
          isUploading = false;
        });
        if (rply) {
          print('has Rply');
          String refresh = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ImageSendingScreen(
                chatType: 'single',
                fPath: afterResult['filepath'],
                hPath: afterResult['path'],
                recId: widget.rId,
                rplyId: replyId,
                fileType: 'image',
              ),
            ),
          );
          if (refresh == 'refresh') {
            setState(() {
              socketFunction();
            });
          }
          setState(() {
            rply = false;
            vwe = false;
          });
        } else {
          print('No Rply');
          String refresh = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ImageSendingNoRplyScreen(
                chatType: 'single',
                fPath: afterResult['filepath'],
                hPath: afterResult['path'],
                recId: widget.rId,
                fileType: 'image',
              ),
            ),
          );
          if (refresh == 'refresh') {
            setState(() {
              socketFunction();
            });
          }
          setState(() {
            rply = false;
            vwe = false;
          });
        }
      });
    });

    return compressedImage;
  }

  Future<XFile?> getImage(ImageSource source) async {
    final pick = await ImagePicker()
        .pickImage(source: source, preferredCameraDevice: CameraDevice.rear);

    return pick;
  }

  Future<int> getRoundedVideoDurationInSeconds(String videoFile) async {
    final File file = File(videoFile);
    final VideoPlayerController controller = VideoPlayerController.file(file);
    await controller.initialize();
    int durationInSeconds = controller.value.duration.inSeconds;
    print(durationInSeconds);

    int roundedDurationInSeconds = durationInSeconds.round();
    await controller.dispose();
    return roundedDurationInSeconds;
  }

  Future getVideo(ImageSource source) async {
    var auth = Provider.of<AuthProvider>(context, listen: false);

    final pick = await ImagePicker().pickVideo(source: source);
    if (pick != null) {
      setState(() {
        isUploading = true;
      });
      int durationInSeconds = await getRoundedVideoDurationInSeconds(pick.path);
      print(pick);
      print(durationInSeconds);
      print('duration');
      if (durationInSeconds > 31) {
        setState(() {
          isUploading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video duration exceeds 30 seconds.'),
            ),
          );
          print('error vidieo');
        });
      } else {
        final info = await VideoCompress.compressVideo(
          pick.path,
          quality: VideoQuality.DefaultQuality,
          deleteOrigin: false,
        );

        final thumbnailFile = await VideoCompress.getFileThumbnail(pick.path,
            quality: 50, // default(100)
            position: -1 // default(-1)
            );

        if (info != null) {
          final compressedFile = File(info.path.toString());
          var auth = Provider.of<AuthProvider>(context, listen: false);
          String url = '${AppUrls.appBaseUrl}fileupload';
          var stream = new http.ByteStream(compressedFile.openRead());
          var length = await compressedFile.length();
          var request = new http.MultipartRequest('POST', Uri.parse(url));
          var multipartFile = http.MultipartFile('file', stream, length,
              filename: compressedFile.path.split('/').last);
          request.fields['user_id'] = auth.userId;
          request.fields['accessToken'] = auth.accessToken;
          request.files.add(multipartFile);
          await request.send().then((value) {
            value.stream.transform(utf8.decoder).listen((event) async {
              if (jsonDecode(event)['status'] == true) {
                fullPath = jsonDecode(event)['filepath'];
                halfPath = jsonDecode(event)['path'];
                if (thumbnailFile != null) {
                  print('AAAAAAAAAAAAAAAAAAAAAAAAAAaA');
                  print(thumbnailFile);
                  print('AAAAAAAAAAAAAAAAAAAAAAAAAAaA');
                  final thumbNail = File(thumbnailFile.path.toString());
                  var auth = Provider.of<AuthProvider>(context, listen: false);
                  String url = '${AppUrls.appBaseUrl}fileupload';
                  var tStream = new http.ByteStream(thumbNail.openRead());
                  var tLength = await thumbNail.length();
                  var thumbRequest =
                      new http.MultipartRequest('POST', Uri.parse(url));
                  var multipartFile = http.MultipartFile(
                      'file', tStream, tLength,
                      filename: thumbNail.path.split('/').last);
                  thumbRequest.fields['user_id'] = auth.userId;
                  thumbRequest.fields['accessToken'] = auth.accessToken;
                  thumbRequest.files.add(multipartFile);
                  await thumbRequest.send().then((tvalue) {
                    tvalue.stream
                        .transform(utf8.decoder)
                        .listen((tevent) async {
                      if (jsonDecode(tevent)['status'] == true) {
                        thumbPath = jsonDecode(tevent)['path'];
                        setState(() {
                          isUploading = false;
                        });
                        if (rply) {
                          print('has Rply');
                          String refresh = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => VideoSendingScreen(
                                chatType: 'single',
                                fPath: fullPath.toString(),
                                hPath: halfPath.toString(),
                                tPath: thumbPath.toString(),
                                recId: widget.rId,
                                rplyId: replyId.toString(),
                                fileType: 'video',
                              ),
                            ),
                          );
                          if (refresh == 'refresh') {
                            setState(() {
                              socketFunction();
                            });
                          }
                          setState(() {
                            rply = false;
                            vwe = false;
                          });
                        } else {
                          print('No Rply');
                          String refresh = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => VideoSendingNoRplyScreen(
                                chatType: 'single',
                                fPath: fullPath.toString(),
                                hPath: halfPath.toString(),
                                tPath: thumbPath.toString(),
                                recId: widget.rId,
                                fileType: 'video',
                              ),
                            ),
                          );
                          if (refresh == 'refresh') {
                            setState(() {
                              socketFunction();
                            });
                          }
                          setState(() {
                            rply = false;
                            vwe = false;
                          });
                        }
                      }
                    });
                  });
                }
              }
            });
          });

          // resp.stream.transform(utf8.decoder).listen((event) {
          //   var afterResult;
          //   print(event);
          //   afterResult = jsonDecode(event);
          //   fullPath = afterResult['filepath'];
          //   halfPath = afterResult['path'];
          //
          //

          //
          //
          // });
        } else {
          print('NULL');
        }
      }
    }
  }

  Future getFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      // multiple: false,
      allowedExtensions: [
        'pdf',
        'txt',
        'ppt',
        'xlsx',
        'json',
        'doc',
        'docx',
        'pptx'
      ],
    );
    if (result != null) {
      setState(() {
        isUploading = true;
      });
      var afterResult;
      var auth = Provider.of<AuthProvider>(context, listen: false);
      var url = Uri.parse('${AppUrls.appBaseUrl}fileupload');
      final file = result.files.single.path.toString();
      final request = http.MultipartRequest('POST', url);
      var stream = http.ByteStream(File(file).openRead());
      var length = await File(file).length();
      var multipartFile =
          http.MultipartFile('file', stream, length, filename: File(file).path);
      request.fields['user_id'] = auth.userId;
      request.fields['accessToken'] = auth.accessToken;
      request.files.add(multipartFile);
      var resp = await request.send();

      resp.stream.transform(utf8.decoder).listen((event) async {
        afterResult = jsonDecode(event);
        fullPath = afterResult['filepath'];
        halfPath = afterResult['path'];
        String fileName = fullPath!.split('/').last;
        fileType = fullPath!.split('.').last;

        setState(() {
          isUploading = false;
        });
        if (rply) {
          print('has Rply');
          String refresh = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DocumentSendingScreen(
                chatType: 'single',
                fPath: afterResult['filepath'],
                hPath: afterResult['path'],
                recId: widget.rId,
                rplyId: replyId.toString(),
                fileName: fileName,
                fileType: fileType!,
              ),
            ),
          );
          if (refresh == 'refresh') {
            setState(() {
              socketFunction();
            });
          }
          setState(() {
            rply = false;
            vwe = false;
          });
        } else {
          print('No Rply');
          String? refresh = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DocumentSendingNoRplyScreen(
                  chatType: 'single',
                  fPath: afterResult['filepath'],
                  hPath: afterResult['path'],
                  recId: widget.rId,
                  fileType: fileType!,
                  fileName: fileName),
            ),
          );
          if (refresh == 'refresh') {
            setState(() {
              Future.delayed(const Duration(microseconds: 5000)).then((value) {
                if (_socket.connected) {
                  // _socket.disconnect();
                  socketFunction();
                } else {
                  print('alredy connected');
                  socketFunction();
                }
              });
            });
          }
          setState(() {
            rply = false;
            vwe = false;
          });
        }
      });
    }
  }

  Future getAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'ogg'],
    );
    if (result != null && result.files.isNotEmpty) {
      var afterResult;
      var auth = Provider.of<AuthProvider>(context, listen: false);
      var url = Uri.parse('${AppUrls.appBaseUrl}fileupload');
      final file = result.files.single.path.toString();
      final request = http.MultipartRequest('POST', url);
      var stream = http.ByteStream(File(file).openRead());
      var length = await File(file).length();
      var multipartFile =
          http.MultipartFile('file', stream, length, filename: File(file).path);
      request.fields['user_id'] = auth.userId;
      request.fields['accessToken'] = auth.accessToken;
      request.files.add(multipartFile);
      var resp = await request.send();

      resp.stream.transform(utf8.decoder).listen((event) async {
        print(event);
        afterResult = jsonDecode(event);
        fullPath = afterResult['filepath'];
        halfPath = afterResult['path'];
        if (rply) {
          print('has Rply');
          String refresh = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AudioSendingScreen(
                chatType: 'single',
                fPath: afterResult['filepath'],
                hPath: afterResult['path'],
                recId: widget.rId,
                rplyId: replyId.toString(),
                fileType: 'voice',
              ),
            ),
          );
          if (refresh == 'refresh') {
            setState(() {
              socketFunction();
            });
          }
          setState(() {
            rply = false;
            vwe = false;
          });
        } else {
          print('No Rply');
          String refresh = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AudioSendingNoRplyScreen(
                chatType: 'single',
                fPath: afterResult['filepath'],
                hPath: afterResult['path'],
                recId: widget.rId,
                fileType: 'image',
              ),
            ),
          );
          if (refresh == 'refresh') {
            setState(() {
              socketFunction();
            });
          }
          setState(() {
            rply = false;
            vwe = false;
          });
        }
      });

      // Use the selected file
    }
  }

  void getAudioUrl(url, id) async {
    if (voicePlay.length > 0 && voicePlay.contains(id)) {
      if (playing) {
        await audioPlayer.pause();
        setState(() {
          playing = false;
        });
      } else {
        await audioPlayer.play(UrlSource(url));
        setState(() {
          playing = true;
        });
      }
    }

    audioPlayer.onDurationChanged.listen((Duration seekDuration) {
      setState(() {
        duration = seekDuration;
      });
    });

    audioPlayer.onPositionChanged.listen((Duration seekPosition) {
      setState(() {
        position = seekPosition;
      });
    });

    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        position = const Duration(
          seconds: 0,
        );
        playing = false;
      });
    });
  }

  Future<void> vedioCallPushMessage(String toFCM, String name) async {
    try {
      http.Response response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'key=AAAAaV_FFUY:APA91bG7a2R2cvCkc84AKqP0sNa5V9rcM0y2CeoMW_IjPBNJBJ3xkw-J5vxADkGkXpyJ7DgL-LRMYUC66RISh2iwF_O1p1p_gDxD6hmnHGpTMifC-jxPla8_lIwf5QRALvAJEIjyCO4N',
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{
            'body': name,
            'title': 'incoming call',
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'type': 'videoCall',
            'fromFCM': await FirebaseMessaging.instance.getToken(),
          },
          'to': toFCM
        }),
      );
      response;
    } catch (e) {
      0;
    }
  }

  Future<void> audioCallPushMessage(String toFCM, String name) async {
    try {
      http.Response response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'key=AAAAaV_FFUY:APA91bG7a2R2cvCkc84AKqP0sNa5V9rcM0y2CeoMW_IjPBNJBJ3xkw-J5vxADkGkXpyJ7DgL-LRMYUC66RISh2iwF_O1p1p_gDxD6hmnHGpTMifC-jxPla8_lIwf5QRALvAJEIjyCO4N',
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{
            'body': name,
            'title': 'incoming call',
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'type': 'audioCall',
            'fromFCM': await FirebaseMessaging.instance.getToken(),
          },
          'to': toFCM
        }),
      );
      response;
    } catch (e) {
      0;
    }
  }

  onTapStarred(message, messageList) {
    if (longPress && messageId.length > 0) {
      if (messageId.contains(message.id)) {
        setState(() {
          messageId.removeWhere((element) => element == message.id);
          onLongDel.remove(message.deleteStatus);
        });
        messageId.forEach((element) {
          messageList.forEach((list) {
            if (element == list.id) {
              if (userId == list.senterId) {
                isDeleteEveryone = true;
              }
              if (userId != list.senterId) {
                isDeleteEveryone = false;
              }
              if (list.starredStatus == '1') {
                setState(() {
                  starred = true;
                });
              } else {
                setState(() {
                  starred = false;
                });
              }
            }
          });
        });
        if (messageId.length == 0) {
          setState(() {
            longPress = false;
          });
        }
      } else {
        setState(() {
          messageId.add(message.id);
          onLongDel.add(message.deleteStatus);
        });
        // if (messageList[index]
        //         .starredStatus ==
        //     '1') {
        //   setState(() {
        //     starred = true;
        //   });
        // } else {
        //   setState(() {
        //     starred = false;
        //   });
        // }
        messageId.forEach((element) {
          messageList.forEach((list) {
            if (element == list.id) {
              if (userId == list.senterId) {
                isDeleteEveryone = true;
              }
              if (userId != list.senterId) {
                isDeleteEveryone = false;
              }

              if (list.starredStatus == '1') {
                setState(() {
                  starred = true;
                });
              } else {
                setState(() {
                  starred = false;
                });
              }
            }
          });
        });
      }
    } else {
      if (message.replayMessage.isNotEmpty) {
        String searchId = message.replayId;
        var searchData =
            messageList.firstWhere((element) => element.id == searchId);
        int goToIdx = messageList.indexOf(searchData);
        itemScrollController.scrollTo(
            index: goToIdx,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
      }

      setState(() {
        longPress = false;
      });
    }
  }

  List<String> onLongDel = [];

  String? copyButtonText;
  longPressStarred(
    message,
  ) {
    setState(() {
      rply = false;
      replyMsg = '';
      replyId = '';
      senderId = '';
      sndName = '';
      msgTyp = '';
    });
    if (message.senterId == userId) {
      isDeleteEveryone = true;
    } else {
      isDeleteEveryone = false;
    }
    if (message.starredStatus == '1') {
      setState(() {
        starred = true;
      });
    } else {
      setState(() {
        starred = false;
      });
    }
    setState(() {
      longPress = true;
      sharedText = message.message;
      if (messageId.contains(message.id)) {
        print('Already Selected');
        messageId.remove(message.id);
        onLongDel.remove(message.deleteStatus);
        if (messageId.isEmpty) {
          longPress = false;
        }
      } else {
        messageId.add(message.id);
        onLongDel.add(message.deleteStatus);
      }
      copyButtonText = message.message.toString();
    });

    print("###############################");
    print(sharedText);
    print("###############################");
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  String formatDuration(Duration duration) {
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds.remainder(60);

    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');

    return '$minutesStr:$secondsStr';
  }

  shareToExternal(value) {
    Share.share(value, subject: "Origin: From SmartStation");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: StreamBuilder(
        stream: streamController.stream,
        builder: (BuildContext context,
            AsyncSnapshot<IndividualChatModel> snapshot) {
          var auth = Provider.of<AuthProvider>(context, listen: false);
          var usp = Provider.of<UserProvider>(context, listen: false);
          var cdp = Provider.of<ChatDetailProvider>(context, listen: false);
          var ftp;

          if (snapshot.hasData) {
            var messageList = snapshot.data!.data.list;
            var messageData = snapshot.data!.data;
            String? displayName;
            phoneContacts.forEach((element) {
              element.phones?.forEach((phone) {
                if (messageData.phoneNumber.replaceAll(' ', '') ==
                    phone.value!.replaceAll(' ', '')) {
                  displayName = element.displayName;
                }
              });
            });

            for (int i = 0; i < messageList.length; i++) {
              if (messageList[i].messageType == 'video') {
                _videoPlayerController =
                    VideoPlayerController.network(messageList[i].message);
              }
            }

            return Scaffold(
              resizeToAvoidBottomInset: true,
              extendBodyBehindAppBar: true,
              appBar: longPress
                  ? AppBar(
                      elevation: 0,
                      backgroundColor: Colors.black26,
                      leadingWidth: 70,
                      leading: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                longPress = !longPress;
                                messageId = [];
                                onLongDel = [];
                              });
                            },
                            child: Row(
                              children: [
                                Text(messageId.length.toString()),
                                const Icon(Icons.arrow_back,
                                    color: Colors.white),
                              ],
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        // callButton(false),
                        // callButton(true),
                        onLongDel.contains('0')
                            ? const SizedBox()
                            : InkWell(
                                onTap: () {
                                  // print(messageId.join(','));

                                  var body = {
                                    'user_id': auth.userId,
                                    'accessToken': auth.accessToken,
                                    'message_id': messageId.join(','),
                                  };
                                  if (starred) {
                                    _socket.emit('unstarred_message', body);
                                    socketFunction();
                                  } else {
                                    _socket.emit('starred_message', body);
                                    socketFunction();
                                  }

                                  setState(() {
                                    longPress = false;
                                    messageId = [];
                                    onLongDel = [];
                                  });
                                },
                                child: SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: //Image(image: AssetImage(phoneIcon)),
                                        starred
                                            ? const Icon(
                                                Icons.star_border_outlined)
                                            : const Icon(Icons.star)),
                              ),

                        const SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Delete message?'),
                                  // content: Text(""),
                                  actions: [
                                    onLongDel.contains('0')
                                        ? const SizedBox()
                                        : isDeleteEveryone
                                            ? TextButton(
                                                child: const Text(
                                                    'Delete from everyone'),
                                                onPressed: () {
                                                  var body = {
                                                    'user_id': auth.userId,
                                                    'accessToken':
                                                        auth.accessToken,
                                                    'id': messageId.join(','),
                                                    'type': 'for_everyone'
                                                  };
                                                  _socket.emit(
                                                      'delete_message', body);
                                                  _socket.on('delete_message',
                                                      (data) {
                                                    print(
                                                        'SSSSSSSSSSSSSSSSSSSSSSSSS');
                                                    print(data);
                                                    print(
                                                        'SSSSSSSSSSSSSSSSSSSSSSSSS');
                                                    socketFunction();
                                                  });
                                                  setState(() {
                                                    longPress = false;
                                                    messageId = [];
                                                    onLongDel = [];
                                                  });
                                                  Navigator.of(context).pop();
                                                },
                                              )
                                            : const SizedBox(),
                                    TextButton(
                                      child: const Text('Delete from me'),
                                      onPressed: () {
                                        var body = {
                                          'user_id': auth.userId,
                                          'accessToken': auth.accessToken,
                                          'id': messageId.join(','),
                                          'type': 'for_one'
                                        };
                                        _socket.emit('delete_message', body);
                                        setState(() {
                                          longPress = false;
                                          messageId = [];
                                          onLongDel = [];
                                        });
                                        Navigator.of(context).pop();
                                        // Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                );
                              },
                            );
                          },
                          child: const SizedBox(
                              height: 30,
                              width: 30,
                              child: //Image(image: AssetImage(videoIcon)),
                                  Icon(Icons.delete)),
                        ),
                        onLongDel.contains('0')
                            ? const SizedBox()
                            : messageId.length == 1
                                ? IconButton(
                                    onPressed: () {
                                      Clipboard.setData(
                                          ClipboardData(text: copyButtonText!));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              50,
                                          content: Center(
                                              child: Text(
                                            'Text copied to clipboard!',
                                            style: const TextStyle(
                                                color: Colors.white),
                                          )),
                                          duration: const Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: const Color.fromRGBO(
                                              0, 0, 0, 0.5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                      );
                                      //            ScaffoldMessenger.of(context).showSnackBar(
                                      // SnackBar(content: Text('Text copied to clipboard!')));
                                    },
                                    icon: const Icon(Icons.copy))
                                : const SizedBox(),
                        onLongDel.contains('0')
                            ? const SizedBox()
                            : IconButton(
                                onPressed: () {
                                  _destroySocket();
                                  // streamController.close();

                                  usp.userList(context: context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ForwardScreen(
                                                messageId: messageId,
                                                rId: widget.rId,
                                              )));
                                },
                                icon: const Icon(
                                  Icons.forward,
                                  color: Colors.white,
                                )),
                        onLongDel.contains('0')
                            ? const SizedBox()
                            : messageId.length == 1
                                ? IconButton(
                                    onPressed: () {
                                      shareToExternal(sharedText);
                                    },
                                    icon: Icon(Icons.share),
                                    color: Colors.white,
                                  )
                                : IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.more_vert,
                                      color: Colors.white,
                                    )),
                      ],
                    )
                  : PreferredSize(
                      preferredSize: const Size.fromHeight(50.0),
                      child: AppBar(
                        backgroundColor: Colors.black26,
                        leadingWidth: 70,
                        elevation: 0,
                        automaticallyImplyLeading: false,
                        leading: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                _destroySocket();
                                Navigator.pop(context, 'refresh');
                              },
                              child: const Icon(Icons.arrow_back),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              // padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 1)),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                    NetworkImage(messageData.profile),
                              ),
                            ),
                          ],
                        ),
                        title: InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ConversationInfo(
                                      receiverId: messageData.id))),
                          child: Row(
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                      width: MediaQuery.of(context).size.width /
                                          2.25,
                                      child: Text(
                                        displayName ?? messageData.name,
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                  Text(
                                    typing
                                        ? 'typing...'
                                        : userStatus == null
                                            ? ''
                                            : '$userStatus',
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          InkWell(
                            child: CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.transparent,
                                child: Image.asset(
                                  phoneIcon,
                                )),
                            onTap: () {
                              audioCallPushMessage(widget.toFcm, auth.username)
                                  .then(
                                (value) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CallingPage(
                                                groupeFCM: const [],
                                                type: '',
                                                toFCM: widget.toFcm,
                                                userName: messageData.name,
                                                profile: messageData.profile,
                                              )));
                                },
                              );
                            },
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          InkWell(
                            child: InkWell(
                                child: CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Colors.transparent,
                                    child: Image.asset(
                                      videoIcon,
                                    ))),
                            onTap: () {
                              vedioCallPushMessage(widget.toFcm, auth.username)
                                  .then(
                                (value) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              VideoCameraRingScreen(
                                                groupeFCM: const [],
                                                type: '',
                                                toFCM: widget.toFcm,
                                                userName: messageData.name,
                                                profile: messageData.profile,
                                              )));
                                },
                              );
                            },
                          ),
                          PopupMenuButton(
                            child: const Icon(Icons.more_vert,
                                color: Colors.white),
                            offset: const Offset(0, 25),
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0))),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                child: Text('View contact'),
                                value: 1,
                              ),
                              const PopupMenuItem(
                                child: Text('Media, links, and docs'),
                                value: 2,
                              ),
                              PopupMenuItem(
                                child: isMuted
                                    ? const Text('Unmute notifications')
                                    : const Text('Mute notifications'),
                                value: 3,
                              ),
                              if (messageData.userBlockStatus == 0)
                                const PopupMenuItem(
                                  child: Text('Report Chat'),
                                  value: 4,
                                ),
                              PopupMenuItem(
                                child: messageData.userBlockStatus == 0
                                    ? const Text('Block Chat')
                                    : const Text('Unblock Chat'),
                                value: 5,
                              ),
                              const PopupMenuItem(
                                child: Text('Clear Chat'),
                                value: 6,
                              ),
                              const PopupMenuItem(
                                child: Text('Export Chat'),
                                value: 7,
                              ),
                            ],
                            onSelected: (value) {
                              switch (value) {
                                case 1:
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ConversationInfo(
                                          receiverId: messageData.id),
                                    ),
                                  );
                                  break;

                                case 2:
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => MediaHome(
                                          recName: messageData.name,
                                          recId: messageData.id)));
                                  break;

                                case 3:
                                  String selectedValue = '';
                                  bool isChecked = false;
                                  isMuted
                                      ? getUnMuteInfo(auth.userId,
                                              auth.accessToken, widget.rId)
                                          .then((value) {
                                          procedureFunction();
                                        })
                                      : showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return StatefulBuilder(
                                              builder: (context, setState) {
                                                return AlertDialog(
                                                  title: const Text(
                                                    'Mute notifications',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 25,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      RadioListTile(
                                                        title: const Text(
                                                          'Mute for 8 hours',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                        value: '8_hours',
                                                        groupValue:
                                                            selectedValue,
                                                        onChanged: (value) {
                                                          print(value);
                                                          setState(() {
                                                            selectedValue =
                                                                value!;
                                                          });
                                                        },
                                                      ),
                                                      RadioListTile(
                                                        title: const Text(
                                                            'Mute for 1 week',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .grey)),
                                                        value: '1_week',
                                                        groupValue:
                                                            selectedValue,
                                                        onChanged: (value) {
                                                          print(value);
                                                          setState(() {
                                                            selectedValue =
                                                                value!;
                                                          });
                                                        },
                                                      ),
                                                      RadioListTile(
                                                        title: const Text(
                                                            'Always',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .grey)),
                                                        value: 'always',
                                                        groupValue:
                                                            selectedValue,
                                                        onChanged: (value) {
                                                          print(value);
                                                          setState(() {
                                                            selectedValue =
                                                                value!;
                                                          });
                                                        },
                                                      ),
                                                      Row(
                                                        children: [
                                                          Checkbox(
                                                            value: isChecked,
                                                            onChanged: (value) {
                                                              print(value);
                                                              setState(() {
                                                                isChecked =
                                                                    value!;
                                                              });
                                                              print(isChecked);
                                                            },
                                                          ),
                                                          const Text(
                                                            'Show notifications',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(),
                                                        child: Text('Cancel',
                                                            style: TextStyle(
                                                                color:
                                                                    textGreen,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 18))),
                                                    if (selectedValue
                                                        .isNotEmpty)
                                                      TextButton(
                                                          onPressed: () {
                                                            getMuteInfo(
                                                                    auth.userId,
                                                                    auth
                                                                        .accessToken,
                                                                    messageData
                                                                        .id,
                                                                    selectedValue,
                                                                    isChecked
                                                                        ? '1'
                                                                        : '0')
                                                                .then((value) {
                                                              if (value
                                                                      .status ==
                                                                  true) {
                                                                procedureFunction();
                                                                Navigator.pop(
                                                                    context);
                                                              }
                                                            });
                                                          },
                                                          child: Text('Ok',
                                                              style: TextStyle(
                                                                  color:
                                                                      textGreen,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize:
                                                                      18))),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        );
                                  break;

                                case 4:
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return AlertDialog(
                                            title: Text(
                                                'Report ${messageData.name}'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    'This contact will not be notified.'),
                                                Text(
                                                    'Clear chats will block this person.',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                    )),
                                                Row(
                                                  children: [
                                                    Checkbox(
                                                      value: isChecked,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          isChecked = value!;
                                                        });
                                                      },
                                                    ),
                                                    Text('Clear all chats?')
                                                  ],
                                                ),
                                              ],
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text('Cancel'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: Text('Report'),
                                                onPressed: () {
                                                  var reportBody = {
                                                    "user_id": auth.userId,
                                                    "accessToken":
                                                        auth.accessToken,
                                                    "receiver_id": widget.rId,
                                                    "clear_status":
                                                        isChecked ? '1' : '0'
                                                  };
                                                  if (_socket.connected) {
                                                    _socket.emit(
                                                        'report_and_block_individual_chat',
                                                        reportBody);
                                                    _socket.on(
                                                        'report_and_block_individual_chat',
                                                        (data) {
                                                      Navigator.of(context)
                                                          .pop();
                                                    });
                                                  } else {
                                                    _socket.connect();
                                                    _socket.emit(
                                                        'report_and_block_individual_chat',
                                                        reportBody);
                                                    _socket.on(
                                                        'report_and_block_individual_chat',
                                                        (data) {
                                                      Navigator.of(context)
                                                          .pop();
                                                    });
                                                  }
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                  break;

                                case 5:
                                  var block_unblockBody = {
                                    'user_id': auth.userId,
                                    'accessToken': auth.accessToken,
                                    'receiver_id': messageData.id
                                  };
                                  var reportBody = {
                                    "user_id": auth.userId,
                                    "accessToken": auth.accessToken,
                                    "receiver_id": widget.rId,
                                    "clear_status": '0'
                                  };
                                  if (messageData.userBlockStatus == 0) {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return StatefulBuilder(
                                          builder: (context, setState) {
                                            return AlertDialog(
                                              title: Text(
                                                  'Are you sure you want to block ${messageData.name}'),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      'This contact will not be notified.'),
                                                  Row(
                                                    children: [
                                                      Checkbox(
                                                        value: isChecked,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            isChecked = value!;
                                                          });
                                                        },
                                                      ),
                                                      Text(
                                                          'Report this contact?')
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text('Cancel'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    if (_socket.connected) {
                                                      if (isChecked) {
                                                        _socket.emit('block',
                                                            block_unblockBody);

                                                        _socket.on('block',
                                                            (data) {
                                                          print(data);
                                                          if (data['message'] ==
                                                              'success') {
                                                            setState(() {
                                                              blockWorks = true;
                                                            });
                                                          } else {
                                                            setState(() {
                                                              blockWorks = true;
                                                            });
                                                          }
                                                          // Navigator.pop(context);
                                                        });

                                                        _socket.emit(
                                                            'report_and_block_individual_chat',
                                                            reportBody);
                                                        _socket.on(
                                                            'report_and_block_individual_chat',
                                                            (data) {
                                                          print(data);
                                                          if (data['message'] ==
                                                              'success') {
                                                            setState(() {
                                                              reportWorks =
                                                                  true;
                                                            });
                                                          } else {
                                                            setState(() {
                                                              reportWorks =
                                                                  true;
                                                            });
                                                          }
                                                        });

                                                        if (blockWorks &&
                                                            reportWorks) {
                                                          Navigator.pop(
                                                              context);
                                                        } else {
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      } else {
                                                        _socket.emit('block',
                                                            block_unblockBody);
                                                        _socket.on('block',
                                                            (data) {
                                                          print(data);
                                                          Navigator.pop(
                                                              context);
                                                        });
                                                      }

                                                      print(
                                                          'From Connected ${isChecked}');
                                                    } else {
                                                      _socket.connect();
                                                      if (isChecked) {
                                                        _socket.emit('block',
                                                            block_unblockBody);

                                                        _socket.on('block',
                                                            (data) {
                                                          print(data);
                                                          if (data['message'] ==
                                                              'success') {
                                                            setState(() {
                                                              blockWorks = true;
                                                            });
                                                          } else {
                                                            setState(() {
                                                              blockWorks = true;
                                                            });
                                                          }
                                                          // Navigator.pop(context);
                                                        });

                                                        _socket.emit(
                                                            'report_and_block_individual_chat',
                                                            reportBody);
                                                        _socket.on(
                                                            'report_and_block_individual_chat',
                                                            (data) {
                                                          print(data);
                                                          if (data['message'] ==
                                                              'success') {
                                                            setState(() {
                                                              reportWorks =
                                                                  true;
                                                            });
                                                          } else {
                                                            setState(() {
                                                              reportWorks =
                                                                  true;
                                                            });
                                                          }
                                                        });

                                                        if (blockWorks &&
                                                            reportWorks) {
                                                          Navigator.pop(
                                                              context);
                                                        } else {
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      } else {
                                                        _socket.emit('block',
                                                            block_unblockBody);
                                                        _socket.on('block',
                                                            (data) {
                                                          print(data);
                                                          Navigator.pop(
                                                              context);
                                                        });
                                                      }
                                                      print(
                                                          'From Connected ${isChecked}');
                                                    }
                                                  },
                                                  child: Text('Block'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    );
                                  }
                                  break;

                                case 6:
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return AlertDialog(
                                            title: Text('Clear Chat'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    'All chats will be lost an not able to restore.'),
                                                Row(
                                                  children: [
                                                    Checkbox(
                                                      value: isChecked,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          isChecked = value!;
                                                        });
                                                      },
                                                    ),
                                                    Text(
                                                        'Clear starred messages?')
                                                  ],
                                                ),
                                              ],
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text('Close'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: Text('Clear chat'),
                                                onPressed: () {
                                                  var clearBody = {
                                                    'user_id': auth.userId,
                                                    'accessToken':
                                                        auth.accessToken,
                                                    'receiver_id': widget.rId,
                                                    'delete_starred_message':
                                                        isChecked ? '1' : '0'
                                                  };
                                                  if (_socket.connected) {
                                                    _socket.emit(
                                                        'clear_individual_chat',
                                                        clearBody);
                                                    _socket.on(
                                                        'clear_individual_chat',
                                                        (data) {
                                                      Navigator.of(context)
                                                          .pop();
                                                    });
                                                  } else {
                                                    _socket.connect();
                                                    _socket.emit(
                                                        'clear_individual_chat',
                                                        clearBody);
                                                    _socket.on(
                                                        'clear_individual_chat',
                                                        (data) {
                                                      Navigator.of(context)
                                                          .pop();
                                                    });
                                                  }
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                  break;

                                case 7:
                                  var body = {
                                    'user_id': auth.userId,
                                    'accessToken': auth.accessToken,
                                    'receiver_id': widget.rId
                                  };
                                  if (_socket.connected) {
                                    _socket.on('private_chat_export_data',
                                        (data) {
                                      String exportData =
                                          jsonEncode(data['data']);
                                      exportChat(exportData);
                                    });
                                    _socket.emit(
                                        'private_chat_export_data', body);
                                  }

                                  // exportChat(data);

                                  break;
                              }
                            },
                          )
                        ],
                      ),
                    ),
              body: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(splashBg), fit: BoxFit.fill)),
                child: isUploading
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SpinKitFadingCircle(color: textGreen, size: 24),
                          const Text('Uploading file Please wait',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.italic,
                              )),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .11,
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: ScrollablePositionedList.builder(
                                initialScrollIndex: messageList.length,
                                //shrinkWrap: true,
                                // physics: const PageScrollPhysics(),
                                itemScrollController: itemScrollController,
                                itemPositionsListener: itemPositionsListener,
                                itemCount: messageList.length,
                                key: PageStorageKey(messageList.length),
                                itemBuilder: (context, index) {
                                  // if (messageList[index].messageType == "video") {
                                  //   _videoPlayerController = VideoPlayerController.network(messageList[index].message);
                                  // }
                                  final now = new DateTime.now();
                                  String formatter =
                                      DateFormat('dd/MM/yyyy hh:mm a')
                                          .format(now);
                                  DateTime dateTime = messageList[index].date;
                                  String formattedDate =
                                      dateFormat2.format(dateTime);

                                  if (messageList[index].messageType ==
                                      'date') if (formatter.substring(
                                          0, 10) ==
                                      formattedDate.substring(0, 10))
                                    return Column(
                                      children: [
                                        Center(
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                                color: const Color(0xff63d982),
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            child: const Text(
                                              'Today',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    );
                                  else
                                    return Column(
                                      children: [
                                        Center(
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                                color: const Color(0xff63d982),
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            child: Text(
                                              formattedDate.substring(0, 10),
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    );

                                  if (messageList[index].messageType ==
                                          'notification' &&
                                      messageList[index].type == 'notification')
                                    return Column(
                                      children: [
                                        if (messageList[index].message ==
                                            'You blocked this contact. Tap to unblock.')
                                          Center(
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xff63d982),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Text(
                                                    'You blocked this contact.',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      print('Tapped');
                                                      var auth = Provider.of<
                                                              AuthProvider>(
                                                          context,
                                                          listen: false);
                                                      if (_socket.connected) {
                                                        var body = {
                                                          'user_id':
                                                              auth.userId,
                                                          'accessToken':
                                                              auth.accessToken,
                                                          'receiver_id':
                                                              messageData.id
                                                        };
                                                        _socket.emit(
                                                            'unblock', body);
                                                        _socket.on('unblock',
                                                            (data) {
                                                          if (data['message'] ==
                                                              'success') {
                                                            socketFunction();
                                                          }
                                                        });
                                                      } else {
                                                        _socket.connect();
                                                        var body = {
                                                          'user_id':
                                                              auth.userId,
                                                          'accessToken':
                                                              auth.accessToken,
                                                          'receiver_id':
                                                              messageData.id
                                                        };
                                                        _socket.emit(
                                                            'unblock', body);
                                                        _socket.on('unblock',
                                                            (data) {
                                                          if (data['message'] ==
                                                              'success') {
                                                            socketFunction();
                                                          }
                                                        });
                                                      }
                                                    },
                                                    child: const Text(
                                                      ' Tap to unblock.',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        if (messageList[index].message ==
                                            'You unblocked this contact.')
                                          Center(
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xff63d982),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                              child: Text(
                                                messageList[index].message,
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        const SizedBox(height: 8),
                                      ],
                                    );

                                  if (messageList[index].senterId ==
                                      auth.userId) {
                                    isSender = true;
                                    if (messageList[index].messageType ==
                                        'location') {
                                      return messageList[index].deleteStatus ==
                                              '0'
                                          ? InkWell(
                                              onLongPress: () {
                                                longPressStarred(
                                                    messageList[index]);
                                              },
                                              onTap: () {
                                                onTapStarred(messageList[index],
                                                    messageList);
                                              },
                                              child: Container(
                                                color: messageId.contains(
                                                        messageList[index].id)
                                                    ? Colors.black38
                                                    : const Color.fromARGB(
                                                        0, 0, 0, 0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 3),
                                                      child: Container(
                                                        color:
                                                            Colors.transparent,
                                                        constraints: BoxConstraints(
                                                            maxWidth: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .8),
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 16,
                                                                vertical: 2),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      3),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: messageList[
                                                                            index]
                                                                        .messageStatus !=
                                                                    '1'
                                                                ? rightGreen
                                                                : Colors.blue,
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .only(
                                                              topLeft: Radius
                                                                  .circular(15),
                                                              topRight: Radius
                                                                  .circular(15),
                                                              bottomLeft: Radius
                                                                  .circular(15),
                                                            ),
                                                          ),
                                                          child: messageList[
                                                                          index]
                                                                      .deleteStatus ==
                                                                  '0'
                                                              ? Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(8),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      const Icon(
                                                                          Icons
                                                                              .block,
                                                                          color:
                                                                              Colors.white),
                                                                      Text(
                                                                        messageList[index]
                                                                            .message,
                                                                        style:
                                                                            const TextStyle(
                                                                          fontStyle:
                                                                              FontStyle.italic,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                )
                                                              : Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Flexible(
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () async {
                                                                          String
                                                                              googleMapsUrl =
                                                                              'https://www.google.com/maps/search/?api=1&query=${messageList[index].message}';
                                                                          if (await canLaunch(
                                                                              googleMapsUrl)) {
                                                                            await launch(googleMapsUrl);
                                                                          } else {
                                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                              SnackBar(
                                                                                content: Text('Could not launch $googleMapsUrl'),
                                                                              ),
                                                                            );
                                                                          }
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          padding:
                                                                              const EdgeInsets.all(8),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color: messageList[index].messageStatus != '1'
                                                                                ? rightGreen
                                                                                : Colors.blue,
                                                                            borderRadius:
                                                                                const BorderRadius.only(
                                                                              topLeft: Radius.circular(10),
                                                                              topRight: Radius.circular(10),
                                                                              bottomLeft: Radius.circular(10),
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.end,
                                                                            children: [
                                                                              Container(
                                                                                color: rightGreen,
                                                                                height: 200,
                                                                                width: 300,
                                                                                child: GoogleMap(
                                                                                  myLocationButtonEnabled: false,
                                                                                  zoomControlsEnabled: false,
                                                                                  mapType: MapType.hybrid,
                                                                                  onMapCreated: _onMapCreated,
                                                                                  initialCameraPosition: CameraPosition(
                                                                                    target: LatLng(double.parse(messageList[index].message.split(',').first), double.parse(messageList[index].message.split(',').last)),
                                                                                    zoom: 15,
                                                                                  ),
                                                                                  onTap: (argument) async {
                                                                                    String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=${messageList[index].message}';
                                                                                    if (await canLaunch(googleMapsUrl)) {
                                                                                      await launch(googleMapsUrl);
                                                                                    } else {
                                                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                                                        SnackBar(
                                                                                          content: Text('Could not launch $googleMapsUrl'),
                                                                                        ),
                                                                                      );
                                                                                    }
                                                                                  },
                                                                                ),
                                                                              ),
                                                                              const SizedBox(height: 3),
                                                                              Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: [
                                                                                  messageList[index].starredStatus == '1'
                                                                                      ? const Icon(
                                                                                          Icons.star,
                                                                                          size: 10,
                                                                                          color: Colors.amber,
                                                                                        )
                                                                                      : const SizedBox(),
                                                                                  Text(
                                                                                    formattedDate.substring(11, 19),
                                                                                    style: const TextStyle(
                                                                                      color: Colors.white,
                                                                                      fontSize: 10,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            3),
                                                                    Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        messageList[index].starredStatus ==
                                                                                '1'
                                                                            ? const Icon(
                                                                                Icons.star,
                                                                                size: 10,
                                                                                color: Colors.amber,
                                                                              )
                                                                            : const SizedBox(),
                                                                        Text(
                                                                          formattedDate.substring(
                                                                              11,
                                                                              19),
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize:
                                                                                10,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                          : SwipeTo(
                                              onLeftSwipe: () {
                                                print(
                                                    "________________---deleteStatus-----------------________");
                                                print(messageList[index]
                                                    .deleteStatus);
                                                if (messageList[index]
                                                        .deleteStatus ==
                                                    '1') {
                                                  getValue(
                                                      messageList[index].id,
                                                      messageList[index]
                                                          .message,
                                                      messageList[index]
                                                          .senterId,
                                                      messageData.name,
                                                      messageList[index]
                                                          .messageType);
                                                }
                                              },
                                              child: InkWell(
                                                onLongPress: () {
                                                  longPressStarred(
                                                      messageList[index]);
                                                },
                                                onTap: () {
                                                  onTapStarred(
                                                      messageList[index],
                                                      messageList);
                                                },
                                                child: Container(
                                                  color: messageId.contains(
                                                          messageList[index].id)
                                                      ? Colors.black38
                                                      : const Color.fromARGB(
                                                          0, 0, 0, 0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 3),
                                                        child: Container(
                                                          color: Colors
                                                              .transparent,
                                                          constraints: BoxConstraints(
                                                              maxWidth: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  .8),
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      16,
                                                                  vertical: 2),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        3),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: messageList[
                                                                              index]
                                                                          .messageStatus !=
                                                                      '1'
                                                                  ? rightGreen
                                                                  : Colors.blue,
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        15),
                                                                topRight: Radius
                                                                    .circular(
                                                                        15),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        15),
                                                              ),
                                                            ),
                                                            child: messageList[
                                                                            index]
                                                                        .deleteStatus ==
                                                                    '0'
                                                                ? Container(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(8),
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        const Icon(
                                                                            Icons
                                                                                .block,
                                                                            color:
                                                                                Colors.white),
                                                                        Text(
                                                                          messageList[index]
                                                                              .message,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontStyle:
                                                                                FontStyle.italic,
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  )
                                                                : Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      Flexible(
                                                                        child:
                                                                            InkWell(
                                                                          onTap:
                                                                              () async {
                                                                            String
                                                                                googleMapsUrl =
                                                                                'https://www.google.com/maps/search/?api=1&query=${messageList[index].message}';
                                                                            if (await canLaunch(googleMapsUrl)) {
                                                                              await launch(googleMapsUrl);
                                                                            } else {
                                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                                SnackBar(
                                                                                  content: Text('Could not launch $googleMapsUrl'),
                                                                                ),
                                                                              );
                                                                            }
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            padding:
                                                                                const EdgeInsets.all(8),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: messageList[index].messageStatus != '1' ? rightGreen : Colors.blue,
                                                                              borderRadius: const BorderRadius.only(
                                                                                topLeft: Radius.circular(10),
                                                                                topRight: Radius.circular(10),
                                                                                bottomLeft: Radius.circular(10),
                                                                              ),
                                                                            ),
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                                              children: [
                                                                                Container(
                                                                                  color: rightGreen,
                                                                                  height: 200,
                                                                                  width: 300,
                                                                                  child: GoogleMap(
                                                                                    myLocationButtonEnabled: false,
                                                                                    zoomControlsEnabled: false,
                                                                                    mapType: MapType.hybrid,
                                                                                    onMapCreated: _onMapCreated,
                                                                                    initialCameraPosition: CameraPosition(
                                                                                      target: LatLng(double.parse(messageList[index].message.split(',').first), double.parse(messageList[index].message.split(',').last)),
                                                                                      zoom: 15,
                                                                                    ),
                                                                                    onTap: (argument) async {
                                                                                      String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=${messageList[index].message}';
                                                                                      if (await canLaunch(googleMapsUrl)) {
                                                                                        await launch(googleMapsUrl);
                                                                                      } else {
                                                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                                                          SnackBar(
                                                                                            content: Text('Could not launch $googleMapsUrl'),
                                                                                          ),
                                                                                        );
                                                                                      }
                                                                                    },
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(height: 3),
                                                                                Row(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  children: [
                                                                                    messageList[index].starredStatus == '1'
                                                                                        ? const Icon(
                                                                                            Icons.star,
                                                                                            size: 10,
                                                                                            color: Colors.amber,
                                                                                          )
                                                                                        : const SizedBox(),
                                                                                    Text(
                                                                                      formattedDate.substring(11, 19),
                                                                                      style: const TextStyle(
                                                                                        color: Colors.white,
                                                                                        fontSize: 10,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              3),
                                                                      Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        children: [
                                                                          messageList[index].starredStatus == '1'
                                                                              ? const Icon(
                                                                                  Icons.star,
                                                                                  size: 10,
                                                                                  color: Colors.amber,
                                                                                )
                                                                              : const SizedBox(),
                                                                          Text(
                                                                            formattedDate.substring(11,
                                                                                19),
                                                                            style:
                                                                                const TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 10,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                    }
                                    if (messageList[index].messageType !=
                                        'voice') {
                                      return messageList[index].deleteStatus ==
                                              '0'
                                          ? InkWell(
                                              onLongPress: () {
                                                print(
                                                    "______________________-----------messageType--------------------");
                                                print(messageList[index]
                                                    .messageType);
                                                longPressStarred(
                                                    messageList[index]);
                                              },
                                              onTap: () {
                                                onTapStarred(messageList[index],
                                                    messageList);
                                              },
                                              child: Container(
                                                color: messageId.contains(
                                                        messageList[index].id)
                                                    ? Colors.black38
                                                    : const Color.fromARGB(
                                                        0, 0, 0, 0),
                                                child: CustomBubble(
                                                  text: messageList[index]
                                                      .message,
                                                  thumbNail: messageList[index]
                                                      .thumbnail,
                                                  messageType:
                                                      messageList[index]
                                                          .messageType,
                                                  optionalText:
                                                      messageList[index]
                                                          .optionalText,
                                                  rplyMsg: messageList[index]
                                                              .replayMessage !=
                                                          ''
                                                      ? messageList[index]
                                                          .replayMessage
                                                      : '',
                                                  rplyMsgType: messageList[
                                                                  index]
                                                              .replayMessageType !=
                                                          ''
                                                      ? messageList[index]
                                                          .replayMessageType
                                                      : '',
                                                  rplyMsgSenter: messageList[
                                                                  index]
                                                              .replaySenter !=
                                                          ''
                                                      ? messageList[index]
                                                          .replaySenter
                                                      : '',
                                                  textStyle: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                  time: messageList[index].date,
                                                  isDeleted: messageList[index]
                                                              .deleteStatus ==
                                                          '0'
                                                      ? true
                                                      : false,
                                                  isStarred: messageList[index]
                                                              .starredStatus ==
                                                          '1'
                                                      ? true
                                                      : false,
                                                  color: messageList[index]
                                                              .messageStatus !=
                                                          '1'
                                                      ? rightGreen
                                                      : Colors.blue,
                                                  rplyColor: messageList[index]
                                                              .messageStatus !=
                                                          '1'
                                                      ? Colors.green.shade900
                                                      : Colors.blue.shade900,
                                                  isSender: isSender,
                                                  forwardStatus:
                                                      messageList[index]
                                                          .forwardMessageStatus,
                                                ),
                                              ),
                                            )
                                          : SwipeTo(
                                              onLeftSwipe: () {
                                                print(
                                                    "________________---deleteStatus-----------------________");
                                                print(messageList[index]
                                                    .deleteStatus);
                                                if (messageList[index]
                                                        .deleteStatus ==
                                                    '1') {
                                                  getValue(
                                                      messageList[index].id,
                                                      messageList[index]
                                                          .message,
                                                      messageList[index]
                                                          .senterId,
                                                      messageData.name,
                                                      messageList[index]
                                                          .messageType);
                                                }
                                              },
                                              child: InkWell(
                                                onLongPress: () {
                                                  print(
                                                      "______________________-----------messageType--------------------");
                                                  print(messageList[index]
                                                      .messageType);
                                                  longPressStarred(
                                                      messageList[index]);
                                                },
                                                onTap: () {
                                                  onTapStarred(
                                                      messageList[index],
                                                      messageList);
                                                },
                                                child: Container(
                                                  color: messageId.contains(
                                                          messageList[index].id)
                                                      ? Colors.black38
                                                      : const Color.fromARGB(
                                                          0, 0, 0, 0),
                                                  child: CustomBubble(
                                                    text: messageList[index]
                                                        .message,
                                                    thumbNail:
                                                        messageList[index]
                                                            .thumbnail,
                                                    messageType:
                                                        messageList[index]
                                                            .messageType,
                                                    optionalText:
                                                        messageList[index]
                                                            .optionalText,
                                                    rplyMsg: messageList[index]
                                                                .replayMessage !=
                                                            ''
                                                        ? messageList[index]
                                                            .replayMessage
                                                        : '',
                                                    rplyMsgType: messageList[
                                                                    index]
                                                                .replayMessageType !=
                                                            ''
                                                        ? messageList[index]
                                                            .replayMessageType
                                                        : '',
                                                    rplyMsgSenter: messageList[
                                                                    index]
                                                                .replaySenter !=
                                                            ''
                                                        ? messageList[index]
                                                            .replaySenter
                                                        : '',
                                                    textStyle: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                    time:
                                                        messageList[index].date,
                                                    isDeleted: messageList[
                                                                    index]
                                                                .deleteStatus ==
                                                            '0'
                                                        ? true
                                                        : false,
                                                    isStarred: messageList[
                                                                    index]
                                                                .starredStatus ==
                                                            '1'
                                                        ? true
                                                        : false,
                                                    color: messageList[index]
                                                                .messageStatus !=
                                                            '1'
                                                        ? rightGreen
                                                        : Colors.blue,
                                                    rplyColor: messageList[
                                                                    index]
                                                                .messageStatus !=
                                                            '1'
                                                        ? Colors.green.shade900
                                                        : Colors.blue.shade900,
                                                    isSender: isSender,
                                                    forwardStatus: messageList[
                                                            index]
                                                        .forwardMessageStatus,
                                                  ),
                                                ),
                                              ),
                                              // ),
                                            );
                                    } else {
                                      return messageList[index].deleteStatus ==
                                              '0'
                                          ? InkWell(
                                              onLongPress: () {
                                                longPressStarred(
                                                    messageList[index]);
                                              },
                                              onTap: () {
                                                onTapStarred(messageList[index],
                                                    messageList);
                                              },
                                              child: Container(
                                                color: messageId.contains(
                                                        messageList[index].id)
                                                    ? Colors.black38
                                                    : const Color.fromARGB(
                                                        0, 0, 0, 0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    if (messageList[index]
                                                            .messageStatus ==
                                                        "2")
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 3),
                                                        child: Container(
                                                          color: Colors
                                                              .transparent,
                                                          constraints: BoxConstraints(
                                                              maxWidth: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  .8),
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      16,
                                                                  vertical: 2),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        4),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: rightGreen,
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        15),
                                                                topRight: Radius
                                                                    .circular(
                                                                        15),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        15),
                                                              ),
                                                            ),
                                                            child: messageList[
                                                                            index]
                                                                        .deleteStatus ==
                                                                    '0'
                                                                ? Container(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(8),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        const Icon(
                                                                            Icons
                                                                                .block,
                                                                            color:
                                                                                Colors.white),
                                                                        Text(
                                                                          messageList[index]
                                                                              .message,
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontStyle:
                                                                                FontStyle.italic,
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  )
                                                                : Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      Flexible(
                                                                        child:
                                                                            Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.end,
                                                                          children: [
                                                                            Flexible(
                                                                                child: InkWell(
                                                                              onTap: () {
                                                                                print("TTTTTTTTTTTTTTTt");
                                                                                print(duration.inSeconds);
                                                                                print("TTTTTTTTTTTTTTTt");
                                                                                if (voicePlay.length == 0) {
                                                                                  setState(() {
                                                                                    voicePlay.add(messageList[index].id);
                                                                                  });
                                                                                } else {
                                                                                  voicePlay.forEach((element) {
                                                                                    if (element != messageList[index].id) {
                                                                                      setState(() {
                                                                                        voicePlay = [];
                                                                                        voicePlay.add(messageList[index].id);
                                                                                      });
                                                                                    }
                                                                                  });
                                                                                }

                                                                                getAudioUrl(messageList[index].message, messageList[index].id);
                                                                              },
                                                                              child: voicePlay.contains(messageList[index].id) && playing ? const Icon(Icons.pause_circle_outline, color: Colors.white) : const Icon(Icons.play_circle_outline, color: Colors.white),
                                                                            )),
                                                                            voicePlay.contains(messageList[index].id)
                                                                                ? slider()
                                                                                : sliderDummy(),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              3),
                                                                      Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        children: [
                                                                          messageList[index].starredStatus == '1'
                                                                              ? const Icon(
                                                                                  Icons.star,
                                                                                  size: 10,
                                                                                  color: Colors.amber,
                                                                                )
                                                                              : const SizedBox(),
                                                                          Text(
                                                                            formattedDate.substring(11,
                                                                                19),
                                                                            style:
                                                                                const TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 10,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                          ),
                                                        ),
                                                      ),
                                                    if (messageList[index]
                                                            .messageStatus ==
                                                        "1")
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 3),
                                                        child: Container(
                                                          color: Colors
                                                              .transparent,
                                                          constraints: BoxConstraints(
                                                              maxWidth: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  .8),
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      16,
                                                                  vertical: 2),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        4),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: rightGreen,
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        15),
                                                                topRight: Radius
                                                                    .circular(
                                                                        15),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        15),
                                                              ),
                                                            ),
                                                            child: messageList[
                                                                            index]
                                                                        .deleteStatus ==
                                                                    '0'
                                                                ? Container(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(8),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        const Icon(
                                                                            Icons
                                                                                .block,
                                                                            color:
                                                                                Colors.white),
                                                                        Text(
                                                                          messageList[index]
                                                                              .message,
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontStyle:
                                                                                FontStyle.italic,
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  )
                                                                : Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      Flexible(
                                                                        child:
                                                                            Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.end,
                                                                          children: [
                                                                            Flexible(
                                                                                child: InkWell(
                                                                              onTap: () {
                                                                                print("TTTTTTTTTTTTTTTt");
                                                                                print(duration.inSeconds);
                                                                                print("TTTTTTTTTTTTTTTt");
                                                                                if (voicePlay.length == 0) {
                                                                                  setState(() {
                                                                                    voicePlay.add(messageList[index].id);
                                                                                  });
                                                                                } else {
                                                                                  voicePlay.forEach((element) {
                                                                                    if (element != messageList[index].id) {
                                                                                      setState(() {
                                                                                        voicePlay = [];
                                                                                        voicePlay.add(messageList[index].id);
                                                                                      });
                                                                                    }
                                                                                  });
                                                                                }

                                                                                getAudioUrl(messageList[index].message, messageList[index].id);
                                                                              },
                                                                              child: voicePlay.contains(messageList[index].id) && playing ? const Icon(Icons.pause_circle_outline, color: Colors.white) : const Icon(Icons.play_circle_outline, color: Colors.white),
                                                                            )),
                                                                            voicePlay.contains(messageList[index].id)
                                                                                ? slider()
                                                                                : sliderDummy(),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              3),
                                                                      Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        children: [
                                                                          messageList[index].starredStatus == '1'
                                                                              ? const Icon(
                                                                                  Icons.star,
                                                                                  size: 10,
                                                                                  color: Colors.amber,
                                                                                )
                                                                              : const SizedBox(),
                                                                          Text(
                                                                            formattedDate.substring(11,
                                                                                19),
                                                                            style:
                                                                                const TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 10,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                          ),
                                                        ),
                                                      ),
                                                    if (messageList[index]
                                                            .messageStatus ==
                                                        "0")
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 3),
                                                        child: Container(
                                                          color: Colors
                                                              .transparent,
                                                          constraints: BoxConstraints(
                                                              maxWidth: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  .8),
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      16,
                                                                  vertical: 2),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        4),
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.blue,
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        15),
                                                                topRight: Radius
                                                                    .circular(
                                                                        15),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        15),
                                                              ),
                                                            ),
                                                            child: messageList[
                                                                            index]
                                                                        .deleteStatus ==
                                                                    '0'
                                                                ? Container(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(8),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        const Icon(
                                                                            Icons
                                                                                .block,
                                                                            color:
                                                                                Colors.white),
                                                                        Text(
                                                                          messageList[index]
                                                                              .message,
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontStyle:
                                                                                FontStyle.italic,
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  )
                                                                : Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      Flexible(
                                                                        child:
                                                                            Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.end,
                                                                          children: [
                                                                            Flexible(
                                                                                child: InkWell(
                                                                              onTap: () {
                                                                                print("TTTTTTTTTTTTTTTt");
                                                                                print(duration.inSeconds);
                                                                                print("TTTTTTTTTTTTTTTt");
                                                                                if (voicePlay.length == 0) {
                                                                                  setState(() {
                                                                                    voicePlay.add(messageList[index].id);
                                                                                  });
                                                                                } else {
                                                                                  voicePlay.forEach((element) {
                                                                                    if (element != messageList[index].id) {
                                                                                      setState(() {
                                                                                        voicePlay = [];
                                                                                        voicePlay.add(messageList[index].id);
                                                                                      });
                                                                                    }
                                                                                  });
                                                                                }

                                                                                getAudioUrl(messageList[index].message, messageList[index].id);
                                                                              },
                                                                              child: voicePlay.contains(messageList[index].id) && playing ? const Icon(Icons.pause_circle_outline, color: Colors.white) : const Icon(Icons.play_circle_outline, color: Colors.white),
                                                                            )),
                                                                            voicePlay.contains(messageList[index].id)
                                                                                ? slider()
                                                                                : sliderDummy(),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              3),
                                                                      Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        children: [
                                                                          messageList[index].starredStatus == '1'
                                                                              ? const Icon(
                                                                                  Icons.star,
                                                                                  size: 10,
                                                                                  color: Colors.amber,
                                                                                )
                                                                              : const SizedBox(),
                                                                          Text(
                                                                            formattedDate.substring(11,
                                                                                19),
                                                                            style:
                                                                                const TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 10,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : SwipeTo(
                                              onLeftSwipe: () {
                                                print(
                                                    "________________---deleteStatus-----------------________");
                                                print(messageList[index]
                                                    .deleteStatus);
                                                if (messageList[index]
                                                        .deleteStatus ==
                                                    '1') {
                                                  getValue(
                                                      messageList[index].id,
                                                      messageList[index]
                                                          .message,
                                                      messageList[index]
                                                          .senterId,
                                                      messageData.name,
                                                      messageList[index]
                                                          .messageType);
                                                }
                                              },
                                              child: InkWell(
                                                onLongPress: () {
                                                  longPressStarred(
                                                      messageList[index]);
                                                },
                                                onTap: () {
                                                  onTapStarred(
                                                      messageList[index],
                                                      messageList);
                                                },
                                                child: Container(
                                                  color: messageId.contains(
                                                          messageList[index].id)
                                                      ? Colors.black38
                                                      : const Color.fromARGB(
                                                          0, 0, 0, 0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      if (messageList[index]
                                                              .messageStatus ==
                                                          "2")
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      3),
                                                          child: Container(
                                                            color: Colors
                                                                .transparent,
                                                            constraints: BoxConstraints(
                                                                maxWidth: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    .8),
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        2),
                                                            child: Container(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      4),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color:
                                                                    rightGreen,
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          15),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          15),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          15),
                                                                ),
                                                              ),
                                                              child: messageList[
                                                                              index]
                                                                          .deleteStatus ==
                                                                      '0'
                                                                  ? Container(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          const Icon(
                                                                              Icons.block,
                                                                              color: Colors.white),
                                                                          Text(
                                                                            messageList[index].message,
                                                                            style:
                                                                                const TextStyle(
                                                                              color: Colors.white,
                                                                              fontStyle: FontStyle.italic,
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        Flexible(
                                                                          child:
                                                                              Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            children: [
                                                                              Flexible(
                                                                                  child: InkWell(
                                                                                onTap: () {
                                                                                  print("TTTTTTTTTTTTTTTt");
                                                                                  print(duration.inSeconds);
                                                                                  print("TTTTTTTTTTTTTTTt");
                                                                                  if (voicePlay.length == 0) {
                                                                                    setState(() {
                                                                                      voicePlay.add(messageList[index].id);
                                                                                    });
                                                                                  } else {
                                                                                    voicePlay.forEach((element) {
                                                                                      if (element != messageList[index].id) {
                                                                                        setState(() {
                                                                                          voicePlay = [];
                                                                                          voicePlay.add(messageList[index].id);
                                                                                        });
                                                                                      }
                                                                                    });
                                                                                  }

                                                                                  getAudioUrl(messageList[index].message, messageList[index].id);
                                                                                },
                                                                                child: voicePlay.contains(messageList[index].id) && playing ? const Icon(Icons.pause_circle_outline, color: Colors.white) : const Icon(Icons.play_circle_outline, color: Colors.white),
                                                                              )),
                                                                              voicePlay.contains(messageList[index].id) ? slider() : sliderDummy(),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                3),
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.end,
                                                                          children: [
                                                                            messageList[index].starredStatus == '1'
                                                                                ? const Icon(
                                                                                    Icons.star,
                                                                                    size: 10,
                                                                                    color: Colors.amber,
                                                                                  )
                                                                                : const SizedBox(),
                                                                            Text(
                                                                              formattedDate.substring(11, 19),
                                                                              style: const TextStyle(
                                                                                color: Colors.white,
                                                                                fontSize: 10,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      ],
                                                                    ),
                                                            ),
                                                          ),
                                                        ),
                                                      if (messageList[index]
                                                              .messageStatus ==
                                                          "1")
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      3),
                                                          child: Container(
                                                            color: Colors
                                                                .transparent,
                                                            constraints: BoxConstraints(
                                                                maxWidth: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    .8),
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        2),
                                                            child: Container(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      4),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color:
                                                                    rightGreen,
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          15),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          15),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          15),
                                                                ),
                                                              ),
                                                              child: messageList[
                                                                              index]
                                                                          .deleteStatus ==
                                                                      '0'
                                                                  ? Container(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          const Icon(
                                                                              Icons.block,
                                                                              color: Colors.white),
                                                                          Text(
                                                                            messageList[index].message,
                                                                            style:
                                                                                const TextStyle(
                                                                              color: Colors.white,
                                                                              fontStyle: FontStyle.italic,
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        Flexible(
                                                                          child:
                                                                              Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            children: [
                                                                              Flexible(
                                                                                  child: InkWell(
                                                                                onTap: () {
                                                                                  print("TTTTTTTTTTTTTTTt");
                                                                                  print(duration.inSeconds);
                                                                                  print("TTTTTTTTTTTTTTTt");
                                                                                  if (voicePlay.length == 0) {
                                                                                    setState(() {
                                                                                      voicePlay.add(messageList[index].id);
                                                                                    });
                                                                                  } else {
                                                                                    voicePlay.forEach((element) {
                                                                                      if (element != messageList[index].id) {
                                                                                        setState(() {
                                                                                          voicePlay = [];
                                                                                          voicePlay.add(messageList[index].id);
                                                                                        });
                                                                                      }
                                                                                    });
                                                                                  }

                                                                                  getAudioUrl(messageList[index].message, messageList[index].id);
                                                                                },
                                                                                child: voicePlay.contains(messageList[index].id) && playing ? const Icon(Icons.pause_circle_outline, color: Colors.white) : const Icon(Icons.play_circle_outline, color: Colors.white),
                                                                              )),
                                                                              voicePlay.contains(messageList[index].id) ? slider() : sliderDummy(),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                3),
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.end,
                                                                          children: [
                                                                            messageList[index].starredStatus == '1'
                                                                                ? const Icon(
                                                                                    Icons.star,
                                                                                    size: 10,
                                                                                    color: Colors.amber,
                                                                                  )
                                                                                : const SizedBox(),
                                                                            Text(
                                                                              formattedDate.substring(11, 19),
                                                                              style: const TextStyle(
                                                                                color: Colors.white,
                                                                                fontSize: 10,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      ],
                                                                    ),
                                                            ),
                                                          ),
                                                        ),
                                                      if (messageList[index]
                                                              .messageStatus ==
                                                          "0")
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      3),
                                                          child: Container(
                                                            color: Colors
                                                                .transparent,
                                                            constraints: BoxConstraints(
                                                                maxWidth: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    .8),
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        2),
                                                            child: Container(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      4),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color:
                                                                    Colors.blue,
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          15),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          15),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          15),
                                                                ),
                                                              ),
                                                              child: messageList[
                                                                              index]
                                                                          .deleteStatus ==
                                                                      '0'
                                                                  ? Container(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          const Icon(
                                                                              Icons.block,
                                                                              color: Colors.white),
                                                                          Text(
                                                                            messageList[index].message,
                                                                            style:
                                                                                const TextStyle(
                                                                              color: Colors.white,
                                                                              fontStyle: FontStyle.italic,
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        Flexible(
                                                                          child:
                                                                              Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            children: [
                                                                              Flexible(
                                                                                  child: InkWell(
                                                                                onTap: () {
                                                                                  print("TTTTTTTTTTTTTTTt");
                                                                                  print(duration.inSeconds);
                                                                                  print("TTTTTTTTTTTTTTTt");
                                                                                  if (voicePlay.length == 0) {
                                                                                    setState(() {
                                                                                      voicePlay.add(messageList[index].id);
                                                                                    });
                                                                                  } else {
                                                                                    voicePlay.forEach((element) {
                                                                                      if (element != messageList[index].id) {
                                                                                        setState(() {
                                                                                          voicePlay = [];
                                                                                          voicePlay.add(messageList[index].id);
                                                                                        });
                                                                                      }
                                                                                    });
                                                                                  }

                                                                                  getAudioUrl(messageList[index].message, messageList[index].id);
                                                                                },
                                                                                child: voicePlay.contains(messageList[index].id) && playing ? const Icon(Icons.pause_circle_outline, color: Colors.white) : const Icon(Icons.play_circle_outline, color: Colors.white),
                                                                              )),
                                                                              voicePlay.contains(messageList[index].id) ? slider() : sliderDummy(),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                3),
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.end,
                                                                          children: [
                                                                            messageList[index].starredStatus == '1'
                                                                                ? const Icon(
                                                                                    Icons.star,
                                                                                    size: 10,
                                                                                    color: Colors.amber,
                                                                                  )
                                                                                : const SizedBox(),
                                                                            Text(
                                                                              formattedDate.substring(11, 19),
                                                                              style: const TextStyle(
                                                                                color: Colors.white,
                                                                                fontSize: 10,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      ],
                                                                    ),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                    }
                                  } else {
                                    isSender = false;
                                    if (messageList[index].messageType ==
                                        'location') {
                                      return messageList[index].deleteStatus ==
                                              '0'
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16, top: 8, bottom: 8),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 8,
                                                            horizontal: 8),
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft:
                                                                    Radius
                                                                        .circular(
                                                                            15),
                                                                topRight: Radius
                                                                    .circular(
                                                                        15),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        15))),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.block,
                                                            color:
                                                                Colors.white),
                                                        SizedBox(width: 10),
                                                        Text(
                                                          messageList[index]
                                                              .message,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : SwipeTo(
                                              onRightSwipe: () {
                                                print(
                                                    "________________---deleteStatus-----------------________");
                                                print(messageList[index]
                                                    .deleteStatus);
                                                if (messageList[index]
                                                        .deleteStatus ==
                                                    '1') {
                                                  getValue(
                                                      messageList[index].id,
                                                      messageList[index]
                                                          .message,
                                                      messageList[index]
                                                          .senterId,
                                                      messageData.name,
                                                      messageList[index]
                                                          .messageType);
                                                }
                                              },
                                              child: InkWell(
                                                onLongPress: () {
                                                  longPressStarred(
                                                      messageList[index]);
                                                },
                                                onTap: () {
                                                  onTapStarred(
                                                      messageList[index],
                                                      messageList);
                                                },
                                                child: Container(
                                                  color: messageId.contains(
                                                          messageList[index].id)
                                                      ? Colors.black38
                                                      : const Color.fromARGB(
                                                          0, 0, 0, 0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 3),
                                                        child: Container(
                                                          color: Colors
                                                              .transparent,
                                                          constraints: BoxConstraints(
                                                              maxWidth: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  .8),
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      16,
                                                                  vertical: 2),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        3),
                                                            decoration:
                                                                const BoxDecoration(
                                                              color:
                                                                  Colors.grey,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        15),
                                                                topRight: Radius
                                                                    .circular(
                                                                        15),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            15),
                                                              ),
                                                            ),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Flexible(
                                                                  child:
                                                                      InkWell(
                                                                    onTap:
                                                                        () async {
                                                                      String
                                                                          googleMapsUrl =
                                                                          'https://www.google.com/maps/search/?api=1&query=${messageList[index].message}';
                                                                      if (await canLaunch(
                                                                          googleMapsUrl)) {
                                                                        await launch(
                                                                            googleMapsUrl);
                                                                      } else {
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(
                                                                          SnackBar(
                                                                            content:
                                                                                Text('Could not launch $googleMapsUrl'),
                                                                          ),
                                                                        );
                                                                      }
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8),
                                                                      decoration:
                                                                          const BoxDecoration(
                                                                        color: Colors
                                                                            .grey,
                                                                        borderRadius:
                                                                            BorderRadius.only(
                                                                          topLeft:
                                                                              Radius.circular(10),
                                                                          topRight:
                                                                              Radius.circular(10),
                                                                          bottomLeft:
                                                                              Radius.circular(10),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.end,
                                                                        children: [
                                                                          Container(
                                                                            color:
                                                                                rightGreen,
                                                                            height:
                                                                                200,
                                                                            width:
                                                                                300,
                                                                            child:
                                                                                GoogleMap(
                                                                              myLocationButtonEnabled: false,
                                                                              zoomControlsEnabled: false,
                                                                              mapType: MapType.hybrid,
                                                                              onMapCreated: _onMapCreated,
                                                                              initialCameraPosition: CameraPosition(
                                                                                target: LatLng(double.parse(messageList[index].message.split(',').first), double.parse(messageList[index].message.split(',').last)),
                                                                                zoom: 15,
                                                                              ),
                                                                              onTap: (argument) async {
                                                                                String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=${messageList[index].message}';
                                                                                if (await canLaunch(googleMapsUrl)) {
                                                                                  await launch(googleMapsUrl);
                                                                                } else {
                                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                                    SnackBar(
                                                                                      content: Text('Could not launch $googleMapsUrl'),
                                                                                    ),
                                                                                  );
                                                                                }
                                                                              },
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 3),
                                                                Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    messageList[index].starredStatus ==
                                                                            '1'
                                                                        ? const Icon(
                                                                            Icons.star,
                                                                            size:
                                                                                10,
                                                                            color:
                                                                                Colors.amber,
                                                                          )
                                                                        : const SizedBox(),
                                                                    Text(
                                                                      formattedDate
                                                                          .substring(
                                                                              11,
                                                                              19),
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            10,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                    }

                                    if (messageList[index].messageType !=
                                        'voice') {
                                      return messageList[index].deleteStatus ==
                                              '0'
                                          ? InkWell(
                                              onLongPress: () {
                                                longPressStarred(
                                                    messageList[index]);
                                              },
                                              onTap: () {
                                                onTapStarred(messageList[index],
                                                    messageList);
                                              },
                                              child: Container(
                                                color: messageId.contains(
                                                        messageList[index].id)
                                                    ? Colors.black38
                                                    : const Color.fromARGB(
                                                        0, 0, 0, 0),
                                                child: messageList[index]
                                                            .deleteStatus ==
                                                        '1'
                                                    ? CustomBubble(
                                                        text: messageList[index]
                                                            .message,
                                                        thumbNail:
                                                            messageList[index]
                                                                .thumbnail,
                                                        messageType:
                                                            messageList[index]
                                                                .messageType,
                                                        optionalText:
                                                            messageList[index]
                                                                .optionalText,
                                                        rplyMsg: messageList[
                                                                        index]
                                                                    .replayMessage !=
                                                                ''
                                                            ? messageList[index]
                                                                .replayMessage
                                                            : '',
                                                        rplyMsgType: messageList[
                                                                        index]
                                                                    .replayMessageType !=
                                                                ''
                                                            ? messageList[index]
                                                                .replayMessageType
                                                            : '',
                                                        rplyMsgSenter: messageList[
                                                                        index]
                                                                    .replaySenter !=
                                                                ''
                                                            ? messageList[index]
                                                                .replaySenter
                                                            : '',
                                                        textStyle:
                                                            const TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                        time: messageList[index]
                                                            .date,
                                                        isDeleted: messageList[
                                                                        index]
                                                                    .deleteStatus ==
                                                                '0'
                                                            ? true
                                                            : false,
                                                        isStarred: messageList[
                                                                        index]
                                                                    .starredStatus ==
                                                                '1'
                                                            ? true
                                                            : false,
                                                        color: Colors.grey,
                                                        rplyColor: messageList[
                                                                        index]
                                                                    .messageStatus ==
                                                                '1'
                                                            ? Colors
                                                                .green.shade900
                                                            : Colors
                                                                .blue.shade900,
                                                        isSender: isSender,
                                                        forwardStatus: messageList[
                                                                index]
                                                            .forwardMessageStatus,
                                                      )
                                                    : Row(
                                                        children: [
                                                          Icon(Icons.block,
                                                              color: Colors
                                                                  .grey[100]),
                                                          Text(
                                                            text,
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .grey[100],
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
                                                            ),
                                                            textAlign:
                                                                TextAlign.left,
                                                          )
                                                        ],
                                                      ),
                                              ),
                                              // ),
                                            )
                                          : SwipeTo(
                                              onRightSwipe: () {
                                                print(
                                                    "________________---deleteStatus-----------------________");
                                                print(messageList[index]
                                                    .deleteStatus);
                                                if (messageList[index]
                                                        .deleteStatus ==
                                                    '1') {
                                                  getValue(
                                                      messageList[index].id,
                                                      messageList[index]
                                                          .message,
                                                      messageList[index]
                                                          .senterId,
                                                      messageData.name,
                                                      messageList[index]
                                                          .messageType);
                                                }
                                              },
                                              child: InkWell(
                                                onLongPress: () {
                                                  longPressStarred(
                                                      messageList[index]);
                                                },
                                                onTap: () {
                                                  onTapStarred(
                                                      messageList[index],
                                                      messageList);
                                                },
                                                child: Container(
                                                  color: messageId.contains(
                                                          messageList[index].id)
                                                      ? Colors.black38
                                                      : const Color.fromARGB(
                                                          0, 0, 0, 0),
                                                  child: messageList[index]
                                                              .deleteStatus ==
                                                          '1'
                                                      ? CustomBubble(
                                                          text:
                                                              messageList[index]
                                                                  .message,
                                                          thumbNail:
                                                              messageList[index]
                                                                  .thumbnail,
                                                          messageType:
                                                              messageList[index]
                                                                  .messageType,
                                                          optionalText:
                                                              messageList[index]
                                                                  .optionalText,
                                                          rplyMsg: messageList[
                                                                          index]
                                                                      .replayMessage !=
                                                                  ''
                                                              ? messageList[
                                                                      index]
                                                                  .replayMessage
                                                              : '',
                                                          rplyMsgType: messageList[
                                                                          index]
                                                                      .replayMessageType !=
                                                                  ''
                                                              ? messageList[
                                                                      index]
                                                                  .replayMessageType
                                                              : '',
                                                          rplyMsgSenter: messageList[
                                                                          index]
                                                                      .replaySenter !=
                                                                  ''
                                                              ? messageList[
                                                                      index]
                                                                  .replaySenter
                                                              : '',
                                                          textStyle:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                          time:
                                                              messageList[index]
                                                                  .date,
                                                          isDeleted: messageList[
                                                                          index]
                                                                      .deleteStatus ==
                                                                  '0'
                                                              ? true
                                                              : false,
                                                          isStarred: messageList[
                                                                          index]
                                                                      .starredStatus ==
                                                                  '1'
                                                              ? true
                                                              : false,
                                                          color: Colors.grey,
                                                          rplyColor: messageList[
                                                                          index]
                                                                      .messageStatus ==
                                                                  '1'
                                                              ? Colors.green
                                                                  .shade900
                                                              : Colors.blue
                                                                  .shade900,
                                                          isSender: isSender,
                                                          forwardStatus:
                                                              messageList[index]
                                                                  .forwardMessageStatus,
                                                        )
                                                      : Row(
                                                          children: [
                                                            Icon(Icons.block,
                                                                color: Colors
                                                                    .grey[100]),
                                                            Text(
                                                              text,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey[100],
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                            )
                                                          ],
                                                        ),
                                                ),
                                                // ),
                                              ),
                                            );
                                    } else {
                                      return messageList[index].deleteStatus ==
                                              '0'
                                          ? InkWell(
                                              onLongPress: () {
                                                longPressStarred(
                                                    messageList[index]);
                                              },
                                              onTap: () {
                                                onTapStarred(messageList[index],
                                                    messageList);
                                              },
                                              child: Container(
                                                color: messageId.contains(
                                                        messageList[index].id)
                                                    ? Colors.black38
                                                    : const Color.fromARGB(
                                                        0, 0, 0, 0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 3),
                                                      child: Container(
                                                        color:
                                                            Colors.transparent,
                                                        constraints: BoxConstraints(
                                                            maxWidth: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .8),
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 16,
                                                                vertical: 2),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      4),
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Colors.grey,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              topLeft: Radius
                                                                  .circular(15),
                                                              topRight: Radius
                                                                  .circular(15),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          15),
                                                            ),
                                                          ),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Flexible(
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Flexible(
                                                                        child:
                                                                            InkWell(
                                                                      onTap:
                                                                          () {
                                                                        if (voicePlay.length ==
                                                                            0) {
                                                                          setState(
                                                                              () {
                                                                            voicePlay.add(messageList[index].id);
                                                                          });
                                                                        } else {
                                                                          voicePlay
                                                                              .forEach((element) {
                                                                            if (element !=
                                                                                messageList[index].id) {
                                                                              setState(() {
                                                                                voicePlay = [];
                                                                                voicePlay.add(messageList[index].id);
                                                                              });
                                                                            }
                                                                          });
                                                                        }

                                                                        getAudioUrl(
                                                                            messageList[index].message,
                                                                            messageList[index].id);
                                                                      },
                                                                      child: voicePlay.contains(messageList[index].id) &&
                                                                              playing
                                                                          ? const Icon(Icons.pause_circle_outline,
                                                                              color: Colors
                                                                                  .white)
                                                                          : const Icon(
                                                                              Icons.play_circle_outline,
                                                                              color: Colors.white),
                                                                    )),
                                                                    voicePlay.contains(
                                                                            messageList[index].id)
                                                                        ? slider()
                                                                        : sliderDummy(),
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 3),
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  messageList[index]
                                                                              .starredStatus ==
                                                                          '1'
                                                                      ? const Icon(
                                                                          Icons
                                                                              .star,
                                                                          size:
                                                                              10,
                                                                          color:
                                                                              Colors.amber,
                                                                        )
                                                                      : const SizedBox(),
                                                                  Text(
                                                                    formattedDate
                                                                        .substring(
                                                                            11,
                                                                            19),
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          10,
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : SwipeTo(
                                              onRightSwipe: () {
                                                print(
                                                    "________________---deleteStatus-----------------________");
                                                print(messageList[index]
                                                    .deleteStatus);
                                                if (messageList[index]
                                                        .deleteStatus ==
                                                    '1') {
                                                  getValue(
                                                      messageList[index].id,
                                                      messageList[index]
                                                          .message,
                                                      messageList[index]
                                                          .senterId,
                                                      messageData.name,
                                                      messageList[index]
                                                          .messageType);
                                                }
                                              },
                                              child: InkWell(
                                                onLongPress: () {
                                                  longPressStarred(
                                                      messageList[index]);
                                                },
                                                onTap: () {
                                                  onTapStarred(
                                                      messageList[index],
                                                      messageList);
                                                },
                                                child: Container(
                                                  color: messageId.contains(
                                                          messageList[index].id)
                                                      ? Colors.black38
                                                      : const Color.fromARGB(
                                                          0, 0, 0, 0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 3),
                                                        child: Container(
                                                          color: Colors
                                                              .transparent,
                                                          constraints: BoxConstraints(
                                                              maxWidth: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  .8),
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      16,
                                                                  vertical: 2),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        4),
                                                            decoration:
                                                                const BoxDecoration(
                                                              color:
                                                                  Colors.grey,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        15),
                                                                topRight: Radius
                                                                    .circular(
                                                                        15),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            15),
                                                              ),
                                                            ),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Flexible(
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      Flexible(
                                                                          child:
                                                                              InkWell(
                                                                        onTap:
                                                                            () {
                                                                          if (voicePlay.length ==
                                                                              0) {
                                                                            setState(() {
                                                                              voicePlay.add(messageList[index].id);
                                                                            });
                                                                          } else {
                                                                            voicePlay.forEach((element) {
                                                                              if (element != messageList[index].id) {
                                                                                setState(() {
                                                                                  voicePlay = [];
                                                                                  voicePlay.add(messageList[index].id);
                                                                                });
                                                                              }
                                                                            });
                                                                          }

                                                                          getAudioUrl(
                                                                              messageList[index].message,
                                                                              messageList[index].id);
                                                                        },
                                                                        child: voicePlay.contains(messageList[index].id) &&
                                                                                playing
                                                                            ? const Icon(Icons.pause_circle_outline,
                                                                                color: Colors.white)
                                                                            : const Icon(Icons.play_circle_outline, color: Colors.white),
                                                                      )),
                                                                      voicePlay.contains(
                                                                              messageList[index].id)
                                                                          ? slider()
                                                                          : sliderDummy(),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 3),
                                                                Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    messageList[index].starredStatus ==
                                                                            '1'
                                                                        ? const Icon(
                                                                            Icons.star,
                                                                            size:
                                                                                10,
                                                                            color:
                                                                                Colors.amber,
                                                                          )
                                                                        : const SizedBox(),
                                                                    Text(
                                                                      formattedDate
                                                                          .substring(
                                                                              11,
                                                                              19),
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            10,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(splashBg),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      rply
                                          ? SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  60,
                                              height: 130,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              60,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 20,
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                auth.userId ==
                                                                        senderId
                                                                    ? 'You'
                                                                    : '${sndName}',
                                                                style: TextStyle(
                                                                    color:
                                                                        textGreen,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              if (msgTyp ==
                                                                  'text')
                                                                SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width -
                                                                      150,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            4.0),
                                                                    child: Text(
                                                                      // softWrap: false,
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      maxLines:
                                                                          2,
                                                                      '${replyMsg}',
                                                                    ),
                                                                  ),
                                                                ),
                                                              if (msgTyp ==
                                                                  'voice')
                                                                Row(
                                                                  children: const [
                                                                    Icon(
                                                                        Icons
                                                                            .mic,
                                                                        color: Colors
                                                                            .white),
                                                                    Text(
                                                                      'Voice Message',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ],
                                                                ),
                                                              if (msgTyp ==
                                                                  'image')
                                                                Row(
                                                                  children: const [
                                                                    Icon(
                                                                        Icons
                                                                            .image,
                                                                        color: Colors
                                                                            .white),
                                                                    Text(
                                                                      'Photo',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ],
                                                                ),
                                                              if (msgTyp ==
                                                                  'video')
                                                                Row(
                                                                  children: const [
                                                                    Icon(
                                                                        Icons
                                                                            .play_circle_outline_sharp,
                                                                        color: Colors
                                                                            .white),
                                                                    Text(
                                                                      'Video',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ],
                                                                ),
                                                            ],
                                                          ),
                                                          const Spacer(),
                                                          if (msgTyp == 'text')
                                                            IconButton(
                                                                onPressed: () {
                                                                  setState(() {
                                                                    rply =
                                                                        false;
                                                                    replyMsg =
                                                                        '';
                                                                    replyId =
                                                                        '';
                                                                    senderId =
                                                                        '';
                                                                    sndName =
                                                                        '';
                                                                  });
                                                                },
                                                                icon: const Icon(
                                                                    Icons.close,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 20)),
                                                          if (msgTyp == 'voice')
                                                            IconButton(
                                                                onPressed: () {
                                                                  setState(() {
                                                                    rply =
                                                                        false;
                                                                    replyMsg =
                                                                        '';
                                                                    replyId =
                                                                        '';
                                                                    senderId =
                                                                        '';
                                                                    sndName =
                                                                        '';
                                                                  });
                                                                },
                                                                icon: const Icon(
                                                                    Icons.close,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 20)),
                                                          if (msgTyp == 'image')
                                                            Stack(
                                                              children: [
                                                                Container(
                                                                  height: 35,
                                                                  width: 40,
                                                                  decoration: BoxDecoration(
                                                                      image: DecorationImage(
                                                                          image: NetworkImage(
                                                                              replyMsg!),
                                                                          fit: BoxFit
                                                                              .cover)),
                                                                ),
                                                                Positioned(
                                                                  right: -18,
                                                                  top: -18,
                                                                  child:
                                                                      IconButton(
                                                                          onPressed:
                                                                              () {
                                                                            setState(() {
                                                                              rply = false;
                                                                              replyMsg = '';
                                                                              replyId = '';
                                                                              senderId = '';
                                                                              sndName = '';
                                                                              msgTyp = '';
                                                                            });
                                                                          },
                                                                          icon: const Icon(
                                                                              Icons.close,
                                                                              color: Colors.white,
                                                                              size: 18)),
                                                                ),
                                                              ],
                                                            ),
                                                          if (msgTyp == 'video')
                                                            Stack(
                                                              children: [
                                                                SizedBox(
                                                                  width: 35,
                                                                  height: 40,
                                                                  child: Stack(
                                                                    children: [
                                                                      VideoPlayer(
                                                                          _videoPlayerController),
                                                                      Positioned(
                                                                        bottom:
                                                                            2,
                                                                        right:
                                                                            4,
                                                                        child:
                                                                            Container(
                                                                          child:
                                                                              const Center(
                                                                            child:
                                                                                Icon(
                                                                              Icons.play_circle_outline_outlined,
                                                                              color: Colors.white,
                                                                              size: 14,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Positioned(
                                                                  right: -18,
                                                                  top: -18,
                                                                  child:
                                                                      IconButton(
                                                                          onPressed:
                                                                              () {
                                                                            setState(() {
                                                                              rply = false;
                                                                              replyMsg = '';
                                                                              replyId = '';
                                                                              senderId = '';
                                                                              sndName = '';
                                                                              msgTyp = '';
                                                                            });
                                                                          },
                                                                          icon: const Icon(
                                                                              Icons.close,
                                                                              color: Colors.white,
                                                                              size: 18)),
                                                                ),
                                                              ],
                                                            ),
                                                        ],
                                                      ),
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors.green,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  25),
                                                          topRight:
                                                              Radius.circular(
                                                                  25),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Card(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 2,
                                                            right: 2,
                                                            bottom: 8),
                                                    shape:
                                                        const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              bottomLeft: Radius
                                                                  .circular(25),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          25)),
                                                    ),
                                                    child: Center(
                                                      child: recorder
                                                              .isRecording
                                                          ? StreamBuilder<
                                                              RecordingDisposition>(
                                                              stream: recorder
                                                                  .onProgress,
                                                              builder: (context,
                                                                  snapshot) {
                                                                duration = snapshot.hasData
                                                                    ? snapshot
                                                                        .data!
                                                                        .duration
                                                                    : Duration
                                                                        .zero;
                                                                String twoDigits(
                                                                        int
                                                                            n) =>
                                                                    n
                                                                        .toString()
                                                                        .padLeft(
                                                                            2);
                                                                final twoDigitMinutes =
                                                                    twoDigits(duration
                                                                        .inMinutes
                                                                        .remainder(
                                                                            60));
                                                                final twoDigitSeconds =
                                                                    twoDigits(duration
                                                                        .inSeconds
                                                                        .remainder(
                                                                            60));

                                                                return Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    IconButton(
                                                                      onPressed:
                                                                          () {
                                                                        if (recorder.isRecording ||
                                                                            recorder.isPaused) {
                                                                          stop(
                                                                              rply ? true : false,
                                                                              true);
                                                                        }
                                                                      },
                                                                      icon: const Icon(
                                                                          Icons
                                                                              .delete),
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                    Text(
                                                                        '$twoDigitMinutes:$twoDigitSeconds'),
                                                                    IconButton(
                                                                      onPressed:
                                                                          () async {
                                                                        if (recorder
                                                                            .isRecording) {
                                                                          recorder
                                                                              .pauseRecorder();
                                                                          setState(
                                                                              () {
                                                                            pauseRec =
                                                                                true;
                                                                          });
                                                                        } else {
                                                                          if (recorder
                                                                              .isPaused) {
                                                                            print(recorder.isPaused);
                                                                            recorder.resumeRecorder();
                                                                            if (recorder.isRecording) {
                                                                              setState(() {
                                                                                pauseRec = false;
                                                                              });
                                                                            }
                                                                          }
                                                                        }
                                                                      },
                                                                      icon:
                                                                          Icon(
                                                                        !pauseRec
                                                                            ? Icons.pause_circle_outline
                                                                            : Icons.mic,
                                                                      ),
                                                                      color:
                                                                          rightGreen,
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            )
                                                          : TextField(
                                                              controller:
                                                                  _controller,
                                                              focusNode:
                                                                  focusNode,
                                                              textAlignVertical:
                                                                  TextAlignVertical
                                                                      .center,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .multiline,
                                                              maxLines: 5,
                                                              minLines: 1,
                                                              onChanged:
                                                                  (value) {
                                                                if (_controller
                                                                        .text
                                                                        .length >
                                                                    0) {
                                                                  setState(() {
                                                                    sndBtn =
                                                                        true;
                                                                  });
                                                                } else {
                                                                  setState(() {
                                                                    sndBtn =
                                                                        false;
                                                                  });
                                                                }
                                                              },
                                                              onTap: () {
                                                                getFocus();
                                                              },
                                                              decoration:
                                                                  InputDecoration(
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                                hintText:
                                                                    'Type Message',
                                                                prefixIcon:
                                                                    IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          focusNode
                                                                              .unfocus();
                                                                          focusNode.canRequestFocus =
                                                                              false;
                                                                          if (show) {
                                                                            setState(() {
                                                                              show = false;
                                                                            });
                                                                          } else {
                                                                            setState(() {
                                                                              show = true;
                                                                            });
                                                                          }

                                                                          if (vwe) {
                                                                            setState(() {
                                                                              vwe = false;
                                                                            });
                                                                          }
                                                                        },
                                                                        icon:
                                                                            ImageIcon(
                                                                          AssetImage(
                                                                              smileyIcon),
                                                                          color:
                                                                              rightGreen,
                                                                          size:
                                                                              30,
                                                                        )),
                                                                suffixIcon: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    const SizedBox(),
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        focusNode
                                                                            .unfocus();
                                                                        focusNode.canRequestFocus =
                                                                            false;
                                                                        if (show) {
                                                                          setState(
                                                                              () {
                                                                            show =
                                                                                false;
                                                                          });
                                                                        }

                                                                        if (vwe) {
                                                                          setState(
                                                                              () {
                                                                            vwe =
                                                                                false;
                                                                          });
                                                                        } else {
                                                                          setState(
                                                                              () {
                                                                            vwe =
                                                                                true;
                                                                          });
                                                                        }
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            40,
                                                                        padding:
                                                                            const EdgeInsets.all(3),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              rightGreen,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        child: const Icon(
                                                                            Icons
                                                                                .add,
                                                                            color:
                                                                                Colors.white),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .all(5),
                                                              ),
                                                            ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  60,
                                              height: 70,
                                              child: Card(
                                                margin: const EdgeInsets.only(
                                                    left: 2,
                                                    right: 2,
                                                    bottom: 8),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                ),
                                                child: Center(
                                                  child: recorder.isRecording ||
                                                          recorder.isPaused
                                                      ? StreamBuilder<
                                                          RecordingDisposition>(
                                                          stream: recorder
                                                              .onProgress,
                                                          builder: (context,
                                                              snapshot) {
                                                            final duration =
                                                                snapshot.hasData
                                                                    ? snapshot
                                                                        .data!
                                                                        .duration
                                                                    : Duration
                                                                        .zero;

                                                            String twoDigits(
                                                                    int n) =>
                                                                n
                                                                    .toString()
                                                                    .padLeft(2);
                                                            final twoDigitMinutes =
                                                                twoDigits(duration
                                                                    .inMinutes
                                                                    .remainder(
                                                                        60));
                                                            final twoDigitSeconds =
                                                                twoDigits(duration
                                                                    .inSeconds
                                                                    .remainder(
                                                                        60));

                                                            return Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    if (recorder
                                                                            .isRecording ||
                                                                        recorder
                                                                            .isPaused) {
                                                                      stop(
                                                                          rply
                                                                              ? true
                                                                              : false,
                                                                          true);
                                                                    }
                                                                  },
                                                                  icon: Icon(Icons
                                                                      .delete),
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                                Text(
                                                                    '$twoDigitMinutes:$twoDigitSeconds'),
                                                                IconButton(
                                                                  onPressed:
                                                                      () async {
                                                                    if (recorder
                                                                        .isRecording) {
                                                                      await recorder
                                                                          .pauseRecorder();
                                                                      setState(
                                                                          () {
                                                                        pauseRec =
                                                                            true;
                                                                      });
                                                                    } else {
                                                                      if (recorder
                                                                          .isPaused) {
                                                                        print(recorder
                                                                            .isPaused);
                                                                        await recorder
                                                                            .resumeRecorder();
                                                                        if (recorder
                                                                            .isRecording) {
                                                                          setState(
                                                                              () {
                                                                            pauseRec =
                                                                                false;
                                                                          });
                                                                        }
                                                                      }
                                                                    }
                                                                  },
                                                                  icon: Icon(
                                                                    pauseRec
                                                                        ? Icons
                                                                            .mic
                                                                        : Icons
                                                                            .pause_circle_outline,
                                                                  ),
                                                                  color:
                                                                      rightGreen,
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        )
                                                      : TextField(
                                                          controller:
                                                              _controller,
                                                          focusNode: focusNode,
                                                          textAlignVertical:
                                                              TextAlignVertical
                                                                  .center,
                                                          keyboardType:
                                                              TextInputType
                                                                  .multiline,
                                                          maxLines: 5,
                                                          minLines: 1,
                                                          onTap: () {
                                                            getFocus();
                                                          },
                                                          onChanged: (value) {
                                                            if (_controller.text
                                                                    .length >
                                                                0) {
                                                              setState(() {
                                                                sndBtn = true;
                                                                _socket.emit(
                                                                    'typing_individual',
                                                                    {
                                                                      'sid': auth
                                                                          .userId,
                                                                      'rid': widget
                                                                          .rId,
                                                                      'status':
                                                                          '1'
                                                                    });
                                                                _socket.on(
                                                                    'typing_individual_room',
                                                                    (data) {
                                                                  print(
                                                                      'RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR');
                                                                  print(data);
                                                                  print(
                                                                      'RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR');
                                                                });
                                                              });
                                                            } else {
                                                              setState(() {
                                                                sndBtn = false;
                                                              });
                                                            }
                                                          },
                                                          decoration:
                                                              InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            hintText:
                                                                'Type Message',
                                                            prefixIcon:
                                                                IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      focusNode
                                                                          .unfocus();
                                                                      focusNode
                                                                              .canRequestFocus =
                                                                          false;
                                                                      setState(
                                                                          () {
                                                                        show =
                                                                            !show;
                                                                      });
                                                                    },
                                                                    icon:
                                                                        ImageIcon(
                                                                      AssetImage(
                                                                          smileyIcon),
                                                                      color:
                                                                          rightGreen,
                                                                      size: 30,
                                                                    )),
                                                            suffixIcon: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                const SizedBox(),
                                                                InkWell(
                                                                  onTap: () {
                                                                    focusNode
                                                                        .unfocus();
                                                                    focusNode
                                                                            .canRequestFocus =
                                                                        false;
                                                                    if (show) {
                                                                      setState(
                                                                          () {
                                                                        show =
                                                                            false;
                                                                      });
                                                                    }

                                                                    if (vwe) {
                                                                      setState(
                                                                          () {
                                                                        vwe =
                                                                            false;
                                                                      });
                                                                    } else {
                                                                      setState(
                                                                          () {
                                                                        vwe =
                                                                            true;
                                                                      });
                                                                    }
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    height: 40,
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(3),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color:
                                                                          rightGreen,
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    child: const Icon(
                                                                        Icons
                                                                            .add,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .all(5),
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            ),
                                      sndBtn
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8, right: 5, left: 2),
                                              child: CircleAvatar(
                                                backgroundColor:
                                                    Colors.transparent,
                                                radius: 25,
                                                child: IconButton(
                                                    onPressed: () {
                                                      if (messageData
                                                              .userBlockStatus !=
                                                          0) {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: Text(
                                                                  'Contact is blocked'),
                                                              content: Text(
                                                                  'You need to unblock this contact for sending message.'),
                                                              actions: <Widget>[
                                                                TextButton(
                                                                  child: Text(
                                                                      'Cancel'),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                ),
                                                                TextButton(
                                                                  child:
                                                                      const Text(
                                                                          'Ok'),
                                                                  onPressed:
                                                                      () {
                                                                    var block_unblockBody =
                                                                        {
                                                                      'user_id':
                                                                          auth.userId,
                                                                      'accessToken':
                                                                          auth.accessToken,
                                                                      'receiver_id':
                                                                          messageData
                                                                              .id
                                                                    };
                                                                    if (_socket
                                                                        .connected) {
                                                                      _socket.emit(
                                                                          'unblock',
                                                                          block_unblockBody);
                                                                      _socket.on(
                                                                          'unblock',
                                                                          (data) {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      });
                                                                    } else {
                                                                      _socket
                                                                          .connect();
                                                                      _socket.emit(
                                                                          'unblock',
                                                                          block_unblockBody);
                                                                      _socket.on(
                                                                          'unblock',
                                                                          (data) {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      });
                                                                    }
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      } else {
                                                        if (rply) {
                                                          itemScrollController.scrollTo(
                                                              index: snapshot
                                                                  .data!
                                                                  .data
                                                                  .list
                                                                  .length,
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          300),
                                                              curve: Curves
                                                                  .easeOut);
                                                          var body = {
                                                            'sid': auth.userId,
                                                            'rid': widget.rId,
                                                            'message':
                                                                _controller
                                                                    .value.text,
                                                            'type': 'text',
                                                            'message_id':
                                                                replyId
                                                          };
                                                          if (mounted) {
                                                            setState(() {
                                                              _socket.emit(
                                                                  'message',
                                                                  body);
                                                              _controller
                                                                  .clear();
                                                              sndBtn = false;
                                                              rply = false;
                                                              _socket.emit(
                                                                  'typing_individual',
                                                                  {
                                                                    'sid': auth
                                                                        .userId,
                                                                    'rid': widget
                                                                        .rId,
                                                                    'status':
                                                                        '0'
                                                                  });
                                                              _socket.on(
                                                                  'typing_individual_room',
                                                                  (data) {
                                                                print(
                                                                    'RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR');
                                                                print(data);
                                                                print(
                                                                    'RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR');
                                                              });

                                                              _socket.emit(
                                                                  'chat_list', {
                                                                'user_id':
                                                                    auth.userId,
                                                                'accessToken': auth
                                                                    .accessToken
                                                              });
                                                              // _socket.emit(
                                                              //     'read', {
                                                              //   'sid':
                                                              //       auth.userId,
                                                              //   'rid':
                                                              //       widget.rId
                                                              // });
                                                            });
                                                          }
                                                        } else {
                                                          if (mounted) {
                                                            setState(() {
                                                              _socket.emit(
                                                                  'message', {
                                                                'sid':
                                                                    auth.userId,
                                                                'rid':
                                                                    widget.rId,
                                                                'message':
                                                                    _controller
                                                                        .text,
                                                                'type': 'text'
                                                              });
                                                              _controller
                                                                  .clear();
                                                              // itemScrollController.scrollTo(
                                                              //     index: snapshot
                                                              //         .data!
                                                              //         .data
                                                              //         .list
                                                              //         .length,
                                                              //     duration:
                                                              //         const Duration(
                                                              //             milliseconds:
                                                              //                 300),
                                                              //     );
                                                              sndBtn = false;
                                                              _socket.emit(
                                                                  'typing_individual',
                                                                  {
                                                                    'sid': auth
                                                                        .userId,
                                                                    'rid': widget
                                                                        .rId,
                                                                    'status':
                                                                        '0'
                                                                  });
                                                              _socket.on(
                                                                  'typing_individual_room',
                                                                  (data) {
                                                                print(
                                                                    'RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR');
                                                                print(data);
                                                                print(
                                                                    'RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR');
                                                              });
                                                              // _socket.emit(
                                                              //     'read', {
                                                              //   'sid':
                                                              //       auth.userId,
                                                              //   'rid':
                                                              //       widget.rId
                                                              // });
                                                            });
                                                          }
                                                        }
                                                      }
                                                    },
                                                    icon: const Icon(
                                                      Icons.send,
                                                      color: Colors.green,
                                                    )),
                                              ),
                                            )
                                          : Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8, right: 5, left: 2),
                                              child: CircleAvatar(
                                                backgroundColor:
                                                    Colors.grey[300],
                                                radius: 25,
                                                child: IconButton(
                                                    onPressed: () async {
                                                      if (messageData
                                                              .userBlockStatus !=
                                                          0) {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                  'Contact is blocked'),
                                                              content: const Text(
                                                                  'You need to unblock this contact for sending message.'),
                                                              actions: <Widget>[
                                                                TextButton(
                                                                  child: const Text(
                                                                      'Cancel'),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                ),
                                                                TextButton(
                                                                  child:
                                                                      const Text(
                                                                          'Ok'),
                                                                  onPressed:
                                                                      () {
                                                                    var block_unblockBody =
                                                                        {
                                                                      'user_id':
                                                                          auth.userId,
                                                                      'accessToken':
                                                                          auth.accessToken,
                                                                      'receiver_id':
                                                                          messageData
                                                                              .id
                                                                    };
                                                                    if (_socket
                                                                        .connected) {
                                                                      _socket.emit(
                                                                          'unblock',
                                                                          block_unblockBody);
                                                                      _socket.on(
                                                                          'unblock',
                                                                          (data) {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      });
                                                                    } else {
                                                                      _socket
                                                                          .connect();
                                                                      _socket.emit(
                                                                          'unblock',
                                                                          block_unblockBody);
                                                                      _socket.on(
                                                                          'unblock',
                                                                          (data) {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      });
                                                                    }
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      } else {
                                                        if (recorder
                                                                .isRecording ||
                                                            recorder.isPaused) {
                                                          await stop(
                                                              rply
                                                                  ? true
                                                                  : false,
                                                              false);
                                                        } else {
                                                          await record();
                                                        }
                                                        setState(() {});
                                                      }
                                                    },
                                                    icon: recorder
                                                                .isRecording ||
                                                            recorder.isPaused
                                                        ? Icon(Icons.send,
                                                            color: rightGreen)
                                                        : ImageIcon(
                                                            AssetImage(
                                                                microPhoneIcon),
                                                            color: rightGreen,
                                                          )),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                                show ? emojiPicker() : Container(),
                                vwe ? bottomContainer() : Container()
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            );
          } else {
            return Scaffold(
              body: Center(
                child: SpinKitSpinningLines(color: textGreen),
              ),
            );
          }
        },
      ),
      onWillPop: () {
        if (_socket.connected) {
          var auth = Provider.of<AuthProvider>(context, listen: false);
          _socket.emit('dis', {"s_id": auth.userId});
        } else {
          _socket.connect();
          var auth = Provider.of<AuthProvider>(context, listen: false);
          _socket.emit('dis', {"s_id": auth.userId});
        }
        Navigator.pop(context, 'refresh');
        _destroySocket();
        return Future.value(false);
      },
    );
  }
}
