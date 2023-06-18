// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:smart_station/utils/constants/urls.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';



class AccountProvider extends ChangeNotifier {
  final baseUrl = AppUrls.appBaseUrl;

  //setter
  bool _isLoading = false;
  bool _phoneOtpStatus = false;
  bool _newPhoneStatus = false;
  String _phoneOtp = '';
  String _resMessage = '';
  String _publicStatus = '';
  List<dynamic> _data = [];
  List<dynamic> _headData = [];
  List<dynamic> _footData = [];
  List<dynamic> _signData = [];
  List<dynamic> _stampData = [];
  BuildContext? ctx;

  //getter
  bool get isLoading => _isLoading;
  bool get phoneOtpStatus => _phoneOtpStatus;
  bool get newPhoneStatus => _newPhoneStatus;
  String get phoneOtp => _phoneOtp;
  String get resMessage => _resMessage;
  List get data => _data;
  List get headData => _headData;
  List get footData => _footData;
  List get signData => _signData;
  List get stampData => _stampData;
  String get publicStatus => _publicStatus;

  void showToast(String message,BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        width: MediaQuery.of(context).size.width-50,
        content: Center(child: Text(message,style: const TextStyle(color: Colors.white),)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  void resetOldOtp({
    BuildContext? context,
  }) async {

    _phoneOtpStatus = false;
    _newPhoneStatus = false;
    _phoneOtp = '';
    ctx = context;
    notifyListeners();
  }


  Future sendOldPhoneOtp({
    required String phone,
    required String country,
    BuildContext? context,
  }) async {

    ctx = context;
    notifyListeners();

    String url = '$baseUrl/change_mobile_verification';
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'old_phone': phone,
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
        _isLoading = true;
        _phoneOtpStatus = true;
        _phoneOtp = res['otp'].toString();
        var message = res['message'].toString();
        var status = res['status'];
        if(status==false) {
          _phoneOtpStatus = false;
          notifyListeners();
          ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        width: MediaQuery.of(context).size.width-50,
        content: Center(child: Text(message,textAlign: TextAlign.center,style: const TextStyle(color: Colors.white),)),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
          
          // showDialog(
          //   context: context!,
          //   builder: (context) => AlertDialog(
          //     // title: Text('Result'),
          //     content: Text("Enter a valid Phone number/ Country code missing"),
          //     actions: [
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.end,
          //         children: [
          //           InkWell(
          //             onTap: () {
          //               Navigator.pop(context);
          //             },
          //             child: Padding(
          //               padding: const EdgeInsets.all(10.0),
          //               child: Text("Okay",style: TextStyle(color: textGreen),),
          //             ),
          //           )
          //         ],
          //       )
          //     ],
          //   ),
          // );
        }
        
        notifyListeners();
        return req;
      } else {
        final res = jsonDecode(req.body);
        var message = res['message'].toString();
       ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        width: MediaQuery.of(context).size.width-50,
        content: Center(child: Text(message,style: const TextStyle(color: Colors.white),)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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

  Future sendNewPhoneOtp({
    required String phone,
    required String country,
    BuildContext? context,
  }) async {
    _isLoading = true;
    _phoneOtpStatus = true;
    _phoneOtp='';
    ctx = context;

    String url = '$baseUrl/change_mobile_number';
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
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
        _phoneOtpStatus = true;
        _phoneOtp = res['otp'].toString();
        var message = res['message'].toString();
        var status = res['status'];
        if(status==false) {
          _phoneOtpStatus = false;
          ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        width: MediaQuery.of(context).size.width-50,
        content: Center(child: Text(message,textAlign: TextAlign.center,style: const TextStyle(color: Colors.white),)),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
        }

        notifyListeners();
        return req;
      } else {
        final res = jsonDecode(req.body);
        var message = res['message'].toString();
        ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        width: MediaQuery.of(context).size.width-50,
        content: Center(child: Text(message,style: const TextStyle(color: Colors.white),)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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


  void verifyOldPhoneOtp({
    required String otp,
    //required String country,
    BuildContext? context,
  }) async {

    _isLoading = true;

    ctx = context;
    notifyListeners();

    String url = '$baseUrl/changephone_otp_verify';
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'otp': otp,
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
        _phoneOtpStatus = true;
        _newPhoneStatus = true;
        _phoneOtp = '';
        var message = res['message'].toString();
        var status = res['status'];
        if(status==false) {
         ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        width: MediaQuery.of(context).size.width-50,
        content: Center(child: Text(message,style: const TextStyle(color: Colors.white),)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
        }
       /* AlertDialog(
          title: const Text('Basic dialog title'),
          content: const Text('A dialog is a type of modal window that\n'
              'appears in front of app content to\n'
              'provide critical information, or prompt\n'
              'for a decision to be made.'),
          actions: <Widget>[
           /* TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Disable'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Enable'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),*/
          ],
        );*/

        notifyListeners();

      } else {
        final res = jsonDecode(req.body);
        print(':::::RRRRRR::::::$res');
        var message = res['message'].toString();
        ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        width: MediaQuery.of(context).size.width-50,
        content: Center(child: Text(message,style: const TextStyle(color: Colors.white),)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
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

  void verifyNewPhoneOtp({
    required String otp,
    //required String country,
    BuildContext? context,
  }) async {

    _isLoading = true;

    ctx = context;
    notifyListeners();

    String url = '$baseUrl/changephone_otp_verify';
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'otp': otp,
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
        _phoneOtpStatus = false;
        _phoneOtp = '';
        notifyListeners();
        var message = res['message'].toString();
        var status = res['status'];
        if(status==true){
          showDialog(
            context: context!,
            builder: (context) => AlertDialog(
              title: const Text('Result'),
              content: Text(message),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    // pop the current screen
                   // Navigator.pop(context!);
                   // Navigator.of(context).pop();
                    final navigator = Navigator.maybeOf(context);
                    if (navigator != null) {
                      navigator.pop();
                    }
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );

        }
        else {
          showDialog(
            context: context!,
            builder: (context) =>
                AlertDialog(
                  // title: Text('Result'),
                  content: Text(message),
                ),
          );
        }
       // Navigator.pop(context!);
      } else {
        final res = jsonDecode(req.body);
        print(':::::RRRRRR::::::$res');
        var message = res['message'].toString();
        showDialog(
          context: context!,
          builder: (context) => AlertDialog(
            // title: Text('Result'),
            content: Text(message),
          ),
        );
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


  void getActualData(data) {
    _data = data;
    notifyListeners();
  }
  void getActualHeaderData(data) {
    _headData = data;
    notifyListeners();
  }
  void getActualFooterData(data) {
    _footData = data;
    notifyListeners();
  }
  void getActualSignData(data) {
    _signData = data;
    notifyListeners();
  }
  void getActualStampData(data) {
    _stampData = data;
    notifyListeners();
  }
  void changePrivacyStatus(
      String? accessToken,
      String? userId,
      String? status,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/update_profile_public_status';
    final body = {
      'accessToken': accessToken,
      'user_id': userId,
      'status': status,
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
        _publicStatus = res['privacy_status'];
        getPrivacyStatus(context);
        aProvider.getaccessToken(accessToken, userId,publicStatus,aProvider.securityStatus);
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

  void getPrivacyStatus(
     BuildContext? context,
  ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/get_privacy_status';
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
        var aProvider = Provider.of<AuthProvider>(ctx!, listen: false);
        _isLoading = false;
        _resMessage = req.body;
         _publicStatus = res['privacy_status'];
        aProvider.getaccessToken(
            auth.accessToken, auth.userId, _publicStatus, aProvider.securityStatus);
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



  //.............Security

  void updateSecurityPin(
      String? accessToken,
      String? userId,
      String? pin,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/securityupdate';
    final body = {
      'accessToken': accessToken,
      'user_id': userId,
      'security_pin': pin,
    };

    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        print(res['message']);
        _isLoading = false;
        _resMessage = req.body;
        if(res['status']==false){
            ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        width: MediaQuery.of(context).size.width-50,
        content: Center(child: Text(res['message'],style: const TextStyle(color: Colors.white),)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
        }
        else{
            ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        width: MediaQuery.of(context).size.width-50,
        content: Center(child: Text(res['message'],style: const TextStyle(color: Colors.white),)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
        getSecurityPin(accessToken, userId, context).then((value) => Navigator.pop(context,'Refresh'));
        }// _name = name;
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

  Future checkSecurityPin(
      String? accessToken,
      String? userId,
      String? pin,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/checksecuritypin';
    final body = {
      'accessToken': accessToken,
      'user_id': userId,
      'security_pin': pin,
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
        // _name = name;
        if(res['status']==false){
           ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        width: MediaQuery.of(context).size.width-50,
        content: Center(child: Text(res['message'],style: const TextStyle(color: Colors.white),)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
        }
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

  void deactivateSecurityPin(
      String? accessToken,
      String? userId,
      String? pin,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/removesecuritypin';
    final body = {
      'accessToken': accessToken,
      'user_id': userId,
      'security_pin': pin,
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
        if(res['status']==false){
           ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        width: MediaQuery.of(context).size.width-50,
        content: Center(child: Text(res['message'],style: const TextStyle(color: Colors.white),)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
        }
        else {
            ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        width: MediaQuery.of(context).size.width-50,
        content: Center(child: Text(res['message'],style: const TextStyle(color: Colors.white),)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
          getSecurityPin(accessToken, userId, context).then((value) => Navigator.pop(context,'Refresh'));
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

//.............Header

  void uploadHeader(
      String? accessToken,
      String? userId,
      String? name,
      File? ftr,
      BuildContext? context,
      )

  async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/header_upload';

    _isLoading ? buildShowDialog(ctx!) : Container();
    try {
      var stream = http.ByteStream(ftr!.openRead());
      var length = await ftr.length();
      var request = http.MultipartRequest('POST', Uri.parse(url));
      var multipartFile = http.MultipartFile('header', stream, length,
          filename: ftr.path);
      request.fields['user_id'] = userId!;
      request.fields['accessToken'] = accessToken!;
      request.fields['name'] = name!;
      request.files.add(multipartFile);
      var resp = await request.send();
      resp.stream.transform(utf8.decoder).listen((event) {
        var finalData = jsonDecode(event);
        // _profilePic = finalData['data']['profile_pic'];
        notifyListeners();
        if (finalData['statuscode'] == 200) {
          // Navigator.of(context!).pushReplacement(
          //     MaterialPageRoute(builder: (context) => FooterHome()));
          var status = finalData['status'];
          var message = finalData['message'];
         // getHeader(context);
          _isLoading = false;
         // Navigator.pop(context!);
          if(status){
            getHeader(context);
            _isLoading = false;
            Navigator.pop(context!);
          showToast('Header added successfully.',context);}
          else{
            showToast(message,context!);
          }

          notifyListeners();
          //Navigator.of(context!).pushReplacement(
          //    MaterialPageRoute(builder: (context) => HeaderHome()));
          Navigator.pop(context);
        }
        print('::::::[RESPONSE]::::::');
        print(finalData);
        print('::::::[RESPONSE]::::::');
      });
    } on SocketException catch (_) {
      _isLoading = false;
      _resMessage = 'No Internet connection add available!';
      showToast(_resMessage,context!);
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = 'Please try again!';
      showToast(_resMessage,context!);
      notifyListeners();

      print(':::::: $e');
    }
  }

  void getHeader(
     context
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
  var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/getheader';
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
        getActualHeaderData(res['data']);
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

  void setDefaultHeader(
      String? id,
      String? name,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/set_default_header';
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
        print(res);
       // getActualData(res['data']);
        _isLoading = false;
        // ignore: unused_local_variable
        _resMessage = req.body;var message = res['message'];

          // showDialog(
          //   context: context!,
          //   builder: (context) => AlertDialog(
          //     // title: Text('Result'),
          //     content: Text(message),
          //   ),
          // );
          showToast('${name!} Set to Primary', context!);
        Navigator.pop(context, 'Cancel');
        getHeader(context);

        notifyListeners();

        // showDialog(
        //   context: context!,
        //   builder: (context) => AlertDialog(
        //     // title: Text('Result'),
        //     content: Text(message),
        //   ),
        // ).then((value) {
        //   // Call setState to refresh the view
        //   getHeader(context);
        //   notifyListeners();
        // });






      } else {
        final res = jsonDecode(req.body);
        print(':::::RRRRRR::::::$res');
        _isLoading = false;
        Navigator.pop(context!, 'Cancel');
        notifyListeners();
      }
    } on SocketException catch (_) {
      _isLoading = false;
      _resMessage = 'No Internet connection add available!';
      Navigator.pop(context!, 'Cancel');
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = 'Please try again!';
      Navigator.pop(context!, 'Cancel');
      notifyListeners();

      print(':::::: $e');
    }
  }

  void removeHeader(
      String? id,
      BuildContext? context,
      ) async {

    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/removeheader';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'header_id': id,
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
        var message = res['message'];
        if(res['status']==false){
          showToast(message, context!);
        }
        else {
          showToast('Deleted successfully', context!);
          Navigator.pop(context, 'Cancel');
          getHeader(context);
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

//.............Footer

  void uploadFooter(
      String? accessToken,
      String? userId,
      String? name,
      File? ftr,
      BuildContext? context,
      )
      async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/footer_upload';
    // final body = {
    //   "accessToken": accessToken,
    //   "user_id": userId,
    //   "name": name,
    // };
    //
    // print("BODY: ${jsonEncode(body)}");
    // try {
    //   http.Response req =
    //   await http.post(Uri.parse(url), body: jsonEncode(body));
    //
    //   if (req.statusCode == 200 || req.statusCode == 201) {
    //     final res = jsonDecode(req.body);
    //     print(res);
    //     _isLoading = false;
    //     _resMessage = req.body;
    //     // _name = name;
    //     notifyListeners();
    //   } else {
    //     final res = jsonDecode(req.body);
    //     print(':::::RRRRRR::::::${res}');
    //     _isLoading = false;
    //     notifyListeners();
    //   }
    // } on SocketException catch (_) {
    //   _isLoading = false;
    //   _resMessage = "No Internet connection add available!";
    //   notifyListeners();
    // } catch (e) {
    //   _isLoading = false;
    //   _resMessage = "Please try again!";
    //   notifyListeners();
    //
    //   print(":::::: $e");
    // }
    _isLoading ? buildShowDialog(ctx!) : Container();
    try {
      var stream = http.ByteStream(ftr!.openRead());
      var length = await ftr.length();
      var request = http.MultipartRequest('POST', Uri.parse(url));
      var multipartFile = http.MultipartFile('footer', stream, length,
          filename: ftr.path);
      request.fields['user_id'] = userId!;
      request.fields['accessToken'] = accessToken!;
      request.fields['name'] = name!;
      request.files.add(multipartFile);
      var resp = await request.send();
      resp.stream.transform(utf8.decoder).listen((event) {
        var finalData = jsonDecode(event);
        // _profilePic = finalData['data']['profile_pic'];

        _isLoading = false;
        notifyListeners();
        if (finalData['statuscode'] == 200)
          // ignore: curly_braces_in_flow_control_structures
          if (finalData['statuscode'] == 200) {
            // Navigator.of(context!).pushReplacement(
            //     MaterialPageRoute(builder: (context) => FooterHome()));
            var status = finalData['status'];
            var message = finalData['message'];
            // getHeader(context);
            _isLoading = false;
            // Navigator.pop(context!);
            if(status){
              getFooter(context);
              _isLoading = false;
              Navigator.pop(context!);
              showToast('Footer added successfully.',context);}
            else{
              showToast(message,context!);
            }

            notifyListeners();
            //Navigator.of(context!).pushReplacement(
            //    MaterialPageRoute(builder: (context) => HeaderHome()));
            Navigator.pop(context);
          }
        // {
        //   // Navigator.of(context!).pushReplacement(
        //   //     MaterialPageRoute(builder: (context) => FooterHome()));
        //   // getFooter(context);
        //   // notifyListeners();
        //   // Navigator.pop(context!);
        //
        //   var status = finalData["status"];
        //   var message = finalData["message"];
        //   // getHeader(context);
        //   _isLoading = false;
        //   // Navigator.pop(context!);
        //   if(status){
        //     getFooter(context);
        //     _isLoading = false;
        //     Navigator.pop(context!);
        //     showToast("Footer added successfully.",context!);}
        //   else{
        // _isLoading = false;
        //     showToast(message,context!);
        //   }
        // }
        print('::::::[RESPONSE]::::::');
        print(finalData);
        print('::::::[RESPONSE]::::::');
      });
    } on SocketException catch (_) {
      _isLoading = false;
      _resMessage = 'No Internet connectiongit add available!';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();

      print(':::::: $e');
    }
  }

  void getFooter(
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    notifyListeners();

    String url = '$baseUrl/getfooter';
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
        getActualFooterData(res['data']);
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

  void setDefaultFooter(
      String? id,
      String? name,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/set_default_footer';
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
        print(res);
        _isLoading = false;
        _resMessage = req.body;
        showToast('${name!} Set to Primary', context!);
        Navigator.pop(context, 'Cancel');
        getFooter(context);
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

  void removeFooter(
      String? id,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/removefooter';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'footer_id': id,
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
        var message = res['message'];

          if(res['status']==false){
            showToast(message, context!);
          }
          else {


            showToast('Deleted successfully', context!);
            Navigator.pop(context, 'Cancel');
            getFooter(context);
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

  //.............Signature

  void uploadSignature(
      String? accessToken,
      String? userId,
      String? name,
      File? ftr,
      // image? signature,
      BuildContext? context,
      )
  async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/signatureupload';

    _isLoading ? buildShowDialog(ctx!) : Container();
    try {
      var stream = http.ByteStream(ftr!.openRead());
      var length = await ftr.length();
      var request = http.MultipartRequest('POST', Uri.parse(url));
      var multipartFile = http.MultipartFile('signature', stream, length,
          filename: ftr.path);
      request.fields['user_id'] = userId!;
      request.fields['accessToken'] = accessToken!;
      request.fields['name'] = name!;
      request.files.add(multipartFile);
      var resp = await request.send();
      resp.stream.transform(utf8.decoder).listen((event) {
        var finalData = jsonDecode(event);
        // _profilePic = finalData['data']['profile_pic'];
        notifyListeners();
        if (finalData['statuscode'] == 200) {
          // Navigator.of(context!).pushReplacement(
          //     MaterialPageRoute(builder: (context) => FooterHome()));
          var status = finalData['status'];
          var message = finalData['message'];
          // getHeader(context);
          _isLoading = false;
          // Navigator.pop(context!);
          if(status){
            getSignature(context);
            _isLoading = false;
            Navigator.pop(context!);
            showToast('Signature added successfully.',context);}
          else{
            showToast(message,context!);
          }

          notifyListeners();
          //Navigator.of(context!).pushReplacement(
          //    MaterialPageRoute(builder: (context) => HeaderHome()));
          Navigator.pop(context);
        }
        print('::::::[RESPONSE]::::::');
        print(finalData);
        print('::::::[RESPONSE]::::::');
      });
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

  void getSignature(
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/getsignature';
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
        getActualSignData(res['data']);
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

  void setDefaultSignature(
      String? id,
      String? name,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/set_default_signature';
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
        print(res);
        // getActualData(res['data']);
        _isLoading = false;
        // ignore: unused_local_variable
        _resMessage = req.body;var message = res['message'];

        showToast('${name!} Set to Primary', context!);
        Navigator.pop(context, 'Cancel');
        getSignature(context);

        notifyListeners();

      } else {
        final res = jsonDecode(req.body);
        print(':::::RRRRRR::::::$res');
        _isLoading = false;
        Navigator.pop(context!, 'Cancel');
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


  void removeSignature(
      String? id,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/removesignature';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'image_id': id,
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
        var message = res['message'];
        if(res['status']==false){
          showToast(message, context!);
        }
        else {
          showToast('Deleted successfully', context!);
          Navigator.pop(context, 'Cancel');
          getSignature(context);
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

  //.............Stamp

  void uploadStamp(
      String? accessToken,
      String? userId,
      String? name,
      File? ftr,
      // image? stamp,
      BuildContext? context,
      )
     async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/stamp_upload';

    _isLoading ? buildShowDialog(ctx!) : Container();
    try {
      var stream = http.ByteStream(ftr!.openRead());
      var length = await ftr.length();
      var request = http.MultipartRequest('POST', Uri.parse(url));
      var multipartFile = http.MultipartFile('stamp', stream, length,
          filename: ftr.path);
      request.fields['user_id'] = userId!;
      request.fields['accessToken'] = accessToken!;
      request.fields['name'] = name!;
      request.files.add(multipartFile);
      var resp = await request.send();
      resp.stream.transform(utf8.decoder).listen((event) {
        var finalData = jsonDecode(event);
        // _profilePic = finalData['data']['profile_pic'];
        notifyListeners();
        if (finalData['statuscode'] == 200) {
          // Navigator.of(context!).pushReplacement(
          //     MaterialPageRoute(builder: (context) => FooterHome()));
          var status = finalData['status'];
          var message = finalData['message'];
          // getHeader(context);
          _isLoading = false;
          // Navigator.pop(context!);
          if(status){
            getStamp(context);
            _isLoading = false;
            Navigator.pop(context!);
            showToast('Stamp added successfully.',context);}
          else{
            showToast(message,context!);
          }

          notifyListeners();
          //Navigator.of(context!).pushReplacement(
          //    MaterialPageRoute(builder: (context) => HeaderHome()));
          Navigator.pop(context);
        }
        print('::::::[RESPONSE]::::::');
        print(finalData);
        print('::::::[RESPONSE]::::::');
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

  void getStamp(
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/getstamp';
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
        getActualStampData(res['data']);
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

  void setDefaultStamp(
      String? id,
      String? name,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/set_default_stamp';
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
        print(res);
        // getActualData(res['data']);
        var status = res['status'];
        _isLoading = false;
        _resMessage = req.body;var message = res['message'];

        if(status==false){
          showToast(message, context!);
        }
        else{
          getStamp(context);
        showToast('${name!} Set to Primary', context!);}
        Navigator.pop(context, 'Cancel');


        notifyListeners();

      } else {
        final res = jsonDecode(req.body);
        print(':::::RRRRRR::::::$res');
        _isLoading = false;
        Navigator.pop(context!, 'Cancel');
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

  void removeStamp(
      String? id,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/removestamp';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'stamp_id': id,
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
        var message = res['message'];
        if(res['status']==false){
          showToast(message, context!);
        }
        else {
          showToast('Deleted successfully', context!);
          Navigator.pop(context, 'Cancel');
          getStamp(context);
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
   Future getSecurityPin(
      String? accessToken,
      String? userId,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/get_security_status';
    final body = {
      'accessToken': accessToken,
      'user_id': userId,
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
        var auth = Provider.of<AuthProvider>(ctx!, listen: false);
        var securityStatus= res['data']['security_status'];
        auth.getaccessToken(accessToken, userId,publicStatus,securityStatus);
        // _name = name;
        notifyListeners();
        return res;
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
    Future checkNewPhoneOtpVerify({
    required String otp,
    required String newPhone,
    required String country,
    BuildContext? context,
  }) async {

    _isLoading = true;

    ctx = context;
    notifyListeners();

    String url = '$baseUrl/checknewphone_otp_verify';
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'otp': otp,
      'new_phone': newPhone,
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
        _phoneOtpStatus = false;
        _phoneOtp = '';
        notifyListeners();
        var message = res['message'].toString();
        var status = res['status'];
        if(status==true){
          ScaffoldMessenger.of(context!).showSnackBar(
          SnackBar(
            width: MediaQuery.of(context).size.width-50,
            content: Center(child: Text(message,style: const TextStyle(color: Colors.white),)),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        );
                          
          // showDialog(
          //   context: context!,
          //   builder: (context) => AlertDialog(
          //     title: Text('Result'),
          //     content: Text(message),
          //     actions: [
          //       ElevatedButton(
          //         onPressed: () {
          //           // pop the current screen
          //          // Navigator.pop(context!);
          //          // Navigator.of(context).pop();
          //           final navigator = Navigator.maybeOf(context);
          //           if (navigator != null) {
          //             navigator.pop();
          //           }
          //         },
          //         child: Text('OK'),
          //       ),
          //     ],
          //   ),
          // );

        }
        else {
            ScaffoldMessenger.of(context!).showSnackBar(
              SnackBar(
                width: MediaQuery.of(context).size.width-50,
                content: Center(child: Text(message,style: const TextStyle(color: Colors.white),)),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
          // showDialog(
          //   context: context!,
          //   builder: (context) =>
          //       AlertDialog(
          //         // title: Text('Result'),
          //         content: Text(message),
          //       ),
          // );
        }
        return req;
       // Navigator.pop(context!);
      } else {
        final res = jsonDecode(req.body);
        print(':::::RRRRRR::::::$res');
        var message = res['message'].toString();
       ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        width: MediaQuery.of(context).size.width-50,
        content: Center(child: Text(message,style: const TextStyle(color: Colors.white),)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
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

  buildShowDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(leftGreen),
            )
          );
        });
  }

}