// import 'dart:convert';
// import 'dart:io';

// import 'package:crypto/crypto.dart';
// import 'package:flutter_styled_toast/flutter_styled_toast.dart';
// // import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// int zegocloudappID = 684213027;
// String zegocloudappSign =
//     "e53c1e82fd9be54d016d1d7b687613a96f26cbda5ad8e2579c2b9e3254ba2302";
// String userDevicesID = "";
// String userName = "hello";


// Future<String> getUniqueUserId() async { 
//   String? deviceID;
//   // var deviceInfo = "hj";
//   // if (Platform.isIOS) {
//   //   var iosDeviceInfo = await deviceInfo.iosInfo;
//   //   deviceID = iosDeviceInfo.identifierForVendor; // unique ID on iOS
//   // } else if (Platform.isAndroid) {
//   //   var androidDeviceInfo = await deviceInfo.androidInfo;
//   //   deviceID = androidDeviceInfo.androidId; // unique ID on Android
//   // }

//   if (deviceID != null && deviceID.length < 4) {
//     if (Platform.isAndroid) {
//       deviceID += "_android";
//     } else if (Platform.isIOS) {
//       deviceID += "_ios___";
//     }
//   }
//   if (Platform.isAndroid) {
//     deviceID ??= "flutter_user_id_android";
//   } else if (Platform.isIOS) {
//     deviceID ??= "flutter_user_id_ios";
//   }

//   var userID = md5
//       .convert(utf8.encode(deviceID!))
//       .toString()
//       .replaceAll(RegExp(r'[^0-9]'), '');
//   // print("iddddddddd");
//   // print(userID);
//   return userID.substring(userID.length - 6);
// }

// // List<ZegoUIKitUser> getInvitesFromTextCtrl(String textCtrlText) {
// //   List<ZegoUIKitUser> invitees = [];
// //
// //   var inviteeIDs = textCtrlText.trim().replaceAll('，', '');
// //   inviteeIDs.split(",").forEach((inviteeUserID) {
// //     if (inviteeUserID.isEmpty) {
// //       return;
// //     }
// //     print(invitees);
// //     invitees.add(ZegoUIKitUser(
// //       id: inviteeUserID,
// //       name: 'user_$inviteeUserID',
// //     ));
// //   });
// //
// //   return invitees;
// // }

