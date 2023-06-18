// To parse this JSON data, do
//
//     final IndividualBlockModel = IndividualBlockModelFromJson(jsonString);

import 'dart:convert';

class IndividualBlockModel {
  IndividualBlockModel({
    required this.status,
    required this.statuscode,
    required this.message,
  });

  final bool status;
  final int statuscode;
  final String message;

  factory IndividualBlockModel.fromRawJson(String str) => IndividualBlockModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory IndividualBlockModel.fromJson(Map<String, dynamic> json) => IndividualBlockModel(
    status: json['status'],
    statuscode: json['statuscode'],
    message: json['message'],
  );

  Map<String, dynamic> toJson() => {
    'status': status,
    'statuscode': statuscode,
    'message': message,
  };
}
