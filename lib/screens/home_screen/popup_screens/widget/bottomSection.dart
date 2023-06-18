import 'package:flutter/material.dart';
import 'package:smart_station/utils/constants/app_constants.dart';

class BottomSection extends StatelessWidget {
  const BottomSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Container(
      child: Column(
        children: [
          SizedBox(
            width: 70,
            child: Image(
              image: AssetImage(greenLogo),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Smart Station',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class BottomSectionTransp extends StatelessWidget {
  const BottomSectionTransp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Container(
      child: Column(
        children: [
          SizedBox(
            width: 60,
            child: Image(
              image: AssetImage(transpLogo),
            ),
          ),

        ],
      ),
    );
  }
}

