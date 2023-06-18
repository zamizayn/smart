import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:smart_station/screens/home_screen/letter/letter_api_services.dart';
import 'package:smart_station/screens/home_screen/letter/letter_compose_screen.dart';
import 'package:smart_station/screens/home_screen/letter/letter_detail_screen.dart';
import 'package:smart_station/providers/LetterProvider/letter_provider.dart';
import 'package:html/parser.dart';
import 'package:shimmer/shimmer.dart';
import '../../../providers/AuthProvider/auth_provider.dart';

class LetterScreen extends StatefulWidget {
  const LetterScreen({Key? key}) : super(key: key);

  @override
  State<LetterScreen> createState() => _LetterScreenState();
}

//List selectedLetter =[];
bool undoPressedInbox = false;
bool deletePressedInbox = false;
List selectedInboxLetter = [];
List selectedDateInbox = [];
List tempDeleteInbox = [];
List tempSelectedInbox = [];
List mailReadInbox = [];
List importantStatusInbox = [];
List starredStatusInbox = [];

class _LetterScreenState extends State<LetterScreen> {
  @override
  //List selectedLetter =[];
  List letterStatus = [];
  @override
  void initState() {
    // TODO: implement initState
    print('fd');
    super.initState();
  
      var letter = Provider.of<LetterProvider>(context, listen: false);
      letter.getInboxList(context);
      print(letter.inboxData.length);
      //  for(var i=0 ;i<letter.inboxData.length;i++){
      //         selectedLetter.insert(i,false);
      //  }
      //  print("selected letter------------$selectedLetter");
      print('fdd');
      letter.getEmailList(context);
      print('==============[email list]==============');
      print('result--${letter.emailData}');
      print('==============[email list]==============');
      var emailSet = <dynamic>{};
      for (var i = 0; i < letter.emailData.length; i++) {
        var data = {
          'email': letter.emailData[i]['company_mail'],
          'name': letter.emailData[i]['name'],
          'profilePic': letter.emailData[i]['profile_pic']
        };
        emailSet.add(data);
        // emailList.add(letter.emailData[i]["company_mail"]);
      }
      emailList = emailSet.toList();
      print('full list --$emailList');
    

    //  for(var i = 0 ; i < letter.emailData.length ; i++){
    //   nameList.add(letter.emailData[i]["name"]);
    // }
    // nameList = nameList.toSet().toList();
    // print(nameList);
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: false);
   // var letter = Provider.of<LetterProvider>(context, listen: false);
    return  Consumer<LetterProvider>(builder: (context, letter, child) {
      return FutureBuilder(
      future: LetterApiService().getletter_list(auth.userId, auth.accessToken, ''),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.data.letterList.isEmpty) {
            return const Center(
              child: Text('No Letter',
                  style: TextStyle(color: Colors.black, fontSize: 18)),
            );
          } else {
            return Scaffold(
              body: Center(
                child: //Text("Email devi"),
                    ListView.builder(
                        /*padding: EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 15,
          ),*/
                        itemCount: snapshot.data!.data.letterList.length,
                        itemBuilder: (context, index) {
                          // if (tempSelectedInbox.contains(snapshot
                          //         .data!.data.letterList[index].id
                          //         .toString()) &&
                          //     deletePressedInbox) {
                          //   return Container();
                          // } else {
                            if (snapshot.data!.data.letterList[index].type ==
                                'date') {
                              // int listCount = tempDeleteInbox
                              //     .where((element) =>
                              //         element ==
                              //         snapshot
                              //             .data!.data.letterList[index].datetime
                              //             .toString()
                              //             .substring(0, 10))
                              //     .length;
                              // int apiCount = 0;
                              // for (var i = 0;
                              //     i < letter.inboxData.length;
                              //     i++) {
                              //   if (snapshot
                              //       .data!.data.letterList[i].datetime
                              //       .toString()
                              //       .contains(snapshot
                              //           .data!.data.letterList[index].datetime
                              //           .toString()
                              //           .substring(0, 10))) {
                              //     apiCount++;
                              //   }
                              // }
                              //  print(index);
                              //   print("listCount-----------$listCount");
                              //   print("apicount------------$apiCount");
                              // if (
                              //     (listCount + 1) == (apiCount) &&
                              //         deletePressedInbox) {
                              //   print("true=======");
                              //   return Container();
                             // } else {
                                return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 10),
                                    child: Column(
                                      children: [
                                        // SizedBox(
                                        //   height: 15,
                                        // ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Center(
                                                child: Text(
                                              DateFormat('dd-MM-yyyy')
                                                  .format(snapshot
                                                      .data!
                                                      .data
                                                      .letterList[index]
                                                      .datetime)
                                                  .toString(),
                                            )),
                                            const SizedBox(
                                              width: 20,
                                            )
                                          ],
                                        ),
                                      ],
                                    ));
                             // }
                            } else {
                              return Padding(
                                padding: const EdgeInsets.only(left: 10,right: 10,bottom: 15),
                                child: InkWell(
                                  onTap: () {
                                    Email email = Email(
                                      sender: snapshot
                                          .data!.data.letterList[index].from,
                                      letter_id: snapshot
                                          .data!.data.letterList[index].id,
                                      receiver: snapshot
                                          .data!.data.letterList[index].to,
                                      bcc: snapshot
                                          .data!.data.letterList[index].bcc,
                                      cc: snapshot
                                          .data!.data.letterList[index].cc,
                                      status: snapshot.data!.data
                                          .letterList[index].approvalStatus,
                                      subject: snapshot
                                          .data!.data.letterList[index].subject==''?'(no subject)'
                                            : snapshot
                                          .data!.data.letterList[index].subject,
                                      message: snapshot
                                          .data!.data.letterList[index].body,
                                      date: snapshot
                                          .data!.data.letterList[index].datetime
                                          .toString(),
                                      pdf: snapshot.data!.data.letterList[index]
                                          .letterPath,
                                      profilePic: snapshot.data!.data
                                          .letterList[index].profilePic,
                                    );

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            LetterDetailScreen(email: email),
                                      ),
                                    );
                                  },
                                  onLongPress: () {
                                    print('long press $index');
                                    print(selectedInboxLetter);
                                    if (selectedInboxLetter.contains(snapshot
                                        .data!.data.letterList[index].id)) {
                                      setState(() {
                                        selectedInboxLetter.remove(snapshot
                                            .data!.data.letterList[index].id);
                                        selectedDateInbox.remove(snapshot.data!
                                            .data.letterList[index].datetime
                                            .toString()
                                            .substring(0, 10));
                                        mailReadInbox.remove(snapshot.data!.data
                                            .letterList[index].mailReadStatus
                                            .toString());
                                        starredStatusInbox.remove(snapshot
                                            .data!
                                            .data
                                            .letterList[index]
                                            .starredStatus
                                            .toString());
                                        importantStatusInbox.remove(snapshot
                                            .data!
                                            .data
                                            .letterList[index]
                                            .importantStatus
                                            .toString());
                                        print(starredStatusInbox);
                                        print(selectedInboxLetter);
                                        letter.getSelectedLetter(
                                            selectedInboxLetter);
                                            print(letter.selectedLetter);
                                      });
                                    } else {
                                      setState(() {
                                        selectedInboxLetter.add(snapshot
                                            .data!.data.letterList[index].id);
                                        selectedDateInbox.add(snapshot.data!
                                            .data.letterList[index].datetime
                                            .toString()
                                            .substring(0, 10));
                                        mailReadInbox.add(snapshot.data!.data
                                            .letterList[index].mailReadStatus
                                            .toString());
                                        starredStatusInbox.add(snapshot
                                            .data!
                                            .data
                                            .letterList[index]
                                            .starredStatus
                                            .toString());
                                        importantStatusInbox.add(snapshot
                                            .data!
                                            .data
                                            .letterList[index]
                                            .importantStatus
                                            .toString());
                                        print(selectedInboxLetter);
                                        print(starredStatusInbox);
                                        letter.getSelectedLetter(
                                            selectedInboxLetter);
                                            print(letter.selectedLetter);
                                      });
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: letter.selectedLetter.contains(
                                                snapshot.data!.data
                                                    .letterList[index].id)
                                            ? Colors.grey.shade400
                                            : Colors.transparent),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Card(
                                            color: Colors.grey[300],
                                            child: CircleAvatar(
                                                maxRadius: 28,
                                                backgroundImage: NetworkImage(
                                                    snapshot
                                                        .data!
                                                        .data
                                                        .letterList[index]
                                                        .profilePic)
                                                /*isValidLink(url) == false ? NetworkImage(user.data[index]['profile_pic'])
                                                                        : NetworkImage("https://cdn.pixabay.com/photo/2019/08/11/18/59/icon-4399701_1280.png")*/
                                                ),
                                          ),
                                          //SizedBox(width: 5),
                                          Container(
                                            decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(
                                                            15))),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.4,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.only(
                                                      left: 10.0,
                                                      right: 10.0,
                                                      top: 10.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                1.75 -
                                                            30,
                                                        child: Text(
                                                          snapshot
                                                              .data!
                                                              .data
                                                              .letterList[
                                                                  index]
                                                              .from,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                      // SizedBox(
                                                      //   width: 20,
                                                      // ),
                                                      Text(
                                                        DateFormat(
                                                                'hh:mm a')
                                                            .format(snapshot
                                                                .data!
                                                                .data
                                                                .letterList[
                                                                    index]
                                                                .datetime),
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(snapshot
                                          .data!.data.letterList[index].subject==''?'(no subject)'
                                                  :  snapshot
                                                        .data!
                                                        .data
                                                        .letterList[index]
                                                        .subject,
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        //fontWeight:letter.inboxData[index]['mail_read_status'].toString()=="0" ? FontWeight.bold:FontWeight.normal,
                                                        color: snapshot
                                                                    .data!
                                                                    .data
                                                                    .letterList[
                                                                        index]
                                                                    .mailReadStatus.toString() ==
                                                                '0'
                                                            ? Colors.grey
                                                            : Colors.black
                                                        // fontWeight: FontWeight.bold,
                                                        ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      SizedBox(
                                                        height: 45,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            1.9,
                                                        child: Text(
                                                          
                                                          parse(snapshot
                                                                  .data!
                                                                  .data
                                                                  .letterList[
                                                                      index]
                                                                  .body)
                                                              .documentElement!
                                                              .text,
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                            color: snapshot
                                                                        .data!
                                                                        .data
                                                                        .letterList[
                                                                            index]
                                                                        .mailReadStatus.toString() ==
                                                                    '0'
                                                                ? Colors
                                                                    .grey
                                                                : Colors
                                                                    .black,
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400,
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                          onTap: () {
                                                            var auth = Provider.of<
                                                                    AuthProvider>(
                                                                context,
                                                                listen:
                                                                    false);
                                                            if (snapshot
                                                                    .data!
                                                                    .data
                                                                    .letterList[
                                                                        index]
                                                                    .starredStatus ==
                                                                0) {
                                                              setState(() {
                                                                LetterApiService()
                                                                    .starLetter(
                                                                        snapshot.data!.data.letterList[index].id,
                                                                        auth.accessToken,
                                                                        auth.userId)
                                                                    .then((value) {
                                                                  var data =
                                                                      jsonDecode(
                                                                          value.body);
                                                                  if (data[
                                                                          'message'] ==
                                                                      'success') {
                                                                    setState(
                                                                        () {
                                                                      letter
                                                                          .getInboxList(context);
                                                                    });
                                                                  }
                                                                });
                                                              });
                                                            } else {
                                                              setState(() {
                                                                LetterApiService()
                                                                    .unstarLetter(
                                                                        snapshot.data!.data.letterList[index].id,
                                                                        auth.accessToken,
                                                                        auth.userId)
                                                                    .then((value) {
                                                                  var data =
                                                                      jsonDecode(
                                                                          value.body);
                                                                  if (data[
                                                                          'message'] ==
                                                                      'success') {
                                                                    setState(
                                                                        () {
                                                                      letter
                                                                          .getInboxList(context);
                                                                    });
                                                                  }
                                                                });
                                                              });
                                                            }
                                                          },
                                                          child: Icon(
                                                            Icons.star,
                                                            color: snapshot
                                                                        .data!
                                                                        .data
                                                                        .letterList[
                                                                            index]
                                                                        .starredStatus ==
                                                                    1
                                                                ? Colors
                                                                    .yellow
                                                                : Colors
                                                                    .white,
                                                          )),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                         // }
                        }),
              ),
            );
          }
        } else {
          return ListView.builder(
            itemCount: 8,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Shimmer.fromColors(
                      direction: ShimmerDirection.ttb,
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: const CircleAvatar(
                        maxRadius: 35,
                      ),
                    ),
                    Shimmer.fromColors(
                      direction: ShimmerDirection.ltr,
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                          height: 80,
                          width: 250,
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(30),
                          )),
                    )
                  ],
                ),
              );
            },
          );
        }
      },
    );});
  }
}