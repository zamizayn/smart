import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/providers/NotificationProvider/notification_provider.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/bottomSection.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/topSection.dart';
import 'package:smart_station/utils/constants/app_constants.dart';


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool isNotification = false;
  bool isSound = false;
  bool isVibrate = false;
  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    return Consumer<NotificationProvider>(
      builder: (context, notification, child) {
        return  Scaffold(
          body: Stack(
            clipBehavior: Clip.none,
            children: [
              const TopSection(),
              Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(splashBg), fit: BoxFit.fill)),
              ),
              Positioned(
                top: 50,
                child: Row(
                  children: const [
                    BackButton(color: Colors.white),
                    Text(
                      'Notification',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                top: 170,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 1.2,
                    height: MediaQuery.of(context).size.height / 3,
                    // color: Colors.red,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Show Notification',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Transform.scale( scale: 1.3,
                                  child: Switch(
                                    value: notification.isNotify == '1' ? true : false,
                                    onChanged: (value) {
                                      setState(() {
                                        isNotification = value;
                                        print(isNotification);
                                        notification.changeStatus(status: isNotification ? '1' : '0', notfyFor: 'notification', accessToken: auth.accessToken, userId: auth.userId);
                                      });
                                    },
                                    activeTrackColor: Colors.green,
                                    activeColor: Colors.white,
                                  ),
                                ),

                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [

                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Sound',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Transform.scale( scale: 1.3,
                                  child: Switch(
                                    value: notification.isSound == '1' ? true : false,
                                    onChanged: (value) {
                                      setState(() {
                                        isSound = value;
                                        print(isSound);
                                        notification.changeStatus(status: isSound ? '1' : '0', notfyFor: 'sound', accessToken: auth.accessToken, userId: auth.userId);
                                      });
                                    },
                                    activeTrackColor: Colors.green,
                                    activeColor: Colors.white,
                                  ),
                                ),

                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [

                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Vibrate',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Transform.scale( scale: 1.3,
                                  child: Switch(
                                    value: notification.isVbr == '1' ? true : false,
                                    onChanged: (value) {
                                      setState(() {
                                        isVibrate = value;
                                        print(isVibrate);
                                        notification.changeStatus(status: isVibrate ? '1' : '0', notfyFor: 'vibration', accessToken: auth.accessToken, userId: auth.userId);
                                      });
                                    },
                                    activeTrackColor: Colors.green,
                                    activeColor: Colors.white,
                                  ),
                                ),

                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child:
                BottomSection(),
              )
            ],
          ),
        );
      },
    );
  }
}
