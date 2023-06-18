// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables, unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/providers/InfoProvider/individualChatInfoProvider.dart';
import 'package:smart_station/utils/constants/urls.dart';

import '../../utils/constants/app_constants.dart';

class ChatDetailProvider extends ChangeNotifier {
  final baseUrl = AppUrls.appBaseUrl;

  //setter
  bool _isLoading = false;
  String _resMessage = '';
  String _receiverId = '';
  final String _isTyping = '';
  final String _id = '';
  final String _onlineStatus = '';
  final String _last_seen = '';
  String _groupId = '';
  var realData;
  var realGrpData;
  BuildContext? ctx;

  //getter
  bool get isLoading => _isLoading;

  String get resMessage => _resMessage;
  String get isTyping => _isTyping;
  String get id => _id;
  String get onlineStatus => _onlineStatus;
  String get last_seen => _last_seen;

  String get receiverId => _receiverId;
  String get groupId => _groupId;

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

  //............Private

  void privateChatDetail({
    String? accessToken,
    String? userId,
    required String receiverId,
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    _receiverId = receiverId;
    notifyListeners();

    String url = '$baseUrl/getchat_list_details';
    final body = {
      'accessToken': accessToken,
      'user_id': userId,
      'receiver_id': receiverId,
    };

    print('BODY of PVT CHAT: ${jsonEncode(body)}');

    try {
      // http.Response req =
      //     await http.post(Uri.parse(url), body: jsonEncode(body));
      //
      // if (req.statusCode == 200 || req.statusCode == 201) {
      //   final res = jsonDecode(req.body);
      //   print(res);
      //   _isLoading = false;
      //   _resMessage = req.body;
      //   // _name = name;
      //   // Navigator.push(ctx!, MaterialPageRoute(builder: (_) => ConversationScreen()));
      //   notifyListeners();
      // } else {
      //   final res = jsonDecode(req.body);
      //   print(':::::RESPONSE OF PVT CHAT::::::${res}');
      //   _isLoading = false;
      //   notifyListeners();
      // }
      _socket.emit('room', {'sid': userId, 'rid': receiverId});
       
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

  void clearPrivateChat({
    required String receiverId,
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/clear_individual_chat';
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

  void reportPrivateChat({
    required String receiverId,
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/report_individual_chat';
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

  void reportBlockPrivateChat({
    required String receiverId,
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/report_and_block_individual_chat';
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

  void mutePrivateChatNotification({
    required String receiverId,
    String? type,
    String? status,
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/mute_private_chat_notification';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'receiver_id': receiverId,
      'type': type,
      'show_notification': status,
    };

    /*  //type
    1)type=8_hours =>mute for 8 hours
    2)type=1_week =>mute for 1 week
    3)type=always => mute for always

//show_notification
    1)show_notification=1 =>show notification
    2)show_notification=0 => hide notification //used only */
    print('BODY: ${jsonEncode(body)}');
    // var auth = Provider.of<AuthProvider>(ctx!, listen: false);

    try {
      http.Response req =
          await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print('KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK');
        print(res);
        print('KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK');
        _isLoading = false;
        _resMessage = req.body;
        // _name = name;

        InfoProvider().getIndividualProfile(receiverId, ctx);
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

  void unmutePrivatechatNotification(
      {required String receiverId, BuildContext? context}) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/unmute_private_chat_notification';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'receiver_id': receiverId,
    };

    try {
      http.Response res =
          await http.post(Uri.parse(url), body: jsonEncode(body));

      if (res.statusCode == 200 || res.statusCode == 201) {
        var response = jsonDecode(res.body);
        print('%%%%%%%%%%%%%%%%%%[JSON RESPONSE]%%%%%%%%%%%%%%%%%%%%');
        print(response);
        print('%%%%%%%%%%%%%%%%%%[JSON RESPONSE]%%%%%%%%%%%%%%%%%%%%');
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

  //.............Group

  void groupChatDetail({
    String? accessToken,
    String? userId,
    required String groupId,
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    _groupId = groupId;
    notifyListeners();

    String url = '$baseUrl/get_group_chat_details';
    final body = {
      'accessToken': accessToken,
      'user_id': userId,
      'group_id': groupId,
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
      //   // _name = name;
      //   Navigator.push(
      //       ctx!,
      //       MaterialPageRoute(
      //           builder: (_) => GroupConversationScreen(context: ctx!)));
      //   notifyListeners();
      // } else {
      //   final res = jsonDecode(req.body);
      //   print(':::::RRRRRR::::::${res}');
      //   _isLoading = false;
      //   notifyListeners();
      // }
      _socket.emit('room', {'userid': userId, 'room': groupId});
      _socket.on('roomUsers', (data) {
        print('============[GROUP NOTIFICATION]=============');
        print(data);
        print('============[GROUP NOTIFICATION]=============');
        _socket.emit('room_chat_list_details',
            {'sid': userId, 'rid': '', 'room': groupId});
        _socket.on('message', (data) {
          print('ERRERREREREREREREREREREREREREREREREREEREREE');
          print(data);
          print('ERRERREREREREREREREREREREREREREREREREEREREE');

          realGrpData = data;
          notifyListeners();
        });
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

  void clearGroupChat({
    required String groupId,
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/clear_group_chat';
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

  void reportGroupChat({
    required String groupId,
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/report_group_chat';
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

  void reportExitGroupChat({
    required String groupId,
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/report_and_left_group_chat';
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

  void muteGroupChatNotification({
    required String groupId,
    String? type,
    String? status,
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/mute_group_chat_notification';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'group_id': groupId,
      'type': type,
      'show_notification': status,
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

  void unmuteGroupchatNotification(
      {required String receiverId, BuildContext? context}) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/unmute_private_chat_notification';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'receiver_id': receiverId,
    };

    try {
      http.Response res =
          await http.post(Uri.parse(url), body: jsonEncode(body));

      if (res.statusCode == 200 || res.statusCode == 201) {
        var response = jsonDecode(res.body);
        print('%%%%%%%%%%%%%%%%%%[JSON RESPONSE]%%%%%%%%%%%%%%%%%%%%');
        print(response);
        print('%%%%%%%%%%%%%%%%%%[JSON RESPONSE]%%%%%%%%%%%%%%%%%%%%');
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

  void removeGroupMember({
    required String groupId,
    required String userId,
    BuildContext? context,
  }) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    var cdp = Provider.of<ChatDetailProvider>(ctx!, listen: false);
    String url = '$baseUrl/remove_group_member';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'group_id': groupId,
      'remove_user_id': userId,
    };

    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
          await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print('==============[REMOVE]====================');
        print(res);
        print('==============[REMOVE]====================');
        cdp.groupChatDetail(groupId: groupId, context: ctx);
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
}
