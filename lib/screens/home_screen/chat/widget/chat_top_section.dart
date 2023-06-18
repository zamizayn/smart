import 'package:flutter/material.dart';

class ChatTopSection extends StatefulWidget {
  const ChatTopSection({Key? key}) : super(key: key);

  @override
  State<ChatTopSection> createState() => _ChatTopSectionState();
}

class _ChatTopSectionState extends State<ChatTopSection> {
  @override
  Widget build(BuildContext context) {
    return  Container(
      height: 140,
      width: double.infinity,
      color: Colors.black26,
    );
  }
}
