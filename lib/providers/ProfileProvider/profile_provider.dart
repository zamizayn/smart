// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_station/screens/home_screen/home_screen.dart';
import 'package:smart_station/utils/constants/urls.dart';

class ProfileProvider extends ChangeNotifier {
  final baseUrl = AppUrls.appBaseUrl;

  //setter
  bool _isLoading = false;
  String _resMessage = '';
  String _name = '';
  String _email = '';
  String _about = '';
  String _profilePic = '';
  String _filePath = '';
  String _halfPath = '';
  String _profileHalfPath = '';
  String _companyMail = '';
  String _phNumber = '';
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController aboutController = TextEditingController();

  BuildContext? ctx;

  //getter
  bool get isLoading => _isLoading;

  String get resMessage => _resMessage;

  String get name => _name;

  String get email => _email;

  String get about => _about;

  String get profilePic => _profilePic;

  String get filePath => _filePath;

  String get halfPath => _halfPath;

  String get profileHalfPath => _profileHalfPath;

  String get companyMail => _companyMail;

  String get phNumber => _phNumber;

  void addUser({
    String? name,
    String? image,
    String? accessToken,
    String? userId,
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/profileupdate';
    var body = {
      'accessToken': accessToken,
      'user_id': userId,
      'name': name,
      'profile_pic': image
    };

    try {
      http.Response req = await http.post(Uri.parse(url), body: body);

      if (req.statusCode == 200 || req.statusCode == 201) {
        var finalData = jsonDecode(req.body);
        _profilePic = finalData['data']['profile_pic'];
        notifyListeners();
        Navigator.of(context!).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
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

  void getProfile({
    required accessTok,
    required userId,
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/getprofile';
    final body = {
      'accessToken': accessTok,
      'user_id': userId,
    };

    try {
      http.Response req = await http.post(Uri.parse(url), body: body);
      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print('::::::[GET]::::::');
        print(res);
        print('::::::[GET]::::::');
        _isLoading = false;
        _resMessage = req.body;
        getPic(res['data']);
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

  void getPic(data) {
    _profilePic = data['profile_pic'];
    _profileHalfPath = data['half_path'];
    _name = data['name'];
    _email = data['email'];
    _about = data['about'];
    _companyMail = data['company_mail'];
    _phNumber = data['phone'];
    nameController.text = _name;
    emailController.text = _email;
    aboutController.text = _about;
    notifyListeners();
  }

  void editUser({
    required String userId,
    required String accessToken,
    required String name,
    required String email,
    required String about,
    String? profile_pic,
    BuildContext? context,
  }) async {
    print("sujina");
    _isLoading = true;
    ctx = context;
    notifyListeners();
    String url = '$baseUrl/editProfile';
    final body = {
      'accessToken': accessToken,
      'user_id': userId,
      'name': name,
      'email': email,
      'about': about,
      'profile_pic': profile_pic
    };
    print(body);
    try {
      http.Response req = await http.post(Uri.parse(url), body: body);

      if (req.statusCode == 200 || req.statusCode == 201) {
        _isLoading = false;
        _resMessage = req.body;
        // Navigator.of(ctx!).pushReplacement(MaterialPageRoute(builder: (_) => SettingsScreen(ctxt: ctx!)));

        notifyListeners();
        var res = jsonDecode(req.body);
        print(res);
        var status = res['status'].toString();
        var message = res['message'].toString();
        print('status-----$status');
        if (status == 'true') {
          Navigator.pop(ctx!, 'Refresh');
        }
        ScaffoldMessenger.of(ctx!).showSnackBar(
          SnackBar(
            width: MediaQuery.of(context!).size.width - 50,
            content: Center(
                child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            )),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
        print('::::::[Res Update]::::::');
        print(res);
        print('::::::[Res Update]::::::');
      }
    } on SocketException catch (_) {
      _isLoading = false;
      _resMessage = 'No Internet connectiongit add available!';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = 'Please Try Again!';
      notifyListeners();
    }
  }

  void removeProfilePicture({
    required accessTok,
    required userId,
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/remove_profilepic';
    final body = {'accessToken': accessTok, 'user_id': userId};

    try {
      http.Response req = await http.post(Uri.parse(url), body: body);
      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print('::::::[GET]::::::');
        print(res);
        print('::::::[GET]::::::');
        _isLoading = false;
        _resMessage = req.body;
        getProfile(accessTok: accessTok, userId: userId);
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

  void fileUpload(
    File? ftr,
    final String accessToken,
    final String userId,
    BuildContext? context,
  ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    // var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/fileupload';

    try {
      var stream = http.ByteStream(ftr!.openRead());
      var length = await ftr.length();
      var request = http.MultipartRequest('POST', Uri.parse(url));
      var multipartFile =
          http.MultipartFile('file', stream, length, filename: ftr.path);
      print('$userId\n$accessToken\n$multipartFile');
      request.fields['user_id'] = userId;
      request.fields['accessToken'] = accessToken;
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
          getPath(finalData);
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

  Future fileUpload2(
    File? ftr,
    final String accessToken,
    final String userId,
    BuildContext? context,
  ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    // var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/fileupload';

    try {
      var stream = http.ByteStream(ftr!.openRead());
      var length = await ftr.length();
      var request = http.MultipartRequest('POST', Uri.parse(url));
      var multipartFile =
          http.MultipartFile('file', stream, length, filename: ftr.path);
      print('$userId\n$accessToken\n$multipartFile');
      request.fields['user_id'] = userId;
      request.fields['accessToken'] = accessToken;
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
          getPath(finalData);

          // return finalData;
          notifyListeners();
          return finalData;
        } else {
          return finalData;
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

  void getPath(data) {
    _filePath = data['filepath'];
    _halfPath = data['path'];
    notifyListeners();
  }

  void updateProfilePicture(
    File? ftr,
    final String accessToken,
    final String userId,
    BuildContext? context,
  ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    // var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/updateProfilePic';

    try {
      var stream = http.ByteStream(ftr!.openRead());
      var length = await ftr.length();
      var request = http.MultipartRequest('POST', Uri.parse(url));
      var multipartFile =
          http.MultipartFile('profile_pic', stream, length, filename: ftr.path);
      print('$userId\n$accessToken\n$multipartFile');
      request.fields['user_id'] = userId;
      request.fields['accessToken'] = accessToken;
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
          ScaffoldMessenger.of(ctx!).showSnackBar(
            SnackBar(
              width: 200,
              content: const Center(
                  child: Text(
                'Profile photo updated',
                style: TextStyle(color: Colors.white),
              )),
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
          Navigator.pop(ctx!, 'Refresh');
          //getPath(finalData);
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
  //   void updateProfilePicture({
  //   required accessTok,
  //   required userId,
  //   required profile_pic,
  //   BuildContext? context,
  // }) async {
  //   _isLoading = true;
  //   ctx = context;
  //   notifyListeners();

  //   String url = "$baseUrl/updateProfilePic";
  //   final body = {
  //     "accessToken": accessTok,
  //     "user_id": userId,
  //     "profile_pic":profile_pic
  //   };
  //   print("obj----$body");
  //   try {
  //     http.Response req = await http.post(Uri.parse(url), body: body);
  //     if (req.statusCode == 200 || req.statusCode == 201) {
  //       final res = jsonDecode(req.body);
  //       print("::::::[GET]::::::");
  //       print(res);
  //       print("::::::[GET]::::::");
  //       _isLoading = false;
  //       _resMessage = req.body;
  //       notifyListeners();
  //     } else {

  //       final res = jsonDecode(req.body);
  //       print(':::::RRRRRR::::::${res}');
  //       _isLoading = false;
  //       notifyListeners();
  //     }
  //   } on SocketException catch (_) {
  //     _isLoading = false;
  //     _resMessage = "No Internet connection available!";
  //     notifyListeners();
  //   } catch (e) {
  //     _isLoading = false;
  //     _resMessage = "Please try again!";
  //     notifyListeners();

  //     print(":::::: $e");
  //   }
  // }
}
