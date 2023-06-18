// To parse this JSON data, do
//
//     final individualMediaModel = individualMediaModelFromJson(jsonString);

import 'dart:convert';

class IndividualMediaModel {
  IndividualMediaModel({
    required this.status,
    required this.statuscode,
    required this.message,
    required this.data,
  });

  final bool status;
  final int statuscode;
  final String message;
  final Data data;

  factory IndividualMediaModel.fromRawJson(String str) => IndividualMediaModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory IndividualMediaModel.fromJson(Map<String, dynamic> json) => IndividualMediaModel(
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
    required this.medias,
    required this.docs,
    required this.links,
  });

  final List<Doc> medias;
  final List<Doc> docs;
  final List<dynamic> links;

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    medias: List<Doc>.from(json['medias'].map((x) => Doc.fromJson(x))),
    docs: List<Doc>.from(json['docs'].map((x) => Doc.fromJson(x))),
    links: List<dynamic>.from(json['links'].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    'medias': List<dynamic>.from(medias.map((x) => x.toJson())),
    'docs': List<dynamic>.from(docs.map((x) => x.toJson())),
    'links': List<dynamic>.from(links.map((x) => x)),
  };
}

class Doc {
  Doc({
    required this.id,
    required this.userId,
    required this.username,
    required this.date,
    required this.path,
    required this.duration,
    required this.type,
    required this.thumbnail,
  });

  final String id;
  final String userId;
  final String username;
  final String date;
  final String path;
  final String duration;
  final String type;
  final String thumbnail;

  factory Doc.fromRawJson(String str) => Doc.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Doc.fromJson(Map<String, dynamic> json) => Doc(
    id: json['id'],
    userId: json['user_id'],
    username: json['username'],
    date: json['date'],
    path: json['path'],
    duration: json['duration'],
    type: json['type'],
    thumbnail: json['thumbnail'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'username': username,
    'date': date,
    'path': path,
    'duration': duration,
    'type': type,
    'thumbnail': thumbnail,
  };
}
