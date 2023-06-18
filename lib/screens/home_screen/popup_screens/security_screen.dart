import 'package:flutter/material.dart';
import 'package:smart_station/providers/AccountProvider/account_provider.dart';
import 'package:smart_station/screens/home_screen/popup_screens/security_passcode_change.dart';
import 'package:smart_station/screens/home_screen/popup_screens/security_switch_screen.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/bottomSection.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/topSection.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';


class SecurityScreen extends StatefulWidget {
  const SecurityScreen({Key? key}) : super(key: key);

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool isSwitched = false;
  
  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: false);
      var account = Provider.of<AccountProvider>(context, listen: false);
      isSwitched  = auth.securityStatus=='1' ? true : false;
       return Consumer<AuthProvider>(
      builder: (context,auth, child) {
    return  Scaffold(
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
                  'Security',
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
            top: 170,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 1.2,
                height: MediaQuery.of(context).size.height / 3,
                // color: Colors.red,
                child: Column(
                  children: [
                    InkWell(
                      //  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfile())),
                      child: Row(
                        children: [

                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Passcode',
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
                                  value: auth.securityStatus=='1'? true : false,
                                  onChanged: (value) {
                                    
                                    setState(() async {
                                      // isSwitched = value;
                                      // print(isSwitched);
                                      //value =isSwitched;
                                    String refresh = await  Navigator.push(context, MaterialPageRoute(builder: (_) => const SecuritySwitchScreen()));
                                    print('refresh-------------$refresh');
                                    if(refresh=='Refresh'){
                                      setState(() {
                                        account.getSecurityPin(auth.accessToken, auth.userId, context);
                                        print(auth.securityStatus);
                                      });
                                    }
                                   
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
                    ),
                    const SizedBox(height: 10,),
                  auth.securityStatus=='1' ? Row(
                      children: [
                        const SizedBox(width: 15),
                        InkWell(
                          onTap: () {
                           
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>const SecurityPasscodeChange()));
                          },
                          child: Text('Change passcode',style: TextStyle(fontSize: 18,color: Colors.grey[500]),)),
                      ],
                    )
                    :const SizedBox()
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
            BottomSectionTransp(),
          )
        ],
      ),
    );});
  }
}
