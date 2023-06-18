import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../../../utils/constants/app_constants.dart';

class GrupeAudioCallingPage extends StatefulWidget {
  const GrupeAudioCallingPage(
      {Key? key, required this.callID, required this.userName})
      : super(key: key);
  final String callID;
  final String userName;

  @override
  State<GrupeAudioCallingPage> createState() => _GrupeAudioCallingPageState();
}

class _GrupeAudioCallingPageState extends State<GrupeAudioCallingPage> {
  final String localUserID = Random().nextInt(10000).toString();
  Duration _callDuration = Duration.zero;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration += const Duration(seconds: 1);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return '$n';
      return '0$n';
    }

    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ZegoUIKitPrebuiltCall(
              appID: zegoappid,
              appSign: zegoappsign,
              userID: localUserID,
              userName: widget.userName,
              callID: widget.callID.toString(),
              config: ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
                ..onHangUpConfirmation = (BuildContext context) async {
                  return await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Hangup Confirm',
                            style: TextStyle(
                              color: Colors.black,
                            )),
                        content: const Text('Do you want to hangup?',
                            style: TextStyle(color: Colors.black)),
                        actions: [
                          ElevatedButton(
                            child: const Text('Cancel',
                                style: TextStyle(color: Colors.black)),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          ElevatedButton(
                            child: const Text(
                              'Exit',
                              style: TextStyle(color: Colors.black),
                            ),
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ],
                      );
                    },
                  );
                },
            ),
            Positioned(
                right: 0,
                child: Text(
                  _formatDuration(_callDuration),
                  style: const TextStyle(color: Colors.red, fontSize: 20),
                ))
          ],
        ),
      ),
    );
  }
}
