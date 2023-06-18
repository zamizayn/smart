import 'package:flutter/material.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/bottomSection.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/topSection.dart';
import 'package:smart_station/utils/constants/app_constants.dart';

class EmailInboxScreen extends StatefulWidget {
  const EmailInboxScreen({Key? key}) : super(key: key);

  @override
  State<EmailInboxScreen> createState() => _EmailInboxScreenState();
}

class _EmailInboxScreenState extends State<EmailInboxScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('fd');
   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            scrolledUnderElevation: 2,
            backgroundColor: Colors.black38,
            elevation: 0,
            title: const Text(
              'Email Inbox',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ))),
        body: Column(
          children: [],
        ));
  }
}
