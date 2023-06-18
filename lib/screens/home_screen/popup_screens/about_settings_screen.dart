
import 'package:flutter/material.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/topSection.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AccountProvider/privacy_provider.dart';
import 'package:smart_station/screens/home_screen/popup_screens/contact_except_settings_screen.dart';


class AboutSettingsScreen extends StatefulWidget {
  const AboutSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AboutSettingsScreen> createState() => _AboutSettingsScreenState();
}

class _AboutSettingsScreenState extends State<AboutSettingsScreen> {
  int _selectedValue = 0;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    var privacy = Provider.of<PrivacyProvider>(context, listen: false);
    privacy.getPrivacyDetails(context);
    privacy.getExceptedUsersAbout(context);
  }

  @override
  Widget build(BuildContext context) {
   var privacy = Provider.of<PrivacyProvider>(context, listen: false);
   setState(() {
     _selectedValue = privacy.aboutStatus;
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
                        'About',
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
                            'Who can see my About',
                            style: TextStyle(
                              fontSize: 14, // Set the font size to 18
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),),
                      ),
                      RadioListTile(
                        value: 0,
                        groupValue: privacy.aboutStatus,
                        onChanged: (value) {
                          setState(() {
                            _selectedValue = value!;
                          });
                          privacy.setAboutStatus(value!, '', '',context);
                        },
                        activeColor: rightGreen,
                        title: const Text('Everyone'),
                      ),
                      RadioListTile(
                        value: 1,
                        groupValue: privacy.aboutStatus,
                        onChanged: (value) {
                          setState(() {
                            _selectedValue = value!;
                          });
                          privacy.setAboutStatus(value!, '','' ,context);
                         // Navigator.push(context, MaterialPageRoute(builder: (_) => ContactExceptSettingsScreen(type: "about",)));
                        },
                        activeColor: rightGreen,
                        title: const Text('My contacts'),
                      ),
                      RadioListTile(
                        value: 2,
                        toggleable: true,
                        groupValue: privacy.aboutStatus,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedValue = value;
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ContactExceptSettingsScreen(type: 'about',)));
                            });
                          }
                          else{
                             Navigator.push(context, MaterialPageRoute(builder: (_) => ContactExceptSettingsScreen(type: 'about',)));
                          }

                        },
                        activeColor: rightGreen,
                        title: const Text('My contacts except...'),
                      ),
                      RadioListTile(
                        value: 3,
                        groupValue: privacy.aboutStatus,
                        onChanged: (value) {
                          setState(() {
                            _selectedValue = value!;
                          });
                          privacy.setAboutStatus(value!, '','' ,context);
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