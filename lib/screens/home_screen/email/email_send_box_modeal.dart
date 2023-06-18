// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class get_Send_Box_ListM {
  List<Datum> data;
  bool status;
  String message;
  int statuscode;

  get_Send_Box_ListM({
    required this.data,
    required this.status,
    required this.message,
    required this.statuscode,
  });

  factory get_Send_Box_ListM.fromRawJson(String str) => get_Send_Box_ListM.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory get_Send_Box_ListM.fromJson(Map<String, dynamic> json) => get_Send_Box_ListM(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        status: json["status"],
        message: json["message"],
        statuscode: json["statuscode"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "status": status,
        "message": message,
        "statuscode": statuscode,
      };
}

class Datum {
  String id;
  String from;
  String userId;
  String subject;
  String inboxId;
  List<String> to;
  DateTime createdAt;
  DateTime datetime;
  DateTime mailserverdatetime;
  List<dynamic> bcc;
  List<String> cc;
  String type;
  List<Attachment> attachments;
  String body;
  String profilePic;
  String bodyMd5Hash;
  dynamic virtualSend;

  Datum({
    required this.id,
    required this.from,
    required this.userId,
    required this.subject,
    required this.inboxId,
    required this.to,
    required this.createdAt,
    required this.datetime,
    required this.mailserverdatetime,
    required this.bcc,
    required this.cc,
    required this.type,
    required this.attachments,
    required this.body,
    required this.profilePic,
    required this.bodyMd5Hash,
    required this.virtualSend,
  });

  factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        from: json["from"],
        userId: json["userId"],
        subject: json["subject"],
        inboxId: json["inboxId"],
        to: List<String>.from(json["to"].map((x) => x)),
        createdAt: DateTime.parse(json["createdAt"]),
        datetime: DateTime.parse(json["datetime"]),
        mailserverdatetime: DateTime.parse(json["mailserverdatetime"]),
        bcc: List<dynamic>.from(json["bcc"].map((x) => x)),
        cc: List<String>.from(json["cc"].map((x) => x)),
        type: json["type"],
        attachments: List<Attachment>.from(
            json["attachments"].map((x) => Attachment.fromJson(x))),
        body: json["body"],
        profilePic: json["profile_pic"],
        bodyMd5Hash: json["bodyMD5Hash"],
        virtualSend: json["virtualSend"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "from": from,
        "userId": userId,
        "subject": subject,
        "inboxId": inboxId,
        "to": List<dynamic>.from(to.map((x) => x)),
        "createdAt": createdAt.toIso8601String(),
        "datetime": datetime.toIso8601String(),
        "mailserverdatetime": mailserverdatetime.toIso8601String(),
        "bcc": List<dynamic>.from(bcc.map((x) => x)),
        "cc": List<dynamic>.from(cc.map((x) => x)),
        "type": typeValues.reverse[type],
        "attachments": List<dynamic>.from(attachments.map((x) => x.toJson())),
        "body": body,
        "profile_pic": profilePic,
        "bodyMD5Hash": bodyMd5Hash,
        "virtualSend": virtualSend,
      };
}

class Attachment {
  String attachment;

  Attachment({
    required this.attachment,
  });

  factory Attachment.fromRawJson(String str) =>
      Attachment.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
        attachment: json["attachment"],
      );

  Map<String, dynamic> toJson() => {
        "attachment": attachment,
      };
}

enum Type { DATE, MAIL }

final typeValues = EnumValues({"date": Type.DATE, "mail": Type.MAIL});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
