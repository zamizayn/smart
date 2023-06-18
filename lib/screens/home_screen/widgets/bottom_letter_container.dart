import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/LetterProvider/letter_provider.dart';
import 'package:smart_station/screens/home_screen/letter/letter_compose_screen.dart';

import '../../../utils/constants/app_constants.dart';

class BottomLetterContainer extends StatelessWidget {
  const BottomLetterContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LetterProvider>(builder: (context, letter, child) {
      return Container(
        height: 80,
        width: MediaQuery.of(context).size.width,
        color: Colors.grey[300],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              child:
              InkWell(
                  onTap: () =>
                  {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LetterComposeScreen())),
                  },
                  child: Image(image: AssetImage(composeIcon))),
            ),

            SizedBox(
              height: 27,
              child: Container(child: Image(image: AssetImage(transpLogo),),),
            ),
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(25),
                  child: Image(image: AssetImage(countIcon)),
                ),
                (letter.unread!='null' && letter.unread!='0' && letter.unread!='') ?
                Positioned(
                  top: 16,
                  right: 10,
                  child: Container(
                    height: 17,
                    width: 32,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Text(
                        letter.unread
                    ),),
                  ),
                )
                    : const SizedBox()
              ],
            ),
          ],
        ),
      );
    },);
  }
}
