import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/UserProvider/user_provider.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:smart_station/providers/CloudProvider/cloud_provider.dart';

class ContactList extends StatefulWidget {
  const ContactList({Key? key}) : super(key: key);

  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  final TextEditingController _textEditingController = TextEditingController();
  // List<dynamic> userData = [];
  @override
  void initState() {
    super.initState();
    // Initialize values or perform any setup tasks here
    print('Initializing MyWidget');
    var user = Provider.of<UserProvider>(context, listen: false);
    user.userList(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, 'refresh');
        return Future.value(false);
      },
      child: Consumer<UserProvider>(
        builder: (context, user, child) {
          // final data = jsonDecode(user.resMessage);
          // userData = user.data;

          search(String val) {
            if (val.isEmpty) {
              user.userList(context: context);
            } else {
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
                    Container(
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
                          InkWell(
                            onTap: () {
                              var cloud = Provider.of<CloudProvider>(context,
                                  listen: false);
                              cloud.createCloudParentFolder(
                                  user.data[index]['user_id'], context);
                              print('sss');
                              print(cloud.completeStatus);
                              final result = cloud.resMessage[0];
                              print(result);
                              print('lllll');
                              //if(cloud.completeStatus==false)
                              // {
                              Navigator.pop(context, 'refresh');
                              // }
                            },
                            child: Column(
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
                                  width:
                                      MediaQuery.of(context).size.width - 140,
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
      ),
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
