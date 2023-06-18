import 'package:flutter/material.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/bottomSection.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/topSection.dart';
import 'package:smart_station/utils/constants/app_constants.dart';

class GroupInfoScreen extends StatefulWidget {
  const GroupInfoScreen({Key? key}) : super(key: key);

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              left: 0,
              right: 20,

              child: Row(
                children: const [
                  BackButton(color: Colors.white),
                  Text(
                    'Group Name',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),

                  ),

                ],
              ),
            ),
            const Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child:
              BottomSectionTransp(),
            )
          ]
      ),
    );
  }
}
