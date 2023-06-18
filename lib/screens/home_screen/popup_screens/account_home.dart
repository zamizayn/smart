import 'package:flutter/material.dart';
import 'package:smart_station/screens/home_screen/popup_screens/change_number_screen.dart';
import 'package:smart_station/screens/home_screen/popup_screens/footer_home.dart';
import 'package:smart_station/screens/home_screen/popup_screens/header_home.dart';
import 'package:smart_station/screens/home_screen/popup_screens/privacy_settings_screen.dart';
import 'package:smart_station/screens/home_screen/popup_screens/security_screen.dart';
import 'package:smart_station/screens/home_screen/popup_screens/signature_home.dart';
import 'package:smart_station/screens/home_screen/popup_screens/stamp_home.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/bottomSection.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/topSection.dart';
import 'package:smart_station/utils/constants/app_constants.dart';


class AccountHomeScreen extends StatefulWidget {
  const AccountHomeScreen({Key? key}) : super(key: key);

  @override
  State<AccountHomeScreen> createState() => _AccountHomeScreenState();
}

class _AccountHomeScreenState extends State<AccountHomeScreen> {
  @override
  Widget build(BuildContext context) {
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
                SizedBox(width: 10,),
                Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
          Positioned(
            top: 120,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35,vertical: 20),
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 1.2,
                height: MediaQuery.of(context).size.height / 1.3,
                // color: Colors.red,
                child: Column(
                  children: [
                    InkWell(
                      onTap:() {

                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacySettingsScreen()));
                    },
                    child: Row(
                    children: [
                    Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(5),
                    child: Image(image: AssetImage(privacyIcon)),
                    ),
                    const SizedBox(width: 20),
                    Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                    Text(
                    'Privacy',
                    style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    // color: Colors.grey[750]
                    ),

                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityScreen())),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            padding: const EdgeInsets.all(5),
                            child: Center(
                              child: Image(
                                image: AssetImage(securityIcon),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Security',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  // color: Colors.grey[750]
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangeNumberScreen())),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            padding: const EdgeInsets.all(5),
                            child: Image(image: AssetImage(changePhoneIcon)),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Change Phone Number',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  // color: Colors.grey[750]
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignatureHome())),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            padding: const EdgeInsets.all(5),
                            child: Image(image: AssetImage(signatureIcon)),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Signature Upload',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  // color: Colors.grey[750]
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StampHome())),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            padding: const EdgeInsets.all(5),
                            child: Image(image: AssetImage(stampIcon)),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Stamp Upload',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  // color: Colors.grey[750]
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HeaderHome())),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            padding: const EdgeInsets.all(5),
                            child: Image(image: AssetImage(headerIcon)),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Letter Header',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  // color: Colors.grey[750]
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FooterHome())),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            padding: const EdgeInsets.all(5),
                            child: Image(image: AssetImage(headerIcon)),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Letter Footer',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  // color: Colors.grey[750]
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child:
            BottomSection(),
          )
        ],
      ),
    );
  }
}
