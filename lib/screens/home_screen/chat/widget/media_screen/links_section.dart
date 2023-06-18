import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../providers/UserProvider/user_provider.dart';
import '../../../../../utils/constants/app_constants.dart';
import 'package:path/path.dart' as path;

class LinksSection extends StatefulWidget {
  String linkList;
  LinksSection({Key? key, required this.linkList}) : super(key: key);

  @override
  State<LinksSection> createState() => _LinksSectionState();
}

class _LinksSectionState extends State<LinksSection> {
  dynamic fullData;
  var linkData;
  var finalDoc;
  var filterDoc;

  void loadURL(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  void initState() {
    fullData = jsonDecode(widget.linkList);
    filterDoc = fullData['data']['links'];
    linkData = fullData['data']['links'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var searchPro = Provider.of<UserProvider>(context, listen: true);
    // searchPro.clearData();
    var singleArray;
    if (searchPro.searchMediaValue.isNotEmpty) {
      // print(searchPro.searchMediaValue);

      for (var i = 0; i < linkData['list'].length; i++) {
        String singleData = linkData['list'][i];

        singleArray = linkData['list_datas'][i][singleData];

        print(singleData);
        print(singleArray);
        var list = [];

        linkData['list_datas'][i][singleData] = filterDoc['list_datas'][i]
                [singleData]
            .where((element) => (path.basename(element['path']).toLowerCase())
                .contains(searchPro.searchMediaValue.toLowerCase()))
            .toList();

        // print(docData['list_datas'][i][singleData]);
      }
    } else {
      print("isempty");
      setState(() {
        finalDoc = jsonDecode(widget.linkList);
        linkData = finalDoc['data']['links'];
      });
      // print(docData);
    }
    if (linkData['list'].length > 0) {
      return Scaffold(
        body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage(splashBg),
              fit: BoxFit.contain,
            )),
            child: ListView.builder(
              itemCount: linkData['list'].length,
              itemBuilder: (context, index) {
                String filterOn = linkData['list'][index];
                var data = linkData['list_datas'][index];
          
                return Column(
                  children: [
                    ListTile(
                      title: Text(linkData['list'][index]),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      // gridDelegate:
                      // const SliverGridDelegateWithFixedCrossAxisCount(
                      //   crossAxisCount: 4,
                      //   crossAxisSpacing: 2,
                      //   mainAxisSpacing: 5,
                      // ),
                      itemCount: data[filterOn].length,
                      itemBuilder: (context, gridindex) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              InkWell(
                                  onTap: () => loadURL(
                                      data[filterOn][gridindex]['path']),
                                  child: Row(
                                    children: [
                                      Container(
                                        color: textGreen,
                                        child: const Center(
                                          child: Icon(
                                            Icons.link,
                                            color: Colors.white,
                                            size: 35,
                                          ),
                                        ),
                                      ),
                                      Text(data[filterOn][gridindex]['path'])
                                    ],
                                  )),
                            ],
                          ),
                        );
                        // }
                        // return null;
                      },
                      // itemCount: widget.docsArray.first.type == 'date' &&
                      //     widget.docsArray.first.thumbnail == '' ||
                      //     widget.docsArray.first.path == '' ? widget.docsArray.length - 1 : widget.docsArray.length,
                    ),
                  ],
                );
              },
            )),
        // child: GridView.builder(
        //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //     crossAxisCount: 4,
        //     crossAxisSpacing: 2,
        //     mainAxisSpacing: 5,
        //   ),
        //   itemBuilder: (context, index) {
        //       if (widget.docsArray[index].type == 'date') {
        //         widget.docsArray.removeAt(index);
        //         print('Enter');
        //         if (widget.docsArray[index].path.split('.').last == 'pdf') {
        //           return InkWell(
        //             // onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AudioPlayingScreen(fPath: widget.mediaArray[index].path))),
        //             child: Container(
        //                 child:Image.asset(pdfIcon)
        //             ),
        //           );
        //         } else {
        //           return InkWell(
        //             // onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AudioPlayingScreen(fPath: widget.mediaArray[index].path))),
        //             child: Container(
        //                 color: textGreen,
        //                 child:Image.asset('assets/images/text.png')
        //             ),
        //           );
        //         }
        //       }
        //       return null;
        //   },
        //   itemCount: widget.docsArray.first.type == 'date' &&
        //       widget.docsArray.first.thumbnail == '' ||
        //       widget.docsArray.first.path == '' ? widget.docsArray.length - 1 : widget.docsArray.length,
        // ),
      );
    } else {
      return const Scaffold(
        body: Center(
          child: Text('No Data'),
        ),
      );
    }
  }
}
