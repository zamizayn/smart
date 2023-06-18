import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:smart_station/screens/home_screen/letter/letter_compose_screen.dart';
import 'package:smart_station/screens/home_screen/letter/letter_sent_details_view.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:smart_station/providers/LetterProvider/letter_provider.dart';
import 'package:html/parser.dart';

import '../../../providers/AuthProvider/auth_provider.dart';
import 'letter_api_services.dart';

class LetterSentScreen extends StatefulWidget {
  const LetterSentScreen({Key? key}) : super(key: key);

  @override
  State<LetterSentScreen> createState() => _LetterSentScreenState();
}

class _LetterSentScreenState extends State<LetterSentScreen> {
  @override
  bool undoPressed=false;
  bool deletePressed=false;
  List selectedSentLetter=[];
  List selectedDate=[];
   List tempDelete =[];
   List tempSelected = [];
   List importantStatus =[];
  List starredStatus =[];
  @override
  void initState() {
    // TODO: implement initState
    print('fd');
    super.initState();

    var letter = Provider.of<LetterProvider>(context,listen: false);
    letter.getSendList(context);
    print(letter.sendData.length);
    print('fdd');
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<LetterProvider>(builder: (context, letter, child) {
      return Scaffold(
        appBar:selectedSentLetter.isNotEmpty?AppBar(
              backgroundColor: Colors.grey[500],
               leading: IconButton(
                  onPressed: (() {
                    // letter.selectedSentLetter.clear();
                    // for(var i = 0;i<letter.sendData.length;i++){
                    //     letter.selectedSentLetter.insert(i,false);
                    //    // print(selectedLetter);
                    // }
                    // print(letter.selectedSentLetter);
                    selectedSentLetter.clear();
                    selectedDate.clear();
                     tempDelete.clear();
                     tempSelected.clear();
                     importantStatus.clear();
                    starredStatus.clear();
                    setState(() {
                      
                    });
                     // letter.getSelectedSentLetter(letter.selectedSentLetter);
                    //Navigator.pop(context, "Refresh");
                  }),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                  )),
                  title: Text('${selectedSentLetter.length} selected'),
              actions: [
                // IconButton(
                //   onPressed: (){}, 
                // icon: Icon(
                //       Icons.archive,
                //       color: Colors.white,
                //       size: 30,
                //     )),
                     IconButton(
                  onPressed: (){
                     deletePressed= true;
                    setState(() {
                      print('assign to temp');
                    
                        tempDelete= List.from(selectedDate);
                        selectedDate.clear();
                        tempSelected = List.from(selectedSentLetter);
                        selectedSentLetter.clear();
                        importantStatus.clear();
                        starredStatus.clear();
                    });
                    
                    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    //     duration: Duration(seconds: 5),
                    //     content: Text("Deleted"),
                    //     action: SnackBarAction(
                    //       label: "Undo",
                    //       onPressed: () {
                    //        // deletePressed=false;
                    //        selectedSentLetter.clear();
                    //        selectedDate.clear();
                    //        tempDelete.clear();
                    //         setState(() {
                    //          // tempDelete.clear();
                    //           deletePressed=false;
                    //         undoPressed = true;
                    //         });
                    //       },
                    //     ),
                    //   ));

                      // Future.delayed(Duration(seconds: 3), () {
                      //   if (undoPressed == true) {
                      //     setState(() {
                      //      // tempDelete.clear();
                      //      deletePressed=false;
                      //       // selectedImportantLetter.clear();
                      //       // selectedDate.clear();
                      //       tempDelete.clear();
                      //       tempSelected.clear();
                      //     });
                        
                      //     print("hello");
                      //   } else {
                          
                          LetterProvider().multipleDeleteLetter(context, tempSelected).then((value) {
                            var data = jsonDecode(value.body);
                            print(data);
                            setState(() {
                              
                            });
                          });
                          setState(() {
                           deletePressed=false;
                            tempDelete.clear();
                            tempSelected.clear();
                          print('unpressed false');
                          });
                      //   }
                      // });
                  }, 
                icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 30,
                    )),
                //     InkWell(
                //   onTap: () {
                    
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
                switch(value){
                  case 'option1':
                      if(importantStatus.contains('0')){
                        tempSelected = List.from(selectedSentLetter);
                        selectedSentLetter.clear();
                       // starredStatus.clear();
                        importantStatus.clear();
                        selectedDate.clear();
                        starredStatus.clear();
                        setState(() {
                          
                        });
                          LetterProvider().multipleImportantLetter(context, tempSelected).then((value) {
                            var data = jsonDecode(value.body);
                            print(data);
                            setState(() {
                            tempSelected.clear();
                            setState(() {
                              
                            });
                            });
                          });
                    }
                    else{
                        tempSelected = List.from(selectedSentLetter);
                        selectedSentLetter.clear();
                        //starredStatus.clear();
                        importantStatus.clear();
                        selectedDate.clear();
                        starredStatus.clear();
                        importantStatus.clear();
                        setState(() {
                          
                        });
                          LetterProvider().multipleUnimportantLetter(context, tempSelected).then((value) {
                            var data = jsonDecode(value.body);
                            print(data);
                            setState(() {
                            tempSelected.clear();
                            setState(() {
                              
                            });
                            });
                          });
                    }
                              break;
                  case 'option2':
                           if(starredStatus.contains('0')){
                        tempSelected = List.from(selectedSentLetter);
                        selectedSentLetter.clear();
                       // starredStatus.clear();
                        importantStatus.clear();
                        starredStatus.clear();
                        selectedDate.clear();
                        starredStatus.clear();
                        setState(() {
                          
                        });
                          LetterProvider().multipleStarLetter(context, tempSelected).then((value) {
                            var data = jsonDecode(value.body);
                            print(data);
                             setState(() {

                            });
                            
                          });
                          setState(() {
                            tempSelected.clear();
                            });
                    }
                    else{
                        tempSelected = List.from(selectedSentLetter);
                        selectedSentLetter.clear();
                        //starredStatus.clear();
                        importantStatus.clear();
                        starredStatus.clear();
                        selectedDate.clear();
                        starredStatus.clear();
                        setState(() {
                          
                        });
                          LetterProvider().multipleUnstarLetter(context, tempSelected).then((value) {
                            var data = jsonDecode(value.body);
                            print(data);
                            setState(() {
                              
                            });
                            
                          });
                          setState(() {
                            tempSelected.clear();
                            });
                    }
                              break;
                  case 'option3':
                              break;
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
                    child:Text(importantStatus.contains('0')?'Mark important':'Mark unimportant'),
                  ),
                  PopupMenuItem<String>(
                    value: 'option2',
                    child: Text(starredStatus.contains('0')?'Add star':'Remove star'),
                  ),
                   const PopupMenuItem<String>(
                    value: 'option3',
                    child: Text('Help & feedback'),
                  ),
                ];
              },
            ),
              ],
            ): PreferredSize(
    preferredSize: const Size.fromHeight(90.0), // Set the height of the app bar
    child: Container(
      // decoration: BoxDecoration(
      //       image: DecorationImage(
      //         image: AssetImage(splashBg),
      //         fit: BoxFit.fill,
      //       ),
      // ),
        color: Colors.black38,
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0),
            child: Row(
              children: const [
                BackButton(color: Colors.white),
                  Text(
                  'Letter Sent',
                  style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                    ),
                  )
                  ],
                ),
              ),
            ),
          ),
        body: FutureBuilder(
          future: LetterProvider().getSendList(context),
          builder: (context, snapshot) {
            if(snapshot.hasData){
               if(snapshot.data!.data.letterSentList.isEmpty){
                    return const Center(
                      child: Text('No Sent letter',style: TextStyle(fontSize: 16)),
                    );
                  }
                  else{
            return  Padding(
          padding: const EdgeInsets.only(top:10.0),
          child: ListView.builder(
            /*padding: EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 15,
          ),*/
            itemCount: snapshot.data!.data.letterSentList.length,
            itemBuilder: (context, index) {
              final document = parse(snapshot.data!.data.letterSentList[index].body);
              //final String parsedString = parse(document.body?.text).documentElement.text;
              Uri url = Uri.parse(snapshot.data!.data.letterSentList[index].profilePic);
              DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
              DateFormat dateFormat2 = DateFormat('dd-MM-yyyy');
              DateFormat dateFormat3 = DateFormat('hh:mm a');
              DateTime dateTime =
              dateFormat.parse(snapshot.data!.data.letterSentList[index].datetime.toString());
              String formattedDate = dateFormat2.format(dateTime);
              String formattedTime = dateFormat3.format(dateTime);
              String approveStatus;
              Color? color;
              if(snapshot.data!.data.letterSentList[index].approvalStatus.toString()=='0'){
                approveStatus='Reject';
                color=Colors.red[200];
              }
              else if(snapshot.data!.data.letterSentList[index].approvalStatus.toString()=='1'){
                 approveStatus='Pending';
                  color=Colors.orange[200];
              }
              else{
                 approveStatus='Approved';
                color=Colors.green[200];
              }
              // if(tempSelected.contains(snapshot.data!.data.letterSentList[index].id.toString()) && deletePressed){
          
              //     return Container();
              //   }
              //   else{
                    if(snapshot.data!.data.letterSentList[index].type=='date'){
                  //       int listCount = tempDelete.where((element) => element == snapshot.data!.data.letterSentList[index].datetime.toString().substring(0,10)).length;
                  //       int apiCount = 0;
                  //       for (var i = 0;i < snapshot.data!.data.letterSentList.length;i++) {
                  //           if (snapshot.data!.data.letterSentList[i].datetime.toString().contains(snapshot.data!.data.letterSentList[index].datetime.toString().substring(0,10))) {
                  //           apiCount++;
                  //           }
                  //         }
                  //         //  print(index);
                  //         //   print("listCount-----------$listCount");
                  //         //   print("apicount------------$apiCount");
                  //      if(
                  //      // tempDelete.contains(snapshot.data["letter_list"][index]['datetime'].toString().substring(0,10)) &&
                  //      (listCount+1)==(apiCount) 
                  //  && deletePressed
                  // ){
                  //   print("true=======");
                  //   return Container();
                  // }
                  // else{
                      return  Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                        child:  Column(
                  children: [
                   // SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children:[
                        Center(child: Text(
                          formattedDate,
                        )
                        ),
                        const SizedBox(width: 20,)
                      ],
                    ),
                  ],
                ) 
                      ); 
                      // }
                    }
                    else{
              return Padding(
               // padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
               padding: const EdgeInsets.only(left: 10,right: 10,bottom: 15),
                child:  InkWell(
                  onTap: ()async {
                     Email email = Email(
                      sender: snapshot.data!.data.letterSentList[index].from.toString(),
                      receiver:snapshot.data!.data.letterSentList[index].to,
                      bcc: snapshot.data!.data.letterSentList[index].bcc,
                      cc: snapshot.data!.data.letterSentList[index].cc,
                      letter_id:snapshot.data!.data.letterSentList[index].id,
                      approve_status: approveStatus,
                      color: color,
                      subject:snapshot.data!.data.letterSentList[index].subject==''?'(no subject)': snapshot.data!.data.letterSentList[index].subject.toString(),
                      message: snapshot.data!.data.letterSentList[index].body.toString(),
                      date: snapshot.data!.data.letterSentList[index].datetime.toString(),
                      pdf:  snapshot.data!.data.letterSentList[index].letterPath.toString(),
                      profilePic: snapshot.data!.data.letterSentList[index].profilePic.toString(),
                    );
                  String refresh= await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LetterSentDetailView(email: email),
                      ),
                    );
                    if(refresh=='Refresh'){
                       print(refresh);
                    print(refresh.runtimeType);
                      setState(() {
                        letter.getSendList(context);
                      });
                    }
                   // print("deleted id--$id");
                  },
                   onLongPress: () {
                        print('long press $index');
                        print(selectedSentLetter);
                        if(selectedSentLetter.contains(snapshot.data!.data.letterSentList[index].id.toString())){
                        setState(() {
                          selectedSentLetter.remove(snapshot.data!.data.letterSentList[index].id.toString());
                          selectedDate.remove(snapshot.data!.data.letterSentList[index].datetime.toString().substring(0,10));
                          importantStatus.remove(snapshot.data!.data.letterSentList[index].importantStatus.toString());
                          starredStatus.remove(snapshot.data!.data.letterSentList[index].starredStatus.toString());
                          print(importantStatus);
                        print(selectedSentLetter);
                        });
                        
                         }
                        else{
                        setState(() {
                          selectedSentLetter.add(snapshot.data!.data.letterSentList[index].id.toString());
                          selectedDate.add(snapshot.data!.data.letterSentList[index].datetime.toString().substring(0,10));
                          importantStatus.add(snapshot.data!.data.letterSentList[index].importantStatus.toString());
                          starredStatus.add(snapshot.data!.data.letterSentList[index].starredStatus.toString());
                          print(selectedSentLetter);
                          print(importantStatus);
                        });
                        
                        }
                      },
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),
                              color:selectedSentLetter.contains(snapshot.data!.data.letterSentList[index].id)? Colors.grey[400]:Colors.transparent),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Card(
                                color: Colors.grey[300],
                                child: CircleAvatar(
                                    maxRadius: 28,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage: NetworkImage(snapshot.data!.data.letterSentList[index].profilePic)
                                  /*isValidLink(url) == false ? NetworkImage(user.data[index]['profile_pic'])
                                      : NetworkImage("https://cdn.pixabay.com/photo/2019/08/11/18/59/icon-4399701_1280.png")*/
                                ),),
                              //SizedBox(width: 5),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: const BorderRadius.all(Radius.circular(15))
                                ),
                                width: MediaQuery.of(context).size.width/1.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left:10.0,right: 10.0,top: 10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width/1.75-30,
                                            child: Text(
                                              snapshot.data!.data.letterSentList[index].to.join(','),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                       // Spacer(),
                                          Text(
                                            formattedTime.toLowerCase(),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                      snapshot.data!.data.letterSentList[index].subject==''?'(no subject)':   snapshot.data!.data.letterSentList[index].subject,
                                        style: const TextStyle(
                                            fontSize: 13,
                                           // color: snapshot.data!.data.letterSentList[index].mail_read_status.toString()=="0" ? Colors.grey : Colors.black
                                          // fontWeight: FontWeight.bold,
                                        ),             
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width/1.9-30,
                                            child: SizedBox(
                                              height: 40,
                                              child: Text(
                                                parse(document.body?.text).documentElement!.text,
                                                maxLines: 2,
                                                style: const TextStyle(
                                                 // color: letter.sendData[index]['mail_read_status'].toString()=="0" ? Colors.grey : Colors.black,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          ),
                                         
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 5),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                             Container(
                                              //width: 65,
                                             // height: 20,
                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                                              color: color),
                                              child: Padding(
                                                padding: const EdgeInsets.all(2.0),
                                                child: Text(approveStatus),
                                              ),
                                            ),
                                            const SizedBox(width: 10,),
                                            InkWell(
                                                            onTap: () {
                                                              var auth = Provider.of<
                                                                      AuthProvider>(
                                                                  context,
                                                                  listen:
                                                                      false);
                                                              if ( snapshot.data!.data.letterSentList[index].starredStatus
                                                                ==
                                                                  0) {
                                                                setState(() {
                                                                  LetterApiService()
                                                                      .starLetter(
                                                                           snapshot.data!.data.letterSentList[index].id,
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
                                                                      });
                                                                    }
                                                                  });
                                                                });
                                                              } else {
                                                                setState(() {
                                                                  LetterApiService()
                                                                      .unstarLetter(
                                                                          snapshot.data!.data.letterSentList[index].id,
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
                                                                          .letterSentList[
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
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
             } 
           //  }
             },
          ),
        ); }}
        else{
          return const Center(child: CircularProgressIndicator());
        }
     } ),
        bottomNavigationBar: BottomAppBar(
          child: Stack(
      children: [
        Container(
          height: 80,
          width: MediaQuery.of(context).size.width,
          color: Colors.grey[300],
          child: Center(
            child:   SizedBox(
                height: 27,
                child: Container(
                  child: Image(
                    image: AssetImage(transpLogo),
                  ),
                ),
              ),
          ),
        ),
        Container(
          height: 80,
            padding: const EdgeInsets.all(25),
            child:
            InkWell(
                onTap: () =>
                {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LetterComposeScreen())),
                },
                child: Image(image: AssetImage(composeIcon))),
          )
      ],
    ),
        ),
      );
    },);
  }
}