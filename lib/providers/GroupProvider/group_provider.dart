// ignore_for_file: unused_field, prefer_typing_uninitialized_variables, unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_station/utils/constants/urls.dart';
import 'package:smart_station/screens/home_screen/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';

import '../../utils/constants/app_constants.dart';

class GroupProvider extends ChangeNotifier {
  final baseUrl = AppUrls.appBaseUrl;
  late SharedPreferences prefs;

  //setter
  bool _isLoading = false;
  String _resMessage = '';
  List<dynamic> _media = [];
  List<dynamic> _data = [];
  String _fileUrl = '';
  var realGrpInfo;
  BuildContext? ctx;
  String gropId = '';

  final IO.Socket _socket = IO.io(AppUrls.appSocketUrl,
      IO.OptionBuilder().setTransports(['websocket']).build());

  _connectSocket() {
    _socket.connect();
    _socket.onConnect((data) => print('Connection established'));
    _socket.onConnectError((data) => print('Connect Error $data'));
    _socket.onDisconnect((data) => print('Socket.IO disconneted'));
  }

  _destroySocket(){
    _socket.disconnect();
  }

  //getter
  bool get isLoading => _isLoading;
  String get resMessage => _resMessage;
  String get fileUrl => _fileUrl;
  List get data => _data;

  void getActualMedia(data) {
    _media = data;
    notifyListeners();
  }

  void filteredProvider(data) {
    _data = data;
    notifyListeners();
  }

  void uploadFile(data) async {
    String url = '$baseUrl/upload';
    // final body = {
    //   "image": path
    // };

    try {
      var stream = http.ByteStream(data!.openRead());
      var length = await data.length();
      var request = http.MultipartRequest('POST', Uri.parse(url));
      var multipartFile =
          http.MultipartFile('image', stream, length, filename: data.path);
      request.files.add(multipartFile);
      var resp = await request.send();

      resp.stream.transform(utf8.decoder).listen((event) {
        print('event');
        print(event);
        var finalData = jsonDecode(event);
        // _resMessage = finalData;
        _fileUrl = finalData['imageurl'];
        notifyListeners();
        // if (finalData['statuscode'] == 200) {
        //   Navigator.of(context!).pushReplacement(
        //       MaterialPageRoute(builder: (context) => HomeScreen()));
        // }
        print('::::::[RESPONSE]::::::');
        print(_fileUrl);
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

  void createGroup(
    String? accessToken,
    String? userId,
    String? name,
    String? members,
    File? image,
    BuildContext? context,
  ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/create_group';

    final body = {
      'accessToken': accessToken,
      'user_id': userId,
      'group_name': name,
      'members': members,
      'group_profile': fileUrl != '' ? fileUrl : '',
    };

    print('BODY: ${jsonEncode(body)}');

    try {
      //  var stream = new http.ByteStream(image!.openRead());
      // var length = await image.length();
      // var request = new http.MultipartRequest("POST", Uri.parse(url));
      // var multipartFile = http.MultipartFile('group_profile', stream, length,
      //     filename: image.path);
      // request.fields['user_id'] = userId!;
      // request.fields['accessToken'] = accessToken!;
      // request.fields['group_name'] = name!;
      // request.fields['members'] = members!;
      // request.files.add(multipartFile);
      // var resp = await request.send();
      //
      // // if (resp.statusCode == 200) {
      // //   resp.stream.listen((data) {
      // //     print('data');
      // //     print(data);
      // //     print('data');
      // //   });
      // // }
      //
      // resp.stream.transform(utf8.decoder).listen((event) {
      //   print("event");
      //   print(event);
      //   var finalData = jsonDecode(event);
      //   // _resMessage = finalData;
      //   notifyListeners();
      //   if (finalData['statuscode'] == 200) {
      //     Navigator.of(context!).pushReplacement(
      //         MaterialPageRoute(builder: (context) => HomeScreen()));
      //   }
      //   print("::::::[RESPONSE]::::::");
      //   print(finalData);
      //   print("::::::[RESPONSE]::::::");
      // });

      _socket.emit('create_group', body);
      _socket.on('create_group', (data) {
        print('DDDDDDDDDDDDDDDDDDDDDDDDDd');
        print(data);
        print('DDDDDDDDDDDDDDDDDDDDDDDDDd');
        if (data['message'] == 'success') {
          Navigator.of(context!).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()));
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

  void addGroupMembers(
    String? accessToken,
    String? userId,
    String? groupId,
    String? members,
  ) async {
    _isLoading = true;
    notifyListeners();

    String url = '$baseUrl/add_group_member';

    final body = {
      'user_id': userId,
      'accessToken': accessToken,
      'members': members,
      'group_id': groupId,
    };

    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
          await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print('--------------------------------------------------------');
        print(res);
        print('--------------------------------------------------------');
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

  void editGroupMembers({
    String? name,
    String? members,
    required String groupId,
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/add_group_member';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'members': members,
      'group_id': groupId,
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

  void filterSearch(data) {
    // print(realGrpInfo);
    if (data.isEmpty || data == '' || data == null) {
      // print("empty");
      getGroupInfo(groupId: gropId, context: ctx);

      // grpData = grp.realGrpInfo;
    } else {
      // var fnd = realGrpInfo['data'].where((element) {
      //   var name = element['username'].toString().toLowerCase();
      //   var input = data.toLowerCase();
      //   return name.contains(input);
      // }).toList();
      // print(found);

      // print("::::::[NAME]::::::");
      // print(fnd);
      // print("::::::[NAME]::::::");
      // if(fnd.length>0){
      //   realGrpInfo['data'] = fnd;
      //    notifyListeners();
      // }else{
      //    getGroupInfo(groupId: gropId, context: ctx);
      // }
      List filteredData = [];
      for (var i = 0; i < realGrpInfo['data'].length; i++) {
        if (realGrpInfo['data'][i]['username']
            .toString()
            .toLowerCase()
            .contains(data.toLowerCase())) {
          print('contains');

          filteredData.add(realGrpInfo['data'][i]);
          notifyListeners();
        }
      }
      if (filteredData.isNotEmpty) {
        print('filtereeed');
        print(filteredData);
        realGrpInfo['data'] = filteredData;
        notifyListeners();
      } else {
        print('no data');
        getGroupInfo(groupId: gropId, context: ctx);
      }

      // grp.getActualData(fnd);
    }
  }

  void getGroupInfo({
    required String groupId,
    BuildContext? context,
  }) async {
    gropId = groupId;
    _isLoading = true;
    prefs = await SharedPreferences.getInstance();
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/get_group_user_list';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'group_id': groupId,
    };
    print('BODY: ${jsonEncode(body)}');

    try {
      _socket.on('get_group_user_list', (data) {
        print('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
        print(data['data']);
        print('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
        realGrpInfo = data;
        _data = data['data'];
        notifyListeners();
      });
      _socket.emit('get_group_user_list', body);
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
    realGrpInfo['data'] = [];
    notifyListeners();
  }

  void getGroupMedias({
    required String groupId,
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/get_group_chat_medias';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'group_id': groupId,
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
        getActualMedia(res['data']);
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

  void makeGroupAdmin({
    required String groupId,
    required String userId,
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/make_group_admin';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'group_id': groupId,
      'new_admin_user_id': userId,
    };
    print('BODY: ${jsonEncode(body)}');

    try {
      // http.Response req =
      //     await http.post(Uri.parse(url), body: jsonEncode(body));

      // if (req.statusCode == 200 || req.statusCode == 201) {
      //   final res = jsonDecode(req.body);
      //   print(res);
      //   _isLoading = false;
      //   _resMessage = req.body;
      //   // getActualMedia(res['data']);
      //   // _name = name;
      //   notifyListeners();
      // } else {
      //   final res = jsonDecode(req.body);
      //   print(':::::RRRRRR::::::${res}');
      //   _isLoading = false;
      //   notifyListeners();
      // }

       _socket.emit('make_group_admin', body);
      _socket.on('make_group_admin', (data) {
        print('add_new_admin');
        print(data);
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

  void removeGroupAdmin({
    required String groupId,
    required String userId,
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/make_group_admin';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'group_id': groupId,
      'remove_admin_id': userId,
    };
    print('BODY: ${jsonEncode(body)}');

    try {
      // http.Response req =
      //     await http.post(Uri.parse(url), body: jsonEncode(body));

      // if (req.statusCode == 200 || req.statusCode == 201) {
      //   final res = jsonDecode(req.body);
      //   print(res);
      //   _isLoading = false;
      //   _resMessage = req.body;
      //   // getActualMedia(res['data']);
      //   // _name = name;
      //   notifyListeners();
      // } else {
      //   final res = jsonDecode(req.body);
      //   print(':::::RRRRRR::::::${res}');
      //   _isLoading = false;
      //   notifyListeners();
      // }

      _socket.emit('remove_group_admin', body);
      _socket.on('remove_group_admin', (data) {
        print('remove_admin');
        print(data);
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

  void exitGroup({
    required String groupId,
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/exit_group_member';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'group_id': groupId,
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
        getActualMedia(res['data']);
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
}
