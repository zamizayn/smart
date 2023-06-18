// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:video_player/video_player.dart';
// import 'package:chewie/chewie.dart';
//
// class VideoSection extends StatefulWidget {
//   String videoUrl;
//
//   VideoSection({Key? key, required this.videoUrl}) : super(key: key);
//
//   @override
//   State<VideoSection> createState() => _VideoSectionState();
// }
//
// class _VideoSectionState extends State<VideoSection> {
//   late VideoPlayerController _videoPlayerController;
//   ChewieController? chewieController;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _initPlayer();
//   }
//
//   void _initPlayer() async {
//     _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
//     await _videoPlayerController.initialize();
//
//     setState(() {
//       chewieController = ChewieController(
//         videoPlayerController: _videoPlayerController,
//         autoPlay: true,
//         looping: true,
//         deviceOrientationsOnEnterFullScreen: [
//           DeviceOrientation.landscapeLeft,
//         ],
//         aspectRatio: _videoPlayerController.value.aspectRatio,
//         // deviceOrientationsAfterFullScreen: [
//         //   DeviceOrientation.landscapeLeft,
//         // ],
//         additionalOptions: (context) {
//           return <OptionItem>[
//             OptionItem(
//               onTap: () => debugPrint('Option 1 Tapped'),
//               iconData: Icons.chat,
//               title: 'Option 1',
//             ),
//             OptionItem(
//               onTap: () => debugPrint('Option 2 Tapped'),
//               iconData: Icons.share,
//               title: 'Option 2',
//             ),
//           ];
//         },
//       );
//     });
//   }
//
//   @override
//   void dispose() {
//     _videoPlayerController.dispose();
//     chewieController?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Stack(
//         children: [
//           SizedBox(
//             height: MediaQuery.of(context).size.height,
//             width: double.infinity,
//             child: Center(
//               // child: VideoPlayer(_videoPlayerController),
//               child: chewieController!= null
//                       ? Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 20),
//                 child: Chewie(controller: chewieController!),
//               ) : const CircularProgressIndicator(),
//             ),
//           ),
//           Positioned(
//             top: 20,
//             child: IconButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
//           )
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoSection extends StatefulWidget {
  String videoUrl;

  VideoSection({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<VideoSection> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? chewieController;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _initPlayer() async {
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
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
  void dispose() {
    _videoPlayerController.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: Center(
              child: chewieController != null
                  ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Chewie(controller: chewieController!),
              )
                  : const CircularProgressIndicator(),
            ),
          ),
          Positioned(
            top: 40,
            child: Container(
              margin: EdgeInsets.only(left: 10),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

