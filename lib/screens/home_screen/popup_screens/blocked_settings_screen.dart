import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:smart_station/providers/AccountProvider/privacy_provider.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/topSection.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/providers/UserProvider/user_provider.dart';

class BlockedSettingsScreen extends StatefulWidget {
  const BlockedSettingsScreen({Key? key}) : super(key: key);

  @override
  State<BlockedSettingsScreen> createState() => _BlockedSettingsScreenState();
}

class _BlockedSettingsScreenState extends State<BlockedSettingsScreen> {
  final TextEditingController _textEditingController = TextEditingController();

  var searchStatus = false;

  @override
  void initState() {
    super.initState();
    // Initialize values or perform any setup tasks here
    print('Initializing MyWidget');
    var user = Provider.of<UserProvider>(context,listen: false);
    user.unblockedUserList(context:context);

  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    var user = Provider.of<UserProvider>(context, listen: false);


    return Consumer2<UserProvider,PrivacyProvider>(
        builder: (context, user,privacy, child) {
          search(String val) {
            if (val.isEmpty) {
              user.unblockedUserList(context:context);
            }
            else{
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
            body: Stack(
              clipBehavior: Clip.none,
              children: [
                const TopSection(),
                Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(splashBg), fit: BoxFit.fill)),
                ),
                Positioned(
                  top: 22,

                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(top:15.0),
                        child: BackButton(color: Colors.white),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left:13.0),
                        child: Text(
                          'Select contact',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  top: 65,
                  left: 60,
                  child: Row(
                    children: [

                      Text(
                        '${user.data.length} contacts',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
                (searchStatus==true)?
                Positioned(
                  top: 40,
                  left: 50,
                  right: 40,
                  child: SizedBox(
                    // key: UniqueKey(),
                    height: 40,
                    // width: double.infinity,
                    child: Center(
                        child:
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.grey[200],
                          ),
                          child: TextField(
                            controller: _textEditingController,
                            onChanged: (value) {
                              search(value);
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search...',
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                              // prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        )

                    ),
                  ),
                ):const SizedBox(width: 0,),
                Positioned(
                  top: 38,
                  //left:0,
                  right: 0,
                  child: (searchStatus==false)?
                  IconButton(
                    iconSize: 25,
                    icon: const Icon(Icons.search,color: Colors.white,),
                    onPressed: () {
                      // ...
                      setState(() {
                        searchStatus=true;
                        _textEditingController.text='';
                      });

                    },
                  ):
                  IconButton(
                    iconSize: 25,
                    icon: const Icon(Icons.close,color: Colors.white,),
                    onPressed: () {
                      setState(() {
                        searchStatus=false;

                        search('');
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top:90.0),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    itemCount: user.data.length,
                    itemBuilder: (context, index) {
                      var client = http.Client();
                      Uri url = Uri.parse(user.data[index]['profile_pic']);

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
                                    backgroundImage: user.data[index]['profile_pic'] !=
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
                                    privacy.blockUser(name: user.data[index]['name'], receiverId: user.data[index]['user_id'],context:context );
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.data[index]['name'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[700],
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
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.symmetric(horizontal: 12),
                          //   child: Divider(),
                          // ),
                        ],
                      );

                    },
                  ),
                ),

              ],
            ),
          );
        }
    );
  }
}