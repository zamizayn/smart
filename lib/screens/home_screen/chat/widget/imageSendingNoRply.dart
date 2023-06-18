import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../../../utils/constants/app_constants.dart';
import '../../../../utils/constants/urls.dart';

class ImageSendingNoRplyScreen extends StatefulWidget {
  String fPath;
  String hPath;
  String recId;
  String fileType;
  String chatType;
  ImageSendingNoRplyScreen(
      {Key? key,
      required this.chatType,
      required this.fPath,
      required this.hPath,
      required this.recId,
      required this.fileType})
      : super(key: key);

  @override
  State<ImageSendingNoRplyScreen> createState() =>
      _ImageSendingNoRplyScreenState();
}

class _ImageSendingNoRplyScreenState extends State<ImageSendingNoRplyScreen> {

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
    _connectSocket();
    super.initState();
  }

  @override
  void dispose() {
    widget.fPath = '';
    widget.hPath = '';
   // _destroySocket();
    super.dispose();
  }

  final TextEditingController _controller = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    return WillPopScope(
      child: Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(onPressed: (){
          setState(() {
            isUploading = false;
          });
          Navigator.pop(context);
        }, icon: const Icon(Icons.arrow_back), color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Spacer(),
          SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            width: double.infinity,
            child: Image(
              image: NetworkImage(widget.fPath),
              fit: BoxFit.contain,
            ),
          ),
          const Spacer(),
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
                      SizedBox(
                        width:
                        MediaQuery.of(context).size.width -
                            60,
                        height: 70,
                        child: Card(
                          margin: const EdgeInsets.only(
                              left: 2, right: 2, bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(25),
                          ),
                          child: Center(
                            child:TextField(
                              controller: _controller,
                              focusNode: focusNode,
                              textAlignVertical:
                              TextAlignVertical.center,
                              keyboardType:
                              TextInputType.multiline,
                              maxLines: 5,
                              minLines: 1,
                              onTap: () {
                                // getFocus();
                              },
                              onChanged: (value) {
                                // if (_controller.text.length >
                                //     0) {
                                //   setState(() {
                                //     sndBtn = true;
                                //     socket.emit(
                                //         'typing_individual', {
                                //       "sid": auth.userId,
                                //       "rid": widget.rId,
                                //       "status": "1"
                                //     });
                                //     socket.on(
                                //         'typing_individual_room',
                                //             (data) {
                                //           print(
                                //               "RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR");
                                //           print(data);
                                //           print(
                                //               "RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR");
                                //         });
                                //   });
                                // } else {
                                //   setState(() {
                                //     sndBtn = false;
                                //   });
                                // }
                              },
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Type Message',
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 8, right: 5, left: 2),
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 25,
                          child: IconButton(
                              onPressed: () {
                                // if (rply) {
                                //   var body = {
                                //     "sid": auth.userId,
                                //     "rid": widget.rId,
                                //     "message":
                                //     _controller.value.text,
                                //     "type": "text",
                                //     "message_id": replyId
                                //   };
                                //   print(
                                //       "BODY:=======================> $body");
                                //   setState(() {
                                //     socket.emit(
                                //         "message", body);
                                //     _controller.clear();
                                //     sndBtn = false;
                                //     rply = false;
                                //     socket.emit(
                                //         'typing_individual', {
                                //       "sid": auth.userId,
                                //       "rid": widget.rId,
                                //       "status": "0"
                                //     });
                                //     socket.on(
                                //         'typing_individual_room',
                                //             (data) {
                                //           print(
                                //               "RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR");
                                //           print(data);
                                //           print(
                                //               "RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR");
                                //         });
                                //   });
                                // } else {
                                //   setState(() {
                                //     socket.emit("message", {
                                //       "sid": auth.userId,
                                //       "rid": widget.rId,
                                //       "message":
                                //       _controller.text,
                                //       "type": "text"
                                //     });
                                //     _controller.clear();
                                //     sndBtn = false;
                                //     socket.emit(
                                //         'typing_individual', {
                                //       "sid": auth.userId,
                                //       "rid": widget.rId,
                                //       "status": "0"
                                //     });
                                //     socket.on(
                                //         'typing_individual_room',
                                //             (data) {
                                //           print(
                                //               "RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR");
                                //           print(data);
                                //           print(
                                //               "RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR");
                                //         });
                                //   });
                                // }
                               var body;
                                if (widget.chatType == 'single') {
                                  body = {
                                    'sid': auth.userId,
                                    'rid': widget.recId,
                                    'message': widget.hPath,
                                    'optional_text': _controller.text.isNotEmpty ? _controller.text : '',
                                    'type': widget.fileType,
                                  };
                                }
                                if (widget.chatType == 'group') {
                                  body = {
                                    'sid': auth.userId,
                                    'room': widget.recId,
                                    'message': widget.hPath,
                                    'optional_text': _controller.text.isNotEmpty ? _controller.text : '',
                                    'type': widget.fileType,
                                  };
                                }
                                // var body = {
                                //   "sid": auth.userId,
                                //   "rid": widget.recId,
                                //   "message": widget.hPath,
                                //   "type": "image",
                                // };
                                _socket.emit('message', body);
                                Navigator.pop(context,'refresh');
                              },
                              icon: const Icon(
                                Icons.send,
                                color: Colors.green,
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
                // show ? emojiPicker() : Container(),
                // vwe ? bottomContainer() : Container()
              ],
            ),
          ),
        ],
      ),
    ), 
      onWillPop: () {
        setState(() {
          isUploading = false;
        });
        Navigator.pop(context,'refresh');
        return Future.value(false); 
      },);
  }
}
