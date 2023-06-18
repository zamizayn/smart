import 'package:flutter/material.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:provider/provider.dart';

import '../../../../providers/ChatFuntionProvider/chatFunctionProvider.dart';
import '../../../../utils/constants/urls.dart';
import '../group_conversation_screen.dart';
import '../models/chat_List_model.dart';
import '../newConvoScreen.dart';

class ArchiveChatList extends StatefulWidget {
  List<Datum> chatList;
  ArchiveChatList({Key? key, required this.chatList}) : super(key: key);

  @override
  State<ArchiveChatList> createState() => _ArchiveChatListState();
}

class _ArchiveChatListState extends State<ArchiveChatList> {
  final IO.Socket _socket = IO.io(AppUrls.appSocketUrl,
      IO.OptionBuilder().setTransports(['websocket']).build());

  bool archiveStatus = false;
  List<int> indexForSelected = [];

  @override
  Widget build(BuildContext context) {
    final pin = context.watch<PinChatProvider>();
    var auth = Provider.of<AuthProvider>(context, listen: false);
    return WillPopScope(
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50.0),
            child: pin.isPressed
                ? AppBar(
                    backgroundColor: Colors.grey,
                    leading: IconButton(
                      onPressed: () {
                        archiveStatus = false;
                        pin.setValue(archiveStatus);
                      },
                      icon: Icon(Icons.arrow_back),
                    ),
                    actions: [
                      IconButton(
                        onPressed: () {
                          var body = {
                            'user_id': auth.userId,
                            'accessToken': auth.accessToken,
                            'room': chatProcessing.join(',')
                          };

                          if (_socket.connected) {
                            _socket.on('delete_chat_list', (data) {
                              if (data['message'] == 'success') {
                                archiveStatus = false;
                                chatProcessing.clear();
                                pin.setValue(archiveStatus);
                                if (widget.chatList.length != 0) {
                                  setState(() {});
                                } else {
                                  Navigator.pop(context, 'refresh');
                                }
                              }
                            });

                            _socket.emit('delete_chat_list', body);
                          } else {
                            _socket.connect();
                            _socket.on('delete_chat_list', (data) {
                              if (data['message'] == 'success') {
                                archiveStatus = false;
                                chatProcessing.clear();
                                pin.setValue(archiveStatus);
                                if (widget.chatList.length != 0) {
                                  setState(() {});
                                } else {
                                  Navigator.pop(context, 'refresh');
                                }
                              }
                            });

                            _socket.emit('delete_chat_list', body);
                          }
                        },
                        icon: Icon(Icons.delete),
                      ),
                      IconButton(
                        onPressed: () {
                          var body = {
                            'user_id': auth.userId,
                            'accessToken': auth.accessToken,
                            'room': chatProcessing.join(',')
                          };
                          _socket.emit('unarchived_chat_list', body);
                          if (_socket.connected) {
                            _socket.on('unarchived_chat_list', (data) {
                              if (data['message'] == 'success') {
                                archiveStatus = false;
                                pin.setValue(archiveStatus);
                                Navigator.pop(context, 'refresh');
                                chatProcessing.clear();
                              }
                            });
                          } else {
                            _socket.connect();
                            _socket.emit('unarchived_chat_list', body);

                            _socket.on('unarchived_chat_list', (data) {
                              if (data['message'] == 'success') {
                                archiveStatus = false;
                                chatProcessing.clear();
                                pin.setValue(archiveStatus);
                                Navigator.pop(context, 'refresh');
                              }
                            });

                            // _socket.emit('unarchived_chat_list', body);
                          }
                        },
                        icon: Icon(Icons.unarchive_outlined),
                      ),
                    ],
                  )
                : AppBar(
                    backgroundColor: Colors.grey,
                    leading: IconButton(
                      onPressed: () {
                        _socket.disconnect();
                        Navigator.pop(context, 'refresh');
                      },
                      icon: Icon(Icons.arrow_back),
                    ),
                    title: Text('Archived Chat List'),
                  ),
          ),
          body: ListView.builder(
            itemCount: widget.chatList.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: InkWell(
                        onTap: () async {
                          if (archiveStatus) {
                            if (!chatProcessing
                                .contains(widget.chatList[index].room)) {
                              setState(() {
                                chatProcessing.add(widget.chatList[index].room);
                                indexForSelected.add(index);
                              });
                            } else {
                              setState(() {
                                chatProcessing
                                    .remove(widget.chatList[index].room);
                                indexForSelected.remove(index);
                                print(chatProcessing);
                                if (chatProcessing.isEmpty) {
                                  setState(() {
                                    archiveStatus = false;
                                  });
                                }
                              });
                            }
                          } else if (widget.chatList[index].chatType ==
                              'private') {
                            String refresh = await Navigator.of(context)
                                .push(MaterialPageRoute(
                              builder: (context) => NewConversation(
                                  rId: widget.chatList[index].userid,
                                  roomId: widget.chatList[index].room,
                                  toFcm: widget.chatList[index].deviceToken),
                            ));
                          } else {
                            String refresh = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => GroupConversationScreen(
                                    gId: widget.chatList[index].room),
                              ),
                            );
                          }
                          pin.setValue(archiveStatus);
                        },
                        onLongPress: () {
                          archiveStatus = true;
                          if (archiveStatus) {
                            if (!chatProcessing
                                .contains(widget.chatList[index].room)) {
                              setState(() {
                                chatProcessing.add(widget.chatList[index].room);
                                indexForSelected.add(index);
                              });
                            } else {
                              setState(() {
                                chatProcessing
                                    .remove(widget.chatList[index].room);
                                indexForSelected.remove(index);

                                print(chatProcessing);
                                if (chatProcessing.isEmpty) {
                                  setState(() {
                                    archiveStatus = false;
                                  });
                                }
                              });
                            }
                          }
                          pin.setValue(archiveStatus);
                          print(archiveStatus);
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                  color: chatProcessing
                                          .contains(widget.chatList[index].room)
                                      ? Colors.green
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(15)),
                              child: CircleAvatar(
                                backgroundImage: widget
                                            .chatList[index].profile !=
                                        null
                                    ? NetworkImage(
                                        widget.chatList[index].profile)
                                    : const NetworkImage(
                                        'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png'),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.chatList[index].name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                if (widget.chatList[index].messageType ==
                                        'text' ||
                                    widget.chatList[index].messageType ==
                                        'notification')
                                  Container(
                                    padding: const EdgeInsets.only(right: 30.0),
                                    width:
                                        MediaQuery.of(context).size.width - 190,
                                    child: new Text(
                                      widget.chatList[index].message,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      style: TextStyle(
                                        color: widget.chatList[index]
                                                    .unreadMessage ==
                                                '0'
                                            ? const Color(0xFF9B9898)
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                if (widget.chatList[index].messageType ==
                                    'voice')
                                  Container(
                                    padding: const EdgeInsets.only(right: 30.0),
                                    width:
                                        MediaQuery.of(context).size.width - 190,
                                    child: Row(
                                      children: [
                                        Icon(Icons.audiotrack_rounded,
                                            color: widget.chatList[index]
                                                        .unreadMessage ==
                                                    '0'
                                                ? const Color(0xFF9B9898)
                                                : Colors.black),
                                        Text(
                                          'audio',
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                          style: TextStyle(
                                            color: widget.chatList[index]
                                                        .unreadMessage ==
                                                    '0'
                                                ? const Color(0xFF9B9898)
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (widget.chatList[index].messageType ==
                                    'image')
                                  Container(
                                    padding: const EdgeInsets.only(right: 30.0),
                                    width:
                                        MediaQuery.of(context).size.width - 190,
                                    child: Row(
                                      children: [
                                        Icon(Icons.image,
                                            color: widget.chatList[index]
                                                        .unreadMessage ==
                                                    '0'
                                                ? const Color(0xFF9B9898)
                                                : Colors.black),
                                        Text(
                                          'image',
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                          style: TextStyle(
                                            color: widget.chatList[index]
                                                        .unreadMessage ==
                                                    '0'
                                                ? const Color(0xFF9B9898)
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (widget.chatList[index].messageType ==
                                    'video')
                                  Container(
                                    padding: const EdgeInsets.only(right: 30.0),
                                    width:
                                        MediaQuery.of(context).size.width - 190,
                                    child: Row(
                                      children: [
                                        Icon(Icons.play_circle,
                                            color: widget.chatList[index]
                                                        .unreadMessage ==
                                                    '0'
                                                ? const Color(0xFF9B9898)
                                                : Colors.black),
                                        new Text(
                                          'video',
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                          style: TextStyle(
                                            color: widget.chatList[index]
                                                        .unreadMessage ==
                                                    '0'
                                                ? const Color(0xFF9B9898)
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (widget.chatList[index].messageType == 'doc')
                                  Container(
                                    padding: const EdgeInsets.only(right: 30.0),
                                    width:
                                        MediaQuery.of(context).size.width - 190,
                                    child: Row(
                                      children: [
                                        Icon(Icons.picture_as_pdf,
                                            color: widget.chatList[index]
                                                        .unreadMessage ==
                                                    '0'
                                                ? const Color(0xFF9B9898)
                                                : Colors.black),
                                        new Text(
                                          'document',
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                          style: TextStyle(
                                            color: widget.chatList[index]
                                                        .unreadMessage ==
                                                    '0'
                                                ? const Color(0xFF9B9898)
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (widget.chatList[index].messageType ==
                                    'location')
                                  Container(
                                    padding: const EdgeInsets.only(right: 30.0),
                                    width:
                                        MediaQuery.of(context).size.width - 190,
                                    child: Row(
                                      children: [
                                        Icon(Icons.location_pin,
                                            color: widget.chatList[index]
                                                        .unreadMessage ==
                                                    '0'
                                                ? const Color(0xFF9B9898)
                                                : Colors.black),
                                        new Text(
                                          'location',
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                          style: TextStyle(
                                            color: widget.chatList[index]
                                                        .unreadMessage ==
                                                    '0'
                                                ? const Color(0xFF9B9898)
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
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
        onWillPop: () {
          _socket.disconnect();
          Navigator.pop(context, 'refresh');
          return Future.value(false);
        });
  }
}
