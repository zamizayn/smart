// ignore_for_file: file_names

import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_station/screens/callAndNotification/Calling%20Individual/vediocall.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'Calling Individual/audioCalling.dart';
import 'groupCall/groupAudioCall.dart';
import 'groupCall/grupVideocall.dart';

class NotificationServices {
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // String title = message.notification.title.toString();
    // String body = message.notification!.body.toString();
    String reject = message.data['type'].toString();
    String groupCallId = message.data['id'].toString();
    String callerFCM = '';
    String callerName = '';
    print('___________________------------------------------_________________');
    print(groupCallId);
    print('_______________---------type----------------------');
    print(message.data['type']);
    print('_______________------type-------------------------');
    print('keyy');
    print(message.data['my_key']);

    print(message.data['fromFCM']);
    if (message.data['type'] == 'videoCall' ||
        message.data['type'] == 'audioCall' ||
        message.data['type'] == 'gruopeAudioCall' ||
        message.data['type'] == 'gruopeVideoCall') {
      callerFCM = message.data['fromFCM'];
      callerName = message.notification!.body.toString();
      AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 123,
            channelKey: 'call_channel',
            color: Colors.white,
            title: message.notification!.title.toString(),
            body: message.notification!.body.toString(),
            category: NotificationCategory.Call,
            wakeUpScreen: true,
            fullScreenIntent: true,
            autoDismissible: false,
            backgroundColor: Colors.orange,
          ),
          actionButtons: [
            NotificationActionButton(
                key: 'ACCEPT',
                label: 'Accept Call',
                color: Colors.green,
                autoDismissible: true),
            NotificationActionButton(
                key: 'REJECT',
                label: 'Reject Call',
                color: Colors.red,
                autoDismissible: true),
          ]);
      Timer(const Duration(seconds: 45), () {
        if (reject == 'REJECT') {
          print('Recjected CAll');
        } else {
          AwesomeNotifications().cancel(123);
          AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: 11,
              channelKey: 'Missed_CAll',
              color: Colors.white,
              title: 'Missed Call',
              wakeUpScreen: true,
              body: callerName,
              category: NotificationCategory.MissedCall,
            ),
            // actionButtons: [
            //   NotificationActionButton(
            //       key: 'Call',
            //       label: 'Call',
            //       color: Colors.green,
            //       autoDismissible: true),
            //   NotificationActionButton(
            //       key: 'Message',
            //       label: 'Message',
            //       color: Colors.red,
            //       autoDismissible: true),
            // ]
          );
        }
      });
    } else if (message.data['type'] == 'REJECT') {
      print('object');
    } else if (message.data['type'] == 'endByCaller') {
      AwesomeNotifications().cancel(123);
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 11,
          channelKey: 'Missed_CAll',
          color: Colors.white,
          title: 'Missed Call',
          wakeUpScreen: true,
          body: callerName,
          category: NotificationCategory.MissedCall,
        ),
        // actionButtons: [
        //   NotificationActionButton(
        //       key: "Call",
        //       label: "Call",
        //       color: Colors.green,
        //       autoDismissible: true),
        //   NotificationActionButton(
        //       key: "Message",
        //       label: "Message",
        //       color: Colors.red,
        //       autoDismissible: true),
        // ]
      );
    } else if (message.data['type'] == 'ACCEPT') {
    } else if (message.data['type'] == 'REJECT') {
      AwesomeNotifications().cancel(123);
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 11,
          channelKey: 'Missed_CAll',
          color: Colors.white,
          title: 'Missed Call',
          wakeUpScreen: true,
          body: callerName,
          category: NotificationCategory.MissedCall,
        ),
        // actionButtons: [
        //   NotificationActionButton(
        //       key: "Call",
        //       label: "Call",
        //       color: Colors.green,
        //       autoDismissible: true),
        //   NotificationActionButton(
        //       key: "Message",
        //       label: "Message",
        //       color: Colors.red,
        //       autoDismissible: true),
        // ]
      );
    } else if (message.data['type'] == 'individual' ||
        message.data['type'] == 'group') {
      print('notication for message');
      String splitValues = '';
      if (message.data['type'] == 'group') {
        splitValues = message.data['user_id'];
        splitValues.trim();
        print(splitValues);
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: int.parse(splitValues.substring(splitValues.length - 5)),
            channelKey: 'chat_messages',
            title: message.data['title'],
            body: message.data['message'],
            roundedLargeIcon: true,
            largeIcon: message.data['profile_pic'],
            notificationLayout: NotificationLayout.Messaging,
            summary: '',
            showWhen: true,
            displayOnForeground: true,
          ),
        );
      } else {
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: int.parse(message.data['user_id']),
            channelKey: 'chat_messages',
            title: message.data['title'],
            body: message.data['message'],
            roundedLargeIcon: true,
            largeIcon: message.data['profile_pic'],
            notificationLayout: NotificationLayout.Messaging,
            summary: '',
            showWhen: true,
            displayOnForeground: true,
          ),
        );
      }
    } else if (message.data['type'] == 'email') {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 0 + int.parse(message.data['user_id']),
          channelKey: 'chat_messages',
          title: message.data['title'],
          body: message.data['message'],
          roundedLargeIcon: true,
          largeIcon: message.data['profile_pic'],
          notificationLayout: NotificationLayout.Messaging,
          summary: 'email',
          showWhen: true,
          displayOnForeground: true,
        ),
      );
    } else if (message.data['type'] == 'letter') {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 00 + int.parse(message.data['user_id']),
          channelKey: 'chat_messages',
          title: message.data['title'],
          body: message.data['message'],
          roundedLargeIcon: true,
          largeIcon: message.data['profile_pic'],
          notificationLayout: NotificationLayout.Messaging,
          summary: 'letter',
          showWhen: true,
          displayOnForeground: true,
        ),
      );
    } else if (message.data['type'] == 'cloud') {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 0 + int.parse(message.data['user_id']) + 0,
          channelKey: 'chat_messages',
          title: message.data['title'],
          body: message.data['message'],
          roundedLargeIcon: true,
          largeIcon: message.data['profile_pic'],
          notificationLayout: NotificationLayout.Messaging,
          summary: 'cloud',
          showWhen: true,
          displayOnForeground: true,
        ),
      );
    }
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: (receivedAction) => onActionReceivedMethod(
            receivedAction,
            callerFCM.toString(),
            message.data['type'].toString(),
            message.notification!.body.toString(),
            groupCallId.toString()));
  }

  static callNotification() {
    FirebaseMessaging.onMessage.listen((message) {
      // String title = message.notification.title.toString();
      // String body = message.notification!.body.toString();
      String reject = message.data['type'].toString();
      String groupCallId = message.data['id'].toString();
      String callerFCM = '';
      String callerName = '';

      print(
          '___________________------------------------------_________________');
      print(groupCallId);
      print('_______________---------type----------------------');
      print(message.data);
      print(message.data['type']);
      print('_______________------type-------------------------');
      print('_______________------type-------------------------');
      print('keyy');
      print(message.data['my_key']);
      print(message.data['fromFCM']);
      if (message.data['type'] == 'videoCall' ||
          message.data['type'] == 'audioCall' ||
          message.data['type'] == 'gruopeAudioCall' ||
          message.data['type'] == 'gruopeVideoCall') {
        callerFCM = message.data['fromFCM'];
        callerName = message.notification!.body.toString();

        AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: 123,
              channelKey: 'call_channel',
              color: Colors.white,
              title: message.notification!.title.toString(),
              body: message.notification!.body.toString(),
              category: NotificationCategory.Call,
              wakeUpScreen: true,
              fullScreenIntent: true,
              autoDismissible: false,
              backgroundColor: Colors.orange,
            ),
            actionButtons: [
              NotificationActionButton(
                  key: 'ACCEPT',
                  label: 'Accept Call',
                  color: Colors.green,
                  autoDismissible: true),
              NotificationActionButton(
                  key: 'REJECT',
                  label: 'Reject Call',
                  color: Colors.red,
                  autoDismissible: true),
            ]);
        Timer(const Duration(seconds: 45), () {
          if (reject == 'REJECT') {
            print('Recjected CAll');
          } else {
            AwesomeNotifications().cancel(123);
            AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: 11,
                channelKey: 'Missed_CAll',
                color: Colors.white,
                title: 'Missed Call',
                wakeUpScreen: true,
                body: callerName,
                category: NotificationCategory.MissedCall,
              ),
              // actionButtons: [
              //   NotificationActionButton(
              //       key: 'Call',
              //       label: 'Call',
              //       color: Colors.green,
              //       autoDismissible: true),
              //   NotificationActionButton(
              //       key: 'Message',
              //       label: 'Message',
              //       color: Colors.red,
              //       autoDismissible: true),
              // ]
            );
          }
        });
      } else if (message.data['type'] == 'REJECT') {
        print('object');
      } else if (message.data['type'] == 'endByCaller') {
        AwesomeNotifications().cancel(123);
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 11,
            channelKey: 'Missed_CAll',
            color: Colors.white,
            title: 'Missed Call',
            wakeUpScreen: true,
            body: callerName,
            category: NotificationCategory.MissedCall,
          ),
          // actionButtons: [
          //   NotificationActionButton(
          //       key: "Call",
          //       label: "Call",
          //       color: Colors.green,
          //       autoDismissible: true),
          //   NotificationActionButton(
          //       key: "Message",
          //       label: "Message",
          //       color: Colors.red,
          //       autoDismissible: true),
          // ]
        );
      } else if (message.data['type'] == 'ACCEPT') {
      } else if (message.data['type'] == 'REJECT') {
        AwesomeNotifications().cancel(123);
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 11,
            channelKey: 'Missed_CAll',
            color: Colors.white,
            title: 'Missed Call',
            wakeUpScreen: true,
            body: callerName,
            category: NotificationCategory.MissedCall,
          ),
          // actionButtons: [
          //   NotificationActionButton(
          //       key: "Call",
          //       label: "Call",
          //       color: Colors.green,
          //       autoDismissible: true),
          //   NotificationActionButton(
          //       key: "Message",
          //       label: "Message",
          //       color: Colors.red,
          //       autoDismissible: true),
          // ]
        );
      } else if (message.data['type'] == 'individual' ||
          message.data['type'] == 'group') {
        print('notication for message');
        String splitValues = '';
        if (message.data['type'] == 'group') {
          splitValues = message.data['user_id'];
          splitValues.trim();
          print(splitValues);
          AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: int.parse(splitValues.substring(splitValues.length - 5)),
              channelKey: 'chat_messages',
              title: message.data['title'],
              body: message.data['message'],
              roundedLargeIcon: true,
              largeIcon: message.data['profile_pic'],
              notificationLayout: NotificationLayout.Messaging,
              summary: '',
              showWhen: true,
              displayOnForeground: true,
            ),
          );
        } else {
          AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: int.parse(message.data['user_id']),
              channelKey: 'chat_messages',
              title: message.data['title'],
              body: message.data['message'],
              roundedLargeIcon: true,
              largeIcon: message.data['profile_pic'],
              notificationLayout: NotificationLayout.Messaging,
              summary: '',
              showWhen: true,
              displayOnForeground: true,
            ),
          );
        }
      } else if (message.data['type'] == 'email') {
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 0 + int.parse(message.data['user_id']),
            channelKey: 'chat_messages',
            title: message.data['title'],
            body: message.data['message'],
            roundedLargeIcon: true,
            largeIcon: message.data['profile_pic'],
            notificationLayout: NotificationLayout.Messaging,
            summary: 'email',
            showWhen: true,
            displayOnForeground: true,
          ),
        );
      } else if (message.data['type'] == 'letter') {
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 00 + int.parse(message.data['user_id']),
            channelKey: 'chat_messages',
            title: message.data['title'],
            body: message.data['message'],
            roundedLargeIcon: true,
            largeIcon: message.data['profile_pic'],
            notificationLayout: NotificationLayout.Messaging,
            summary: 'letter',
            showWhen: true,
            displayOnForeground: true,
          ),
        );
      } else if (message.data['type'] == 'cloud') {
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 0 + int.parse(message.data['user_id']) + 0,
            channelKey: 'chat_messages',
            title: message.data['title'],
            body: message.data['message'],
            roundedLargeIcon: true,
            largeIcon: message.data['profile_pic'],
            notificationLayout: NotificationLayout.Messaging,
            summary: 'cloud',
            showWhen: true,
            displayOnForeground: true,
          ),
        );
      }
      AwesomeNotifications().setListeners(
          onActionReceivedMethod: (receivedAction) => onActionReceivedMethod(
              receivedAction,
              callerFCM.toString(),
              message.data['type'].toString(),
              message.notification!.body.toString(),
              groupCallId.toString()));
    });
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction,
      String fcmkey, String calltype, String name, String groupeCallid) async {
    print('action _______________________------------------------------');
    final String localUserID = Random().nextInt(10000).toString();
    if (receivedAction.buttonKeyPressed == 'REJECT') {
      if (calltype == 'gruopeAudioCall') {
        print(
            'suiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii');
        print('REJECT,REJECT,REJECT,REJECT,REJECT');
      } else if (calltype == 'videoCall' || calltype == 'audioCall') {
        try {
          http.Response response = await http.post(
            Uri.parse('https://fcm.googleapis.com/fcm/send'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization':
                  'key=AAAAaV_FFUY:APA91bG7a2R2cvCkc84AKqP0sNa5V9rcM0y2CeoMW_IjPBNJBJ3xkw-J5vxADkGkXpyJ7DgL-LRMYUC66RISh2iwF_O1p1p_gDxD6hmnHGpTMifC-jxPla8_lIwf5QRALvAJEIjyCO4N',
            },
            body: jsonEncode(<String, dynamic>{
              'priority': 'high',
              'data': <String, dynamic>{
                'type': 'REJECT',
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'id': '1',
                'status': 'done'
              },
              'to': fcmkey
            }),
          );
          response;
        } catch (e) {
          0;
        }
      }
      print(fcmkey);

      print('call rejected');
    } else if (receivedAction.buttonKeyPressed == 'ACCEPT') {
      print(
          '___________________________-----------------------------------____________________');
      print('ACCEPT,ACCEPT,ACCEPT,ACCEPT,ACCEPT,ACCEPTACCEPT');
      print(fcmkey);
      print(calltype);
      if (calltype == 'videoCall') {
        try {
          http.Response response = await http.post(
            Uri.parse('https://fcm.googleapis.com/fcm/send'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization':
                  'key=AAAAaV_FFUY:APA91bG7a2R2cvCkc84AKqP0sNa5V9rcM0y2CeoMW_IjPBNJBJ3xkw-J5vxADkGkXpyJ7DgL-LRMYUC66RISh2iwF_O1p1p_gDxD6hmnHGpTMifC-jxPla8_lIwf5QRALvAJEIjyCO4N',
            },
            body: jsonEncode(<String, dynamic>{
              'notification': <String, dynamic>{
                'title': name,
              },
              'priority': 'high',
              'data': <String, dynamic>{
                'type': 'VideoACCEPT',
                'uid': localUserID,
              },
              'to': fcmkey,
            }),
          );
          final SharedPreferences prefs = await SharedPreferences.getInstance();

          print('hyyyyyyyyyyyyyyyyy lests video call');
          navigatorKey.currentState!.push(
            MaterialPageRoute(
              builder: (context) => VideoCallingPage(
                  callID: localUserID,
                  userName: prefs.getString('Name').toString()),
            ),
          );
          response;
        } catch (e) {
          0;
        }
      } else if (calltype == 'audioCall') {
        try {
          http.Response response = await http.post(
            Uri.parse('https://fcm.googleapis.com/fcm/send'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization':
                  'key=AAAAaV_FFUY:APA91bG7a2R2cvCkc84AKqP0sNa5V9rcM0y2CeoMW_IjPBNJBJ3xkw-J5vxADkGkXpyJ7DgL-LRMYUC66RISh2iwF_O1p1p_gDxD6hmnHGpTMifC-jxPla8_lIwf5QRALvAJEIjyCO4N',
            },
            body: jsonEncode(<String, dynamic>{
              'notification': <String, dynamic>{
                'body': 'rishad',
                'title': 'incoming call',
              },
              'priority': 'high',
              'data': <String, dynamic>{
                'type': 'audioACCEPT',
                'uid': localUserID,
              },
              'to': fcmkey,
            }),
          );
          print('hyyyyyyyyyyyyyyyyy lests audio call');
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          navigatorKey.currentState!.push(
            MaterialPageRoute(
              builder: (context) => AudioCallingPage(
                  callID: localUserID,
                  userName: prefs.getString('Name').toString()),
            ),
          );
          response;
        } catch (e) {
          0;
        }
      } else if (calltype == 'gruopeAudioCall') {
        print('Suiiiiiiiiiii');
        print('groupe call acc');
        print('call accepted');
        try {
          http.Response response = await http.post(
            Uri.parse('https://fcm.googleapis.com/fcm/send'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization':
                  'key=AAAAaV_FFUY:APA91bG7a2R2cvCkc84AKqP0sNa5V9rcM0y2CeoMW_IjPBNJBJ3xkw-J5vxADkGkXpyJ7DgL-LRMYUC66RISh2iwF_O1p1p_gDxD6hmnHGpTMifC-jxPla8_lIwf5QRALvAJEIjyCO4N',
            },
            body: jsonEncode(<String, dynamic>{
              'notification': <String, dynamic>{
                'title': name,
              },
              'priority': 'high',
              'data': <String, dynamic>{
                'type': 'GroupeAudioACCEPT',
                'uid': groupeCallid,
              },
              'to': fcmkey,
            }),
          );
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          print('hyyyyyyyyyyyyyyyyy lests video call');
          navigatorKey.currentState!.push(
            MaterialPageRoute(
              builder: (context) => GrupeAudioCallingPage(
                  callID: groupeCallid,
                  userName: prefs.getString('Name').toString()),
            ),
          );
          response;
        } catch (e) {
          0;
        }
      } else if (calltype == 'gruopeVideoCall') {
        try {
          http.Response response = await http.post(
            Uri.parse('https://fcm.googleapis.com/fcm/send'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization':
                  'key=AAAAaV_FFUY:APA91bG7a2R2cvCkc84AKqP0sNa5V9rcM0y2CeoMW_IjPBNJBJ3xkw-J5vxADkGkXpyJ7DgL-LRMYUC66RISh2iwF_O1p1p_gDxD6hmnHGpTMifC-jxPla8_lIwf5QRALvAJEIjyCO4N',
            },
            body: jsonEncode(<String, dynamic>{
              'notification': <String, dynamic>{
                'title': name,
              },
              'priority': 'high',
              'data': <String, dynamic>{
                'type': 'GroupeVideoACCEPT',
                'uid': groupeCallid,
              },
              'to': fcmkey,
            }),
          );
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          print('hyyyyyyyyyyyyyyyyy lests video call');
          navigatorKey.currentState!.push(
            MaterialPageRoute(
              builder: (context) => GrupeVideoCallingPage(
                  callID: groupeCallid,
                  userName: prefs.getString('Name').toString()),
            ),
          );
          response;
        } catch (e) {
          0;
        }
      }
    } else {
      print('clicked on notification');
    }
  }
}