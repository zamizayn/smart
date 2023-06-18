import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/providers/ProfileProvider/profile_provider.dart';
import 'package:smart_station/screens/home_screen/popup_screens/edit_profile.dart';
import 'package:smart_station/screens/home_screen/popup_screens/account_home.dart';
import 'package:smart_station/screens/home_screen/popup_screens/notification_screen.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/bottomSection.dart';
import 'package:smart_station/utils/constants/app_constants.dart';

class SettingsScreen extends StatefulWidget {
  BuildContext ctxt;

  SettingsScreen({Key? key, required this.ctxt}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  var p;
  var a;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     p = Provider.of<ProfileProvider>(widget.ctxt, listen: false);
     a = Provider.of<AuthProvider>(widget.ctxt, listen: false);
    p.getProfile(accessTok: a.accessToken, userId: a.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profile, child) {
        return Scaffold(
          body: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 150,
                width: double.infinity,
                color: Colors.black38,
              ),
              Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(splashBg), fit: BoxFit.fill)),
              ),
              Positioned(
                top: 30,
                left: 20,
                child: Row(
                  children: const [
                    BackButton(color: Colors.white),
                    Text(
                      'Settings',
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
                top: 100,
                left: 30,
                child: InkWell(
                   onTap: () async {
                            String refresh = await Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const EditProfile()));
                              print('refresh-- $refresh');
                              if(refresh=='Refresh'){
                                setState(() {
                                  p.getProfile(accessTok: a.accessToken, userId: a.userId);
                                });
                                
                              }
                          },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1)),
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 40,
                          backgroundImage: NetworkImage(profile.profilePic),
                          // child: ClipOval(
                          //   child: Image(image: NetworkImage(profile.profilePic)),
                          // ),
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Column(
                        children: [
                          const SizedBox(height: 5,),
                          SizedBox(
                    width: MediaQuery.of(context).size.width-150,
                    child: Text(
                      profile.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5,),
                  SizedBox(
                    width: MediaQuery.of(context).size.width-150,
                    child: Text(
                      profile.about,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.black26,
                      ),
                    ),
                  ),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 230,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 45),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 1.2,
                   // height: MediaQuery.of(context).size.height / 3,
                    // color: Colors.red,
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            String refresh = await Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const EditProfile()));
                              print('refresh-- $refresh');
                              if(refresh=='Refresh'){
                                setState(() {
                                  p.getProfile(accessTok: a.accessToken, userId: a.userId);
                                });
                                
                              }
                          },
                          // onTap: () => Navigator.push(context,
                          //     MaterialPageRoute(builder: (_) => EditProfile())),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                padding: const EdgeInsets.all(5),
                                child: Image(image: AssetImage(contactIcon)),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Profile',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AccountHomeScreen())),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                padding: const EdgeInsets.all(5),
                                child: Center(
                                  child: Image(
                                    image: AssetImage(accountIcon),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              SizedBox(
                                width: MediaQuery.of(context).size.width/1.6,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Account',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      'Privacy, Security, Change Number',
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                     // overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const NotificationScreen())),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                padding: const EdgeInsets.all(5),
                                child:
                                    Image(image: AssetImage(notificationIcon)),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Notifications',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    'Notification ON/OFF',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              padding: const EdgeInsets.all(5),
                              child: Image(image: AssetImage(helpIcon)),
                            ),
                            const SizedBox(width: 15),
                            SizedBox(
                            width:  MediaQuery.of(context).size.width/1.6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Help',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    'Help center, contact us, privacy policy',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: BottomSection(),
              )
            ],
          ),
        );
      },
    );
  }
}
