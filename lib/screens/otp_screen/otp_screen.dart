import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/providers/AuthProvider/otp_verify_provider.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:smart_station/utils/constants/urls.dart';


class OTPScreen extends StatefulWidget {
  BuildContext ctxt;
  OTPScreen({Key? key, required this.ctxt}) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  var pin1 = TextEditingController();
  var pin2 = TextEditingController();
  var pin3 = TextEditingController();
  var pin4 = TextEditingController();
  var pin5 = TextEditingController();
  var pin6 = TextEditingController();
  var finalOtp;
  var devToken;
  var auth;
  var otpPrv;
  String? deviceid;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getUniqueUserId().then((value) {
    //   print("zeeegooooId");
    //   deviceid = value;
    // });
    auth = Provider.of<AuthProvider>(widget.ctxt, listen: true);
    otpPrv = Provider.of<OtpVerifyProvider>(widget.ctxt, listen: false);

    var data = jsonDecode(auth.resMessage);
    pin1.text = data['otp'].toString()[0];
    pin2.text = data['otp'].toString()[1];
    pin3.text = data['otp'].toString()[2];
    pin4.text = data['otp'].toString()[3];
    pin5.text = data['otp'].toString()[4];
    pin6.text = data['otp'].toString()[5];

    finalOtp =
        pin1.text + pin2.text + pin3.text + pin4.text + pin5.text + pin6.text;
    devToken = auth.deviceToken;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage(splashBg),
              fit: BoxFit.fill,
            )),
          ),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Text(
              'Verify your number',
              style: TextStyle(
                color: textGreen,
                fontWeight: FontWeight.w600,
                fontSize: 25.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            top: 180,
            right: 0,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: const Text(
                'Waiting to automatically detect an OTP sent to',
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ),
          Positioned(
            top: 220,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  auth.cCode + ' ' + auth.phone + '.',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    ' Wrong number?',
                    style: TextStyle(
                      color: textGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ],
            ),
          ),
          Positioned(
            top: 280,
            left: MediaQuery.of(context).size.width / 7,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 45,
                  width: 40,
                  child: TextFormField(
                    controller: pin1,
                    style: Theme.of(context).textTheme.titleLarge,
                    onChanged: (value) {
                      if (value.length == 1) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 11, horizontal: 14),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    // textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 45,
                  width: 40,
                  child: TextFormField(
                    controller: pin2,
                    style: Theme.of(context).textTheme.titleLarge,
                    onChanged: (value) {
                      if (value.length == 1) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 11, horizontal: 14),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 45,
                  width: 40,
                  child: TextFormField(
                    controller: pin3,
                    style: Theme.of(context).textTheme.titleLarge,
                    onChanged: (value) {
                      if (value.length == 1) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 11, horizontal: 14),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 45,
                  width: 40,
                  child: TextFormField(
                    controller: pin4,
                    style: Theme.of(context).textTheme.titleLarge,
                    onChanged: (value) {
                      if (value.length == 1) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 11, horizontal: 14),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 45,
                  width: 40,
                  child: TextFormField(
                    controller: pin5,
                    style: Theme.of(context).textTheme.titleLarge,
                    onChanged: (value) {
                      if (value.length == 1) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 11, horizontal: 14),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 45,
                  width: 40,
                  child: TextFormField(
                    controller: pin6,
                    style: Theme.of(context).textTheme.titleLarge,
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 11, horizontal: 14),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 350,
            left: 0,
            right: 0,
            child: Text(
              'Enter 6-digit OTP',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            top: 400,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "If you didn't receive code?",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    return InkWell(
                      onTap: () async {
                        print('resend');
                        var body = {
                          "phone" : auth.phone,
                          "country" : auth.cCode
                        };
                        
                        var resp = await http.post(Uri.parse(AppUrls.appBaseUrl + 'resendotp'), body: body);
                        print(resp.body);
                        if (resp.statusCode == 200 || resp.statusCode == 201) {
                          var data = jsonDecode(resp.body);
                          setState(() {
                            pin1.text = data['otp'].toString()[0];
                            pin2.text = data['otp'].toString()[1];
                            pin3.text = data['otp'].toString()[2];
                            pin4.text = data['otp'].toString()[3];
                            pin5.text = data['otp'].toString()[4];
                            pin6.text = data['otp'].toString()[5];

                            finalOtp =
                                pin1.text + pin2.text + pin3.text + pin4.text + pin5.text + pin6.text;
                            devToken = auth.deviceToken;
                          });
                        }
                        // auth.loginUser(
                        //     islogin: false,
                        //     phone: auth.phone,
                        //     device_type: '',
                        //     country: auth.cCode,
                        //     device_token: auth.deviceToken);
                      },
                      child: Text(
                        ' Resend',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textGreen,
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
          Positioned(
            top: 450,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Container(
                height: 8,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(8),
                color: textGreen,
              ),
            ),
          ),
          Positioned(
            bottom: 160,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              width: 80,
              padding: const EdgeInsets.all(10),
              child: Image(
                image: AssetImage(transpLogo),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: InkWell(
              onTap: () {
                otpPrv.checkOTP(
                    otp: finalOtp, device_token: devToken, ctx: context);
                otpPrv.isLoading
                    ? showDialog(
                        context: context,
                        builder: (context) {
                          return Container(
                            child: SpinKitSpinningLines(
                              color: rightGreen,
                              size: 100,
                            ),
                          );
                        },
                      )
                    : null;
              },
              child: SizedBox(
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100),
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
                        'Verify',
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
          ),
        ],
      ),
    );
  }
}
