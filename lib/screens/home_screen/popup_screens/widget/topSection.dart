import 'package:flutter/material.dart';
import 'package:smart_station/utils/constants/app_constants.dart';


class TopSection extends StatelessWidget {
  const TopSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Container(
      height: 90,
      width: double.infinity,
      color: Colors.black38,
    );
  }
}
class TopSection2 extends StatelessWidget {
  const TopSection2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Container(
      height: 120,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(splashBg), fit: BoxFit.cover)),
      width: double.infinity,

    );
  }
}
