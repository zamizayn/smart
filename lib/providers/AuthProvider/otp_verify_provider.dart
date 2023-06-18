// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/providers/RecentChatProvider/recentchat_provider.dart';
import 'package:smart_station/screens/passcode_screen/passcode_screen.dart';
import 'package:smart_station/screens/user_profile/new_user_profile.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:smart_station/utils/constants/urls.dart';
import 'package:http/http.dart' as http;

import '../../screens/home_screen/home_screen.dart';

class OtpVerifyProvider extends ChangeNotifier {
  final baseUrl = AppUrls.appBaseUrl;
  bool _isLoading = false;
  String _resMessage = '';

  bool get isLoading => _isLoading;
  String get resMessage => _resMessage;

  void checkOTP(
      {required String otp,
      required String device_token,
      BuildContext? ctx}) async {
    _isLoading = true;
    notifyListeners();

    String url = '$baseUrl/checkotp';

    final body = {'otp': otp, 'deviceToken': device_token};

    try {
      http.Response req =
          await http.post(Uri.parse(url), body: jsonEncode(body));
      print('::::::[OTP CHECK]::::::');
      print(req.body);
      print('::::::[OTP CHECK]::::::');

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('session', res['data']['session'].toString());
        prefs.setString('login_status', 'islogin');
        prefs.setString('security', res['data']['security_status'].toString());
        prefs.setString('accessToken', res['data']['accessToken'].toString());
        prefs.setString('name', res['data']['name'].toString());
        prefs.setString('passCheck', res['data']['security_status'].toString());
        prefs.setString(
            'publicStatus', res['data']['public_status'].toString());
        prefs.setString('userId', res['data']['id']);
        var loginCheck = res['data']['login_status'];
        var passCheck = res['data']['security_status'];
        var publicStatus = res['data']['public_status'];
        var aProvider = Provider.of<AuthProvider>(ctx!, listen: false);
        var recent = Provider.of<RecentChatProvider>(ctx, listen: false);
        aProvider.setUsername(res['data']['name']);
        aProvider.getaccessToken(res['data']['accessToken'], res['data']['id'],
            publicStatus, passCheck);
        aProvider.setBaseDetailsFromPrefs();
        userId = res['data']['id'];
        accessToken = res['data']['accessToken'];

        print('::::::[ResPonse Body]::::::');
        print(loginCheck);
        print(passCheck);
        print(aProvider.accessToken);
        print(aProvider.userId);
        print('::::::[ResPonse Body]::::::');
        if (loginCheck == '0') {
          Navigator.of(ctx).pushReplacement(
              MaterialPageRoute(builder: (context) => const NewUserProfile()));
        } else if (loginCheck == '1' && passCheck == '0') {
          recent.recentChatList(aProvider.accessToken, aProvider.userId, ctx);
          Navigator.of(ctx).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()));
        } else if (loginCheck == '1' && passCheck == '1') {
          // Navigator.of(ctx!).pushReplacement(MaterialPageRoute(builder:(context) => HomeScreen()));
          Navigator.of(ctx).pushReplacement(
              MaterialPageRoute(builder: (context) => const PasscodeScreen()));
        }
      }
    } on SocketException catch (_) {
      _isLoading = false;
      _resMessage = 'No Internet Connection!';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();
    }
  }
}
