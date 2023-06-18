
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/UserProvider/user_provider.dart';
import 'package:video_player/video_player.dart';

class IndividualMedia extends StatefulWidget {
  const IndividualMedia({Key? key}) : super(key: key);

  @override
  State<IndividualMedia> createState() => _IndividualMediaState();
}

class _IndividualMediaState extends State<IndividualMedia> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    var usp = Provider.of<UserProvider>(context, listen: false);
    super.initState();

    for (int i = 0; i < usp.media.length; i++) {
      if (usp.media[i].messageType == 'video') {
        _controller =
        VideoPlayerController.network(usp.media[i].message)
          ..initialize().then((value) {
            setState(() {});
          });
      }
    }

    _controller = VideoPlayerController.network('https://youtu.be/_-0Q-vlR2rA')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, usp, child) {
        // var mData = jsonDecode(usp.resMessage);
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            leading: const BackButton(
              color: Colors.black,
            ),
            title: const Text('Medias', style: TextStyle(color: Colors.black),),
          ),
          body: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              // mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
            ),
            itemCount: usp.media.length,
            itemBuilder: (context, index) {
              if (usp.media[index]['type'] == 'image') {
                return Container(
                  height: 40,
                  width: 40,
                  color: Colors.red,
                  child: Center(
                    child: Image.network(usp.media[index]['path']),
                  ),
                );
              }
              if (usp.media[index]['type'] == 'video') {
                return Container(
                  height: 40,
                  width: 40,
                  color: Colors.red,
                  child: Center(
                    child: VideoPlayer(_controller),
                  ),
                );
              }
              if (usp.media[index]['type'] == 'voice') {
                return Container(
                  height: 40,
                  width: 40,
                  color: Colors.red,
                  child: Center(
                    child: VideoPlayer(_controller),
                  ),
                );
              }
              return Container();
            },
          )
        );
      },
    );
  }
}
