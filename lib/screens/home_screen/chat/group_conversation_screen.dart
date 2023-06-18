import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
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
import 'package:smart_station/providers/ChatDetailProvider/chatdetail_provider.dart';
import 'package:smart_station/providers/GroupProvider/group_provider.dart';
import 'package:smart_station/screens/home_screen/chat/forward_screen.dart';
import 'package:smart_station/screens/home_screen/chat/liveMap.dart';
import 'package:smart_station/screens/home_screen/chat/widget/audioSending.dart';
import 'package:smart_station/screens/home_screen/chat/widget/audioSendingNoRply.dart';
import 'package:smart_station/screens/home_screen/chat/widget/chat%20bubble/group_chat_bubble.dart';
import 'package:smart_station/screens/home_screen/chat/widget/documentSending.dart';
import 'package:smart_station/screens/home_screen/chat/widget/documentSendingNoRply.dart';
import 'package:smart_station/screens/home_screen/chat/widget/imageSending.dart';
import 'package:smart_station/screens/home_screen/chat/widget/imageSendingNoRply.dart';
import 'package:smart_station/screens/home_screen/chat/widget/media_screen/media_group.dart';
import 'package:smart_station/screens/home_screen/chat/widget/videoSending.dart';
import 'package:smart_station/screens/home_screen/chat/widget/videoSendingNoRply.dart';
import 'package:smart_station/screens/home_screen/home_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_compress/video_compress.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:video_player/video_player.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../providers/AuthProvider/auth_provider.dart';
import '../../../providers/UserProvider/user_provider.dart';
import '../../../utils/constants/app_constants.dart';
import '../../../utils/constants/urls.dart';
import '../../callAndNotification/calling.dart';
import '../../callAndNotification/videoCalling.dart';
import 'group_info_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

import 'models/group_chat_model.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class GroupConversationScreen extends StatefulWidget {
  // BuildContext context;
  String gId;
  // String groupeId;
  GroupConversationScreen({
    Key? key,
    required this.gId,
  }) : super(key: key);

  @override
  State<GroupConversationScreen> createState() =>
      _GroupConversationScreenState();
}

class _GroupConversationScreenState extends State<GroupConversationScreen> {
  StreamController<GroupChatModel> groupController =
      StreamController<GroupChatModel>();

  bool show = false;
  bool cUser = false;
  bool rply = false;
  bool sndBtn = false;
  bool vwe = false;
  bool longPress = false;
  bool starred = false;
  bool isSender = false;
  bool isDeleteEveryone = false;
  bool? showN = false;
  bool leftStatus = false;
  bool pauseRec = false;
  FocusNode focusNode = FocusNode();
  String? userId;
  String? replyMsg;
  String? replyId;
  String? senderId;
  String? sndName;
  String? msgTyp;
  String groupMembersDId = '';
  String? groupId;
  String? fullPath;
  List grupeFCM = [];
  String? halfPath;
  // List<String> items = ['hellow', "today", "this", "me"];
  List<String> messageId = [];
  List<String> onLongDel = [];
  AudioPlayer audioPlayer = AudioPlayer();
  Duration duration = const Duration();
  Duration position = const Duration();
  bool playing = false;
  String? thumbPath;
  DateFormat dateFormat2 = DateFormat('dd/MM/yyyy hh:mm a');
  final recorder = FlutterSoundRecorder();
  String? copyButtonText;

  List<String> voicePlay = [];

  late GoogleMapController mapController;
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  final TextEditingController _controller = TextEditingController();
  late VideoPlayerController _videoPlayerController;
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  final ItemScrollController itemScrollController = ItemScrollController();

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
  }

  socketFunction() async {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    groupId = widget.gId;

    if (_socket.connected) {
      _socket.emit('room', {'userid': auth.userId, 'room': widget.gId});
      _socket.on('roomUsers', (data) {
        print(data);
        print('======================[JOINED]========================');
        _socket.emit(
            'room_chat_list_details', {'sid': auth.userId, 'room': widget.gId});

        _socket.on('message', (data) async {
          // socket.on('message', (data) async {
          print(data);
          if (data['data']['user_left_status'] == "1") {
            setState(() {
              leftStatus = true;
            });
          }
          var finalData = GroupChatModel.fromJson(data);

          if (groupController.isClosed) {
            groupController = StreamController();
            groupController.onListen;
            groupController.add(finalData);
          } else {
            groupController.add(finalData);
          }
        });
      });
    } else {
      _connectSocket();
      _socket.emit('room', {'userid': auth.userId, 'room': widget.gId});
      _socket.on('roomUsers', (data) {
        print('======================[JOINED]========================');
        _socket.emit(
            'room_chat_list_details', {'sid': auth.userId, 'room': widget.gId});
        _socket.emit('read', {'sid': auth.userId, 'room': widget.gId});

        // socket.on('typing_individual_room', (data) {});

        // socket.on('online_users', (data) {});

        _socket.on('message', (data) async {
          print('ENTER');
          print(data);
          if (data['data']['user_left_status'] == 1) {
            setState(() {
              leftStatus = true;
            });
          }

          var finalData = GroupChatModel.fromJson(data);
          if (groupController.isClosed) {
            groupController = StreamController();
            groupController.onListen;
            groupController.add(finalData);
          } else {
            groupController.add(finalData);
          }
        });
      });
    }
  }

  getValue(
    mId,
    mData,
    sId,
    sName,
    mTyp,
  ) {
    if (longPress) {
      setState(() {
        longPress = false;
        onLongDel = [];
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

      if (audioPath != null) {
        print('AUDIO PATH:::::::::::::::::::::> $audioPath');

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
            'room': groupId,
            'message': jsonDecode(event)['path'],
            'type': 'voice',
          };
          _socket.emit('message', body);
        });
      }
    }
  }

  @override
  void initState() {
    _connectSocket();
    var auth = Provider.of<AuthProvider>(context, listen: false);
    var grp = Provider.of<GroupProvider>(context, listen: false);
    grp.getGroupInfo(groupId: widget.gId, context: context);
    userId = auth.userId;
    socketFunction();
    initRecorder();

    super.initState();
    print('group dataaas');
  }

  @override
  Widget build(BuildContext context) {
    // print(userDevicesID);
    var auth = Provider.of<AuthProvider>(context, listen: false);
    var grp = Provider.of<GroupProvider>(context, listen: true);
    var usp = Provider.of<UserProvider>(context, listen: false);
    var cdp = Provider.of<ChatDetailProvider>(context, listen: false);
    // grp.getGroupInfo(groupId: widget.gId.toString(), context: context);
    // grp.realGrpInfo;
    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    DateFormat dateFormat2 = DateFormat('dd/MM/yyyy hh:mm a');
    return WillPopScope(
      onWillPop: () async {
        _destroySocket();
        groupController.close();

        Navigator.pop(context, 'refresh');

        return true;
      },
      child: StreamBuilder(
        stream: groupController.stream,
        builder:
            (BuildContext context, AsyncSnapshot<GroupChatModel> snapshot) {
          grp.realGrpInfo;
          if (snapshot.hasData) {
            var messageData = snapshot.data!.data;
            var messageList = snapshot.data!.data.list;

            // grp.getGroupInfo(
            //                   groupId: messageData.id.toString(),
            //                   context: context);

            // for (var i = 0; i < messageList.length; i++) {
            //   messageList[i].optional = '0';
            // }
            String muteStatus = messageData.muteStatus;
            // bool leftStatus = false;
            if (messageData.userLeftStatus == '1') {
              leftStatus = true;
            }
            for (int i = 0; i < messageList.length; i++) {
              if (messageList[i].messageType == 'video') {
                _videoPlayerController =
                    VideoPlayerController.network(messageList[i].message);
              }
            }
            return Scaffold(
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
                                  } else {
                                    _socket.emit('starred_message', body);
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
                                            ? const Icon(Icons.star_half)
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
                                  usp.userList(context: context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ForwardScreen(
                                                messageId: messageId,
                                                rId: widget.gId,
                                              )));
                                },
                                icon: const Icon(
                                  Icons.forward,
                                  color: Colors.white,
                                )),
                        onLongDel.contains('0')
                            ? const SizedBox()
                            : IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.white,
                                )),
                      ],
                    )
                  : AppBar(
                      elevation: 0,
                      backgroundColor: Colors.black26,
                      leadingWidth: 70,
                      leading: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              _destroySocket();
                              groupController.close();
                              Navigator.pop(context, 'refresh');
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => HomeScreen()));
                            },
                            child: const Icon(Icons.arrow_back,
                                color: Colors.white),
                          ),
                          Container(
                            // padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 1)),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  NetworkImage(messageData.groupProfile),
                            ),
                          ),
                        ],
                      ),
                      title: InkWell(
                        onTap: () async {
                          _destroySocket();
                          groupController.close();
                          // grp.getGroupInfo(
                          //     groupId: messageData.id.toString(),
                          //     context: context);
                          // grp.realGrpInfo;
                          String refresh = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GroupInfo(
                                      groupId: messageData.id.toString())));
                          if (refresh == 'refresh') {
                            setState(() {
                              socketFunction();
                            });
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              messageData.groupName,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            //Text(grp.realGrpInfo['data'].length.toString())
                            //Text(grp.realGrpInfo['data'][1]['username'].toString())
                            Container(
                              width: MediaQuery.of(context).size.width / 3,
                              height: 35,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: grp.realGrpInfo['data'].length,
                                  itemBuilder: (context, index) {
                                    if (grp.realGrpInfo['data'][index]
                                            ['user_id'] ==
                                        auth.userId) {
                                      return const Text(
                                        'You,',
                                        style: TextStyle(fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      );
                                    } else {
                                      if(index ==grp.realGrpInfo['data'].length-1 ){
                                        return Text(
                                        '${grp.realGrpInfo['data'][index]['username']}',
                                        style: const TextStyle(fontSize: 15),
                                        overflow: TextOverflow.ellipsis,
                                      );
                                      }else{
                                          return Text(
                                        '${grp.realGrpInfo['data'][index]['username']},',
                                        style: const TextStyle(fontSize: 15),
                                        overflow: TextOverflow.ellipsis,
                                      );
                                      }
                                      
                                    }
                                  }),
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
                            if (!leftStatus) {
                              get_group_user_list(
                                      auth.userId, auth.accessToken, widget.gId)
                                  .then((value) async {
                                print(
                                    '______________________-part 1______________________');
                                grupeFCM.remove(await FirebaseMessaging.instance
                                    .getToken());
                                await Future.wait(
                                    grupeFCM.toSet().toList().map((e) async {
                                  print(
                                      '______________________-part 2______________________');
                                  await gruopeAudioCallPushMessage(
                                      e,
                                      messageData.groupName,
                                      messageData.id.toString());
                                })).then((value) {
                                  print(
                                      '______________________-part 3______________________');
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CallingPage(
                                                toFCM: '',
                                                userName: messageData.groupName,
                                                profile:
                                                    messageData.groupProfile,
                                                groupeFCM: grupeFCM,
                                                type: 'groupe',
                                              )));
                                });
                                print(grupeFCM);
                              });
                            }
                          },
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        InkWell(
                          child: CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.transparent,
                              child: Image.asset(
                                videoIcon,
                              )),
                          onTap: () {
                            if (!leftStatus) {
                              get_group_user_list(
                                      auth.userId, auth.accessToken, widget.gId)
                                  .then((value) async {
                                print(
                                    '______________________-part 1______________________');
                                grupeFCM.remove(await FirebaseMessaging.instance
                                    .getToken());
                                await Future.wait(
                                    grupeFCM.toSet().toList().map((e) async {
                                  print(
                                      '______________________-part 2______________________');
                                  await gruopeVideoCallPushMessage(
                                      e,
                                      messageData.groupName,
                                      messageData.id.toString());
                                })).then((value) {
                                  print(
                                      '______________________-part 3______________________');
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              VideoCameraRingScreen(
                                                toFCM: '',
                                                userName: messageData.groupName,
                                                profile:
                                                    messageData.groupProfile,
                                                groupeFCM: grupeFCM,
                                                type: 'groupe',
                                              )));
                                });
                                print(grupeFCM);
                              });
                            }
                          },
                        ),

                        PopupMenuButton<String>(
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: '1',
                              child: Text('Group info'),
                            ),
                            const PopupMenuItem<String>(
                              value: '2',
                              child: Text('Media, links, and docs'),
                            ),
                            PopupMenuItem<String>(
                              value: '3',
                              child: muteStatus == '0'
                                  ? const Text('Mute notifications')
                                  : const Text('Unmute notifications'),
                            ),
                            const PopupMenuItem<String>(
                              value: '4',
                              child: Text('Report Group'),
                            ),
                            const PopupMenuItem<String>(
                              value: '5',
                              child: Text('Clear chat'),
                            ),
                            const PopupMenuItem<String>(
                              value: '6',
                              child: Text('Export chat'),
                            ),
                            !leftStatus
                                ? const PopupMenuItem<String>(
                                    value: '7',
                                    child: Text('Exit chat'),
                                  )
                                : const PopupMenuItem<String>(
                                    // value: '7',
                                    child: Text('You are left'),
                                  ),
                          ],
                          onSelected: (String value) {
                            // Do something when a menu item is selected
                            print('You selected $value');
                            if (value == '1') {
                              grp.getGroupInfo(
                                  groupId: messageData.id.toString(),
                                  context: context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => GroupInfo(
                                          groupId: messageData.id.toString())));
                            }
                            if (value == '2') {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => MediaGroup(
                                    recName: messageData.groupName,
                                    recId: messageData.id.toString()),
                              ));
                            }
                            if (value == '3') {
                              if (muteStatus == '0') {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    String selectedOption = '';

                                    return AlertDialog(
                                      title: const Text('Mute Notification'),
                                      content: StatefulBuilder(
                                        builder: (BuildContext context,
                                            StateSetter setState) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              RadioListTile(
                                                title: const Text('8 hours'),
                                                value: '8_hours',
                                                groupValue: selectedOption,
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedOption = value!;
                                                  });
                                                },
                                              ),
                                              RadioListTile(
                                                title: const Text('1 Week'),
                                                value: '1_week',
                                                groupValue: selectedOption,
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedOption = value!;
                                                  });
                                                },
                                              ),
                                              RadioListTile(
                                                title: const Text('Always'),
                                                value: 'always',
                                                groupValue: selectedOption,
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedOption = value!;
                                                  });
                                                },
                                              ),
                                              Row(
                                                children: [
                                                  Checkbox(
                                                    value: showN,
                                                    onChanged: (newValue) {
                                                      setState(() {
                                                        showN = newValue;
                                                      });
                                                    },
                                                    activeColor: Colors.green,
                                                    checkColor: Colors.white,
                                                  ),
                                                  const Text(
                                                      'Show Notifications'),
                                                ],
                                              )
                                            ],
                                          );
                                        },
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text('OK'),
                                          onPressed: () {
                                            // Do something with the selected option
                                            cdp.muteGroupChatNotification(
                                              groupId: groupId.toString(),
                                              status: showN! ? '1' : '0',
                                              type: selectedOption,
                                              context: context,
                                            );
                                            if (jsonDecode(cdp.resMessage)[
                                                    'message'] ==
                                                'success') {
                                              muteStatus = '1';
                                            }
                                            // cdp.groupChatDetail(
                                            //     groupId: groupId.toString(),
                                            //     accessToken: accessToken,
                                            //     userId: userId);

                                            // print(cdp.realGrpData[
                                            //     'mute_end_datetime']);
                                            Navigator.of(context).pop();

                                            // Navigator.pop(context);

                                            // if (jsonDecode(
                                            //         cdp.resMessage)['message'] ==
                                            //     "success") {
                                            //   grp.getGroupInfo(
                                            //     groupId: cdp.receiverId,
                                            //     context: context,
                                            //   );
                                            //   // Navigator.pop(context);
                                            // }
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                cdp.unmuteGroupchatNotification(
                                    receiverId: widget.gId.toString(),
                                    context: context);
                                if (jsonDecode(cdp.resMessage)['message'] ==
                                    'success') {
                                  muteStatus = '0';
                                }
                              }
                            }
                            if (value == '4') {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  bool isChecked = false;

                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return AlertDialog(
                                        title: Text(
                                          'Report ${messageData.groupName}?',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            // Text(
                                            //  'This contact will not be notified.',
                                            //   style: TextStyle(
                                            //     fontSize: 12,
                                            //     color: textGreen,
                                            //   ),
                                            // ),
                                            Row(
                                              children: [
                                                Checkbox(
                                                  value: isChecked,
                                                  onChanged: (value) {
                                                    print(value);
                                                    setState(() {
                                                      isChecked = value!;
                                                    });
                                                    print(isChecked);
                                                  },
                                                ),
                                                const Text(
                                                  'Exit from group',
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: Text('Cancel',
                                                  style: TextStyle(
                                                      color: textGreen,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 18))),
                                          TextButton(
                                              onPressed: () {
                                                if (_socket.connected) {
                                                  var body = {
                                                    'user_id': auth.userId,
                                                    'accessToken':
                                                        auth.accessToken,
                                                    'group_id': groupId,
                                                  };
                                                  if (isChecked) {
                                                    body['exit'] = '1';
                                                  } else {
                                                    body['exit'] = '0';
                                                  }

                                                  _socket.emit(
                                                      'report_and_left_group_chat',
                                                      body);
                                                  _socket.on(
                                                      'report_and_left_group_chat',
                                                      (data) {
                                                    if (data['message'] ==
                                                        'success') {
                                                      Navigator.pushAndRemoveUntil(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (_) =>
                                                                  const HomeScreen()),
                                                          (route) => false);
                                                    }
                                                  });
                                                } else {
                                                  _connectSocket();
                                                  var body = {
                                                    'user_id': auth.userId,
                                                    'accessToken':
                                                        auth.accessToken,
                                                    'group_id': groupId,
                                                  };

                                                  _socket.emit(
                                                      'report_and_left_group_chat',
                                                      body);
                                                  _socket.on(
                                                      'report_and_left_group_chat',
                                                      (data) {
                                                    if (data['message'] ==
                                                        'success') {
                                                      Navigator.pushAndRemoveUntil(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (_) =>
                                                                  const HomeScreen()),
                                                          (route) => false);
                                                    }
                                                  });
                                                }
                                              },
                                              child: Text('Ok',
                                                  style: TextStyle(
                                                      color: textGreen,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 18))),
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            }
                            if (value == '5') {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  bool isChecked = false;

                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return AlertDialog(
                                        title: Text(
                                          'Clear ${messageData.groupName} Chat?',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            // Text(
                                            //  'This contact will not be notified.',
                                            //   style: TextStyle(
                                            //     fontSize: 12,
                                            //     color: textGreen,
                                            //   ),
                                            // ),
                                            Row(
                                              children: [
                                                Checkbox(
                                                  value: isChecked,
                                                  onChanged: (value) {
                                                    print(value);
                                                    setState(() {
                                                      isChecked = value!;
                                                    });
                                                    print(isChecked);
                                                  },
                                                ),
                                                const Text(
                                                  'Delete Starred massage',
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: Text('Cancel',
                                                  style: TextStyle(
                                                      color: textGreen,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 18))),
                                          TextButton(
                                              onPressed: () {
                                                if (_socket.connected) {
                                                  var body = {
                                                    'user_id': auth.userId,
                                                    'accessToken':
                                                        auth.accessToken,
                                                    'group_id': groupId,
                                                  };
                                                  if (isChecked) {
                                                    body['delete_starred_message'] =
                                                        '1';
                                                  } else {
                                                    body['delete_starred_message'] =
                                                        '0';
                                                  }

                                                  _socket.emit(
                                                      'clear_group_chat', body);
                                                  _socket.on('clear_group_chat',
                                                      (data) {
                                                    if (data['message'] ==
                                                        'success') {
                                                      Navigator.of(context)
                                                          .pop();
                                                      // Navigator.pushAndRemoveUntil(
                                                      //     context,
                                                      //     MaterialPageRoute(
                                                      //         builder: (_) =>
                                                      //             HomeScreen()),
                                                      //     (route) => false);
                                                    }
                                                  });
                                                } else {
                                                  var body = {
                                                    'user_id': auth.userId,
                                                    'accessToken':
                                                        auth.accessToken,
                                                    'group_id': groupId,
                                                  };

                                                  _socket.emit(
                                                      'clear_group_chat', body);
                                                  _socket.on('clear_group_chat',
                                                      (data) {
                                                    if (data['message'] ==
                                                        'success') {
                                                      Navigator.pushAndRemoveUntil(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (_) =>
                                                                  const HomeScreen()),
                                                          (route) => false);
                                                    }
                                                  });
                                                }
                                              },
                                              child: Text('Ok',
                                                  style: TextStyle(
                                                      color: textGreen,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 18))),
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            }
                            if (value == '6') {
                              var body = {
                                'user_id': auth.userId,
                                'accessToken': auth.accessToken,
                                'room': widget.gId
                              };

                              if (_socket.connected) {
                                _socket.on('group_chat_export_data', (data) {
                                  print("######################3");
                                  print(data);
                                  print("######################3");
                                  String exportData = jsonEncode(data['data']);
                                  exportChat(exportData);
                                });
                                _socket.emit('group_chat_export_data', body);
                              }
                            }
                            if (value == '7') {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  bool isChecked = false;
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return AlertDialog(
                                        title: Text(
                                          'Exit ${messageData.groupName}?',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        // content: Column(
                                        //   mainAxisSize:
                                        //       MainAxisSize.min,
                                        //   children: <Widget>[
                                        //     Text(
                                        //       'This contact will not be notified.',
                                        //       style: TextStyle(
                                        //         fontSize: 12,
                                        //         color: textGreen,
                                        //       ),
                                        //     ),
                                        //     Row(
                                        //       children: [
                                        //         Checkbox(
                                        //           value: isChecked,
                                        //           onChanged:
                                        //               (value) {
                                        //             print(value);
                                        //             setState(() {
                                        //               isChecked =
                                        //                   value!;
                                        //             });
                                        //             print(
                                        //                 isChecked);
                                        //           },
                                        //         ),
                                        //         Text(
                                        //           'Clear chat!',
                                        //           style: TextStyle(
                                        //               color: Colors
                                        //                   .grey,
                                        //               fontWeight:
                                        //                   FontWeight
                                        //                       .bold),
                                        //         ),
                                        //       ],
                                        //     ),
                                        //   ],
                                        // ),
                                        actions: <Widget>[
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: Text('Cancel',
                                                  style: TextStyle(
                                                      color: textGreen,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 18))),
                                          TextButton(
                                              onPressed: () {
                                                if (_socket.connected) {
                                                  var body = {
                                                    'user_id': auth.userId,
                                                    'accessToken':
                                                        auth.accessToken,
                                                    'group_id': widget.gId,
                                                  };

                                                  _socket.emit(
                                                      'exit_group_member',
                                                      body);
                                                  _socket
                                                      .on('exit_group_member',
                                                          (data) {
                                                    if (data['message'] ==
                                                        'success') {
                                                      _destroySocket();
                                                      Navigator.pushAndRemoveUntil(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (_) =>
                                                                  const HomeScreen()),
                                                          (route) => false);
                                                    }
                                                  });
                                                } else {
                                                  _connectSocket();
                                                  var body = {
                                                    'user_id': auth.userId,
                                                    'accessToken':
                                                        auth.accessToken,
                                                    'group_id': widget.gId,
                                                  };

                                                  _socket.emit(
                                                      'exit_group_member',
                                                      body);
                                                  _socket
                                                      .on('exit_group_member',
                                                          (data) {
                                                    if (data['message'] ==
                                                        'success') {
                                                      _destroySocket();
                                                      Navigator.pushAndRemoveUntil(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (_) =>
                                                                  const HomeScreen()),
                                                          (route) => false);
                                                    }
                                                  });
                                                }
                                              },
                                              child: Text('Ok',
                                                  style: TextStyle(
                                                      color: textGreen,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 18))),
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            }
                          },
                          icon: const Icon(Icons.more_vert),
                        ),
                        // IconButton(
                        //     onPressed: () {
                        //       print("ho");

                        //     },
                        //     icon: Icon(
                        //       Icons.more_vert,
                        //       color: Colors.white,
                        //     ))
                      ],
                    ),
              body: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(splashBg), fit: BoxFit.fill)),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .11,
                      ),
                      Expanded(
                        child: ScrollablePositionedList.builder(
                          //shrinkWrap: true,
                          initialScrollIndex: messageList.length,
                          itemScrollController: itemScrollController,
                          itemPositionsListener: itemPositionsListener,
                          key: PageStorageKey(messageList.length),
                          itemCount: messageList.length,
                          itemBuilder: (context, index) {
                            final now = DateTime.now();
                            // messageList[index].optional = '0';
                            String formatter =
                                DateFormat('dd/MM/yyyy hh:mm a').format(now);
                            DateTime dateTime = dateFormat
                                .parse(messageList[index].date.toString());
                            String formattedDate = dateFormat2.format(dateTime);

                            print(':::[TESTING]:::');
                            print(messageList[index].replaySenter);
                            print(':::[TESTING]:::');
                            print(messageList[index].thumbnail);
                            print('---------------------');
                            if (messageList[index].type == 'date') if (formatter
                                    .substring(0, 10) ==
                                formattedDate.substring(0, 10)) {
                              return Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: const Color(0xff63d982),
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    child: const Text(
                                      'Today',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: const Color(0xff63d982),
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    child: Text(
                                      formattedDate.substring(0, 10),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              );
                            }

                            if (messageList[index].type == 'notification') {
                              //print(messageList[index].message.contains('changed the group description. Tap to view.'));
                              return InkWell(
                                onTap: () {
                                  if (messageList[index].message.contains(
                                      'changed the group description. Tap to view.')) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => GroupInfo(
                                                groupId: messageData.id
                                                    .toString())));
                                  }
                                },
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: const Color(0xff63d982),
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: Text(
                                        messageList[index].message,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }

                            if (messageList[index].senterId == auth.userId) {
                              isSender = true;
                              print(
                                  'status---${messageList[index].deleteStatus}');
                              if (messageList[index].messageType ==
                                  'location') {
                                return messageList[index].deleteStatus == '0'
                                    ? InkWell(
                                        onLongPress: () {
                                          if (!longPress) {
                                            longPressStarred(
                                                messageList[index]);
                                          }
                                        },
                                        onTap: () {
                                          onTapStarred(
                                              messageList[index], messageList);
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
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 3),
                                                child: Container(
                                                  color: Colors.transparent,
                                                  constraints: BoxConstraints(
                                                      maxWidth:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .8),
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 16,
                                                      vertical: 2),
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 3),
                                                    decoration: BoxDecoration(
                                                      color: messageList[index]
                                                                  .messageStatus ==
                                                              '1'
                                                          ? rightGreen
                                                          : Colors.blue,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topLeft:
                                                            Radius.circular(15),
                                                        topRight:
                                                            Radius.circular(15),
                                                        bottomLeft:
                                                            Radius.circular(15),
                                                      ),
                                                    ),
                                                    child: messageList[index]
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
                                                                    Icons.block,
                                                                    color: Colors
                                                                        .white),
                                                                Text(
                                                                  messageList[
                                                                          index]
                                                                      .message,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic,
                                                                    color: Colors
                                                                        .white,
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
                                                                child: InkWell(
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
                                                                      ScaffoldMessenger.of(
                                                                              context)
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
                                                                        const EdgeInsets
                                                                            .all(8),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: messageList[index].messageStatus ==
                                                                              '1'
                                                                          ? rightGreen
                                                                          : Colors
                                                                              .blue,
                                                                      borderRadius:
                                                                          const BorderRadius
                                                                              .only(
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
                                                                          MainAxisSize
                                                                              .min,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .end,
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
                                                                            myLocationButtonEnabled:
                                                                                false,
                                                                            zoomControlsEnabled:
                                                                                false,
                                                                            mapType:
                                                                                MapType.hybrid,
                                                                            onMapCreated:
                                                                                _onMapCreated,
                                                                            initialCameraPosition:
                                                                                CameraPosition(
                                                                              target: LatLng(double.parse(messageList[index].message.split(',').first), double.parse(messageList[index].message.split(',').last)),
                                                                              zoom: 15,
                                                                            ),
                                                                            onTap:
                                                                                (argument) async {
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
                                                                        const SizedBox(
                                                                            height:
                                                                                3),
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
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
                                                                  height: 3),
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
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
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    : SwipeTo(
                                        onLeftSwipe: () {
                                          if (!longPress) {
                                            if (messageList[index]
                                                    .deleteStatus ==
                                                '1') {
                                              getValue(
                                                  messageList[index].id,
                                                  messageList[index].message,
                                                  messageList[index].senterId,
                                                  messageList[index].name,
                                                  messageList[index]
                                                      .messageType);
                                            }
                                          }
                                        },
                                        child: InkWell(
                                          onLongPress: () {
                                            if (!longPress) {
                                              longPressStarred(
                                                  messageList[index]);
                                            }
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
                                                      .symmetric(horizontal: 3),
                                                  child: Container(
                                                    color: Colors.transparent,
                                                    constraints: BoxConstraints(
                                                        maxWidth: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .8),
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 16,
                                                        vertical: 2),
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 3),
                                                      decoration: BoxDecoration(
                                                        color: messageList[
                                                                        index]
                                                                    .messageStatus ==
                                                                '1'
                                                            ? rightGreen
                                                            : Colors.blue,
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  15),
                                                          topRight:
                                                              Radius.circular(
                                                                  15),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  15),
                                                        ),
                                                      ),
                                                      child: messageList[index]
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
                                                                      color: Colors
                                                                          .white),
                                                                  Text(
                                                                    messageList[
                                                                            index]
                                                                        .message,
                                                                    style:
                                                                        const TextStyle(
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .italic,
                                                                      color: Colors
                                                                          .white,
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
                                                                          BoxDecoration(
                                                                        color: messageList[index].messageStatus ==
                                                                                '1'
                                                                            ? rightGreen
                                                                            : Colors.blue,
                                                                        borderRadius:
                                                                            const BorderRadius.only(
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
                                                                          const SizedBox(
                                                                              height: 3),
                                                                          Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
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
                              if (messageList[index].messageType != 'voice') {
                                return messageList[index].deleteStatus == '0'
                                    ? Container(
                                        color: messageId
                                                .contains(messageList[index].id)
                                            ? Colors.black38
                                            : const Color.fromARGB(0, 0, 0, 0),
                                        child: InkWell(
                                          onLongPress: () {
                                            if (!longPress) {
                                              longPressStarred(
                                                  messageList[index]);
                                            }
                                            // longPressStarred(messageList[index]);
                                          },
                                          onTap: () {
                                            onTapStarred(messageList[index],
                                                messageList);
                                          },
                                          // child: InkWell(
                                          // onTap: () {
                                          //   if (messageList[index]
                                          //       .replayMessage
                                          //       .isNotEmpty) {
                                          //     String searchId =
                                          //         messageList[index].replayId;
                                          //     var searchData = messageList
                                          //         .firstWhere((element) =>
                                          //             element.id == searchId);
                                          //     int goToIdx =
                                          //         messageList.indexOf(searchData);
                                          //     itemScrollController.scrollTo(
                                          //         index: goToIdx,
                                          //         duration: const Duration(
                                          //             milliseconds: 300),
                                          //         curve: Curves.easeOut);
                                          //   }
                                          //   print("EEEEEEEEEEEEEEEEEEEEEE");
                                          //   print(index);
                                          //   print("EEEEEEEEEEEEEEEEEEEEEE");
                                          // },
                                          child: GroupBubble(
                                            thumbnail:
                                                messageList[index].thumbnail,
                                            text: messageList[index].message,
                                            time: messageList[index].date,
                                            color: messageList[index]
                                                        .messageStatus ==
                                                    '1'
                                                ? rightGreen
                                                : Colors.blue,
                                            rplyMessage: messageList[index]
                                                .replayMessage,
                                            rplyColor: messageList[index]
                                                        .messageStatus ==
                                                    '1'
                                                ? Colors.green.shade900
                                                : Colors.blue.shade900,
                                            optionalText:
                                                messageList[index].optionalText,
                                            messageSenter:
                                                messageList[index].name,
                                            messageType:
                                                messageList[index].messageType,
                                            rplyMessageType: messageList[index]
                                                .replayMessageType,
                                            rplyMessageSenter:
                                                messageList[index].replaySenter,
                                            textStyle: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            isSender: isSender,
                                            isDeleted: messageList[index]
                                                        .deleteStatus ==
                                                    '1'
                                                ? false
                                                : true,
                                            isStarred: messageList[index]
                                                        .starredStatus ==
                                                    '0'
                                                ? false
                                                : true,
                                            forwardStatus: messageList[index]
                                                .forwardMessageStatus,
                                          ),
                                          // ),
                                        ),
                                      )
                                    : SwipeTo(
                                        onLeftSwipe: () {
                                          if (!longPress) {
                                            if (messageList[index]
                                                    .deleteStatus ==
                                                '1') {
                                              getValue(
                                                messageList[index].id,
                                                messageList[index].message,
                                                messageList[index].senterId,
                                                messageList[index].name,
                                                messageList[index].messageType,
                                              );
                                            }
                                          }
                                        },
                                        child: Container(
                                          color: messageId.contains(
                                                  messageList[index].id)
                                              ? Colors.black38
                                              : const Color.fromARGB(
                                                  0, 0, 0, 0),
                                          child: InkWell(
                                            onLongPress: () {
                                              if (!longPress) {
                                                longPressStarred(
                                                    messageList[index]);
                                              }
                                              // longPressStarred(messageList[index]);
                                            },
                                            onTap: () {
                                              onTapStarred(messageList[index],
                                                  messageList);
                                            },
                                            // child: InkWell(
                                            // onTap: () {
                                            //   if (messageList[index]
                                            //       .replayMessage
                                            //       .isNotEmpty) {
                                            //     String searchId =
                                            //         messageList[index].replayId;
                                            //     var searchData = messageList
                                            //         .firstWhere((element) =>
                                            //             element.id == searchId);
                                            //     int goToIdx =
                                            //         messageList.indexOf(searchData);
                                            //     itemScrollController.scrollTo(
                                            //         index: goToIdx,
                                            //         duration: const Duration(
                                            //             milliseconds: 300),
                                            //         curve: Curves.easeOut);
                                            //   }
                                            //   print("EEEEEEEEEEEEEEEEEEEEEE");
                                            //   print(index);
                                            //   print("EEEEEEEEEEEEEEEEEEEEEE");
                                            // },
                                            child: GroupBubble(
                                              thumbnail:
                                                  messageList[index].thumbnail,
                                              text: messageList[index].message,
                                              time: messageList[index].date,
                                              color: messageList[index]
                                                          .messageStatus ==
                                                      '1'
                                                  ? rightGreen
                                                  : Colors.blue,
                                              rplyMessage: messageList[index]
                                                  .replayMessage,
                                              rplyColor: messageList[index]
                                                          .messageStatus ==
                                                      '1'
                                                  ? Colors.green.shade900
                                                  : Colors.blue.shade900,
                                              optionalText: messageList[index]
                                                  .optionalText,
                                              messageSenter:
                                                  messageList[index].name,
                                              messageType: messageList[index]
                                                  .messageType,
                                              rplyMessageType:
                                                  messageList[index]
                                                      .replayMessageType,
                                              rplyMessageSenter:
                                                  messageList[index]
                                                      .replaySenter,
                                              textStyle: const TextStyle(
                                                color: Colors.white,
                                              ),
                                              isSender: isSender,
                                              isDeleted: messageList[index]
                                                          .deleteStatus ==
                                                      '1'
                                                  ? false
                                                  : true,
                                              isStarred: messageList[index]
                                                          .starredStatus ==
                                                      '0'
                                                  ? false
                                                  : true,
                                              forwardStatus: messageList[index]
                                                  .forwardMessageStatus,
                                            ),
                                            // ),
                                          ),
                                        ),
                                      );
                              } else {
                                // if (longPress) {
                                //   setState(() {
                                //     longPress = false;
                                //   });
                                // }
                                return messageList[index].deleteStatus == '0'
                                    ? InkWell(
                                        onLongPress: () {
                                          if (!longPress) {
                                            longPressStarred(
                                                messageList[index]);
                                          }
                                          // longPressStarred(messageList[index]);
                                        },
                                        onTap: () {
                                          onTapStarred(
                                              messageList[index], messageList);
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
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 3),
                                                child: Container(
                                                  color: Colors.transparent,
                                                  constraints: BoxConstraints(
                                                      maxWidth:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .8),
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 16,
                                                      vertical: 2),
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 4),
                                                    decoration: BoxDecoration(
                                                      color: messageList[index]
                                                                  .messageStatus ==
                                                              '1'
                                                          ? rightGreen
                                                          : Colors.blue,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topLeft:
                                                            Radius.circular(15),
                                                        topRight:
                                                            Radius.circular(15),
                                                        bottomLeft:
                                                            Radius.circular(15),
                                                      ),
                                                    ),
                                                    child: messageList[index]
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
                                                                    Icons.block,
                                                                    color: Colors
                                                                        .white),
                                                                Text(
                                                                  messageList[
                                                                          index]
                                                                      .message,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic,
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
                                                                        if (voicePlay
                                                                            .isEmpty) {
                                                                          setState(
                                                                              () {
                                                                            voicePlay.add(messageList[index].id);
                                                                          });
                                                                        } else {
                                                                          for (var element
                                                                              in voicePlay) {
                                                                            if (element !=
                                                                                messageList[index].id) {
                                                                              setState(() {
                                                                                voicePlay = [];
                                                                                voicePlay.add(messageList[index].id);
                                                                              });
                                                                            }
                                                                          }
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
                                                                        : sliderDummy()
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
                                                                        .end,
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
                                        onLeftSwipe: () {
                                          if (!longPress) {
                                            if (messageList[index]
                                                    .deleteStatus ==
                                                '1') {
                                              getValue(
                                                  messageList[index].id,
                                                  messageList[index].message,
                                                  messageList[index].senterId,
                                                  messageList[index].name,
                                                  messageList[index]
                                                      .messageType);
                                            }
                                          }
                                        },
                                        child: InkWell(
                                          onLongPress: () {
                                            if (!longPress) {
                                              longPressStarred(
                                                  messageList[index]);
                                            }
                                            // longPressStarred(messageList[index]);
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
                                                      .symmetric(horizontal: 3),
                                                  child: Container(
                                                    color: Colors.transparent,
                                                    constraints: BoxConstraints(
                                                        maxWidth: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .8),
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 16,
                                                        vertical: 2),
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 4),
                                                      decoration: BoxDecoration(
                                                        color: messageList[
                                                                        index]
                                                                    .messageStatus ==
                                                                '1'
                                                            ? rightGreen
                                                            : Colors.blue,
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  15),
                                                          topRight:
                                                              Radius.circular(
                                                                  15),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  15),
                                                        ),
                                                      ),
                                                      child: messageList[index]
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
                                                                      color: Colors
                                                                          .white),
                                                                  Text(
                                                                    messageList[
                                                                            index]
                                                                        .message,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .italic,
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
                                                                          if (voicePlay
                                                                              .isEmpty) {
                                                                            setState(() {
                                                                              voicePlay.add(messageList[index].id);
                                                                            });
                                                                          } else {
                                                                            for (var element
                                                                                in voicePlay) {
                                                                              if (element != messageList[index].id) {
                                                                                setState(() {
                                                                                  voicePlay = [];
                                                                                  voicePlay.add(messageList[index].id);
                                                                                });
                                                                              }
                                                                            }
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
                                                                          : sliderDummy()
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
                                return messageList[index].deleteStatus == '0'
                                    ? InkWell(
                                        onLongPress: () {
                                          if (!longPress) {
                                            longPressStarred(
                                                messageList[index]);
                                          }
                                          // longPressStarred(messageList[index]);
                                        },
                                        onTap: () {
                                          onTapStarred(
                                              messageList[index], messageList);
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
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 3),
                                                child: Container(
                                                  color: Colors.transparent,
                                                  constraints: BoxConstraints(
                                                      maxWidth:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .8),
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 16,
                                                      vertical: 2),
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 3),
                                                    decoration: BoxDecoration(
                                                      color: messageList[index]
                                                                  .messageStatus ==
                                                              '1'
                                                          ? rightGreen
                                                          : Colors.blue,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topLeft:
                                                            Radius.circular(15),
                                                        topRight:
                                                            Radius.circular(15),
                                                        bottomLeft:
                                                            Radius.circular(15),
                                                      ),
                                                    ),
                                                    child: messageList[index]
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
                                                                    Icons.block,
                                                                    color: Colors
                                                                        .white),
                                                                Text(
                                                                  messageList[
                                                                          index]
                                                                      .message,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic,
                                                                    color: Colors
                                                                        .white,
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
                                                                child: InkWell(
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
                                                                      ScaffoldMessenger.of(
                                                                              context)
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
                                                                        const EdgeInsets
                                                                            .all(8),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: messageList[index].messageStatus ==
                                                                              '1'
                                                                          ? rightGreen
                                                                          : Colors
                                                                              .blue,
                                                                      borderRadius:
                                                                          const BorderRadius
                                                                              .only(
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
                                                                          MainAxisSize
                                                                              .min,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .end,
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
                                                                            myLocationButtonEnabled:
                                                                                false,
                                                                            zoomControlsEnabled:
                                                                                false,
                                                                            mapType:
                                                                                MapType.hybrid,
                                                                            onMapCreated:
                                                                                _onMapCreated,
                                                                            initialCameraPosition:
                                                                                CameraPosition(
                                                                              target: LatLng(double.parse(messageList[index].message.split(',').first), double.parse(messageList[index].message.split(',').last)),
                                                                              zoom: 15,
                                                                            ),
                                                                            onTap:
                                                                                (argument) async {
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
                                                                        const SizedBox(
                                                                            height:
                                                                                3),
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
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
                                                                  height: 3),
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
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
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    : SwipeTo(
                                        onLeftSwipe: () {
                                          if (!longPress) {
                                            if (messageList[index]
                                                    .deleteStatus ==
                                                '1') {
                                              getValue(
                                                  messageList[index].id,
                                                  messageList[index].message,
                                                  messageList[index].senterId,
                                                  messageList[index].name,
                                                  messageList[index]
                                                      .messageType);
                                            }
                                          }
                                        },
                                        child: InkWell(
                                          onLongPress: () {
                                            if (!longPress) {
                                              longPressStarred(
                                                  messageList[index]);
                                            }
                                            // longPressStarred(messageList[index]);
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
                                                      .symmetric(horizontal: 3),
                                                  child: Container(
                                                    color: Colors.transparent,
                                                    constraints: BoxConstraints(
                                                        maxWidth: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .8),
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 16,
                                                        vertical: 2),
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 3),
                                                      decoration: BoxDecoration(
                                                        color: messageList[
                                                                        index]
                                                                    .messageStatus ==
                                                                '1'
                                                            ? rightGreen
                                                            : Colors.blue,
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  15),
                                                          topRight:
                                                              Radius.circular(
                                                                  15),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  15),
                                                        ),
                                                      ),
                                                      child: messageList[index]
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
                                                                      color: Colors
                                                                          .white),
                                                                  Text(
                                                                    messageList[
                                                                            index]
                                                                        .message,
                                                                    style:
                                                                        const TextStyle(
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .italic,
                                                                      color: Colors
                                                                          .white,
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
                                                                          BoxDecoration(
                                                                        color: messageList[index].messageStatus ==
                                                                                '1'
                                                                            ? rightGreen
                                                                            : Colors.blue,
                                                                        borderRadius:
                                                                            const BorderRadius.only(
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
                                                                          const SizedBox(
                                                                              height: 3),
                                                                          Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
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
                              if (messageList[index].messageType != 'voice') {
                                return messageList[index].deleteStatus == '0'
                                    ? Container(
                                        color: messageId
                                                .contains(messageList[index].id)
                                            ? Colors.black38
                                            : const Color.fromARGB(0, 0, 0, 0),
                                        child: InkWell(
                                          onLongPress: () {
                                            if (!longPress) {
                                              longPressStarred(
                                                  messageList[index]);
                                            }
                                            // longPressStarred(messageList[index]);
                                            // print(messageList[index].thumbnail);
                                          },
                                          onTap: () {
                                            onTapStarred(messageList[index],
                                                messageList);
                                          },
                                          child: GroupBubble(
                                            thumbnail:
                                                messageList[index].thumbnail,
                                            text: messageList[index].message,
                                            time: messageList[index].date,
                                            color: Colors.grey,
                                            rplyMessage: messageList[index]
                                                .replayMessage,
                                            rplyColor: messageList[index]
                                                        .messageStatus ==
                                                    '1'
                                                ? Colors.green.shade900
                                                : Colors.blue.shade900,
                                            optionalText:
                                                messageList[index].optionalText,
                                            messageSenter:
                                                messageList[index].name,
                                            messageType:
                                                messageList[index].messageType,
                                            rplyMessageType: messageList[index]
                                                .replayMessageType,
                                            rplyMessageSenter:
                                                messageList[index].replaySenter,
                                            textStyle: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            isSender: isSender,
                                            isDeleted: messageList[index]
                                                        .deleteStatus ==
                                                    '1'
                                                ? false
                                                : true,
                                            isStarred: messageList[index]
                                                        .starredStatus ==
                                                    '0'
                                                ? false
                                                : true,
                                            forwardStatus: messageList[index]
                                                .forwardMessageStatus,
                                          ),
                                        ),
                                      )
                                    : SwipeTo(
                                        onRightSwipe: () {
                                          if (!longPress) {
                                            if (messageList[index]
                                                    .deleteStatus ==
                                                '1') {
                                              getValue(
                                                messageList[index].id,
                                                messageList[index].message,
                                                messageList[index].senterId,
                                                messageList[index].name,
                                                messageList[index].messageType,
                                              );
                                            }
                                          }
                                        },
                                        child: Container(
                                          color: messageId.contains(
                                                  messageList[index].id)
                                              ? Colors.black38
                                              : const Color.fromARGB(
                                                  0, 0, 0, 0),
                                          child: InkWell(
                                            onLongPress: () {
                                              if (!longPress) {
                                                longPressStarred(
                                                    messageList[index]);
                                              }
                                              // longPressStarred(messageList[index]);
                                              // print(messageList[index].thumbnail);
                                            },
                                            onTap: () {
                                              onTapStarred(messageList[index],
                                                  messageList);
                                            },
                                            child: GroupBubble(
                                              thumbnail:
                                                  messageList[index].thumbnail,
                                              text: messageList[index].message,
                                              time: messageList[index].date,
                                              color: Colors.grey,
                                              rplyMessage: messageList[index]
                                                  .replayMessage,
                                              rplyColor: messageList[index]
                                                          .messageStatus ==
                                                      '1'
                                                  ? Colors.green.shade900
                                                  : Colors.blue.shade900,
                                              optionalText: messageList[index]
                                                  .optionalText,
                                              messageSenter:
                                                  messageList[index].name,
                                              messageType: messageList[index]
                                                  .messageType,
                                              rplyMessageType:
                                                  messageList[index]
                                                      .replayMessageType,
                                              rplyMessageSenter:
                                                  messageList[index]
                                                      .replaySenter,
                                              textStyle: const TextStyle(
                                                color: Colors.white,
                                              ),
                                              isSender: isSender,
                                              isDeleted: messageList[index]
                                                          .deleteStatus ==
                                                      '1'
                                                  ? false
                                                  : true,
                                              isStarred: messageList[index]
                                                          .starredStatus ==
                                                      '0'
                                                  ? false
                                                  : true,
                                              forwardStatus: messageList[index]
                                                  .forwardMessageStatus,
                                            ),
                                          ),
                                        ),
                                      );
                              } else {
                                return messageList[index].deleteStatus == '0'
                                    ? InkWell(
                                        onLongPress: () {
                                          if (!longPress) {
                                            longPressStarred(
                                                messageList[index]);
                                          }
                                          // longPressStarred(messageList[index]);
                                        },
                                        onTap: () {
                                          onTapStarred(
                                              messageList[index], messageList);
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
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 3),
                                                child: Container(
                                                  color: Colors.transparent,
                                                  constraints: BoxConstraints(
                                                      maxWidth:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .8),
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 16,
                                                      vertical: 2),
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 4),
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.grey,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(15),
                                                        topRight:
                                                            Radius.circular(15),
                                                        bottomLeft:
                                                            Radius.circular(15),
                                                      ),
                                                    ),
                                                    child: messageList[index]
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
                                                                    Icons.block,
                                                                    color: Colors
                                                                        .white),
                                                                Text(
                                                                  messageList[
                                                                          index]
                                                                      .message,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic,
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
                                                                        if (voicePlay
                                                                            .isEmpty) {
                                                                          setState(
                                                                              () {
                                                                            voicePlay.add(messageList[index].id);
                                                                          });
                                                                        } else {
                                                                          for (var element
                                                                              in voicePlay) {
                                                                            if (element !=
                                                                                messageList[index].id) {
                                                                              setState(() {
                                                                                voicePlay = [];
                                                                                voicePlay.add(messageList[index].id);
                                                                              });
                                                                            }
                                                                          }
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
                                                                        : sliderDummy()
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
                                                                        .end,
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
                                        onLeftSwipe: () {
                                          if (!longPress) {
                                            if (messageList[index]
                                                    .deleteStatus ==
                                                '1') {
                                              getValue(
                                                  messageList[index].id,
                                                  messageList[index].message,
                                                  messageList[index].senterId,
                                                  messageList[index].name,
                                                  messageList[index]
                                                      .messageType);
                                            }
                                          }
                                        },
                                        child: InkWell(
                                          onLongPress: () {
                                            if (!longPress) {
                                              longPressStarred(
                                                  messageList[index]);
                                            }
                                            // longPressStarred(messageList[index]);
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
                                                      .symmetric(horizontal: 3),
                                                  child: Container(
                                                    color: Colors.transparent,
                                                    constraints: BoxConstraints(
                                                        maxWidth: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .8),
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 16,
                                                        vertical: 2),
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 4),
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors.grey,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  15),
                                                          topRight:
                                                              Radius.circular(
                                                                  15),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  15),
                                                        ),
                                                      ),
                                                      child: messageList[index]
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
                                                                      color: Colors
                                                                          .white),
                                                                  Text(
                                                                    messageList[
                                                                            index]
                                                                        .message,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .italic,
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
                                                                          if (voicePlay
                                                                              .isEmpty) {
                                                                            setState(() {
                                                                              voicePlay.add(messageList[index].id);
                                                                            });
                                                                          } else {
                                                                            for (var element
                                                                                in voicePlay) {
                                                                              if (element != messageList[index].id) {
                                                                                setState(() {
                                                                                  voicePlay = [];
                                                                                  voicePlay.add(messageList[index].id);
                                                                                });
                                                                              }
                                                                            }
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
                                                                          : sliderDummy()
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
                      leftStatus
                          ? Align(
                              alignment: Alignment.bottomCenter,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                10,
                                        height: 70,
                                        child: Card(
                                          margin: const EdgeInsets.only(
                                              left: 2, right: 2, bottom: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          child: Center(
                                            child: Text(
                                                "You can't send message to this group \n       you're no longer a participant"),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // show ? emojiPicker() : Container(),
                                  // vwe ? bottomContainer() : Container()
                                ],
                              ),
                            )
                          : Align(
                              alignment: Alignment.bottomCenter,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      rply
                                          ? SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  60,
                                              height: 120,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            60,
                                                    height: 50,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 20,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: leftGreen,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topLeft:
                                                            Radius.circular(25),
                                                        topRight:
                                                            Radius.circular(25),
                                                      ),
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
                                                                  : '$sndName',
                                                              style: TextStyle(
                                                                  color:
                                                                      textGreen,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            if (msgTyp ==
                                                                'text')
                                                              Expanded(
                                                                child: Text(
                                                                  '$replyMsg',
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            if (msgTyp ==
                                                                'voice')
                                                              Row(
                                                                children: const [
                                                                  Icon(
                                                                      Icons.mic,
                                                                      color: Colors
                                                                          .white),
                                                                  Text(
                                                                    'Voice Message',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
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
                                                                        color: Colors
                                                                            .white),
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
                                                                        color: Colors
                                                                            .white),
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
                                                                  rply = false;
                                                                  replyMsg = '';
                                                                  replyId = '';
                                                                  senderId = '';
                                                                  sndName = '';
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
                                                                  rply = false;
                                                                  replyMsg = '';
                                                                  replyId = '';
                                                                  senderId = '';
                                                                  sndName = '';
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
                                                                          setState(
                                                                              () {
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
                                                                            msgTyp =
                                                                                '';
                                                                          });
                                                                        },
                                                                        icon: const Icon(
                                                                            Icons
                                                                                .close,
                                                                            color:
                                                                                Colors.white,
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
                                                                      bottom: 2,
                                                                      right: 4,
                                                                      child:
                                                                          Container(
                                                                        child:
                                                                            const Center(
                                                                          child:
                                                                              Icon(
                                                                            Icons.play_circle_outline_outlined,
                                                                            color:
                                                                                Colors.white,
                                                                            size:
                                                                                14,
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
                                                                          setState(
                                                                              () {
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
                                                                            msgTyp =
                                                                                '';
                                                                          });
                                                                        },
                                                                        icon: const Icon(
                                                                            Icons
                                                                                .close,
                                                                            color:
                                                                                Colors.white,
                                                                            size: 18)),
                                                              ),
                                                            ],
                                                          ),
                                                      ],
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
                                                      child: TextFormField(
                                                        controller: _controller,
                                                        focusNode: focusNode,
                                                        textAlignVertical:
                                                            TextAlignVertical
                                                                .center,
                                                        keyboardType:
                                                            TextInputType
                                                                .multiline,
                                                        maxLines: 5,
                                                        minLines: 1,
                                                        onChanged: (Value) {
                                                          if (_controller
                                                                  .text.length >
                                                              0) {
                                                            setState(() {
                                                              sndBtn = true;
                                                            });
                                                          } else {
                                                            setState(() {
                                                              sndBtn = false;
                                                            });
                                                          }
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              InputBorder.none,
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
                                                                    if (show) {
                                                                      setState(
                                                                          () {
                                                                        show =
                                                                            false;
                                                                      });
                                                                    } else {
                                                                      setState(
                                                                          () {
                                                                        show =
                                                                            false;
                                                                      });
                                                                    }
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
                                                                  print(
                                                                      'swipe');
                                                                  setState(() {
                                                                    vwe = !vwe;
                                                                  });
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
                                                                      Icons.add,
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

                                                            // return Text(
                                                            //     '$twoDigitMinutes:$twoDigitSeconds');
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
                                                          onChanged: (value) {
                                                            if (_controller.text
                                                                    .length >
                                                                0) {
                                                              setState(() {
                                                                sndBtn = true;
                                                                _socket.emit(
                                                                    'type_group',
                                                                    {
                                                                      'sid': auth
                                                                          .userId,
                                                                      'room':
                                                                          groupId,
                                                                      'status':
                                                                          '1'
                                                                    });
                                                                _socket.on(
                                                                    'type_group',
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
                                                          onTap: () {
                                                            if (vwe) {
                                                              setState(() {
                                                                vwe = false;
                                                              });
                                                            } else {
                                                              setState(() {
                                                                vwe = false;
                                                              });
                                                            }

                                                            if (show) {
                                                              setState(() {
                                                                show = false;
                                                              });
                                                            } else {
                                                              setState(() {
                                                                show = false;
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
                                                                    print(
                                                                        'clicked plus');
                                                                    setState(
                                                                        () {
                                                                      vwe =
                                                                          !vwe;
                                                                    });
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
                                                      setState(() {
                                                        if (rply) {
                                                          print('reply');
                                                          var body = {
                                                            'sid': auth.userId,
                                                            'room': groupId,
                                                            'message':
                                                                _controller
                                                                    .value.text,
                                                            'message_id':
                                                                replyId,
                                                            'type': 'text',
                                                            'accessToken':
                                                                auth.accessToken
                                                          };

                                                          print(body);
                                                          _socket.emit(
                                                              'message', body);
                                                          _controller.clear();
                                                          sndBtn = false;
                                                          rply = false;
                                                        } else {
                                                          _socket
                                                              .emit('message', {
                                                            'sid': auth.userId,
                                                            'room': groupId,
                                                            'message':
                                                                _controller
                                                                    .value.text,
                                                            'type': 'text'
                                                          });
                                                          _controller.clear();
                                                          sndBtn = false;
                                                          _socket.emit(
                                                              'type_group', {
                                                            'sid': auth.userId,
                                                            'room': groupId,
                                                            'status': '0'
                                                          });
                                                          _socket
                                                              .on('type_group',
                                                                  (data) {
                                                            print(
                                                                'RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR');
                                                            print(data);
                                                            print(
                                                                'RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR');
                                                          });
                                                        }
                                                      });
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
                                                    Colors.transparent,
                                                radius: 25,
                                                child: IconButton(
                                                    onPressed: () async {
                                                      if (recorder
                                                              .isRecording ||
                                                          recorder.isPaused) {
                                                        await stop(
                                                            rply ? true : false,
                                                            false);
                                                      } else {
                                                        await record();
                                                      }
                                                      setState(() {});
                                                    },
                                                    icon: recorder.isRecording
                                                        ? Icon(Icons.stop,
                                                            color: rightGreen)
                                                        : ImageIcon(
                                                            AssetImage(
                                                                microPhoneIcon),
                                                            color: rightGreen,
                                                          )),
                                              ),
                                            )
                                    ],
                                  ),
                                  show ? emojiPicker() : Container(),
                                  vwe ? bottomContainer() : Container()
                                ],
                              ),
                            )
                    ],
                  ),
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
    );
  }

  // void exportChat(String messageList) async {
  //   DateTime now = DateTime.now();
  //   String formattedDate = DateFormat('yyyyMMddkkmm').format(now);
  //   // Parse the JSON string to a list of messages
  //   // final List<dynamic> messages = jsonDecode(messageList);
  //
  //   // Get the user's downloads directory
  //   final directory = await getDownloadsDirectory();
  //   final file = File('/storage/emulated/0/Download/chat${formattedDate}.txt');
  //   await file.writeAsString(messageList).then((value) async {
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
    List expData = [];
    expData = jsonDecode(messageList);
    List dts = [];
    String passdData = '';
    IOSink sink;
    expData.forEach((element) {
      final now = new DateTime.now();
      String formatter = DateFormat('dd MM yyyy HH:mm:ss').format(now);
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
      if (file.existsSync()) {
        file.deleteSync();
      }
      file.createSync();
      //  file.writeAsStringSync('');
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
                          getImage(ImageSource.camera);
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
                          getImage(ImageSource.gallery);
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
                              chatType: 'group',
                              recId: widget.gId,
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
                  // color: Color(0xffE68C78),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.audiotrack,
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

  Future getImage(ImageSource source) async {
    var auth = Provider.of<AuthProvider>(context, listen: false);

    final pick = await ImagePicker().pickImage(source: source);
    if (pick == null) return null;

    File compressedImage = await FlutterNativeImage.compressImage(
      pick.path,
      percentage: 80,
      quality: 100,
    );

    cropImage(compressedImage).then((value) async {
      File imgPath = File(value!.path);
      String url = '${AppUrls.appBaseUrl}fileupload';
      var stream = http.ByteStream(File(imgPath.path).openRead());
      var length = await File(imgPath.path).length();
      var request = http.MultipartRequest('POST', Uri.parse(url));
      var multipartFile = http.MultipartFile('file', stream, length,
          filename: File(imgPath.path).path);
      request.fields['user_id'] = auth.userId;
      request.fields['accessToken'] = auth.accessToken;
      request.files.add(multipartFile);
      var resp = await request.send();

      resp.stream.transform(utf8.decoder).listen((event) {
        var afterResult;
        print(event);
        afterResult = jsonDecode(event);
        fullPath = afterResult['filepath'];
        halfPath = afterResult['path'];

        if (rply) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ImageSendingScreen(
                chatType: 'group',
                fPath: afterResult['filepath'],
                hPath: afterResult['path'],
                recId: groupId.toString(),
                rplyId: replyId,
                fileType: 'image',
              ),
            ),
          );
          setState(() {
            rply = false;
            vwe = !vwe;
          });
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ImageSendingNoRplyScreen(
                chatType: 'group',
                fPath: afterResult['filepath'],
                hPath: afterResult['path'],
                recId: groupId.toString(),
                fileType: 'image',
              ),
            ),
          );
          setState(() {
            rply = false;
            vwe = !vwe;
          });
        }
      });
    });

    // return {"fPath": fullPath, "hPath": halfPath};
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

  Future getAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      // multiple: false,
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

      resp.stream.transform(utf8.decoder).listen((event) {
        print(event);
        afterResult = jsonDecode(event);
        fullPath = afterResult['filepath'];
        halfPath = afterResult['path'];
        if (rply) {
          print('has Rply');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AudioSendingScreen(
                chatType: 'group',
                fPath: afterResult['filepath'],
                hPath: afterResult['path'],
                recId: groupId.toString(),
                rplyId: replyId.toString(),
                fileType: 'voice',
              ),
            ),
          );
          setState(() {
            rply = false;
            vwe = false;
          });
        } else {
          print('No Rply');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AudioSendingNoRplyScreen(
                chatType: 'group',
                fPath: afterResult['filepath'],
                hPath: afterResult['path'],
                recId: groupId.toString(),
                fileType: 'image',
              ),
            ),
          );
          setState(() {
            rply = false;
            vwe = false;
          });
        }
      });

      // Use the selected file
    }
  }

  Future getFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      // multiple: false,
      allowedExtensions: [
        'pdf',
        'txt',
        'json',
        'csv',
        'xlsx',
        'ppt',
        'pptx',
        'doc',
        'docx'
      ],
    );
    if (result != null) {
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

      resp.stream.transform(utf8.decoder).listen((event) {
        afterResult = jsonDecode(event);
        fullPath = afterResult['filepath'];
        halfPath = afterResult['path'];
        String fileType = fullPath!.split('.').last;
        String fileName = fullPath!.split('/').last;
        if (rply) {
          print('has Rply');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DocumentSendingScreen(
                chatType: 'group',
                fPath: afterResult['filepath'],
                hPath: afterResult['path'],
                recId: groupId.toString(),
                rplyId: replyId.toString(),
                fileType: fileType,
                fileName: fileName,
              ),
            ),
          );
          setState(() {
            rply = false;
            vwe = false;
          });
        } else {
          print('No Rply');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DocumentSendingNoRplyScreen(
                chatType: 'group',
                fPath: afterResult['filepath'],
                hPath: afterResult['path'],
                recId: groupId.toString(),
                fileType: fileType,
                fileName: fileName,
              ),
            ),
          );
          setState(() {
            rply = false;
            vwe = false;
          });
        }
      });
    }
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
      final info = await VideoCompress.compressVideo(
        pick.path,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false,
      );
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
        final thumbnailFile = await VideoCompress.getFileThumbnail(pick.path,
            quality: 50, // default(100)
            position: -1 // default(-1)
            );

        if (info != null) {
          final compressedFile = File(info.path.toString());
          var auth = Provider.of<AuthProvider>(context, listen: false);
          String url = '${AppUrls.appBaseUrl}fileupload';
          var stream = http.ByteStream(compressedFile.openRead());
          var length = await compressedFile.length();
          var request = http.MultipartRequest('POST', Uri.parse(url));
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
                final thumbNail = File(thumbnailFile.path.toString());
                var auth = Provider.of<AuthProvider>(context, listen: false);
                String url = '${AppUrls.appBaseUrl}fileupload';
                var tStream = http.ByteStream(thumbNail.openRead());
                var tLength = await thumbNail.length();
                var thumbRequest =
                    http.MultipartRequest('POST', Uri.parse(url));
                var multipartFile = http.MultipartFile('file', tStream, tLength,
                    filename: thumbNail.path.split('/').last);
                thumbRequest.fields['user_id'] = auth.userId;
                thumbRequest.fields['accessToken'] = auth.accessToken;
                thumbRequest.files.add(multipartFile);
                await thumbRequest.send().then((tvalue) {
                  tvalue.stream.transform(utf8.decoder).listen((tevent) {
                    if (jsonDecode(tevent)['status'] == true) {
                      thumbPath = jsonDecode(tevent)['path'];
                      if (rply) {
                        print('has Rply');
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VideoSendingScreen(
                              chatType: 'group',
                              fPath: fullPath.toString(),
                              hPath: halfPath.toString(),
                              tPath: thumbPath.toString(),
                              recId: groupId.toString(),
                              rplyId: replyId.toString(),
                              fileType: 'video',
                            ),
                          ),
                        );
                        setState(() {
                          rply = false;
                          vwe = false;
                        });
                      } else {
                        print('No Rply');
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VideoSendingNoRplyScreen(
                              chatType: 'group',
                              fPath: fullPath.toString(),
                              hPath: halfPath.toString(),
                              tPath: thumbPath.toString(),
                              recId: groupId.toString(),
                              fileType: 'video',
                            ),
                          ),
                        );
                        setState(() {
                          rply = false;
                          vwe = false;
                        });
                      }
                    }
                  });
                });
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

  void getAudioUrl(url, id) async {
    if (voicePlay.isNotEmpty && voicePlay.contains(id)) {
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

  longPressStarred(message) {
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
        print("____________------onLongDel------------___________");
        print(onLongDel);
      }
      copyButtonText = message.message.toString();
    });
  }

  onTapStarred(message, messageList) {
    print("ontap");
    if (longPress && messageId.isNotEmpty) {
      if (messageId.contains(message.id)) {
        print("ontap");
        setState(() {
          messageId.removeWhere((element) => element == message.id);
          onLongDel.remove(message.deleteStatus);
        });
        for (var element in messageId) {
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
        }
        if (messageId.isEmpty) {
          setState(() {
            longPress = false;
          });
        }
      } else {
        setState(() {
          messageId.add(message.id);
          onLongDel.add(message.deleteStatus);
          print("____________------onLongDel------------___________");
          print(onLongDel);
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
        for (var element in messageId) {
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
        }
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

  Future get_group_user_list(
    userId,
    accessToken,
    groupId,
  ) async {
    final body = {
      'accessToken': accessToken,
      'user_id': userId,
      'group_id': groupId,
    };
    _socket.emit('room', {'userid': userId, 'room': groupId});
    _socket.on('roomUsers', (data) {
      _socket.emit('get_group_user_list', body);
      _socket.on('get_group_user_list', (data) async {
        print('SDSDSDSDSDSDSD');
        for (var i = 0; i < data['data'].length; i++) {
          grupeFCM.add(data['data'][i]['device_token']);
        }
        grupeFCM.remove(await FirebaseMessaging.instance.getToken());

        print(grupeFCM);
        print('SDSDSDSDSDSDSD');
      });
    });
  }

  Future<void> gruopeAudioCallPushMessage(
      String toFCM, String gruopName, String groupeid) async {
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
            'body': gruopName,
            'title': 'incoming call',
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'type': 'gruopeAudioCall',
            'id': groupeid,
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

  Future<void> gruopeVideoCallPushMessage(
      String toFCM, String gruopName, String groupeid) async {
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
            'body': gruopName,
            'title': 'incoming call',
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'type': 'gruopeVideoCall',
            'id': groupeid,
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
}
