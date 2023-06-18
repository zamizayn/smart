import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/providers/ChatFuntionProvider/chatFunctionProvider.dart';
import 'package:smart_station/providers/ProfileProvider/profile_provider.dart';
import 'package:smart_station/providers/UserProvider/user_provider.dart';
import 'package:smart_station/screens/callAndNotification/callNotification.dart';
import 'package:smart_station/screens/home_screen/chat/chat_screen.dart';
import 'package:smart_station/screens/home_screen/contacts/user_list.dart';
import 'package:smart_station/screens/home_screen/email/email_compose_screen.dart';
import 'package:smart_station/screens/home_screen/email/email_screen.dart';
import 'package:smart_station/screens/home_screen/email/email_sent_screen.dart';
import 'package:smart_station/screens/home_screen/group/create_group_screen.dart';
import 'package:smart_station/screens/home_screen/letter/letter_archieved_screen.dart';
import 'package:smart_station/screens/home_screen/letter/letter_compose_screen.dart';
import 'package:smart_station/screens/home_screen/letter/letter_draft_screen.dart';
import 'package:smart_station/screens/home_screen/letter/letter_important_screen.dart';
import 'package:smart_station/screens/home_screen/letter/letter_screen.dart';
import 'package:smart_station/screens/home_screen/letter/letter_search_list.dart';
import 'package:smart_station/screens/home_screen/letter/letter_sent_screen.dart';
import 'package:smart_station/screens/home_screen/letter/letter_starred_screen.dart';
import 'package:smart_station/screens/home_screen/popup_screens/settings_screen.dart';
import 'package:smart_station/screens/home_screen/widgets/bottom_section.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:smart_station/screens/phone_screen/phone_screen.dart';
import '../../providers/LetterProvider/letter_provider.dart';
import '../../utils/constants/urls.dart';
import 'chat/starred_message_list.dart';
import 'email/apiServices.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class HomeScreen extends StatefulWidget {
  final tabindex;
  const HomeScreen({Key? key, this.tabindex}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool isPressed = false;
  bool cancelPress = true;
  bool unpinStatus = true;
  bool menuTap = false;
  var tabIndex = 0;
  List allEmails = [];

  final GlobalKey _menuKey = GlobalKey();
  late TabController _tabController;
  final IO.Socket _socket = IO.io(AppUrls.appSocketUrl,
      IO.OptionBuilder().setTransports(['websocket']).build());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var auth = Provider.of<AuthProvider>(context, listen: false);
    NotificationServices.callNotification();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    get_user_mailids(auth.userId, auth.accessToken).then((value) {
      if (value.statusCode == 200) {
        var data = jsonDecode(value.body);
        allEmails = data['mailids'];
        // print("data");
        // print(allEmails);
      }
    });
    if (widget.tabindex != null) {
      tabIndex = widget.tabindex;
    }
    _tabController = TabController(
      initialIndex: tabIndex,
      length: 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();

    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      // Do something with the current index here
      print('Current index: ${_tabController.index}');

      setState(() {
        print('gooo hell email');
      }); // Rebuild the widget tree
    }
  }

  @override
  Widget build(BuildContext context) {
    TabBar tabBar = TabBar(
      controller: _tabController,
      indicator: BoxDecoration(color: Colors.grey[200]),
      onTap: (value) {
        setState(() {
          tabIndex = value;
          if (menuTap) {
            setState(() {
              menuTap = !menuTap;
            });
          }
        });
      },
      tabs: [
        Tab(
            child: Row(children: [
          ImageIcon(AssetImage(chatIcon), color: rightGreen, size: 22),
          const SizedBox(width: 8),
          const Text(
            'Chat',
            style: TextStyle(fontSize: 14, color: Colors.black),
          )
        ])),
        Tab(
            child: Row(children: [
          ImageIcon(AssetImage(mailIcon), color: rightGreen, size: 22),
          const SizedBox(width: 8),
          const Text(
            'Email',
            style: TextStyle(fontSize: 14, color: Colors.black),
          )
        ])),
        Tab(
            child: Row(children: [
          ImageIcon(AssetImage(letterIcon), color: rightGreen, size: 22),
          const SizedBox(width: 8),
          const Text(
            'Letter',
            style: TextStyle(fontSize: 14, color: Colors.black),
          )
        ])),
      ],
    );
    var auth = Provider.of<AuthProvider>(context, listen: false);
    var profile = Provider.of<ProfileProvider>(context, listen: false);
    var userP = Provider.of<UserProvider>(context, listen: false);
    var letter = Provider.of<LetterProvider>(context, listen: false);
    return Stack(
      children: [
        GestureDetector(onTap: () {
          if (menuTap) {
            setState(() {
              menuTap = !menuTap;
            });
          }
        }, child: Consumer2<LetterProvider, PinChatProvider>(
            builder: (context, letter, pin, child) {
          return Scaffold(
            floatingActionButton: _tabController.index == 0
                ? FloatingActionButton(
                    onPressed: () {
                      _socket.disconnect();
                      userP.userList(context: context);
                      Future.delayed(
                          const Duration(milliseconds: 500),
                          () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const UserList())));
                    },
                    backgroundColor: Colors.green,
                    elevation: 2,
                    child: const Icon(Icons.chat),
                  )
                : Container(),
            appBar: (letter.selectedLetter.isNotEmpty &&
                    _tabController.index == 2)
                ? AppBar(
                    backgroundColor: Colors.grey[500],
                    leading: IconButton(
                        onPressed: (() {
                          selectedInboxLetter.clear();
                          selectedDateInbox.clear();
                          tempDeleteInbox.clear();
                          tempSelectedInbox.clear();
                          starredStatusInbox.clear();
                          importantStatusInbox.clear();
                          mailReadInbox.clear();
                          letter.getSelectedLetter([]);
                        }),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 30,
                        )),
                    title: Text('${letter.selectedLetter.length} selected'),
                    actions: [
                      IconButton(
                          onPressed: () {
                            deletePressedInbox = true;
                            setState(() {
                              print('assign to temp');

                              tempDeleteInbox = List.from(selectedDateInbox);
                              selectedDateInbox.clear();
                              tempSelectedInbox =
                                  List.from(selectedInboxLetter);
                              selectedInboxLetter.clear();
                              letter.getSelectedLetter(selectedInboxLetter);
                              starredStatusInbox.clear();
                              importantStatusInbox.clear();
                              mailReadInbox.clear();
                            });

                            // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            //   duration: Duration(seconds: 5),
                            //   content: Text("Archived"),
                            //   action: SnackBarAction(
                            //     label: "Undo",
                            //     onPressed: () {
                            //       // deletePressed=false;
                            //       selectedInboxLetter.clear();
                            //       selectedDateInbox.clear();
                            //       tempDeleteInbox.clear();
                            //       setState(() {
                            //         // tempDelete.clear();
                            //         deletePressedInbox = false;
                            //         undoPressedInbox = true;
                            //       });
                            //     },
                            //   ),
                            // ));

                            // Future.delayed(Duration(seconds: 3), () {
                            //   if (undoPressedInbox == true) {
                            //     setState(() {
                            //       // tempDelete.clear();
                            //       deletePressedInbox = false;
                            //       // selectedImportantLetter.clear();
                            //       // selectedDate.clear();
                            //       tempDeleteInbox.clear();
                            //       tempSelectedInbox.clear();
                            //     });

                            //     print("hello");
                            //   } else {
                            LetterProvider()
                                .multipleArchiveLetter(
                                    context, tempSelectedInbox)
                                .then((value) {
                              // var data = jsonDecode(value.body);
                              // print(data);
                              LetterProvider().getInboxList(context);
                              letter.getSelectedLetter([]);
                            });
                            setState(() {
                              deletePressedInbox = false;
                              tempDeleteInbox.clear();
                              tempSelectedInbox.clear();
                              print('unpressed false');
                            });
                            //   }
                            // });
                          },
                          icon: const Icon(
                            Icons.archive,
                            color: Colors.white,
                            size: 30,
                          )),
                      IconButton(
                          onPressed: () {
                            deletePressedInbox = true;
                            setState(() {
                              print('assign to temp');

                              tempDeleteInbox = List.from(selectedDateInbox);
                              selectedDateInbox.clear();
                              tempSelectedInbox =
                                  List.from(selectedInboxLetter);
                              selectedInboxLetter.clear();
                              letter.getSelectedLetter(selectedInboxLetter);
                              starredStatusInbox.clear();
                              importantStatusInbox.clear();
                              mailReadInbox.clear();
                              letter.getSelectedLetter(selectedInboxLetter);
                            });

                            // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            //   duration: Duration(seconds: 5),
                            //   content: Text("Deleted"),
                            //   action: SnackBarAction(
                            //     label: "Undo",
                            //     onPressed: () {
                            //       // deletePressed=false;
                            //       selectedInboxLetter.clear();
                            //       selectedDateInbox.clear();
                            //       tempDeleteInbox.clear();
                            //       letter.getSelectedLetter(selectedInboxLetter);
                            //       setState(() {
                            //         // tempDelete.clear();
                            //         deletePressedInbox = false;
                            //         undoPressedInbox = true;
                            //       });
                            //     },
                            //   ),
                            // ));

                            // Future.delayed(Duration(seconds: 3), () {
                            //   if (undoPressedInbox == true) {
                            //     setState(() {
                            //       // tempDelete.clear();
                            //       deletePressedInbox = false;
                            //       // selectedImportantLetter.clear();
                            //       // selectedDate.clear();
                            //       tempDeleteInbox.clear();
                            //       tempSelectedInbox.clear();
                            //     });

                            //     print("hello");
                            //   } else {
                            LetterProvider()
                                .multipleDeleteLetter(
                                    context, tempSelectedInbox)
                                .then((value) {
                              var data = jsonDecode(value.body);
                              print(data);
                              letter.getInboxList(context);
                            });
                            setState(() {
                              deletePressedInbox = false;
                              tempDeleteInbox.clear();
                              tempSelectedInbox.clear();
                              print('unpressed false');
                            });
                            //   }
                            // });
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 30,
                          )),
                      IconButton(
                          onPressed: () {
                            if (mailReadInbox.contains('1')) {
                              tempSelectedInbox =
                                  List.from(selectedInboxLetter);
                              selectedInboxLetter.clear();
                              letter.getSelectedLetter(selectedInboxLetter);
                              starredStatusInbox.clear();
                              importantStatusInbox.clear();
                              mailReadInbox.clear();
                              setState(() {});
                              LetterProvider()
                                  .multipleMarkasReadLetter(
                                      context, tempSelectedInbox)
                                  .then((value) {
                                var data = jsonDecode(value.body);
                                print(data);
                                setState(() {
                                  tempSelectedInbox.clear();
                                  selectedDateInbox.clear();

                                  LetterProvider().getInboxList(context);
                                  letter.getSelectedLetter([]);
                                  setState(() {});
                                });
                              });
                            } else {
                              tempSelectedInbox =
                                  List.from(selectedInboxLetter);
                              selectedInboxLetter.clear();
                              starredStatusInbox.clear();
                              importantStatusInbox.clear();
                              mailReadInbox.clear();
                              setState(() {});
                              LetterProvider()
                                  .multipleMarkasUnreadLetter(
                                      context, tempSelectedInbox)
                                  .then((value) {
                                var data = jsonDecode(value.body);
                                print(data);
                                setState(() {
                                  tempSelectedInbox.clear();
                                  selectedDateInbox.clear();

                                  LetterProvider().getInboxList(context);
                                  letter.getSelectedLetter([]);
                                  setState(() {});
                                });
                              });
                            }
                          },
                          icon: mailReadInbox.contains('1')
                              ? const Icon(Icons.mark_email_read)
                              : const Icon(Icons.mark_email_unread)),
                      //     InkWell(
                      //   onTap: () {

                      //   },
                      //   child: Image.asset(
                      //     countIcon,
                      //     color: Colors.white,
                      //     height: 35,
                      //     width: 35,
                      //   ),
                      // ),
                      PopupMenuButton<String>(
                        iconSize: 30,
                        onSelected: (value) {
                          print('Selected value: $value');
                          switch (value) {
                            case 'option1':
                              if (importantStatusInbox.contains('0')) {
                                tempSelectedInbox =
                                    List.from(selectedInboxLetter);
                                selectedInboxLetter.clear();
                                letter.getSelectedLetter(selectedInboxLetter);
                                starredStatusInbox.clear();
                                importantStatusInbox.clear();
                                mailReadInbox.clear();
                                setState(() {});
                                LetterProvider()
                                    .multipleImportantLetter(
                                        context, tempSelectedInbox)
                                    .then((value) {
                                  var data = jsonDecode(value.body);
                                  print(data);
                                  setState(() {
                                    tempSelectedInbox.clear();
                                    selectedDateInbox.clear();

                                    LetterProvider().getInboxList(context);
                                    setState(() {});
                                  });
                                });
                              } else {
                                tempSelectedInbox =
                                    List.from(selectedInboxLetter);
                                selectedInboxLetter.clear();
                                letter.getSelectedLetter(selectedInboxLetter);
                                starredStatusInbox.clear();
                                importantStatusInbox.clear();
                                mailReadInbox.clear();
                                setState(() {});
                                LetterProvider()
                                    .multipleUnimportantLetter(
                                        context, tempSelectedInbox)
                                    .then((value) {
                                  var data = jsonDecode(value.body);
                                  print(data);
                                  setState(() {
                                    tempSelectedInbox.clear();
                                    selectedDateInbox.clear();

                                    LetterProvider().getInboxList(context);
                                    setState(() {});
                                  });
                                });
                              }
                              break;
                            case 'option2':
                              break;
                            case 'option3':
                              if (starredStatusInbox.contains('0')) {
                                tempSelectedInbox =
                                    List.from(selectedInboxLetter);
                                selectedInboxLetter.clear();
                                letter.getSelectedLetter(selectedInboxLetter);
                                starredStatusInbox.clear();
                                importantStatusInbox.clear();
                                mailReadInbox.clear();
                                setState(() {});
                                LetterProvider()
                                    .multipleStarLetter(
                                        context, tempSelectedInbox)
                                    .then((value) {
                                  var data = jsonDecode(value.body);
                                  print(data);
                                  setState(() {
                                    tempSelectedInbox.clear();
                                    selectedDateInbox.clear();

                                    LetterProvider().getInboxList(context);
                                    setState(() {});
                                  });
                                });
                              } else {
                                tempSelectedInbox =
                                    List.from(selectedInboxLetter);
                                selectedInboxLetter.clear();
                                letter.getSelectedLetter(selectedInboxLetter);
                                starredStatusInbox.clear();
                                importantStatusInbox.clear();
                                mailReadInbox.clear();
                                setState(() {});
                                LetterProvider()
                                    .multipleUnstarLetter(
                                        context, tempSelectedInbox)
                                    .then((value) {
                                  var data = jsonDecode(value.body);
                                  print(data);
                                  setState(() {
                                    tempSelectedInbox.clear();
                                    selectedDateInbox.clear();

                                    LetterProvider().getInboxList(context);
                                    setState(() {});
                                  });
                                });
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
                              child: Text(importantStatusInbox.contains('0')
                                  ? 'Mark important'
                                  : 'Mark unimportant'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'option2',
                              child: Text('Help & feedback'),
                            ),
                            PopupMenuItem<String>(
                              value: 'option3',
                              child: Text(starredStatusInbox.contains('0')
                                  ? 'Add Star'
                                  : 'Remove Star'),
                            ),
                          ];
                        },
                      ),
                    ],
                  )
                : (letter.selectedChat.isNotEmpty && _tabController.index == 0)
                    ? AppBar(
                        backgroundColor: Colors.grey[500],
                        leading: IconButton(
                            onPressed: () {
                              letter.getSelectedChat([]);
                            },
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 30,
                            )),
                        actions: [
                          IconButton(
                              onPressed: () {
                                // var auth = Provider.of<AuthProvider>(context, listen: false);
                                // final body = {
                                // 'accessToken': auth.accessToken,
                                // 'user_id': auth.userId,
                                // 'receiver_id': ,
                                // 'room':
                                // };
                                //   if (socket.connected) {
                                //     print('*****************[SOCKET CONNECTED]****************');
                                //     socket.emit('chat_list', body);
                                //     socket.on('chat_list', (data) {
                                //       print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
                                //       print('invoked');
                                //       print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
                                //   });

                                // } else {
                                //     print('*****************[SOCKET DISCONNECTED]****************');
                                //     socket.connect();
                                //     socket.emit('chat_list', body);
                                //     socket.on('chat_list', (data) {
                                //     print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
                                //     print('invoked');
                                //     print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

                                //   });

                                // }
                              },
                              icon: const Icon(
                                Icons.push_pin,
                                color: Colors.white,
                                size: 30,
                              )),
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.notifications_off,
                                color: Colors.white,
                                size: 30,
                              )),
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.archive,
                                color: Colors.white,
                                size: 30,
                              )),
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.white,
                                size: 30,
                              ))
                        ],
                      )
                    : AppBar(
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        elevation: 0,
                        leading: pin.isPressed
                            ? IconButton(
                                onPressed: () {
                                  setState(() {
                                    cancelPress = false;
                                    individualChatId.clear();
                                    groupChatId.clear();
                                    chatProcessing.clear();
                                  });
                                  pin.setValue(cancelPress);
                                },
                                icon: Icon(Icons.arrow_back),
                                color: rightGreen)
                            : InkWell(
                                onTap: () {
                                  setState(() {
                                    menuTap = !menuTap;
                                    tabIndex = _tabController.index;
                                    print(menuTap);
                                  });
                                },
                                child: menuTap
                                    ? null
                                    : Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 18, vertical: 18),
                                        child: Image(
                                          image: AssetImage(menuIcon),
                                        ),
                                      ),
                              ),
                        actions: pin.isPressed
                            ? [
                                /// Pin / Unpin
                                InkWell(
                                  onTap: pin.isPinned
                                      ? () {
                                          if (_socket.connected) {
                                            var body = {
                                              "user_id": auth.userId,
                                              "accessToken": auth.accessToken,
                                              "receiver_id":
                                                  individualChatId.join(','),
                                              "room": groupChatId.join(',')
                                            };

                                            _socket.emit('unpin_chat', body);
                                            _socket.on('unpin_chat', (data) {
                                              if (data['message'] ==
                                                  'Unpinned') {
                                                setState(() {
                                                  unpinStatus = false;
                                                  cancelPress = false;
                                                  clearData();
                                                });
                                                pin.setValue(cancelPress);
                                                pin.checkPinned(unpinStatus);
                                              }
                                            });
                                          } else {
                                            _socket.connect();
                                            var body = {
                                              "user_id": auth.userId,
                                              "accessToken": auth.accessToken,
                                              "receiver_id":
                                                  individualChatId.join(','),
                                              "room": groupChatId.join(',')
                                            };

                                            _socket.emit('unpin_chat', body);
                                            _socket.on('unpin_chat', (data) {
                                              if (data['message'] ==
                                                  'Unpinned') {
                                                setState(() {
                                                  unpinStatus = false;
                                                  cancelPress = false;
                                                  clearData();
                                                });
                                                pin.setValue(cancelPress);
                                                pin.checkPinned(unpinStatus);
                                              }
                                            });
                                          }
                                        }
                                      : () {
                                          if (_socket.connected) {
                                            print(_socket.connected);
                                            var body = {
                                              "user_id": auth.userId,
                                              "accessToken": auth.accessToken,
                                              "receiver_id":
                                                  individualChatId.join(','),
                                              "room": groupChatId.join(',')
                                            };

                                            _socket.emit('pin_chat', body);
                                            _socket.on('pin_chat', (data) {
                                              print(
                                                  '*********************************************');
                                              print(data);
                                              print(
                                                  '*********************************************');
                                              if (data['message'] == 'Pinned') {
                                                setState(() {
                                                  cancelPress = false;
                                                  clearData();
                                                });
                                                pin.setValue(cancelPress);
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        '${data['message']}'),
                                                  ),
                                                );
                                                setState(() {
                                                  cancelPress = false;
                                                  clearData();
                                                });
                                                pin.setValue(cancelPress);
                                              }
                                            });
                                          } else {
                                            print(_socket.connected);
                                            _socket.connect();
                                            var body = {
                                              "user_id": auth.userId,
                                              "accessToken": auth.accessToken,
                                              "receiver_id":
                                                  individualChatId.join(','),
                                              "room": groupChatId.join(',')
                                            };

                                            _socket.emit('pin_chat', body);
                                            _socket.on('pin_chat', (data) {
                                              print(
                                                  '*********************************************');
                                              print(data);
                                              print(
                                                  '*********************************************');
                                              if (data['message'] == 'Pinned') {
                                                setState(() {
                                                  cancelPress = false;
                                                  clearData();
                                                });
                                                pin.setValue(cancelPress);
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        '${data['message']}'),
                                                  ),
                                                );
                                                setState(() {
                                                  cancelPress = false;
                                                  clearData();
                                                });
                                                pin.setValue(cancelPress);
                                              }
                                            });
                                          }
                                        },
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    height: 10,
                                    width: 25,
                                    child: Image(
                                      image: AssetImage(
                                          pin.isPinned ? unpinIcon : pinIcon),
                                    ),
                                  ),
                                ),

                                /// Delete Chat
                                IconButton(
                                    onPressed: () {
                                      print(chatProcessing);
                                      if (_socket.connected) {
                                        var body = {
                                          'user_id': auth.userId,
                                          'accessToken': auth.accessToken,
                                          'room': chatProcessing.join(',')
                                        };
                                        _socket.emit('delete_chat_list', body);
                                        _socket.on('delete_chat_list', (data) {
                                          print(data);
                                          if (data['message'] == 'success') {
                                            setState(() {
                                              cancelPress = false;
                                              clearData();
                                            });
                                            pin.setValue(cancelPress);
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content:
                                                    Text('${data['message']}'),
                                              ),
                                            );
                                            setState(() {
                                              cancelPress = false;
                                              clearData();
                                            });
                                            pin.setValue(cancelPress);
                                          }
                                        });
                                      } else {
                                        _socket.connect();
                                        var body = {
                                          'user_id': auth.userId,
                                          'accessToken': auth.accessToken,
                                          'room': chatProcessing.join(',')
                                        };
                                        _socket.emit('delete_chat_list', body);
                                        _socket.on('delete_chat_list', (data) {
                                          print(data);
                                          if (data['message'] == 'success') {
                                            clearData();
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content:
                                                    Text('${data['message']}'),
                                              ),
                                            );
                                            setState(() {
                                              cancelPress = false;
                                              clearData();
                                            });
                                            pin.setValue(cancelPress);
                                          }
                                        });
                                      }
                                    },
                                    icon: Icon(Icons.delete),
                                    color: rightGreen),

                                /// Mute / Unmute
                                IconButton(
                                    onPressed: pin.isMuted
                                        ? () {
                                            print("EEEEEEEEEEEEEEEEEEE");
                                            print(individualChatId);
                                            print(groupChatId);
                                            print("EEEEEEEEEEEEEEEEEEE");
                                            if (_socket.connected) {
                                              String selectedValue = '';

                                              var body = {
                                                "user_id": auth.userId,
                                                "accessToken": auth.accessToken,
                                                "receiver_id":
                                                    individualChatId.join(','),
                                                "room": groupChatId.join(','),
                                                "type": selectedValue
                                              };
                                              _socket.emit(
                                                  'unmute_chat_list', body);
                                              _socket.on('unmute_chat_list',
                                                  (data) {
                                                print(data);
                                                if (data['message'] ==
                                                    'success') {
                                                  cancelPress = false;
                                                  clearData();
                                                  pin.setValue(cancelPress);
                                                  Navigator.pop(context);
                                                } else {
                                                  cancelPress = false;
                                                  clearData();
                                                  pin.setValue(cancelPress);
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          '${data['message']}'),
                                                    ),
                                                  );
                                                }
                                              });
                                            }
                                          }
                                        : () {
                                            print("EEEEEEEEEEEEEEEEEEE");
                                            print(individualChatId);
                                            print(groupChatId);
                                            print("EEEEEEEEEEEEEEEEEEE");
                                            if (_socket.connected) {
                                              String selectedValue = '';

                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return StatefulBuilder(
                                                    builder:
                                                        (context, setState) {
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
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                              value: '8_hours',
                                                              groupValue:
                                                                  selectedValue,
                                                              onChanged:
                                                                  (value) {
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
                                                              onChanged:
                                                                  (value) {
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
                                                              onChanged:
                                                                  (value) {
                                                                print(value);
                                                                setState(() {
                                                                  selectedValue =
                                                                      value!;
                                                                });
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                        actions: <Widget>[
                                                          TextButton(
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(),
                                                              child: Text(
                                                                  'Cancel',
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
                                                                var body = {
                                                                  "user_id": auth
                                                                      .userId,
                                                                  "accessToken":
                                                                      auth.accessToken,
                                                                  "receiver_id":
                                                                      individualChatId
                                                                          .join(
                                                                              ','),
                                                                  "room":
                                                                      groupChatId
                                                                          .join(
                                                                              ','),
                                                                  "type":
                                                                      selectedValue
                                                                };
                                                                _socket.emit(
                                                                    'mute_chat_list',
                                                                    body);
                                                                _socket.on(
                                                                    'mute_chat_list',
                                                                    (data) {
                                                                  if (data[
                                                                          'message'] ==
                                                                      'success') {
                                                                    cancelPress =
                                                                        false;
                                                                    clearData();
                                                                    pin.setValue(
                                                                        cancelPress);
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  } else {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                            Text('${data['message']}'),
                                                                      ),
                                                                    );
                                                                  }
                                                                });
                                                              },
                                                              child: Text(
                                                                'Ok',
                                                                style: TextStyle(
                                                                    color:
                                                                        textGreen,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        18),
                                                              ),
                                                            ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                            }
                                          },
                                    icon: Icon(pin.isMuted
                                        ? Icons.volume_mute
                                        : Icons.volume_off_sharp),
                                    color: rightGreen),

                                /// Archive / Unarvhive
                                IconButton(
                                    onPressed: () {
                                      var body = {
                                        'user_id': auth.userId,
                                        'accessToken': auth.accessToken,
                                        'room': chatProcessing.join(',')
                                      };
                                      print(body);

                                      if (_socket.connected) {
                                        _socket.emit(
                                            'archived_chat_list', body);
                                        _socket.on('archived_chat_list',
                                            (data) {
                                          print('DATA =========> $data');
                                          cancelPress = false;
                                          individualChatId.clear();
                                          groupChatId.clear();
                                          chatProcessing.clear();
                                          pin.setValue(cancelPress);
                                        });
                                      }
                                    },
                                    icon: Icon(Icons.archive),
                                    color: rightGreen),

                                /// More Options
                                IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.more_vert),
                                    color: rightGreen),
                              ]
                            : [
                                _tabController.index == 0
                                    ? Consumer<UserProvider>(
                                        builder: (context, user, child) {
                                          return InkWell(
                                            onTap: () {
                                              var uId = auth.userId;
                                              var aToken = auth.accessToken;
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 18,
                                                      vertical: 18),
                                              child: Image(
                                                image: AssetImage(searchIcon),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : Container(),
                                _tabController.index == 2
                                    ? InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const LetterSearchList()));
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 18, vertical: 18),
                                          child: Image(
                                            image: AssetImage(searchIcon),
                                          ),
                                        ),
                                      )
                                    : Container()
                              ],
                        bottom: PreferredSize(
                          preferredSize: tabBar.preferredSize,
                          child: Material(
                            color: Colors.grey[300],
                            child: tabBar,
                          ),
                        ),
                      ),
            bottomNavigationBar: BottomBarSection(
              tabIndex: _tabController.index,
              emailList: allEmails,
            ),
            body: GestureDetector(onTap: () {
              if (menuTap) {
                setState(() {
                  menuTap = !menuTap;
                });
              }
            }, child: Builder(builder: (BuildContext context) {
              _tabController.animation!.addListener(() {
                if (_tabController.index != 0) {
                  print('email email,email');
                  chat_List_StreamController.close();
                  _socket.dispose();
                }
                if (!_tabController.indexIsChanging) {
                  setState(() {
                    tabIndex = _tabController.index;
                    if (menuTap) {
                      setState(() {
                        menuTap = !menuTap;
                      });
                    }
                  });
                }
              });
              // if (_tabController.indexIsChanging) {
              //   tabIndex=_tabController.index;
              //   if (menuTap)
              //         setState(() {
              //           menuTap = !menuTap;
              //         });
              // }
              return TabBarView(
                physics: const BouncingScrollPhysics(),
                controller: _tabController,
                children: [
                  const ChatScreen(),
                  EmailScreen(allEmaildetails: allEmails),
                  const LetterScreen(),
                ],
              );
            })),
          );
        })),
        // if (menuTap)
        if (menuTap && _tabController.index == 0)
          Positioned(
            top: 60,
            left: 25,
            child: Container(
              width: 200,
              height: 250,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Scaffold(
                backgroundColor: const Color.fromARGB(0, 104, 72, 72),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //Chat menu
                  children: [
                    InkWell(
                      onTap: () {
                        var uId = auth.userId;
                        var aToken = auth.accessToken;

                        userP.userList(context: context);
                        setState(() {
                          menuTap = !menuTap;
                        });

                        // Future.delayed(
                        //     const Duration(milliseconds: 500),
                        //     () => Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //             builder: (_) =>
                        //                 const CreateGroupScreen())));
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => CreateGroupScreen()));
                      },
                      child: Container(
                          child: Text(
                        'New Group',
                        style: TextStyle(color: Colors.transparent),
                      )),
                      //const SizedBox(width: 180, child: Text('New Group')),
                    ),
                    // const DottedLine(),
                    // InkWell(
                    //   onTap: () {},
                    //   child: const SizedBox(width: 180, child: Text('Payment')),
                    // ),
                    InkWell(
                      onTap: () {
                        var uId = auth.userId;
                        var aToken = auth.accessToken;

                        userP.userList(context: context);
                        setState(() {
                          menuTap = !menuTap;
                        });

                        Future.delayed(
                            const Duration(milliseconds: 500),
                            () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const CreateGroupScreen())));
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (_) => CreateGroupScreen()));
                      },
                      child: const SizedBox(
                          width: 250,
                          height: 20,
                          child: Text(
                            'New Group',
                            style: TextStyle(fontSize: 13),
                          )),
                    ),
                    const DottedLine(),
                    InkWell(
                      onTap: () {
                        setState(() {
                          menuTap = !menuTap;
                        });
                        Future.delayed(
                            const Duration(milliseconds: 500),
                            () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const StarredMessage())));
                      },
                      child: const SizedBox(
                          width: 180, child: Text('Starred messaage')),
                    ),
                    const DottedLine(),
                    InkWell(
                      onTap: () {
                        var uid = auth.userId;
                        var aTok = auth.accessToken;
                        profile.getProfile(accessTok: aTok, userId: uid);
                        setState(() {
                          menuTap = !menuTap;
                        });
                        Future.delayed(
                            const Duration(milliseconds: 500),
                            () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        SettingsScreen(ctxt: context))));
                      },
                      child:
                          const SizedBox(width: 180, child: Text('Settings')),
                    ),
                    const DottedLine(),
                    InkWell(
                      onTap: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        setState(() {
                          menuTap = !menuTap;
                        });
                        userP.logOut(context: context);
                        prefs.clear();

                        chat_List_StreamController.close();
                        _socket.dispose();

                        // if (jsonDecode(userP.resMessage)['message'] == "Logout Successfully") {
                        //   prefs.remove('session');
                        //   prefs.remove('login_status');
                        //   prefs.remove('security');
                        //   prefs.remove('accessToken');
                        //   prefs.remove('userId');
                        //   prefs.setString('session', jsonDecode(userP.resMessage)['session'].toString());
                        //
                        // }
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PhoneScreen()));
                      },
                      child: const SizedBox(width: 180, child: Text('Log Out')),
                    ),
                    // const DottedLine(),add
                    InkWell(
                      onTap: () {
                        var uId = auth.userId;
                        var aToken = auth.accessToken;

                        userP.userList(context: context);
                        setState(() {
                          menuTap = !menuTap;
                        });

                        // Future.delayed(
                        //     const Duration(milliseconds: 500),
                        //     () => Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //             builder: (_) =>
                        //                 const CreateGroupScreen())));
                      },
                      child: const SizedBox(width: 180, child: Text('')),
                    ),
                  ],
                ),
              ),
            ),
          ),

        if (menuTap && _tabController.index == 1)
          Positioned(
            top: 60,
            left: 25,
            child: Container(
              width: 180,
              height: 200,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                  //Email Menu
                  children: [
                    InkWell(
                      onTap: () => {
                        setState(() {
                          menuTap = !menuTap;
                        }),
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => EmailComposeScreen(
                                      replayBody: '',
                                      replayEmail: '',
                                      forwardbool: false,
                                      replaySubject: '',
                                      emailList: allEmails,
                                    ))),
                      },
                      child: const SizedBox(width: 180, child: Text('Compose')),
                    ),
                    const DottedLine(),
                    InkWell(
                      onTap: () => {
                        setState(() {
                          menuTap = !menuTap;
                        }),
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => EmailSentScreen(
                                      allEmaildetails: allEmails,
                                    ))),
                      },
                      child: const SizedBox(width: 180, child: Text('Sent')),
                    ),
                    const DottedLine(),
                    InkWell(
                      onTap: () => {
                        setState(() {
                          menuTap = !menuTap;
                          chat_List_StreamController.close();
                          _socket.dispose();
                        }),
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PhoneScreen())),
                      },
                      child: const SizedBox(width: 180, child: Text('Log Out')),
                    ),
                  ],

                  //Letter Menu
                  // children: [
                  //   InkWell(
                  //     onTap: () =>
                  //     {
                  //       setState(() {
                  //         menuTap = !menuTap;
                  //       }),
                  //       Navigator.push(context, MaterialPageRoute(builder: (_) => LetterComposeScreen())),
                  //     },
                  //     child: Text("Compose"),
                  //   ),
                  //   DottedLine(),
                  //   InkWell(
                  //     onTap: () =>
                  //     {
                  //       setState(() {
                  //         menuTap = !menuTap;
                  //       }),
                  //       Navigator.push(context, MaterialPageRoute(builder: (_) => LetterInboxScreen())),
                  //     },
                  //     child: Text("Inbox"),
                  //   ),
                  //   DottedLine(),
                  //   InkWell(
                  //     onTap: () =>
                  //     {
                  //       setState(() {
                  //         menuTap = !menuTap;
                  //       }),
                  //       Navigator.push(context, MaterialPageRoute(builder: (_) => LetterSentScreen())),
                  //     },
                  //     child: Text("Sent"),
                  //   ),
                  //   DottedLine(),
                  //   InkWell(
                  //     onTap: () =>
                  //     {
                  //       setState(() {
                  //         menuTap = !menuTap;
                  //       }),
                  //       Navigator.push(context,
                  //           MaterialPageRoute(builder: (_) => PhoneScreen())),
                  //     },
                  //     child: Text("Log Out"),
                  //   ),
                  // ],
                ),
              ),
            ),
          ),
        /*Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child:
          BottomSectionTransp(),
        ),*/

        if (menuTap && _tabController.index == 2)
          Positioned(
            top: 60,
            left: 25,
            child: Container(
              width: 180,
              height: 300,
              padding: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  // Letter Menu
                  children: [
                    InkWell(
                      onTap: () => {
                        setState(() {
                          menuTap = !menuTap;
                        }),
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LetterComposeScreen())),
                      },
                      child: const SizedBox(
                          width: 180,
                          child: Text(
                            'Compose',
                            style: TextStyle(color: Colors.transparent),
                          )),
                    ),
                    InkWell(
                      onTap: () => {
                        setState(() {
                          menuTap = !menuTap;
                        }),
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LetterComposeScreen())),
                      },
                      child: const SizedBox(width: 180, child: Text('Compose')),
                    ),
                    const DottedLine(),
                    // InkWell(
                    //   onTap: () => {
                    //     setState(() {
                    //       menuTap = !menuTap;
                    //     }),
                    //     Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (_) => LetterInboxScreen())),
                    //   },
                    //   child: Container(
                    //     width: 180,
                    //     child: Text("Inbox")),
                    // ),
                    // DottedLine(),
                    InkWell(
                      onTap: () => {
                        setState(() {
                          menuTap = !menuTap;
                        }),
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LetterSentScreen())),
                      },
                      child: const SizedBox(width: 180, child: Text('Sent')),
                    ),
                    const DottedLine(),
                    InkWell(
                      onTap: () => {
                        setState(() {
                          menuTap = !menuTap;
                        }),
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LetterStarredScreen())),
                      },
                      child: const SizedBox(width: 180, child: Text('Starred')),
                    ),
                    const DottedLine(),
                    InkWell(
                      onTap: () => {
                        setState(() {
                          menuTap = !menuTap;
                        }),
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const LetterArchivedScreen()))
                            .then((value) {
                          print(value);
                          if (value == 'Refresh') {
                            letter.getSelectedLetter([]);
                          }
                        }),
                      },
                      child:
                          const SizedBox(width: 180, child: Text('Archived')),
                    ),
                    const DottedLine(),
                    InkWell(
                      onTap: () => {
                        setState(() {
                          menuTap = !menuTap;
                        }),
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LetterImportantScreen())),
                      },
                      child:
                          const SizedBox(width: 180, child: Text('Important')),
                    ),
                    const DottedLine(),
                    InkWell(
                      onTap: () => {
                        setState(() {
                          menuTap = !menuTap;
                        }),
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LetterDraftScreen())),
                      },
                      child: const SizedBox(width: 180, child: Text('Draft')),
                    ),
                    const DottedLine(),
                    InkWell(
                      onTap: () => {
                        setState(() {
                          menuTap = !menuTap;
                        }),
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PhoneScreen())),
                      },
                      child: const SizedBox(width: 180, child: Text('Log Out')),
                    ),
                  ],
                ),
              ),
            ),
          ),

        if (menuTap)
          Positioned(
            top: 30,
            left: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  menuTap = !menuTap;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 15,
                  child: Center(
                    child: Container(
                      height: 24,
                      width: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
