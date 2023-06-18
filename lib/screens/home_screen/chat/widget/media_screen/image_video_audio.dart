import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/screens/home_screen/chat/widget/audioPlaying.dart';
import 'package:smart_station/screens/home_screen/chat/widget/image_section.dart';
import 'package:smart_station/screens/home_screen/chat/widget/video_section.dart';
import 'package:smart_station/utils/constants/app_constants.dart';

import '../../models/individualChat/individualMediaModel.dart';

class AudVidImgSection extends StatefulWidget {
  String mediaList;
  AudVidImgSection({Key? key, required this.mediaList}) : super(key: key);

  @override
  State<AudVidImgSection> createState() => _AudVidImgSectionState();
}

class _AudVidImgSectionState extends State<AudVidImgSection> {
  // List<Doc> mediaList = [];
  dynamic fullData;
  var mediaData;

  @override
  void initState() {
    fullData = jsonDecode(widget.mediaList);
    mediaData = fullData['data']['medias'];
    // for (var element in widget.mediaArray) {
    //   if (element.type != 'date') {
    //     setState(() {
    //       mediaList.add(element);
    //     });
    //   }
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage(splashBg),
            fit: BoxFit.fill,
          )),
          child: ListView.builder(
            itemCount: mediaData['list'].length,
            
            itemBuilder: (context, index) {
              String filterOn = mediaData['list'][index];
                var data = mediaData['list_datas'][index];
              return Column(
                children: [
                  ListTile(
                    title: Text(mediaData['list'][index]),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: data[filterOn].length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 5,
                    ),
                    // itemCount: ,
                    itemBuilder: (context, gridindex) {
                      if (data[filterOn][gridindex]['type'] == 'voice') {
                        return InkWell(
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AudioPlayingScreen(fPath: data[filterOn][gridindex]['path']))),
                          child: Container(
                              color: textGreen,
                              child:const Center(child: Icon(Icons.headphones, color: Colors.white, size: 45))
                              //Text(data[filterOn][gridindex]['duration'])
                          ),
                        );
                      } else if (data[filterOn][gridindex]['type'] == 'video') {
                        return InkWell(
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => VideoSection(videoUrl: data[filterOn][gridindex]['path']))),
                          child: Stack(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width/4-1,
                                  height: MediaQuery.of(context).size.width/4-1,
                                  child:Image.network(data[filterOn][gridindex]['thumbnail'], fit: BoxFit.cover)
                              ),
                                const Positioned(
                                          left: 1,
                                          bottom: 1,
                                          child: Icon(Icons.video_camera_back,color: Colors.white,))
                            ],
                          ),
                        );
                      // } else if (widget.mediaArray[index].type == 'date') {
                      //   widget.mediaArray.removeAt(index);
                      } else {
                        return InkWell(
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ImageSection(imageUrl: data[filterOn][gridindex]['path']))),
                          child: Container(
                              child:Image.network(data[filterOn][gridindex]['path'])
                          ),
                        );
                      }
                      // return null;
                    },
                    // itemCount: widget.mediaArray.first.type == 'date' &&
                    //     widget.mediaArray.first.thumbnail == '' ||
                    //     widget.mediaArray.first.path == '' ? widget.mediaArray.length - 1 : widget.mediaArray.length,
                  ),
                ],
              );
            },
          )),
    );
  }
}
