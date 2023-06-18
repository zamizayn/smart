import 'dart:convert';
import 'package:smart_station/utils/constants/urls.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/lost_phone_provider.dart';

import 'package:smart_station/screens/home_screen/popup_screens/widget/topSection.dart';
import '../../../utils/constants/app_constants.dart';
import '../../providers/AuthProvider/auth_provider.dart';

class OtpScreen extends StatefulWidget {
  String email;
  String deviceToken;
  BuildContext ctxt;
  OtpScreen(
      {Key? key,
      required this.email,
      required this.deviceToken,
      required this.ctxt})
      : super(key: key);
  //const OtpScreen({Key? key}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _textControllers;

  int _selectedIndex = 0;
  var otpPrv;

  @override
  void initState() {
    super.initState();

    _focusNodes = List.generate(6, (_) => FocusNode());
    _textControllers = List.generate(6, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _textControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  void _onFocusChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String getOtpValue() {
    return _textControllers.map((controller) => controller.text).join();
  }

  @override
  Widget build(BuildContext context) {
    // otpPrv = Provider.of<LostPhoneProvider>(widget.ctxt, listen: false);
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
                      'Verification',
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
                              text:
                                  'please enter your verification code we sent to your',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textGreen,
                              ),
                              children: const [
                                TextSpan(
                                  text: ' email address',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
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
                          const Center(
                            child: Text(
                              'Enter 6-digits code',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     SizedBox(
                          //       width: 50,
                          //       child: TextFormField(
                          //         textAlign: TextAlign.center,
                          //         keyboardType: TextInputType.number,
                          //         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          //         decoration: InputDecoration(
                          //           contentPadding: EdgeInsets.symmetric(vertical: 10),
                          //           border: OutlineInputBorder(
                          //             borderSide: BorderSide(
                          //               color: Colors.black,
                          //               width: 2,
                          //             ),
                          //             borderRadius: BorderRadius.circular(10),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //     SizedBox(width: 10),
                          //     SizedBox(
                          //       width: 50,
                          //       child: TextFormField(
                          //         textAlign: TextAlign.center,
                          //         keyboardType: TextInputType.number,
                          //         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          //         decoration: InputDecoration(
                          //           contentPadding: EdgeInsets.symmetric(vertical: 10),
                          //           border: OutlineInputBorder(
                          //             borderSide: BorderSide(
                          //               color: Colors.black,
                          //               width: 2,
                          //             ),
                          //             borderRadius: BorderRadius.circular(10),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //     SizedBox(width: 10),
                          //     SizedBox(
                          //       width: 50,
                          //       child: TextFormField(
                          //         textAlign: TextAlign.center,
                          //         keyboardType: TextInputType.number,
                          //         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          //         decoration: InputDecoration(
                          //           contentPadding: EdgeInsets.symmetric(vertical: 10),
                          //           border: OutlineInputBorder(
                          //             borderSide: BorderSide(
                          //               color: Colors.black,
                          //               width: 2,
                          //             ),
                          //             borderRadius: BorderRadius.circular(10),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //     SizedBox(width: 10),
                          //     SizedBox(
                          //       width: 50,
                          //       child: TextFormField(
                          //         textAlign: TextAlign.center,
                          //         keyboardType: TextInputType.number,
                          //         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          //         decoration: InputDecoration(
                          //           contentPadding: EdgeInsets.symmetric(vertical: 10),
                          //           border: OutlineInputBorder(
                          //             borderSide: BorderSide(
                          //               color: Colors.black,
                          //               width: 2,
                          //             ),
                          //             borderRadius: BorderRadius.circular(10),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //     SizedBox(width: 10),
                          //     SizedBox(
                          //       width: 50,
                          //       child: TextFormField(
                          //         textAlign: TextAlign.center,
                          //         keyboardType: TextInputType.number,
                          //         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          //         decoration: InputDecoration(
                          //           contentPadding: EdgeInsets.symmetric(vertical: 10),
                          //           border: OutlineInputBorder(
                          //             borderSide: BorderSide(
                          //               color: Colors.black,
                          //               width: 2,
                          //             ),
                          //             borderRadius: BorderRadius.circular(10),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //     SizedBox(width: 10),
                          //     SizedBox(
                          //       width: 50,
                          //       child: TextFormField(
                          //         textAlign: TextAlign.center,
                          //         keyboardType: TextInputType.number,
                          //         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          //         decoration: InputDecoration(
                          //           contentPadding: EdgeInsets.symmetric(vertical: 10),
                          //           border: OutlineInputBorder(
                          //             borderSide: BorderSide(
                          //               color: Colors.black,
                          //               width: 2,
                          //             ),
                          //             borderRadius: BorderRadius.circular(10),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              6,
                              (index) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: SizedBox(
                                  width: 45,
                                  height: 50,
                                  child: TextField(
                                    controller: _textControllers[index],
                                    focusNode: _focusNodes[index],
                                    maxLength: 1,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: InputDecoration(
                                      counterText: '',
                                      border: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.grey,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),

                                    onChanged: (value) =>
                                        _onTextChanged(index, value),
                                    // onFocusChange: (hasFocus) {
                                    //   _onFocusChange(index);
                                    // },
                                  ),
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
              Positioned(
                bottom: 150,
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
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () => print('click'),
                            child: Text.rich(
                              TextSpan(
                                text: 'If you did’t receive code? ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textGreen,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Resend',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        print('Resend');
                                        resendOtp();
                                      },
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                      /*onTap: () {
                        lost.sendOtp(
                          mail_id: lost.emailController.text,
                          deviceToken: widget.deviceToken,
                          context: context,
                        );
                      },*/
                      onTap: () {
                        // lost.checkOTP(
                        //    otp: getOtpValue(), device_token: widget.deviceToken, context: context!);
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
                          child: Center(
                            child: InkWell(
                              onTap: () {
                                lost.checkEmailOTP(
                                    otp: getOtpValue(),
                                    email: widget.email,
                                    device_token: widget.deviceToken,
                                    context: context);
                              },
                              child: const Text(
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> resendOtp() async {
    print("resnend Otp");
    String url = AppUrls.appBaseUrl + '/sendemailotp';
    final body = {
      'mail_id': widget.email,
    };

    print('BODY: ${jsonEncode(body)}');

    http.Response req = await http.post(Uri.parse(url), body: jsonEncode(body));
    print(req.body);

    if (req.statusCode == 200 || req.statusCode == 201) {
      final res = jsonDecode(req.body);
      print(res);
      var aProvider = Provider.of<AuthProvider>(context, listen: false);

      var status = res['status'];
      if (status == true) {
        // Show an alert
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('OTP Sent'),
              content: const Text('An OTP has been sent to your email.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }
}
