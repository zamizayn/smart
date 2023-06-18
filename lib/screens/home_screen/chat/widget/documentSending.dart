import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../../providers/AuthProvider/auth_provider.dart';
import '../../../../utils/constants/app_constants.dart';
import '../../../../utils/constants/urls.dart';

class DocumentSendingScreen extends StatefulWidget {
  String fPath;
  String hPath;
  String rplyId;
  String recId;
  String fileType;
  String fileName;
  String chatType;
  DocumentSendingScreen(
      {Key? key,
      required this.chatType,
      required this.fPath,
      required this.hPath,
      required this.rplyId,
      required this.recId,
        required this.fileName,
      required this.fileType})
      : super(key: key);

  @override
  State<DocumentSendingScreen> createState() => _DocumentSendingScreenState();
}

class _DocumentSendingScreenState extends State<DocumentSendingScreen> {

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
    print("CCCCCCCCCCCCCCCCCCCCCCCCCCCCCC");
    print(widget.fileType);
    print("CCCCCCCCCCCCCCCCCCCCCCCCCCCCCC");
    super.initState();
    _connectSocket();
  }

  @override
  void dispose() {
    widget.fPath = '';
    widget.hPath = '';
    widget.rplyId = '';
    //_destroySocket();
    super.dispose();
  }

  final TextEditingController _controller = TextEditingController();
  FocusNode focusNode = FocusNode();
    final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();


  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    return WillPopScope(
      child: Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.fileName),
        leading: IconButton(onPressed: (){
          setState(() {
            isUploading = false;
          });
          Navigator.pop(context,'refresh');
        }, icon: const Icon(Icons.arrow_back), color: Colors.white),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          if (widget.fileType == 'pdf')
            SizedBox(
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
              child: SfPdfViewer.network(
            widget.fPath,
            key: _pdfViewerKey,
          )
            ),
          if (widget.fileType == 'txt')
            SizedBox(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(15),
                  child: Image(image: AssetImage(text)),
                )
            ),

          if (widget.fileType == 'ppt')
            SizedBox(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(15),
                  child: Image(image: AssetImage(pptIcon)),
                )
            ),

          if (widget.fileType == 'xlsx')
            SizedBox(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(15),
                  child: Image(image: AssetImage(excelIcon)),
                )
            ),

          if (widget.fileType == 'json')
            SizedBox(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(15),
                  child: Image(image: AssetImage(json)),
                )
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
                          backgroundColor: Colors.grey[300],
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
                                    'sid': auth.userId,
                                    'rid': widget.recId,
                                    'message': widget.hPath,
                                    'optional_text': _controller.text.isNotEmpty ? _controller.text : '',
                                    'type': 'doc',
                                    'message_id': widget.rplyId
                                  };
                                }
                                if (widget.chatType == 'group') {

                                  rplyBody = {
                                    'sid': auth.userId,
                                    'room': widget.recId,
                                    'message': widget.hPath,
                                    'optional_text': _controller.text.isNotEmpty ? _controller.text : '',
                                    'type': 'doc',
                                    'message_id': widget.rplyId
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
