// To parse this JSON data, do
//
//     final mediaGroupItems = mediaGroupItemsFromJson(jsonString);

import 'dart:convert';



class MediaGroupItems {
    final bool status;
    final int statuscode;
    final String message;
    final Data data;

    MediaGroupItems({
        required this.status,
        required this.statuscode,
        required this.message,
        required this.data,
    });

    factory MediaGroupItems.fromRawJson(String str) => MediaGroupItems.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory MediaGroupItems.fromJson(Map<String, dynamic> json) => MediaGroupItems(
        status: json["status"],
        statuscode: json["statuscode"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "statuscode": statuscode,
        "message": message,
        "data": data.toJson(),
    };
}

class Data {
    final Medias medias;
    final Docs docs;
    final Docs links;

    Data({
        required this.medias,
        required this.docs,
        required this.links,
    });

    factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        medias: Medias.fromJson(json["medias"]),
        docs: Docs.fromJson(json["docs"]),
        links: Docs.fromJson(json["links"]),
    );

    Map<String, dynamic> toJson() => {
        "medias": medias.toJson(),
        "docs": docs.toJson(),
        "links": links.toJson(),
    };
}

class Docs {
    final List<dynamic> list;
    final List<dynamic> listDates;

    Docs({
        required this.list,
        required this.listDates,
    });

    factory Docs.fromRawJson(String str) => Docs.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Docs.fromJson(Map<String, dynamic> json) => Docs(
        list: List<dynamic>.from(json["list"].map((x) => x)),
        listDates: List<dynamic>.from(json["list_dates"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "list": List<dynamic>.from(list.map((x) => x)),
        "list_dates": List<dynamic>.from(listDates.map((x) => x)),
    };
}

class Medias {
    final List<String> list;
    final List<ListData> listDatas;

    Medias({
        required this.list,
        required this.listDatas,
    });

    factory Medias.fromRawJson(String str) => Medias.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Medias.fromJson(Map<String, dynamic> json) => Medias(
        list: List<String>.from(json["list"].map((x) => x)),
        listDatas: List<ListData>.from(json["list_datas"].map((x) => ListData.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "list": List<dynamic>.from(list.map((x) => x)),
        "list_datas": List<dynamic>.from(listDatas.map((x) => x.toJson())),
    };
}

class ListData {
    final List<LastMonth> lastMonth;

    ListData({
        required this.lastMonth,
    });

    factory ListData.fromRawJson(String str) => ListData.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ListData.fromJson(Map<String, dynamic> json) => ListData(
        lastMonth: List<LastMonth>.from(json["Last Month"].map((x) => LastMonth.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "Last Month": List<dynamic>.from(lastMonth.map((x) => x.toJson())),
    };
}

class LastMonth {
    final String id;
    final String userId;
    final String username;
    final DateTime date;
    final String path;
    final String type;
    final String thumbnail;

    LastMonth({
        required this.id,
        required this.userId,
        required this.username,
        required this.date,
        required this.path,
        required this.type,
        required this.thumbnail,
    });

    factory LastMonth.fromRawJson(String str) => LastMonth.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory LastMonth.fromJson(Map<String, dynamic> json) => LastMonth(
        id: json["id"],
        userId: json["user_id"],
        username: json["username"],
        date: DateTime.parse(json["date"]),
        path: json["path"],
        type: json["type"],
        thumbnail: json["thumbnail"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "username": username,
        "date": date.toIso8601String(),
        "path": path,
        "type": type,
        "thumbnail": thumbnail,
    };
}


// class MediaGroupItems {
//     MediaGroupItems({
//         required this.status,
//         required this.statuscode,
//         required this.message,
//         required this.data,
//     });

//     final bool status;
//     final int statuscode;
//     final String message;
//     final Data data;

//     factory MediaGroupItems.fromRawJson(String str) => MediaGroupItems.fromJson(json.decode(str));

//     String toRawJson() => json.encode(toJson());

//     factory MediaGroupItems.fromJson(Map<String, dynamic> json) => MediaGroupItems(
//         status: json['status'],
//         statuscode: json['statuscode'],
//         message: json['message'],
//         data: Data.fromJson(json['data']),
//     );

//     Map<String, dynamic> toJson() => {
//         'status': status,
//         'statuscode': statuscode,
//         'message': message,
//         'data': data.toJson(),
//     };
// }

// class Data {
//     Data({
//         required this.medias,
//         required this.docs,
//         required this.links,
//     });

//     final List<Media> medias;
//     final List<dynamic> docs;
//     final List<dynamic> links;

//     factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

//     String toRawJson() => json.encode(toJson());

//     factory Data.fromJson(Map<String, dynamic> json) => Data(
//         medias: List<Media>.from(json['medias'].map((x) => Media.fromJson(x))),
//         docs: List<dynamic>.from(json['docs'].map((x) => x)),
//         links: List<dynamic>.from(json['links'].map((x) => x)),
//     );

//     Map<String, dynamic> toJson() => {
//         'medias': List<dynamic>.from(medias.map((x) => x.toJson())),
//         'docs': List<dynamic>.from(docs.map((x) => x)),
//         'links': List<dynamic>.from(links.map((x) => x)),
//     };
// }

// class Media {
//     Media({
//         required this.id,
//         required this.userId,
//         required this.username,
//         required this.date,
//         required this.path,
//         required this.type,
//         required this.thumbnail,
//     });

//     final String id;
//     final String userId;
//     final String username;
//     final DateTime date;
//     final String path;
//     final String type;
//     final String thumbnail;

//     factory Media.fromRawJson(String str) => Media.fromJson(json.decode(str));

//     String toRawJson() => json.encode(toJson());

//     factory Media.fromJson(Map<String, dynamic> json) => Media(
//         id: json['id'],
//         userId: json['user_id'],
//         username: json['username'],
//         date: DateTime.parse(json['date']),
//         path: json['path'],
//         type: json['type'],
//         thumbnail: json['thumbnail'],
//     );

//     Map<String, dynamic> toJson() => {
//         'id': id,
//         'user_id': userId,
//         'username': username,
//         'date': date.toIso8601String(),
//         'path': path,
//         'type': type,
//         'thumbnail': thumbnail,
//     };
// }
