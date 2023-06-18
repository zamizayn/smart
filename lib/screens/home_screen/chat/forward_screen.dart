import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/screens/home_screen/chat/group_conversation_screen.dart';
import 'package:smart_station/screens/home_screen/chat/newConvoScreen.dart';
import 'package:smart_station/utils/constants/urls.dart';

import '../../../providers/AuthProvider/auth_provider.dart';
import '../../../providers/UserProvider/user_provider.dart';
import '../../../utils/constants/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
class ForwardScreen extends StatefulWidget {
  List messageId ;
  final rId;
  ForwardScreen({super.key,required this.messageId,required this.rId});

  @override
  State<ForwardScreen> createState() => _ForwardScreenState();
}

class _ForwardScreenState extends State<ForwardScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  bool searchStatus =false;
  List forwardIds = [];
  List forwardname = [];
  List forwardIndex = [];
  List groupIndex = [];
  List groupList = [];
  var length;
   final IO.Socket _socket = IO.io(AppUrls.appSocketUrl,
      IO.OptionBuilder().setTransports(['websocket']).build());

  _connectSocket() {
    _socket.connect();
    _socket.onConnect((data) => print('Connection established'));
    _socket.onConnectError((data) => print('Connect Error $data'));
    _socket.onDisconnect((data) => print('Socket.IO disconneted'));
  }

  _destroySocket(){
    _socket.disconnect();
  }
  
  socketGetGroup() async{
    var auth = Provider.of<AuthProvider>(context, listen: false);
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
    };
    print("body--------$body");
    if(_socket.connected){
       _socket.emit('my_group_list',body);
      _socket.on('my_group_list', (data) {
        print(data);
        groupList = data['data'];
        print(groupList);
      });
    }
    else{
     _connectSocket();
      _socket.emit('my_group_list',body);
      _socket.on('my_group_list', (data) {
        print(data);
        groupList = data['data'];
        print(groupList);
      });
    }
    
   
  }
 
  @override
  void initState() {
    socketGetGroup();
    _connectSocket();
    // TODO: implement initState
    super.initState();
  }
  
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text('Forward to.....'),
    //     actions: [
    //       IconButton(
    //         onPressed: (){}, 
    //         icon: const Icon(Icons.search))
    //     ],
    //   ),
    //   body: Column(),
    // );
    return Consumer<UserProvider>(
      builder: (context, user, child) {
        // final data = jsonDecode(user.resMessage);
        // userData = user.data;

        search(String val) {
          if (val.isEmpty) {
            user.userList(context:context);
          }
          else{
            final fnd = user.data.where((element) {
              final name = element['name'].toString().toLowerCase();
              final phone = element['phone'].toString().toLowerCase();
              final input = val.toLowerCase();
              return  (name.contains(input)||phone.contains(input));
            }).toList();
            // print(found);
            print('::::::[NAME]::::::');
            print(fnd);
            print('::::::[NAME]::::::');

            setState(() {
              user.getActualData(fnd);
            });
          }
        }
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            leading: searchStatus? IconButton(
              onPressed: (){
                searchStatus = false;
                _textEditingController.clear();
                search('');
                setState(() {
                  
                });
              },
               icon: const Icon(Icons.arrow_back,color: Colors.black,))
               :IconButton(
              onPressed: (){
                
                Navigator.pop(context);
              },
               icon: const Icon(Icons.arrow_back,color: Colors.black,)),
            title:forwardIds.isNotEmpty? 
            Text('${forwardIds.length} selected',style: const TextStyle(color: Colors.black,),)
            :searchStatus? Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 0),
              decoration: BoxDecoration(
                color:  Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child:
              TextField(
                controller: _textEditingController,
                onChanged: (value) {

                  search(value);
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search...',
                  prefixIcon: Icon(
                    Icons.search,
                  ),
                ),
              ),
            ) 
            : const Text('Forward to.....',style: TextStyle(color: Colors.black,),),
        actions: [
        searchStatus?const SizedBox()
          :  IconButton(
            onPressed: (){
              searchStatus =true ;
              setState(() {
                
              });
            }, 
            icon: const Icon(Icons.search,color: Colors.black,))
        ],
            //leading: BackButton(color: rightGreen),
          ),
          body:
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Text('Group',style: TextStyle(fontSize: 18),),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  itemCount: groupList.length,
                  itemBuilder: (context, index){
                    if(groupList[index]['group_id'] != widget.rId) {
                      if(groupList[index]['group_name'].toString().toLowerCase().contains(_textEditingController.text.toString().toLowerCase())) {
                        return Column(
                      children: [
                        InkWell(
                          onTap: (){
                             //print( user.data[index]['user_id']);
                            if( forwardIds.contains(groupList[index]['group_id']+':g')){
                              forwardIds.remove(groupList[index]['group_id'].toString()+':g');
                              forwardname.remove(groupList[index]['group_name']);
                              groupIndex.remove(index);
                            }
                            else{
                              forwardIds.add(groupList[index]['group_id']+':g');
                              forwardname.add(groupList[index]['group_name']);
                              groupIndex.add(index);
                            }
                            print(forwardIds);
                            length=forwardIds.length;
                            print(forwardIds.length);
                            setState(() {
                              
                            });
                            // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => NewConversation(rId: user.data[index]['user_id'],
                            //   toFcm: user.data[index]['deviceToken'],
                            // )));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(15)),
                                      child: CircleAvatar(
                                        backgroundImage: groupList[index]['group_profile'] !=
                                            null
                                            ? NetworkImage(
                                            groupList[index]['group_profile'])
                                            : const NetworkImage(
                                            'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png'),
                                      ),
                                    ),
                                  Positioned(
                                      right: 1,
                                      bottom: 1,
                                      child:forwardIds.contains(groupList[index]['group_id']+':g')? Container(
                                        decoration: const BoxDecoration(shape: BoxShape.circle,color: Colors.green),
                                        child: const Icon(Icons.check,size: 17,color: Colors.white,))
                                        :const SizedBox()
                                        )
                                  ],
                                ),
                                const SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      groupList[index]['group_name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                        
                                    // Container(
                                    //   padding: const EdgeInsets.only(right: 0.0),
                                    //   width: MediaQuery.of(context).size.width - 140,
                                    //   child: Text(
                                    //     user.data[index]['about'],
                                    //     overflow: TextOverflow.ellipsis,
                                    //     softWrap: false,
                                    //     style: const TextStyle(
                                    //       color:  Color(0xFF9B9898)
                                    //       ,
                                    //     ),
                                    //   ),
                                    // ),
                        
                                  ],
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Divider(),
                        ),
                      ],
                    );
                      }
                      else{
                        return const SizedBox();
                      }
                    }
                    else{
                      return const SizedBox();
                    }
                  }
                  ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Text('Other contacts',style: TextStyle(fontSize: 18),),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  itemCount: user.data.length,
                  itemBuilder: (context, index) {
                    var client = http.Client();
                    Uri url = Uri.parse(user.data[index]['profile_pic']);
                        
                    String? displayName;
                    for (var element in phoneContacts) {
                      element.phones?.forEach((phone) {
                        
                        if (user.data[index]['phone'].replaceAll(' ', '') == phone.value!.replaceAll(' ', '')) {
                          displayName = element.displayName;
                        }
                      });
                    }
                    var auth = Provider.of<AuthProvider>(context, listen: false);
                    if(user.data[index]['user_id']!= widget.rId) {
                      return Column(
                      children: [
                        InkWell(
                          onTap: (){
                             //print( user.data[index]['user_id']);
                            if( forwardIds.contains(user.data[index]['user_id']+':p')){
                              forwardIds.remove(user.data[index]['user_id'].toString()+':p');
                              forwardname.remove(user.data[index]['name']);
                              forwardIndex.remove(index);
                            }
                            else{
                              forwardIds.add(user.data[index]['user_id']+':p');
                              forwardname.add(user.data[index]['name']);
                              forwardIndex.add(index);
                            }
                            print(forwardIds);
                            length = forwardIds.length;
                            setState(() {
                              
                            });
                            // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => NewConversation(rId: user.data[index]['user_id'],
                            //   toFcm: user.data[index]['deviceToken'],
                            // )));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(15)),
                                      child: CircleAvatar(
                                        backgroundImage: user.data[index]['profile_pic'] !=
                                            null
                                            ? NetworkImage(
                                            user.data[index]['profile_pic'])
                                            : const NetworkImage(
                                            'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png'),
                                      ),
                                    ),
                                  Positioned(
                                      right: 1,
                                      bottom: 1,
                                      child:forwardIds.contains(user.data[index]['user_id']+':p')? Container(
                                        decoration: const BoxDecoration(shape: BoxShape.circle,color: Colors.green),
                                        child: const Icon(Icons.check,size: 17,color: Colors.white,))
                                        :const SizedBox()
                                        )
                                  ],
                                ),
                                const SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayName ?? user.data[index]['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                        
                                    Container(
                                      padding: const EdgeInsets.only(right: 0.0),
                                      width: MediaQuery.of(context).size.width - 140,
                                      child: Text(
                                        user.data[index]['about'],
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                        style: const TextStyle(
                                          color:  Color(0xFF9B9898)
                                          ,
                                        ),
                                      ),
                                    ),
                        
                                  ],
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Divider(),
                        ),
                      ],
                    );
                    }
                    else{
                      return const SizedBox();
                    }
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: forwardIds.isNotEmpty? BottomAppBar(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 70,
              child:Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width/1.3 ,
                      child: Text(forwardname.join(','),overflow: TextOverflow.ellipsis,),
                    ),
                    IconButton(
                      color: Colors.green,
                      onPressed: (){
                      //socketOperation();
                      var auth = Provider.of<AuthProvider>(context, listen: false);
                         var body = {
                    'sid': auth.userId,
                    'to_users': forwardIds.join(',').toString(),
                    'message_ids': widget.messageId.join(',').toString(),
                    };
                  print(body);
                 // var status;
                  if(_socket.connected){
                     print('socket if1');
                     _socket.emit('forward_message',body);
                  // _socket.on('forward_message', (data) {
                  //   print('socket if , on');
                  //    print('data------$data');
                  //     if(data['status'].toString()=='true'){
                  //     }
                  // });
                  _socket.on('forward_message', (data) {
                    print("SSSSSSSSSSSSSSSSSSSSSSSSsss");
                    print(data);
                     print('data------$data');
                       if(data['status']==true){
                       }
                    print("SSSSSSSSSSSSSSSSSSSSSSSSsss");
                  });
                  print('socket if2');
                  }
                  else{
                    print('socket else1');
                   _connectSocket();
                    print('socket else2');
                    _socket.emit('forward_message',body);
                     _socket.on('forward_message', (data) {
                      print('data------$data');
                       if(data['status']==true){
                        
                       }
                      
                     } );
                      print('socket else3');
                   
                  }
                  if (forwardIds.length == 1) {
  print('if condition');
  if (groupIndex.length == 1) {
    int Index = groupIndex[0];
    print(Index);
    String rId = forwardIds[0].toString().substring(0, forwardIds[0].toString().length - 2);
    print(rId);
    
    Navigator.pop(context,'Refresh');
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => GroupConversationScreen(gId: rId)),
    // );
  } else {
    int Index = forwardIndex[0];
    print(Index);
    String rId = forwardIds[0].toString().substring(0, forwardIds[0].toString().length - 2);
    print(rId);
    print(user.data[Index]['deviceToken'].toString());
    Navigator.pop(context,'Refresh');
  
  //  _destroySocket();
    
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => NewConversation(rId: rId, toFcm: user.data[Index]['deviceToken'].toString())),
  //   );
  }
} else {
  print('else condition');

 // _destroySocket();
  Navigator.pop(context,'Refresh');
}

                      }, 
                      icon: const Icon(Icons.send))
                  ],
                ),
              ) ,
            ),
          )
          :const SizedBox()
        );
      },
    );
  }
}