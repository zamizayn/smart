// ignore_for_file: non_constant_identifier_names, unused_local_variable, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_station/utils/constants/urls.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/providers/RecentChatProvider/recentchat_provider.dart';
import 'package:smart_station/screens/passcode_screen/passcode_screen.dart';
import 'package:smart_station/screens/user_profile/new_user_profile.dart';
import 'package:smart_station/screens/lost_phone/otp_screen.dart';
import '../../screens/home_screen/home_screen.dart';
import 'package:smart_station/screens/lost_phone/change_new_number_screen.dart';

class LostPhoneProvider extends ChangeNotifier {
  final baseUrl = AppUrls.appBaseUrl;

  //setter
  bool _isLoading = false;
  String _resMessage = '';
  TextEditingController emailController = TextEditingController();
  List<dynamic> _data = [];
  bool _phoneOtpStatus = false;
  String _phoneOtp = '';

  BuildContext? ctx;

  //getter
  bool get isLoading => _isLoading;
  String get resMessage => _resMessage;
  List get data => _data;
  bool get phoneOtpStatus => _phoneOtpStatus;
  String get phoneOtp => _phoneOtp;

  void getActualData(data) {
    _data = data;
    notifyListeners();
  }

  void sendOtp({
    required String mail_id,
    required String deviceToken,
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/sendemailotp';
    final body = {
      'mail_id': mail_id,
    };

    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
          await http.post(Uri.parse(url), body: jsonEncode(body));
      print(req.body);

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        var aProvider = Provider.of<AuthProvider>(ctx!, listen: false);
        _isLoading = false;
        _resMessage = req.body;
        var status = res['status'];
        if (status == true) {
          // Show an alert
          showDialog(
            context: ctx!,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('OTP Sent'),
                content: const Text('An OTP has been sent to your email.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      // Navigate to the next screen
                      /* Navigator.push(
                        ctx!,
                        MaterialPageRoute(builder: (context) => OtpScreen()),
                      );*/
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => OtpScreen(
                                    email: mail_id,
                                    deviceToken: deviceToken,
                                    ctxt: context,
                                  )));
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          _resMessage = 'OTP sending failed!';
        }
        notifyListeners();
      } else {
        final res = jsonDecode(req.body);
        print(':::::RRRRRR::::::$res');
        _isLoading = false;
        notifyListeners();
      }
    } on SocketException catch (_) {
      _isLoading = false;
      _resMessage = 'No Internet connection add available!';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();
      print(':::::: $e');
    }
  }

  void resendOtp({
    required String mail_id,
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/resendemailotp';
    final body = {
      'mail_id': mail_id,
    };

    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
          await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        var aProvider = Provider.of<AuthProvider>(ctx!, listen: false);
        _isLoading = false;
        _resMessage = req.body;
        var status = res['status'];
        if (status == 'true') {
          print('true otp');
        }
        // _name = name;
        notifyListeners();
      } else {
        final res = jsonDecode(req.body);
        print(':::::RRRRRR::::::$res');
        _isLoading = false;
        notifyListeners();
      }
    } on SocketException catch (_) {
      _isLoading = false;
      _resMessage = 'No Internet connection add available!';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();

      print(':::::: $e');
    }
  }

  void checkEmailOTP({
    required String otp,
    required String email,
    required String device_token,
    BuildContext? context,
  }) async {
    _isLoading = true;
    notifyListeners();

    String url = '$baseUrl/verify_email_otp';

    final body = {'otp': otp, 'email': email};

    try {
      http.Response req =
          await http.post(Uri.parse(url), body: jsonEncode(body));
      print('::::::[OTP CHECK]::::::');
      print(req.body);
      print('::::::[OTP CHECK]::::::');

      /* Navigator.push(ctx!, MaterialPageRoute(builder: (
          _) => ChangeNewNumberScreen()));*/

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);

        var status = res['status'];
        var message = res['message'].toString();

        if (status) {
          Navigator.of(ctx!).pushReplacement(MaterialPageRoute(
              builder: (context) => ChangeNewNumberScreen(
                    email: email,
                    deviceToken: device_token,
                  )));
        } else {
          showDialog(
            context: context!,
            builder: (context) => AlertDialog(
              // title: Text('Result'),
              content: Text(message),
            ),
          );
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

  void resetOldOtp() {
    _phoneOtpStatus = false;
    _phoneOtp = '';
    notifyListeners();
  }

  void sendNewPhoneOtp({
    required String phone,
    required String country,
    required String email,
    required String deviceToken,
    BuildContext? context,
  }) async {
    _isLoading = true;
    _phoneOtpStatus = true;
    _phoneOtp = '';
    ctx = context;

    String url = '$baseUrl/update_new_phone';

    final body = {
      'email': email,
      'deviceToken': deviceToken,
      'new_phone': phone,
      'country': country,
    };

    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
          await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        _isLoading = false;
        _resMessage = req.body;

        var message = res['message'].toString();
        var status = res['status'];
        var data = res['data'];
        if (status == false) {
          _phoneOtpStatus = false;
          _phoneOtp = '';
          showDialog(
            context: context!,
            builder: (context) => AlertDialog(
              // title: Text('Result'),
              content: Text(message),
            ),
          );
        } else {
          _phoneOtpStatus = true;

          _phoneOtp = data['otp'].toString();
          notifyListeners();
        }
      } else {
        final res = jsonDecode(req.body);
        var message = res['message'].toString();
        showDialog(
          context: context!,
          builder: (context) => AlertDialog(
            // title: Text('Result'),
            content: Text(message),
          ),
        );
        print(':::::RRRRRR::::::$res');
        _isLoading = false;
        notifyListeners();
      }
    } on SocketException catch (_) {
      _isLoading = false;
      _resMessage = 'No Internet connection available!';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();
      print(':::::: $e');
    }
  }

  void checkOTP(
      {required String otp,
      required String device_token,
      required String country,
      required String email,
      required String new_phone,
      BuildContext? ctx}) async {
    _isLoading = true;
    notifyListeners();

    String url = '$baseUrl/verify_change_phone_otp';

    final body = {
      'otp': otp,
      'deviceToken': device_token,
      'country': country,
      'email': email,
      'new_phone': new_phone
    };

    try {
      http.Response req =
          await http.post(Uri.parse(url), body: jsonEncode(body));
      print('::::::[OTP CHECK]::::::');
      print(req.body);
      print('::::::[OTP CHECK]::::::');

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('session', res['data']['session']);
        prefs.setString('login_status', res['data']['login_status']);
        prefs.setString('security', res['data']['security_status']);
        prefs.setString('accessToken', res['data']['accessToken']);
        prefs.setString('userId', res['data']['id']);
        var loginCheck = res['data']['login_status'];
        var passCheck = res['data']['security_status'];
        var publicStatus = res['data']['public_status'];
        var aProvider = Provider.of<AuthProvider>(ctx!, listen: false);
        var recent = Provider.of<RecentChatProvider>(ctx, listen: false);
        aProvider.getaccessToken(res['data']['accessToken'], res['data']['id'],
            publicStatus, passCheck);
        aProvider.setBaseDetailsFromPrefs();

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
