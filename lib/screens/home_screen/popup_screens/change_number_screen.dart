import 'dart:convert';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/bottomSection.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/topSection.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/providers/AccountProvider/account_provider.dart';

class ChangeNumberScreen extends StatefulWidget {
  const ChangeNumberScreen({Key? key}) : super(key: key);

  @override
  State<ChangeNumberScreen> createState() => _ChangeNumberScreenState();
}

class _ChangeNumberScreenState extends State<ChangeNumberScreen> {
  final phoneController = TextEditingController();
  final countryPicker = const FlCountryCodePicker();

  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _textControllers;
  CountryCode? countryCode;
  FocusNode myFocus = FocusNode();
  var oldPhoneOtpStatus = false;
  var newPhoneStatus = false;
  var phoneOtp = '';

  @override
  void initState() {
    super.initState();
    //otpPrv = Provider.of<OtpVerifyProvider>(widget.ctxt, listen: false);
    var account = Provider.of<AccountProvider>(context, listen: false);
    account.resetOldOtp();

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
      // _selectedIndex = index;
    });
  }

  String getOtpValue() {
    return _textControllers.map((controller) => controller.text).join();
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: false);

    return Consumer<AccountProvider>(builder: (context, account, child) {
      //  oldPhoneOtpStatus = account.phoneOtpStatus;
      newPhoneStatus = account.newPhoneStatus;
      phoneOtp = account.phoneOtp; // Replace with your OTP string
      List<String> otpList = [
        '',
        '',
        '',
        '',
        '',
        ''
      ]; // Initialize an array of 6 empty strings

      for (int i = 0; i < phoneOtp.length; i++) {
        otpList[i] = phoneOtp[
            i]; // Set the text of each TextField to the corresponding character in the OTP string
      }

      // Update the text controllers of the TextFields with the otpList
      for (int i = 0; i < _textControllers.length; i++) {
        _textControllers[i].text = otpList[i];
      }

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
              top: 40,
              child: Row(
                children: const [
                  BackButton(color: Colors.white),
                  Text(
                    'Change Phone Number',
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
              left: MediaQuery.of(context).size.width / 10,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Country Code',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          (!newPhoneStatus)
                              ? 'Old Mobile Number'
                              : 'New Mobile Number',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        // Spacer(),
                        // Text('Verify',style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.end),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
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
                            child: TextField(
                              // textAlign: TextAlign.end,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              controller: phoneController,
                              focusNode: myFocus,
                              onChanged: (value) {
                                if (value.length == 10) {
                                  FocusManager.instance.primaryFocus?.unfocus();
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
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                            onTap: () {
                              myFocus.unfocus();
                              // Action to perform when the icon is pressed
                              if (phoneController.text == '') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    width:
                                        MediaQuery.of(context).size.width - 50,
                                    content: const Center(
                                        child: Text(
                                      'Enter a valid Phone number/ Country code missing',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white),
                                    )),
                                    duration: const Duration(seconds: 3),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor:
                                        const Color.fromRGBO(0, 0, 0, 0.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                );
                              } else {
                                if (!newPhoneStatus) {
                                  account
                                      .sendOldPhoneOtp(
                                          phone: phoneController.text,
                                          country: countryCode != null
                                              ? countryCode!.dialCode
                                                  .substring(1)
                                              : '+91',
                                          context: context)
                                      .then((value) {
                                    var data = jsonDecode(value.body);
                                    oldPhoneOtpStatus = data['status'];
                                  });
                                } else {
                                  account
                                      .sendNewPhoneOtp(
                                          phone: phoneController.text,
                                          country: countryCode != null
                                              ? countryCode!.dialCode
                                                  .substring(1)
                                              : '+91',
                                          context: context)
                                      .then((value) {
                                    var data = jsonDecode(value.body);
                                    oldPhoneOtpStatus = data['status'];
                                  });
                                }
                              }
                            },
                            child: const Text(
                              'Verify',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ))
                      ],
                    ),
                    const SizedBox(height: 100),
                    oldPhoneOtpStatus
                        ? Column(
                            children: [
                              const Text('OTP',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  6,
                                  (index) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: SizedBox(
                                      width: 40,
                                      height: 50,
                                      child: TextField(
                                        controller: _textControllers[index],
                                        focusNode: _focusNodes[index],
                                        maxLength: 1,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: InputDecoration(
                                          counterText: '',
                                          border: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Colors.grey,
                                              width: 2,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                              const SizedBox(
                                height: 80,
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    oldPhoneOtpStatus = false;
                                  });
                                  if (phoneController.text == '') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                50,
                                        content: const Center(
                                            child: Text(
                                          'Enter a valid Phone number/ Country code missing',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white),
                                        )),
                                        duration: const Duration(seconds: 3),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor:
                                            const Color.fromRGBO(0, 0, 0, 0.5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                    );
                                  } else {
                                    if (newPhoneStatus == false) {
                                      setState(() {
                                        phoneController.clear();
                                        account.verifyOldPhoneOtp(
                                            otp: getOtpValue(),
                                            context: context);
                                      });
                                    } else {
                                      account
                                          .checkNewPhoneOtpVerify(
                                              newPhone: phoneController.text,
                                              country: countryCode != null
                                                  ? countryCode!.dialCode
                                                      .substring(1)
                                                  : '+91',
                                              otp: getOtpValue(),
                                              context: context)
                                          .then((value) {
                                        var data = jsonDecode(value.body);
                                        if (data['status'] == true) {
                                          Navigator.pop(context);
                                        }
                                      });
                                    }
                                  }
                                  // Navigator.push(context, MaterialPageRoute(builder: (_) => ChangeNewNumberScreen()));
                                },
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width / 3,
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
                                      child: Text(
                                        (!newPhoneStatus) ? 'Next' : 'Submit',
                                        style: const TextStyle(
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
                          )
                        : const SizedBox()
                  ],
                ),
              ),
            ),
            const Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: BottomSectionTransp(),
            )
          ],
        ),
      );
    });
  }
}
