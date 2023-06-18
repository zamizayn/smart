import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../providers/AuthProvider/auth_provider.dart';
import '../../../providers/GroupProvider/group_provider.dart';
import '../../../utils/constants/urls.dart';

class GroupDescriptionAndSubject extends StatefulWidget {
  final String id;
  final String title;
  final String content;
  final String groupId;
  const GroupDescriptionAndSubject(
      {super.key,
      required this.id,
      required this.title,
      required this.content,
      required this.groupId});

  @override
  State<GroupDescriptionAndSubject> createState() =>
      _GroupDescriptionAndSubjectState();
}

class _GroupDescriptionAndSubjectState
    extends State<GroupDescriptionAndSubject> {
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
  void initState() {
    _textEditingController.text = widget.content;
    // TODO: implement initState
    super.initState();
  }

  TextEditingController _textEditingController = TextEditingController();
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _destroySocket();

        Navigator.pop(context, 'Refresh');

        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const SizedBox(),
          backgroundColor: Colors.black26,
          title: Text(widget.title),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      hintText: widget.id == '1'
                          ? 'subject'
                          : 'Add group description',
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                        child: Align(
                      alignment: Alignment.bottomLeft,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            onPressed: () {
                              _destroySocket();
                              Navigator.pop(context,'Refresh');
                            },
                            child: const Text('Cancel')),
                      ),
                    )),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        child: Align(
                      alignment: Alignment.bottomLeft,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            onPressed: () {
                              //  Navigator.pop(context, 'Refresh');
                              // Provider.of<GroupProvider>(context, listen: false)
                              //     .getGroupInfo(
                              //         groupId: widget.groupId.toString(),
                              //         context: context);
                              // Future.delayed(Duration(microseconds: 500));

                              if (widget.id == '1') {
                                var auth = Provider.of<AuthProvider>(context,
                                    listen: false);
                                var body = {
                                  'user_id': auth.userId,
                                  'accessToken': auth.accessToken,
                                  'name': _textEditingController.text,
                                  'group_id': widget.groupId,
                                };
                                print(body);
                                if (_socket.connected) {
                                  _socket.emit('update_group_name', {
                                    'user_id': auth.userId,
                                    'accessToken': auth.accessToken,
                                    'name': _textEditingController.text,
                                    'group_id': widget.groupId,
                                  });
                                  _socket.on('update_group_name', (data) {
                                    var info = Provider.of<GroupProvider>(
                                        context,
                                        listen: false);
                                    info.getGroupInfo(
                                        groupId: widget.groupId,
                                        context: context);
                                    Future.delayed(
                                        const Duration(milliseconds: 500), () {
                                      _destroySocket();
                                      print(
                                          '======================[JOINED1]========================');
                                      print(data);
                                      Navigator.pop(context, 'Refresh');
                                    });
                                    // _destroySocket();
                                    print(
                                        '======================[JOINED1]========================');
                                    print(data);
                                    // Navigator.pop(context, 'Refresh');
                                    // Provider.of<GroupProvider>(context,
                                    //         listen: false)
                                    //     .getGroupInfo(
                                    //         groupId: widget.groupId,
                                    //         context: context);
                                  });
                                } else {
                                  _connectSocket();
                                  _socket.emit('update_group_name', {
                                    'user_id': auth.userId,
                                    'accessToken': auth.accessToken,
                                    'name': _textEditingController.text,
                                    'group_id': widget.groupId,
                                  });
                                  _socket.on('update_group_name', (data) {
                                    var info = Provider.of<GroupProvider>(
                                        context,
                                        listen: false);
                                    info.getGroupInfo(
                                        groupId: widget.groupId,
                                        context: context);

                                    Future.delayed(Duration(microseconds: 500),
                                        () {
                                      _destroySocket();
                                      print(
                                          '======================[JOINED2]========================');
                                      print(data);

                                      Navigator.pop(context, 'Refresh');
                                    });

                                    // });
                                  });
                                }
                              }
                              if (widget.id == '2') {
                                var auth = Provider.of<AuthProvider>(context,
                                    listen: false);
                                var body = {
                                  'user_id': auth.userId,
                                  'accessToken': auth.accessToken,
                                  'description': _textEditingController.text,
                                  'group_id': widget.groupId,
                                };
                                print(body);
                                if (_socket.connected) {
                                  _socket.emit('update_group_description', {
                                    'user_id': auth.userId,
                                    'accessToken': auth.accessToken,
                                    'description': _textEditingController.text,
                                    'group_id': widget.groupId,
                                  });
                                  _socket.on('update_group_description',
                                      (data) {
                                    _destroySocket();
                                    print(
                                        '======================[JOINED1]========================');
                                    print(data);
                                    Navigator.pop(context, 'Refresh');
                                  });
                                } else {
                                  _connectSocket();
                                  _socket.emit('update_group_description', {
                                    'user_id': auth.userId,
                                    'accessToken': auth.accessToken,
                                    'description': _textEditingController.text,
                                    'group_id': widget.groupId,
                                  });
                                  _socket.on('update_group_description',
                                      (data) {
                                    _destroySocket();
                                    print(
                                        '======================[JOINED2]========================');
                                    print(data);
                                    Navigator.pop(context, 'Refresh');
                                  });
                                }
                              }
                            },
                            child: const Text('OK')),
                      ),
                    )),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
