
import 'package:flutter/material.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/topSection.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AccountProvider/privacy_provider.dart';
import 'package:smart_station/screens/home_screen/popup_screens/contact_except_settings_screen.dart';


class GroupSettingsScreen extends StatefulWidget {
  const GroupSettingsScreen({Key? key}) : super(key: key);

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  int _selectedValue = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    var privacy = Provider.of<PrivacyProvider>(context, listen: false);
    privacy.getPrivacyDetails(context);
    privacy.getExceptedUsersGroup(context);
  }

  @override
  Widget build(BuildContext context) {

    var privacy = Provider.of<PrivacyProvider>(context, listen: false);
    setState(() {
      _selectedValue = privacy.groupStatus;
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
                        'Groups',
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
                  padding: const EdgeInsets.only(top:90.0,right: 20),
                  child: ListView(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left:30.0,top:10,bottom: 15),
                          child: Text(
                            'Who can add me to groups',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,// Set the font size to 18
                              color: Colors.grey[600], // Set the color to black
                            ),
                          ),),
                      ),
                      RadioListTile(
                        value: 0,
                        groupValue: privacy.groupStatus,
                        onChanged: (value) {
                          setState(() {
                            _selectedValue = value!;
                          });
                          privacy.setGroupStatus(value!, '','', context);
                        },
                        activeColor: rightGreen,
                        title: const Text('Everyone'),
                       // contentPadding: EdgeInsets.symmetric(vertical: 2.0),
                      ),
                      RadioListTile(
                        value: 1,
                        groupValue: privacy.groupStatus,
                        onChanged: (value) {
                          setState(() {
                            _selectedValue = value!;
                          });
                          privacy.setGroupStatus(value!, '', '',context);
                        },
                        activeColor: rightGreen,
                        title: const Text('My contacts'),
                       // contentPadding: EdgeInsets.symmetric(vertical: 2.0),
                      ),
                      RadioListTile(
                        value: 2,
                        toggleable: true,
                        groupValue: privacy.groupStatus,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedValue = value;
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ContactExceptSettingsScreen(type: 'group',)));
                            });
                          }
                          else{
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ContactExceptSettingsScreen(type: 'group',)));
                          }

                        },
                        activeColor: rightGreen,
                        title: const Text('My contacts except...'),
                      ),
                     /* RadioListTile(
                        toggleable: false,
                        value: 2,
                        groupValue: privacy.groupStatus,
                        onChanged: (value) {
                          setState(() {
                            _selectedValue = value!;
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ContactExceptSettingsScreen(type: "group",)),
                          );
                        },
                        activeColor: rightGreen,
                        title: Text('My contacts except...'),
                      ),*/

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left:30.0,top:15),
                          child: Text(
                            'Admins who can\'t add you to a group chat will have the option of inviting you privately instead.',
                            style: TextStyle(
                              fontSize: 14, // Set the font size to 18
                              color: Colors.grey[700], // Set the color to black
                            ),
                          ),),
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