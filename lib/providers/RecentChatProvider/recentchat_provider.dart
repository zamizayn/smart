// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:smart_station/utils/constants/urls.dart';

class RecentChatProvider extends ChangeNotifier {
  final baseUrl = AppUrls.appBaseUrl;

  //setter
  bool _isLoading = false;
  String _resMessage = '';
  String _isUserTyping = '';
  String _currentUser = '';
  List<dynamic> _recentChat = [];
  final List<dynamic> _socketRecentChat = [];
  BuildContext? ctx;

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
  String get isUserTyping => _isUserTyping;
  String get currentUser => _currentUser;
  List<dynamic> get recentChat => _recentChat;
  List<dynamic> get socketRecentChat => _socketRecentChat;

  void recentChatList(
    String? accessToken,
    String? userId,
    BuildContext? context,
  ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/getrecent_chat';
    final body = {
      'accessToken': accessToken,
      'user_id': userId,
    };

    print('BODY: ${jsonEncode(body)}');

    try {
      _socket.emit('chat_list', body);
      _socket.on('chat_list', (data) {
        _isLoading = false;
        print('::::::::::::::::::');
        print('ENTER');
        print('::::::::::::::::::');
        chatData(data['data']);
        notifyListeners();
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

  void chatData(data) {
    print('::::::::::::::::::');
    print(data);
    print('::::::::::::::::::');
    _recentChat = data;
    notifyListeners();
  }

  

  void userAction(typing, userId) {
    _isUserTyping = typing;
    _currentUser = userId;
    notifyListeners();
  }

}