import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/screens/lost_phone/lost_phone.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
//import 'package:smart_station/screens/lost_phone/lost_phone.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({Key? key}) : super(key: key);

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final phoneController = TextEditingController();
  final countryPicker = const FlCountryCodePicker();
  CountryCode? countryCode;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  FocusNode myFocus = FocusNode();
  String? deviceToken;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _firebaseMessaging.getToken().then((value) {
      print('FCM TOKEN: $value');
      setState(() {
        deviceToken = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            clipBehavior: Clip.none,
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
                left: MediaQuery.of(context).size.width / 4.2,
                child: Text(
                  'Enter Your Phone Number',
                  style: TextStyle(fontSize: 20, color: textGreen),
                ),
              ),
              Positioned(
                top: 180,
                left: MediaQuery.of(context).size.width / 10,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Text('Country Code'),
                          Spacer(),
                          Text('Mobile Number', textAlign: TextAlign.end),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 135,
                            child: InkWell(
                              onTap: () async {
                                final code = await countryPicker.showPicker(
                                    fullScreen: true,
                                    initialSelectedLocale: 'IN',
                                    context: context);
                                setState(() {
                                  countryCode = code;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      child: countryCode != null
                                          ? countryCode!.flagImage
                                          : SizedBox(
                                              width: 30,
                                              height: 20,
                                              child: Image.asset(IndianFlag),
                                            ),
                                    ),
                                    const SizedBox(width: 5),
                                    const Icon(Icons.arrow_drop_down),
                                    const SizedBox(width: 5),
                                    Text(countryCode != null
                                        ? countryCode!.dialCode
                                        : '+91'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 60,
                              child: GestureDetector(
                                onTap: countryCode == null ? () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Select your Country')
                                    ),
                                  );
                                } : (){},
                                child: TextField(
                                  textAlign: TextAlign.end,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  enabled: countryCode != null ? true : false,
                                  maxLength: 10,
                                  controller: phoneController,
                                  focusNode: myFocus,
                                  onChanged: (value) {

                                    if (value.length == 10 || value.length == 11) {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    counterText: '',
                                    border: OutlineInputBorder(),
                                    hintText: 'Phone Number',
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text(''),
                          const Spacer(),
                          InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => LostPhone(
                                              deviceToken:
                                                  deviceToken.toString(),
                                            )));
                              },
                              child: const Text('Lost My Phone',
                                  textAlign: TextAlign.end,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Smart Station will verify\nyour phone number',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textGreen,
                  ),
                ),
              ),
              if (auth.isLoading)
                Scaffold(
                  body: Center(
                    child: SpinKitSpinningLines(color: rightGreen),
                  ),
                ),
              Positioned(
                bottom: 180,
                left: MediaQuery.of(context).size.width / 2.8,
                child: SizedBox(
                  width: 100,
                  child: Image(
                    image: AssetImage(transpLogo),
                  ),
                ),
              ),
              Positioned(
                bottom: 40,
                left: MediaQuery.of(context).size.width / 4,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: InkWell(
                    onTap: () {
                      if (phoneController.text.isNotEmpty) {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          builder: (BuildContext context) {
                            return SizedBox(
                              height: 200,
                              child: Scaffold(
                                body: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Expanded(
                                          child: Text(
                                              'You entered the phone number: ')),
                                      const SizedBox(height: 20),
                                      Expanded(
                                        child: Text(
                                          "${countryCode != null ? countryCode!.dialCode.substring(1) : "+91"} ${phoneController.text}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const Expanded(
                                        child: Text(
                                            'Is this Ok, or would you like to edit the number?'),
                                      ),
                                      const SizedBox(height: 50),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                myFocus.requestFocus();
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                'EDIT',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: textGreen),
                                              ),
                                            ),
                                            const Spacer(),
                                            InkWell(
                                              onTap: () {
                                                String deviceType = '';
                                                if (Platform.isAndroid) {
                                                  setState(() {
                                                    deviceType = 'ANDROID';
                                                  });
                                                } else if (Platform.isIOS) {
                                                  deviceType = 'IOS';
                                                }
                                                auth.loginUser(
                                                  phone: phoneController.text,
                                                  device_type: deviceType,
                                                  country: countryCode != null
                                                      ? countryCode!.dialCode
                                                          .substring(1)
                                                      : '+91',
                                                  device_token:
                                                      deviceToken.toString(),
                                                  islogin: true,
                                                  context: context,
                                                );
                                              },
                                              child: Text(
                                                'OK',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: textGreen),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Phone Number Is Required'),
                        ));
                        print('NOT OK');
                      }
                    },
                    child: SizedBox(
                      height: 40,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                textGreen,
                                rightGreen,
                              ]),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Center(
                          child: Text(
                            'Send',
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
      },
    );
  }
}
