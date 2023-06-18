import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../../providers/AuthProvider/auth_provider.dart';
import '../../../../utils/constants/app_constants.dart';
import '../../../../utils/constants/urls.dart';

class AudioSendingScreen extends StatefulWidget {
  String fPath;
  String hPath;
  String rplyId;
  String recId;
  String fileType;
  String chatType;
  AudioSendingScreen(
      {Key? key,
      required this.chatType,
      required this.fPath,
      required this.hPath,
      required this.rplyId,
      required this.recId,
      required this.fileType})
      : super(key: key);

  @override
  State<AudioSendingScreen> createState() => _AudioSendingScreenState();
}

class _AudioSendingScreenState extends State<AudioSendingScreen> {
  AudioPlayer audioPlayer = AudioPlayer();
  Duration duration = const Duration();
  Duration position = const Duration();
  bool playing = false;

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
    super.initState();
  }

  @override
  void dispose() {
    widget.fPath = '';
    widget.hPath = '';
    widget.rplyId = '';
    //_destroySocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, 'refresh');
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () {
            var rplyBody;
            if (widget.chatType == 'single') {
              rplyBody = {
                'sid': auth.userId,
                'rid': widget.recId,
                'message': widget.hPath,
                'type': 'voice',
                'message_id': widget.rplyId
              };
            }
            if (widget.chatType == 'group') {
              rplyBody = {
                'sid': auth.userId,
                'room': widget.recId,
                'message': widget.hPath,
                'type': 'voice',
                'message_id': widget.rplyId
              };
            }
            // var rply_body = {
            //   "sid": auth.userId,
            //   "rid": widget.recId,
            //   "message": widget.hPath,
            //   "type": "voice",
            //   "message_id": widget.rplyId
            // };
            _socket.emit('message', rplyBody);
            Navigator.pop(context, 'refresh');
          },
          child: const Icon(Icons.send, color: Colors.white),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: Card(
                color: textGreen,
                child: Center(
                  child: Icon(
                    Icons.headphones,
                    size: MediaQuery.of(context).size.height / 4,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Card(
              shape: const CircleBorder(),
              elevation: 6,
              color: textGreen,
              child: IconButton(
                onPressed: () {
                  // audioPlayer.play(UrlSource(messageList[index].message));
                  getAudioUrl(widget.fPath);
                },
                icon: playing == false
                    ? const Icon(Icons.play_circle_outline, color: Colors.white)
                    : const Icon(Icons.pause_circle_outline,
                        color: Colors.white),
              ),
            ),
            slider(),
          ],
        ),
      ),
    );
  }

  void getAudioUrl(url) async {
    if (playing) {
      await audioPlayer.pause();
      setState(() {
        playing = false;
      });
    } else {
      await audioPlayer.play(UrlSource(url));
      setState(() {
        playing = true;
      });
    }

    audioPlayer.onDurationChanged.listen((Duration seekDuration) {
      setState(() {
        duration = seekDuration;
      });
    });

    audioPlayer.onPositionChanged.listen((Duration seekPosition) {
      setState(() {
        position = seekPosition;
      });
    });
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
}
