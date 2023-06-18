import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_station/providers/RecentChatProvider/recentchat_provider.dart';
import 'package:smart_station/screens/get_started/get_started.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../providers/AuthProvider/auth_provider.dart';
import '../../utils/constants/urls.dart';
import '../home_screen/home_screen.dart';
import '../passcode_screen/passcode_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String loginStatus = '';
  final IO.Socket _socket = IO.io(AppUrls.appSocketUrl,
      IO.OptionBuilder().setTransports(['websocket']).build());

  _connectSocket() {
    _socket.connect();
    _socket.onConnect((data) => print('Connection established'));
    _socket.onConnectError((data) => print('Connect Error $data'));
    _socket.onDisconnect((data) => print('Socket.IO disconneted'));
  }

  _destroySocket(){
    _socket.disconnect();
  }

  @override
  void initState() {
    _connectSocket();
    super.initState();
    getSession();
    Future.delayed(
        const Duration(
          seconds: 8,
        ), () async {
      if (loginStatus == 'islogin') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var aProvider = Provider.of<AuthProvider>(context, listen: false);
        var recent = Provider.of<RecentChatProvider>(context, listen: false);
        String passCheck = prefs.getString('passCheck').toString();
        aProvider.setUsername(prefs.getString('name').toString());
        aProvider.getaccessToken(
            prefs.getString('accessToken').toString(),
            prefs.getString('userId').toString(),
            prefs.getString('publicStatus').toString(),
            prefs.getString('passCheck').toString());
        if (passCheck == '0') {
          recent.recentChatList(
              aProvider.accessToken, aProvider.userId, context);
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()));
        } else if (passCheck == '1') {
          // Navigator.of(ctx!).pushReplacement(MaterialPageRoute(builder:(context) => HomeScreen()));
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const PasscodeScreen()));
        }
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const GetStarted(),
        ));
      }
    });
  }

  void getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var recent = Provider.of<RecentChatProvider>(context, listen: false);
    var currentSession = prefs.getString('session');
    loginStatus = prefs.getString('login_status').toString();
    var securityStatus = prefs.getString('security');
    var userId = prefs.getString('userId');
    var accessToken = prefs.getString('accessToken');
    print('RRRRRRRRRRRRRR');
    print(currentSession);
    print(loginStatus);
    print(securityStatus);
    print(userId);
    print(accessToken);
    print('RRRRRRRRRRRRRR');

    // if (currentSession == null || currentSession == "0" && loginStatus == "0" || loginStatus == null) {
    //   print(" To Get Started");
    //   Future.delayed(
    //     Duration(
    //       seconds: 8,
    //     ),
    //         () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => GetStarted(),)),
    //   );
    // } else if (currentSession == "1" && loginStatus == "1" && securityStatus == "0"){
    //   recent.recentChatList(accessToken, userId, context);
    //   Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context) => HomeScreen()));
    // } else if (currentSession == "1" && loginStatus == "1" && securityStatus == "1") {
    //   Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context) => PasscodeScreen()));
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(splashBg), fit: BoxFit.cover)),
        child: Center(
          child: Image(image: AssetImage(splashLogo)),
        ),
      ),
    );
  }
}
