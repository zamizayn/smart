
import 'package:flutter/material.dart';
import 'package:smart_station/providers/AccountProvider/privacy_provider.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/topSection.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/screens/home_screen/popup_screens/contact_except_settings_screen.dart';


class LastSeenSettingsScreen extends StatefulWidget {

  int lastseen;
  int online;
  LastSeenSettingsScreen({Key? key,required this.lastseen,required this.online}) : super(key: key);

  //const LastSeenSettingsScreen({Key? key}) : super(key: key);

  @override
  State<LastSeenSettingsScreen> createState() => _LastSeenSettingsScreenState();
}

class _LastSeenSettingsScreenState extends State<LastSeenSettingsScreen> {
  int _selectedValue = 0;
  int _onlineSelectedValue = 0;

  @override
  void initState() {
    // TODO: implement initState
    print('fd');

    super.initState();

    var privacy = Provider.of<PrivacyProvider>(context, listen: false);
    privacy.getPrivacyDetails(context);
    privacy.getExceptedUsersLastseen(context);
  }

  @override
  Widget build(BuildContext context) {

    var privacy = Provider.of<PrivacyProvider>(context, listen: false);
    setState(() {
      _selectedValue = privacy.lastseenStatus;
      _onlineSelectedValue = privacy.onlineStatus;
    });



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
                        'Last seen and online',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
              padding: const EdgeInsets.only(top:120.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                        padding: const EdgeInsets.only(left:30.0,top:10,bottom: 20),
                        child: Text(
                          'Who can see my last seen',
                          style: TextStyle(
                            fontSize: 15, // Set the font size to 18
                            color: Colors.grey[600], // Set the color to black
                            fontWeight: FontWeight.bold,
                          ),
                        ),),
                  ),
                  RadioListTile(
                    value: 0,
                    groupValue: privacy.lastseenStatus,
                    onChanged: (value) {
                      setState(() {
                        _selectedValue = value!;
                      });
                      privacy.setLastseenStatus(value!, '','', context);
                    },
                    activeColor: rightGreen,
                    title: const Text('Everyone'),
                  ),
                  RadioListTile(
                    value: 1,
                    groupValue: privacy.lastseenStatus,
                    onChanged: (value) {
                      setState(() {
                        _selectedValue = value!;
                      });
                      privacy.setLastseenStatus(value!, '','', context);
                    },
                    activeColor: rightGreen,
                    title: const Text('My contacts'),
                  ),
                  RadioListTile(
                    value: 2,
                    toggleable: true,
                    groupValue: privacy.lastseenStatus,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedValue = value;
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ContactExceptSettingsScreen(type: 'lastseen',)));
                        });
                      }
                      else{
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ContactExceptSettingsScreen(type: 'lastseen',)));
                      }

                    },
                    activeColor: rightGreen,
                    title: const Text('My contacts except...'),
                  ),
                /*  RadioListTile(
                    value: 2,
                    groupValue: privacy.lastseenStatus,
                    onChanged: (value) {
                      setState(() {
                        _selectedValue = value!;
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ContactExceptSettingsScreen(type: "lastseen",)));
                      });
                    //  privacy.setLastseenStatus(value!, "", context);
                    },
                    activeColor: rightGreen,
                    title: Text('My contacts except...'),
                  ),*/
                  RadioListTile(
                    value: 3,
                    groupValue: privacy.lastseenStatus,
                    onChanged: (value) {
                      setState(() {
                        _selectedValue = value!;
                      });
                      privacy.setLastseenStatus(value!, '','', context);
                    },
                    activeColor: rightGreen,
                    title: const Text('Nobody'),
                  ),
                  const Divider(),
                ],
              ),
            ),

                Padding(
                  padding: const EdgeInsets.only(top:380.0),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left:30.0,top:40,bottom: 20),
                          child: Text(
                            'Who can see when I\'m online',
                            style: TextStyle(
                              fontSize: 15, // Set the font size to 18
                              color: Colors.grey[600],
                             fontWeight: FontWeight.bold,// Set the color to black
                            ),
                          ),),
                      ),
                      RadioListTile(
                        value: 0,
                        groupValue: privacy.onlineStatus,
                        onChanged: (value) {
                          setState(() {
                            _onlineSelectedValue = value!;
                          });
                          privacy.setOnlineStatus(value!, '', context);
                        },
                        activeColor: rightGreen,
                        title: const Text('Everyone'),
                      ),
                      RadioListTile(
                        value: 1,
                        groupValue: privacy.onlineStatus,
                        onChanged: (value) {
                          setState(() {
                            _onlineSelectedValue = value!;
                          });
                          privacy.setOnlineStatus(value!, '', context);
                        },
                        activeColor: rightGreen,
                        title: const Text('Same as last seen'),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left:30.0,top:20),
                          child:
                          Text.rich(
                            TextSpan(
                              text: "If you don't share your ",
                              style: TextStyle(
                                fontSize: 14,
                                //fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                              children: const [
                                TextSpan(
                                  text: 'last seen ',
                                  style: TextStyle(
                                   // fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.grey,
                                  ),
                                ),
                                TextSpan(
                                  text: 'and ',
                                ),
                                TextSpan(
                                  text: 'online',
                                  style: TextStyle(
                                    //fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.grey,
                                  ),
                                ),
                                TextSpan(
                                  text: ", you won't be able to see other peoples last seen and online. ",
                                ),
                              ],
                            ),
                            textAlign: TextAlign.left,
                          ),
                          // Text(
                          //   'If you don\'t share your last seen and online, you won\'t be able to see other peoples last seen and online.',
                          //   style: TextStyle(
                          //     fontSize: 16, // Set the font size to 18
                          //     color: Colors.grey[600], // Set the color to black
                          //   ),
                          // ),
                        ),
                      ),

                    ],
                  ),
                ),

              ],
            ),
          );
        }
    );
  }
}