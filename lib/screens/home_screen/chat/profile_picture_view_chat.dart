import 'package:flutter/material.dart';

import '../../../utils/constants/app_constants.dart';
import '../popup_screens/widget/topSection.dart';
class ProfilePictureViewChat extends StatefulWidget {
  final name;
  final picture;
  const ProfilePictureViewChat({super.key,required this.name,required this.picture});

  @override
  State<ProfilePictureViewChat> createState() => _ProfilePictureViewChatState();
}

class _ProfilePictureViewChatState extends State<ProfilePictureViewChat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: Stack(
        children: [
           const TopSection(),
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(splashBg), fit: BoxFit.fill)),
            ),
                        Positioned(
              top: 40,
              left: 0,
              right: 20,

              child: Row(
                children: [
                  const BackButton(color: Colors.white),
                   Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),

                  ),
                 
                ],
              ),
            ),

          Center(
            child: SizedBox(
              //padding: const EdgeInsets.all(10),
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
              child:  Image.network(widget.picture, fit: BoxFit.fitWidth),
            ),
          ),
        ],
      ),
    );
  }
}