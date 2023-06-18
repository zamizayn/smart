// ignore_for_file: unused_field, unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_station/utils/constants/urls.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';

class CommonProvider extends ChangeNotifier {
  final baseUrl = AppUrls.appBaseUrl;

  //setter
  bool _isLoading = false;
  String _resMessage = '';
  String _filePath = '';
  String _halfPath = '';
  final String _unread = '';

  BuildContext? ctx;

  //getter
  bool get isLoading => _isLoading;
  String get resMessage => _resMessage;
  String get filePath => _filePath;
  String get halfPath => _halfPath;

  void uploadFile(
      File? ftr,
      String? type,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/fileupload';

    try {
      var stream = http.ByteStream(ftr!.openRead());
      var length = await ftr.length();
      var request = http.MultipartRequest('POST', Uri.parse(url));
      var multipartFile =
      http.MultipartFile('file', stream, length, filename: ftr.path);
      request.fields['user_id'] = auth.userId;
      request.fields['accessToken'] = auth.accessToken;
      request.files.add(multipartFile);
      var resp = await request.send();
      resp.stream.transform(utf8.decoder).listen((event) {
        print('#############################');
        print(event.runtimeType);
        print(event);
        print('#############################');
        var finalData = jsonDecode(event);
        // _profilePic = finalData['data']['profile_pic'];
        notifyListeners();
        if (finalData['statuscode'] == 200) {
          _isLoading = false;
          _resMessage = event;
          _filePath = finalData['filepath'];
          _halfPath = finalData['path'];

          notifyListeners();

        }
      });
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

  void sendEmailOtp(
      String? mailId,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/sendemailotp';
    final body = {
      'mail_id': mailId,
    };

    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        notifyListeners();
        final res = jsonDecode(req.body);
        print(res);
        // getActualData(res['data']);
        _isLoading = false;
        _resMessage = req.body;

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

  void checkEmailOtp(
      String? otp,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/checkemailotp';
    final body = {
      'otp': otp,
    };

    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        notifyListeners();
        final res = jsonDecode(req.body);
        print(res);
        // getActualData(res['data']);
        _isLoading = false;
        _resMessage = req.body;

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


  buildShowDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}