import 'package:flutter/material.dart';
import 'package:smart_station/screens/home_screen/widgets/bottom_container.dart';
import 'package:smart_station/screens/home_screen/widgets/bottom_email_container.dart';
import 'package:smart_station/screens/home_screen/widgets/bottom_letter_container.dart';

class BottomBarSection extends StatefulWidget {
  int tabIndex;
  final List emailList;

  BottomBarSection({Key? key, required this.tabIndex, required this.emailList})
      : super(key: key);

  @override
  State<BottomBarSection> createState() => _BottomBarSectionState();
}

class _BottomBarSectionState extends State<BottomBarSection> {
  @override
  Widget build(BuildContext context) {
    if (widget.tabIndex == 0) return const BottomContainer();
    if (widget.tabIndex == 1) return BottomEmailContainer(emailList:widget.emailList ,);
    if (widget.tabIndex == 2) return const BottomLetterContainer();
    return Container();
  }
}