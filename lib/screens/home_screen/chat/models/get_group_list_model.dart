// To parse this JSON data, do
//
//     final getGroupList = getGroupListFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class GetGroupList {
    final bool status;
    final int statuscode;
    final String message;
    final List<Datum> data;

    GetGroupList({
        required this.status,
        required this.statuscode,
        required this.message,
        required this.data,
    });

    factory GetGroupList.fromRawJson(String str) => GetGroupList.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory GetGroupList.fromJson(Map<String, dynamic> json) => GetGroupList(
        status: json["status"],
        statuscode: json["statuscode"],
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "statuscode": statuscode,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    final String groupName;
    final String groupId;
    final String groupDescription;
    final String groupProfile;

    Datum({
        required this.groupName,
        required this.groupId,
        required this.groupDescription,
        required this.groupProfile,
    });

    factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        groupName: json["group_name"],
        groupId: json["group_id"],
        groupDescription: json["group_description"],
        groupProfile: json["group_profile"],
    );

    Map<String, dynamic> toJson() => {
        "group_name": groupName,
        "group_id": groupId,
        "group_description": groupDescription,
        "group_profile": groupProfile,
    };
}
