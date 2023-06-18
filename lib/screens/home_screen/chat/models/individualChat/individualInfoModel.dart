
//     final individualInfoModel = individualInfoModelFromJson(jsonString);

import 'dart:convert';

class IndividualInfoModel {
    IndividualInfoModel({
        required this.status,
        required this.statuscode,
        required this.message,
        required this.data,
    });

    bool status;
    int statuscode;
    String message;
    Data data;

    factory IndividualInfoModel.fromRawJson(String str) => IndividualInfoModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory IndividualInfoModel.fromJson(Map<String, dynamic> json) => IndividualInfoModel(
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
        required this.receiverData,
        required this.commonGroupData,
        required this.mediaCount,
        required this.userBlockStatus,
        required this.mute,
    });

    ReceiverData receiverData;
    CommonGroupData commonGroupData;
    int mediaCount;
    int userBlockStatus;
    Mute mute;

    factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        receiverData: ReceiverData.fromJson(json['receiver_data']),
        commonGroupData: CommonGroupData.fromJson(json['common_group_data']),
        mediaCount: json['media_count'],
        userBlockStatus: json['user_block_status'],
        mute: Mute.fromJson(json['mute']),
    );

    Map<String, dynamic> toJson() => {
        'receiver_data': receiverData.toJson(),
        'common_group_data': commonGroupData.toJson(),
        'media_count': mediaCount,
        'user_block_status': userBlockStatus,
        'mute': mute.toJson(),
    };
}

class CommonGroupData {
    CommonGroupData({
        required this.noOfGroups,
        required this.data,
    });

    int noOfGroups;
    List<Datum> data;

    factory CommonGroupData.fromRawJson(String str) => CommonGroupData.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory CommonGroupData.fromJson(Map<String, dynamic> json) => CommonGroupData(
        noOfGroups: json['no_of_groups'],
        data: List<Datum>.from(json['data'].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        'no_of_groups': noOfGroups,
        'data': List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    Datum({
        required this.groupId,
        required this.groupName,
        required this.groupProfilePic,
        required this.groupUsers,
    });

    String groupId;
    String groupName;
    String groupProfilePic;
    String groupUsers;

    factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        groupId: json['group_id'],
        groupName: json['group_name'],
        groupProfilePic: json['group_profile_pic'],
        groupUsers: json['group_users'],
    );

    Map<String, dynamic> toJson() => {
        'group_id': groupId,
        'group_name': groupName,
        'group_profile_pic': groupProfilePic,
        'group_users': groupUsers,
    };
}

class Mute {
    Mute({
        required this.muteStatus,
        required this.endDatetime,
    });

    int muteStatus;
    String endDatetime;

    factory Mute.fromRawJson(String str) => Mute.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Mute.fromJson(Map<String, dynamic> json) => Mute(
        muteStatus: json['mute_status'],
        endDatetime: json['end_datetime'],
    );

    Map<String, dynamic> toJson() => {
        'mute_status': muteStatus,
        'end_datetime': endDatetime,
    };
}

class ReceiverData {
    ReceiverData({
        required this.name,
        required this.profilePic,
        required this.phone,
        required this.about,
        required this.aboutUpdatedDatetime,
        required this.companyMail,
        required this.deviceToken,
    });

    String name;
    String profilePic;
    String phone;
    String about;
    DateTime aboutUpdatedDatetime;
    String companyMail;
    String deviceToken;

    factory ReceiverData.fromRawJson(String str) => ReceiverData.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ReceiverData.fromJson(Map<String, dynamic> json) => ReceiverData(
        name: json['name'],
        profilePic: json['profile_pic'],
        phone: json['phone'],
        about: json['about'],
        aboutUpdatedDatetime: DateTime.parse(json['about_updated_datetime']),
        companyMail: json['company_mail'],
        deviceToken: json['device_token'],
    );

    Map<String, dynamic> toJson() => {
        'name': name,
        'profile_pic': profilePic,
        'phone': phone,
        'about': about,
        'about_updated_datetime': aboutUpdatedDatetime.toIso8601String(),
        'company_mail': companyMail,
        'device_token': deviceToken,
    };
}
