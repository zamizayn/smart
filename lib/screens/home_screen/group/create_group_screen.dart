import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/topSection.dart';
import 'package:smart_station/screens/home_screen/group/create_group_screen2.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:smart_station/providers/UserProvider/user_provider.dart';

import '../../../providers/AuthProvider/auth_provider.dart';
import '../chat/api/common_api.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../utils/constants/urls.dart';

class CreateGroupScreen extends StatefulWidget {
  final userId;
  final name;
  final profile;
  const CreateGroupScreen({Key? key,this.userId,this.name,this.profile}) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  List _addMenber = [];
  List ids = [];
  List<Contact> contacts = [];
  bool searchSelected = false;
  TextEditingController _textSearchController = TextEditingController();
  List list = [
    {'id': '1', 'name': 'Kiran', 'age': '29'},
    {'id': '1', 'name': 'Kiran', 'age': '29'},
    {'id': '1', 'name': 'Kiran', 'age': '29'},
  ];
  final IO.Socket _socket = IO.io(AppUrls.appSocketUrl,
      IO.OptionBuilder().setTransports(['websocket']).build());
       void getContactPermossion() async {
    if (await Permission.contacts.isGranted) {
      ///***************[Fetch Contacts]**************
      fetchContacts();
    } else {
      ///***************[Request Permission]**************
      await Permission.contacts.request();
    }
  }

  /// ****************[Get Phone Contacts]********************
  void fetchContacts() async {
    contacts = await ContactsService.getContacts();
    setState(() {
      // isLoading = false;
    });
  }

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
    getContactPermossion();
    // TODO: implement initState
    super.initState();
     WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        _addMenber = ids.toSet().toList();
      });
    });
  }
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, user, child) {
        // final data = jsonDecode(user.resMessage);
        // userData = user.data;

        search(String val) {
          final fnd = user.data.where((element) {
            final name = element['name'].toString().toLowerCase();
            final input = val.toLowerCase();
            return name.contains(input);
          }).toList();
          // print(found);
          print('::::::[NAME]::::::');
          print(fnd);
          print('::::::[NAME]::::::');

          setState(() {
            user.getActualData(fnd);
          });
        }

        var auth = Provider.of<AuthProvider>(context, listen: false);

        return Scaffold(
          /*  appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Text(
              "New group",
              style: TextStyle(color: Colors.black),
            ),
            leading: BackButton(color: rightGreen),
          ),*/
          body: Column(
            children: [
              // ListView.builder(itemBuilder: itemBuilder),
              Stack(children: [
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: Container(
                    height: 120,
                    color: Colors.black38,
                  ),
                ),
                const TopSection2(),
                searchSelected
                    ? Positioned(
                        top: 50,
                        left: 0,
                        right: 20,
                        child: Row(
                          children: [
                            // BackButton(color: Colors.white),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    searchSelected = false;
                                    _textSearchController.clear();
                                  });
                                  print(searchSelected);
                                },
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                )),
                            Container(
                              width: MediaQuery.of(context).size.width / 1.5,
                              alignment: Alignment.centerLeft,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 0),
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
                            ),
                          ],
                        ),
                      )
                    : Positioned(
                        top: 50,
                        left: 0,
                        right: 20,
                        child: Row(
                          children: const [
                            BackButton(color: Colors.white),
                            Text(
                              'New Group',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                Positioned(
                    top: 50,
                    //left: 0,
                    right: 0,
                    child: IconButton(
                        onPressed: () {
                          setState(() {
                            searchSelected = true;
                          });
                        },
                        icon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ))),
              ]),
              Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(splashBg), fit: BoxFit.fill)),
              ),
             
              _addMenber.isNotEmpty
                  ? SizedBox(
                      height: 105,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _addMenber.length,
                        itemBuilder: (context, index) {
                          var client = http.Client();
                          Uri url = Uri.parse(_addMenber[index].profilePic);
                          if(_addMenber[index].userId == widget.userId){
                            return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
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
                                        backgroundImage: _addMenber[index]
                                                    .profilePic !=
                                                null
                                            ? NetworkImage(
                                                _addMenber[index]
                                                    .profilePic)
                                            : const NetworkImage(
                                                'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png'),
                                      ),
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
                          );
                          }
                           else{
                            return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: InkWell(
                              onTap: () {
                                _removeUser(index);
                                // _addUser(user.data[index]);
                              },
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                                      _addMenber[index]
                                                          .profilePic)
                                                  : const NetworkImage(
                                                      'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png'),
                                            ),
                                          ),
                                          Positioned(
                                             right: 1,
                                                bottom: 1,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(1),
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
                                          )
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
                          }
                        },
                      ))
                  :  widget.userId!=null?
                 Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
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
                                        backgroundImage:widget.profile !=
                                                null
                                            ? NetworkImage(
                                                widget.profile)
                                            : const NetworkImage(
                                                'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png'),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 60,
                                      child: Text(
                                        widget.name,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(width: 10),
                              ],
                            ),
                          )
                  :const SizedBox(),
              Expanded(
                  child: FutureBuilder(
                      future: getUsersList(auth.userId, auth.accessToken),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: snapshot.data!.data.length,
                            itemBuilder: (context, index) {
                              snapshot.data!.data[index].isAdd = false;
                              for (var element in _addMenber) {
                                if (snapshot.data!.data[index].userId ==
                                    element.userId) {
                                  snapshot.data!.data[index].isAdd = true;
                                }
                              }
                              String? displayName;
          for (var element in contacts) {
            element.phones?.forEach((phone) {
              if (snapshot.data!.data[index].phone.replaceAll(' ', '') ==
                  phone.value!.replaceAll(' ', '')) {
                displayName = element.displayName;
                snapshot.data!.data[index].name = element.displayName!;
              }
            });
          }
                              // print('truuueeee');
                              // print(snapshot.data!.data[index].isAdd);

                              var client = http.Client();
                              Uri url = Uri.parse(
                                  snapshot.data!.data[index].profilePic);
                                  print('userid=========${widget.userId}');
                              if (snapshot.data!.data[index].name
                                  .toLowerCase()
                                  .contains(_textSearchController.text
                                      .toString()
                                      .toLowerCase())) {
                                        if(snapshot.data!.data[index].userId == widget.userId){
                                           if(ids.any((item) => item.userId ==snapshot.data!.data[index].userId )){
       
                                            }
                                          else{
                                            ids.add(snapshot.data!.data[index]);
                                            }
                                          _addMenber = ids.toSet().toList();
                                          return Container();
                                        } 
                                        else{
                                          return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 10),
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
                                            backgroundImage: snapshot
                                                        .data!
                                                        .data[index]
                                                        .profilePic !=
                                                    null
                                                ? NetworkImage(snapshot.data!
                                                    .data[index].profilePic)
                                                : const NetworkImage(
                                                    'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png'),
                                          ),
                                        ),
                                        snapshot.data!.data[index].isAdd
                                            ? Container(
                                              padding:
                                                  const EdgeInsets.all(1),
                                              decoration:
                                                  const BoxDecoration(
                                                      shape:
                                                          BoxShape.circle,
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
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              displayName?? snapshot.data!.data[index].name,
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
                                                snapshot
                                                    .data!.data[index].about,
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: false,
                                                style: const TextStyle(
                                                  color: Color(0xFF9B9898),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
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
                      })),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.green,
            onPressed: () {
              if(_addMenber.length>0){
                 _destroySocket();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          CreateGroupScreen2(memberData: _addMenber)));

              }else{
                  showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('At Least 1 contact must be selected'),
              actions: <Widget>[
                TextButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
              }
             
            },
            child: const Icon(
              Icons.arrow_forward,
              size: 35,
            ),
          ),
        );
      },
    );
  }

  _addUser(data) {
    setState(() {
      //ids = ids.where((item) => item.userId != data.userId).toList();
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
      // List id=ids.toList();
      ids.removeAt(index);
      _addMenber = ids.toSet().toList();
    });
  }
}
