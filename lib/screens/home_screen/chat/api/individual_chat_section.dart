import 'dart:convert';

import 'package:smart_station/utils/constants/urls.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/individualChat/messageModel.dart';
import '../../../../utils/constants/app_constants.dart';
import '../models/group_media_model.dart';
import '../models/individualChat/individualBlockModel.dart';
import '../models/individualChat/individualClearModel.dart';
import '../models/individualChat/individualInfoModel.dart';
import '../models/individualChat/individualMediaModel.dart';
import '../models/individualChat/individualMuteModel.dart';
import '../models/starred_message_model.dart';

final IO.Socket _socket = IO.io(AppUrls.appSocketUrl,
    IO.OptionBuilder().setTransports(['websocket']).build());

_connectSocket() {
  _socket.connect();
  _socket.onConnect((data) => print('Connection established'));
  _socket.onConnectError((data) => print('Connect Error $data'));
  _socket.onDisconnect((data) => print('Socket.IO disconneted'));
}

_destroySocket() {
  _socket.disconnect();
}

getPrivateChatDetails(userId, accessToken, receiverId) async {
  if (_socket.connected) {
    _socket.emit('room', {'sid': userId, 'rid': receiverId});
    _socket.on('room_notification', (data) {
      if (data != null) {
        _socket.emit('room_chat_list_details',
            {'sid': userId, 'rid': receiverId, 'room': ''});
        _socket.on('message', (data) {
          final chatdata = IndividualChatModel.fromJson(data);
          chatController.add(chatdata);
        });
      }
    });
  }
}

Future<IndividualInfoModel> getIndividualInfo(
    userId, accessToken, receiverId) async {
  String url = '${AppUrls.appBaseUrl}get_individual_pofile_details';
  var data;
  var body = {
    'user_id': userId,
    'accessToken': accessToken,
    'receiver_id': receiverId
  };

  var resp = await http.post(Uri.parse(url), body: body);

  if (resp.statusCode == 200 || resp.statusCode == 201) {
    data = IndividualInfoModel.fromJson(jsonDecode(resp.body));
  }

  return data;
}

Future<IndividualMuteModel> getMuteInfo(
    userId, accessToken, receiverId, nType, sNoti) async {
  String url = '${AppUrls.appBaseUrl}mute_private_chat_notification';
  var muteInfo;
  var body = {
    'user_id': userId,
    'accessToken': accessToken,
    'receiver_id': receiverId,
    'type': nType,
    'show_notification': sNoti
  };

  var resp = await http.post(Uri.parse(url), body: body);

  if (resp.statusCode == 200 || resp.statusCode == 201) {
    print("RRRRRRRRRRRRRRRRRRRr");
    print(resp.body);
    print("RRRRRRRRRRRRRRRRRRRr");
    muteInfo = IndividualMuteModel.fromJson(jsonDecode(resp.body));
  }

  return muteInfo;
}

Future<String> getUnMuteInfo(userId, accessToken, receiverId) async {
  String url = '${AppUrls.appBaseUrl}unmute_private_chat_notification';
  var muteInfo;
  var body = {
    'user_id': userId,
    'accessToken': accessToken,
    'receiver_id': receiverId
  };

  var resp = await http.post(Uri.parse(url), body: body);

  if (resp.statusCode == 200) {
    return jsonDecode(resp.body)['message'];
  } else {
    return 'ERROR';
  }
}

Future<IndividualBlockModel> blockPerson(
    userId, accessToken, receiverId) async {
  var finalData;
  var body = {
    'user_id': userId,
    'accessToken': accessToken,
    'receiver_id': receiverId
  };
  if (_socket.connected) {
    _socket.emit('block', body);
    _socket.on('block', (data) {
      print(data);
      finalData = data;
    });
  } else {
    _connectSocket();
    _socket.emit('block', body);
    _socket.on('block', (data) {
      print(data);
      finalData = data;
    });
  }
  print('DDDDDDDDDDDDDDDDDDDdd');
  print(finalData);
  print('DDDDDDDDDDDDDDDDDDDdd');
  return finalData;
}

Future<StarredMessage> getStarredList(userId, accessToken) async {
  String url = '${AppUrls.appBaseUrl}starred_chat_list';
  var starred;
  var body = {
    'user_id': userId,
    'accessToken': accessToken,
    // "receiver_id":receiverId
  };

  var resp = await http.post(Uri.parse(url), body: body);

  if (resp.statusCode == 200) {
    starred = StarredMessage.fromJson(jsonDecode(resp.body));
    return starred;
  } else {
    return starred;
  }
}


Future<dynamic> getchatMedia(
    userId, accessToken, receiverId) async {
  String url = '${AppUrls.appBaseUrl}get_individual_chat_medias';
  var mediaInfo;
  var body = {
    'user_id': userId,
    'accessToken': accessToken,
    'receiver_id': receiverId
  };

  var resp = await http.post(Uri.parse(url), body: body);

  if (resp.statusCode == 200 || resp.statusCode == 201) {
    mediaInfo = (resp.body);
  }

  return mediaInfo;
}

Future<dynamic> getchatMediaGroup(userId, accessToken, receiverId) async {
  String url = '${AppUrls.appBaseUrl}get_group_chat_medias';
  // print(url);

  var mediaInfo;
  var body = {
    'user_id': userId,
    'accessToken': accessToken,
    'group_id': receiverId
  };
  print(body);

  var resp = await http.post(Uri.parse(url), body: body);

  if (resp.statusCode == 200 || resp.statusCode == 201) {
    print(resp.body);
    mediaInfo = (resp.body);
    // mediaInfo = resp.body;
  }

  return mediaInfo;
}

Future<IndividualClearModel> getClearChatInfo(
    userId, accessToken, receiverId) async {
  var clearInfo;
  var body = {
    'user_id': userId,
    'accessToken': accessToken,
    'group_id': receiverId
  };

  if (_socket.connected) {
    _socket.emit('clear_individual_chat', body);
    _socket.on('clear_individual_chat', (data) {
      clearInfo = IndividualClearModel.fromJson(data);
    });
  } else {
    _connectSocket();
    _socket.emit('clear_individual_chat', body);
    _socket.on('clear_individual_chat', (data) {
      clearInfo = IndividualClearModel.fromJson(data);
    });
  }

  return clearInfo;
}
