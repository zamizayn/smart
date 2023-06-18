// To parse this JSON data, do
//
//     final getDraftLetterView = getDraftLetterViewFromJson(jsonString);

import 'dart:convert';

class GetDraftLetterView {
    GetDraftLetterView({
        required this.status,
        required this.statuscode,
        required this.message,
        required this.data,
    });

    final bool status;
    final int statuscode;
    final String message;
    final List<Datum> data;

    factory GetDraftLetterView.fromRawJson(String str) => GetDraftLetterView.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory GetDraftLetterView.fromJson(Map<String, dynamic> json) => GetDraftLetterView(
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
        required this.userId,
        required this.receiverId,
        required this.datetime,
        required this.addressTo,
        required this.fromMail,
        required this.toMail,
        required this.ccMail,
        required this.bccMail,
        required this.subject,
        required this.body,
        required this.type,
        required this.importantStatus,
        required this.markAsRead,
        required this.archiveStatus,
        required this.starredMessage,
        required this.letterAttatchment,
        required this.status,
    });

    final String id;
    final String userId;
    final String receiverId;
    final DateTime datetime;
    final String addressTo;
    final String fromMail;
    final String toMail;
    final String ccMail;
    final String bccMail;
    final String subject;
    final String body;
    final String type;
    final String importantStatus;
    final String markAsRead;
    final String archiveStatus;
    final String starredMessage;
    final String letterAttatchment;
    final String status;

    factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json['id'],
        userId: json['user_id'],
        receiverId: json['receiver_id'],
        datetime: DateTime.parse(json['datetime']),
        addressTo: json['address_to'].toString(),
        fromMail: json['from_mail'],
        toMail: json['to_mail'],
        ccMail: json['cc_mail'],
        bccMail: json['bcc_mail'],
        subject: json['subject'] ?? '',
        body: json['body'].toString(),
        type: json['type'],
        importantStatus: json['important_status'],
        markAsRead: json['mark_as_read'],
        archiveStatus: json['archive_status'],
        starredMessage: json['starred_message'],
        letterAttatchment: json['letter_attatchment'],
        status: json['status'],
    );

    Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'receiver_id': receiverId,
        'datetime': datetime.toIso8601String(),
        'address_to': addressTo,
        'from_mail': fromMail,
        'to_mail': toMail,
        'cc_mail': ccMail,
        'bcc_mail': bccMail,
        'subject': subject,
        'body': body,
        'type': type,
        'important_status': importantStatus,
        'mark_as_read': markAsRead,
        'archive_status': archiveStatus,
        'starred_message': starredMessage,
        'letter_attatchment': letterAttatchment,
        'status': status,
    };
}
