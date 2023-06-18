
import 'package:flutter/material.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/bottomSection.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/topSection.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/providers/AccountProvider/account_provider.dart';


class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool isSwitched = false;
  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    var account = Provider.of<AccountProvider>(context, listen: false);
   setState(() {
    
     isSwitched = auth.publicStatus == '1' ? true : false;
   });

    return  Consumer<AccountProvider>(
        builder: (context, account, child) {
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
                top: 50,
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
                top: 180,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 1.2,
                    height: MediaQuery.of(context).size.height / 3,
                    // color: Colors.red,
                    child: Column(
                      children: [
                           Row(
                            children: [

                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Show Public',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Transform.scale( scale: 1.5,
                                      child: Switch(
                                      value: auth.publicStatus == '1' ? true : false,
                                      onChanged: (value) {
                                        setState(() {
                                           account.changePrivacyStatus(auth.accessToken,auth.userId,value==true ? '1' : '0',context,);
                                           // isSwitched = auth.publicStatus == "1" ? true : false;
                                        });
                                         
                                      },
                                      activeTrackColor: Colors.green,
                                      activeColor: Colors.white,
                                      ),
                                    ),

                                ],
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
                child:
                BottomSection(),
              )
            ],
          ),
        );
      }
    );
  }
}
