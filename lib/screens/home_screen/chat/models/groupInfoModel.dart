// To parse this JSON data, do
//
//     final groupInfoModel = groupInfoModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class GroupInfoModel {
  final bool status;
  final int statuscode;
  final String message;
  final String groupName;
  final String groupProfile;
  final int numberOfMembers;
  final DateTime createdDatetime;
  final String description;
  final String descriptionUpdatedDatetime;
  final int mediaCount;
  final int muteStatus;
  final String muteEndDatetime;
  final List<Datum> data;

  GroupInfoModel({
    required this.status,
    required this.statuscode,
    required this.message,
    required this.groupName,
    required this.groupProfile,
    required this.numberOfMembers,
    required this.createdDatetime,
    required this.description,
    required this.descriptionUpdatedDatetime,
    required this.mediaCount,
    required this.muteStatus,
    required this.muteEndDatetime,
    required this.data,
  });

  factory GroupInfoModel.fromRawJson(String str) => GroupInfoModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GroupInfoModel.fromJson(Map<String, dynamic> json) => GroupInfoModel(
    status: json["status"],
    statuscode: json["statuscode"],
    message: json["message"],
    groupName: json["group_name"],
    groupProfile: json["group_profile"],
    numberOfMembers: json["number_of_members"],
    createdDatetime: DateTime.parse(json["created_datetime"]),
    description: json["description"],
    descriptionUpdatedDatetime: json["description_updated_datetime"],
    mediaCount: json["media_count"],
    muteStatus: json["mute_status"],
    muteEndDatetime: json["mute_end_datetime"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "statuscode": statuscode,
    "message": message,
    "group_name": groupName,
    "group_profile": groupProfile,
    "number_of_members": numberOfMembers,
    "created_datetime": createdDatetime.toIso8601String(),
    "description": description,
    "description_updated_datetime": descriptionUpdatedDatetime,
    "media_count": mediaCount,
    "mute_status": muteStatus,
    "mute_end_datetime": muteEndDatetime,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  final String userId;
  final String username;
  final String type;
  final String profilePic;
  final String about;
  final String phone;

  Datum({
    required this.userId,
    required this.username,
    required this.type,
    required this.profilePic,
    required this.about,
    required this.phone,
  });

  factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    userId: json["user_id"],
    username: json["username"],
    type: json["type"],
    profilePic: json["profile_pic"],
    about: json["about"],
    phone: json["phone"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "username": username,
    "type": type,
    "profile_pic": profilePic,
    "about": about,
    "phone": phone,
  };
}
