// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_station/screens/home_screen/home_screen.dart';
import 'package:smart_station/utils/constants/urls.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';

class EmailProvider extends ChangeNotifier {
  final baseUrl = AppUrls.appBaseUrl;

  //setter
  bool _isLoading = false;
  String _resMessage = '';
  final String _unread = '';
  List<dynamic> _inboxData = [];
  List<dynamic> _sentData = [];
  BuildContext? ctx;

  //getter
  bool get isLoading => _isLoading;
  String get resMessage => _resMessage;
  String get unread => _unread;
  List get inboxData => _inboxData;
  List get sentData => _sentData;

  void getInboxData(data) {
    _inboxData = data;
    notifyListeners();
  }

  void getSendData(data) {
    _sentData = data;
    notifyListeners();
  }

  void getSendList(context) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/send_mail_list';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
    };

    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        // print(res);
        getSendData(res['data']);
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

  void updateEmailReadStatus(
      String? id,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/update_read_mail_status';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'id': id,
    };

    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        // print(res);
        getSendData(res['data']);
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
      _resMessage = 'No Internet connection available!';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();

      print(':::::: $e');
    }
  }

  /* void deleteEmail(
      String? id,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = "$baseUrl/delete_mail";
    final body = {
      "accessToken": auth.accessToken,
      "user_id": auth.userId,
      "id": id,
    };

    print("BODY: ${jsonEncode(body)}");

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        // print(res);
        getSendData(res['data']);
        _isLoading = false;
        _resMessage = req.body;
        notifyListeners();
      } else {
        final res = jsonDecode(req.body);
        print(':::::RRRRRR::::::${res}');
        _isLoading = false;
        notifyListeners();
      }
    } on SocketException catch (_) {
      _isLoading = false;
      _resMessage = "No Internet connection available!";
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = "Please try again!";
      notifyListeners();

      print(":::::: $e");
    }
  }*/

  void deleteEmailByType(
      String? id,
      String? type,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/delete_mail';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'id': id,
      'type': type
    };
    // "type":"send"
    // "type":"inbox"
    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        // print(res);
        getSendData(res['data']);
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
      _resMessage = 'No Internet connection available!';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();

      print(':::::: $e');
    }
  }

  void undoDeletedEmail(
      String? id,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/undo_deleted_mail';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'id': id,
    };

    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        // print(res);
        getSendData(res['data']);
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
      _resMessage = 'No Internet connection available!';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();

      print(':::::: $e');
    }
  }

  void getInboxEmailDetails(
      String? id,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/get_inbox_mail_details';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'id': id,
    };

    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        // print(res);
        getSendData(res['data']);
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
      _resMessage = 'No Internet connection available!';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();

      print(':::::: $e');
    }
  }

  void getSentEmailDetails(
      String? id,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/get_sent_mail_details';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'id': id,
    };

    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        // print(res);
        getSendData(res['data']);
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
      _resMessage = 'No Internet connection available!';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();

      print(':::::: $e');
    }
  }

  void sendMail(
      String toMail,
      String bodyMail,
      BuildContext? context, {
        String? ccMail,
        String? bccMail,
        String? subject,
        List? attachment,
      }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/compose_mail';

    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'to_mail': toMail,
      'cc_mail': ccMail,
      'bcc_mail': bccMail,
      'subject': subject,
      'body': bodyMail,
      // attachment
    };
    _isLoading ? buildShowDialog(ctx!) : Container();
    try {
      // var stream = new http.ByteStream(image!.openRead());
      // var length = await image.length();
      var request = http.MultipartRequest('POST', Uri.parse(url));
      // var multipartFile = http.MultipartFile('group_profile', stream, length,
      //     filename: image.path);
      for (int i = 0; i < attachment!.length; i++) {
        request.files.add(
          http.MultipartFile(
            'attachment[$i]',
            http.ByteStream((attachment[i].openRead())),
            await attachment[i].length(),
            filename: (attachment[i].path),
          ),
        );
      }
      request.fields['accessToken'] = auth.accessToken;
      request.fields['user_id'] = auth.userId;
      request.fields['to_mail'] = toMail;
      request.fields['cc_mail'] = ccMail!;
      request.fields['bcc_mail'] = bccMail!;
      request.fields['subject'] = subject!;
      request.fields['body'] = bodyMail;
      print('request');
      print(request.fields);
      var resp = await request.send();
      resp.stream.transform(utf8.decoder).listen((event) {
        print('event');
        print(event);
        var finalData = jsonDecode(event);
        // _resMessage = finalData;
        _isLoading = false;
        notifyListeners();
        if (finalData['statuscode'] == 200) {
          print(finalData['body']);

          Navigator.of(context!).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()));
        }
        print('::::::[RESPONSE]::::::');
        print(finalData);
        print('::::::[RESPONSE]::::::');
      });

      // http.Response req =
      //     await http.post(Uri.parse(url), body: jsonEncode(body));

      // if (req.statusCode == 200 || req.statusCode == 201) {
      //   final res = jsonDecode(req.body);
      //   // print(res);
      //   getSendData(res['data']);
      //   _isLoading = false;
      //   _resMessage = req.body;
      //   notifyListeners();
      // } else {
      //   final res = jsonDecode(req.body);
      //   print(':::::RRRRRR::::::${res}');
      //   _isLoading = false;
      //   notifyListeners();
      // }
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