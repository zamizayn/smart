// To parse this JSON data, do
//
//     final getmailList = getmailListFromJson(jsonString);

import 'dart:convert';

class GetmailList {
  GetmailList({
    required this.status,
    required this.statuscode,
    required this.userId,
    required this.message,
    required this.data,
  });

  final bool status;
  final int statuscode;
  final String userId;
  final String message;
  final List<Datum> data;

  factory GetmailList.fromRawJson(String str) =>
      GetmailList.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GetmailList.fromJson(Map<String, dynamic> json) => GetmailList(
        status: json['status'],
        statuscode: json['statuscode'],
        userId: json['user_id'],
        message: json['message'],
        data: List<Datum>.from(json['data'].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        'status': status,
        'statuscode': statuscode,
        'user_id': userId,
        'message': message,
        'data': List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  Datum({
    required this.id,
    required this.userId,
    required this.datetime,
    required this.subject,
    required this.to,
    required this.from,
    required this.bcc,
    required this.cc,
    required this.type,
    required this.createdAt,
    required this.attachments,
    required this.body,
    required this.profilePic,
    required this.mailReadStatus,
  });

  final String id;
  final String userId;
  final String datetime;
  final String subject;
  final List<dynamic> to;
  final String from;
  final List<dynamic> bcc;
  final List<String> cc;
  final String type;
  final DateTime createdAt;
  final List<dynamic> attachments;
  final String body;
  final String profilePic;
  final dynamic mailReadStatus;

  factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json['id'],
        userId: json['user_id'],
        datetime: json['datetime'],
        subject: json['subject'],
        to: List<dynamic>.from(json['to'].map((x) => x)),
        from: json['from'],
        bcc: List<dynamic>.from(json['bcc'].map((x) => x)),
        cc: List<String>.from(json['cc'].map((x) => x)),
        type: json['type'],
        createdAt: DateTime.parse(json['createdAt']),
        attachments: List<dynamic>.from(json['attachments'].map((x) => x)),
        body: json['body'],
        profilePic: json['profile_pic'],
        mailReadStatus: json['mail_read_status'].toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'datetime': datetime,
        'subject': subject,
        'to': List<dynamic>.from(to.map((x) => x)),
        'from': from,
        'bcc': List<dynamic>.from(bcc.map((x) => x)),
        'cc': List<dynamic>.from(cc.map((x) => x)),
        'type': type,
        'createdAt': createdAt.toIso8601String(),
        'attachments': List<dynamic>.from(attachments.map((x) => x)),
        'body': body,
        'profile_pic': profilePic,
        'mail_read_status': mailReadStatus.toString(),
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
