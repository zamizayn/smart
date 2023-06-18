import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/screens/home_screen/letter/letter_draft_details_screen.dart';

import '../../../providers/AuthProvider/auth_provider.dart';
import '../../../providers/LetterProvider/letter_provider.dart';
import '../../../utils/constants/app_constants.dart';
import 'letter_api_services.dart';
class LetterDraftScreen extends StatefulWidget {
  const LetterDraftScreen({super.key});

  @override
  State<LetterDraftScreen> createState() => _LetterDraftScreenState();
}

class _LetterDraftScreenState extends State<LetterDraftScreen> {
  @override
   bool undoPressed=false;
  bool deletePressed=false;
  List selectedDraftLetter=[];
  List selectedDate=[];
   List tempDelete =[];
   List tempSelected = [];
   List archivedStatus =[];
  List importantStatus =[];
  List starredStatus =[];
  List mailRead =[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: selectedDraftLetter.isNotEmpty?AppBar(
              backgroundColor: Colors.grey[500],
               leading: IconButton(
                  onPressed: (() {
                    selectedDraftLetter.clear();
                    // for(var i = 0;i<letter.starredData.length;i++){
                    //     letter.selectedStarredLetter.insert(i,false);
                    //    // print(selectedLetter);
                    // }
                   selectedDate.clear();
                     tempDelete.clear();
                     tempSelected.clear();
                      importantStatus.clear();
                    starredStatus.clear();
                    mailRead.clear();
                    archivedStatus.clear();
                    print(selectedDraftLetter);
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
                  title: Text('${selectedDraftLetter.length} selected'),
              actions: [
                IconButton(
                  onPressed: (){
                   // deletePressed= true;
                   if(archivedStatus.contains('1')){
                    setState(() {
                      print('assign to temp');
                    
                        tempDelete= List.from(selectedDate);
                        selectedDate.clear();
                        tempSelected = List.from(selectedDraftLetter);
                        selectedDraftLetter.clear();
                        importantStatus.clear();
                        archivedStatus.clear();
                        mailRead.clear();
                        starredStatus.clear();
                    });
                    
                    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    //     duration: Duration(seconds: 3),
                    //     content: Text("Archived"),
                    //     action: SnackBarAction(
                    //       label: "Undo",
                    //       onPressed: () {
                    //        // deletePressed=false;
                    //        selectedDraftLetter.clear();
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
                          
                          LetterProvider().multipleArchiveDraftLetter(context, tempSelected).then((value) {
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
                   }
                   else{
                    setState(() {
                      print('assign to temp');
                    
                        tempDelete= List.from(selectedDate);
                        selectedDate.clear();
                        tempSelected = List.from(selectedDraftLetter);
                        selectedDraftLetter.clear();
                        importantStatus.clear();
                        archivedStatus.clear();
                        mailRead.clear();
                        starredStatus.clear();
                    });
                    
                    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    //     duration: Duration(seconds: 5),
                    //     content: Text("Unarchived"),
                    //     action: SnackBarAction(
                    //       label: "Undo",
                    //       onPressed: () {
                    //        // deletePressed=false;
                    //        selectedDraftLetter.clear();
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
                          
                          LetterProvider().multipleUnarchiveDraftLetter(context, tempSelected).then((value) {
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
                        tempSelected = List.from(selectedDraftLetter);
                        selectedDraftLetter.clear();
                        starredStatus.clear();
                        importantStatus.clear();
                        archivedStatus.clear();
                        mailRead.clear();
                    });
                    
                    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    //     duration: Duration(seconds: 3),
                    //     content: Text("Deleted"),
                    //     action: SnackBarAction(
                    //       label: "Undo",
                    //       onPressed: () {
                    //        // deletePressed=false;
                    //        selectedDraftLetter.clear();
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
                          
                          LetterProvider().multipleDeleteDraftLetter(context, tempSelected).then((value) {
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
                  IconButton(
                      onPressed: (){
                        if(mailRead.contains('1')){
                        tempSelected = List.from(selectedDraftLetter);
                        selectedDraftLetter.clear();
                        archivedStatus.clear();
                        importantStatus.clear();
                        starredStatus.clear();
                        mailRead.clear();
                        setState(() {
                          
                        });
                          LetterProvider().multipleMarkasReadDraftLetter(context, tempSelected).then((value) {
                            var data = jsonDecode(value.body);
                            print(data);
                            setState(() {
                            tempSelected.clear();
                            selectedDate.clear();
                           
                            LetterProvider().getInboxList(context);
                            setState(() {
                              
                            });
                            });
                          });
                    }
                    else{
                        tempSelected = List.from(selectedDraftLetter);
                        selectedDraftLetter.clear();
                        archivedStatus.clear();
                        importantStatus.clear();
                        starredStatus.clear();
                        mailRead.clear();
                        setState(() {
                          
                        });
                          LetterProvider().multipleMarkasUnreadDraftLetter(context, tempSelected).then((value) {
                            var data = jsonDecode(value.body);
                            print(data);
                            setState(() {
                            tempSelected.clear();
                            selectedDate.clear();
                            
                            LetterProvider().getInboxList(context);
                            setState(() {
                              
                            });
                            });
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
                      if(importantStatus.contains('0')){
                        tempSelected = List.from(selectedDraftLetter);
                        selectedDraftLetter.clear();
                         archivedStatus.clear();
                        importantStatus.clear();
                        mailRead.clear();
                        selectedDate.clear();
                        starredStatus.clear();
                        setState(() {
                          
                        });
                          LetterProvider().multipleImportantDraftLetter(context, tempSelected).then((value) {
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
                        tempSelected = List.from(selectedDraftLetter);
                        selectedDraftLetter.clear();
                        archivedStatus.clear();
                        importantStatus.clear();
                        mailRead.clear();
                        selectedDate.clear();
                        starredStatus.clear();
                        setState(() {
                          
                        });
                          LetterProvider().multipleUnimportantDraftLetter(context, tempSelected).then((value) {
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
                        tempSelected = List.from(selectedDraftLetter);
                        selectedDraftLetter.clear();
                        archivedStatus.clear();
                        importantStatus.clear();
                        mailRead.clear();
                        selectedDate.clear();
                        starredStatus.clear();
                        setState(() {
                          
                        });
                          LetterProvider().multipleStarDraftLetter(context, tempSelected).then((value) {
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
                        tempSelected = List.from(selectedDraftLetter);
                        selectedDraftLetter.clear();
                        archivedStatus.clear();
                        importantStatus.clear();
                        mailRead.clear();
                        selectedDate.clear();
                        starredStatus.clear();
                        setState(() {
                          
                        });
                          LetterProvider().multipleUnstarDraftLetter(context, tempSelected).then((value) {
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
        color: Colors.black38,
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0),
            child: Row(
              children: const [
                BackButton(color: Colors.white),
                  Text(
                  'Letter Draft',
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
                future: LetterProvider().getDraftList(context),
                builder: (context, snapshot) {
                  // print("snapshot----------------------");
                  // print(snapshot.data);
                  // if(snapshot.connectionState ==ConnectionState.waiting){
                  //   return Center(
                  //     child: CircularProgressIndicator(),
                  //   );
                  // }
                  //  else
                  if(snapshot.hasData){
                    if(snapshot.data['letter_list'].length==0){
                    return const Center(
                      child: Text('No Draft letter',style: TextStyle(fontSize: 16)),
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
                    final document = parse(snapshot.data['letter_list'][index]['body'].toString());
                    //final String parsedString = parse(document.body?.text).documentElement.text;
                    Uri url = Uri.parse(snapshot.data['letter_list'][index]['profile_pic'].toString());
                    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
                    DateFormat dateFormat2 = DateFormat('dd-MM-yyyy');
                    DateFormat dateFormat3 = DateFormat('hh:mm a');
                    DateTime dateTime =
                    dateFormat.parse(snapshot.data['letter_list'][index]['datetime']);
                    String formattedDate = dateFormat2.format(dateTime);
                    String formattedTime = dateFormat3.format(dateTime);
                    print(snapshot.data['letter_list'][index]['id']);
                    if(tempSelected.contains(snapshot.data['letter_list'][index]['id'].toString()) && deletePressed){
              
                      return Container();
                    }
                    else{
                        if(snapshot.data['letter_list'][index]['type']=='date'){
                            int listCount = tempDelete.where((element) => element == snapshot.data['letter_list'][index]['datetime'].toString().substring(0,10)).length;
                            int apiCount = 0;
                            for (var i = 0;i < snapshot.data['letter_list'].length;i++) {
                                if (snapshot.data['letter_list'][i]['datetime'].toString().contains(snapshot.data['letter_list'][index]['datetime'].toString().substring(0,10))) {
                                apiCount++;
                                }
                              }
                               print(index);
                                print('listCount-----------$listCount');
                                print('apicount------------$apiCount');
                           if(
                           // tempDelete.contains(snapshot.data["letter_list"][index]['datetime'].toString().substring(0,10)) &&
                           (listCount+1)==(apiCount) 
                       && deletePressed
                      ){
                        print('true=======');
                        return Container();
                      }
                      else{
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
                          ); }
                        }
                        else{
                          return  Padding(
                            padding: const EdgeInsets.only(left: 15,right: 15,bottom: 15),
                            child: InkWell(
                            onTap: () async {
                            EmailLetter email = EmailLetter(
                              sender: snapshot.data['letter_list'][index]['from'].toString(),
                              letter_id: snapshot.data['letter_list'][index]['id'].toString(),
                              receiver: snapshot.data['letter_list'][index]['to'],
                              bcc: snapshot.data['letter_list'][index]['bcc'],
                              cc: snapshot.data['letter_list'][index]['cc'],
                              addressTo:snapshot.data['letter_list'][index]['address_to'],
                              subject: snapshot.data['letter_list'][index]['subject'],
                              message: snapshot.data['letter_list'][index]['body'].toString(),
                              date: snapshot.data['letter_list'][index]['datetime'].toString(),
                              pdf:  snapshot.data['letter_list'][index]['letter_attatchment'].toString(),
                              profilePic: snapshot.data['letter_list'][index]['profile_pic'].toString(),
                            );
                                        
                                        
                            String refresh = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LetterDraftDetailScreen(email: email),
                              ),
                            );
                             if(refresh == 'Refresh'){
                              setState(() {
                                
                              });
                            }
                          },
                         onLongPress: () {
                            print('long press $index');
                            print(selectedDraftLetter);
                            if(selectedDraftLetter.contains(snapshot.data['letter_list'][index]['id'].toString())){
                            setState(() {
                              selectedDraftLetter.remove(snapshot.data['letter_list'][index]['id'].toString());
                              selectedDate.remove(snapshot.data['letter_list'][index]['datetime'].toString().substring(0,10));
                              importantStatus.remove(snapshot.data['letter_list'][index]['important_status'].toString());
                              starredStatus.remove(snapshot.data['letter_list'][index]['starred_status'].toString());
                              mailRead.remove(snapshot.data['letter_list'][index]['mark_as_read'].toString());
                              archivedStatus.remove(snapshot.data['letter_list'][index]['archive_status'].toString());
                              print(mailRead);
                            print(selectedDraftLetter);
                            });
                            
                             }
                            else{
                            setState(() {
                              selectedDraftLetter.add(snapshot.data['letter_list'][index]['id'].toString());
                              selectedDate.add(snapshot.data['letter_list'][index]['datetime'].toString().substring(0,10));
                              importantStatus.add(snapshot.data['letter_list'][index]['important_status'].toString());
                              starredStatus.add(snapshot.data['letter_list'][index]['starred_status'].toString());
                              mailRead.add(snapshot.data['letter_list'][index]['mark_as_read'].toString());
                              archivedStatus.add(snapshot.data['letter_list'][index]['archive_status'].toString());
                              print(selectedDraftLetter);
                              print(mailRead);
                            });
                            
                            }
                          },
                          child: Container(
                             decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),
                                    color:selectedDraftLetter.contains(snapshot.data['letter_list'][index]['id'])? Colors.grey[400]:Colors.transparent),
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
                                        child: Image.asset(defaultImage),
                                      //  backgroundImage: NetworkImage(snapshot.data["letter_list"][index]['profile_pic'])
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
                                                child: const Text(
                                                  'Draft',
                                                  //snapshot.data["letter_list"][index]['from'],
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.red,
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
                                            snapshot.data['letter_list'][index]['subject'].toString() ==''?
                                            '(no subject)' :snapshot.data['letter_list'][index]['subject'].toString(),
                                            style: TextStyle(
                                                fontSize: 13,
                                                color:snapshot.data['letter_list'][index]['mark_as_read'].toString()=='0'?Colors.grey :Colors.black
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
                                                    color: snapshot.data['letter_list'][index]['mark_as_read'].toString()=='0'?Colors.grey : Colors.black,
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
                   
                  }
                  },
                );}
                  }
                  else{
                    return const CircularProgressIndicator();
                  }
                },
              
              ),
            ),
    );
  }
}