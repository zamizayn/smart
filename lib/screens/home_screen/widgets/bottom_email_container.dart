import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/EmailProvider/email_provider.dart';
import 'package:smart_station/screens/home_screen/email/email_compose_screen.dart';

import '../../../utils/constants/app_constants.dart';

class BottomEmailContainer extends StatelessWidget {
  final List emailList;

  const BottomEmailContainer({super.key, required this.emailList});

  @override
  Widget build(BuildContext context) {
    return Consumer<EmailProvider>(
      builder: (context, email, child) {
        return Container(
          height: 80,
          width: MediaQuery.of(context).size.width,
          color: Colors.grey[300],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(25),
                child: InkWell(
                    onTap: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => EmailComposeScreen(
                                        replayBody: '',
                                        forwardbool: false,
                                        replayEmail: '',
                                        replaySubject: '',
                                        emailList: emailList,
                                      ))),
                        },
                    child: Image(image: AssetImage(composeIcon))),
              ),
              SizedBox(
                height: 27,
                child: Container(
                  child: Image(
                    image: AssetImage(transpLogo),
                  ),
                ),
              ),
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(25),
                    child: Image(image: AssetImage(countIcon)),
                  ),
                  (email.unread != 'null' &&
                          email.unread != '0' &&
                          email.unread != '')
                      ? Positioned(
                          top: 16,
                          right: 10,
                          child: Container(
                            height: 17,
                            width: 32,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(email.unread),
                            ),
                          ),
                        )
                      : const Text(''),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
