// To parse this JSON data, do
//
//     final getInboxMailDetails = getInboxMailDetailsFromJson(jsonString);

import 'dart:convert';

class GetInboxMailDetails {
  GetInboxMailDetails({
    required this.status,
    required this.statuscode,
    required this.message,
    required this.data,
  });

  bool status;
  int statuscode;
  String message;
  Data data;

  factory GetInboxMailDetails.fromRawJson(String str) => GetInboxMailDetails.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GetInboxMailDetails.fromJson(Map<String, dynamic> json) => GetInboxMailDetails(
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
    required this.from,
    required this.to,
    required this.cc,
    required this.bcc,
    required this.replyTo,
    required this.createdDatetime,
    required this.subject,
    required this.body,
    required this.attachments,
  });

  String from;
  List<String> to;
  List<String> cc;
  List<String> bcc;
  String replyTo;
  DateTime createdDatetime;
  String subject;
  String body;
  List<dynamic> attachments;

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    from: json['from'],
    to: List<String>.from(json['to'].map((x) => x)),
    cc: List<String>.from(json['cc'].map((x) => x)),
    bcc: List<String>.from(json['bcc'].map((x) => x)),
    replyTo: json['replyTo'],
    createdDatetime: DateTime.parse(json['created_datetime']),
    subject: json['subject'],
    body: json['body'],
    attachments: List<dynamic>.from(json['attachments'].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    'from': from,
    'to': List<dynamic>.from(to.map((x) => x)),
    'cc': List<dynamic>.from(cc.map((x) => x)),
    'bcc': List<dynamic>.from(bcc.map((x) => x)),
    'replyTo': replyTo,
    'created_datetime': createdDatetime.toIso8601String(),
    'subject': subject,
    'body': body,
    'attachments': List<dynamic>.from(attachments.map((x) => x)),
  };
}