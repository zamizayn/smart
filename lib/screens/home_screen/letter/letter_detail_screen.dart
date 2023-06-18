import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/screens/home_screen/email/emailAttachmentView.dart';
import 'package:smart_station/screens/home_screen/letter/letter_api_services.dart';
import 'package:smart_station/screens/home_screen/letter/letter_forward.dart';
import 'package:smart_station/utils/constants/app_constants.dart';

import '../../../providers/AuthProvider/auth_provider.dart';
import '../../../providers/LetterProvider/letter_provider.dart';
import '../popup_screens/widget/bottomSection.dart';
import 'package:path/path.dart' as path;


class Email {
  final String sender;
  final String letter_id;
  final List receiver;
  final List bcc;
  final List cc;
  final String status;
  final String subject;
  final String message;
  final String pdf;
  final String date;
  final  profilePic;

  Email({
    required this.sender,
    required this.letter_id,
    required this.receiver,
    required this.bcc,
    required this.cc,
    required this.status,
    required this.subject,
    required this.message,
    required this.pdf,
    required this.date,
    required this.profilePic,
  });
}
class LetterDetailScreen extends StatefulWidget {
  final Email email;
  const LetterDetailScreen({super.key, required this.email});

  @override
  State<LetterDetailScreen> createState() => _LetterDetailScreenState();
}

class _LetterDetailScreenState extends State<LetterDetailScreen> {
  final String pdfPath = 'https://creativeapplab.in/smartstation/api/uploads/letter/LETTER_20230223_130217.pdf';
  @override
  late bool tomeButtonBool = false;
 // final PageController _controller = PageController(viewportFraction: 0.5);
  String url =  '';
  String fileName = ''; 
  @override
  var auth;
  var data;
  bool undoPressed=false;
  String? starStatus;
  String? importantStatus;
  String? archievedStatus;
  @override
  void initState() {
    url = widget.email.pdf;
    fileName = path.basename(url); 
     auth = Provider.of<AuthProvider>(context, listen: false);
    imageProvider = NetworkImage(widget.email.profilePic);
    LetterApiService().viewLetterDetails(widget.email.letter_id,auth.accessToken, auth.userId).then((value) 
     {
        data = jsonDecode(value.body);
        var letter = Provider.of<LetterProvider>(context,listen: false);
        letter.getInboxList(context);
        setState(() {
           starStatus=data['data']['starred_status'].toString();
         importantStatus=data['data']['important_status'].toString();
         archievedStatus=data['data']['archive_status'].toString();
        });
        
        print('status==========$starStatus');
     }
     );    //to know the count of unread message
      
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
    // if (!status.isGranted) {
    //   status = await Permission.storage.request();
    //   if (!status.isGranted) {
    //     await downloadFile(url, filename, context);
    //     // Handle permission denied case
    //     return;
    //   }
    // }
    if (!status.isGranted) {
      status = await Permission.storage.request();
      print(status.isGranted);
      // if (status.isGranted) {
      //   await downloadFile(url, filename, context);
      //   showNotification(notifiationName, 'Download complete');
      //   // Handle permission denied case
      //   return;
      // }
    }
    if (status.isGranted) {
      print("granted");
       await downloadFile(url, filename, context);
       showNotification(notifiationName, 'Download complete');
        // Handle permission denied case
        return;
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
  ImageProvider? imageProvider ;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()  async {
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
                        if(archievedStatus=='1'){
                        LetterApiService().archieveLetter(widget.email.letter_id,auth.accessToken,auth.userId, context);
                        }
                        else{
                        LetterApiService().unarchieveLetter(widget.email.letter_id,auth.accessToken,auth.userId, context);
                        }
                      }),
                      icon: archievedStatus=='0'? const Icon(
                        Icons.unarchive,
                        color: Colors.white,
                        size: 30,
                      )
                      :const Icon(
                        Icons.archive,
                        color: Colors.white,
                        size: 30,
                      )
                      ),
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
                              LetterApiService().deleteLetter(widget.email.letter_id, auth.accessToken,auth.userId).then((value) {
                                print(value.body);
                                Navigator.pop(context,'Refresh');
                              } );
                              
                              
                          }
                        });
                      }),
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 30,
                      )),
                  InkWell(
                    onTap: () {
                      LetterApiService().markAsUnreadLetter(widget.email.letter_id, auth.accessToken, auth.userId, context);
                    },
                    child: Image.asset(
                      countIcon,
                      color: Colors.white,
                      height: 35,
                      width: 35,
                    ),
                  ),
                   PopupMenuButton<String>(
                    iconSize: 30,
                onSelected: (value) {
                  print('Selected value: $value');
                  if(value=='option1'){
                    if(importantStatus=='0'){
                        setState(() {
                        LetterApiService().markImportantLetter(widget.email.letter_id, auth.accessToken, auth.userId).then((value) {
                          data = jsonDecode(value.body);
                          if(data['message']=='success'){
                              LetterApiService().viewLetterDetails(widget.email.letter_id,auth.accessToken, auth.userId).then((value) 
                               {
                                  data = jsonDecode(value.body);
                                     setState(() {
                                        importantStatus=data['data']['important_status'].toString();
                                         });
                                      print('status==========$importantStatus');
                               }
                               );  
                            }
                          });
                        });
                                
                          }
                          else{
                              setState(() {
                                 LetterApiService().markUnimportantLetter(widget.email.letter_id, auth.accessToken, auth.userId).then((value)  {
                                 data = jsonDecode(value.body);
                            if(data['message']=='success'){
                             LetterApiService().viewLetterDetails(widget.email.letter_id,auth.accessToken, auth.userId).then((value) 
                             {
                                  data = jsonDecode(value.body);
                                 setState(() {
                                   importantStatus=data['data']['important_status'].toString();
                                  });
                                print('status==========$importantStatus');
                             }
                            );  
                          }
                        });
                      });
                                 
                    }
                  }
                },
                itemBuilder: (BuildContext context) {
                  return <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'option1',
                      child:importantStatus=='0'? const Text('Mark important'):const Text('Mark not important'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'option2',
                      child: Text('Help & feedback'),
                    ),
                  ];
                },
              ),
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
                            SizedBox(
                              width: MediaQuery.of(context).size.width/1.3,
                              child: Wrap(
                                children: [
                                  Text(
                                    widget.email.subject,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30),
                                  ),
                                  Chip(
                                    label: const Text(
                                      'Inbox',
                                      style: TextStyle(),
                                    ),
                                    backgroundColor: Colors.grey.shade300,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if(starStatus=='0'){
                                  setState(() {
                                    LetterApiService().starLetter(widget.email.letter_id, auth.accessToken, auth.userId).then((value) {
                                       data = jsonDecode(value.body);
                                      if(data['message']=='success'){
                                         LetterApiService().viewLetterDetails(widget.email.letter_id,auth.accessToken, auth.userId).then((value) 
                                         {
                                            data = jsonDecode(value.body);
                                             setState(() {
                                               starStatus=data['data']['starred_status'].toString();
                                             });
                                            print('status==========$starStatus');
                                           }
                                         );  
                                      }
                                    });
                                  });
                                
                                }
                                else{
                                  setState(() {
                                     LetterApiService().unstarLetter(widget.email.letter_id, auth.accessToken, auth.userId).then((value)  {
                                       data = jsonDecode(value.body);
                                      if(data['message']=='success'){
                                         LetterApiService().viewLetterDetails(widget.email.letter_id,auth.accessToken, auth.userId).then((value) 
                                         {
                                            data = jsonDecode(value.body);
                                             setState(() {
                                               starStatus=data['data']['starred_status'].toString();
                                             });
                                            print('status==========$starStatus');
                                           }
                                         );  
                                      }
                                     });
                                  });
                                 
                                }
                              },
                              icon: starStatus=='1'?
                              const Icon(
                                 Icons.star,
                                color: Colors.yellow,
                                size: 30,
                              )
                              :const Icon(
                                 Icons.star_border,
                                color: Colors.black,
                                size: 30,
                              )
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundImage: imageProvider,
                              radius: 30,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                            // color: Colors.white,
                               width: MediaQuery.of(context).size.width/1.65,
                              height: 60,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                       width: MediaQuery.of(context).size.width/2.5,
                                        child: Text(
                                          widget.email.sender,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 15,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                     // SizedBox(width: 10,),
                                      Text(
                                        DateFormat('MMM dd').format(
                                          DateTime.parse(widget.email.date)),
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
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'to me ',
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
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
                                          child:tomeButtonBool?const Icon(
                                            Icons.keyboard_arrow_up,
                                            color: Colors.black,
                                          ) 
                                          : const Icon(
                                            Icons.keyboard_arrow_down,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                           // SizedBox(width: 10,),
                   PopupMenuButton<String>(
                    iconSize: 30,
                onSelected: (value) {
                  print('Selected value: $value');
                   switch (value) {
                  case 'option1':
                     Navigator.push(context, MaterialPageRoute(builder: (context)=>
                          LetterForwardScreen(pdf: widget.email.pdf,letter_id: widget.email.letter_id,)));
                    break;
                  case 'option2':
                          if(starStatus=='0'){
                                  setState(() {
                                    LetterApiService().starLetter(widget.email.letter_id, auth.accessToken, auth.userId).then((value) {
                                       data = jsonDecode(value.body);
                                      if(data['message']=='success'){
                                         LetterApiService().viewLetterDetails(widget.email.letter_id,auth.accessToken, auth.userId).then((value) 
                                         {
                                            data = jsonDecode(value.body);
                                             setState(() {
                                               starStatus=data['data']['starred_status'].toString();
                                             });
                                            print('status==========$starStatus');
                                           }
                                         );  
                                      }
                                    });
                                  });
                                
                                }
                                else{
                                  setState(() {
                                     LetterApiService().unstarLetter(widget.email.letter_id, auth.accessToken, auth.userId).then((value)  {
                                       data = jsonDecode(value.body);
                                      if(data['message']=='success'){
                                         LetterApiService().viewLetterDetails(widget.email.letter_id,auth.accessToken, auth.userId).then((value) 
                                         {
                                            data = jsonDecode(value.body);
                                             setState(() {
                                               starStatus=data['data']['starred_status'].toString();
                                             });
                                            print('status==========$starStatus');
                                           }
                                         );  
                                      }
                                     });
                                  });
                                 
                                }
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => Screen2()),
                    // );
                    break;
                  case 'option3':
                      LetterApiService().markAsUnreadLetter(widget.email.letter_id, auth.accessToken, auth.userId, context);
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => Screen3()),
                    // );
                    break;
                }
                },
                itemBuilder: (BuildContext context) {
                  return <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'option1',
                      child: Text('Forward'),
                    ),
                    PopupMenuItem<String>(
                      value: 'option2',
                      child: starStatus=='0'?const Text('Add star'):const Text('Remove star'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'option3',
                      child: Text('Mark unread from here'),
                    ),
                  ];
                },
              ),                         
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const SizedBox(
                                            width: 50,
                                            child: Text('From: ',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600)),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width/1.4,
                                            child: Text( widget.email.sender,
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          const SizedBox(
                                            width: 50,
                                            child: Text('To: ',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600)),
                                          ),
                                           SizedBox(
                                            width: MediaQuery.of(context).size.width/1.4,
                                            child: Column(
                                              children: [
                                                ListView.builder(
                                                  physics: const NeverScrollableScrollPhysics(),
                                                  itemCount: widget.email.receiver.length,
                                                   shrinkWrap: true,
                                                  itemBuilder: (context,index){
                                                    if(widget.email.receiver[index]!='') {
                                                      return Text(widget.email.receiver[index],
                                                          style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600));
                                                    return null;
                                                    }
                                                    return null;
                                                      },
                                                    )
                                              ],
                                            )
                                           
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                    widget.email.bcc.isNotEmpty?  Row(
                                        children: [
                                          const SizedBox(
                                            width: 50,
                                            child: Text('bcc: ',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700)),
                                          ),
                                           SizedBox(
                                            width: MediaQuery.of(context).size.width/1.4,
                                            child: Column(
                                              children: [
                                                ListView.builder(
                                                  physics: const NeverScrollableScrollPhysics(),
                                                  itemCount: widget.email.bcc.length,
                                                   shrinkWrap: true,
                                                  itemBuilder: (context,index){
                                                    if(widget.email.bcc[index]!='') {
                                                      return Text(widget.email.bcc[index],
                                                          style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700));
                                                    return null;
                                                    }
                                                    return null;
                                                      },
                                                    )
                                              ],
                                            )
                                           
                                          ),
                                        ],
                                      )
                                      :const SizedBox(),
                                      widget.email.bcc.isNotEmpty?const SizedBox(
                                        height: 10,
                                      )
                                      :const SizedBox(),
                                      widget.email.cc.isNotEmpty?  Row(
                                        children: [
                                          const SizedBox(
                                            width: 50,
                                            child: Text('cc: ',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700)),
                                          ),
                                           SizedBox(
                                            width: MediaQuery.of(context).size.width/1.4,
                                            child: Column(
                                              children: [
                                                ListView.builder(
                                                  physics: const NeverScrollableScrollPhysics(),
                                                  itemCount: widget.email.cc.length,
                                                   shrinkWrap: true,
                                                  itemBuilder: (context,index){
                                                    if(widget.email.cc[index]!='') {
                                                      return Text(widget.email.cc[index],
                                                          style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700));
                                                    return null;
                                                    }
                                                    return null;
                                                      },
                                                    )
                                              ],
                                            )
                                           
                                          ),
                                        ],
                                      )
                                      :const SizedBox(),
                                      widget.email.cc.isNotEmpty?const SizedBox(
                                        height: 10,
                                      )
                                      :const SizedBox(),
                                      Row(
                                        children: [
                                          const SizedBox(
                                            width: 50,
                                            child: Text('Date: ',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600)),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width/1.4,
                                            child:Text(DateFormat('MMM dd, yyyy, h:mm a')
                                                    .format(DateTime.parse(widget.email.date)),
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
                            
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>
                              EmailAttachmentView(
                                                      filetype: path.extension(
                                                          widget.email.pdf),
                                                      pdfUrl: widget.email.pdf,
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                          width: MediaQuery.of(context).size.width/3,
                                          child: 
                                          Text(
                                            fileName,
                                            overflow: TextOverflow.ellipsis,)),
                                        const SizedBox(
                                          width: 30,
                                        ),
                                        IconButton(
                                          onPressed:(){
                                             checkPermissionAndDownloadFile(widget.email.pdf, widget.email.pdf, context)
                                          .then((value) {
                                              //showNotification(notifiationName, 'Download complete');
                                          });
                                          },
                                         icon: const Icon(Icons.download),)
                                        
                                      ],
                                    )
                                  ],
                                ),
                              )),
                          ),
                        ),
                        const SizedBox(height: 70),
                        Column(
                          children: [
                           
                           widget.email.status=='1'? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                               SizedBox(
                                  height: 60,
                                  //width: 110,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      elevation: 0,
                                      side: BorderSide(
                                          width: 1, color: Colors.grey.shade400),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25)),
                                    ),
                                    onPressed: () {
                                      LetterApiService().approveLetter(widget.email.letter_id, auth.accessToken, auth.userId).then((value) {
                                       print(value.body); 
                                       var letter = Provider.of<LetterProvider>(context,listen: false);
                                      letter.getInboxList(context);
                                      Navigator.pop(context);
                                      }
                                      );
                                    },
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.check_box_outlined,
                                          color: Colors.green,
                                        ),
                                        Text(
                                          'Approve',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // SizedBox(
                                //   width: 25,
                                // ),
                              SizedBox(
                                  height: 60,
                                  //width: 110,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      elevation: 0,
                                      side: BorderSide(
                                          width: 1, color: Colors.grey.shade400),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25)),
                                    ),
                                    onPressed: () {
                                      LetterApiService().rejectLetter(widget.email.letter_id,auth.accessToken, auth.userId).then((value) {
                                        print(value.body);
                                       var letter = Provider.of<LetterProvider>(context,listen: false);
                                        letter.getInboxList(context); 
                                        Navigator.pop(context);
                                      } 
                                      );
                                    },
                                    child: Row(
                                      children: const [
                                        Text(
                                          'Reject',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Icon(
                                          Icons.cancel_presentation_sharp,
                                          color: Colors.red,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 60,
                                  //width: 110,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      elevation: 0,
                                      side: BorderSide(
                                          width: 1, color: Colors.grey.shade400),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25)),
                                    ),
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                      LetterForwardScreen(pdf: widget.email.pdf,letter_id: widget.email.letter_id,)));
                                    },
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.forward,
                                          color: Colors.black,
                                        ),
                                        Text(
                                          'Forward',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            )
                            :Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 60,
                                 // width: 110,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      elevation: 0,
                                      side: BorderSide(
                                          width: 1, color: Colors.grey.shade400),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25)),
                                    ),
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                      LetterForwardScreen(pdf: widget.email.pdf,letter_id: widget.email.letter_id,)));
                                    },
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.forward,
                                          color: Colors.black,
                                        ),
                                        Text(
                                          'Forward',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        )
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
}
