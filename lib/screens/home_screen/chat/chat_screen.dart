import 'dart:async';
import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:smart_station/providers/ChatFuntionProvider/chatFunctionProvider.dart';
import 'package:smart_station/providers/GroupProvider/group_provider.dart';
import 'package:smart_station/screens/home_screen/chat/group_info_screen.dart';
import 'package:smart_station/screens/home_screen/chat/widget/archiveChatList.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/providers/ChatDetailProvider/chatdetail_provider.dart';
import 'package:smart_station/providers/RecentChatProvider/recentchat_provider.dart';
import 'package:smart_station/screens/home_screen/chat/newConvoScreen.dart';
import 'package:smart_station/screens/home_screen/chat/profile_picture_view_chat.dart';
import 'package:smart_station/utils/constants/app_constants.dart';

import '../../../providers/InfoProvider/individualChatInfoProvider.dart';
import '../../../utils/constants/urls.dart';
import '../../callAndNotification/callNotification.dart';
import '../../callAndNotification/calling.dart';
import '../../callAndNotification/videoCalling.dart';
import 'conversation_info.dart';
import 'group_conversation_screen.dart';
import 'models/chat_List_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

List selectedChatId = [];
List selectedGroupId = [];

class _ChatScreenState extends State<ChatScreen> {
  var socketDetails;
  DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  DateFormat dateFormat2 = DateFormat('dd/MM/yyyy');
  DateFormat timeFormat = DateFormat('hh:mm a');

  List grupeFCM = [];

  bool isTyping = false;
  bool pressStatus = false;
  bool pinStatus = false;
  bool muteStatus = false;

  String typingUser = '';

  final IO.Socket _socket = IO.io(AppUrls.appSocketUrl,
      IO.OptionBuilder().setTransports(['websocket']).build());

  _connectSocket() {
    _socket.connect();
    _socket.onConnect((data) => print('Connection established'));
    _socket.onConnectError((data) => print('Connect Error $data'));
    _socket.onDisconnect((data) {
      print('Socket.IO disconneted $data');
      //  _socket.connect();
      //socketProcessing();
    });
  }

  _destroySocket() {
    _socket.disconnect();
    chat_List_StreamController.close();
  }

  /// *************************[Socket Processing]***********************

  socketProcessing() {
    print('CALLED');
    var auth = Provider.of<AuthProvider>(context, listen: false);
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
    };
    if (_socket.connected) {
      print('*****************[SOCKET CONNECTED]****************');
      _socket.on('chat_list', (data) {
        print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
        print('invoked');
        print(data);
        print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
        var dataa = ChatList.fromJson(data);
        setState(() {
          if (chat_List_StreamController.isPaused) {
            print('resume streem');
            chat_List_StreamController.onResume;
            if (chat_List_StreamController.isClosed) {
              chat_List_StreamController.onListen;
              chat_List_StreamController.add(dataa);
              print(dataa);
            } else {
              chat_List_StreamController.add(dataa);
              print(dataa);
            }
          } else if (chat_List_StreamController.isClosed) {
            chat_List_StreamController = StreamController();
            chat_List_StreamController.onListen;
            chat_List_StreamController.add(dataa);
            print(dataa);
          } else {
            chat_List_StreamController.add(dataa);
            print(dataa);
          }
        });
      });
      _socket.on('typing_individual_chatlist', (data) {
        print('TYPING DATA $data');
        if (data['typing'] == '1') {
          setState(() {
            isTyping = true;
            typingUser = data['user_id'];
          });
        } else {
          setState(() {
            isTyping = false;
            typingUser = '';
          });
        }
      });
      _socket.emit('chat_list', body);
    } else {
      print('*****************[SOCKET DISCONNECTED]****************');
      _connectSocket();
      _socket.on('chat_list', (data) {
        var dataa = ChatList.fromJson(data);
        setState(() {
          if (chat_List_StreamController.isPaused) {
            chat_List_StreamController.onResume;
            chat_List_StreamController.add(dataa);
          } else if (chat_List_StreamController.isClosed) {
            chat_List_StreamController = StreamController();
            chat_List_StreamController.onListen;
            chat_List_StreamController.add(dataa);
          } else {
            chat_List_StreamController.add(dataa);
          }
        });
      });
      _socket.on('typing_individual_chatlist', (data) {
        print('TYPING DATA $data');
        if (data['typing'] == '1') {
          setState(() {
            isTyping = true;
            typingUser = data['user_id'];
          });
        } else {
          setState(() {
            isTyping = false;
            typingUser = '';
          });
        }
      });
      _socket.emit('chat_list', body);
    }
  }

  int? onlog;

  /// *************************[Socket Processing]***********************

  @override
  void initState() {
    _connectSocket();
    super.initState();
    chat_List_StreamController = StreamController<ChatList>();
    socketProcessing();
    AwesomeNotifications().isNotificationAllowed().then((value) {
      if (!value) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    NotificationServices.callNotification();
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    var pvtChat = Provider.of<ChatDetailProvider>(context, listen: false);
    final pin = context.watch<PinChatProvider>();

    return StreamBuilder<ChatList>(
      stream: chat_List_StreamController.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.data.length == 0) {
            return const Center(
              child: Text('No Chats',
                  style: TextStyle(color: Colors.black, fontSize: 18)),
            );
          } else {
            return Column(
              children: [
                if (snapshot.data!.archivedChatList.isNotEmpty)
                  InkWell(
                    onTap: () async {
                      String refresh = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ArchiveChatList(
                                  chatList: snapshot.data!.archivedChatList)));
                      if (refresh == 'refresh') {
                        socketProcessing();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.archive_outlined,
                                  color: Colors.grey.shade600),
                              SizedBox(width: 15),
                              Text(
                                'Archived',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.green,
                                style: BorderStyle.solid,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Text(snapshot.data!.archivedChatList.length
                                .toString()),
                          )
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: Scaffold(
                    body: ListView.builder(
                      physics: const BouncingScrollPhysics(
                          decelerationRate: ScrollDecelerationRate.fast),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.data.length,
                      itemBuilder: (context, index) {
                        DateTime dateTime = dateFormat
                            .parse(snapshot.data!.data[index].date.toString());
                        String formattedDate2 = dateFormat2.format(dateTime);
                        String formattedTime = timeFormat.format(dateTime);
                        String formattedDate =
                            dateTime.isToday() ? formattedTime : formattedDate2;
                        String? displayName;
                        phoneContacts.forEach((element) {
                          element.phones?.forEach((phone) {
                            if (snapshot.data!.data[index].phone
                                    .replaceAll(' ', '') ==
                                phone.value!.replaceAll(' ', '')) {
                              displayName = element.displayName;
                            }
                          });
                        });
                        return Column(
                          children: [
                            InkWell(
                              onTap: () async {
                                if (pin.isPressed) {
                                  setState(() {
                                    pressStatus = true;
                                    var check = null;
                                    var checkMute = null;
                                    if (snapshot.data!.data[index].chatType ==
                                        "private") {
                                      /// Pin Individual Chat ///
                                      if (!individualChatId.contains(
                                          snapshot.data!.data[index].userid)) {
                                        individualChatId.add(
                                            snapshot.data!.data[index].userid);
                                        groupChatId.add(
                                            snapshot.data!.data[index].room);
                                        individualChatId.forEach((element) {
                                          snapshot.data!.data.indexWhere((elm) {
                                            check = elm.userid == element &&
                                                elm.pinStatus == '1';
                                            return check;
                                          });
                                        });
                                        individualChatId.forEach((element) {
                                          snapshot.data!.data.indexWhere((elm) {
                                            checkMute = elm.userid == element &&
                                                elm.muteStatus == '1';
                                            print(checkMute);
                                            return checkMute;
                                          });
                                        });
                                      } else {
                                        setState(() {
                                          individualChatId.remove(snapshot
                                              .data!.data[index].userid);
                                          groupChatId.remove(
                                              snapshot.data!.data[index].room);
                                          individualChatId.forEach((element) {
                                            snapshot.data!.data
                                                .indexWhere((elm) {
                                              check = elm.userid == element &&
                                                  elm.pinStatus == '1';
                                              return check;
                                            });
                                          });
                                          individualChatId.forEach((element) {
                                            snapshot.data!.data
                                                .indexWhere((elm) {
                                              checkMute =
                                                  elm.userid == element &&
                                                      elm.muteStatus == '1';
                                              print(checkMute);
                                              return checkMute;
                                            });
                                          });
                                        });
                                        // ScaffoldMessenger.of(context)
                                        //     .showSnackBar(
                                        //   SnackBar(
                                        //     content: Text(
                                        //         '${snapshot.data!.data[index].name} is already selected'),
                                        //   ),
                                        // );
                                      }

                                      /// Delete Individual Chat ///
                                      if (!chatProcessing.contains(
                                          snapshot.data!.data[index].room)) {
                                        chatProcessing.add(
                                            snapshot.data!.data[index].room);
                                        print(snapshot.data!.data[index].room);
                                      } else {
                                        setState(() {
                                          chatProcessing.remove(
                                              snapshot.data!.data[index].room);
                                          print(
                                              snapshot.data!.data[index].room);
                                        });

                                        // ScaffoldMessenger.of(context)
                                        //     .showSnackBar(
                                        //   SnackBar(
                                        //     content: Text(
                                        //         '${snapshot.data!.data[index].name} is already selected'),
                                        //   ),
                                        // );
                                      }
                                    } else {
                                      /// Pin Group Chat ///
                                      if (!groupChatId.contains(
                                          snapshot.data!.data[index].room)) {
                                        groupChatId.add(
                                            snapshot.data!.data[index].room);
                                        individualChatId.add(0);
                                        groupChatId.forEach((element) {
                                          snapshot.data!.data.indexWhere((elm) {
                                            check = elm.room == element &&
                                                elm.pinStatus == '1';
                                            return check;
                                          });
                                        });
                                        groupChatId.forEach((element) {
                                          snapshot.data!.data.indexWhere((elm) {
                                            checkMute = elm.room == element &&
                                                elm.muteStatus == '1';
                                            print(checkMute);
                                            return checkMute;
                                          });
                                        });
                                      } else {
                                        setState(() {
                                          groupChatId.remove(
                                              snapshot.data!.data[index].room);
                                          individualChatId.remove(0);
                                          groupChatId.forEach((element) {
                                            snapshot.data!.data
                                                .indexWhere((elm) {
                                              checkMute = elm.room == element &&
                                                  elm.muteStatus == '1';
                                              print(checkMute);
                                              return checkMute;
                                            });
                                          });
                                          groupChatId.forEach((element) {
                                            snapshot.data!.data
                                                .indexWhere((elm) {
                                              check = elm.room == element &&
                                                  elm.pinStatus == '1';
                                              return check;
                                            });
                                          });
                                        });

                                        // ScaffoldMessenger.of(context)
                                        //     .showSnackBar(
                                        //   SnackBar(
                                        //     content: Text(
                                        //         '${snapshot.data!.data[index].name} is already selected'),
                                        //   ),
                                        // );
                                      }

                                      /// Delete Group Chat ///
                                      if (!chatProcessing.contains(
                                          snapshot.data!.data[index].room)) {
                                        chatProcessing.add(
                                            snapshot.data!.data[index].room);
                                        print(snapshot.data!.data[index].room);
                                      } else {
                                        setState(() {
                                          chatProcessing.remove(
                                              snapshot.data!.data[index].room);
                                          print(
                                              snapshot.data!.data[index].room);
                                        });
                                        // ScaffoldMessenger.of(context)
                                        //     .showSnackBar(
                                        //   SnackBar(
                                        //     content: Text(
                                        //         '${snapshot.data!.data[index].name} is already selected'),
                                        //   ),
                                        // );
                                      }
                                    }
                                    if (chatProcessing.isEmpty ||
                                        groupChatId.isEmpty ||
                                        individualChatId.isEmpty) {
                                      setState(() {
                                        pressStatus = false;
                                        pin.setValue(false);
                                      });
                                    }
                                    print(individualChatId);
                                    if (check) {
                                      pinStatus = check;
                                      pin.checkPinned(pinStatus);
                                    }
                                    if (checkMute) {
                                      print('pine');
                                      print(checkMute);
                                      muteStatus = checkMute;
                                      pin.checkMuted(muteStatus);
                                    } else {
                                      pin.checkMuted(false);
                                    }
                                  });
                                  pin.setValue(pressStatus);
                                  // print(snapshot.data!.data[index].)
                                } else {
                                  _destroySocket();
                                  if (snapshot.data!.data[index].chatType ==
                                      'private') {
                                    String refresh = await Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => NewConversation(
                                        rId: snapshot.data!.data[index].userid,
                                        toFcm: snapshot
                                            .data!.data[index].deviceToken,
                                        roomId: snapshot.data!.data[index].room,
                                      ),
                                    ));
                                    if (refresh == 'refresh') {
                                      socketProcessing();
                                    }
                                  } else {
                                    var grp = Provider.of<GroupProvider>(
                                        context,
                                        listen: false);

                                    grp.getGroupInfo(
                                        groupId:
                                            snapshot.data!.data[index].room,
                                        context: context);
                                    String refresh =
                                        await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            GroupConversationScreen(
                                          gId: snapshot.data!.data[index].room,
                                        ),
                                      ),
                                    );
                                    if (refresh == 'refresh') {
                                      socketProcessing();
                                    }
                                  }
                                }
                              },
                              onLongPress: () {
                                setState(() {
                                  pressStatus = true;
                                  var check = null;
                                  var checkMute = null;
                                  if (snapshot.data!.data[index].chatType ==
                                      "private") {
                                    /// Pin Individual Chat ///
                                    if (!individualChatId.contains(
                                        snapshot.data!.data[index].userid)) {
                                      individualChatId.add(
                                          snapshot.data!.data[index].userid);
                                      groupChatId
                                          .add(snapshot.data!.data[index].room);
                                      individualChatId.forEach((element) {
                                        snapshot.data!.data.indexWhere((elm) {
                                          check = elm.userid == element &&
                                              elm.pinStatus == '1';
                                          return check;
                                        });
                                      });
                                      individualChatId.forEach((element) {
                                        snapshot.data!.data.indexWhere((elm) {
                                          checkMute = elm.userid == element &&
                                              elm.muteStatus == '1';
                                          print(checkMute);
                                          return checkMute;
                                        });
                                      });
                                    } else {
                                      setState(() {
                                        individualChatId.remove(
                                            snapshot.data!.data[index].userid);
                                        groupChatId.remove(
                                            snapshot.data!.data[index].room);
                                        individualChatId.forEach((element) {
                                          snapshot.data!.data.indexWhere((elm) {
                                            check = elm.userid == element &&
                                                elm.pinStatus == '1';
                                            return check;
                                          });
                                        });
                                        individualChatId.forEach((element) {
                                          snapshot.data!.data.indexWhere((elm) {
                                            checkMute = elm.userid == element &&
                                                elm.muteStatus == '1';
                                            print(checkMute);
                                            return checkMute;
                                          });
                                        });
                                      });
                                      // ScaffoldMessenger.of(context)
                                      //     .showSnackBar(
                                      //   SnackBar(
                                      //     content: Text(
                                      //         '${snapshot.data!.data[index].name} is already selected'),
                                      //   ),
                                      // );
                                    }

                                    /// Delete Individual Chat ///
                                    if (!chatProcessing.contains(
                                        snapshot.data!.data[index].room)) {
                                      chatProcessing
                                          .add(snapshot.data!.data[index].room);
                                      print(snapshot.data!.data[index].room);
                                    } else {
                                      setState(() {
                                        chatProcessing.remove(
                                            snapshot.data!.data[index].room);
                                        print(snapshot.data!.data[index].room);
                                      });

                                      // ScaffoldMessenger.of(context)
                                      //     .showSnackBar(
                                      //   SnackBar(
                                      //     content: Text(
                                      //         '${snapshot.data!.data[index].name} is already selected'),
                                      //   ),
                                      // );
                                    }
                                  } else {
                                    /// Pin Group Chat ///
                                    if (!groupChatId.contains(
                                        snapshot.data!.data[index].room)) {
                                      groupChatId
                                          .add(snapshot.data!.data[index].room);
                                      individualChatId.add(0);
                                      groupChatId.forEach((element) {
                                        snapshot.data!.data.indexWhere((elm) {
                                          check = elm.room == element &&
                                              elm.pinStatus == '1';
                                          return check;
                                        });
                                      });
                                      groupChatId.forEach((element) {
                                        snapshot.data!.data.indexWhere((elm) {
                                          checkMute = elm.room == element &&
                                              elm.muteStatus == '1';
                                          print(checkMute);
                                          return checkMute;
                                        });
                                      });
                                    } else {
                                      setState(() {
                                        groupChatId.remove(
                                            snapshot.data!.data[index].room);
                                        individualChatId.remove(0);
                                        groupChatId.forEach((element) {
                                          snapshot.data!.data.indexWhere((elm) {
                                            checkMute = elm.room == element &&
                                                elm.muteStatus == '1';
                                            print(checkMute);
                                            return checkMute;
                                          });
                                        });
                                        groupChatId.forEach((element) {
                                          snapshot.data!.data.indexWhere((elm) {
                                            check = elm.room == element &&
                                                elm.pinStatus == '1';
                                            return check;
                                          });
                                        });
                                      });

                                      // ScaffoldMessenger.of(context)
                                      //     .showSnackBar(
                                      //   SnackBar(
                                      //     content: Text(
                                      //         '${snapshot.data!.data[index].name} is already selected'),
                                      //   ),
                                      // );
                                    }

                                    /// Delete Group Chat ///
                                    if (!chatProcessing.contains(
                                        snapshot.data!.data[index].room)) {
                                      chatProcessing
                                          .add(snapshot.data!.data[index].room);
                                      print(snapshot.data!.data[index].room);
                                    } else {
                                      setState(() {
                                        chatProcessing.remove(
                                            snapshot.data!.data[index].room);
                                        print(snapshot.data!.data[index].room);
                                      });
                                      // ScaffoldMessenger.of(context)
                                      //     .showSnackBar(
                                      //   SnackBar(
                                      //     content: Text(
                                      //         '${snapshot.data!.data[index].name} is already selected'),
                                      //   ),
                                      // );
                                    }
                                  }
                                  if (chatProcessing.isEmpty ||
                                      groupChatId.isEmpty ||
                                      individualChatId.isEmpty) {
                                    setState(() {
                                      pressStatus = false;
                                      pin.setValue(false);
                                    });
                                  }
                                  print(individualChatId);
                                  if (check) {
                                    pinStatus = check;
                                    pin.checkPinned(pinStatus);
                                  }
                                  if (checkMute) {
                                    print('pine');
                                    print(checkMute);
                                    muteStatus = checkMute;
                                    pin.checkMuted(muteStatus);
                                  } else {
                                    pin.checkMuted(false);
                                  }
                                });
                                pin.setValue(pressStatus);
                                // print(snapshot.data!.data[index].)
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                // backgroundColor: Colors.transparent,
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        _destroySocket();
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => ProfilePictureViewChat(
                                                                    name: snapshot
                                                                        .data!
                                                                        .data[
                                                                            index]
                                                                        .name,
                                                                    picture: snapshot
                                                                        .data!
                                                                        .data[
                                                                            index]
                                                                        .profile)));
                                                      },
                                                      child: Container(
                                                        width: 200,
                                                        height: 200,
                                                        decoration:
                                                            BoxDecoration(
                                                          image:
                                                              DecorationImage(
                                                            image: NetworkImage(
                                                                snapshot
                                                                    .data!
                                                                    .data[index]
                                                                    .profile),
                                                            fit: BoxFit.fill,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      decoration:
                                                          const BoxDecoration(
                                                              color:
                                                                  Colors.white),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          IconButton(
                                                              onPressed:
                                                                  () async {
                                                                _destroySocket();
                                                                if (snapshot
                                                                        .data!
                                                                        .data[
                                                                            index]
                                                                        .chatType ==
                                                                    'private') {
                                                                  String
                                                                      refresh =
                                                                      await Navigator
                                                                          .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (_) =>
                                                                              NewConversation(
                                                                        toFcm: snapshot
                                                                            .data!
                                                                            .data[index]
                                                                            .deviceToken,
                                                                        rId: snapshot
                                                                            .data!
                                                                            .data[index]
                                                                            .userid,
                                                                        roomId: snapshot
                                                                            .data!
                                                                            .data[index]
                                                                            .room,
                                                                      ),
                                                                    ),
                                                                  );
                                                                  if (refresh ==
                                                                      'refresh') {
                                                                    setState(
                                                                        () {
                                                                      socketProcessing();
                                                                    });
                                                                  }
                                                                }

                                                                if (snapshot
                                                                        .data!
                                                                        .data[
                                                                            index]
                                                                        .chatType ==
                                                                    'group') {
                                                                  String
                                                                      refresh =
                                                                      await Navigator
                                                                          .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (_) =>
                                                                              GroupConversationScreen(
                                                                        gId: snapshot
                                                                            .data!
                                                                            .data[index]
                                                                            .room,
                                                                      ),
                                                                    ),
                                                                  );
                                                                  if (refresh ==
                                                                      'refresh') {
                                                                    setState(
                                                                        () {
                                                                      socketProcessing();
                                                                    });
                                                                  }
                                                                }
                                                              },
                                                              icon: Icon(
                                                                  Icons
                                                                      .chat_bubble,
                                                                  color:
                                                                      textGreen)),
                                                          IconButton(
                                                              onPressed: () {
                                                                _destroySocket();
                                                                if (snapshot
                                                                        .data!
                                                                        .data[
                                                                            index]
                                                                        .chatType ==
                                                                    'group') {
                                                                  get_group_user_list(
                                                                          auth
                                                                              .userId,
                                                                          auth
                                                                              .accessToken,
                                                                          snapshot
                                                                              .data!
                                                                              .data[index]
                                                                              .userid)
                                                                      .then(
                                                                    (value) async {
                                                                      print(
                                                                          '______________________-part 1______________________');
                                                                      grupeFCM.remove(await FirebaseMessaging
                                                                          .instance
                                                                          .getToken());
                                                                      await Future.wait(grupeFCM
                                                                          .toSet()
                                                                          .toList()
                                                                          .map(
                                                                              (e) async {
                                                                        print(
                                                                            '______________________-part 2______________________');
                                                                        await gruopeAudioCallPushMessage(
                                                                            e,
                                                                            snapshot.data!.data[index].name,
                                                                            snapshot.data!.data[index].room);
                                                                      })).then(
                                                                          (value) {
                                                                        print(
                                                                            '______________________-part 3______________________');
                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                                builder: (context) => CallingPage(
                                                                                      toFCM: '',
                                                                                      userName: snapshot.data!.data[index].name,
                                                                                      profile: snapshot.data!.data[index].profile,
                                                                                      groupeFCM: grupeFCM,
                                                                                      type: 'groupe',
                                                                                    )));
                                                                      });
                                                                    },
                                                                  );
                                                                  // print(recent
                                                                  //         .recentChat[
                                                                  //     index]['room']);
                                                                  print(
                                                                      'grupeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee');
                                                                } else {
                                                                  audioCallPushMessage(
                                                                          snapshot
                                                                              .data!
                                                                              .data[index]
                                                                              .deviceToken,
                                                                          auth.username)
                                                                      .then((value) {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) => CallingPage(
                                                                                  groupeFCM: const [],
                                                                                  type: '',
                                                                                  toFCM: snapshot.data!.data[index].deviceToken,
                                                                                  userName: snapshot.data!.data[index].name,
                                                                                  profile: snapshot.data!.data[index].profile,
                                                                                )));
                                                                  });
                                                                }
                                                              },
                                                              icon: Icon(
                                                                  Icons.call,
                                                                  color:
                                                                      textGreen)),
                                                          IconButton(
                                                              onPressed: () {
                                                                _destroySocket();
                                                                if (snapshot
                                                                        .data!
                                                                        .data[
                                                                            index]
                                                                        .chatType ==
                                                                    'group') {
                                                                  get_group_user_list(
                                                                          auth
                                                                              .userId,
                                                                          auth
                                                                              .accessToken,
                                                                          snapshot
                                                                              .data!
                                                                              .data[index]
                                                                              .userid)
                                                                      .then((value) async {
                                                                    print(
                                                                        '______________________-part 1______________________');
                                                                    grupeFCM.remove(await FirebaseMessaging
                                                                        .instance
                                                                        .getToken());
                                                                    await Future.wait(grupeFCM
                                                                        .toSet()
                                                                        .toList()
                                                                        .map(
                                                                            (e) async {
                                                                      print(
                                                                          '______________________-part 2______________________');
                                                                      await gruopeVideoCallPushMessage(
                                                                          e,
                                                                          snapshot
                                                                              .data!
                                                                              .data[
                                                                                  index]
                                                                              .name,
                                                                          snapshot
                                                                              .data!
                                                                              .data[index]
                                                                              .room);
                                                                    })).then(
                                                                        (value) {
                                                                      print(
                                                                          '______________________-part 3______________________');
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => VideoCameraRingScreen(
                                                                                    toFCM: '',
                                                                                    userName: snapshot.data!.data[index].name,
                                                                                    profile: snapshot.data!.data[index].profile,
                                                                                    groupeFCM: grupeFCM,
                                                                                    type: 'groupe',
                                                                                  )));
                                                                    });
                                                                  });

                                                                  print(
                                                                      'grupeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee');
                                                                } else {
                                                                  vedioCallPushMessage(
                                                                          snapshot
                                                                              .data!
                                                                              .data[index]
                                                                              .deviceToken,
                                                                          auth.username)
                                                                      .then(
                                                                    (value) {
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => VideoCameraRingScreen(
                                                                                    groupeFCM: const [],
                                                                                    type: '',
                                                                                    toFCM: snapshot.data!.data[index].deviceToken,
                                                                                    userName: snapshot.data!.data[index].name,
                                                                                    profile: snapshot.data!.data[index].profile,
                                                                                  )));
                                                                    },
                                                                  );
                                                                  // print(recent.recentChat[
                                                                  //         index][
                                                                  //     'device_token']);
                                                                }
                                                              },
                                                              icon: Icon(
                                                                  Icons
                                                                      .videocam,
                                                                  color:
                                                                      textGreen)),
                                                          IconButton(
                                                              onPressed: () {
                                                                _destroySocket();
                                                                if (snapshot
                                                                        .data!
                                                                        .data[
                                                                            index]
                                                                        .chatType ==
                                                                    'group') {
                                                                  var grp = Provider.of<
                                                                          GroupProvider>(
                                                                      context,
                                                                      listen:
                                                                          false);

                                                                  grp.getGroupInfo(
                                                                      groupId: snapshot
                                                                          .data!
                                                                          .data[
                                                                              index]
                                                                          .room,
                                                                      context:
                                                                          context);

                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (_) =>
                                                                              GroupInfo(groupId: snapshot.data!.data[index].userid)));
                                                                } else {
                                                                  var info = Provider.of<
                                                                          InfoProvider>(
                                                                      context,
                                                                      listen:
                                                                          false);
                                                                  info.getIndividualProfile(
                                                                      snapshot
                                                                          .data!
                                                                          .data[
                                                                              index]
                                                                          .userid,
                                                                      context);
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (_) =>
                                                                              ConversationInfo(receiverId: snapshot.data!.data[index].userid)));
                                                                }
                                                              },
                                                              icon: Icon(
                                                                  Icons
                                                                      .info_outline,
                                                                  color:
                                                                      textGreen)),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: snapshot.data!.data[index]
                                                    .chatType ==
                                                "private"
                                            ? Container(
                                                width: 60,
                                                height: 60,
                                                padding:
                                                    const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                    color: pin.isPressed &&
                                                            individualChatId
                                                                .contains(snapshot
                                                                    .data!
                                                                    .data[index]
                                                                    .userid)
                                                        ? rightGreen
                                                        : Colors.grey[200],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                child: CircleAvatar(
                                                  backgroundImage: snapshot
                                                              .data!
                                                              .data[index]
                                                              .profile !=
                                                          null
                                                      ? NetworkImage(snapshot
                                                          .data!
                                                          .data[index]
                                                          .profile)
                                                      : const NetworkImage(
                                                          'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png'),
                                                ),
                                              )
                                            : Container(
                                                width: 60,
                                                height: 60,
                                                padding:
                                                    const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                    color: pin.isPressed &&
                                                            groupChatId.contains(
                                                                snapshot
                                                                    .data!
                                                                    .data[index]
                                                                    .room)
                                                        ? rightGreen
                                                        : Colors.grey[200],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                child: CircleAvatar(
                                                  backgroundImage: snapshot
                                                              .data!
                                                              .data[index]
                                                              .profile !=
                                                          null
                                                      ? NetworkImage(snapshot
                                                          .data!
                                                          .data[index]
                                                          .profile)
                                                      : const NetworkImage(
                                                          'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png'),
                                                ),
                                              ),
                                      ),
                                      const SizedBox(width: 15),
                                      if (isTyping &&
                                          typingUser ==
                                              snapshot.data!.data[index].userid)
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              displayName ??
                                                  snapshot
                                                      .data!.data[index].name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              'typing....',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle: FontStyle.italic,
                                                  color: textGreen),
                                            ),
                                          ],
                                        )
                                      else
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              displayName ??
                                                  snapshot
                                                      .data!.data[index].name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            if (snapshot.data!.data[index]
                                                        .messageType ==
                                                    'text' ||
                                                snapshot.data!.data[index]
                                                        .messageType ==
                                                    'notification')
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    right: 30.0),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    190,
                                                child: new Text(
                                                  snapshot.data!.data[index]
                                                      .message,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  softWrap: false,
                                                  style: TextStyle(
                                                    color: snapshot
                                                                .data!
                                                                .data[index]
                                                                .unreadMessage ==
                                                            '0'
                                                        ? const Color(
                                                            0xFF9B9898)
                                                        : Colors.black,
                                                  ),
                                                ),
                                              ),
                                            if (snapshot.data!.data[index]
                                                    .messageType ==
                                                'voice')
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    right: 30.0),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    190,
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                        Icons
                                                            .audiotrack_rounded,
                                                        color: snapshot
                                                                    .data!
                                                                    .data[index]
                                                                    .unreadMessage ==
                                                                '0'
                                                            ? const Color(
                                                                0xFF9B9898)
                                                            : Colors.black),
                                                    Text(
                                                      'audio',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      softWrap: false,
                                                      style: TextStyle(
                                                        color: snapshot
                                                                    .data!
                                                                    .data[index]
                                                                    .unreadMessage ==
                                                                '0'
                                                            ? const Color(
                                                                0xFF9B9898)
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (snapshot.data!.data[index]
                                                    .messageType ==
                                                'image')
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    right: 30.0),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    190,
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.image,
                                                        color: snapshot
                                                                    .data!
                                                                    .data[index]
                                                                    .unreadMessage ==
                                                                '0'
                                                            ? const Color(
                                                                0xFF9B9898)
                                                            : Colors.black),
                                                    Text(
                                                      'image',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      softWrap: false,
                                                      style: TextStyle(
                                                        color: snapshot
                                                                    .data!
                                                                    .data[index]
                                                                    .unreadMessage ==
                                                                '0'
                                                            ? const Color(
                                                                0xFF9B9898)
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (snapshot.data!.data[index]
                                                    .messageType ==
                                                'video')
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    right: 30.0),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    190,
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.play_circle,
                                                        color: snapshot
                                                                    .data!
                                                                    .data[index]
                                                                    .unreadMessage ==
                                                                '0'
                                                            ? const Color(
                                                                0xFF9B9898)
                                                            : Colors.black),
                                                    new Text(
                                                      'video',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      softWrap: false,
                                                      style: TextStyle(
                                                        color: snapshot
                                                                    .data!
                                                                    .data[index]
                                                                    .unreadMessage ==
                                                                '0'
                                                            ? const Color(
                                                                0xFF9B9898)
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (snapshot.data!.data[index]
                                                    .messageType ==
                                                'doc')
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    right: 30.0),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    190,
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.picture_as_pdf,
                                                        color: snapshot
                                                                    .data!
                                                                    .data[index]
                                                                    .unreadMessage ==
                                                                '0'
                                                            ? const Color(
                                                                0xFF9B9898)
                                                            : Colors.black),
                                                    new Text(
                                                      'document',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      softWrap: false,
                                                      style: TextStyle(
                                                        color: snapshot
                                                                    .data!
                                                                    .data[index]
                                                                    .unreadMessage ==
                                                                '0'
                                                            ? const Color(
                                                                0xFF9B9898)
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (snapshot.data!.data[index]
                                                    .messageType ==
                                                'location')
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    right: 30.0),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    190,
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.location_pin,
                                                        color: snapshot
                                                                    .data!
                                                                    .data[index]
                                                                    .unreadMessage ==
                                                                '0'
                                                            ? const Color(
                                                                0xFF9B9898)
                                                            : Colors.black),
                                                    new Text(
                                                      'location',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      softWrap: false,
                                                      style: TextStyle(
                                                        color: snapshot
                                                                    .data!
                                                                    .data[index]
                                                                    .unreadMessage ==
                                                                '0'
                                                            ? const Color(
                                                                0xFF9B9898)
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      const Spacer(),
                                      if (snapshot.data!.data[index]
                                                  .unreadMessage !=
                                              '0' ||
                                          snapshot.data!.data[index]
                                                  .pinStatus !=
                                              '0' ||
                                          snapshot.data!.data[index]
                                                  .muteStatus !=
                                              '0')
                                        if (snapshot
                                                .data!.data[index].muteStatus ==
                                            '1')
                                          const Icon(Icons.volume_off_sharp,
                                              color: Colors.grey),
                                      if (snapshot
                                              .data!.data[index].pinStatus ==
                                          '1')
                                        const Icon(Icons.push_pin,
                                            color: Colors.grey),
                                      Column(
                                        children: [
                                          DateTime.now()
                                                      .toString()
                                                      .substring(0, 11) ==
                                                  snapshot
                                                      .data!.data[index].date
                                                      .toString()
                                                      .substring(0, 11)
                                              ? Text(
                                                  snapshot
                                                      .data!.data[index].date
                                                      .toString()
                                                      .substring(11, 16),
                                                  style: TextStyle(
                                                      color: snapshot
                                                                  .data!
                                                                  .data[index]
                                                                  .unreadMessage ==
                                                              '0'
                                                          ? Colors.grey
                                                          : Colors.black),
                                                )
                                              : Text(
                                                  DateFormat('dd/MM/yyyy')
                                                      .format(snapshot.data!
                                                          .data[index].date)
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: snapshot
                                                                  .data!
                                                                  .data[index]
                                                                  .unreadMessage ==
                                                              '0'
                                                          ? Colors.grey
                                                          : Colors.black)),
                                          if (snapshot.data!.data[index]
                                                  .unreadMessage !=
                                              '0')
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: rightGreen),
                                              child: Center(
                                                child: Text(
                                                  snapshot.data!.data[index]
                                                      .unreadMessage,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Divider()
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }
        } else {
          return ListView.builder(
            itemCount: 8,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Shimmer.fromColors(
                      direction: ShimmerDirection.ttb,
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: const CircleAvatar(
                        maxRadius: 35,
                      ),
                    ),
                    Flexible(
                      child: Shimmer.fromColors(
                        direction: ShimmerDirection.ltr,
                        child: Container(
                            height: 80,
                            width: 280,
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(30),
                            )),
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                      ),
                    )
                  ],
                ),
              );
            },
          );
        }
      },
    );
    return Consumer<RecentChatProvider>(
      builder: (context, recent, child) {},
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
}

extension DateHelpers on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return now.day == this.day &&
        now.month == this.month &&
        now.year == this.year;
  }

  bool isYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return yesterday.day == this.day &&
        yesterday.month == this.month &&
        yesterday.year == this.year;
  }
}
