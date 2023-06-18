import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/UserProvider/user_provider.dart';
import 'package:smart_station/screens/home_screen/chat/newConvoScreen.dart';
import 'package:smart_station/utils/constants/app_constants.dart';

class UserList extends StatefulWidget {
  const UserList({
    Key? key,
  }) : super(key: key);

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  final TextEditingController _textEditingController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // _checkPermission().then(
    //        (hasGranted) {
    //      if (hasGranted == PermissionStatus.granted) {
    //      print("granted");
    //      }
    //      else{
    //
    //        print(Permission.contacts.status.toString());
    //        Permission.contacts.request();
    //      }
    //    },
    //  );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, user, child) {
        // final data = jsonDecode(user.resMessage);
        // userData = user.data;

        search(String val) {
          if (val.isEmpty) {
            user.userList(context: context);
          } else {
            final fnd = user.data.where((element) {
              final name = element['name'].toString().toLowerCase();
              final phone = element['phone'].toString().toLowerCase();
              final input = val.toLowerCase();
              return (name.contains(input) || phone.contains(input));
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
            title: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
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
            ),
            leading: BackButton(color: rightGreen),
          ),
          body: ListView.builder(
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
                  if (user.data[index]['phone'].replaceAll(' ', '') ==
                      phone.value!.replaceAll(' ', '')) {
                    displayName = element.displayName;
                    user.data[index]['name'] = element.displayName;
                  }
                });
              }

              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      print(user.data[index]);
                      Navigator.of(context)
                          .pushReplacement(MaterialPageRoute(
                              builder: (_) => NewConversation(
                                    rId: user.data[index]['user_id'],
                                    toFcm: user.data[index]['deviceToken'],
                                    roomId: user.data[index]['room'].toString(),
                                  )))
                          .then((value) {
                        user.clearData();
                      });
                    },
                    child: Container(
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
                              backgroundImage: user.data[index]
                                          ['profile_pic'] !=
                                      null
                                  ? NetworkImage(
                                      user.data[index]['profile_pic'])
                                  : const NetworkImage(
                                      'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png'),
                            ),
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
                                    color: Color(0xFF9B9898),
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
            },
          ),
        );
      },
    );
  }

  Future<bool> isValidLink(Uri url) async {
    http.Response response = await http.head(url);
    if (response.statusCode == 404) {
      print('False');
      return false;
    } else {
      print('True');
      return true;
    }
  }
}
