// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:smart_station/utils/constants/urls.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/providers/UserProvider/user_provider.dart';




class PrivacyProvider extends ChangeNotifier {
  final baseUrl = AppUrls.appBaseUrl;

  //setter
  bool _isLoading = false;
  String _resMessage = '';
  List<dynamic> _data = [];
  List<dynamic> _blockedLastseenUsers = [];
  int _profileStatus = 0;
  int _aboutStatus = 0;
  int _lastseenStatus =0;
  int _onlineStatus = 0;
  int _groupStatus = 0;
  String _blockCount = '';
  String _readStatus = '';
  List<dynamic> _blockedStatusUsers = [];
  final Set<int> _blockedUsersAbout = {};
  String _profileStatusMessage = '';
  String _aboutStatusMessage = '';
  String _lastseenStatusMessage = '';
  String _groupStatusMessage = '';

  BuildContext? ctx;

  //getter
  bool get isLoading => _isLoading;
  String get resMessage => _resMessage;
  int get profileStatus => _profileStatus;
  int get aboutStatus => _aboutStatus;
  int get lastseenStatus => _lastseenStatus;
  int get groupStatus => _groupStatus;
  int get onlineStatus => _onlineStatus;
  String get blockCount => _blockCount;
  String get readStatus => _readStatus;
  List get blockedStatusUsers => _blockedStatusUsers;
  Set<int> get blockedUsersAbout => _blockedUsersAbout;
  String get profileStatusMessage => _profileStatusMessage;
  String get aboutStatusMessage => _aboutStatusMessage;
  String get lastseenStatusMessage => _lastseenStatusMessage;
  String get groupStatusMessage => _groupStatusMessage;


  List get data => _data;
  List get blockedLastseenUsers => _blockedLastseenUsers;

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

  void getPrivacyDetails(
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/account_privacy_details';
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
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
        print('_readStatus22');
        print(res['data']['last_seen_status']);

        //_data = res["data"];
        _isLoading = false;
        _resMessage = req.body;
         _profileStatus = int.parse(res['data']['profile_pic_status']);
        print(_profileStatus.toString());
         _aboutStatus = int.parse(res['data']['about_status']);
        _lastseenStatus = int.parse(res['data']['last_seen_status']);
        _onlineStatus = int.parse(res['data']['online_status']);
         _groupStatus = int.parse(res['data']['groups_status']);
         _blockCount = res['data']['block_contact_count'].toString();
        _lastseenStatusMessage = res['data']['last_seen_message'];
        _aboutStatusMessage = res['data']['about_message'];
        _profileStatusMessage = res['data']['profile_pic_message'];
        _groupStatusMessage = res['data']['groups_message'];

        print(_lastseenStatus.toString());

         if(res['data']['block_contact_count']=='0'){
           _blockCount = 'None';
         }
        _readStatus = res['data']['read_receipts'].toString();
print('_readStatus');
print(_readStatus);
        getActualData([]);
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

  void setLastseenStatus(
      int options,
      String? contacts,
      String? from,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/set_view_last_seen';
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'options':options.toString(),
      'except_users':contacts,
    };

    print('BODY: ${jsonEncode(body)}');
    _isLoading ? buildShowDialog(ctx!) : Container();
    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        _isLoading = false;
        Navigator.pop(context!);
        final res = jsonDecode(req.body);
        print(res);
        if(res['status']) {
          _lastseenStatus = options;
          getPrivacyDetails(context);
          getExceptedUsersLastseen(context);
          if(from=='except'){
            Navigator.pop(context);
            Navigator.pop(context);
          }
         // showToast("Last seen status changed", context!);
        }
        notifyListeners();
      } else {
        final res = jsonDecode(req.body);
        print(':::::RRRRRR::::::$res');
        _isLoading = false;
        Navigator.pop(context!);
        notifyListeners();
      }
    } on SocketException catch (_) {
      _isLoading = false;
      Navigator.pop(context!);
      _resMessage = 'No Internet connection add available!';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      Navigator.pop(context!);
      _resMessage = 'Please try again!';
      notifyListeners();

      print(':::::: $e');
    }
  }

  void setOnlineStatus(
      int options,
      String? contacts,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/set_view_online';
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'options':options.toString(),
    };

    print('BODY: ${jsonEncode(body)}');
    _isLoading ? buildShowDialog(ctx!) : Container();
    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        Navigator.pop(context!);
        print(res);
        if(res['status']) {
          _onlineStatus = options;
          if(options==2){
            Navigator.pop(context);
            Navigator.pop(context);
          }
         // showToast("Online status changed", context!);
        }
        notifyListeners();
      } else {
        Navigator.pop(context!);
        final res = jsonDecode(req.body);
        print(':::::RRRRRR::::::$res');
        _isLoading = false;
        notifyListeners();
      }
    } on SocketException catch (_) {
      Navigator.pop(context!);
      _isLoading = false;
      _resMessage = 'No Internet connection add available!';
      notifyListeners();
    } catch (e) {
      Navigator.pop(context!);
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();

      print(':::::: $e');
    }
  }

  void setAboutStatus(
      int options,
      String? contacts,
      String? from,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/set_view_about';
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'options':options.toString(),
      'except_users':contacts,
    };

    print('BODY: ${jsonEncode(body)}');
    _isLoading ? buildShowDialog(ctx!) : Container();
    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        Navigator.pop(context!);
        final res = jsonDecode(req.body);
        print(res);
        if(res['status']) {
          getPrivacyDetails(context);
          _aboutStatus = options;
          getExceptedUsersAbout(context);
          if(options==2){

          }
          if(from=='except'){
            getExceptedUsersAbout(context);
            Navigator.pop(context);
            Navigator.pop(context);
          }
         // showToast("About status changed", context!);
        }
        notifyListeners();
      } else {
        Navigator.pop(context!);
        final res = jsonDecode(req.body);
        print(':::::RRRRRR::::::$res');
        _isLoading = false;
        notifyListeners();
      }
    } on SocketException catch (_) {
      Navigator.pop(context!);
      _isLoading = false;
      _resMessage = 'No Internet connection add available!';
      notifyListeners();
    } catch (e) {
      Navigator.pop(context!);
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();

      print(':::::: $e');
    }
  }

  void getExceptedUsersAbout(
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/get_chat_list_user_for_about';
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
    };

    print('BODY: ${jsonEncode(body)}');
   // _blockedStatusUsers=[];

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {

        final res = jsonDecode(req.body);
        print(res);
        if(res['status']) {

          // String? displayName;
          // for (var element in phoneContacts) {
          //   element.phones?.forEach((phone) {
          //     if (user.data[index]['phone'].replaceAll(' ', '') ==
          //         phone.value!.replaceAll(' ', '')) {
          //       displayName = element.displayName;
          //       user.data[index]['name'] = element.displayName;
          //     }
          //   });
          // }

          _blockedStatusUsers = res['data'];
          print(res['data']);
        //  _blockedStatusUsers = matchedItems;

          _blockedUsersAbout.clear();
          for (var user in _blockedStatusUsers) {
            _blockedUsersAbout.add(int.parse(user['user_id']));
          }

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

  void getExceptedUsersProfile(
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/get_chat_list_user_for_profile_pic';
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
    };

    print('BODY: ${jsonEncode(body)}');
    // _blockedStatusUsers=[];

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {

        final res = jsonDecode(req.body);
        print(res);
        if(res['status']) {
          _blockedStatusUsers = res['data'];
          _blockedUsersAbout.clear();
          for (var user in _blockedStatusUsers) {
            _blockedUsersAbout.add(int.parse(user['user_id']));
          }

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

  void getExceptedUsersLastseen(
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/get_chat_list_user_for_last_seen';
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
    };

    print('BODY: ${jsonEncode(body)}');
    // _blockedStatusUsers=[];

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {

        final res = jsonDecode(req.body);
        print(res);
        if(res['status']) {
          _blockedStatusUsers = res['data'];
          _blockedUsersAbout.clear();
          for (var user in _blockedStatusUsers) {
            _blockedUsersAbout.add(int.parse(user['user_id']));
          }

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

  void getExceptedUsersGroup(
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/get_chat_list_user_for_group';
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
    };

    print('BODY: ${jsonEncode(body)}');
    // _blockedStatusUsers=[];

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {

        final res = jsonDecode(req.body);
        print(res);
        if(res['status']) {
          _blockedStatusUsers = res['data'];
          _blockedUsersAbout.clear();
          for (var user in _blockedStatusUsers) {
            _blockedUsersAbout.add(int.parse(user['user_id']));
          }

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




  void setGroupStatus(
      int options,
      String? contacts,
      String? from,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/set_who_can_add_me_to_group';
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'options':options.toString(),
      'except_users':contacts,
    };

    print('BODY: ${jsonEncode(body)}');
    _isLoading ? buildShowDialog(ctx!) : Container();
    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        Navigator.pop(context!);
        final res = jsonDecode(req.body);
        print(res);
        if(res['status']) {
          _groupStatus = options;
          getPrivacyDetails(context);
          getExceptedUsersGroup(context);
          if(from=='except'){
            Navigator.pop(context);
            Navigator.pop(context);
          }
         // showToast("Group status changed", context!);
        }
        notifyListeners();
      } else {
        Navigator.pop(context!);
        final res = jsonDecode(req.body);
        print(':::::RRRRRR::::::$res');
        _isLoading = false;
        notifyListeners();
      }
    } on SocketException catch (_) {
      Navigator.pop(context!);
      _isLoading = false;
      _resMessage = 'No Internet connection add available!';
      notifyListeners();
    } catch (e) {
      Navigator.pop(context!);
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();

      print(':::::: $e');
    }
  }

  void setProfileStatus(
      int options,
      String? contacts,
      String? from,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/set_view_profile_pic';
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'options':options.toString(),
      'except_users':contacts,
    };

    print('BODY: ${jsonEncode(body)}');
    _isLoading ? buildShowDialog(ctx!) : Container();
    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        Navigator.pop(context!);
        final res = jsonDecode(req.body);
        print(res);
        if(res['status']) {
          _profileStatus = options;
          getPrivacyDetails(context);
          getExceptedUsersProfile(context);
          if(from=='except'){
            Navigator.pop(context);
            Navigator.pop(context);
          }
         // showToast("Profilepic status changed", context!);
        }
        notifyListeners();
      } else {
        Navigator.pop(context!);
        final res = jsonDecode(req.body);
        print(':::::RRRRRR::::::$res');
        _isLoading = false;
        notifyListeners();
      }
    } on SocketException catch (_) {
      Navigator.pop(context!);
      _isLoading = false;
      _resMessage = 'No Internet connection add available!';
      notifyListeners();
    } catch (e) {
      Navigator.pop(context!);
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();

      print(':::::: $e');
    }
  }

  void setReadStatus(
      String status,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/set_read_receipts';
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'status':status,
    };

    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        if(res['status']) {
          _readStatus = status;
         // showToast("Read Receipts successfully changed", context!);
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

  void blockUser({
    required String name,
    required String receiverId,
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/block_user_chat';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'receiver_id': receiverId,
    };

    print('BODY: ${jsonEncode(body)}');
    _isLoading ? buildShowDialog(ctx!) : Container();
    try {

      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        Navigator.pop(context!);
        final res = jsonDecode(req.body);
        print(res);
        _isLoading = false;
        _resMessage = req.body;
        // _name = name;
        if (res['message'] == 'success') {
          _resMessage = 'refresh';
          if(res['status']){
            showToast('$name has been blocked', context);
            blockedUserList(context:context);
            Navigator.pop(context);

          }

        }
        else{
          showToast(res['message'], context);
        }
        notifyListeners();
      } else {
        Navigator.pop(context!);
        final res = jsonDecode(req.body);
        print(':::::RRRRRR::::::$res');
        _isLoading = false;
        notifyListeners();
      }
    } on SocketException catch (_) {
      Navigator.pop(context!);
      _isLoading = false;
      _resMessage = 'No Internet connection available!';
      notifyListeners();
    } catch (e) {
      Navigator.pop(context!);
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();

      print(':::::: $e');
    }
  }

  void unBlockUser({
    required String name,
    required String receiverId,
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/un_block_user_chat';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'receiver_id': receiverId,
    };

    print('BODY: ${jsonEncode(body)}');
    _isLoading ? buildShowDialog(ctx!) : Container();
    try {

      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        Navigator.pop(context!);
        final res = jsonDecode(req.body);
        print(res);
        _isLoading = false;
        _resMessage = req.body;
        // _name = name;
        if (res['message'] == 'success') {
          _resMessage = 'refresh';
          if(res['status']){
            showToast('$name has been unblocked', context);
            blockedUserList(context:context);
            notifyListeners();
           // Navigator.pop(context);

          }

        }
        else{

          showToast(res['message'], context);
        }
        notifyListeners();
      } else {
        Navigator.pop(context!);
        final res = jsonDecode(req.body);
        print(':::::RRRRRR::::::$res');
        _isLoading = false;
        notifyListeners();
      }
    } on SocketException catch (_) {
      Navigator.pop(context!);
      _isLoading = false;
      _resMessage = 'No Internet connection available!';
      notifyListeners();
    } catch (e) {
      Navigator.pop(context!);
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
  void getActualBlockedData(data) {
    _blockedStatusUsers = data;
    notifyListeners();
  }

  void blockedUserList({
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/blockedcontact_list';
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
        print('::::::[DETAILS]::::::');
        print(res['data'].runtimeType);
        print('::::::[DETAILS]::::::');
        print(res['count']);
        if(res['count']!=null){
        getActualData(res['list']);
        _isLoading = false;
        _resMessage = req.body;
        _data=res['list'];
        _blockCount = _data.length.toString();
        // _name = name;
        notifyListeners();}
        else{
          getActualData([]);
          _isLoading = false;
          _resMessage = req.body;
          _data=[];
          _blockCount ="None";
        }
        // Navigator.of(context!).push(MaterialPageRoute(builder: (context) => UserList()));
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

  void blockedLastseenUserList({
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider >(ctx!,listen: false);
    String url = '$baseUrl/get_view_last_seen_and_online';
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
        print('::::::[DETAILS]::::::');
        print(res['data'].runtimeType);
        print('::::::[DETAILS]::::::');

        _isLoading = false;
        _resMessage = req.body;
        var lastseen = res['data'][0];
        _blockedLastseenUsers=lastseen['except_users'];
        _blockCount = _data.length.toString();
        // _name = name;
        notifyListeners();
        // Navigator.of(context!).push(MaterialPageRoute(builder: (context) => UserList()));
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


  //


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