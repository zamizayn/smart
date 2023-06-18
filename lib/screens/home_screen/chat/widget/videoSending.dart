import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../../providers/AuthProvider/auth_provider.dart';
import '../../../../utils/constants/app_constants.dart';
import '../../../../utils/constants/urls.dart';

class VideoSendingScreen extends StatefulWidget {
  String fPath;
  String hPath;
  String tPath;
  String rplyId;
  String recId;

  String fileType;
  String chatType;
  VideoSendingScreen(
      {Key? key,
      required this.fPath,
      required this.hPath,
      required this.rplyId,
      required this.recId,
      required this.fileType,
      required this.chatType,
      required this.tPath})
      : super(key: key);

  @override
  State<VideoSendingScreen> createState() => _VideoSendingScreenState();
}

class _VideoSendingScreenState extends State<VideoSendingScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? chewieController;

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

  void _initPlayer() async {
    _videoPlayerController = VideoPlayerController.network(widget.fPath);
    await _videoPlayerController.initialize();

    setState(() {
      chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: true,
        deviceOrientationsOnEnterFullScreen: [
          DeviceOrientation.landscapeLeft,
        ],
        aspectRatio: _videoPlayerController.value.aspectRatio,
        // deviceOrientationsAfterFullScreen: [
        //   DeviceOrientation.landscapeLeft,
        // ],
        additionalOptions: (context) {
          return <OptionItem>[
            OptionItem(
              onTap: () => debugPrint('Option 1 Tapped'),
              iconData: Icons.chat,
              title: 'Option 1',
            ),
            OptionItem(
              onTap: () => debugPrint('Option 2 Tapped'),
              iconData: Icons.share,
              title: 'Option 2',
            ),
          ];
        },
      );
    });
  }

  @override
  void initState() {
    _connectSocket();
    _initPlayer();
    super.initState();
  }

  @override
  void dispose() {
    widget.fPath = '';
    widget.hPath = '';
    widget.rplyId = '';
    _videoPlayerController.dispose();
    chewieController?.dispose();
    //_destroySocket();
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     var rply_body;
      //       if(widget.chatType == 'single'){
      //         rply_body = {
      //       "sid": auth.userId,
      //       "rid": widget.recId,
      //       "message": widget.hPath,
      //       "type": "video",
      //       "message_id": widget.rplyId
      //     };
      //       }
      //       if(widget.chatType == 'group'){
      //         rply_body = {
      //       "sid": auth.userId,
      //       "room": widget.recId,
      //       "message": widget.hPath,
      //       "type": "video",
      //       "message_id": widget.rplyId
      //     };
      //       }
      //     // var rply_body = {
      //     //   "sid": auth.userId,
      //     //   "rid": widget.recId,
      //     //   "message": widget.hPath,
      //     //   "type": "video",
      //     //   "message_id": widget.rplyId
      //     // };
      //     socket.emit("message", rply_body);
      //     Navigator.pop(context);
      //   },
      //   child: Icon(Icons.send, color: Colors.white),
      // ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Spacer(),
          SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            width: double.infinity,
            child: Center(
              // child: VideoPlayer(_videoPlayerController),
              child: chewieController != null
                  ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Chewie(controller: chewieController!),
              )
                  : const CircularProgressIndicator(),
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
                                var rplyBody;
                                if (widget.chatType == 'single') {
                                  rplyBody = {
                                    'sid':auth.userId,
                                    'rid':widget.recId,
                                    'message':widget.hPath,
                                    'optional_text':_controller.text.isNotEmpty ? _controller.text : '',
                                    'thumbnail':widget.tPath,
                                    'type':widget.fileType,
                                  };
                                }
                                if (widget.chatType == 'group') {
                                  rplyBody = {
                                    'sid':auth.userId,
                                    'room':widget.recId,
                                    'message':widget.hPath,
                                    'message_id':widget.rplyId,
                                    'optional_text':_controller.text.isNotEmpty ? _controller.text : '',
                                    'thumbnail':widget.tPath,
                                    'type':widget.fileType,
                                  };
                                }
                                _socket.emit('message', rplyBody);
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
      },
    );
  }
}
