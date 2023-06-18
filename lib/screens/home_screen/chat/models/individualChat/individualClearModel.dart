// To parse this JSON data, do
//
//     final individualClearModel = individualClearModelFromJson(jsonString);

import 'dart:convert';

class IndividualClearModel {
  IndividualClearModel({
    required this.status,
    required this.statuscode,
    required this.message,
  });

  final bool status;
  final int statuscode;
  final String message;

  factory IndividualClearModel.fromRawJson(String str) => IndividualClearModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory IndividualClearModel.fromJson(Map<String, dynamic> json) => IndividualClearModel(
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
