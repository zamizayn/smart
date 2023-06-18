// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_station/screens/home_screen/letter/letter_search_list.dart';
import 'package:smart_station/utils/constants/urls.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/screens/home_screen/home_screen.dart';

import '../../screens/home_screen/letter/letter_sent_list_model.dart';

class LetterProvider extends ChangeNotifier {
  final baseUrl = AppUrls.appBaseUrl;

  //setter
  bool _isLoading = false;
  String _resMessage = '';
  String _unread = '';
  List<dynamic> _inboxData = [];
  List<dynamic> _sendData = [];
  List<dynamic> _emailData = [];
  List<dynamic> _stampData = [];
  List<dynamic> _starredData = [];
  List<dynamic> _importantData = [];
  List<dynamic> _archievedData = [];
  List<dynamic> _selectedLetter = [];
  List<dynamic> _filteredLetter = [];
  List<dynamic> _selectedSentLetter = [];
  List<dynamic> _selectedStarredLetter = [];
  List<dynamic> _selectedChat = [];
  BuildContext? ctx;

  //getter
  bool get isLoading => _isLoading;
  String get resMessage => _resMessage;
  String get unread => _unread;
  List get inboxData => _inboxData;
  List get sendData => _sendData;
  List get emailData => _emailData;
  List get stampData => _stampData;
  List get starredData => _starredData;
  List get importantData => _importantData;
  List get archievedData => _archievedData;
  List get selectedLetter => _selectedLetter;
  List get selectedSentLetter => _selectedSentLetter;
  List get selectedStarredLetter => _selectedStarredLetter;
  List get filteredLetter => _filteredLetter;
  List get selectedChat => _selectedChat;

   void getSelectedLetter(data) {
    _selectedLetter = data;
    print('selected ======$_selectedLetter');
    notifyListeners();
  }
  void getSelectedChat(data) {
    _selectedChat = data;
    print('selected  chat======$_selectedChat');
    print('-------------------');
    print(selectedChat);
    notifyListeners();
  }

   void getSelectedSentLetter(data) {
    _selectedSentLetter = data;
    notifyListeners();
  }

  void getSelectedStarredLetter(data) {
    _selectedStarredLetter = data;
    print('----------------------');
    print(_selectedStarredLetter);
    notifyListeners();
  }

   void getFilteredLetter(data) {
    _filteredLetter = data;
    filter=data;
    print(_filteredLetter);
    notifyListeners();
  }

  void getInboxData(data) {
    _inboxData = data;
    notifyListeners();
  }

  void getSendData(data) {
    _sendData = data;
    notifyListeners();
  }
  void getEmailData(data) {
    _emailData = data;
    notifyListeners();
  }
  void getStampData(data) {
    _stampData = data;
    notifyListeners();
  }
  void getStarredData(data) {
    _starredData = data;
    notifyListeners();
  }
   void getImportantData(data) {
    _importantData = data;
    notifyListeners();
  }
   void getArchievedData(data) {
    _archievedData = data;
    notifyListeners();
  }

  void getInboxList(
      context
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/getletter_list';
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
        print(res);
        final json = res['data'];
        //print("json");
        // print(json);
        // print(json['letter_list']);
        getInboxData(json['letter_list']);
        getFilteredLetter(json['letter_list']);
        // List selectedLetter=[];
        //   for(var i = 0;i<inboxData.length;i++){
        //     selectedLetter.insert(i,false);
        //     print(selectedLetter);
        //   }
        //   getSelectedLetter(selectedLetter);
        print('unread');
        print(json['unread']);
        _unread = json['unread'].toString();
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

  Future<GetSentLetterList> getSendList(
      context
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/get_letter_sent_list';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
    };
    print('jjj');
    print('BODY: ${jsonEncode(body)}');

    
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final data = GetSentLetterList.fromJson(json.decode(req.body));
      print(req.body);
      return data;
      
    
      }
       else {
        final res = jsonDecode(req.body);
        print(':::::RRRRRR::::::$res');
        _isLoading = false;
        notifyListeners();
        throw Exception('Failed to load users');
      }
    
  }

  void updateLetterReadStatus(
      String? id,
      String? letterReadStatus,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/update_read_letter_status';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'id': id,
      'letter_read_status': letterReadStatus,
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

  void sendLetter(
      String toMail,
      String toAddress,
      String bodyMail,
      String? header,
      String? footer,
      String? signature,
      String? stamp,
      BuildContext? context,
      { String? ccMail,
        String? bccMail,
        String? subject,

        List? attachment,}
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();


    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/create_letter';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'to_mail': toMail,
      'cc_mail': ccMail,
      'bcc_mail': bccMail,
      'subject': subject,
      'letter_body': bodyMail,
      'mail_body': bodyMail,
      'address_to' : toAddress,
      'header_url_path' : header,
      'footer_url_path' : footer,
      'signature_url_path' : signature,
      'stamp_url_path' : stamp,
    };
    print('obj--$body');
    print('BODY: ${jsonEncode(body)}');
    _isLoading? buildShowDialog(ctx!):Container();
    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);

        _isLoading = false;
        _resMessage = req.body;
        notifyListeners();
        Navigator.of(context!).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen(tabindex: 2,)));
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


/*





    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = "$baseUrl/compose_mail";

    final body = {
      "accessToken": auth.accessToken,
      "user_id": auth.userId,
      "to_mail": toMail,
      "cc_mail": ccMail,
      "bcc_mail": bccMail,
      "subject": subject,
      "body": bodyMail,
      "address_to" : toAddress,
      "header_url_path" : header,
      "footer_url_path" : footer,
      "signature_url_path" : signature,
      "stamp_url_path" : stamp,
      // attachment
    };
    _isLoading? buildShowDialog(ctx!):Container();
    try {
      // var stream = new http.ByteStream(image!.openRead());
      // var length = await image.length();
      var request = new http.MultipartRequest("POST", Uri.parse(url));
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
      print("request");
      print(request.fields);
      var resp = await request.send();
      resp.stream.transform(utf8.decoder).listen((event) {
        print("event");
        print(event);
        var finalData = jsonDecode(event);
        // _resMessage = finalData;
        _isLoading = false;
        notifyListeners();
        if (finalData['statuscode'] == 200) {


          Navigator.of(context!).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen()));
        }
        print("::::::[RESPONSE]::::::");
        print(finalData);
        print("::::::[RESPONSE]::::::");
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
      _resMessage = "No Internet connection add available!";
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = "Please try again!";
      notifyListeners();

      print(":::::: $e");
    }*/
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
  

  void deleteLetter(
      String? id,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/delete_letter_mail';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'id': id
    };
    // "type":"send"
    // "type":"inbox"
    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        _isLoading = false;
        _resMessage = req.body;
        notifyListeners();
        // SnackBar(
        //       duration: Duration(milliseconds: 1000),
        //       content: Text("1 deleted"),
        //       action: SnackBarAction(
        //     label: 'Undo',
        //     onPressed: () {
        //       undoDeletedLetter(id, context);
        //     },
        //   ),
        //   );

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

      print(':::::: err$e');
    }
  }

  void undoDeletedLetter(
      String? id,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/undo_deleted_letter';
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

  void getLetterDetails(
      String? id,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/view_letter_list_details';
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
  void getEmailList(
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/get_user_mailids';
    final body = {
      'user_id': auth.userId,
      'accessToken': auth.accessToken,
    };

    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));
      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        // print("res--$res");
        getEmailData(res['mailids']);
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

      print(':::::: Error $e');
    }
  }
  Future<dynamic> getDefaultStamp(
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/get_default_signature_and_stamp';
    final body = {
      'user_id': auth.userId,
      'accessToken': auth.accessToken,
    };

    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));
      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        var resp=res['data']['default'];
        // print("res--$res");
        getStampData(res['data']['default']);
        _isLoading = false;
        _resMessage = req.body;
        notifyListeners();
        print('resp=========$resp');
        return resp;
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
  void forwardLetter(
      String toMail,
      BuildContext? context,
      String? ccMail,
      String? bccMail,
      String? subject,
      String? id

      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();


    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/forward_letter';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'to_mail': toMail,
      'cc': ccMail,
      'bcc': bccMail,
      'subject': subject,
      'id':id
    };
    print('obj--$body');
    print('BODY: ${jsonEncode(body)}');
    _isLoading? buildShowDialog(ctx!):Container();
    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);

        _isLoading = false;
        _resMessage = req.body;
        notifyListeners();
        Navigator.of(context!).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen(tabindex: 2,)));
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
    Future<dynamic> getStarredList(
      context
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/starred_letter_list';
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
        print(res);
        final json = res['data'];
        //print("json");
        // print(json);
        // print(json['letter_list']);
        getStarredData(json['letter_list']);
        //  List selectedStarredLetter=[];
        //   for(var i = 0;i<starredData.length;i++){
        //     selectedStarredLetter.insert(i,false);
        //     print(selectedStarredLetter);
        //   }
        //   print("stared");
        //   print(selectedStarredLetter);
        //   getSelectedStarredLetter(selectedStarredLetter);
        // print("unread");
        // print(json['unread']);
       // _unread = json['unread'].toString();
        _isLoading = false;
        _resMessage = req.body;
        //return json;
        notifyListeners();
        return json;
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
      Future<dynamic> getImportantList(
      context
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/important_letter_list';
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
        final json = res['data'];
        getImportantData(json['letter_list']);
        _isLoading = false;
        _resMessage = req.body;
       
        notifyListeners();
         return json;
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
      Future<dynamic> getArchievedList(
      context
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/archivedletter_list';
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
        print(res);
        final json = res['data'];
        getArchievedData(json['letter_list']);
        _isLoading = false;
        _resMessage = req.body;
        notifyListeners();
         return json;
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
   Future draftLetter(
      String toMail,
      String toAddress,
      String bodyMail,
      String? header,
      String? footer,
      String? signature,
      String? stamp,
      BuildContext? context,
      String? ccMail,
      String? bccMail,
      String? subject,
      String? draftId,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();


    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/create_letter_draft';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'to_mail': toMail,
      'cc_mail': ccMail,
      'bcc_mail': bccMail,
      'subject': subject,
      'letter_body': bodyMail,
      'mail_body' :bodyMail,
      'address_to' : toAddress,
      'header_url_path' : header,
      'footer_url_path' : footer,
      'signature_url_path' : signature,
      'stamp_url_path' : stamp,
      'id':draftId,
    };
    print('obj--$body');
    print('BODY: ${jsonEncode(body)}');
    //_isLoading? buildShowDialog(ctx!):Container();
    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        if(res['status'].toString()=='true'){
          ScaffoldMessenger.of(context!).showSnackBar(
              SnackBar(
                width: MediaQuery.of(context).size.width-50,
                content: const Center(child: Text('Message saved as draft',style: TextStyle(color: Colors.white),)),
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              ),
            );
          Navigator.pop(context);
        }
        _isLoading = false;
        _resMessage = req.body;
        notifyListeners();
        return req;
        //  var status = res["status"];
        // if(status==true){
        //   print("inside snackbar");
        //   ScaffoldMessenger.of(context!).showSnackBar(
        //   SnackBar(
        //     width: MediaQuery.of(context).size.width-50,
        //     content: Center(child: Text("Message saved as draft",style: TextStyle(color: Colors.white),)),
        //     duration: Duration(seconds: 5),
        //     behavior: SnackBarBehavior.floating,
        //     backgroundColor: Color.fromRGBO(0, 0, 0, 0.5),
        //     shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(20),
        //   ),
        // ),
        // );
        // }
        
        // Navigator.of(context!).pushReplacement(
        //     MaterialPageRoute(builder: (context) => HomeScreen()));
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
  Future<dynamic> multipleDeleteLetter(
      context,
      deleteList
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/delete_letter_multiple';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'ids':deleteList
    };
    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        final json = res['data'];
      //  getImportantData(json['letter_list']);
        _isLoading = false;
        _resMessage = req.body;
       
        notifyListeners();
         return json;
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
    Future<dynamic> getDraftList(
      context
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/getletter_draft_list';
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
        print(res);
        final json = res['data'];
       // getArchievedData(json['letter_list']);
        _isLoading = false;
        _resMessage = req.body;
        notifyListeners();
         return json;
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
  Future<dynamic> multipleArchiveLetter(
      context,
      deleteList
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/archive_letter_multiple';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'letter_ids':deleteList
    };
    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        final json = res['data'];
      //  getImportantData(json['letter_list']);
        _isLoading = false;
        _resMessage = req.body;
       
        notifyListeners();
         return json;
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
   Future<dynamic> multipleUnarchiveLetter(
      context,
      deleteList
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/unarchive_letter_multiple';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'letter_ids':deleteList
    };
    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        final json = res['data'];
      //  getImportantData(json['letter_list']);
        _isLoading = false;
        _resMessage = req.body;
       
        notifyListeners();
         return json;
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
   Future<dynamic> multipleStarLetter(
      context,
      starList
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/letter_starred_status_multiple';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'letter_ids':starList
    };
    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        final json = res['data'];
      //  getImportantData(json['letter_list']);
        _isLoading = false;
        _resMessage = req.body;
       
        notifyListeners();
         return json;
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
   Future<dynamic> multipleUnstarLetter(
      context,
      starList
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/letter_unstarred_status_multiple';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'letter_ids':starList
    };
    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        final json = res['data'];
      //  getImportantData(json['letter_list']);
        _isLoading = false;
        _resMessage = req.body;
       
        notifyListeners();
         return json;
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
   Future<dynamic> multipleImportantLetter(
      context,
      impList
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/markas_important_multiple';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'letter_ids':impList
    };
    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        final json = res['data'];
      //  getImportantData(json['letter_list']);
        _isLoading = false;
        _resMessage = req.body;
       
        notifyListeners();
         return req;
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
   Future<dynamic> multipleUnimportantLetter(
      context,
      impList
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/markas_unimportant_multiple';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'letter_ids':impList
    };
    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        final json = res['data'];
      //  getImportantData(json['letter_list']);
        _isLoading = false;
        _resMessage = req.body;
       
        notifyListeners();
         return req;
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
   Future<dynamic> multipleMarkasReadLetter(
      context,
      impList
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/markas_readletter_multiple';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'letter_ids':impList
    };
    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        final json = res['data'];
      //  getImportantData(json['letter_list']);
        _isLoading = false;
        _resMessage = req.body;
       
        notifyListeners();
         return req;
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
   Future<dynamic> multipleMarkasUnreadLetter(
      context,
      impList
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/markas_unreadletter_multiple';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'letter_ids':impList
    };
    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        final json = res['data'];
      //  getImportantData(json['letter_list']);
        _isLoading = false;
        _resMessage = req.body;
       
        notifyListeners();
         return req;
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
  Future<dynamic> multipleDeleteDraftLetter(
      context,
      deleteList
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/deletedraft_multiple';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'letter_ids':deleteList
    };
    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        final json = res['data'];
      //  getImportantData(json['letter_list']);
        _isLoading = false;
        _resMessage = req.body;
       
        notifyListeners();
         return req;
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
   Future<dynamic> multipleImportantDraftLetter(
      context,
      impList
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/markas_importantdraft_multiple';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'letter_ids':impList
    };
    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        final json = res['data'];
      //  getImportantData(json['letter_list']);
        _isLoading = false;
        _resMessage = req.body;
       
        notifyListeners();
         return req;
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
   Future<dynamic> multipleUnimportantDraftLetter(
      context,
      impList
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/markas_unimportantdraft_multiple';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'letter_ids':impList
    };
    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        final json = res['data'];
      //  getImportantData(json['letter_list']);
        _isLoading = false;
        _resMessage = req.body;
       
        notifyListeners();
         return req;
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
   Future<dynamic> multipleStarDraftLetter(
      context,
      starList
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/markas_starreddraft_multiple';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'letter_ids':starList
    };
    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        final json = res['data'];
      //  getImportantData(json['letter_list']);
        _isLoading = false;
        _resMessage = req.body;
       
        notifyListeners();
         return req;
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
   Future<dynamic> multipleUnstarDraftLetter(
      context,
      starList
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/markas_unstarreddraft_multiple';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'letter_ids':starList
    };
    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        final json = res['data'];
      //  getImportantData(json['letter_list']);
        _isLoading = false;
        _resMessage = req.body;
       
        notifyListeners();
         return req;
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
   Future<dynamic> multipleArchiveDraftLetter(
      context,
      deleteList
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/markas_archivedraft_multiple';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'letter_ids':deleteList
    };
    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        final json = res['data'];
      //  getImportantData(json['letter_list']);
        _isLoading = false;
        _resMessage = req.body;
       
        notifyListeners();
         return req;
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
   Future<dynamic> multipleUnarchiveDraftLetter(
      context,
      deleteList
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/markas_unarchivedraft_multiple';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'letter_ids':deleteList
    };
    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        final json = res['data'];
      //  getImportantData(json['letter_list']);
        _isLoading = false;
        _resMessage = req.body;
       
        notifyListeners();
         return req;
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
  Future<dynamic> multipleMarkasReadDraftLetter(
      context,
      impList
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/markas_readletterdraft_multiple';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'letter_ids':impList
    };
    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        final json = res['data'];
      //  getImportantData(json['letter_list']);
        _isLoading = false;
        _resMessage = req.body;
       
        notifyListeners();
         return req;
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
   Future<dynamic> multipleMarkasUnreadDraftLetter(
      context,
      impList
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/markas_unreadletterdraft_multiple';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'letter_ids':impList
    };
    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        final json = res['data'];
      //  getImportantData(json['letter_list']);
        _isLoading = false;
        _resMessage = req.body;
       
        notifyListeners();
         return req;
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
   void sendDraftLetter(
      String toMail,
      String toAddress,
      String bodyMail,
      String? header,
      String? footer,
      String? signature,
      String? stamp,
      BuildContext? context,
       String? ccMail,
        String? bccMail,
        String? subject,
        String draftId,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();


    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/send_draft_letter';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'to_mail': toMail,
      'cc_mail': ccMail,
      'bcc_mail': bccMail,
      'subject': subject,
      'letter_body': bodyMail,
      'mail_body': bodyMail,
      'address_to' : toAddress,
      'header_url_path' : header,
      'footer_url_path' : footer,
      'signature_url_path' : signature,
      'stamp_url_path' : stamp,
      'draft_id' :draftId,
    };
    print('obj--$body');
    print('BODY: ${jsonEncode(body)}');
    _isLoading? buildShowDialog(ctx!):Container();
    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);

        _isLoading = false;
        _resMessage = req.body;
        notifyListeners();
        Navigator.of(context!).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen(tabindex: 2,)));
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
  
}