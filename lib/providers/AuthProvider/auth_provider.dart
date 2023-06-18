// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_station/utils/constants/urls.dart';

import '../../screens/otp_screen/otp_screen.dart';

class AuthProvider extends ChangeNotifier {
  final baseUrl = AppUrls.appBaseUrl;
//hy
  //setter
  bool _isLoading = false;
  String _resMessage = '';
  String _phone = '';
  String _cCode = '';
  String _deviceToken = '';
  String _accesssToken = '';
  String _userId = '';
  String _publicStatus = '';
  String _securityStatus = '';
  String _userName = '';
  BuildContext? ctx;

  //getter
  bool get isLoading => _isLoading;

  String get phone => _phone;

  String get cCode => _cCode;
  String get username => _userName;
  String get deviceToken => _deviceToken;
  String get accessToken => _accesssToken;
  String get userId => _userId;
  String get publicStatus => _publicStatus;
  String get securityStatus => _securityStatus;

  String get resMessage => _resMessage;

  void loginUser({
    required String phone,
    required String device_type,
    required String country,
    required String device_token,
    required bool islogin,
    BuildContext? context,
  }) async {
    _isLoading = true;
    _deviceToken = device_token;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/login';
    final body = {
      'phone': phone,
      'deviceType': device_type,
      'country': country,
      'deviceToken': device_token,
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
        _phone = phone;
        _cCode = country;
        if (islogin) {
          Navigator.of(ctx!).pushReplacement(
              MaterialPageRoute(builder: (_) => OTPScreen(ctxt: ctx!)));
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
      _resMessage = 'No Internet connection available!';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();

      print(':::::: $e');
    }
  }

  void clearAll() {
    _accesssToken = '';
    _userId = '';
    _userName = '';
    _deviceToken = '';
    notifyListeners();
  }

  Future<void> setUsername(userName) async {
    _userName = userName;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('Name', _userName);
    print('SharePref________________----------------------------------------');
    print(prefs.getString('Name'));
  }

  void getaccessToken(
    token,
    uId,
    publicStatus,
    securityStatus,
  ) {
    _accesssToken = token;
    _userId = uId;
    _publicStatus = publicStatus;
    _securityStatus = securityStatus;
    notifyListeners();
  }

  void setBaseDetailsFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _accesssToken = prefs.getString('accessToken').toString();
    _userId = prefs.getString('userId').toString();
    notifyListeners();
  }
}
