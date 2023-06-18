
import 'package:flutter/material.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/bottomSection.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/topSection.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/providers/AccountProvider/account_provider.dart';
import 'package:smart_station/screens/home_screen/popup_screens/lastseen_settings_screen.dart';
import 'package:smart_station/screens/home_screen/popup_screens/about_settings_screen.dart';
import 'package:smart_station/screens/home_screen/popup_screens/profile_settings_screen.dart';
import 'package:smart_station/screens/home_screen/popup_screens/group_settings_screen.dart';
import 'package:smart_station/screens/home_screen/popup_screens/blocked_contact_screen.dart';
import 'package:smart_station/providers/AccountProvider/privacy_provider.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({Key? key}) : super(key: key);

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool isSwitched = false;
  bool _isStatusVisible = true;
  var profileStatus = '';
  var aboutStatus = '';
  var lastseenStatus = '';
  var onlineStatus = '';
  var groupStatus = '';
  var blockCount = '';
  @override
  void initState() {
    // TODO: implement initState
    print('fd');

    super.initState();

    var privacy = Provider.of<PrivacyProvider>(context, listen: false);
    privacy.getPrivacyDetails(context);
    setState(() {
      //OnlineStatus
      //   switch(privacy.onlineStatus) {
      //     case 0: {
      //       onlineStatus = ",Everyone";
      //     }
      //     break;
      //     case 1: {
      //       onlineStatus = "";
      //     }
      //     break;
      //     default: {
      //       //statements;
      //     }
      //     break;
      //   }
      //   //profileStatus
      //   switch(privacy.profileStatus) {
      //     case 0: {
      //       profileStatus = "Everyone";
      //     }
      //     break;
      //     case 1: {
      //       profileStatus = "Everyone";
      //     }
      //     break;
      //     case 2: {
      //       profileStatus = "1 contact excluded";
      //     }
      //     break;
      //     case 3: {
      //       profileStatus = "Nobody";
      //     }
      //     break;
      //     default: {
      //       //statements;
      //     }
      //     break;
      //   }
      //   //aboutStatus
      //   switch(privacy.aboutStatus) {
      //     case 0: {
      //       aboutStatus = "Everyone";
      //     }
      //     break;
      //     case 1: {
      //       aboutStatus = "My contacts";
      //     }
      //     break;
      //     case 2: {
      //       aboutStatus = "1 contact excluded";
      //     }
      //     break;
      //     case 3: {
      //       aboutStatus = "Nobody";
      //     }
      //     break;
      //     default: {
      //       //statements;
      //     }
      //     break;
      //   }
      //   //lastseenStatus
      //   switch(privacy.lastseenStatus) {
      //     case 0: {
      //       lastseenStatus = "Everyone";
      //       if(privacy.onlineStatus==0){
      //         onlineStatus="";
      //       }
      //     }
      //     break;
      //     case 1: {
      //       lastseenStatus = "My contacts";
      //     }
      //     break;
      //     case 2: {
      //       lastseenStatus = "1 contact excluded";
      //     }
      //     break;
      //     case 3: {
      //       lastseenStatus = "Nobody";
      //     }
      //     break;
      //     default: {
      //       //statements;
      //     }
      //     break;
      //   }
      //   //groupStatus
      //   switch(privacy.groupStatus) {
      //     case 0: {
      //       groupStatus = "Everyone";
      //     }
      //     break;
      //     case 1: {
      //       groupStatus = "My contacts";
      //     }
      //     break;
      //     case 2: {
      //       groupStatus = "1 contact excluded";
      //     }
      //     break;
      //     case 3: {
      //       groupStatus = "Nobody";
      //     }
      //     break;
      //     default: {
      //       //statements;
      //     }
      //     break;
      //   }
      // profileStatus = privacy.profileStatus;
      // aboutStatus = privacy.aboutStatus;
      // lastseenStatus = privacy.lastseenStatus;
      // groupStatus = privacy.groupStatus;

      _isStatusVisible = privacy.readStatus == '1' ? true : false;
      // groupStatus = "";
      //  blockCount = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    var privacy = Provider.of<PrivacyProvider>(context, listen: false);

    isSwitched = auth.publicStatus == '1' ? true : false;

    return Consumer2<AccountProvider,PrivacyProvider>(
        builder: (context, account,privacy, child) {
          _isStatusVisible = privacy.readStatus == '1' ? true : false;
          blockCount = privacy.blockCount;
//OnlineStatus
          switch(privacy.onlineStatus) {
            case 0: {
              onlineStatus = ' ,Everyone';
            }
            break;
            case 1: {
              onlineStatus = '';
            }
            break;
            default: {
              //statements;
            }
            break;
          }
          //profileStatus
          switch(privacy.profileStatus) {
            case 0: {
              profileStatus = 'Everyone';
            }
            break;
            case 1: {
              profileStatus = 'My contacts';
            }
            break;
            case 2: {
              profileStatus = privacy.profileStatusMessage;
            }
            break;
            case 3: {
              profileStatus = 'Nobody';
            }
            break;
            default: {
              //statements;
            }
            break;
          }
          //aboutStatus
          switch(privacy.aboutStatus) {
            case 0: {
              aboutStatus = 'Everyone';
            }
            break;
            case 1: {
              aboutStatus = 'My contacts';
            }
            break;
            case 2: {
              aboutStatus = privacy.aboutStatusMessage;
            }
            break;
            case 3: {
              aboutStatus = 'Nobody';
            }
            break;
            default: {
              //statements;
            }
            break;
          }
          //lastseenStatus
          print('privacy.lastseenStatus');
          print(privacy.lastseenStatus);
          switch(privacy.lastseenStatus) {
            case 0: {
              lastseenStatus = 'Everyone';
              if(privacy.onlineStatus==0){
                onlineStatus='';
              }
            }
            break;
            case 1: {
              lastseenStatus = 'My contacts';
            }
            break;
            case 2: {
              lastseenStatus = privacy.lastseenStatusMessage;
            }
            break;
            case 3: {
              lastseenStatus = 'Nobody';
            }
            break;
            default: {
              //statements;
            }
            break;
          }
          //groupStatus
          switch(privacy.groupStatus) {
            case 0: {
              groupStatus = 'Everyone';
            }
            break;
            case 1: {
              groupStatus = 'My contacts';
            }
            break;
            case 2: {
              groupStatus = privacy.groupStatusMessage;
            }
            break;
            case 3: {
              groupStatus = 'Nobody';
            }
            break;
            default: {
              //statements;
            }
            break;
          }
            blockCount = privacy.blockCount;
            _isStatusVisible = privacy.readStatus == '1' ? true : false;
            // groupStatus = "";
            //  blockCount = "";

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
                        'Privacy',
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
                  top: 90,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 1.07,
                      height: MediaQuery.of(context).size.height /1.1,
                      child: ListView(
                        children: [
                          Transform.scale(
                            scale: 1.08, // Set the scale factor to 1.5 (150%)
                            child: SwitchListTile(
                              title: Text('Show public',style: TextStyle(fontSize:15,fontWeight: FontWeight.bold,color: Colors.grey[600]),),
                              subtitle: const Text(''),
                              value: auth.publicStatus == '1' ? true : false,
                              onChanged: (value) {
                                setState(() {
                                 // isSwitched = value;
                                  account.changePrivacyStatus(auth.accessToken,auth.userId,value==true ? '1' : '0',context,);
                                });
                              },
                              activeColor: Colors.green, // Set the active color to green
                              dense: false, // Set the dense property to false to increase height
                            ),

                          ),
                          Padding(
                            padding: const EdgeInsets.only(top:0.0,bottom: 5),
                            child: Text(
                              'Note: If you don\'t share your status to public, nobody can see you in search contact.',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          const Divider(),

                          Padding(
                            padding: const EdgeInsets.only(top:10.0,bottom: 5),
                            child: Text(
                              'Who can see my personal info',
                              style: TextStyle(
                                fontSize: 15, // Set the font size to 18
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LastSeenSettingsScreen(lastseen:privacy.lastseenStatus,online: privacy.onlineStatus,))),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start, //
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left:0,top:30.0,bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Last seen and online'
                                        ,style: TextStyle(fontSize:16,fontWeight: FontWeight.bold,color: Colors.grey[600]),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top:0.0,bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      lastseenStatus+onlineStatus,
                                      style: TextStyle(
                                        fontSize: 15, // Set the font size to 18
                                        color: Colors.grey[600],
                                       // fontWeight: FontWeight.bold// Set the color to black
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10,),
                          InkWell(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileSettingsScreen())),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start, //
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left:0,top:30.0,bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Profile Photo',style: TextStyle(fontSize:16,fontWeight: FontWeight.bold,color: Colors.grey[600]),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top:0.0,bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                     profileStatus,
                                      style: TextStyle(
                                        fontSize: 15, // Set the font size to 18
                                        color: Colors.grey[600], // Set the color to black
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10,),
                          InkWell(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutSettingsScreen())),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start, //
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left:0,top:30.0,bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'About',style: TextStyle(fontSize:16,fontWeight: FontWeight.bold,color: Colors.grey[600]),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top:0.0,bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                     aboutStatus,
                                      style: TextStyle(
                                        fontSize: 15, // Set the font size to 18
                                        color: Colors.grey[600], // Set the color to black
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20,),
                          const Divider(),
                          Transform.scale(
                            scale: 1.08, // Set the scale factor to 1.5 (150%)
                            child: SwitchListTile(
                              title: Text('Read Receipts',style: TextStyle(fontSize:15,fontWeight: FontWeight.bold,color: Colors.grey[600])),
                              subtitle: const Text(''),
                              value: privacy.readStatus == '1' ? true : false,
                              onChanged: (value) {
                                setState(() {
                                   _isStatusVisible = value;
                                 // account.changePrivacyStatus(auth.accessToken,auth.userId,value==true ? "1" : "0",context,);
                                });
                                print('ffff');
                                privacy.setReadStatus(value==true ? '1' : '0', context);
                              },
                              activeColor: Colors.green, // Set the active color to green
                              dense: false, // Set the dense property to false to increase height
                            ),

                          ),
                          const Padding(
                            padding: EdgeInsets.only(top:0.0,bottom: 5),
                            child: Text(
                              'If turned off, you won\'t send or receive Read receipts. Read receipts are always sent for group chats.',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const Divider(),
                          InkWell(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupSettingsScreen())),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start, //
                              children: [
                              Padding(
                                padding: const EdgeInsets.only(left:0,top:10.0,bottom: 5),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Groups',style: TextStyle(fontSize:16,fontWeight: FontWeight.bold,color: Colors.grey[600]),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top:0.0,bottom: 5),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    groupStatus,
                                    style: TextStyle(
                                      fontSize: 15, // Set the font size to 18
                                      color: Colors.grey[600], // Set the color to black
                                    ),
                                  ),
                                ),
                              ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20,),
                          InkWell(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BlockedContactsScreen())),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start, //
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left:0,top:10.0,bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Blocked Contacts',style: TextStyle(fontSize:16,fontWeight: FontWeight.bold,color: Colors.grey[600]),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top:0.0,bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      blockCount,
                                      style: TextStyle(
                                        fontSize: 15, // Set the font size to 18
                                        color: Colors.grey[600], // Set the color to black
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: BottomSectionTransp(),
                          )
                          // Padding(
                          //   padding: const EdgeInsets.all(16.0),
                          //   child:
                          //   Container(
                          //     child: Column(
                          //       children: [
                          //         SizedBox(
                          //           width: 70,
                          //           child: Image(
                          //             image: AssetImage(greenLogo),
                          //           ),
                          //         ),
                          //         SizedBox(height: 8),
                          //         Text(
                          //           "Smart Station",
                          //           style: TextStyle(
                          //             fontSize: 20,
                          //             fontWeight: FontWeight.w500,
                          //             color: Colors.grey[600],
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // )
                        ],
                      ),
                    ),
                  ),
                ),

                // Positioned(
                // top: 180,
                // child: Padding(
                // padding: EdgeInsets.symmetric(horizontal: 25),
                // child: Container(
                // width: MediaQuery.of(context).size.width / 1.2,
                // height: MediaQuery.of(context).size.height / 3,
                // // color: Colors.red,
                // child: Column(
                // children: [
                // Row(
                // children: [
                //
                // SizedBox(width: 15),
                // Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                // children: [
                // Text(
                // "Show Public",
                // style: TextStyle(
                // fontSize: 20,
                // fontWeight: FontWeight.bold,
                // color: Colors.black54,
                // ),
                // ),
                // ],
                // ),
                // Spacer(),
                // Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                // children: [
                // Transform.scale( scale: 1.5,
                // child: Switch(
                // value: auth.publicStatus == "1" ? true : false,
                // onChanged: (value) {
                // setState(() {
                // account.changePrivacyStatus(auth.accessToken,auth.userId,value==true ? "1" : "0",context,);
                // // isSwitched = auth.publicStatus == "1" ? true : false;
                // });
                //
                // },
                // activeTrackColor: Colors.green,
                // activeColor: Colors.white,
                // ),
                // ),
                //
                // ],
                // ),
                // ],
                // ),
                // ],
                // ),
                // ),
                // ),
                // ),


              ],
            ),
          );
        }
    );
  }
}