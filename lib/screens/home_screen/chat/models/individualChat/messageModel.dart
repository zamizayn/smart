// To parse this JSON data, do
//
//     final individualChatModel = individualChatModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class IndividualChatModel {
    final bool status;
    final int statuscode;
    final String message;
    final Data data;

    IndividualChatModel({
        required this.status,
        required this.statuscode,
        required this.message,
        required this.data,
    });

    factory IndividualChatModel.fromRawJson(String str) => IndividualChatModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory IndividualChatModel.fromJson(Map<String, dynamic> json) => IndividualChatModel(
        status: json["status"],
        statuscode: json["statuscode"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "statuscode": statuscode,
        "message": message,
        "data": data.toJson(),
    };
}

class Data {
    final String name;
    final String profile;
    final String id;
    final int userBlockStatus;
    final String phoneNumber;
    final String muteStatus;
    final List<ListElement> list;

    Data({
        required this.name,
        required this.profile,
        required this.id,
        required this.userBlockStatus,
        required this.phoneNumber,
        required this.muteStatus,
        required this.list,
    });

    factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        name: json["name"],
        profile: json["profile"],
        id: json["id"],
        userBlockStatus: json["user_block_status"],
        phoneNumber: json["phone_number"],
        muteStatus: json["mute_status"],
        list: List<ListElement>.from(json["list"].map((x) => ListElement.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "profile": profile,
        "id": id,
        "user_block_status": userBlockStatus,
        "phone_number": phoneNumber,
        "mute_status": muteStatus,
        "list": List<dynamic>.from(list.map((x) => x.toJson())),
    };
}

class ListElement {
    final String id;
    final DateTime date;
    final String senterId;
    final String receiverId;
    final String message;
    final String messageType;
    final String duration;
    final String messageStatus;
    final String room;
    final String type;
    final String status;
    final String replayId;
    final String replayMessage;
    final String replayMessageType;
    final String replaySenter;
    final String replayDuration;
    final String forwardId;
    final String forwardCount;
    final String forwardMessageStatus;
    final String deleteStatus;
    final String starredStatus;
    final String readReceipt;
    final String optionalText;
    final String thumbnail;

    ListElement({
        required this.id,
        required this.date,
        required this.senterId,
        required this.receiverId,
        required this.message,
        required this.messageType,
        required this.duration,
        required this.messageStatus,
        required this.room,
        required this.type,
        required this.status,
        required this.replayId,
        required this.replayMessage,
        required this.replayMessageType,
        required this.replaySenter,
        required this.replayDuration,
        required this.forwardId,
        required this.forwardCount,
        required this.forwardMessageStatus,
        required this.deleteStatus,
        required this.starredStatus,
        required this.readReceipt,
        required this.optionalText,
        required this.thumbnail,
    });

    factory ListElement.fromRawJson(String str) => ListElement.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        id: json["id"],
        date: DateTime.parse(json["date"]),
        senterId: json["senter_id"],
        receiverId: json["receiver_id"],
        message: json["message"],
        messageType: json["message_type"],
        duration: json["duration"],
        messageStatus: json["message_status"],
        room: json["room"],
        type: json["type"],
        status: json["status"],
        replayId: json["replay_id"],
        replayMessage: json["replay_message"],
        replayMessageType: json["replay_message_type"],
        replaySenter: json["replay_senter"],
        replayDuration: json["replay_duration"],
        forwardId: json["forward_id"],
        forwardCount: json["forward_count"],
        forwardMessageStatus: json["forward_message_status"],
        deleteStatus: json["delete_status"],
        starredStatus: json["starred_status"],
        readReceipt: json["read_receipt"],
        optionalText: json["optional_text"],
        thumbnail: json["thumbnail"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "date": date.toIso8601String(),
        "senter_id": senterId,
        "receiver_id": receiverId,
        "message": message,
        "message_type": messageType,
        "duration": duration,
        "message_status": messageStatus,
        "room": room,
        "type": type,
        "status": status,
        "replay_id": replayId,
        "replay_message": replayMessage,
        "replay_message_type": replayMessageType,
        "replay_senter": replaySenter,
        "replay_duration": replayDuration,
        "forward_id": forwardId,
        "forward_count": forwardCount,
        "forward_message_status": forwardMessageStatus,
        "delete_status": deleteStatus,
        "starred_status": starredStatus,
        "read_receipt": readReceipt,
        "optional_text": optionalText,
        "thumbnail": thumbnail,
    };
}
