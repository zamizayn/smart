// To parse this JSON data, do
//
//     final groupChatModel = groupChatModelFromJson(jsonString);

import 'dart:convert';

class GroupChatModel {
  GroupChatModel({
    required this.status,
    required this.statuscode,
    required this.message,
    required this.data,
  });

  final bool status;
  final int statuscode;
  final String message;
  final Data data;

  factory GroupChatModel.fromRawJson(String str) => GroupChatModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GroupChatModel.fromJson(Map<String, dynamic> json) => GroupChatModel(
    status: json['status'],
    statuscode: json['statuscode'],
    message: json['message'],
    data: Data.fromJson(json['data']),
  );

  Map<String, dynamic> toJson() => {
    'status': status,
    'statuscode': statuscode,
    'message': message,
    'data': data.toJson(),
  };
}

class Data {
  Data({
    required this.groupName,
    required this.id,
    required this.groupProfile,
    required this.createdDatetime,
    required this.userLeftStatus,
    required this.muteStatus,
    required this.list,
  });

  final String groupName;
  final String id;
  final String groupProfile;
  final DateTime createdDatetime;
  final String userLeftStatus;
  final String muteStatus;
  final List<ListElement> list;

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    groupName: json['group_name'],
    id: json['id'],
    groupProfile: json['group_profile'],
    createdDatetime: DateTime.parse(json['created_datetime']),
    userLeftStatus: json['user_left_status'],
    muteStatus: json['mute_status'],
    list: List<ListElement>.from(json['list'].map((x) => ListElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    'group_name': groupName,
    'id': id,
    'group_profile': groupProfile,
    'created_datetime': createdDatetime.toIso8601String(),
    'user_left_status': userLeftStatus,
    'mute_status': muteStatus,
    'list': List<dynamic>.from(list.map((x) => x.toJson())),
  };
}

class ListElement {
  ListElement({
    required this.id,
    required this.date,
    required this.senterId,
    required this.message,
    required this.messageType,
    required this.duration,
    required this.room,
    required this.messageStatus,
    required this.name,
    required this.type,
    required this.status,
    required this.replayId,
    required this.replayMessage,
    required this.replayMessageType,
    required this.replaySenter,
    required this.forwardId,
    required this.forwardCount,
    required this.forwardMessageStatus,
    required this.deleteStatus,
    required this.starredStatus,
    required this.readReceipt,
    required this.optionalText,
    required this.thumbnail,
    required this.newProfilePic,
    required this.previousProfilePic,
  });

  final String id;
  final DateTime date;
  final String senterId;
  final String message;
  final String messageType;
  final String duration;
  final String room;
  final String messageStatus;
  final String name;
  final String type;
  final String status;
  final String replayId;
  final String replayMessage;
  final String replayMessageType;
  final String replaySenter;
  final String forwardId;
  final String forwardCount;
  final String forwardMessageStatus;
  final String deleteStatus;
  final String starredStatus;
  final String readReceipt;
  final String optionalText;
  final String thumbnail;
  final String newProfilePic;
  final String previousProfilePic;

  factory ListElement.fromRawJson(String str) => ListElement.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
    id: json['id'],
    date: DateTime.parse(json['date']),
    senterId: json['senter_id'],
    message: json['message'],
    messageType: json['message_type'],
    duration: json['duration'],
    room: json['room'],
    messageStatus: json['message_status'],
    name: json['name'],
    type: json['type'],
    status: json['status'],
    replayId: json['replay_id'],
    replayMessage: json['replay_message'],
    replayMessageType: json['replay_message_type'],
    replaySenter: json['replay_senter'],
    forwardId: json['forward_id'],
    forwardCount: json['forward_count'],
    forwardMessageStatus: json['forward_message_status'],
    deleteStatus: json['delete_status'],
    starredStatus: json['starred_status'],
    readReceipt: json['read_receipt'],
    optionalText: json['optional_text'],
    thumbnail: json['thumbnail'],
    newProfilePic: json['new_profile_pic'] ?? '',
    previousProfilePic: json['previous_profile_pic'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'senter_id': senterId,
    'message': message,
    'message_type': messageType,
    'duration': duration,
    'room': room,
    'message_status': messageStatus,
    'name': name,
    'type': type,
    'status': status,
    'replay_id': replayId,
    'replay_message': replayMessage,
    'replay_message_type': replayMessageType,
    'replay_senter': replaySenter,
    'forward_id': forwardId,
    'forward_count': forwardCount,
    'forward_message_status': forwardMessageStatus,
    'delete_status': deleteStatus,
    'starred_status': starredStatus,
    'read_receipt': readReceipt,
    'optional_text': optionalText,
    'thumbnail': thumbnail,
    'new_profile_pic': newProfilePic,
    'previous_profile_pic': previousProfilePic,
  };
}