import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/providers/ChatDetailProvider/chatdetail_provider.dart';
import 'package:smart_station/providers/GroupProvider/group_provider.dart';
import 'package:smart_station/providers/InfoProvider/individualChatInfoProvider.dart';
import 'package:smart_station/providers/ProfileProvider/profile_provider.dart';
import 'package:smart_station/providers/UserProvider/user_provider.dart';
import 'package:smart_station/screens/callAndNotification/calling.dart';
import 'package:smart_station/screens/callAndNotification/videoCalling.dart';
import 'package:smart_station/screens/home_screen/chat/conversation_info.dart';
import 'package:smart_station/screens/home_screen/chat/edit_description_and_subject.dart';
import 'package:smart_station/screens/home_screen/chat/newConvoScreen.dart';
import 'package:smart_station/screens/home_screen/chat/profile_picture_view_chat.dart';
import 'package:smart_station/screens/home_screen/chat/widget/media_screen/media_group.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../utils/constants/urls.dart';
import '../home_screen.dart';
import 'add_participants.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class GroupInfo extends StatefulWidget {
  String? groupId;
  GroupInfo({Key? key, required this.groupId}) : super(key: key);

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  final baseUrl = AppUrls.appBaseUrl;
  bool? showN = false;
  var grpFilter;
  var grpData;
  List grupeFCM = [];
  var grpP;
  List userIds = [];

  File? _image;
  File? croppedImage;
  String? halfPath;
  bool isloading = false;
  int displayCount = 10;

  final TextEditingController _textEditingController = TextEditingController();

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

  @override
  void initState() {
    _connectSocket();
    grpP = Provider.of<GroupProvider>(context, listen: false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    DateFormat dateFormat2 = DateFormat('dd/MM/yyyy hh:mm a');
    var UpdatedDate = "";
    var cdp = Provider.of<ChatDetailProvider>(context, listen: false);
    var auth = Provider.of<AuthProvider>(context, listen: false);
    var info = Provider.of<InfoProvider>(context, listen: false);
    var usp = Provider.of<UserProvider>(context, listen: false);
    return WillPopScope(
      onWillPop: () async {
        _destroySocket();

        Navigator.pop(context, 'refresh');

        return true;
      },
      child: Consumer<GroupProvider>(
        builder: (context, grp, child) {
          grpData = grp.realGrpInfo;
          grpFilter = grp.realGrpInfo;
          var myId = grpData['data']
              .firstWhere((user) => user['user_id'] == auth.userId);

          DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
          DateFormat dateFormat2 = DateFormat("dd/MM/yyyy");

          DateTime dateTime = dateFormat.parse(grpData['created_datetime']);
          UpdatedDate = dateFormat2.format(dateTime).toLowerCase();



         // grp.data[index]['username']

          // DateTime dateTime = dateFormat.parse(
          //     grpData['description_updated_datetime'] != "0000-00-00 00:00:00"
          //         ? grpData['description_updated_datetime']
          //         : "1980-12-30 10:30:00");
          // String monthName = DateFormat('MMM').format(dateTime);
          // String day = dateTime.day.toString();
          // String year = dateTime.year.toString();




          search(String val) {
            print(val);
            if (val.isEmpty || val == '') {
              print('empty');
              // grp.getGroupInfo(groupId: );
              grp.filteredProvider(grp.realGrpInfo['data']);

              // setState(() {
              //   grpData = grp.realGrpInfo;
              // });
            } else {
              var fnd = grp.realGrpInfo['data'].where((element) {
                var name = element['username'].toString().toLowerCase();
                var input = val.toLowerCase();
                return name.contains(input);
              }).toList();
              grp.filteredProvider(fnd);
              setState(() {
                grp.filteredProvider(fnd);
              });
            }
          }

          return isloading ? Scaffold(
            body: Center(
              child: Column(
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
              ),
            ),
          ) :
          Scaffold(
            body: SingleChildScrollView(
              child: Column(
                      children: [
                        /******************** Profile ********************/

                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Card(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      BackButton(
                                        onPressed: () {
                                          _destroySocket();

                                          Navigator.pop(context, 'refresh');
                                        },
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: PopupMenuButton<String>(
                                          iconSize: 30,
                                          onSelected: (value) async {
                                            print('Selected value: $value');
                                            switch (value) {
                                              case 'option1':
                                                _destroySocket();
                                                String refresh =
                                                    await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                GroupDescriptionAndSubject(
                                                                  id: '1',
                                                                  title:
                                                                      'Enter new subject',
                                                                  content: grpData[
                                                                          'group_name']
                                                                      .toString(),
                                                                  groupId: widget
                                                                      .groupId
                                                                      .toString(),
                                                                )));
                                                if (refresh == 'Refresh') {
                                                  _connectSocket();
                                                  print("refreshinggggggg12");
                                                  grp.getGroupInfo(
                                                      groupId: widget.groupId
                                                          .toString(),
                                                      context: context);
                                                  grpData = grp.realGrpInfo;
                                                  // grp.getGroupInfo(
                                                  //   groupId: widget.groupId
                                                  //       .toString(),
                                                  //   context: context,
                                                  // );

                                                  setState(() {});
                                                }

                                                break;
                                            }
                                          },
                                          itemBuilder: (BuildContext context) {
                                            return <PopupMenuEntry<String>>[
                                              // PopupMenuItem<String>(
                                              //   value: 'option1',
                                              //   child: Text('Option 1'),
                                              // ),
                                              PopupMenuItem<String>(
                                                value: 'option1',
                                                child: Text('Change subject'),
                                              ),
                                              // const PopupMenuItem<String>(
                                              //   value: 'option2',
                                              //   child: Text('Help & feedback'),
                                              // ),
                                              // PopupMenuItem<String>(
                                              //   value: 'option3',
                                              //   child: Text(starredStatusInbox.contains('0')
                                              //       ? 'Add Star'
                                              //       : 'Remove Star'),
                                              // ),
                                            ];
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Stack(children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfilePictureViewChat(
                                                      name: "Group icon",
                                                      picture: grpData[
                                                          'group_profile'])));
                                    },
                                    child: _image != null
                                        ? CircleAvatar(
                                            radius: 80,
                                            backgroundImage: FileImage(croppedImage!))
                                        : CircleAvatar(
                                            maxRadius: 80,
                                            backgroundImage: NetworkImage(
                                                grpData['group_profile']),
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
                                ]),
                                Text(
                                  grpData['group_name'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Group . ${grpData['number_of_members']} participants',
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Row(
                                      children: [
                                        InkWell(
                                          child: CircleAvatar(
                                              radius: 15,
                                              backgroundColor:
                                                  Colors.transparent,
                                              child: Image.asset(
                                                phoneIcon,
                                              )),
                                          onTap: () {
                                            get_group_user_list(
                                                    auth.userId,
                                                    auth.accessToken,
                                                    widget.groupId)
                                                .then((value) async {
                                              print(
                                                  '______________________-part 1______________________');
                                              grupeFCM.remove(
                                                  await FirebaseMessaging
                                                      .instance
                                                      .getToken());
                                              await Future.wait(grupeFCM
                                                  .toSet()
                                                  .toList()
                                                  .map((e) async {
                                                print(
                                                    '______________________-part 2______________________');
                                                await gruopeAudioCallPushMessage(
                                                    e,
                                                    grpData['group_name'],
                                                    widget.groupId.toString());
                                              })).then((value) {
                                                print(
                                                    '______________________-part 3______________________');
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            CallingPage(
                                                              toFCM: '',
                                                              userName: grpData[
                                                                  'group_name'],
                                                              profile: grpData[
                                                                  'group_profile'],
                                                              groupeFCM:
                                                                  grupeFCM,
                                                              type: 'groupe',
                                                            )));
                                              });
                                              print(grupeFCM);
                                            });
                                          },
                                        ),
                                        const SizedBox(
                                          width: 60,
                                        ),
                                        InkWell(
                                          child: CircleAvatar(
                                              radius: 15,
                                              backgroundColor:
                                                  Colors.transparent,
                                              child: Image.asset(
                                                videoIcon,
                                              )),
                                          onTap: () {
                                            get_group_user_list(
                                                    auth.userId,
                                                    auth.accessToken,
                                                    widget.groupId)
                                                .then((value) async {
                                              print(
                                                  '______________________-part 1______________________');
                                              grupeFCM.remove(
                                                  await FirebaseMessaging
                                                      .instance
                                                      .getToken());
                                              await Future.wait(grupeFCM
                                                  .toSet()
                                                  .toList()
                                                  .map((e) async {
                                                print(
                                                    '______________________-part 2______________________');
                                                await gruopeVideoCallPushMessage(
                                                    e,
                                                    grpData['group_name'],
                                                    widget.groupId.toString());
                                              })).then((value) {
                                                print(
                                                    '______________________-part 3______________________');
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            VideoCameraRingScreen(
                                                              toFCM: '',
                                                              userName: grpData[
                                                                  'group_name'],
                                                              profile: grpData[
                                                                  'group_profile'],
                                                              groupeFCM:
                                                                  grupeFCM,
                                                              type: 'groupe',
                                                            )));
                                              });
                                              print(grupeFCM);
                                            });
                                          },
                                        ),
                                        Text(
                                          '',
                                          // "Group Call",
                                          style: TextStyle(
                                              fontSize: 16, color: textGreen),
                                        ),
                                      ],
                                    ),
                                    // Column(
                                    //   children: [
                                    //     SizedBox(
                                    //       height: 40,
                                    //       child: Icon(Icons.search,
                                    //           color: textGreen, size: 30),
                                    //     ),
                                    //     Text(
                                    //       'Search',
                                    //       style:
                                    //           TextStyle(fontSize: 16, color: textGreen),
                                    //     ),
                                    //   ],
                                    // ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ),

                        /******************** Description ********************/

                        // if (grpData['description'] != '' &&
                        //     grpData['description_updated_datetime'] !=
                        //         '0000-00-00 00:00:00')
                        //   SizedBox(
                        //     width: MediaQuery.of(context).size.width,
                        //     child: Card(
                        //       child: Padding(
                        //         padding: const EdgeInsets.all(16.0),
                        //         child: Column(
                        //           crossAxisAlignment: CrossAxisAlignment.start,
                        //           children: [
                        //             Text(grpData['description']),

                        //             const SizedBox(height: 5),
                        //             // Text("$monthName $day, $year"),
                        //           ],
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // if (grpData['description'] == '' &&
                        //     grpData['description_updated_datetime'] ==
                        //         '0000-00-00 00:00:00')
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                      onTap: () async {
                                        _destroySocket();
                                        String refresh = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    GroupDescriptionAndSubject(
                                                      id: '2',
                                                      title:
                                                          'Group Description',
                                                      content:
                                                          grpData['description']
                                                              .toString(),
                                                      groupId: widget.groupId
                                                          .toString(),
                                                    )));
                                        print(refresh);
                                        if (refresh == 'Refresh') {
                                                  _connectSocket();
                                                  print("refreshinggggggg12");
                                                  grp.getGroupInfo(
                                                      groupId: widget.groupId
                                                          .toString(),
                                                      context: context);
                                                  grpData = grp.realGrpInfo;
                                                  // grp.getGroupInfo(
                                                  //   groupId: widget.groupId
                                                  //       .toString(),
                                                  //   context: context,
                                                  // );

                                                  setState(() {});
                                                }
                                        // if (refresh == 'Refresh') {
                                        //   setState(() {
                                            
                                          
                                        //   print("refreinggggggggggg2");
                                        //   grp.getGroupInfo(
                                        //       groupId:
                                        //           widget.groupId.toString(),
                                        //       context: context);
                                        //   grpData = grp.realGrpInfo;
                                        //   });
                                        //   setState(() {});
                                        // }
                                      },
                                      child:
                                          grpData['description'].toString() ==
                                                  ''
                                              ? Text('Add group description',
                                                  style: TextStyle(
                                                    color: textGreen,
                                                    fontWeight: FontWeight.bold,
                                                  ))
                                              : Text(grpData['description']
                                                  .toString())),
                                  const SizedBox(height: 8),
                                  // Text(
                                  //     "Created by ${grpData['created_by'].toString()}, ${grpData['created_datetime'].toString().substring(0, 10)}"),
                                  Text(
                                      "Created by ${grpData['created_by'].toString()}, ${UpdatedDate}"),
                                ],
                              ),
                            ),
                          ),
                        ),

                        /******************** Media ********************/

                        const SizedBox(height: 6),
                        InkWell(
                          // onTap: () {
                          //   print(grpData);
                          // },
                          onTap: grpData['media_count'] > 0
                              ? () =>
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => MediaGroup(
                                        recName: grpData['group_name'],
                                        recId: widget.groupId.toString()),
                                  ))
                              : () {},
                          child: SizedBox(
                            width: MediaQuery.of(context).size.height,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      child: Row(
                                        children: [
                                          const Text(
                                            'Media, links, and docs',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.green,
                                                  style: BorderStyle.solid,
                                                  width: 1),
                                            ),
                                            child: Text(grpData['media_count']
                                                .toString()),
                                          ),
                                          IconButton(
                                              onPressed: () {},
                                              icon: const Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                color: Colors.grey,
                                                size: 20,
                                              ))
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Card(
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(16.0),
                        //     child: Row(
                        //       children: [
                        //         Text(
                        //           'Total Media sent',
                        //           style: TextStyle(
                        //             fontSize: 16,
                        //             fontWeight: FontWeight.bold,
                        //             color: textGreen,
                        //           ),
                        //         ),
                        //         Spacer(),
                        //         InkWell(
                        //           onTap: () {},
                        //           child: Container(
                        //             padding: EdgeInsets.all(8),
                        //             decoration: BoxDecoration(
                        //                 shape: BoxShape.circle,
                        //                 border: Border.all(color: textGreen)),
                        //             child: Center(
                        //               child: Text(grpData['media_count'].toString()),
                        //             ),
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),

                        /******************** Mute Notification ********************/

                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.notifications,
                                      color: Colors.grey),
                                  const SizedBox(width: 20),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Mute notifications',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      if (grpData['mute_end_datetime'] != '')
                                        Text(grpData['mute_end_datetime'])
                                    ],
                                  ),
                                  const Spacer(),
                                  Transform.scale(
                                    scale: 1,
                                    child: Switch(
                                      value: grpData['mute_status'] == 0
                                          ? false
                                          : true,
                                      onChanged: (value) {
                                        // setState(() {
                                        //   isActivate = value;
                                        // });
                                        // print(isActivate);

                                        if (grpData['mute_status'] == 0) {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              String selectedOption = '';

                                              return AlertDialog(
                                                title: const Text(
                                                    'Mute Notification'),
                                                content: StatefulBuilder(
                                                  builder: (BuildContext
                                                          context,
                                                      StateSetter setState) {
                                                    return Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: <Widget>[
                                                        RadioListTile(
                                                          title: const Text(
                                                              '8 hours'),
                                                          value: '8_hours',
                                                          groupValue:
                                                              selectedOption,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              selectedOption =
                                                                  value!;
                                                            });
                                                          },
                                                        ),
                                                        RadioListTile(
                                                          title: const Text(
                                                              '1 Week'),
                                                          value: '1_week',
                                                          groupValue:
                                                              selectedOption,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              selectedOption =
                                                                  value!;
                                                            });
                                                          },
                                                        ),
                                                        RadioListTile(
                                                          title: const Text(
                                                              'Always'),
                                                          value: 'always',
                                                          groupValue:
                                                              selectedOption,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              selectedOption =
                                                                  value!;
                                                            });
                                                          },
                                                        ),
                                                        Row(
                                                          children: [
                                                            Checkbox(
                                                              value: showN,
                                                              onChanged:
                                                                  (newValue) {
                                                                setState(() {
                                                                  showN =
                                                                      newValue;
                                                                });
                                                              },
                                                              activeColor:
                                                                  Colors.green,
                                                              checkColor:
                                                                  Colors.white,
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
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: const Text('OK'),
                                                    onPressed: () {
                                                      // Do something with the selected option
                                                      cdp.muteGroupChatNotification(
                                                        groupId: widget.groupId
                                                            .toString(),
                                                        status:
                                                            showN! ? '1' : '0',
                                                        type: selectedOption,
                                                        context: context,
                                                      );
                                                      if (jsonDecode(cdp
                                                                  .resMessage)[
                                                              'message'] ==
                                                          'success') {
                                                        grp.getGroupInfo(
                                                          groupId: widget
                                                              .groupId
                                                              .toString(),
                                                          context: context,
                                                        );
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }

                                        if (grpData['mute_status'] == 1) {
                                          cdp.unmuteGroupchatNotification(
                                              receiverId:
                                                  widget.groupId.toString(),
                                              context: context);
                                          if (jsonDecode(
                                                  cdp.resMessage)['message'] ==
                                              'success') {
                                            grp.getGroupInfo(
                                              groupId:
                                                  widget.groupId.toString(),
                                              context: context,
                                            );
                                          }
                                        }
                                      },
                                      activeTrackColor: Colors.green,
                                      activeColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        /******************** Group Members ********************/

                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${grpData['number_of_members']} participants',
                                      style: TextStyle(
                                        color: textGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    // IconButton(
                                    //   onPressed: () {
                                    //     grp.filterSearch(
                                    //         _textEditingController.value.text);
                                    //   },
                                    //   icon: Icon(
                                    //     Icons.search,
                                    //     color: textGreen,
                                    //   ),
                                    // ),
                                  ],
                                ),
                                TextField(
                                  controller: _textEditingController,
                                  onChanged: (value) {
                                    // grp.filterSearch(value);
                                    search(value);
                                  },
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Search...',
                                    prefixIcon: Icon(
                                      Icons.search,
                                    ),
                                  ),
                                ),
                                if (myId['type'] == 'admin')
                                  InkWell(
                                    onTap: () {
                                      usp.userList(context: context);
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddParticipants(
                                              userIds: userIds,
                                              grpId: widget.groupId.toString()),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: textGreen,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.person_add,
                                              color: Colors.white,
                                              size: 25,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Text(
                                          'Add Group Members',
                                          style: TextStyle(
                                            color: textGreen,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                SizedBox(
                                  // height: 500,
                                  //child: grpData['data'] != null
                                  child: grp.data.length != 0
                                      ? ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: grp.data.length,
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            userIds.add(grp.data[index]
                                                    ['user_id']
                                                .toString());

                                            for (var element in phoneContacts) {
                                              element.phones?.forEach((phone) {
                                                if (grp.data[index]['phone'].replaceAll(' ', '') ==
                                                    phone.value!.replaceAll(' ', '')) {
                                                  grp.data[index]['username'] = element.displayName;
                                                }
                                              });
                                            }



                                                if(index < displayCount) {
                                                  return InkWell(
                                              onTap: () {
                                                if (myId['user_id'] !=
                                                    grp.data[index]
                                                        ['user_id']) {
                                                  if (myId['user_id'] ==
                                                          auth.userId &&
                                                      myId['type'] == 'user') {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          // title: Text('Mute Notification'),
                                                          content:
                                                              StatefulBuilder(
                                                            builder: (BuildContext
                                                                    context,
                                                                StateSetter
                                                                    setState) {
                                                              return Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: <
                                                                    Widget>[
                                                                  TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        _destroySocket();
                                                                        // cdp.privateChatDetail(
                                                                        //   receiverId:
                                                                        //       grp.data[index]['user_id'],
                                                                        //   context:
                                                                        //       context,
                                                                        //   userId:
                                                                        //       auth.userId,
                                                                        //   accessToken:
                                                                        //       auth.accessToken,
                                                                        // );
                                                                        // if (jsonDecode(cdp.resMessage)['message'] ==
                                                                        //     'success') {
                                                                        // _destroySocket();
                                                                        print(
                                                                            '===============================');
                                                                        //  print(grp.data[index]['user_id']);
                                                                        //  print(usp.data[index]['deviceToken']);
                                                                        print(
                                                                            '===============================');
                                                                        Navigator.pushReplacement(
                                                                            context,
                                                                            MaterialPageRoute(builder: (_) => NewConversation(toFcm: grp.data[index]['device_token'], rId: grp.data[index]['user_id'], roomId: '',)));
                                                                        // }
                                                                      },
                                                                      child: Text(
                                                                          'Message ${grp.data[index]['username']}')),
                                                                  TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        info.getIndividualProfile(
                                                                            grp.data[index]['user_id'],
                                                                            context);
                                                                        if (jsonDecode(info.resMessage)['message'] ==
                                                                            'success') {
                                                                          Navigator.pushReplacement(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                  builder: (_) => ConversationInfo(
                                                                                        receiverId: grp.data[index]['user_id'],
                                                                                    
                                                                                      )));
                                                                        }
                                                                      },
                                                                      child: Text(
                                                                          'View ${grp.data[index]['username']}')),
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  }

                                                  if (myId['user_id'] ==
                                                          auth.userId &&
                                                      myId['type'] == 'admin') {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          // title: Text('Mute Notification'),
                                                          content:
                                                              StatefulBuilder(
                                                            builder: (BuildContext
                                                                    context,
                                                                StateSetter
                                                                    setState) {
                                                              return Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: <
                                                                    Widget>[
                                                                  TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        _destroySocket();
                                                                        print(
                                                                            "clickeddddd");
                                                                        // cdp.privateChatDetail(
                                                                        //   receiverId:
                                                                        //       grp.data[index]['user_id'],
                                                                        //   context:
                                                                        //       context,
                                                                        //   userId:
                                                                        //       auth.userId,
                                                                        //   accessToken:
                                                                        //       auth.accessToken,
                                                                        // );
                                                                        // if (jsonDecode(cdp
                                                                        //             .resMessage)[
                                                                        //         'message'] ==
                                                                        //     'success') {
                                                                        print(
                                                                            '-----------------------');
                                                                        print(grp
                                                                            .data[index]);
                                                                        //    print(usp.data[index]['deviceToken']);
                                                                        print(
                                                                            '-----------------------');
                                                                        // Navigator.pushReplacement(
                                                                        // Navigator.pushReplacement(
                                                                        //     context,
                                                                        //     MaterialPageRoute(builder: (_) => NewConversation(toFcm: grp.data[index]['device_token'], rId: grp.data[index]['user_id'])));

                                                                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                                                                            builder: (_) => NewConversation(
                                                                                  rId: grp.data[index]['user_id'],
                                                                                  toFcm: grp.data[index]['device_token'],
                                                                              roomId: '',
                                                                                )));
                                                                        // }
                                                                      },
                                                                      child: Text(
                                                                          'Message ${grp.data[index]['username']}')),
                                                                  TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        info.getIndividualProfile(
                                                                            grp.data[index]['user_id'],
                                                                            context);
                                                                        if (jsonDecode(info.resMessage)['message'] ==
                                                                            'success') {
                                                                          Navigator.pushReplacement(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                  builder: (_) => ConversationInfo(
                                                                                        receiverId: grp.data[index]['user_id'],
                                                                                      )));
                                                                        }
                                                                      },
                                                                      child: Text(
                                                                          'View ${grp.data[index]['username']}')),
                                                                  if (grp.data[
                                                                              index]
                                                                          [
                                                                          'type'] ==
                                                                      'admin')
                                                                    TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          grp.removeGroupAdmin(
                                                                              groupId: widget.groupId.toString(),
                                                                              userId: grpData['data'][index]['user_id'],
                                                                              context: context);
                                                                          Navigator.pop(
                                                                              context);
                                                                          Future.delayed(
                                                                              const Duration(seconds: 3),
                                                                              () => grp.getGroupInfo(groupId: cdp.groupId, context: context));
                                                                        },
                                                                        child: const Text(
                                                                            'Remove group admin')),
                                                                  if (grpData['data']
                                                                              [
                                                                              index]
                                                                          [
                                                                          'type'] ==
                                                                      'user')
                                                                    TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          grp.makeGroupAdmin(
                                                                              groupId: widget.groupId.toString(),
                                                                              userId: grp.data[index]['user_id'],
                                                                              context: context);
                                                                          Navigator.pop(
                                                                              context);
                                                                          Future.delayed(
                                                                              const Duration(seconds: 3),
                                                                              () => grp.getGroupInfo(groupId: cdp.groupId, context: context));
                                                                        },
                                                                        child: const Text(
                                                                            'Make group admin')),
                                                                  TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        cdp.removeGroupMember(
                                                                            groupId:
                                                                                widget.groupId.toString(),
                                                                            userId: grp.data[index]['user_id'],
                                                                            context: context);

                                                                        Navigator.pop(
                                                                            context,
                                                                            'Refresh');

                                                                        //                       if (jsonDecode(cdp
                                                                        //             .resMessage)[
                                                                        //         'message'] ==
                                                                        //     'success') {
                                                                        //   grp.getGroupInfo(
                                                                        //     groupId: widget
                                                                        //         .groupId
                                                                        //         .toString(),
                                                                        //     context: context,
                                                                        //   );
                                                                        //   Navigator.pop(context);
                                                                        // }
                                                                        //     setState (() {
                                                                        //              });
                                                                        // Navigator.pushReplacement(
                                                                        //     context,
                                                                        //     MaterialPageRoute(
                                                                        //       builder: (context) => const HomeScreen(),
                                                                        //     ));
                                                                      },
                                                                      child: Text(
                                                                          'Remove ${grp.data[index]['username']}')),
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  }
                                                }

                                                // if (auth.userId == grpData['data'][index]['user_id'])
                                                // if (myId['user_id'] != grpData['data'][index]['user_id'])
                                                grp.getGroupInfo(
                                                  groupId:
                                                      widget.groupId.toString(),
                                                  context: context,
                                                );
                                                setState(() {});
                                              },
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 20),
                                                  Row(
                                                    children: [
                                                      CircleAvatar(
                                                        backgroundImage:
                                                            NetworkImage(grp
                                                                    .data[index]
                                                                [
                                                                'profile_pic']),
                                                      ),
                                                      const SizedBox(width: 20),
                                                      Flexible(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(auth.userId ==
                                                                    grp.data[
                                                                            index]
                                                                        [
                                                                        'user_id']
                                                                ? 'You'
                                                                : grp.data[
                                                                        index][
                                                                    'username']),
                                                            const SizedBox(
                                                                height: 5),
                                                            SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width -
                                                                  120,
                                                              child: Text(
                                                                grp.data[index]
                                                                    ['about'],
                                                                softWrap: false,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      if (grp.data[index]
                                                              ['type'] ==
                                                          'admin')
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: Colors
                                                                          .green[
                                                                      100]),
                                                          child: Center(
                                                            child: Text(
                                                              'Group Admin',
                                                              style: TextStyle(
                                                                  color:
                                                                      textGreen,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                        )
                                                    ],
                                                  ),
                                                  const SizedBox(height: 20)
                                                ],
                                              ),
                                            );
                                                }
                                            // return Text("TEST");
                                          },
                                        )
                                      : Column(
                                          children: [
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              'No results found for searched  \'' +
                                                  _textEditingController
                                                      .value.text! +
                                                  '\'',
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                ),
                               grp.data.length>10? InkWell(
                                  onTap: () {
                                    if(displayCount==10) {
                                      setState(() {
                                      displayCount = grp.data.length ;
                                    });
                                    }
                                    else{
                                      setState(() {
                                        displayCount = 10;
                                      });
                                    }
                                    
                                  },
                                  child:displayCount==10? 
                                  Text('View all(${grp.data.length -10} more)',style: const TextStyle(color: Colors.green),)
                                  :const Text('View less',style: TextStyle(color: Colors.green),)
                                  )
                                  :SizedBox()
                              ],
                            ),
                          ),
                        ),

                        /******************** Exit & Report ********************/

                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  // if (grpData['data'].length != 1)
                                    InkWell(
                                      onTap: () {
                                        // grp.exitGroup(
                                        //     groupId: widget.groupId.toString(), context: context);
                                        // if (jsonDecode(grp.resMessage)['message'] ==
                                        //     'success') {
                                        //   Navigator.pop(context);
                                        // }
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            bool isChecked = false;
                                            return StatefulBuilder(
                                              builder: (context, setState) {
                                                return AlertDialog(
                                                  title: Text(
                                                    'Exit ${grpData['group_name']}?',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                    TextButton(
                                                        onPressed: () {
                                                          if (_socket
                                                              .connected) {
                                                            var body = {
                                                              'user_id':
                                                                  auth.userId,
                                                              'accessToken': auth
                                                                  .accessToken,
                                                              'group_id': widget
                                                                  .groupId,
                                                            };

                                                            _socket.emit(
                                                                'exit_group_member',
                                                                body);
                                                            _socket.on(
                                                                'exit_group_member',
                                                                (data) {
                                                              if (data[
                                                                      'message'] ==
                                                                  'success') {
                                                                Navigator.pushAndRemoveUntil(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (_) =>
                                                                                const HomeScreen()),
                                                                    (route) =>
                                                                        false);
                                                              }
                                                            });
                                                          } else {
                                                            _connectSocket();
                                                            var body = {
                                                              'user_id':
                                                                  auth.userId,
                                                              'accessToken': auth
                                                                  .accessToken,
                                                              'group_id': widget
                                                                  .groupId,
                                                            };

                                                            _socket.emit(
                                                                'exit_group_member',
                                                                body);
                                                            _socket.on(
                                                                'exit_group_member',
                                                                (data) {
                                                              if (data[
                                                                      'message'] ==
                                                                  'success') {
                                                                Navigator.pushAndRemoveUntil(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (_) =>
                                                                                const HomeScreen()),
                                                                    (route) =>
                                                                        false);
                                                              }
                                                            });
                                                          }
                                                        },
                                                        child: Text('Ok',
                                                            style: TextStyle(
                                                                color:
                                                                    textGreen,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 18))),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Icon(Icons.logout,
                                              color: Colors.red[700]),
                                          const SizedBox(width: 20),
                                          Text(
                                            'Exit group',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                  if (grpData['data'].length != 1)
                                    // const SizedBox(height: 15),
                                  InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          bool isChecked = false;

                                          return StatefulBuilder(
                                            builder: (context, setState) {
                                              return AlertDialog(
                                                title: Text(
                                                  'Report ${grpData['group_name']}?',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 25,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
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
                                                              isChecked =
                                                                  value!;
                                                            });
                                                            print(isChecked);
                                                          },
                                                        ),
                                                        const Text(
                                                          'Exit from group',
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
                                                          Navigator.of(context)
                                                              .pop(),
                                                      child: Text('Cancel',
                                                          style: TextStyle(
                                                              color: textGreen,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 18))),
                                                  TextButton(
                                                      onPressed: () {
                                                        if (_socket.connected) {
                                                          var body = {
                                                            'user_id':
                                                                auth.userId,
                                                            'accessToken': auth
                                                                .accessToken,
                                                            'group_id':
                                                                widget.groupId,
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
                                                            if (data[
                                                                    'message'] ==
                                                                'success') {
                                                              Navigator.pushAndRemoveUntil(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (_) =>
                                                                              const HomeScreen()),
                                                                  (route) =>
                                                                      false);
                                                            }
                                                          });
                                                        } else {
                                                          _connectSocket();
                                                          var body = {
                                                            'user_id':
                                                                auth.userId,
                                                            'accessToken': auth
                                                                .accessToken,
                                                            'group_id':
                                                                widget.groupId,
                                                          };

                                                          _socket.emit(
                                                              'report_and_left_group_chat',
                                                              body);
                                                          _socket.on(
                                                              'report_and_left_group_chat',
                                                              (data) {
                                                            if (data[
                                                                    'message'] ==
                                                                'success') {
                                                              Navigator.pushAndRemoveUntil(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (_) =>
                                                                              const HomeScreen()),
                                                                  (route) =>
                                                                      false);
                                                            }
                                                          });
                                                        }
                                                      },
                                                      child: Text('Ok',
                                                          style: TextStyle(
                                                              color: textGreen,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 18))),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.thumb_down,
                                            color: Colors.red[700]),
                                        const SizedBox(width: 20),
                                        Text(
                                          'Report group',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
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
                                // showDialog(
                                //     context: context,
                                //     builder: (BuildContext context) {
                                //       return AlertDialog(
                                //         content: SizedBox(
                                //             width: MediaQuery.of(context)
                                //                     .size
                                //                     .width /
                                //                 1.5,
                                //             child: const Text(
                                //                 'Remove profile photo?')),
                                //         actions: [
                                //           Row(
                                //             mainAxisAlignment:
                                //                 MainAxisAlignment.end,
                                //             children: [
                                //               InkWell(
                                //                 onTap: () {
                                //                   Navigator.of(context)
                                //                       .pop(); // Dismiss dialog
                                //                 },
                                //                 child: Container(
                                //                     padding:
                                //                         const EdgeInsets.all(
                                //                             10),
                                //                     child: const Text('Cancel',
                                //                         style: TextStyle(
                                //                             color:
                                //                                 Colors.green))),
                                //               ),
                                //               const SizedBox(
                                //                 width: 5,
                                //               ),
                                //               InkWell(
                                //                 onTap: () {
                                //                   setState(() {
                                //                     profile
                                //                         .removeProfilePicture(
                                //                             accessTok: auth
                                //                                 .accessToken,
                                //                             userId:
                                //                                 auth.userId);
                                //                   });
                                //                   Navigator.of(context)
                                //                       .pop(); // Dismiss dialog
                                //                 },
                                //                 child: Container(
                                //                     padding:
                                //                         const EdgeInsets.all(
                                //                             10),
                                //                     child: const Text(
                                //                       'Remove',
                                //                       style: TextStyle(
                                //                           color: Colors.green),
                                //                     )),
                                //               ),
                                //               const SizedBox(
                                //                 width: 10,
                                //               )
                                //             ],
                                //           )
                                //         ],
                                //       );
                                //     });
                              },
                              // child: ImageIcon(AssetImage(trashIcon),
                              //     color: Colors.grey[600], size: 30),
                              child: Container(),
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

  Future getImageSouce(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return null;
    _image = File(image.path);
    setState(() {
      isloading = true;
    });

    File compressedImage = await FlutterNativeImage.compressImage(
      image.path,
      percentage: 80,
      quality: 100,
    );
    cropImage(compressedImage).then((value) async {
      var auth = Provider.of<AuthProvider>(context, listen: false);
      var profile = Provider.of<ProfileProvider>(context, listen: false);
      File imgPath = File(value!.path);
      croppedImage = File(value.path);
      String url = '$baseUrl/fileupload';

      try {
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
          setState(() {
            isloading = false;
          });
          // _profilePic = finalData['data']['profile_pic'];
          // notifyListeners();
          if (finalData['statuscode'] == 200) {
            if (_socket.connected) {
              var body = {
                'user_id': auth.userId,
                'accessToken': auth.accessToken,
                'group_id': widget.groupId,
                "group_profile": finalData['path']
              };

              print(body);

              _socket.emit('change_group_profile_pic', body);
              _socket.on('change_group_profile_pic', (data) {
                print("00");
                print(data);
                if (data['message'] == 'success') {
                  // Navigator.pop(context);
                  // var usp = Provider.of<GroupProvider>(context, listen: false);
                  // grpP.getGroupInfo(groupId: widget.groupId.toString());
                  // // Navigator.pushAndRemoveUntil(
                  //     context,
                  //     MaterialPageRoute(builder: (_) => const HomeScreen()),
                  //     (route) => false);
                } else {}
              });
            } else {
              var body = {
                'user_id': auth.userId,
                'accessToken': auth.accessToken,
                'group_id': widget.groupId,
                "group_profile": finalData['path']
              };
              _socket.connect();
              _socket.emit('change_group_profile_pic', body);
              _socket.on('change_group_profile_pic', (data) {
                print("111");
                print(data);
                if (data['message'] == 'success') {
                  // _image = File(image.path);
                  // _destroySocket();
                  // Navigator.pop(context);

                  // grpP.getGroupInfo(groupId: widget.groupId.toString());
                  // Navigator.pushAndRemoveUntil(
                  //     context,
                  //     MaterialPageRoute(builder: (_) => const HomeScreen()),
                  //     (route) => false);
                }
              });
            }

            // _isLoading = false;
            // _resMessage = event;
            // getPath(finalData);

            // return finalData;
            // notifyListeners();
            // return finalData;
          } else {
            setState(() {
              _image = null;
            });

            errorTost(finalData['message']);
            // return finalData;
          }
        });
      } catch (e) {}

      // profile
      //     .fileUpload2(imgPath, auth.accessToken, auth.userId, context)
      //     .then((value) {
      // print("value insile provider");
      // print(value);

      // });
      //  profile.updateProfilePicture(imgPath, auth.accessToken, auth.userId, context);

      setState(() {
        // _image = imgPath;
        // halfPath = profile.halfPath;

        // print('halfpath===================$halfPath');
        // print("fulllpath000000${profile.filePath}");
      });
    });
  }

  errorTost(msg) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 66,
        channelKey: 'downloaded_pdf',
        title: msg,
        body: 'Upload Failed',
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
}
