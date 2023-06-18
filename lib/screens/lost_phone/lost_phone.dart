import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/lost_phone_provider.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/topSection.dart';
import '../../../utils/constants/app_constants.dart';
//import 'package:image_cropper/image_cropper.dart';

class LostPhone extends StatefulWidget {
  String deviceToken;
  LostPhone({Key? key, required this.deviceToken}) : super(key: key);
  // const LostPhone({Key? key}) : super(key: key);

  @override
  State<LostPhone> createState() => _LostPhoneState();
}

class _LostPhoneState extends State<LostPhone> {
  var expr = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  @override
  Widget build(BuildContext context) {
    return Consumer<LostPhoneProvider>(
      builder: (context, lost, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
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
                child: Row(
                  children: const [
                    BackButton(color: Colors.white),
                    Text(
                      'Lost Phone / Mobile Number',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                top: 180,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  child: Image(
                    width: 30,
                    height: 30,
                    image: AssetImage(mailIcon),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    SizedBox(
                      width: 70,
                      child: Image(
                        image: AssetImage(transpLogo),
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        if (expr.hasMatch(lost.emailController.text)) {
                          lost.sendOtp(
                            mail_id: lost.emailController.text,
                            deviceToken: widget.deviceToken,
                            context: context,
                          );
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            duration: Duration(milliseconds: 1000),
                            content: Text('Please enter a valid email address'),
                          ));
                        }
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  textGreen,
                                  textGreen,
                                  rightGreen,
                                ]),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Center(
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 280,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: Center(
                          child: Text.rich(
                            TextSpan(
                              text: 'Please enter your ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textGreen,
                              ),
                              children: const [
                                TextSpan(
                                  text: 'email address',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: ' to receive a verification code',
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 120),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              'Email Address',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textGreen,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 55,
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.black12,
                            ),
                            child: TextFormField(
                              controller: lost.emailController,
                              decoration: InputDecoration(
                                fillColor: Colors.grey[100],
                                filled: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
