// To parse this JSON data, do
//
//     final individualMuteModel = individualMuteModelFromJson(jsonString);

import 'dart:convert';

class IndividualMuteModel {
  IndividualMuteModel({
    required this.status,
    required this.statuscode,
    required this.message,
    required this.endTime,
  });

  final bool status;
  final int statuscode;
  final String message;
  final String endTime;

  factory IndividualMuteModel.fromRawJson(String str) => IndividualMuteModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory IndividualMuteModel.fromJson(Map<String, dynamic> json) => IndividualMuteModel(
    status: json['status'],
    statuscode: json['statuscode'],
    message: json['message'],
    endTime: json['end_time'].toString(),
  );

  Map<String, dynamic> toJson() => {
    'status': status,
    'statuscode': statuscode,
    'message': message,
    'end_time': endTime,
  };
}
