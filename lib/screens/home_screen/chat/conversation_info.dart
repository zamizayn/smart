import 'dart:async';
import 'dart:convert';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/screens/home_screen/chat/api/individual_chat_section.dart';
import 'package:smart_station/screens/home_screen/chat/newConvoScreen.dart';
import 'package:smart_station/screens/home_screen/chat/profile_picture_view_chat.dart';
import 'package:smart_station/screens/home_screen/chat/widget/media_screen/media_home.dart';
import 'package:smart_station/screens/home_screen/home_screen.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../providers/AuthProvider/auth_provider.dart';
import '../../../utils/constants/urls.dart';
import '../../callAndNotification/calling.dart';
import '../../callAndNotification/videoCalling.dart';
import 'models/individualChat/individualInfoModel.dart';
import 'package:intl/intl.dart';
import 'package:smart_station/screens/home_screen/chat/group_conversation_screen.dart';
import 'package:smart_station/screens/home_screen/group/create_group_screen.dart';

class ConversationInfo extends StatefulWidget {
  String receiverId;
  ConversationInfo({
    Key? key,
    required this.receiverId,
  }) : super(key: key);

  @override
  State<ConversationInfo> createState() => _ConversationInfoState();
}

class _ConversationInfoState extends State<ConversationInfo> {
  StreamController<IndividualInfoModel> infoController =
      StreamController<IndividualInfoModel>();

  List<Contact> contacts = [];

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
    // infoController.close();
  }

  /// ***************[Phone Contact Fetching Permission]*****************
  void getContactPermossion() async {
    if (await Permission.contacts.isGranted) {
      ///***************[Fetch Contacts]**************
      fetchContacts();
    } else {
      ///***************[Request Permission]**************
      await Permission.contacts.request();
    }
  }

  /// ****************[Get Phone Contacts]********************
  void fetchContacts() async {
    contacts = await ContactsService.getContacts();
    setState(() {
      // isLoading = false;
    });
  }

  procedureFunction() async {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    var data;
    var body = {
      'user_id': auth.userId,
      'accessToken': auth.accessToken,
      'receiver_id': widget.receiverId
    };
    String url = '${AppUrls.appBaseUrl}get_individual_pofile_details';
    var resp = await http.post(Uri.parse(url), body: body);

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      data = IndividualInfoModel.fromJson(jsonDecode(resp.body));
    }

    setState(() {
      infoController.add(data);
    });
  }

  @override
  void initState() {
    _connectSocket();
    procedureFunction();
    getContactPermossion();
    super.initState();
  }

  @override
  void dispose() {
    infoController.close();
    // _destroySocket();
    super.dispose();
  }

  var top2 = 0.0;
  int displayCount = 3;
  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: false);

    var top = 0.0;

    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    DateFormat dateFormat2 = DateFormat('dd/MM/yyyy');
    DateFormat timeFormat = DateFormat('hh:mm a');

    return StreamBuilder(
      stream: infoController.stream,
      builder:
          (BuildContext context, AsyncSnapshot<IndividualInfoModel> snapshot) {
        /* var lastSeenDate = snapshot.data!.data.receiverData
                .aboutUpdatedDatetime
                .toString();*/

        if (snapshot.hasData) {
          DateTime dateTime =
              snapshot.data!.data.receiverData.aboutUpdatedDatetime;
          String lastSeenDate = dateFormat2.format(dateTime);
          String lastSeenTime = timeFormat.format(dateTime);
          String? displayName;
          for (var element in contacts) {
            element.phones?.forEach((phone) {
              if (snapshot.data!.data.receiverData.phone.replaceAll(' ', '') ==
                  phone.value!.replaceAll(' ', '')) {
                displayName = element.displayName;
              }
            });
          }
          return Scaffold(
            body: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(splashBg), fit: BoxFit.contain)),
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    shape: const ContinuousRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30))),
                    leading: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back)),
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.black26,
                    // backgroundColor: top2 ==0.0 ?Colors.black26: Colors.black,
                    expandedHeight: MediaQuery.of(context).size.height / 2.8,
                    // actions: [Icon(Icons.more_vert)],
                    flexibleSpace: LayoutBuilder(
                      builder: (ctx, cons) {
                        top = cons.biggest.height;
                        print(top2);
                        return FlexibleSpaceBar(
                          background: Column(
                            children: [
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * .05),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ProfilePictureViewChat(
                                                  name: snapshot.data!.data
                                                      .receiverData.name,
                                                  picture: snapshot
                                                      .data!
                                                      .data
                                                      .receiverData
                                                      .profilePic)));
                                },
                                child: Container(
                                  // padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 1)),
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage: NetworkImage(snapshot
                                        .data!.data.receiverData.profilePic),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  displayName ??
                                      snapshot.data!.data.receiverData.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                snapshot.data!.data.receiverData.companyMail,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                              Text(
                                snapshot.data!.data.receiverData.phone,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 14),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      // print(snapshot.data!.data.receiverData.deviceToken);
                                      // print(widget.receiverId);
                                      _destroySocket();
                                      // // Navigator.pop(context, 'refresh');
                                      Navigator.of(context)
                                          .pushReplacement(MaterialPageRoute(
                                              builder: (_) => NewConversation(
                                                    rId: widget.receiverId,
                                                    toFcm: snapshot
                                                        .data!
                                                        .data
                                                        .receiverData
                                                        .deviceToken,
                                                    roomId: '',
                                                  )));
                                    },
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                            radius: 15,
                                            backgroundColor: Colors.transparent,
                                            child: Image.asset(
                                              chatIcon,
                                            )),
                                        Text(
                                          'Message',
                                          style: TextStyle(color: textGreen),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      InkWell(
                                        child: CircleAvatar(
                                            radius: 15,
                                            backgroundColor: Colors.transparent,
                                            child: Image.asset(
                                              phoneIcon,
                                            )),
                                        onTap: () {
                                          audioCallPushMessage(
                                                  snapshot.data!.data
                                                      .receiverData.deviceToken,
                                                  auth.username)
                                              .then(
                                            (value) {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          CallingPage(
                                                            groupeFCM: const [],
                                                            type: '',
                                                            toFCM: snapshot
                                                                .data!
                                                                .data
                                                                .receiverData
                                                                .deviceToken,
                                                            userName: snapshot
                                                                .data!
                                                                .data
                                                                .receiverData
                                                                .name,
                                                            profile: snapshot
                                                                .data!
                                                                .data
                                                                .receiverData
                                                                .profilePic,
                                                          )));
                                            },
                                          );
                                        },
                                      ),
                                      Text(
                                        'Audio',
                                        style: TextStyle(color: textGreen),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      InkWell(
                                        child: CircleAvatar(
                                            radius: 15,
                                            backgroundColor: Colors.transparent,
                                            child: Image.asset(
                                              videoIcon,
                                            )),
                                        onTap: () {
                                          vedioCallPushMessage(
                                                  snapshot.data!.data
                                                      .receiverData.deviceToken,
                                                  auth.username)
                                              .then(
                                            (value) {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          VideoCameraRingScreen(
                                                            groupeFCM: const [],
                                                            type: '',
                                                            toFCM: snapshot
                                                                .data!
                                                                .data
                                                                .receiverData
                                                                .deviceToken,
                                                            userName: snapshot
                                                                .data!
                                                                .data
                                                                .receiverData
                                                                .name,
                                                            profile: snapshot
                                                                .data!
                                                                .data
                                                                .receiverData
                                                                .profilePic,
                                                          )));
                                            },
                                          );
                                        },
                                      ),
                                      Text(
                                        'Video',
                                        style: TextStyle(color: textGreen),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          title: StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: top <= 90 ? 1.0 : 0.0,
                                onEnd: () {
                                  print('I am not called but should be');
                                  print(top);
                                  setState(() {
                                    top2 = top;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 1),
                                      ),
                                      child: CircleAvatar(
                                        radius: 16,
                                        backgroundImage: NetworkImage(snapshot
                                            .data!
                                            .data
                                            .receiverData
                                            .profilePic),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          displayName ??
                                              snapshot
                                                  .data!.data.receiverData.name,
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        const Text(
                                          'online',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // About Section
                          SizedBox(
                            width: MediaQuery.of(context).size.height,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      snapshot.data!.data.receiverData.about,
                                      style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black45),
                                    ),
                                    /* Text(snapshot.data!.data.receiverData
                                        .aboutUpdatedDatetime
                                        .toString(), style: TextStyle(fontSize: 14),)*/
                                    Text(
                                      '$lastSeenDate ${lastSeenTime.toLowerCase()}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.black45),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Media Section
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: snapshot.data!.data.mediaCount > 0
                                ? () => Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (_) => MediaHome(
                                          recName: snapshot
                                              .data!.data.receiverData.name,
                                          recId: widget.receiverId),
                                    ))
                                : () {},
                            child: SizedBox(
                              width: MediaQuery.of(context).size.height,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        child: Row(
                                          children: [
                                            const Text(
                                              'Media, links, and docs',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black45,
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
                                              child: Text(
                                                snapshot.data!.data.mediaCount
                                                    .toString(),
                                                style: const TextStyle(
                                                    color: Colors.black54),
                                              ),
                                            ),
                                            IconButton(
                                                onPressed: () {},
                                                icon: const Icon(
                                                  Icons
                                                      .arrow_forward_ios_rounded,
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
                          // Mute n Unmute Section
                          const SizedBox(height: 6),
                          SizedBox(
                            width: MediaQuery.of(context).size.height,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.notifications,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Mute notifications',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black45,
                                      ),
                                    ),
                                    const Spacer(),
                                    Switch(
                                      value:
                                          snapshot.data!.data.mute.muteStatus ==
                                                  0
                                              ? false
                                              : true,
                                      onChanged: (value) {
                                        if (value) {
                                          var auth = Provider.of<AuthProvider>(
                                              context,
                                              listen: false);
                                          String selectedValue = '';
                                          bool isChecked = false;
                                          showDialog(
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
                                                        fontSize: 22,
                                                        color: Colors.black45,
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
                                                                    Colors.grey,
                                                                fontSize: 17),
                                                          ),
                                                          value: '8_hours',
                                                          activeColor:
                                                              rightGreen,
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
                                                                      .grey,
                                                                  fontSize:
                                                                      17)),
                                                          activeColor:
                                                              rightGreen,
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
                                                                      .grey,
                                                                  fontSize:
                                                                      17)),
                                                          activeColor:
                                                              rightGreen,
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
                                                              activeColor:
                                                                  rightGreen,
                                                              onChanged:
                                                                  (value) {
                                                                print(value);
                                                                setState(() {
                                                                  isChecked =
                                                                      value!;
                                                                });
                                                                print(
                                                                    isChecked);
                                                              },
                                                            ),
                                                            const Text(
                                                              'Show notifications',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 15),
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
                                                                  fontSize:
                                                                      18))),
                                                      if (selectedValue
                                                          .isNotEmpty)
                                                        TextButton(
                                                            onPressed: () {
                                                              getMuteInfo(
                                                                      auth
                                                                          .userId,
                                                                      auth
                                                                          .accessToken,
                                                                      widget
                                                                          .receiverId,
                                                                      selectedValue,
                                                                      isChecked
                                                                          ? '1'
                                                                          : '0')
                                                                  .then(
                                                                      (value) {
                                                                if (value
                                                                        .status ==
                                                                    true) {
                                                                  getIndividualInfo(
                                                                          auth
                                                                              .userId,
                                                                          auth
                                                                              .accessToken,
                                                                          widget
                                                                              .receiverId)
                                                                      .then(
                                                                          (value) {
                                                                    infoController
                                                                        .add(
                                                                            value);
                                                                    Navigator.pop(
                                                                        context);
                                                                  });
                                                                  // Navigator.pop(context);
                                                                  // setState(() {
                                                                  //
                                                                  // });
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
                                        } else {
                                          var auth = Provider.of<AuthProvider>(
                                              context,
                                              listen: false);
                                          getUnMuteInfo(
                                                  auth.userId,
                                                  auth.accessToken,
                                                  widget.receiverId)
                                              .then((value) {
                                            if (value == 'success') {
                                              getIndividualInfo(
                                                      auth.userId,
                                                      auth.accessToken,
                                                      widget.receiverId)
                                                  .then((value) {
                                                infoController.add(value);
                                                // Navigator.pop(context);
                                              });
                                            }
                                          });
                                        }
                                      },
                                      activeColor: rightGreen,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Common group Section
                          const SizedBox(height: 6),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (snapshot.data!.data.commonGroupData
                                                .noOfGroups >
                                            0 &&
                                        snapshot.data!.data.commonGroupData
                                                .noOfGroups ==
                                            1)
                                      Text(
                                        '${snapshot.data!.data.commonGroupData.noOfGroups} Group in common',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black45,
                                        ),
                                      ),
                                    if (snapshot.data!.data.commonGroupData
                                            .noOfGroups ==
                                        0)
                                      Text(
                                        '${snapshot.data!.data.commonGroupData.noOfGroups} Group in common',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    if (snapshot.data!.data.commonGroupData
                                                .noOfGroups >
                                            0 &&
                                        snapshot.data!.data.commonGroupData
                                                .noOfGroups >
                                            1)
                                      Text(
                                        '${snapshot.data!.data.commonGroupData.noOfGroups} Groups in common',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    const SizedBox(height: 15),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: textGreen,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Center(
                                            child: Icon(Icons.group_add,
                                                color: Colors.white),
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        CreateGroupScreen(
                                                          userId:
                                                              widget.receiverId,
                                                          name: snapshot
                                                              .data!
                                                              .data
                                                              .receiverData
                                                              .name,
                                                          profile: snapshot
                                                              .data!
                                                              .data
                                                              .receiverData
                                                              .profilePic,
                                                        )));
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.5,
                                            child: Text(
                                                'Create group with ${snapshot.data!.data.receiverData.name}',
                                                style: const TextStyle(
                                                    color: Colors.black54)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: snapshot.data!.data
                                          .commonGroupData.noOfGroups,
                                      itemBuilder: (context, index) {
                                        if (index < displayCount) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(snapshot
                                                            .data!
                                                            .data
                                                            .commonGroupData
                                                            .data[index]
                                                            .groupProfilePic),
                                                  ),
                                                  const SizedBox(width: 20),
                                                  InkWell(
                                                    onTap: () {
                                                      String gId = '';
                                                      setState(() {
                                                        gId = snapshot
                                                            .data!
                                                            .data
                                                            .commonGroupData
                                                            .data[index]
                                                            .groupId;
                                                      });
                                                      print('sujina');
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (_) =>
                                                                  GroupConversationScreen(
                                                                      gId:
                                                                          gId)));
                                                      /*MaterialPageRoute(
                                                        builder: (_) => GroupConversationScreen(
                                                          gId: gId,
                                                        ));*/
                                                    },
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(snapshot
                                                            .data!
                                                            .data
                                                            .commonGroupData
                                                            .data[index]
                                                            .groupName),
                                                        const SizedBox(
                                                            height: 5),
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width -
                                                              120,
                                                          child: Text(
                                                            snapshot
                                                                .data!
                                                                .data
                                                                .commonGroupData
                                                                .data[index]
                                                                .groupUsers,
                                                            softWrap: false,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 20)
                                            ],
                                          );
                                        }
                                        // return Text("TEST");
                                      },
                                    ),
                                    snapshot.data!.data.commonGroupData
                                                .noOfGroups >
                                            3
                                        ? InkWell(
                                            onTap: () {
                                              if (displayCount == 3) {
                                                setState(() {
                                                  displayCount = snapshot
                                                      .data!
                                                      .data
                                                      .commonGroupData
                                                      .noOfGroups;
                                                });
                                              } else {
                                                setState(() {
                                                  displayCount = 3;
                                                });
                                              }
                                            },
                                            child: displayCount == 3
                                                ? const Text(
                                                    'See all',
                                                    style: TextStyle(
                                                        color: Colors.green),
                                                  )
                                                : const Text(
                                                    'See less',
                                                    style: TextStyle(
                                                        color: Colors.green),
                                                  ))
                                        : const SizedBox()
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Block n Report
                          const SizedBox(height: 6),
                          SizedBox(
                            width: MediaQuery.of(context).size.height,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: snapshot.data!.data
                                                          .userBlockStatus ==
                                                      0
                                                  ? Text(
                                                      'Block ${snapshot.data!.data.receiverData.name}?',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .grey.shade600,
                                                          fontSize: 18),
                                                    )
                                                  : Text(
                                                      'Unblock ${snapshot.data!.data.receiverData.name}?',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .grey.shade600),
                                                    ),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: textGreen,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    var auth = Provider.of<
                                                            AuthProvider>(
                                                        context,
                                                        listen: false);
                                                    if (_socket.connected) {
                                                      var body = {
                                                        'user_id': auth.userId,
                                                        'accessToken':
                                                            auth.accessToken,
                                                        'receiver_id':
                                                            widget.receiverId
                                                      };
                                                      _socket.emit(
                                                          snapshot.data!.data
                                                                      .userBlockStatus ==
                                                                  0
                                                              ? 'block'
                                                              : 'unblock',
                                                          body);
                                                      _socket.on(
                                                          snapshot.data!.data
                                                                      .userBlockStatus ==
                                                                  0
                                                              ? 'block'
                                                              : 'unblock',
                                                          (data) {
                                                        if (data['message'] ==
                                                            'success') {
                                                          getIndividualInfo(
                                                                  auth.userId,
                                                                  auth
                                                                      .accessToken,
                                                                  widget
                                                                      .receiverId)
                                                              .then((value) {
                                                            infoController
                                                                .add(value);
                                                            Navigator.pop(
                                                                context);
                                                          });
                                                        }
                                                      });
                                                    } else {
                                                      _connectSocket();
                                                      var body = {
                                                        'user_id': auth.userId,
                                                        'accessToken':
                                                            auth.accessToken,
                                                        'receiver_id':
                                                            widget.receiverId
                                                      };
                                                      _socket.emit(
                                                          snapshot.data!.data
                                                                      .userBlockStatus ==
                                                                  0
                                                              ? 'block'
                                                              : 'unblock',
                                                          body);
                                                      _socket.on(
                                                          snapshot.data!.data
                                                                      .userBlockStatus ==
                                                                  0
                                                              ? 'block'
                                                              : 'unblock',
                                                          (data) {
                                                        if (data['message'] ==
                                                            'success') {
                                                          getIndividualInfo(
                                                                  auth.userId,
                                                                  auth
                                                                      .accessToken,
                                                                  widget
                                                                      .receiverId)
                                                              .then((value) {
                                                            infoController
                                                                .add(value);
                                                            Navigator.pop(
                                                                context);
                                                          });
                                                        }
                                                      });
                                                    }
                                                  },
                                                  child: Text(
                                                    snapshot.data!.data
                                                                .userBlockStatus ==
                                                            0
                                                        ? 'Block'
                                                        : 'Unblock',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: textGreen,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.block,
                                              color: snapshot.data!.data
                                                          .userBlockStatus ==
                                                      0
                                                  ? Colors.red
                                                  : Colors.grey,
                                            ),
                                            const SizedBox(width: 12),
                                            snapshot.data!.data
                                                        .userBlockStatus ==
                                                    0
                                                ? Text(
                                                    'Block ${snapshot.data!.data.receiverData.name}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.red,
                                                    ),
                                                  )
                                                : Text(
                                                    'Unblock ${snapshot.data!.data.receiverData.name}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    if (snapshot.data!.data.userBlockStatus ==
                                        0)
                                      InkWell(
                                        onTap: () {
                                          var auth = Provider.of<AuthProvider>(
                                              context,
                                              listen: false);
                                          // var body = {
                                          //   "user_id":auth.userId,
                                          //   "accessToken":auth.accessToken,
                                          //   "receiver_id":widget.receiverId
                                          // };
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              bool isChecked = false;
                                              return StatefulBuilder(
                                                builder: (context, setState) {
                                                  return AlertDialog(
                                                    title: Text(
                                                      'Report ${snapshot.data!.data.receiverData.name}?',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .grey.shade600),
                                                    ),
                                                    content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: <Widget>[
                                                        Text(
                                                          'This contact will not be notified.',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: textGreen,
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Checkbox(
                                                              value: isChecked,
                                                              onChanged:
                                                                  (value) {
                                                                print(value);
                                                                setState(() {
                                                                  isChecked =
                                                                      value!;
                                                                });
                                                                print(
                                                                    isChecked);
                                                              },
                                                            ),
                                                            const Text(
                                                              'Clear chat!',
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .grey,
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
                                                                  fontSize:
                                                                      16))),
                                                      TextButton(
                                                          onPressed: () {
                                                            if (_socket
                                                                .connected) {
                                                              var body = {
                                                                'user_id':
                                                                    auth.userId,
                                                                'accessToken': auth
                                                                    .accessToken,
                                                                'receiver_id':
                                                                    widget
                                                                        .receiverId,
                                                                'clear_status':
                                                                    isChecked
                                                                        ? '1'
                                                                        : '0'
                                                              };

                                                              _socket.emit(
                                                                  'report_and_block_individual_chat',
                                                                  body);
                                                              _socket.on(
                                                                  'report_and_block_individual_chat',
                                                                  (data) {
                                                                if (data[
                                                                        'message'] ==
                                                                    'success') {
                                                                  Navigator.pushAndRemoveUntil(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (_) =>
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
                                                                'receiver_id':
                                                                    widget
                                                                        .receiverId,
                                                                'clear_status':
                                                                    isChecked
                                                                        ? '1'
                                                                        : '0'
                                                              };

                                                              _socket.emit(
                                                                  'report_and_block_individual_chat',
                                                                  body);
                                                              _socket.on(
                                                                  'report_and_block_individual_chat',
                                                                  (data) {
                                                                if (data[
                                                                        'message'] ==
                                                                    'success') {
                                                                  Navigator.pushAndRemoveUntil(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (_) =>
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
                                                                  fontSize:
                                                                      16))),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.thumb_down,
                                                color: Colors.red,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Report ${snapshot.data!.data.receiverData.name}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
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
    );
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
}
