import 'package:flutter/material.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/topSection.dart';


class ImageView extends StatelessWidget {
  final String imageUrl;
  final String name;

  BuildContext ctx;

  ImageView({super.key, required this.imageUrl,required this.name,required this.ctx});


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
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),

                ),

              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 90),
            child: Center(
              child: Container(
                child: InteractiveViewer(
                 // boundaryMargin: EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4,
                  child: Image.network(imageUrl),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}