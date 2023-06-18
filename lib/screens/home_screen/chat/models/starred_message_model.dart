// To parse this JSON data, do
//
//     final starredMessage = starredMessageFromJson(jsonString);

import 'dart:convert';

class StarredMessage {
    StarredMessage({
        required this.status,
        required this.statuscode,
        required this.message,
        required this.data,
    });

    final bool status;
    final int statuscode;
    final String message;
    final List<Datum> data;

    factory StarredMessage.fromRawJson(String str) => StarredMessage.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory StarredMessage.fromJson(Map<String, dynamic> json) => StarredMessage(
        status: json['status'],
        statuscode: json['statuscode'],
        message: json['message'],
        data: List<Datum>.from(json['data'].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        'status': status,
        'statuscode': statuscode,
        'message': message,
        'data': List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    Datum({
        required this.id,
        required this.date,
        required this.senderName,
        required this.senderProfilePic,
        required this.receiverName,
        required this.receiverId,
        required this.senterId,
        required this.message,
        required this.messageType,
        required this.room,
        required this.thumbnail,
        required this.optionalText,
        required this.replayId,
        required this.replayMessage,
        required this.replayThumbnail,
        required this.replayOptionalText,
        required this.replayMessageType,
        required this.forwardId,
        required this.forwardMessage,
    });

    final String id;
    final DateTime date;
    final String senderName;
    final String senderProfilePic;
    final String receiverName;
    final String receiverId;
    final String senterId;
    final String message;
    final String messageType;
    final String room;
    final String thumbnail;
    final String optionalText;
    final String replayId;
    final String replayMessage;
    final String replayThumbnail;
    final String replayOptionalText;
    final String replayMessageType;
    final String forwardId;
    final String forwardMessage;

    factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json['id'],
        date: DateTime.parse(json['date']),
        senderName: json['sender_name'],
        senderProfilePic: json['sender_profile_pic'],
        receiverName: json['receiver_name'],
        receiverId: json['receiver_id'],
        senterId: json['senter_id'],
        message: json['message'],
        messageType: json['message_type'],
        room: json['room'],
        thumbnail: json['thumbnail'],
        optionalText: json['optional_text'],
        replayId: json['replay_id'],
        replayMessage: json['replay_message'],
        replayThumbnail: json['replay_thumbnail'],
        replayOptionalText: json['replay_optional_text'],
        replayMessageType: json['replay_message_type'],
        forwardId: json['forward_id'],
        forwardMessage: json['forward_message'],
    );

    Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'sender_name': senderName,
        'sender_profile_pic': senderProfilePic,
        'receiver_name': receiverName,
        'receiver_id': receiverId,
        'senter_id': senterId,
        'message': message,
        'message_type': messageType,
        'room': room,
        'thumbnail': thumbnail,
        'optional_text': optionalText,
        'replay_id': replayId,
        'replay_message': replayMessage,
        'replay_thumbnail': replayThumbnail,
        'replay_optional_text': replayOptionalText,
        'replay_message_type': replayMessageType,
        'forward_id': forwardId,
        'forward_message': forwardMessage,
    };
}
