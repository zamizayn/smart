import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/bottomSection.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/topSection.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/lost_phone_provider.dart';

class ChangeNewNumberScreen extends StatefulWidget {
  String email;
  String deviceToken;

  ChangeNewNumberScreen({
    Key? key,
    required this.email,
    required this.deviceToken,
  }) : super(key: key);
  //const ChangeNewNumberScreen({Key? key}) : super(key: key);

  @override
  State<ChangeNewNumberScreen> createState() => _ChangeNewNumberScreenState();
}

class _ChangeNewNumberScreenState extends State<ChangeNewNumberScreen> {
  final phoneController = TextEditingController();
  final countryPicker = const FlCountryCodePicker();
  CountryCode? countryCode;

  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _textControllers;
  FocusNode myFocus = FocusNode();
  var oldPhoneOtpStatus = false;
  var phoneOtp = '';

  @override
  void initState() {
    super.initState();
    // var lost = Provider.of<LostPhoneProvider>(context, listen: false);
    // setState(() {
    //   lost.resetOldOtp();
    // });

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
    return Consumer<LostPhoneProvider>(builder: (context, lost, child) {
      // oldPhoneOtpStatus = lost.phoneOtpStatus;

      phoneOtp = lost.phoneOtp; // Replace with your OTP string
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
              top: 50,
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
                      children: const [
                        Text(
                          'Country Code',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        Text(
                          ' New Mobile Number',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        Text('Verify',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.end),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 100,
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
                                            width: 20,
                                            height: 20,
                                            child: Image.asset(IndianFlag),
                                          ),
                                  ),
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
                            height: 50,
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
                        const SizedBox(
                          width: 20,
                        ),
                        InkWell(
                          onTap: () {
                            if (phoneController.text.length == 10) {
                              oldPhoneOtpStatus = true;
                              lost.sendNewPhoneOtp(
                                  phone: phoneController.text,
                                  country: countryCode != null
                                      ? countryCode!.dialCode.substring(1)
                                      : '+91',
                                  email: widget.email,
                                  deviceToken: widget.deviceToken,
                                  context: context);
                            } else {
                              oldPhoneOtpStatus = false;
                            }
                            // Action to perform when the icon is pressed
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 30,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 100),
                    if (oldPhoneOtpStatus)
                      Column(
                        children: [
                          const Text('OTP',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              6,
                              (index) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 9.2,
                                  height: 45,
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
                          const SizedBox(
                            height: 80,
                          ),
                          InkWell(
                            onTap: () {
                              print(widget.deviceToken +
                                  '+91' +
                                  widget.email +
                                  phoneController.text);

                              lost.checkOTP(
                                  otp: getOtpValue(),
                                  device_token: widget.deviceToken,
                                  ctx: context,
                                  country: countryCode != null
                                      ? countryCode!.dialCode.substring(1)
                                      : '+91',
                                  email: widget.email,
                                  new_phone: phoneController.text);
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
