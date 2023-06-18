import 'package:flutter/material.dart';
import 'package:smart_station/screens/phone_screen/phone_screen.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({Key? key}) : super(key: key);

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {

  void loadURL(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $uri');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(splashBg), fit: BoxFit.fill),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height / 3,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(topBg),
                fit: BoxFit.cover,
              )
              // color: Colors.grey[200],
            ),
          ),
          Positioned(
            top: 100,
            left: MediaQuery.of(context).size.width / 3,
            // right: MediaQuery.of(context).size.width * 0.5,
            child: Text(
              'Welcome to\nSmartStation',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: textGreen,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 2,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 120,
                child: Image(
                  image: AssetImage(mainLogo),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
           // left: MediaQuery.of(context).size.width / 6,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Read our'),
                      InkWell(
                        onTap: () => loadURL('https://creativeapplab.in/privacy.html'),
                        child: Text(
                          '\tPrivacy policy.',
                          style: TextStyle(color: textGreen),
                        ),
                      ),
                      const Text('Tap "Get Started"'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('to accept the'),
                      InkWell(
                        onTap: () => loadURL('https://creativeapplab.in/terms.html'),
                        child: Text(
                          'Terms of Service',
                          style: TextStyle(color: textGreen),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const PhoneScreen()),
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                leftGreen,
                                rightGreen ,
                              ]),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Center(
                          child: Text(
                            'Get Started',
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
          ),
        ],
      ),
    );
  }
}
