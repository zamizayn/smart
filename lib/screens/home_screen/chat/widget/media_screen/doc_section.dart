import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../providers/UserProvider/user_provider.dart';
import '../../../../../utils/constants/app_constants.dart';
import '../../models/individualChat/individualMediaModel.dart';
import 'package:path/path.dart' as path;

class DocSection extends StatefulWidget {
  String docsList;

  DocSection({Key? key, required this.docsList}) : super(key: key);

  @override
  State<DocSection> createState() => _DocSectionState();
}

class _DocSectionState extends State<DocSection> {
  dynamic fullData;
  var docData;
  var filterDoc;
  var finalDoc;
  void loadURL(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  void initState() {
     
    // searchPro1.clearSearch();
    fullData = jsonDecode(widget.docsList);
    filterDoc = fullData['data']['docs'];
    docData = fullData['data']['docs'];
    // finalDoc = fullData['data']['docs'];
  }

  @override
  Widget build(BuildContext context) {
    var searchPro = Provider.of<UserProvider>(context, listen: true);
    // searchPro.clearData();
    var singleArray;
    if (searchPro.searchMediaValue.isNotEmpty) {
      // print(searchPro.searchMediaValue);

      for (var i = 0; i < docData['list'].length; i++) {
        String singleData = docData['list'][i];

        singleArray = docData['list_datas'][i][singleData];

        // print(singleData);
        // print(singleArray);
        var list = [];

        docData['list_datas'][i][singleData] = filterDoc['list_datas'][i]
                [singleData]
            .where((element) => (path.basename(element['path']).toUpperCase())
                .contains(searchPro.searchMediaValue.toUpperCase()))
            .toList();

        // print(docData['list_datas'][i][singleData]);
      }
    } else {
      print("isempty");
      setState(() {
        finalDoc = jsonDecode(widget.docsList);
        docData = finalDoc['data']['docs'];
      });
      print(docData);
    }
    if (docData['list'].length > 0) {
      return Scaffold(
        body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage(splashBg),
              fit: BoxFit.contain,
            )),
            child: ListView.builder(
              itemCount: docData['list'].length,
              itemBuilder: (context, index) {
                String filterOn = docData['list'][index];
                var data = docData['list_datas'][index];

                return Column(
                  children: [
                    ListTile(
                      title: Text(docData['list'][index]),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      // gridDelegate:
                      //     const SliverGridDelegateWithFixedCrossAxisCount(
                      //   crossAxisCount: 3,
                      //   crossAxisSpacing: 2,
                      //   mainAxisSpacing: 5,
                      // ),
                      itemCount: data[filterOn].length,
                      itemBuilder: (context, gridindex) {
                        // if (widget.docsArray[index].type == 'date') {
                        //   widget.docsArray.removeAt(index);
                        //   print('Enter');
                        if (data[filterOn][gridindex]['path'].split('.').last ==
                            'pdf') {
                          return InkWell(
                            onTap: () =>
                                loadURL(data[filterOn][gridindex]['path']),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Image.asset(
                                    pdfIcon,
                                    width:
                                        MediaQuery.of(context).size.width / 7,
                                  ),
                                  Text(
                                    path.basename(
                                        data[filterOn][gridindex]['path']),
                                  )
                                ],
                              ),
                            ),
                          );
                        } else if (data[filterOn][gridindex]['path']
                                    .split('.')
                                    .last ==
                                'doc' ||
                            data[filterOn][gridindex]['path'].split('.').last ==
                                'docx') {
                          return InkWell(
                            onTap: () =>
                                loadURL(data[filterOn][gridindex]['path']),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Container(
                                      color: textGreen,
                                      child: Image.asset(
                                        wordIcon,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                7,
                                      )),
                                  Text(
                                    path.basename(
                                        data[filterOn][gridindex]['path']),
                                  )
                                ],
                              ),
                            ),
                          );
                        } else if (data[filterOn][gridindex]['path']
                                .split('.')
                                .last ==
                            'ppt') {
                          return InkWell(
                            onTap: () =>
                                loadURL(data[filterOn][gridindex]['path']),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Container(
                                      color: textGreen,
                                      child: Image.asset(
                                        pptIcon,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                7,
                                      )),
                                  Text(
                                    path.basename(
                                        data[filterOn][gridindex]['path']),
                                  )
                                ],
                              ),
                            ),
                          );
                        } else if (data[filterOn][gridindex]['path']
                                .split('.')
                                .last ==
                            'xlsx') {
                          return InkWell(
                            onTap: () =>
                                loadURL(data[filterOn][gridindex]['path']),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Container(
                                      color: textGreen,
                                      child: Image.asset(
                                        excelIcon,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                7,
                                      )),
                                  Text(
                                    path.basename(
                                        data[filterOn][gridindex]['path']),
                                  )
                                ],
                              ),
                            ),
                          );
                        } else if (data[filterOn][gridindex]['path']
                                .split('.')
                                .last ==
                            'json') {
                          return InkWell(
                            onTap: () =>
                                loadURL(data[filterOn][gridindex]['path']),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Container(
                                      color: textGreen,
                                      child: Image.asset(
                                        json,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                7,
                                      )),
                                  Text(
                                    path.basename(
                                        data[filterOn][gridindex]['path']),
                                  )
                                ],
                              ),
                            ),
                          );
                        } else {
                          return InkWell(
                            onTap: () =>
                                loadURL(data[filterOn][gridindex]['path']),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Container(
                                      color: textGreen,
                                      child: Image.asset(
                                        text,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                7,
                                      )),
                                  Text(
                                    path.basename(
                                        data[filterOn][gridindex]['path']),
                                  )
                                ],
                              ),
                            ),
                          );
                        }
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
