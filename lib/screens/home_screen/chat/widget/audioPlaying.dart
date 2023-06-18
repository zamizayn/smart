import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/AuthProvider/auth_provider.dart';
import '../../../../utils/constants/app_constants.dart';

class AudioPlayingScreen extends StatefulWidget {
  String fPath;
  AudioPlayingScreen(
      {Key? key,
        required this.fPath})
      : super(key: key);

  @override
  State<AudioPlayingScreen> createState() => _AudioPlayingScreenState();
}

class _AudioPlayingScreenState extends State<AudioPlayingScreen> {
  AudioPlayer audioPlayer = AudioPlayer();
  Duration duration = const Duration();
  Duration position = const Duration();
  bool playing = false;

  @override
  void dispose() {
    widget.fPath = '';
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
                  : const Icon(Icons.pause_circle_outline, color: Colors.white),
            ),
          ),
          slider(),
        ],
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
