import 'dart:convert';

class ChatList {
  ChatList({
    required this.status,
    required this.statuscode,
    required this.message,
    required this.socket,
    required this.archivedChatList,
    required this.data,
  });

  final bool status;
  final int statuscode;
  final String message;
  final bool socket;
  final List<Datum> archivedChatList;
  final List<Datum> data;

  factory ChatList.fromRawJson(String str) =>
      ChatList.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ChatList.fromJson(Map<String, dynamic> json) => ChatList(
        status: json['status'],
        statuscode: json['statuscode'],
        message: json['message'],
        socket: json['socket'] ?? false,
        archivedChatList: List<Datum>.from(
            json['archived_chat_list'].map((x) => Datum.fromJson(x))),
        data: List<Datum>.from(json['data'].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        'status': status,
        'statuscode': statuscode,
        'message': message,
        'socket': socket,
        'archived_chat_list':
            List<dynamic>.from(archivedChatList.map((x) => x)),
        'data': List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  Datum({
    required this.id,
    required this.date,
    required this.message,
    required this.unreadMessage,
    required this.userid,
    required this.name,
    required this.profile,
    required this.phone,
    required this.muteStatus,
    required this.muteMessage,
    required this.room,
    required this.messageType,
    required this.chatType,
    required this.pinStatus,
    required this.deviceToken,
  });

  final String id;
  final DateTime date;
  final String message;
  final String unreadMessage;
  final String userid;
  final String name;
  final String profile;
  final String phone;
  final String muteStatus;
  final String muteMessage;
  final String room;
  final String messageType;
  final String chatType;
  final String pinStatus;
  final String deviceToken;

  factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json['id'],
        date: DateTime.parse(json['date']),
        message: json['message'],
        unreadMessage: json['unread_message'],
        userid: json['userid'],
        name: json['name'],
        profile: json['profile'],
        phone: json['phone'],
        muteStatus: json['mute_status'],
        muteMessage: json['mute_message'],
        room: json['room'],
        messageType: json['message_type'],
        chatType: json['chat_type'],
        pinStatus: json['pin_status'],
        deviceToken: json['device_token'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'message': message,
        'unread_message': unreadMessage,
        'userid': userid,
        'name': name,
        'profile': profile,
        'phone': phone,
        'mute_status': muteStatus,
        'mute_message': muteMessage,
        'room': room,
        'message_type': messageType,
        'chat_type': chatType,
        'pin_status': pinStatus,
        'device_token': deviceToken,
      };
}
