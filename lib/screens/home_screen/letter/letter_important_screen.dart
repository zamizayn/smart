import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/screens/home_screen/letter/letter_api_services.dart';
import 'package:smart_station/screens/home_screen/letter/letter_detail_screen.dart';
import 'package:smart_station/screens/home_screen/letter/letter_draft_details_screen.dart';

import '../../../providers/LetterProvider/letter_provider.dart';
import 'package:html/parser.dart';

class LetterImportantScreen extends StatefulWidget {
  const LetterImportantScreen({Key? key}) : super(key: key);

  @override
  State<LetterImportantScreen> createState() => _LetterImportantScreenState();
}

class _LetterImportantScreenState extends State<LetterImportantScreen> {
  @override
  var letter;
  bool undoPressed=false;
  bool deletePressed=false;
   List selectedImportantLetter=[];
   List selectedDate=[];
   List tempDelete =[];
   List tempSelected = [];
   List archivedStatus =[];
  List starredStatus =[];
   List mailRead =[];
   List selectedDraftLetter =[];
   List tempDraft = [];
    @override
  void initState() {
    // TODO: implement initState
    print('fd');
    super.initState();
    setState(() {
     letter = Provider.of<LetterProvider>(context,listen: false);
    letter.getImportantList(context);
    print(letter.importantData.length);
    
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  selectedImportantLetter.isNotEmpty ||selectedDraftLetter.isNotEmpty?AppBar(
              backgroundColor: Colors.grey[500],
               leading: IconButton(
                  onPressed: (() {
                    selectedImportantLetter.clear();
                    selectedDraftLetter.clear();
                    selectedDate.clear();
                    // for(var i = 0;i<letter.starredData.length;i++){
                    //     letter.selectedStarredLetter.insert(i,false);
                    //    // print(selectedLetter);
                    // }
                    selectedDate.clear();
                     tempDelete.clear();
                     tempSelected.clear();
                     archivedStatus.clear();
                    starredStatus.clear();
                    mailRead.clear();
                    print(selectedImportantLetter);
                    setState(() {
                      
                    });
                     // letter.getSelectedStarredLetter(letter.selectedStarredLetter);
                    //Navigator.pop(context, "Refresh");
                  }),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                  )),
                  title: Text('${selectedImportantLetter.length+selectedDraftLetter.length} selected'),
              actions: [
                IconButton(
                  onPressed: (){
                   // deletePressed= true;
                   if(archivedStatus.contains('1')){
                    setState(() {
                      print('assign to temp');
                    
                        tempDelete= List.from(selectedDate);
                        selectedDate.clear();
                        tempSelected = List.from(selectedImportantLetter);
                        selectedImportantLetter.clear();
                        tempDraft = List.from(selectedDraftLetter);
                        selectedDraftLetter.clear();
                        archivedStatus.clear();
                        starredStatus.clear();
                        mailRead.clear();
                    });
                    
                    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    //     duration: Duration(seconds: 3),
                    //     content: Text("Archived"),
                    //     action: SnackBarAction(
                    //       label: "Undo",
                    //       onPressed: () {
                    //        // deletePressed=false;
                    //        selectedImportantLetter.clear();
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
                          if(tempSelected.isNotEmpty){
                          LetterProvider().multipleArchiveLetter(context, tempSelected).then((value) {
                            var data = jsonDecode(value.body);
                            print(data);
                            setState(() {
                              
                            });
                          });
                          }
                          if(tempDraft.isNotEmpty){
                            LetterProvider().multipleArchiveDraftLetter(context, tempDraft).then((value) {
                            var data = jsonDecode(value.body);
                            print(data);
                            setState(() {
                              
                            });
                          });
                          }
                          setState(() {
                           deletePressed=false;
                            tempDelete.clear();
                            tempSelected.clear();
                            tempDraft.clear();
                          print('unpressed false');
                          });
                      //   }
                      // });
                   }
                    else{
                    setState(() {
                      print('assign to temp');
                    
                        tempDelete= List.from(selectedDate);
                        selectedDate.clear();
                        tempSelected = List.from(selectedImportantLetter);
                        selectedImportantLetter.clear();
                        tempDraft = List.from(selectedDraftLetter);
                        selectedDraftLetter.clear();
                        starredStatus.clear();
                        archivedStatus.clear();
                        mailRead.clear();
                    });
                    
                    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    //     duration: Duration(seconds: 3),
                    //     content: Text("Unarchived"),
                    //     action: SnackBarAction(
                    //       label: "Undo",
                    //       onPressed: () {
                    //        // deletePressed=false;
                    //        selectedImportantLetter.clear();
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
                          if(tempSelected.isNotEmpty){
                          LetterProvider().multipleUnarchiveLetter(context, tempSelected).then((value) {
                            var data = jsonDecode(value.body);
                            print(data);
                            setState(() {
                              
                            });
                          });
                          }
                          if(tempDraft.isNotEmpty){
                          LetterProvider().multipleUnarchiveDraftLetter(context, tempDraft).then((value) {
                            var data = jsonDecode(value.body);
                            print(data);
                            setState(() {
                              
                            });
                          });
                          }
                          setState(() {
                           deletePressed=false;
                            tempDelete.clear();
                            tempSelected.clear();
                            tempDraft.clear();
                          print('unpressed false');
                          });
                      //   }
                      // });
                   }
                  }, 
                icon: Icon(
                      archivedStatus.contains('1')?  Icons.archive:Icons.unarchive,
                      color: Colors.white,
                      size: 30,
                    )),
                     IconButton(
                  onPressed: (){
                    deletePressed= true;
                    setState(() {
                      print('assign to temp');
                    
                        tempDelete= List.from(selectedDate);
                        selectedDate.clear();
                        tempSelected = List.from(selectedImportantLetter);
                        selectedImportantLetter.clear();
                         tempDraft = List.from(selectedDraftLetter);
                        selectedDraftLetter.clear();
                        archivedStatus.clear();
                        starredStatus.clear();
                        mailRead.clear();
                      //  print("Clearing");
                       
                      //  print("cleared");
                      // selectedImportantLetter.clear();
                    });
                    
                    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    //     duration: Duration(seconds: 3),
                    //     content: Text("Deleted"),
                    //     action: SnackBarAction(
                    //       label: "Undo",
                    //       onPressed: () {
                    //        // deletePressed=false;
                    //        selectedImportantLetter.clear();
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

                    //   Future.delayed(Duration(seconds: 3), () {
                    //     if (undoPressed == true) {
                    //       setState(() {
                    //        // tempDelete.clear();
                    //        deletePressed=false;
                    //         // selectedImportantLetter.clear();
                    //         // selectedDate.clear();
                    //         tempDelete.clear();
                    //         tempSelected.clear();
                    //       });
                        
                    //       print("hello");
                    //     } else {
                          if(tempSelected.isNotEmpty){
                            LetterProvider().multipleDeleteLetter(context, tempSelected).then((value) {
                              var data = jsonDecode(value.body);
                              print(data);
                            setState(() {
                              
                            });
                          });
                          }
                          if(tempDraft.isNotEmpty){
                              LetterProvider().multipleDeleteDraftLetter(context, tempDraft).then((value) {
                              var data = jsonDecode(value.body);
                              print(data);
                            setState(() {
                              
                            });
                          });
                          }
                          setState(() {
                           // tempDelete.clear();
                           deletePressed=false;
                            // selectedImportantLetter.clear();
                            // selectedDate.clear();
                            tempDraft.clear();
                            tempDelete.clear();
                            tempSelected.clear();
                          print('unpressed false');
                          });
                          
                            // letter.deleteLetter(widget.email.letter_id, context);
                            // print("deleted");
                            // letter.multipleDel.then((value) {
                            //   print(value.body);
                            //   Navigator.pop(context,"Refresh");
                            // } 
                            // );
                            
                            
                      //   }
                      // });
                  }, 
                icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 30,
                    )),
                IconButton(
                      onPressed: (){
                        if(mailRead.contains('1')){
                        tempSelected = List.from(selectedImportantLetter);
                        selectedImportantLetter.clear();
                        tempDraft = List.from(selectedDraftLetter);
                        selectedDraftLetter.clear();
                        archivedStatus.clear();
                        starredStatus.clear();
                        mailRead.clear();
                        setState(() {
                          
                        });
                        if(tempSelected.isNotEmpty){
                          LetterProvider().multipleMarkasReadLetter(context, tempSelected).then((value) {
                            var data = jsonDecode(value.body);
                            print(data);
                           setState(() {
                             
                           });
                          });
                        }
                        if(tempDraft.isNotEmpty){
                          LetterProvider().multipleMarkasReadDraftLetter(context, tempDraft).then((value) {
                            var data = jsonDecode(value.body);
                            print(data);
                           setState(() {
                             
                           });
                          });
                        }
                           setState(() {
                            tempSelected.clear();
                            selectedDate.clear();
                            tempDraft.clear();
                            });
                    }
                    else{
                        tempSelected = List.from(selectedImportantLetter);
                        selectedImportantLetter.clear();
                        tempDraft = List.from(selectedDraftLetter);
                        selectedDraftLetter.clear();
                        archivedStatus.clear();
                        starredStatus.clear();
                        mailRead.clear();
                        setState(() {
                          
                        });
                        if(tempSelected.isNotEmpty){
                          LetterProvider().multipleMarkasUnreadLetter(context, tempSelected).then((value) {
                            var data = jsonDecode(value.body);
                            print(data);
                           setState(() {
                             
                           });
                          });
                        }
                        if(tempDraft.isNotEmpty){
                          LetterProvider().multipleMarkasUnreadDraftLetter(context, tempDraft).then((value) {
                            var data = jsonDecode(value.body);
                            print(data);
                           setState(() {
                             
                           });
                          });
                        }
                           setState(() {
                            tempSelected.clear();
                            selectedDate.clear();
                            tempDraft.clear();
                            });
                    }
                      },
                       icon:mailRead.contains('1')?const Icon(Icons.mark_email_read):const Icon(Icons.mark_email_unread) ),
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
                        tempSelected = List.from(selectedImportantLetter);
                        selectedImportantLetter.clear();
                         tempDraft = List.from(selectedDraftLetter);
                        selectedDraftLetter.clear();
                        archivedStatus.clear();
                        starredStatus.clear();
                        mailRead.clear();
                        setState(() {
                          
                        });
                        if(tempSelected.isNotEmpty){
                          LetterProvider().multipleUnimportantLetter(context, tempSelected).then((value) {
                            var data = jsonDecode(value.body);
                            print(data);
                            setState(() {
                              
                            });
                          });
                        }
                         if(tempDraft.isNotEmpty){
                          LetterProvider().multipleUnimportantDraftLetter(context, tempDraft).then((value) {
                            var data = jsonDecode(value.body);
                            print(data);
                            setState(() {
                              
                            });
                            
                          });
                        }
                        
                          setState(() {
                            tempSelected.clear();
                            selectedDate.clear();
                            tempDraft.clear();
                            });
                     break;
                  case 'option2':
                       if(starredStatus.contains('0')){
                        tempSelected = List.from(selectedImportantLetter);
                        selectedImportantLetter.clear();
                        tempDraft = List.from(selectedDraftLetter);
                        selectedDraftLetter.clear();
                       // starredStatus.clear();
                        archivedStatus.clear();
                        mailRead.clear();
                        selectedDate.clear();
                        starredStatus.clear();
                        setState(() {
                          
                        });
                        if(tempSelected.isNotEmpty){
                          LetterProvider().multipleStarLetter(context, tempSelected).then((value) {
                            var data = jsonDecode(value.body);
                            print(data);
                            setState(() {
                              
                            });
                            
                          });
                        }
                        if(tempDraft.isNotEmpty){
                          LetterProvider().multipleStarDraftLetter(context, tempDraft).then((value) {
                            var data = jsonDecode(value.body);
                            print(data);
                            setState(() {
                              
                            });
                          });
                        }
                          setState(() {
                            tempSelected.clear();
                            selectedDate.clear();
                            tempDraft.clear();
                            });
                    }
                    else{
                        tempSelected = List.from(selectedImportantLetter);
                        selectedImportantLetter.clear();
                        tempDraft = List.from(selectedDraftLetter);
                        selectedDraftLetter.clear();
                        //starredStatus.clear();
                        archivedStatus.clear();
                        mailRead.clear();
                        selectedDate.clear();
                        starredStatus.clear();
                        setState(() {
                          
                        });
                        if(tempSelected.isNotEmpty){
                          LetterProvider().multipleUnstarLetter(context, tempSelected).then((value) {
                            var data = jsonDecode(value.body);
                            print(data);
                            setState(() {
                              
                            });
                          });
                        }
                        if(tempDraft.isNotEmpty){
                          LetterProvider().multipleUnstarDraftLetter(context, tempDraft).then((value) {
                            var data = jsonDecode(value.body);
                            print(data);
                            setState(() {
                              
                            });
                          });
                        }
                          setState(() {
                            tempSelected.clear();
                            tempDraft.clear();
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
                  const PopupMenuItem<String>(
                    value: 'option1',
                    child:Text('Mark unimportant'),
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
                  'Letter Important',
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
      body:Center(
              child: //Text("Email devi"),
              FutureBuilder(
                future: LetterProvider().getImportantList(context),
                builder: (context, snapshot) {
                  // print("snapshot----------------------");
                  // print(snapshot.data);
                  if(snapshot.hasData){
                   
                   if(snapshot.data['letter_list'].length==0){
                    return const Center(
                      child: Text('No important letter',style: TextStyle(fontSize: 16)),
                    );
                  }
                  else{
                  return  ListView.builder(
                  /*padding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 15,
                        ),*/
                  
                  itemCount: snapshot.data['letter_list'].length,
                  itemBuilder: (context, index) {
                    final document = parse(snapshot.data['letter_list'][index]['body']);
                    //final String parsedString = parse(document.body?.text).documentElement.text;
                    Uri url = Uri.parse(snapshot.data['letter_list'][index]['profile_pic']);
                    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
                    DateFormat dateFormat2 = DateFormat('dd-MM-yyyy');
                    DateFormat dateFormat3 = DateFormat('hh:mm a');
                    DateTime dateTime =
                    dateFormat.parse(snapshot.data['letter_list'][index]['datetime']);
                    String formattedDate = dateFormat2.format(dateTime);
                    String formattedTime = dateFormat3.format(dateTime);
                   // print('del--------------------$tempDelete');
                  //  print("temp-------$tempDraft");
                  //  print(tempSelected.contains(snapshot.data["letter_list"][index]['id']));
                  //  print(tempSelected.contains(snapshot.data["letter_list"][index]['id'].toString()));
                    // if((
                    //   (tempSelected.contains(snapshot.data["letter_list"][index]['id'].toString())&&
                    //  snapshot.data["letter_list"][index]['type']=='letter')||
                    //  (tempDraft.contains(snapshot.data["letter_list"][index]['id'].toString())&&
                    //  snapshot.data["letter_list"][index]['type']=='draft')
                    // )&& deletePressed){
                    //  // snapshot.data['letterlist'].removeAt(index-1);
                    //   return Container();
                    // }
                    // else{
                        if(snapshot.data['letter_list'][index]['type']=='date'){
                      //       int listCount = tempDelete.where((element) => element == snapshot.data["letter_list"][index]['datetime'].toString().substring(0,10)).length ;
                      //       int apiCount = 0;
                      //       for (var i = 0;i < snapshot.data["letter_list"].length;i++) {
                      //           if (snapshot.data["letter_list"][i]['datetime'].toString().contains(snapshot.data["letter_list"][index]['datetime'].toString().substring(0,10))) {
                      //           apiCount++;
                      //           }
                      //         }
                      //         //  print(index);
                      //         //   print("listCount$index-----------$listCount");
                      //         //   print("apicount$index------------$apiCount");
                      //      if(
                      //      // tempDelete.contains(snapshot.data["letter_list"][index]['datetime'].toString().substring(0,10)) &&
                      //      (listCount+1)==(apiCount) 
                      //  && deletePressed
                      // ){
                      //  // print("true=======");
                      //   return Container();
                      // }
                      // else{
                          return  Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                            child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                children:[
                                    Center(child: Text(
                                        formattedDate,
                                      )
                                    ),
                                    const SizedBox(width: 20,)
                                ],
                              ),
                          ); 
                          // }
                        }
                        else{
                          return  Padding(
                            padding: const EdgeInsets.only(left: 15,right: 15,bottom: 15),
                            child: InkWell(
                            onTap: () async{
                              if(snapshot.data['letter_list'][index]['type']=='letter'){
                            Email email = Email(
                              sender: snapshot.data['letter_list'][index]['from'],
                              letter_id: snapshot.data['letter_list'][index]['id'],
                              receiver: snapshot.data['letter_list'][index]['to'],
                              bcc: snapshot.data['letter_list'][index]['bcc'],
                              cc: snapshot.data['letter_list'][index]['cc'],
                              
                              status:snapshot.data['letter_list'][index]['approval_status'],
                              subject:snapshot.data['letter_list'][index]['subject']==''?'(no subject)' :  snapshot.data['letter_list'][index]['subject'],
                              message: snapshot.data['letter_list'][index]['body'],
                              date: snapshot.data['letter_list'][index]['datetime'],
                              pdf:  snapshot.data['letter_list'][index]['letter_path'],
                              profilePic: snapshot.data['letter_list'][index]['profile_pic'],
                            );        
                          String refresh= await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LetterDetailScreen(email: email),
                              ),
                            );
                            if(refresh=='Refresh'){
                              setState(() {
                                
                              });
                            }
                              }
                              if(snapshot.data['letter_list'][index]['type']=='draft'){
                              EmailLetter email = EmailLetter(
                              sender: snapshot.data['letter_list'][index]['from'].toString(),
                              letter_id: snapshot.data['letter_list'][index]['id'].toString(),
                              receiver: snapshot.data['letter_list'][index]['to'],
                              bcc: snapshot.data['letter_list'][index]['bcc'],
                              cc: snapshot.data['letter_list'][index]['cc'],
                              addressTo:snapshot.data['letter_list'][index]['address_to'],
                              subject: snapshot.data['letter_list'][index]['subject']==''?'(no subject)':snapshot.data['letter_list'][index]['subject'],
                              message: snapshot.data['letter_list'][index]['body'].toString(),
                              date: snapshot.data['letter_list'][index]['datetime'].toString(),
                              pdf:  snapshot.data['letter_list'][index]['letter_attatchment'].toString(),
                              profilePic: snapshot.data['letter_list'][index]['profile_pic'].toString(),
                            );
                                        
                                        
                            String refresh= await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LetterDraftDetailScreen(email: email),
                              ),
                            );
                            if(refresh=='Refresh'){
                              setState(() {
                                
                              });
                            }
                            }
                          },
                         onLongPress: () {
                            print('long press $index');
                           // print(selectedImportantLetter);
                            if((selectedImportantLetter.contains(snapshot.data['letter_list'][index]['id'].toString())
                            &&snapshot.data['letter_list'][index]['type']=='letter') ||
                            (selectedDraftLetter.contains(snapshot.data['letter_list'][index]['id'].toString())
                            &&snapshot.data['letter_list'][index]['type']=='draft')
                            ){
                            setState(() {
                              if(snapshot.data['letter_list'][index]['type']=='draft'){
                                selectedDraftLetter.remove(snapshot.data['letter_list'][index]['id'].toString());
                              }
                              else{
                                selectedImportantLetter.remove(snapshot.data['letter_list'][index]['id'].toString());
                              }
                              selectedDate.remove(snapshot.data['letter_list'][index]['datetime'].toString().substring(0,10));
                              mailRead.remove(snapshot.data['letter_list'][index]['mail_read_status'].toString());
                              archivedStatus.remove(snapshot.data['letter_list'][index]['archive_status'].toString());
                              starredStatus.remove(snapshot.data['letter_list'][index]['starred_status'].toString());
                              print('if');
                              print(selectedDraftLetter);
                            print(selectedImportantLetter);
                            });
                            
                             }
                            else{
                            setState(() {
                               if(snapshot.data['letter_list'][index]['type']=='draft'){
                                selectedDraftLetter.add(snapshot.data['letter_list'][index]['id'].toString());
                              }
                              else{
                                selectedImportantLetter.add(snapshot.data['letter_list'][index]['id'].toString());
                              }
                              selectedDate.add(snapshot.data['letter_list'][index]['datetime'].toString().substring(0,10));
                              mailRead.add(snapshot.data['letter_list'][index]['mail_read_status'].toString());
                              archivedStatus.add(snapshot.data['letter_list'][index]['archive_status'].toString());
                              starredStatus.add(snapshot.data['letter_list'][index]['starred_status'].toString());
                              print('else');
                              print(selectedImportantLetter);
                              print(selectedDraftLetter);
                            });
                            
                            }
                          },
                          child: Container(
                             decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),
                                    color:(selectedImportantLetter.contains(snapshot.data['letter_list'][index]['id']) &&
                                    snapshot.data['letter_list'][index]['type']=='letter')
                                    ||(selectedDraftLetter.contains(snapshot.data['letter_list'][index]['id'])&&
                                    snapshot.data['letter_list'][index]['type']=='draft')
                                    ? Colors.grey[400]:Colors.transparent),
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
                                        backgroundImage: NetworkImage(snapshot.data['letter_list'][index]['profile_pic'])
                                      /*isValidLink(url) == false ? NetworkImage(user.data[index]['profile_pic'])
                                        : NetworkImage("https://cdn.pixabay.com/photo/2019/08/11/18/59/icon-4399701_1280.png")*/
                                    ),),
                                  //SizedBox(width: 5),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: const BorderRadius.all(Radius.circular(15))
                                    ),
                                    width: MediaQuery.of(context).size.width/1.45,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left:10.0,right: 10.0,top: 10.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context).size.width/2-30,
                                                child: Text(
                                                   snapshot.data['letter_list'][index]['type']=='draft'?
                                                  'Draft'
                                                 : snapshot.data['letter_list'][index]['from'],
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color:snapshot.data['letter_list'][index]['type']=='draft'?
                                                      Colors.red:Colors.black ,
                                                    fontWeight: FontWeight.bold,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
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
                                          snapshot.data['letter_list'][index]['subject']==''?'(no subject)' :   snapshot.data['letter_list'][index]['subject'],
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: snapshot.data['letter_list'][index]['mail_read_status'].toString()=='0' ? Colors.grey : Colors.black
                                              // fontWeight: FontWeight.bold,
                                            ),
                                      
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                height: 45,
                                                width: MediaQuery.of(context).size.width/2,
                                                child: Text(
                                                  parse(document.body?.text).documentElement!.text,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    color: snapshot.data['letter_list'][index]['mail_read_status'].toString()=='0' ? Colors.grey : Colors.black,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w400,
                                      
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
                                                      if(snapshot.data['letter_list'][index]['type']=='draft'){
                                                           if ( snapshot.data['letter_list'][index]['starred_status'].toString() ==
                                                                '0') {
                                                              setState(() {
                                                                
                                                                LetterApiService()
                                                                    .starDraftLetter(
                                                                        snapshot.data['letter_list'][index]['id'],
                                                                        auth.accessToken,
                                                                        auth.userId)
                                                                    .then((value) {
                                                                  var data =
                                                                      jsonDecode(
                                                                          value.body);
                                                                  print(data);
                                                                });
                                                                
                                                              });
                                                               
                                                              
                                                            } else {
                                                              setState(() {
                                                              
                                                                LetterApiService()
                                                                    .unstarDraftLetter(
                                                                        snapshot.data['letter_list'][index]['id'],
                                                                        auth.accessToken,
                                                                        auth.userId)
                                                                    .then((value) {
                                                                  var data =
                                                                      jsonDecode(
                                                                          value.body);
                                                                  print(data);
                                                                });
                                                              
                                                              });
                                                            }
                                                        }
                                                        else{
                                                            if ( snapshot.data['letter_list'][index]['starred_status'].toString() ==
                                                                '0') {
                                                              setState(() {
                                                               
                                                                LetterApiService()
                                                                    .starLetter(
                                                                        snapshot.data['letter_list'][index]['id'],
                                                                        auth.accessToken,
                                                                        auth.userId)
                                                                    .then((value) {
                                                                  var data =
                                                                      jsonDecode(
                                                                          value.body);
                                                                  print(data);
                                                                });
                                                                 
                                                              });
                                                              
                                                            } else {
                                                              setState(() {
                                                              
                                                                LetterApiService()
                                                                    .unstarLetter(
                                                                        snapshot.data['letter_list'][index]['id'],
                                                                        auth.accessToken,
                                                                        auth.userId)
                                                                    .then((value) {
                                                                  var data =
                                                                      jsonDecode(
                                                                          value.body);
                                                                  print(data);
                                                                });
                                                              
                                                              });
                                                            }
                                                          }
                                                          },
                                                          child: Icon(
                                                            Icons.star,
                                                            color: snapshot.data['letter_list'][index]['starred_status'].toString() ==
                                                                    '1'
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
                  //}
                  },
                );}}
                else{
                  return const CircularProgressIndicator();
                }
                },
              ),
            ),
    );
  }
}
