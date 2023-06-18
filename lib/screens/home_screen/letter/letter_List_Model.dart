// To parse this JSON data, do
//
//     final getletterList = getletterListFromJson(jsonString);

import 'dart:convert';

class GetletterList {
    GetletterList({
        required this.status,
        required this.statuscode,
        required this.message,
        required this.data,
    });

    final bool status;
    final int statuscode;
    final String message;
    final Data data;

    factory GetletterList.fromRawJson(String str) => GetletterList.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory GetletterList.fromJson(Map<String, dynamic> json) => GetletterList(
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
        required this.unread,
        required this.letterList,
    });

    final int unread;
    final List<LetterList> letterList;

    factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        unread: json['unread'],
        letterList: List<LetterList>.from(json['letter_list'].map((x) => LetterList.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        'unread': unread,
        'letter_list': List<dynamic>.from(letterList.map((x) => x.toJson())),
    };
}

class LetterList {
    LetterList({
        required this.id,
        required this.userId,
        required this.to,
        required this.from,
        required this.cc,
        required this.bcc,
        required this.datetime,
        required this.subject,
        required this.body,
        required this.mailReadStatus,
        required this.type,
        required this.profilePic,
        required this.letterPath,
        required this.approvalStatus,
        required this.starredStatus,
        required this.importantStatus,
    });

    final String id;
    final String userId;
    final List<String> to;
    final String from;
    final List<dynamic> cc;
    final List<dynamic> bcc;
    final DateTime datetime;
    final String subject;
    final String body;
    final dynamic mailReadStatus;
    final String type;
    final String profilePic;
    final String letterPath;
    final String approvalStatus;
    final dynamic starredStatus;
    final dynamic importantStatus;

    factory LetterList.fromRawJson(String str) => LetterList.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory LetterList.fromJson(Map<String, dynamic> json) => LetterList(
        id: json['id'],
        userId: json['user_id'],
        to: List<String>.from(json['to'].map((x) => x)),
        from: json['from'],
        cc: List<dynamic>.from(json['cc'].map((x) => x)),
        bcc: List<dynamic>.from(json['bcc'].map((x) => x)),
        datetime: DateTime.parse(json['datetime']),
        subject: json['subject'],
        body: json['body'],
        mailReadStatus: json['mail_read_status'],
        type: json['type'],
        profilePic: json['profile_pic'],
        letterPath: json['letter_path'],
        approvalStatus: json['approval_status'],
        starredStatus: json['starred_status'],
        importantStatus: json['important_status'],
    );

    Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'to': List<dynamic>.from(to.map((x) => x)),
        'from': from,
        'cc': List<dynamic>.from(cc.map((x) => x)),
        'bcc': List<dynamic>.from(bcc.map((x) => x)),
        'datetime': datetime.toIso8601String(),
        'subject': subject,
        'body': body,
        'mail_read_status': mailReadStatus,
        'type': type,
        'profile_pic': profilePic,
        'letter_path': letterPath,
        'approval_status': approvalStatus,
        'starred_status': starredStatus,
        'important_status': importantStatus,
    };
}
