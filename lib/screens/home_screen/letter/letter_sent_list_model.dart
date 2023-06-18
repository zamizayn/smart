// To parse this JSON data, do
//
//     final getSentLetterList = getSentLetterListFromJson(jsonString);

import 'dart:convert';

class GetSentLetterList {
    GetSentLetterList({
        required this.status,
        required this.statuscode,
        required this.message,
        required this.data,
    });

    final bool status;
    final int statuscode;
    final String message;
    final Data data;

    factory GetSentLetterList.fromRawJson(String str) => GetSentLetterList.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory GetSentLetterList.fromJson(Map<String, dynamic> json) => GetSentLetterList(
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
        required this.letterSentList,
    });

    final List<LetterSentList> letterSentList;

    factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        letterSentList: List<LetterSentList>.from(json['letter_sent_list'].map((x) => LetterSentList.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        'letter_sent_list': List<dynamic>.from(letterSentList.map((x) => x.toJson())),
    };
}

class LetterSentList {
    LetterSentList({
        required this.id,
        required this.to,
        required this.from,
        required this.cc,
        required this.bcc,
        required this.datetime,
        required this.subject,
        required this.body,
        required this.type,
        required this.profilePic,
        required this.letterPath,
        required this.approvalStatus,
        required this.starredStatus,
        required this.importantStatus,
        required this.archiveStatus,
    });

    final String id;
    final List<String> to;
    final String from;
    final List<dynamic> cc;
    final List<dynamic> bcc;
    final DateTime datetime;
    final String subject;
    final String body;
    final String type;
    final String profilePic;
    final String letterPath;
    final String approvalStatus;
    final dynamic starredStatus;
    final dynamic importantStatus;
    final dynamic archiveStatus;

    factory LetterSentList.fromRawJson(String str) => LetterSentList.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory LetterSentList.fromJson(Map<String, dynamic> json) => LetterSentList(
        id: json['id'],
        to: List<String>.from(json['to'].map((x) => x)),
        from: json['from'],
        cc: List<dynamic>.from(json['cc'].map((x) => x)),
        bcc: List<dynamic>.from(json['bcc'].map((x) => x)),
        datetime: DateTime.parse(json['datetime']),
        subject: json['subject'].toString(),
        body: json['body'].toString(),
        type: json['type'],
        profilePic: json['profile_pic'],
        letterPath: json['letter_path'],
        approvalStatus: json['approval_status'],
        starredStatus: json['starred_status'],
        importantStatus: json['important_status'],
        archiveStatus: json['archive_status'],
    );

    Map<String, dynamic> toJson() => {
        'id': id,
        'to': List<dynamic>.from(to.map((x) => x)),
        'from': from,
        'cc': List<dynamic>.from(cc.map((x) => x)),
        'bcc': List<dynamic>.from(bcc.map((x) => x)),
        'datetime': datetime.toIso8601String(),
        'subject': subject,
        'body': body,
        'type': type,
        'profile_pic': profilePic,
        'letter_path': letterPath,
        'approval_status': approvalStatus,
        'starred_status': starredStatus,
        'important_status': importantStatus,
        'archive_status': archiveStatus,
    };
}
