import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_station/utils/constants/urls.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/utils/constants/app_constants.dart';

class UserProvider extends ChangeNotifier {
  final baseUrl = AppUrls.appBaseUrl;
  late SharedPreferences prefs;

  //setter
  bool _isLoading = false;
  String _resMessage = '';
  List<dynamic> _data = [];
  List<dynamic> _media = [];
  List<dynamic> _links = [];
  BuildContext? ctx;
  String _searchValue = '';

  //getter
  bool get isLoading => _isLoading;
  String get resMessage => _resMessage;
  List get data => _data;
  List get media => _media;
  List get links => _links;
  String get searchMediaValue => _searchValue;

  void userList({
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/get_all_user_details';
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

        // String? displayName;
        // for (var element in phoneContacts) {
        //   element.phones?.forEach((phone) {
        //     if (res.data['phone'].replaceAll(' ', '') ==
        //         phone.value!.replaceAll(' ', '')) {
        //       displayName = element.displayName;
        //     }
        //   });
        // }
        // for (var element in phoneContacts) {
        //   element.phones?.forEach((phone) {
        //     res['data'].forEach((contact) {
        //       if (contact['phone'].replaceAll(' ', '') ==
        //           phone.value!.replaceAll(' ', '')) {
        //         contact['contactName'] = element.displayName; // Replace 'contactName' with the appropriate field from the phone contact
        //       }
        //     });
        //   });
        // }
        getActualData(res['data']);
        _isLoading = false;
        _resMessage = req.body;
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

  void unblockedUserList({
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/get_user_list_unblocked';
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

        getActualData(res['list']);
        _isLoading = false;
        _resMessage = req.body;
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

  void getActualData(data) {
    _data = data;
    notifyListeners();
  }

  void getActualMedia(data) {
    _media = data;
    notifyListeners();
  }

  void getActualLinks(data) {
    _links = data;
    notifyListeners();
  }

  void userInfo({
    required String receiverId,
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    var auth = Provider.of<AuthProvider>(ctx!, listen: false);

    String url = '$baseUrl/get_individual_pofile_details';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'receiver_id': receiverId,
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

  void userMedias({
    required String receiverId,
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    var auth = Provider.of<AuthProvider>(ctx!, listen: false);

    String url = '$baseUrl/get_individual_chat_medias';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'receiver_id': receiverId,
    };
    print('BODY of MEDIA: ${jsonEncode(body)}');

    try {
      http.Response req =
          await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%[D]%%%%%%%%%%%%%%%%%%%%%%%%%%%');
        print(res);
        print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%[D]%%%%%%%%%%%%%%%%%%%%%%%%%%%');
        _isLoading = false;
        _resMessage = req.body;
        getActualMedia(res['data']['medias']);
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
      _resMessage = 'No Internet connection available!';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();

      print(':::::: $e');
    }
  }

  void blockUser({
    required String receiverId,
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/BottomBarSection';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'receiver_id': receiverId,
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
        if (res['message'] == 'success') {
          _resMessage = 'refresh';
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

  void unblockUser({
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

    try {
      http.Response req =
          await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        _isLoading = false;
        _resMessage = req.body;
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
      _resMessage = 'No Internet connection available!';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();

      print(':::::: $e');
    }
  }

  void logOut({
    BuildContext? context,
  }) async {
    _isLoading = true;
    prefs = await SharedPreferences.getInstance();
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/logOutStatus';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
    };
    print('BODY: ${jsonEncode(body)}');
    try {
      http.Response req =
          await http.post(Uri.parse(url), body: jsonEncode(body));
      print(req.body);
      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        auth.clearAll();
        _isLoading = false;
        prefs.setString('session', res['session'].toString());
        _resMessage = req.body;
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
      _resMessage = 'No Internet connection available!';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();

      print(':::::: $e');
    }
  }

  void clearData() {
    _data = [];
    notifyListeners();
  }

  void searchMedia(value) {
    _searchValue = value;
    // print(value);
    notifyListeners();
  }

  // void clearSearch() {
  //   _searchValue = '';
  //   notifyListeners();
  // }
}
