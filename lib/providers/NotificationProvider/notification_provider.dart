// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_station/utils/constants/urls.dart';

class NotificationProvider extends ChangeNotifier {
  final baseUrl = AppUrls.appBaseUrl;

  //setter
  bool _isLoading = false;
  String _isNotify = '';
  String _isSound = '';
  String _isVbr = '';
  String _resMessage = '';
  BuildContext? ctx;

  //getter
  bool get isLoading => _isLoading;

  String get isSound => _isSound;

  String get isVbr => _isVbr;

  String get isNotify => _isNotify;

  String get resMessage => _resMessage;

  void changeStatus({
    required String status,
    required String notfyFor,
    String? accessToken,
    String? userId,
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/changenotification_status';
    var body;
    if (notfyFor == 'notification') {
      body = {
        'accessToken': accessToken,
        'user_id': userId,
        'notification_status': status
      };
    }

    if (notfyFor == 'sound') {
      body = {
        'accessToken': accessToken,
        'user_id': userId,
        'sound': status
      };
    }

    if (notfyFor == 'vibration') {
      body = {
        'accessToken': accessToken,
        'user_id': userId,
        'vibration': status
      };
    }


    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
          await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        if (res['message'] == 'Notification Status Updated Successfully') {
        //   get Notification

          String getUrl = '${baseUrl}getnotification_status';

          var data = await http.post(Uri.parse(getUrl), body: {'user_id': userId , 'accessToken': accessToken});

          if (data.statusCode == 200 || data.statusCode == 201) {
            var jsonData = jsonDecode(data.body);
            print('%%%%%%%%%%%%%%%%%%%%%%%%[DATA]%%%%%%%%%%%%%%%%%%%%%%%%');
            print(jsonData);
            print('%%%%%%%%%%%%%%%%%%%%%%%%[DATA]%%%%%%%%%%%%%%%%%%%%%%%%');
            _isNotify = jsonData['notification_status'];
            _isSound = jsonData['sound'];
            _isVbr = jsonData['vibration'];
            notifyListeners();
          }

        }
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


}
