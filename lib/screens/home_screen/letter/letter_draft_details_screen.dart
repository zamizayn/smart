import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:smart_station/screens/home_screen/email/emailAttachmentView.dart';
import 'package:smart_station/screens/home_screen/letter/letter_api_services.dart';
import 'package:smart_station/screens/home_screen/letter/letter_draft_edit_screen.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:smart_station/utils/constants/urls.dart';

import '../../../providers/AuthProvider/auth_provider.dart';
import '../popup_screens/widget/bottomSection.dart';
import 'package:path/path.dart' as path;

import 'letter_draft_detail_view_model.dart';

class EmailLetter {
  final String sender;
  final String letter_id;
  final List receiver;
  final List bcc;
  final List cc;
  final String addressTo;
  final String subject;
  final String message;
  final String pdf;
  final String date;
  final profilePic;

  EmailLetter({
    required this.sender,
    required this.letter_id,
    required this.receiver,
    required this.bcc,
    required this.cc,
    required this.addressTo,
    required this.subject,
    required this.message,
    required this.pdf,
    required this.date,
    required this.profilePic,
  });
}

class LetterDraftDetailScreen extends StatefulWidget {
  final EmailLetter email;
  const LetterDraftDetailScreen({super.key, required this.email});

  @override
  State<LetterDraftDetailScreen> createState() =>
      _LetterDraftDetailScreenState();
}

class _LetterDraftDetailScreenState extends State<LetterDraftDetailScreen> {
  @override
  late bool tomeButtonBool = false;
  final PageController _controller = PageController(viewportFraction: 0.5);
  String url = '';
  String fileName = '';
  @override
  var auth;
  var data;
  bool undoPressed = false;
  String? starStatus;
  String? importantStatus;
  String? archievedStatus;
  @override
  void initState() {
    url = AppUrls.appBaseUrl + widget.email.pdf;
    fileName = path.basename(url);
    auth = Provider.of<AuthProvider>(context, listen: false);
    imageProvider = NetworkImage(widget.email.profilePic);
   
    // TODO: implement initState
    print(widget.email.pdf);
    super.initState();
  }

 String notifiationName = '';

  Future<void> checkPermissionAndDownloadFile(
      String url, String filename, context) async {
    filename = Uri.parse(widget.email.pdf).pathSegments.last;
    notifiationName = filename;
    print(notifiationName);
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        await downloadFile(url, filename, context);
        // Handle permission denied case
        return;
      }
    }
  }

  Future<File> downloadFile(String url, String filename, context) async {
    final response = await http.get(Uri.parse(widget.email.pdf));
    final bytes = response.bodyBytes;
    final file = File('/storage/emulated/0/Download/$filename');
    await file.writeAsBytes(bytes);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloaded file to ${file.path}'),
      ),
    );
    return file;
  }

  Future<void> showNotification(String title, String body) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 66,
        channelKey: 'downloaded_pdf',
        title: title,
        body: body,
      ),
    );
  }

  ImageProvider? imageProvider;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GetDraftLetterView>(
        future: LetterApiService().viewDraftLetterDetails(
            widget.email.letter_id, auth.accessToken, auth.userId),
        builder: ((context, snapshot) {
          // print(snapshot.data);
          if (snapshot.hasData) {
            return WillPopScope(
              onWillPop: () async {
                 Navigator.pop(context, 'Refresh');
                  return true;
              },
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: const Color(0xff999999),
                  toolbarHeight: 100,
                  elevation: 0,
                  leading: IconButton(
                      onPressed: (() {
                        Navigator.pop(context, 'Refresh');
                      }),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 30,
                      )),
                  actions: [
                    IconButton(
                        onPressed: (() {
                          if (snapshot.data!.data[0].archiveStatus == '0') {
                            LetterApiService()
                                .unarchieveDraftLetter(snapshot.data!.data[0].id,
                                    auth.accessToken, auth.userId, context)
                                .then((value) {
                              data = jsonDecode(value.body);
                              print(data);
                              // if (data['status'].toString() == 'true') {
                              //   LetterApiService()
                              //       .viewDraftLetterDetails(
                              //           widget.email.letter_id,
                              //           auth.accessToken,
                              //           auth.userId)
                              //       .then((value) {
                              //     data = value;
                              //     setState(() {
                              //       archievedStatus = data["data"][0]
                              //               ["archive_status"]
                              //           .toString();
                              //     });
                              //     print("status==========$archievedStatus");
                              //   });
                              // }
                            });
                          } else {
                            LetterApiService()
                                .archieveDraftLetter(snapshot.data!.data[0].id,
                                    auth.accessToken, auth.userId, context)
                                .then((value) {
                              data = jsonDecode(value.body);
                              print(data);
                              // if (data['status'].toString() == 'true') {
                              //   LetterApiService()
                              //       .viewDraftLetterDetails(
                              //           widget.email.letter_id,
                              //           auth.accessToken,
                              //           auth.userId)
                              //       .then((value) {
                              //     data = value;
                              //     print(data);
                              //     setState(() {
                              //       archievedStatus = data["data"][0]
                              //               ["archive_status"]
                              //           .toString();
                              //     });
                              //     print("status==========$archievedStatus");
                              //   });
                              // }
                            });
                          }
                        }),
                        icon: snapshot.data!.data[0].archiveStatus == '0'
                            ? const Icon(
                                Icons.unarchive,
                                color: Colors.white,
                                size: 30,
                              )
                            : const Icon(
                                Icons.archive,
                                color: Colors.white,
                                size: 30,
                              )),
                    IconButton(
                        onPressed: (() {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: const Duration(seconds: 5),
                            content: const Text('Deleted'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                undoPressed = true;
                              },
                            ),
                          ));
            
                          Future.delayed(const Duration(seconds: 5), () {
                            if (undoPressed == true) {
                              print('hello');
                            } else {
                              // letter.deleteLetter(widget.email.letter_id, context);
                              // print("deleted");
                              LetterApiService()
                                  .deleteDraftLetter(snapshot.data!.data[0].id,
                                      auth.accessToken, auth.userId)
                                  .then((value) {
                                print(value.body);
                                Navigator.pop(context, 'Refresh');
                              });
                            }
                          });
                        }),
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 30,
                        )),
                    // InkWell(
                    //   onTap: () {
                    //     LetterApiService().markAsUnreadLetter(widget.email.letter_id, auth.accessToken, auth.userId, context);
                    //   },
                    //   child: Image.asset(
                    //     countIcon,
                    //     color: Colors.white,
                    //     height: 35,
                    //     width: 35,
                    //   ),
                    // ),
                    PopupMenuButton<String>(
                      iconSize: 30,
                      onSelected: (value) {
                        print('Selected value: $value');
                        if (value == 'option1') {
                          if (snapshot.data!.data[0].importantStatus == '0') {
                            setState(() {
                              LetterApiService()
                                  .markImportantDraftLetter(
                                      snapshot.data!.data[0].id,
                                      auth.accessToken,
                                      auth.userId)
                                  .then((value) {
                                data = jsonDecode(value.body);
                                print(data);
                                // if (data['status'].toString() == 'true') {
                                //   LetterApiService()
                                //       .viewDraftLetterDetails(
                                //           widget.email.letter_id,
                                //           auth.accessToken,
                                //           auth.userId)
                                //       .then((value) {
                                //     data = value;
                                //     setState(() {
                                //       importantStatus = data["data"][0]
                                //               ["important_status"]
                                //           .toString();
                                //     });
                                //     print("status==========$importantStatus");
                                //   });
                                // }
                              });
                            });
                          } else {
                            setState(() {
                              LetterApiService()
                                  .markUnimportantDraftLetter(
                                      snapshot.data!.data[0].id,
                                      auth.accessToken,
                                      auth.userId)
                                  .then((value) {
                                data = jsonDecode(value.body);
                                print(data);
                                // if (data['status'].toString() == 'true') {
                                //   LetterApiService()
                                //       .viewDraftLetterDetails(
                                //           widget.email.letter_id,
                                //           auth.accessToken,
                                //           auth.userId)
                                //       .then((value) {
                                //     data = value;
                                //     setState(() {
                                //       importantStatus = data["data"][0]
                                //               ["important_status"]
                                //           .toString();
                                //     });
                                //     print("status==========$importantStatus");
                                //   });
                                // }
                              });
                            });
                          }
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return <PopupMenuEntry<String>>[
                          // PopupMenuItem<String>(
                          //   value: 'option1',
                          //   child: Text('Option 1'),
                          // ),
                          PopupMenuItem<String>(
                            value: 'option1',
                            child: snapshot.data!.data[0].importantStatus == '0'
                                ? const Text('Mark important')
                                : const Text('Mark not important'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'option2',
                            child: Text('Help & feedback'),
                          ),
                        ];
                      },
                    ),
                    // IconButton(
                    //     onPressed: (() {}),
                    //     icon: Icon(
                    //       Icons.more_vert,
                    //       color: Colors.white,
                    //       size: 30,
                    //     ))
                  ],
                ),
                body: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                   // "data",
                                    snapshot.data?.data[0].subject==''?'(no subject)'
                                      :
                                     snapshot.data!.data[0].subject,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30),
                                  ),
                                  // Chip(
                                  //   label: Text(
                                  //     "Add label",
                                  //     style: TextStyle(),
                                  //   ),
                                  //   backgroundColor: Colors.grey.shade300,
                                  // ),
                                ],
                              ),
                              IconButton(
                                  onPressed: () {
                                    if (snapshot.data!.data[0].starredMessage == '0') {
                                      setState(() {
                                        LetterApiService()
                                            .starDraftLetter(
                                                widget.email.letter_id,
                                                auth.accessToken,
                                                auth.userId)
                                            .then((value) {
                                          data = jsonDecode(value.body);
                                          print(data);
                                          // if (data['status'].toString() ==
                                          //     'true') {
                                          //   LetterApiService()
                                          //       .viewDraftLetterDetails(
                                          //           widget.email.letter_id,
                                          //           auth.accessToken,
                                          //           auth.userId)
                                          //       .then((value) {
                                          //     data = value;
                                          //     setState(() {
                                          //       starStatus = data["data"][0]
                                          //               ["starred_message"]
                                          //           .toString();
                                          //     });
                                          //     print(
                                          //         "status==========$starStatus");
                                          //   });
                                          // }
                                        });
                                      });
                                    } else {
                                      setState(() {
                                        LetterApiService()
                                            .unstarDraftLetter(
                                                widget.email.letter_id,
                                                auth.accessToken,
                                                auth.userId)
                                            .then((value) {
                                          data = jsonDecode(value.body);
                                          print(data);
                                          // if (data['status'].toString() ==
                                          //     'true') {
                                          //   LetterApiService()
                                          //       .viewDraftLetterDetails(
                                          //           widget.email.letter_id,
                                          //           auth.accessToken,
                                          //           auth.userId)
                                          //       .then((value) {
                                          //     data = value;
                                          //     setState(() {
                                          //       starStatus = data["data"][0]
                                          //               ["starred_message"]
                                          //           .toString();
                                          //     });
                                          //     print(
                                          //         "status==========$starStatus");
                                          //   });
                                          // }
                                        });
                                      });
                                    }
                                  },
                                  icon: snapshot.data!.data[0].starredMessage == '1'
                                      ? const Icon(
                                          Icons.star,
                                          color: Colors.yellow,
                                          size: 30,
                                        )
                                      : const Icon(
                                          Icons.star_border,
                                          color: Colors.black,
                                          size: 30,
                                        )),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                // backgroundImage: imageProvider,
                                radius: 30,
                                // backgroundImage: imageProvider,
                                child: Image.asset(defaultImage),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              SizedBox(
                                // color: Colors.white,
                                width: MediaQuery.of(context).size.width / 1.65,
                                height: 60,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width /
                                                  2.2,
                                          child: const Text(
                                            'Draft',
                                            // widget.email.sender,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                              fontSize: 15,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        // SizedBox(width: 10,),
                                        Text(
                                          DateFormat('MMM dd').format(
                                              DateTime.parse(snapshot.data!.data[0].datetime.toString())),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      width: 250,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'to',
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.6,
                                            child: Text(
                                              jsonDecode(snapshot.data!.data[0].toMail)
                                                .map<String>((email) => email.toString())
                                                .toList().join(','),
                                              //widget.email.receiver.join(','),
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                if (tomeButtonBool == false) {
                                                  tomeButtonBool = true;
                                                } else {
                                                  tomeButtonBool = false;
                                                }
                                              });
                                            },
                                            child: tomeButtonBool
                                                ? const Icon(
                                                    Icons.keyboard_arrow_up,
                                                    color: Colors.black,
                                                  )
                                                : const Icon(
                                                    Icons.keyboard_arrow_down,
                                                    color: Colors.black,
                                                  ),
                                          ),
                                          // InkWell(
                                          //     onTap: () {},
                                          //     child: Icon(Icons.reply_rounded)),
            
                                          // InkWell(
                                          //     onTap: () {
            
                                          //     },
                                          //     child: Icon(Icons.more_vert)),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              // SizedBox(
                              //   width: 10,
                              // ),
                              IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LetterDraftEditScreen(
                                                  to: jsonDecode(snapshot.data!.data[0].toMail)
                                                  .map<String>((email) => email.toString())
                                                  .toList(),
                                                  addressTo:snapshot.data!.data[0].addressTo,
                                                  subject: snapshot.data!.data[0].subject,
                                                  body: snapshot.data!.data[0].body,
                                                  bcc: jsonDecode(snapshot.data!.data[0].bccMail)
                                                  .map<String>((email) => email.toString())
                                                  .toList(),
                                                  cc: jsonDecode(snapshot.data!.data[0].ccMail)
                                                  .map<String>((email) => email.toString())
                                                  .toList(),
                                                  id: snapshot.data!.data[0].id,
                                                )));
                                  },
                                  icon: const Icon(Icons.edit))
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          tomeButtonBool == true
                              ? Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const SizedBox(
                                              width: 50,
                                              child: Text('From: ',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  1.4,
                                              child: Text(snapshot.data!.data[0].fromMail,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        jsonDecode(snapshot.data!.data[0].toMail)
                                                  .map<String>((email) => email.toString())
                                                  .toList().length != 0
                                            ? Row(
                                                children: [
                                                  const SizedBox(
                                                    width: 50,
                                                    child: Text('To: ',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600)),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              1.4,
                                                      child: Column(
                                                        children: [
                                                          ListView.builder(
                                                            physics:
                                                                const NeverScrollableScrollPhysics(),
                                                            itemCount: jsonDecode(snapshot.data!.data[0].toMail)
                                                  .map<String>((email) => email.toString())
                                                  .toList().length,
                                                            shrinkWrap: true,
                                                            itemBuilder:
                                                                (context, index) {
                                                              if (jsonDecode(snapshot.data!.data[0].toMail)
                                                  .map<String>((email) => email.toString())
                                                  .toList()[
                                                                      index] !=
                                                                  '') {
                                                                return Text(
                                                                  jsonDecode(snapshot.data!.data[0].toMail)
                                                  .map<String>((email) => email.toString())
                                                  .toList()[ index],
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600));
                                                              return null;
                                                              }
                                                              return null;
                                                            },
                                                          )
                                                        ],
                                                      )),
                                                ],
                                              )
                                            : const SizedBox(),
                                       jsonDecode(snapshot.data!.data[0].toMail)
                                                  .map<String>((email) => email.toString())
                                                  .toList().length != 0
                                            ? const SizedBox(
                                                height: 10,
                                              )
                                            : const SizedBox(),
                                       jsonDecode(snapshot.data!.data[0].bccMail)
                                                  .map<String>((email) => email.toString())
                                                  .toList().length != 0
                                            ? Row(
                                                children: [
                                                  const SizedBox(
                                                    width: 50,
                                                    child: Text('bcc: ',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600)),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              1.4,
                                                      child: Column(
                                                        children: [
                                                          ListView.builder(
                                                            physics:
                                                                const NeverScrollableScrollPhysics(),
                                                            itemCount: jsonDecode(snapshot.data!.data[0].bccMail)
                                                  .map<String>((email) => email.toString())
                                                  .toList().length,
                                                            shrinkWrap: true,
                                                            itemBuilder:
                                                                (context, index) {
                                                              if (jsonDecode(snapshot.data!.data[0].bccMail)
                                                  .map<String>((email) => email.toString())
                                                  .toList()[
                                                                      index] !=
                                                                  '') {
                                                                return Text(
                                                                   jsonDecode(snapshot.data!.data[0].bccMail)
                                                  .map<String>((email) => email.toString())
                                                  .toList()[
                                                                        index],
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600));
                                                              return null;
                                                              }
                                                              return null;
                                                            },
                                                          )
                                                        ],
                                                      )),
                                                ],
                                              )
                                            : const SizedBox(),
                                        jsonDecode(snapshot.data!.data[0].bccMail)
                                                  .map<String>((email) => email.toString())
                                                  .toList().length != 0
                                            ? const SizedBox(
                                                height: 10,
                                              )
                                            : const SizedBox(),
                                        jsonDecode(snapshot.data!.data[0].ccMail)
                                                  .map<String>((email) => email.toString())
                                                  .toList().length != 0
                                            ? Row(
                                                children: [
                                                  const SizedBox(
                                                    width: 50,
                                                    child: Text('cc: ',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600)),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              1.4,
                                                      child: Column(
                                                        children: [
                                                          ListView.builder(
                                                            physics:
                                                                const NeverScrollableScrollPhysics(),
                                                            itemCount: jsonDecode(snapshot.data!.data[0].ccMail)
                                                  .map<String>((email) => email.toString())
                                                  .toList().length,
                                                            shrinkWrap: true,
                                                            itemBuilder:
                                                                (context, index) {
                                                              if (jsonDecode(snapshot.data!.data[0].ccMail)
                                                  .map<String>((email) => email.toString())
                                                  .toList()[
                                                                      index] !=
                                                                  '') {
                                                                return Text(
                                                                   jsonDecode(snapshot.data!.data[0].ccMail)
                                                  .map<String>((email) => email.toString())
                                                  .toList()[
                                                                        index],
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600));
                                                              return null;
                                                              }
                                                              return null;
                                                            },
                                                          )
                                                        ],
                                                      )),
                                                ],
                                              )
                                            : const SizedBox(),
                                        jsonDecode(snapshot.data!.data[0].ccMail)
                                                  .map<String>((email) => email.toString())
                                                  .toList().length != 0
                                            ? const SizedBox(
                                                height: 10,
                                              )
                                            : const SizedBox(),
                                        Row(
                                          children: [
                                            const SizedBox(
                                              width: 50,
                                              child: Text('Date: ',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  1.4,
                                              child: Text(
                                                DateFormat('MMM dd, yyyy, h:mm a')
                                                    .format(DateTime.parse(
                                                        snapshot.data!.data[0].datetime.toString())),
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                          const SizedBox(
                            height: 15,
                          ),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EmailAttachmentView(
                                              filetype: path.extension(AppUrls.appBaseUrl+snapshot.data!.data[0].letterAttatchment),
                                              pdfUrl: AppUrls.appBaseUrl+snapshot.data!.data[0].letterAttatchment,
                                            )
                                        // LetterPdfView(pdf: widget.email.pdf)
                                        ));
                              },
                              child: Container(
                                  height: 250,
                                  width: MediaQuery.of(context).size.width / 1.2,
                                  color: Colors.grey.shade200,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          height: 50,
                                        ),
                                        const Icon(
                                          Icons.file_copy,
                                          size: 40,
                                        ),
                                        const SizedBox(
                                          height: 50,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.picture_as_pdf),
                                            const SizedBox(
                                              width: 15,
                                            ),
                                            SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3,
                                                child: Text(
                                                  path.basename(AppUrls.appBaseUrl+snapshot.data!.data[0].letterAttatchment),
                                                  overflow: TextOverflow.ellipsis,
                                                )),
                                            const SizedBox(
                                              width: 30,
                                            ),
                                            IconButton(
                                                    onPressed: (){
                                                      checkPermissionAndDownloadFile(widget.email.pdf, widget.email.pdf, context)
                                                      .then((value) {
                                                        showNotification(notifiationName, 'Download complete');
                                                      });
                                                    },
                                                    icon: const Icon(Icons.download),
                                                  )
                                          ],
                                        )
                                      ],
                                    ),
                                  )),
                            ),
                          ),
                        ]),
                  ),
                ),
                bottomNavigationBar: Container(
                  color: Colors.grey[300],
                  height: 100,
                  child: Column(
                    children: const [
                      SizedBox(
                        height: 35,
                      ),
                      Center(child: BottomSectionTransp()),
                    ],
                  ),
                ),
              ),
            );
          }
          else{
            return const Center(child: CircularProgressIndicator.adaptive());
          }
        }));
  }
}
