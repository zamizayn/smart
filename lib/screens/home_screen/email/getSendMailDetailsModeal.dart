import 'package:meta/meta.dart';
import 'dart:convert';

class GetSentMailDetails {
  bool status;
  int statuscode;
  String message;
  Data data;

  GetSentMailDetails({
    required this.status,
    required this.statuscode,
    required this.message,
    required this.data,
  });

  factory GetSentMailDetails.fromRawJson(String str) =>
      GetSentMailDetails.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GetSentMailDetails.fromJson(Map<String, dynamic> json) =>
      GetSentMailDetails(
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
  String from;
  List<String> to;
  List<String> cc;
  List<String> bcc;
  DateTime sentDatetime;
  String subject;
  String body;
  List<String> attachments;

  Data({
    required this.from,
    required this.to,
    required this.cc,
    required this.bcc,
    required this.sentDatetime,
    required this.subject,
    required this.body,
    required this.attachments,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        from: json["from"],
        to: List<String>.from(json["to"].map((x) => x)),
        cc: List<String>.from(json["cc"].map((x) => x)),
        bcc: List<String>.from(json["bcc"].map((x) => x)),
        sentDatetime: DateTime.parse(json["sent_datetime"]),
        subject: json["subject"],
        body: json["body"],
        attachments: List<String>.from(json["attachments"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "from": from,
        "to": List<dynamic>.from(to.map((x) => x)),
        "cc": List<dynamic>.from(cc.map((x) => x)),
        "bcc": List<dynamic>.from(bcc.map((x) => x)),
        "sent_datetime": sentDatetime.toIso8601String(),
        "subject": subject,
        "body": body,
        "attachments": List<dynamic>.from(attachments.map((x) => x)),
      };
}
