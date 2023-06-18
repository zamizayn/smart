// import 'dart:html';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/screens/home_screen/chat/models/group_media_model.dart';
import 'package:smart_station/screens/home_screen/chat/widget/audioPlaying.dart';
import 'package:smart_station/screens/home_screen/chat/widget/image_section.dart';
import 'package:smart_station/screens/home_screen/chat/widget/video_section.dart';
import 'package:smart_station/utils/constants/app_constants.dart';

class AudVidImgSectionGrp extends StatefulWidget {
  // List<Media> mediaArray;
  String mediaList;

  AudVidImgSectionGrp({Key? key, required this.mediaList}) : super(key: key);

  @override
  State<AudVidImgSectionGrp> createState() => _AudVidImgSectionState();
}

class _AudVidImgSectionState extends State<AudVidImgSectionGrp> {
  // List<Media> mediaList = [];
  // List<ListData> infoList = [];
  dynamic fullData;
  var mediaData;
  @override
  void initState() {
    print("image video page");

    fullData = jsonDecode(widget.mediaList);

    mediaData = fullData['data']['medias'];
    print(mediaData);
    // List<dynamic> mediasList1 = jsonDecode( fullData!['data']!['medias']!['list'][0]);
    // print(mediasList1);
    // print(widget.mediaList.list_datas);
    // infoList = widget.mediaList.list_datas;
    // for (var element in widget.mediaArray) {
    //   if (element.type != 'date') {
    //     mediaList.add(element);
    //   }
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    if (mediaData['list'].length > 0) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage(splashBg),
            fit: BoxFit.contain,
          )),
          // child: ListView.builder(
          //   itemCount: 2,
          //   itemBuilder: (context, index) {
          //     return SizedBox(
          //       height: 50,
          //       child: ListView.builder(

          //         itemCount: widget.mediaArray.length,
          //         scrollDirection: Axis.horizontal,
          //         itemBuilder: (BuildContext context, index) {
          //           return Container(
          //             child: Container(
          //                 child: Image.network(widget.mediaArray[index].thumbnail,
          //                     fit: BoxFit.cover)),
          //           );
          //         },
          //       ),
          //     );
          //   },
          // )

          child: ListView.builder(
              itemCount: mediaData['list'].length,
              itemBuilder: (context, index) {
                String filterOn = mediaData['list'][index];
                var data = mediaData['list_datas'][index];
                print(data[filterOn].length);
                return Column(
                  children: [
                    ListTile(
                      title: Text(mediaData['list'][index]),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: data[filterOn].length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 1,
                        mainAxisSpacing: 5,
                      ),
                      itemBuilder: (context, gridIndex) {
                        // return GridTile(
                        //   child: Text("gridItems[index][gridIndex]"),
                        // );

                        // child: Image.network(widget.mediaArray[gridIndex].path),
                        if (data[filterOn][gridIndex]['type'] == 'voice') {
                          return InkWell(
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => AudioPlayingScreen(
                                        fPath: data[filterOn][gridIndex]
                                            ['path']))),
                            child: Container(
                                color: textGreen,
                                child: const Center(
                                    child: Icon(Icons.headphones,
                                        color: Colors.white, size: 45))),
                          );
                        } else if (data[filterOn][gridIndex]['type'] ==
                            'video') {
                          return InkWell(
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => VideoSection(
                                        videoUrl: data[filterOn][gridIndex]
                                            ['path']))),
                            child: Stack(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width/4-1,
                                  height: MediaQuery.of(context).size.width/4-1,
                                    child: Image.network(
                                        data[filterOn][gridIndex]['thumbnail'],
                                        fit: BoxFit.cover)),
                                        const Positioned(
                                          left: 1,
                                          bottom: 1,
                                          child: Icon(Icons.video_camera_back,color: Colors.white,))
                              ],
                            ),
                          );
                          // } else if (widget.mediaArray[gridIndex].type == 'date') {
                          //   widget.mediaArray.removeAt(gridIndex);
                        } else {
                          return InkWell(
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => ImageSection(
                                        imageUrl: data[filterOn][gridIndex]
                                            ['path']))),
                            child: Container(
                                child: Image.network(
                                    data[filterOn][gridIndex]['path'])),
                          );
                        }
                      },
                    ),
                  ],
                );
              }),
          // child: GridView.builder(
          //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          // crossAxisCount: 4,
          // crossAxisSpacing: 2,
          // mainAxisSpacing: 5,
          //   ),
          //   itemBuilder: (context, index) {
          // if (widget.mediaArray[index].type == 'voice') {
          //   return InkWell(
          //     onTap: () => Navigator.of(context).push(MaterialPageRoute(
          //         builder: (_) => AudioPlayingScreen(
          //             fPath: widget.mediaArray[index].path))),
          //     child: Container(
          //         color: textGreen,
          //         child: const Center(
          //             child: Icon(Icons.headphones,
          //                 color: Colors.white, size: 45))),
          //   );
          // } else if (widget.mediaArray[index].type == 'video') {
          //   return InkWell(
          //     onTap: () => Navigator.of(context).push(MaterialPageRoute(
          //         builder: (_) =>
          //             VideoSection(videoUrl: widget.mediaArray[index].path))),
          //     child: Container(
          //         child: Image.network(widget.mediaArray[index].thumbnail,
          //             fit: BoxFit.cover)),
          //   );
          // } else if (widget.mediaArray[index].type == 'date') {
          //   widget.mediaArray.removeAt(index);
          // } else {
          //   return InkWell(
          //     onTap: () => Navigator.of(context).push(MaterialPageRoute(
          //         builder: (_) =>
          //             ImageSection(imageUrl: widget.mediaArray[index].path))),
          //     child: Container(
          //         child: Image.network(widget.mediaArray[index].path)),
          //   );
          // }
          //     return null;
          //   },
          //   itemCount: widget.mediaArray.first.type == 'date' &&
          //               widget.mediaArray.first.thumbnail == '' ||
          //           widget.mediaArray.first.path == ''
          //      // ? widget.mediaArray.length - 1
          //       : widget.mediaArray.length,
          // ),
        ),
      );
    }else{
      return  const Scaffold(
        body: Center(
          child: Text('No Data'),
        ),
      );
    }
  }
}
