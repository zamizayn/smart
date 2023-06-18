import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/UserProvider/user_provider.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../providers/AuthProvider/auth_provider.dart';
import '../../../utils/constants/urls.dart';
import 'api/common_api.dart';

class AddParticipants extends StatefulWidget {
  String grpId;
  final userIds;
  AddParticipants({Key? key, required this.grpId, this.userIds})
      : super(key: key);

  @override
  State<AddParticipants> createState() => _AddParticipantsState();
}

class _AddParticipantsState extends State<AddParticipants> {
  List _addMenber = [];
  List ids = [];
  bool searchSelected = false;
  TextEditingController _textSearchController = TextEditingController();

  final IO.Socket _socket = IO.io(AppUrls.appSocketUrl,
      IO.OptionBuilder().setTransports(['websocket']).build());

  _connectSocket() {
    _socket.connect();
    _socket.onConnect((data) => print('Connection established'));
    _socket.onConnectError((data) => print('Connect Error $data'));
    _socket.onDisconnect((data) => print('Socket.IO disconneted'));
  }

  _destroySocket() {
    _socket.disconnect();
  }

  @override
  void initState() {
    _connectSocket();
    super.initState();
  }

  @override
  void dispose() {
    _destroySocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var usp = Provider.of<UserProvider>(context, listen: false);
    var auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      floatingActionButton: _addMenber.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                _addMembers();
              },
              elevation: 0.0,
              backgroundColor: Colors.green,
              child: const Icon(Icons.arrow_forward),
            )
          : FloatingActionButton(
              onPressed: () {},
              elevation: 0.0,
              backgroundColor: const Color.fromARGB(0, 252, 253, 252),
              child: const Icon(Icons.arrow_forward),
            ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: searchSelected
            ? IconButton(
                onPressed: () {
                  setState(() {
                    searchSelected = false;
                    _textSearchController.clear();
                  });
                  print(searchSelected);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ))
            : const BackButton(color: Colors.black),
        title: searchSelected
            ? Container(
                width: MediaQuery.of(context).size.width / 1.5,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 0),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _textSearchController,
                  onChanged: (value) {
                    setState(() {});
                    //search(value);
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
            : const Text('Add Participants',
                style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  searchSelected = true;
                });
              },
              icon: const Icon(
                Icons.search,
                color: Colors.black,
              ))
        ],
      ),
      body: Column(
        children: [
          if (_addMenber.isNotEmpty)
            SizedBox(
                height: 105,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _addMenber.length,
                  itemBuilder: (context, index) {
                    print(_addMenber[index]);


                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InkWell(
                        onTap: () {
                          _removeUser(index);
                          print(_addMenber[index]);
                        },
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Stack(
                                  children: [
                                    /* CircleAvatar(
                                        maxRadius: 25,
                                        backgroundImage: NetworkImage(
                                            _addMenber[index]['profile_pic'])
                                        /*isValidLink(url) == false ? NetworkImage(user.data[index]['profile_pic'])
                                            : NetworkImage("https://cdn.pixabay.com/photo/2019/08/11/18/59/icon-4399701_1280.png")*/
                                        ),*/
                                    Container(
                                      width: 60,
                                      height: 60,
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: CircleAvatar(
                                        backgroundImage: _addMenber[index]
                                                    .profilePic !=
                                                null
                                            ? NetworkImage(
                                                _addMenber[index].profilePic)
                                            : const NetworkImage(
                                                'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png'),
                                      ),
                                    ),
                                    Positioned(
                                        right: 1,
                                        bottom: 1,
                                        child: InkWell(
                                          onTap: () {},
                                          child: Container(
                                            padding: const EdgeInsets.all(1),
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.grey),
                                            child: const Center(
                                                child: Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 17,
                                            )),
                                          ),
                                        ))
                                  ],
                                ),
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    _addMenber[index].name,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                    );
                  },
                )),
          Expanded(
            child: FutureBuilder(
              future: getUsersList(auth.userId, auth.accessToken),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.data.length,
                    itemBuilder: (context, index) {
                      snapshot.data!.data[index].isAdd = false;


                      for (var element in _addMenber) {
                        if (snapshot.data!.data[index].userId ==
                            element.userId) {
                          snapshot.data!.data[index].isAdd = true;
                        }
                      }
                      if (snapshot.data!.data[index].name
                          .toLowerCase()
                          .contains(_textSearchController.text.toLowerCase())) {
                        if (widget.userIds
                            .contains(snapshot.data!.data[index].userId)) {
                          return Container(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(15)),
                                  child: CircleAvatar(
                                    backgroundImage: snapshot
                                                .data!.data[index].profilePic !=
                                            null
                                        ? NetworkImage(snapshot
                                            .data!.data[index].profilePic)
                                        : const NetworkImage(
                                            'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png'),
                                  ),
                                ),
                                snapshot.data!.data[index].isAdd
                                    ? Container(
                                        padding: const EdgeInsets.all(1),
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.green),
                                        child: const Center(
                                            child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 17,
                                        )),
                                      )
                                    : Container(),
                                const SizedBox(width: 10),
                                //const SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      snapshot.data!.data[index].name,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      padding:
                                          const EdgeInsets.only(right: 0.0),
                                      width: MediaQuery.of(context).size.width -
                                          140,
                                      child: const Text(
                                        'Already added to the group',
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Color(0xFF9B9898),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                /*Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              //Text(dateTime.toString().substring(0,10)),
                              Text(formattedDate,
                                  style: TextStyle(fontSize: 12)),
                              if (recent.recentChat[index]['unread_message'] !=
                                  "0")
                                Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: rightGreen,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      recent.recentChat[index]
                                      ['unread_message'],
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                  ),
                                )
                            ],
                            )*/
                              ],
                            ),
                          );
                        } else {
                          return Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: InkWell(
                                  onTap: () {
                                    _addUser(snapshot.data!.data[index]);
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: CircleAvatar(
                                          backgroundImage: snapshot.data!
                                                      .data[index].profilePic !=
                                                  null
                                              ? NetworkImage(snapshot
                                                  .data!.data[index].profilePic)
                                              : const NetworkImage(
                                                  'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png'),
                                        ),
                                      ),
                                      snapshot.data!.data[index].isAdd
                                          ? Container(
                                              padding: const EdgeInsets.all(1),
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.green),
                                              child: const Center(
                                                  child: Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 17,
                                              )),
                                            )
                                          : Container(),
                                      const SizedBox(width: 10),
                                      //const SizedBox(width: 15),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            snapshot.data!.data[index].name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Container(
                                            padding: const EdgeInsets.only(
                                                right: 0.0),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                140,
                                            child: Text(
                                              snapshot.data!.data[index].about,
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: false,
                                              style: const TextStyle(
                                                color: Color(0xFF9B9898),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      /*Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                //Text(dateTime.toString().substring(0,10)),
                                Text(formattedDate,
                                    style: TextStyle(fontSize: 12)),
                                if (recent.recentChat[index]['unread_message'] !=
                                    "0")
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: rightGreen,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        recent.recentChat[index]
                                        ['unread_message'],
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                    ),
                                  )
                              ],
                            )*/
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
                      } else {
                        return Container();
                      }
                    },
                  );
                } else {
                  return const Scaffold(
                    body: Center(
                      child: SpinKitSpinningLines(color: Colors.green),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  _addMembers() {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    List data = [];
    for (var element in _addMenber) {
      print(element.userId);
      data.add(element.userId);
    }
    var joined = data.join(',');
    var body = {
      'user_id': auth.userId,
      'accessToken': auth.accessToken,
      'group_id': widget.grpId,
      'members': joined,
    };
    print(body);
    if (_socket.connected) {
      _socket.emit('add_group_member', body);
      _socket.on('add_group_member', (data) {
        print('======================[JOINED1]========================');
        print(data);
        Navigator.pop(context);
        // Navigator.of(context!).pushReplacement(
        //     MaterialPageRoute(builder: (context) => HomeScreen()));
      });
    } else {
      _connectSocket();
      _socket.emit('add_group_member', body);
      _socket.on('add_group_member', (data) {
        print('======================[JOINED2]========================');
        print(data);
        // Navigator.of(context!).pushReplacement(
        //     MaterialPageRoute(builder: (context) => HomeScreen()));
        Navigator.pop(context);
      });
    }
  }

  _addUser(data) {
    setState(() {
      // print('-------------');
      // print(ids);
      // ids.add(data);
      // print('-------------');
      // print(ids);
      // _addMenber = ids.toSet().toList();

      // ids = ids.where((item) => item.userId != data.userId).toList();

      // ids.add(data);
      // _addMenber = ids.toSet().toList();
       if(ids.any((item) => item.userId == data.userId)){
        print(true);
       ids = ids.where((item) => item.userId != data.userId).toList();
      }
      else{
      ids.add(data);
      }
      _addMenber = ids.toSet().toList();


      // _addMenber.add(data);
    });
  }

  _removeUser(index) {
    _addMenber = [];
    setState(() {
      // print(ids);
      ids.removeAt(index);
      _addMenber = ids.toSet().toList();
    });
  }
}
