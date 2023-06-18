
import 'package:flutter/material.dart';
import 'package:smart_station/providers/AccountProvider/privacy_provider.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/topSection.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/screens/home_screen/popup_screens/contact_except_settings_screen.dart';


class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  int _selectedValue = 0;
  @override
  void initState() {
    // TODO: implement initState
    print('fd');

    super.initState();

    var privacy = Provider.of<PrivacyProvider>(context, listen: false);
    privacy.getPrivacyDetails(context);
    privacy.getExceptedUsersProfile(context);
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
                        'Profile Photo',
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
                  padding: const EdgeInsets.only(top:90.0,bottom: 10),
                  child: ListView(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left:30.0,top:10),
                          child: Text(
                            'Who can see my Profile Photo',
                            style: TextStyle(
                              fontSize: 14, // Set the font size to 18
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold// Set the color to black
                            ),
                          ),),
                      ),
                     /* RadioListTile(
                        value: 0,
                        groupValue: _selectedValue,
                        onChanged: (value) {
                          setState(() {
                            _selectedValue = value!;
                          });
                        },
                        activeColor: rightGreen,
                        title: Text('Everyone'),
                      ),
                      RadioListTile(
                        value: 1,
                        groupValue: _selectedValue,
                        onChanged: (value) {
                          setState(() {
                            _selectedValue = value!;
                          });
                        },
                        activeColor: rightGreen,
                        title: Text('My contacts'),
                      ),
                      InkWell(
                        onTap: () {
                          print("sujina");
                          print('Context: $context');
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ContactExceptSettingsScreen(type: "profile",)),
                          );
                        },
                        child: RadioListTile(
                          toggleable: false,
                          value: 2,
                          groupValue: _selectedValue,
                          onChanged: (value) {
                            setState(() {
                                    _selectedValue = value!;
                                });
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ContactExceptSettingsScreen(type: "profile",)),
                            );
                          },
                          activeColor: rightGreen,
                          title: Text('My contacts except...'),
                        ),
                      ),
                      RadioListTile(
                        value: 3,
                        groupValue: _selectedValue,
                        onChanged: (value) {
                          setState(() {
                            _selectedValue = value!;
                          });
                        },
                        activeColor: rightGreen,
                        title: Text('Nobody'),
                      ),*/
                      RadioListTile(
                        value: 0,
                        groupValue: privacy.profileStatus,
                        onChanged: (value) {
                          setState(() {
                            _selectedValue = value!;
                          });
                          privacy.setProfileStatus(value!, '','', context);
                        },
                        activeColor: rightGreen,
                        title: const Text('Everyone'),
                      ),
                      RadioListTile(
                        value: 1,
                        groupValue: privacy.profileStatus,
                        onChanged: (value) {
                          setState(() {
                            _selectedValue = value!;
                          });
                          privacy.setProfileStatus(value!, '','', context);
                        },
                        activeColor: rightGreen,
                        title: const Text('My contacts'),
                      ),
                      RadioListTile(
                        value: 2,
                        toggleable: true,
                        groupValue: privacy.profileStatus,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedValue = value;
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ContactExceptSettingsScreen(type: 'profile',)));
                            });
                          }
                          else{

                              Navigator.push(context, MaterialPageRoute(builder: (_) => ContactExceptSettingsScreen(type: 'profile',)));

                          }

                        },
                        activeColor: rightGreen,
                        title: const Text('My contacts except...'),
                      ),
                      /*Material(
                        child: InkWell(
                          onTap: (){
                            print("hiiii");
                          },
                          child: Container(
                            child: RadioListTile(
                              value: 2,
                              groupValue: privacy.profileStatus,
                              onChanged: (value) async {
                                setState(() {
                                  _selectedValue = value!;
                                });
                                if (value == 2) {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => ContactExceptSettingsScreen(type: "profile",)));
                                } else {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => ContactExceptSettingsScreen(type: "profile",)));
                                }
                              },
                              activeColor: rightGreen,
                              title: Text('My contacts except...'),
                            ),
                          ),
                        ),
                      ),*/
                     /* CustomRadioListTile(
                        value: 2,
                        groupValue: privacy.profileStatus,
                        onChanged: (value) async {
                          setState(() {
                            _selectedValue = value!;
                          });
                          if (value == 2) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ContactExceptSettingsScreen(type: "profile",)));
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ContactExceptSettingsScreen(type: "profile",)));
                          }
                        },
                        activeColor: rightGreen,
                        title: 'My contacts except...',
                        onTap: () {
                          print('CustomRadioListTile tapped');
                        },
                      ),
*/

                      RadioListTile(
                        value: 3,
                        groupValue: privacy.profileStatus,
                        onChanged: (value) {
                          setState(() {
                            _selectedValue = value!;
                          });
                          privacy.setProfileStatus(value!, '','', context);
                        },
                        activeColor: rightGreen,
                        title: const Text('Nobody'),
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

class CustomRadioListTile extends StatelessWidget {
  final int value;
  final int groupValue;
  final Function(int?) onChanged;
  final Color activeColor;
  final String title;
  final VoidCallback onTap;

  const CustomRadioListTile({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.activeColor,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: RadioListTile(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
          activeColor: activeColor,
          title: Text(title),
        ),
      ),
    );
  }
}
