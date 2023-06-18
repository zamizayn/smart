import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:smart_station/screens/home_screen/chat/group_conversation_screen.dart';
import 'package:smart_station/screens/home_screen/chat/newConvoScreen.dart';
import 'package:smart_station/screens/home_screen/chat/widget/pdf_section.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


import '../../../providers/AuthProvider/auth_provider.dart';
import '../../../utils/constants/app_constants.dart';
import '../../../utils/constants/urls.dart';
import 'api/individual_chat_section.dart';
import 'package:audioplayers/audioplayers.dart';

class StarredMessage extends StatefulWidget {
  const StarredMessage({super.key});

  @override
  State<StarredMessage> createState() => _StarredMessageState();
}

class _StarredMessageState extends State<StarredMessage> {
  String? userId;
  String? accessToken;
  var starredMessage;
  bool playing = false;
  bool longPress = false;
  List<String> messageId = [];
  List<String> messageIdList = [];
  AudioPlayer audioPlayer = AudioPlayer();
  Duration duration = const Duration();
  Duration position = const Duration();
  DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  DateFormat dateFormat2 = DateFormat('dd/MM/yyyy hh:mm a');
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? deviceToken;

  final IO.Socket _socket = IO.io(AppUrls.appSocketUrl,
      IO.OptionBuilder().setTransports(['websocket']).build());

  _connectSocket() {
    _socket.connect();
    _socket.onConnect((data) => print('Connection established'));
    _socket.onConnectError((data) => print('Connect Error $data'));
    _socket.onDisconnect((data) => print('Socket.IO disconneted'));
  }

  _destroySocket(){
    _socket.disconnect();
  }

  @override
  void initState() {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    _firebaseMessaging.getToken().then((value) {
      print('FCM TOKEN: $value');
      setState(() {
        deviceToken = value;
      });
    });
    setState(() {
      userId = auth.userId;
      accessToken = auth.accessToken;
    });
  }

  @override
  void dispose() {
    _destroySocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getStarredList(userId, accessToken),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
              appBar: longPress
                  ? AppBar(
                elevation: 0,
                backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                leadingWidth: 70,
                leading: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          longPress = !longPress;
                          messageId = [];
                        });
                      },
                      child: Row(
                        children: [
                          Text(messageId.length.toString()),
                          const Icon(Icons.arrow_back, color: Colors.white),
                        ],
                      ),
                    ),
                    // Container(
                    //   // padding: EdgeInsets.all(2),
                    //   decoration: BoxDecoration(
                    //       shape: BoxShape.circle,
                    //       border: Border.all(color: Colors.white, width: 1)),
                    //   child: CircleAvatar(
                    //     radius: 20,
                    //     backgroundImage: NetworkImage(messageData.groupProfile),
                    //   ),
                    // ),
                  ],
                ),
                // title: InkWell(
                //   onTap: () {
                //     grp.getGroupInfo(
                //         groupId: messageData.id.toString(), context: context);
                //     Navigator.push(context,
                //         MaterialPageRoute(builder: (context) => GroupInfo()));
                //   },
                //   child: Column(
                //     children: [
                //       Text(
                //         messageData.groupName,
                //         style: TextStyle(
                //           fontSize: 18,
                //           color: Colors.white,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                actions: [
                  // callButton(false),
                  // callButton(true),
                  InkWell(
                      onTap: () {
                        // print(messageId.join(','));

                        var body = {
                          'user_id': userId,
                          'accessToken': accessToken,
                          'message_id': messageId.join(','),
                        };

                        _socket.emit('unstarred_message', body);

                        setState(() {
                          longPress = false;
                          messageId = [];
                        });
                      },
                      child: const SizedBox(
                        height: 30,
                        width: 30,
                        child: //Image(image: AssetImage(phoneIcon)),

                        Icon(Icons.star_half),
                      ))
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
                        Navigator.pop(context, 'refresh');
                      },
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    // Container(
                    //   // padding: EdgeInsets.all(2),
                    //   decoration: BoxDecoration(
                    //       shape: BoxShape.circle,
                    //       border: Border.all(color: Colors.white, width: 1)),
                    //   child: CircleAvatar(
                    //     radius: 20,
                    //     // backgroundImage: NetworkImage(messageData.groupProfile),
                    //   ),
                    // ),
                  ],
                ),
                title: InkWell(
                  onTap: () {
                    // grp.getGroupInfo(
                    //     groupId: messageData.id.toString(), context: context);
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) => GroupInfo()));
                  },
                  child: Column(
                    children: const [
                      Text(
                        'Starred Message',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  PopupMenuButton<String>(
                    itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: '1',
                        child: Text('Unstar all'),
                      ),
                    ],
                    onSelected: (String value) {
                      // Do something when a menu item is selected
                      print('You selected $value');
                      if (value == '1') {
                        // getStarredList(userId, accessToken).then((value) {
                        //   value.data.forEach((element) {
                        //     // messageId.add(element.id);
                        //     var body = {
                        //       "user_id": userId,
                        //       "accessToken": accessToken,
                        //       "message_id": element.id,
                        //     };
                        //     socket.emit("unstarred_message", body);
                        //   });
                        // });
                        print(messageIdList);
                        var body = {
                          'user_id': userId,
                          'accessToken': accessToken,
                          'message_id': messageIdList.join(','),
                        };
                        _socket.emit('unstarred_message', body);
                        setState(() {});
                        // Navigator.pop(context);
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
              body: snapshot.data!.data.length==0?
              const Center(
                child: Text('No starred message'),
              )
                  :ScrollablePositionedList.builder(
                itemCount: snapshot.data!.data.length,
                itemBuilder: (context, index) {
                  DateTime dateTime = snapshot.data!.data[index].date;
                  String formattedDate = dateFormat2.format(dateTime);
                  messageIdList.add(snapshot.data!.data[index].id);

                  if (snapshot.data!.data.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 25.0,
                                    width: 25.0,
                                    padding: const EdgeInsets.only(right: 10, top: 5),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: NetworkImage(snapshot.data!
                                              .data[index].senderProfilePic),
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 3,
                                  ),
                                  Text(snapshot.data!.data[index].senderName),
                                  const SizedBox(
                                    width: 3,
                                  ),
                                  const Icon(
                                    Icons.send_sharp,
                                    size: 10,
                                  ),
                                  const SizedBox(
                                    width: 3,
                                  ),
                                  Text(snapshot.data!.data[index].receiverName),
                                ],
                              ),
                              Text(
                                '${dateTime.day}/${dateTime.month}/${dateTime.year}',
                                textAlign: TextAlign.right,
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            color: messageId
                                .contains(snapshot.data!.data[index].id)
                                ? const Color.fromARGB(63, 0, 0, 0)
                                : const Color.fromRGBO(0, 0, 0, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (snapshot.data!.data[index].messageType ==
                                    'text')
                                  InkWell(
                                    onLongPress: () {
                                      longPressStarred(
                                          snapshot.data!.data[index]);
                                    },
                                    onTap: () {
                                      if (snapshot.data!.data[index].room.contains('group')) {
                                        print("GROUP");
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => GroupConversationScreen(gId: snapshot.data!.data[index].room)));
                                      } else {
                                        print("PRIVATE");
                                        // Navigator.push(context, MaterialPageRoute(builder: (context) => NewConversation(rId: snapshot.data!.data[index].senterId, toFcm: deviceToken!, roomId: snapshot.data!.data[index].room,)));
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => NewConversation(rId: snapshot.data!.data[index].receiverId, toFcm: deviceToken!, roomId: snapshot.data!.data[index].room)));
                                      }
                                      onTapStarred(snapshot.data!.data[index],
                                          snapshot.data!.data);
                                    },
                                    child: Container(
                                      width: snapshot.data!.data[index].message
                                          .length >
                                          5
                                          ? MediaQuery.of(context).size.width *
                                          0.5
                                          : MediaQuery.of(context).size.width *
                                          0.2,
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                          topLeft: Radius.circular(10),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                        children: [
                                          Align(
                                            // widthFactor: 12,
                                            alignment: Alignment.topLeft,
                                            child: AutoSizeText(
                                              snapshot
                                                  .data!.data[index].message,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            formattedDate.substring(11, 19),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                if (snapshot.data!.data[index].messageType ==
                                    'image')
                                  InkWell(
                                    onLongPress: () {
                                      longPressStarred(
                                          snapshot.data!.data[index]);
                                    },
                                    onTap: () {
                                      if (snapshot.data!.data[index].room.contains('group')) {
                                        print("GROUP");
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => GroupConversationScreen(gId: snapshot.data!.data[index].room)));
                                      } else {
                                        print("PRIVATE");
                                        // Navigator.push(context, MaterialPageRoute(builder: (context) => NewConversation(rId: snapshot.data!.data[index].senterId, toFcm: deviceToken!, roomId: snapshot.data!.data[index].room,)));
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => NewConversation(rId: snapshot.data!.data[index].receiverId, toFcm: deviceToken!, roomId: snapshot.data!.data[index].room)));
                                      }
                                      onTapStarred(snapshot.data!.data[index],
                                          snapshot.data!.data);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              // Get.to(
                                              //     () => ImageSection(
                                              //         imageUrl:
                                              //             messageList[
                                              //                     index]
                                              //                 .message),
                                              //     transition:
                                              //         Transition.zoom);
                                            },
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.all(3.0),
                                              child: SizedBox(
                                                width: 200,
                                                height: 180,
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      left: 0, right: 6),
                                                  child: Container(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          15),
                                                      child: Image(
                                                        image: NetworkImage(
                                                            snapshot
                                                                .data!
                                                                .data[index]
                                                                .message),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 12.0, top: 3, bottom: 3),
                                            child: Text(
                                              formattedDate.substring(11, 19),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (snapshot.data!.data[index].messageType ==
                                    'voice')
                                  InkWell(
                                    onLongPress: () {
                                      longPressStarred(
                                          snapshot.data!.data[index]);
                                    },

                                    onTap: () {
                                      if (snapshot.data!.data[index].room.contains('group')) {
                                        print("GROUP");
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => GroupConversationScreen(gId: snapshot.data!.data[index].room)));
                                      } else {
                                        print("PRIVATE");
                                        // Navigator.push(context, MaterialPageRoute(builder: (context) => NewConversation(rId: snapshot.data!.data[index].senterId, toFcm: deviceToken!, roomId: snapshot.data!.data[index].room,)));
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => NewConversation(rId: snapshot.data!.data[index].receiverId, toFcm: deviceToken!, roomId: snapshot.data!.data[index].room)));
                                      }
                                      onTapStarred(snapshot.data!.data[index],
                                          snapshot.data!.data);
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.65,
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(5),
                                            child: Row(
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    // audioPlayer.play(UrlSource(messageList[index].message));
                                                    // getAudioUrl(
                                                    //     messageList[index]
                                                    //         .message, messageList[index].id);
                                                  },
                                                  icon: playing == false
                                                      ? const Icon(Icons
                                                      .play_circle_outline)
                                                      : const Icon(Icons
                                                      .pause_circle_outline),
                                                ),
                                                Flexible(child: slider())
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            formattedDate.substring(11, 19),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                if (snapshot.data!.data[index].messageType ==
                                    'video')
                                  InkWell(
                                    onLongPress: () {
                                      longPressStarred(
                                          snapshot.data!.data[index]);
                                    },
                                    onTap: () {
                                      if (snapshot.data!.data[index].room.contains('group')) {
                                        print("GROUP");
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => GroupConversationScreen(gId: snapshot.data!.data[index].room)));
                                      } else {
                                        print("PRIVATE");
                                        // Navigator.push(context, MaterialPageRoute(builder: (context) => NewConversation(rId: snapshot.data!.data[index].senterId, toFcm: deviceToken!, roomId: snapshot.data!.data[index].room,)));
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => NewConversation(rId: snapshot.data!.data[index].receiverId, toFcm: deviceToken!, roomId: snapshot.data!.data[index].room)));
                                      }
                                      onTapStarred(snapshot.data!.data[index],
                                          snapshot.data!.data);
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.65,
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                        children: [
                                          // _videoPlayerController
                                          //         .value.isInitialized
                                          InkWell(
                                            onTap: () {
                                              // Get.to(VideoSection(
                                              //     videoUrl:
                                              //         messageList[
                                              //                 index]
                                              //             .message));
                                            },
                                            child: SizedBox(
                                              width: 200,
                                              height: 180,
                                              child: Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        15),
                                                    child: SizedBox(
                                                      child: Image(
                                                        image: NetworkImage(
                                                            snapshot
                                                                .data!
                                                                .data[index]
                                                                .message),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    // bottom: 2,
                                                    // right: 4,
                                                    child: Container(
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons
                                                              .play_circle_outline_outlined,
                                                          color: Colors.white,
                                                          size: 50,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 12.0, top: 3, bottom: 3),
                                            child: Text(
                                              formattedDate.substring(11, 19),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (snapshot.data!.data[index].messageType ==
                                    'doc')
                                  InkWell(
                                    onLongPress: () {
                                      longPressStarred(
                                          snapshot.data!.data[index]);
                                    },
                                    onTap: () {
                                      if (snapshot.data!.data[index].room.contains('group')) {
                                        print("GROUP");
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => GroupConversationScreen(gId: snapshot.data!.data[index].room)));
                                      } else {
                                        print("PRIVATE");
                                        // Navigator.push(context, MaterialPageRoute(builder: (context) => NewConversation(rId: snapshot.data!.data[index].senterId, toFcm: deviceToken!, roomId: snapshot.data!.data[index].room,)));
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => NewConversation(rId: snapshot.data!.data[index].receiverId, toFcm: deviceToken!, roomId: snapshot.data!.data[index].room)));
                                      }
                                      onTapStarred(snapshot.data!.data[index],
                                          snapshot.data!.data);
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              String path = snapshot
                                                  .data!.data[index].message;
                                              Uri uri = Uri.parse(path);
                                              String fileName =
                                                  uri.pathSegments.last;
                                              print(fileName);
                                              Get.to(ChatPdfView(
                                                  pdf: snapshot.data!
                                                      .data[index].message,
                                                  fileName: fileName));
                                            },
                                            child: Container(
                                              height: 120,
                                              width: 120,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(8),
                                              ),
                                              child: Image.asset(pdfIcon),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 12.0, top: 3, bottom: 3),
                                            child: Text(
                                              formattedDate.substring(11, 19),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  } else {
                    return const Center(
                      child: Text('No Data'),
                    );
                  }
                },
              ));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
      // appBar: AppBar(
      //   title: Text("Starred Messages"),
      // ),
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

  onTapStarred(message, messageList) {
    if (longPress && messageId.isNotEmpty) {
      if (messageId.contains(message.id)) {
        setState(() {
          messageId.removeWhere((element) => element == message.id);
        });
        // messageId.forEach((element) {
        //   messageList.forEach((list) {
        //     if (element == list.id) {
        //       // if (userId == list.senterId) {
        //       //   isDeleteEveryone = true;
        //       // }
        //       // if (userId != list.senterId) {
        //       //   isDeleteEveryone = false;
        //       // }
        //       if (list.starredStatus == '1') {
        //         setState(() {
        //           starred = true;
        //         });
        //       } else {
        //         setState(() {
        //           starred = false;
        //         });
        //       }
        //     }
        //   });
        // });
        if (messageId.isEmpty) {
          setState(() {
            longPress = false;
          });
        }
      } else {
        setState(() {
          messageId.add(message.id);
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
        // messageId.forEach((element) {
        //   messageList.forEach((list) {
        //     if (element == list.id) {
        //       if (userId == list.senterId) {
        //         isDeleteEveryone = true;
        //       }
        //       if (userId != list.senterId) {
        //         isDeleteEveryone = false;
        //       }

        //       if (list.starredStatus == '1') {
        //         setState(() {
        //           starred = true;
        //         });
        //       } else {
        //         setState(() {
        //           starred = false;
        //         });
        //       }
        //     }
        //   });
        // });
      }
    } else {
      setState(() {
        longPress = false;
      });
    }
  }

  longPressStarred(message) {
    // if (message.senterId == userId) {
    //   isDeleteEveryone = true;
    // } else {
    //   isDeleteEveryone = false;
    // }
    // if (message.starredStatus == '1') {
    //   setState(() {
    //     // starred = true;
    //   });
    // } else {
    //   setState(() {
    //     // starred = false;
    //   });
    // }
    setState(() {
      longPress = true;
      messageId.add(message.id);
    });
  }
}