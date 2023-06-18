// To parse this JSON data, do
//
//     final userListModel = userListModelFromJson(jsonString);

import 'dart:convert';

class UserListModel {
  UserListModel({
    required this.status,
    required this.statuscode,
    required this.message,
    required this.data,
  });

  final bool status;
  final int statuscode;
  final String message;
  final List<Datum> data;

  factory UserListModel.fromRawJson(String str) => UserListModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserListModel.fromJson(Map<String, dynamic> json) => UserListModel(
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
    required this.userId,
    required this.name,
    required this.profilePic,
    required this.about,
    required this.phone,
    required this.country,
    required this.companyMail,
    required this.deviceToken,
    required this.blockStatus,
  });

  final String userId;
  final String name;
  final String profilePic;
  final String about;
  final String phone;
  final String country;
  final String companyMail;
  final String deviceToken;
  final int blockStatus;

  factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    userId: json['user_id'],
    name: json['name'],
    profilePic: json['profile_pic'],
    about: json['about'],
    phone: json['phone'],
    country: json['country'],
    companyMail: json['company_mail'],
    deviceToken: json['deviceToken'],
    blockStatus: json['block_status'],
  );

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'name': name,
    'profile_pic': profilePic,
    'about': about,
    'phone': phone,
    'country': country,
    'company_mail': companyMail,
    'deviceToken': deviceToken,
    'block_status': blockStatus,
  };
}
