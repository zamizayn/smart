import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:smart_station/screens/callAndNotification/Calling%20Individual/vediocall.dart';
import 'package:smart_station/screens/callAndNotification/callNotification.dart';
import 'Calling Individual/audioCalling.dart';
import 'groupCall/groupAudioCall.dart';
import 'groupCall/grupVideocall.dart';

class VideoCameraRingScreen extends StatefulWidget {
  String toFCM;
  String userName;
  String profile;
  List groupeFCM;
  String type;
  VideoCameraRingScreen(
      {super.key,
      required this.toFCM,
      required this.userName,
      required this.profile,
      required this.groupeFCM,
      required this.type});
  @override
  _VideoCameraRingScreenState createState() => _VideoCameraRingScreenState();
}

class _VideoCameraRingScreenState extends State<VideoCameraRingScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  final assetsAudioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    _initCamera();

    // play the audio on repeat
    assetsAudioPlayer.open(
      Audio('assets/audio/vsxeh-thatj.mp3'),
      loopMode: LoopMode.single,
    );
    assetsAudioPlayer.play();

    // stop the audio after 45 seconds
    Future.delayed(const Duration(seconds: 45), () {
      assetsAudioPlayer.stop();
      Navigator.pop(context);
    });

    // loop the audio every 6 seconds
    Timer.periodic(const Duration(seconds: 6), (timer) {
      if (assetsAudioPlayer.isPlaying.value) {
        assetsAudioPlayer.seek(Duration.zero);
        assetsAudioPlayer.play();
      }
    });
    NotificationServices.callNotification();
    FirebaseMessaging.onMessage.listen((event) async {
      print('hdfghsjgfhdjskgfhndks');
      if (event.data['type'] == 'REJECT') {
        Navigator.pop(context);
      } else if (event.data['type'] == 'VideoACCEPT') {
        print('ACCEPT,ACCEfdghsjfgdhsjkPT,ACCEPT');
        print(event.data['uid']);
        assetsAudioPlayer.stop();
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VideoCallingPage(
                  callID: event.data['uid'].toString(),
                  userName: prefs.getString('Name').toString()),
            ));
      } else if (event.data['type'] == 'audioACCEPT') {
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        print(event.data['uid']);
        assetsAudioPlayer.stop();
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AudioCallingPage(
                  callID: event.data['uid'].toString(),
                  userName: prefs.getString('Name').toString()),
            ));
      } else if (event.data['type'] == 'GroupeAudioACCEPT') {
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        print(event.data['uid']);
        assetsAudioPlayer.stop();
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => GrupeAudioCallingPage(
                  callID: event.data['uid'].toString(),
                  userName: prefs.getString('Name').toString()),
            ));
      } else if (event.data['type'] == 'GroupeVideoACCEPT') {
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        print(event.data['uid']);
        assetsAudioPlayer.stop();
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => GrupeVideoCallingPage(
                  callID: event.data['uid'].toString(),
                  userName: prefs.getString('Name').toString()),
            ));
      }
    });
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    final frontCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );
    _cameraController = CameraController(frontCamera, ResolutionPreset.high);
    await _cameraController!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    assetsAudioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    return Scaffold(
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: AspectRatio(
          aspectRatio: _cameraController!.value.aspectRatio,
          child: CameraPreview(_cameraController!,
              child: Column(
                children: [
                  const Flexible(
                    child: SizedBox(
                      height: 110,
                    ),
                  ),
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(widget.profile),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    widget.userName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Ringing',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w300),
                  ),
                  const Spacer(),
                  const Spacer(),
                  const Spacer(),
                  Center(
                    child: SizedBox(
                      height: 70,
                      width: 70,
                      child: FloatingActionButton(
                        backgroundColor: Colors.red,
                        onPressed: () async {
                          if (widget.type == 'groupe') {
                            Future.wait(widget.groupeFCM.map((e) async {
                              try {
                                http.Response response = await http.post(
                                  Uri.parse(
                                      'https://fcm.googleapis.com/fcm/send'),
                                  headers: <String, String>{
                                    'Content-Type':
                                        'application/json; charset=UTF-8',
                                    'Authorization':
                                        'key=AAAAaV_FFUY:APA91bG7a2R2cvCkc84AKqP0sNa5V9rcM0y2CeoMW_IjPBNJBJ3xkw-J5vxADkGkXpyJ7DgL-LRMYUC66RISh2iwF_O1p1p_gDxD6hmnHGpTMifC-jxPla8_lIwf5QRALvAJEIjyCO4N',
                                  },
                                  body: jsonEncode(<String, dynamic>{
                                    'notification': <String, dynamic>{
                                      'body': 'rishad',
                                      'title': 'incoming call',
                                    },
                                    'priority': 'high',
                                    'data': <String, dynamic>{
                                      'type': 'endByCaller',
                                    },
                                    'to': e,
                                  }),
                                );
                                response;
                              } catch (e) {
                                0;
                              }
                            }));
                          } else {
                            try {
                              http.Response response = await http.post(
                                Uri.parse(
                                    'https://fcm.googleapis.com/fcm/send'),
                                headers: <String, String>{
                                  'Content-Type':
                                      'application/json; charset=UTF-8',
                                  'Authorization':
                                      'key=AAAAaV_FFUY:APA91bG7a2R2cvCkc84AKqP0sNa5V9rcM0y2CeoMW_IjPBNJBJ3xkw-J5vxADkGkXpyJ7DgL-LRMYUC66RISh2iwF_O1p1p_gDxD6hmnHGpTMifC-jxPla8_lIwf5QRALvAJEIjyCO4N',
                                },
                                body: jsonEncode(<String, dynamic>{
                                  'notification': <String, dynamic>{
                                    'body': 'rishad',
                                    'title': 'incoming call',
                                  },
                                  'priority': 'high',
                                  'data': <String, dynamic>{
                                    'type': 'endByCaller',
                                  },
                                  'to': widget.toFCM,
                                }),
                              );
                              response;
                            } catch (e) {
                              0;
                            }
                          }

                          Navigator.pop(context);
                          assetsAudioPlayer.stop();
                        },
                        child: const Icon(
                          Icons.call_end,
                          size: 35,
                        ),
                      ),
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }
}
