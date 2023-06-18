import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/topSection.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AccountProvider/privacy_provider.dart';
import 'package:smart_station/screens/home_screen/popup_screens/blocked_settings_screen.dart';

class BlockedContactsScreen extends StatefulWidget {
  const BlockedContactsScreen({Key? key}) : super(key: key);

  @override
  State<BlockedContactsScreen> createState() => _BlockedContactsScreenState();
}

class _BlockedContactsScreenState extends State<BlockedContactsScreen> {

  @override
  void initState() {
    super.initState();
    // Initialize values or perform any setup tasks here
    print('Initializing MyWidget');
    var privacy = Provider.of<PrivacyProvider>(context,listen: false);
    privacy.blockedUserList(context:context);

  }
  @override
  void dispose() {
    // Call your function here to dispose it
    // var privacy = Provider.of<PrivacyProvider>(context,listen: false);
    // privacy.data.clear();
    // super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<PrivacyProvider>(
        builder: (context, privacy, child) {
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
                  top: 40,
                  child: Row(
                    children: const [
                      BackButton(color: Colors.white),
                      Text(
                        'Blocked Contacts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 10,
                  child: Row(
                    children: [
                      IconButton(onPressed:() {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const BlockedSettingsScreen()));
                      }, icon: const Icon(Icons.person_add_sharp,color: Colors.white,)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top:90.0),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left:30.0,top:10,bottom: 20),
                          child: Text(
                            'Contacts',
                            style: TextStyle(
                              fontSize: 14, // Set the font size to 18
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),),
                      ),


                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top:120.0),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    itemCount: privacy.data.length,
                    itemBuilder: (context, index) {
                      var client = http.Client();
                      Uri url = Uri.parse(privacy.data[index]['profile_pic']);

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
                                    backgroundImage: privacy.data[index]['profile_pic'] !=
                                        null
                                        ? NetworkImage(
                                        privacy.data[index]['profile_pic'])
                                        : const NetworkImage(
                                        'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png'),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                            side: const BorderSide(color: Colors.grey),
                                          ),
                                          actions: <Widget>[
                                            Container(
                                              width: MediaQuery.of(context).size.width - 50,
                                              height: 38.0,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5.0),
                                                // border: Border.all(color: Colors.blue),
                                              ),
                                              child: TextButton(
                                                child: Text(
                                                  'Unblock ' + privacy.data[index]['name'],
                                                  style: TextStyle(
                                                    color: Colors.grey[700],
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                onPressed: () {
                                                  privacy.unBlockUser(
                                                    name: privacy.data[index]['name'],
                                                    receiverId: privacy.data[index]['receiver_id'],
                                                    context: context,
                                                  );
                                                  Navigator.of(context).pop();
                                                },
                                              )
                                              ,
                                            ),
                                          ],
                                        );

                                      },
                                    );

                                    //privacy.unBlockUser(name: privacy.data[index]['name'], receiverId: privacy.data[index]['receiver_id'],context:context );
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        privacy.data[index]['name'],
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
                                          privacy.data[index]['about'],
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