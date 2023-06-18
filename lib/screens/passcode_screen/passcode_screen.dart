import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/utils/constants/app_constants.dart';

import '../../providers/AccountProvider/account_provider.dart';
import '../../providers/AuthProvider/auth_provider.dart';
import '../home_screen/home_screen.dart';

class PasscodeScreen extends StatefulWidget {
  const PasscodeScreen({Key? key}) : super(key: key);

  @override
  State<PasscodeScreen> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen> {
  @override
  var pin1 = TextEditingController();
  var pin2 = TextEditingController();
  var pin3 = TextEditingController();
  var pin4 = TextEditingController();
  FocusNode pin4Focus = FocusNode();
  var confirmStatus = false;
  bool changeStatus=false;
   bool submitStatus=false;
    bool checkStatus=false;
    String oldPin = '';
  // var section1 = "";
  // var section2 = "";
  bool _obscureStatus = true;
  @override
  Widget build(BuildContext context) {
      var auth = Provider.of<AuthProvider>(context, listen: false);
    var account = Provider.of<AccountProvider>(context, listen: false);
    return Scaffold(
        resizeToAvoidBottomInset: false,
      
          body: Container(
             height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
             decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(splashBg), fit: BoxFit.fill)),
            child:  Column(
          children: [
            const SizedBox(height: 170,),
            //  SizedBox(
            //         width:50,
            //         child: Image(
            //           image: AssetImage(privacyIcon),
            //         ),
            //  ),
             const SizedBox(height: 20,),
             const Text(
                      'Enter your pin to continue',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20,),
                    Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 45,
                    width: 40,
                    child: TextFormField(
                      obscureText: _obscureStatus,
                      obscuringCharacter: '•',
                      controller: pin1,
                      style: Theme.of(context).textTheme.titleLarge,
                      onChanged: (value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                          if(checkStatus==false){
                            oldPin = pin1.text +
                                  pin2.text +
                                  pin3.text +
                                  pin4.text ;
                                  print('pin1------------------${oldPin.length}');
                                  if(oldPin.length==4){
                                    setState(() {
                                      checkStatus=true;
                                    });
                                  }
                          }
                        }
                        else{
                           setState(() {
                            checkStatus=false;
                          });
                        //  FocusScope.of(context).previousFocus();
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: '*',
                        contentPadding: EdgeInsets.symmetric( vertical: 10,horizontal: 13),
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
                      obscureText: _obscureStatus,
                      obscuringCharacter: '•',
                      controller: pin2,
                      style: Theme.of(context).textTheme.titleLarge,
                      onChanged: (value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                          if(checkStatus==false){
                            oldPin = pin1.text +
                                  pin2.text +
                                  pin3.text +
                                  pin4.text ;
                                  print('pin2------------------${oldPin.length}');
                                  if(oldPin.length==4){
                                    setState(() {
                                      checkStatus=true;
                                    });
                                  }
                          }
                        }
                        else{
                          FocusScope.of(context).previousFocus();
                           setState(() {
                            checkStatus=false;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: '*',
                        contentPadding: EdgeInsets.symmetric( vertical: 10,horizontal: 13),
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
                      obscureText: _obscureStatus,
                      obscuringCharacter: '•',
                      controller: pin3,
                      style: Theme.of(context).textTheme.titleLarge,
                      onChanged: (value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                          if(checkStatus==false){
                            oldPin = pin1.text +
                                  pin2.text +
                                  pin3.text +
                                  pin4.text ;
                                  print('pin3------------------${oldPin.length}');
                                  if(oldPin.length==4){
                                    setState(() {
                                      checkStatus=true;
                                    });
                                    
                                  }
                          }
                        }
                        else{
                          FocusScope.of(context).previousFocus();
                           setState(() {
                            checkStatus=false;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: '*',
                        contentPadding: EdgeInsets.symmetric( vertical: 10,horizontal: 13),
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
                      obscureText: _obscureStatus,
                      obscuringCharacter: '•',
                      controller: pin4,
                      focusNode: pin4Focus,
                      style: Theme.of(context).textTheme.titleLarge,
                      onChanged: (value) {
                        if (value.length == 1) {
                          pin4Focus.unfocus();
                          //FocusScope.of(context).nextFocus();
                          if(checkStatus==false){
                            oldPin= pin1.text +
                                  pin2.text +
                                  pin3.text +
                                  pin4.text ;
                                  print('pin4------------------${oldPin.length}');
                                  if(oldPin.length==4){
                                    setState(() {
                                      checkStatus=true;
                                      
                                    });
                                    
                                  }
                          }
                         
                        }
                        else{
                          FocusScope.of(context).previousFocus();
                          setState(() {
                            checkStatus=false;
                          });
                          
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: '*',
                        contentPadding: EdgeInsets.symmetric( vertical: 10,horizontal: 13),
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
              ),const SizedBox(height: 20,),
               InkWell(
                onTap: () {
                  setState(() {
                    _obscureStatus = !_obscureStatus;
                  });
                },
                 child: Text(
                        _obscureStatus==true  ?
                        'Show pin' : 'Hide pin',
                        style: const TextStyle(
                         // fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                        textAlign: TextAlign.center,
                      ),
               ),
              const SizedBox(height: 50,),
              checkStatus==true?
               InkWell(
                onTap: () {
                    pin1.clear();
                    pin2.clear();
                    pin3.clear();
                    pin4.clear();
                    
                    print('oldpin--------------------$oldPin');
                  account.checkSecurityPin(auth.accessToken, auth.userId, oldPin, context).then((value) {
                    var data = jsonDecode(value.body);
                    print('value-------------${jsonDecode(value.body)}');
                    if(data['status']==true){
                      setState(() {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context) => const HomeScreen()));
                        // changeStatus=true;
                        // _obscureStatus=true;
                      });
                    }
                    else{
                      setState(() {
                        checkStatus=false;
                      });
                    }
                  });
                
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
                                   child: Text('Submit',
                                     style: TextStyle(
                                       color: Colors.white,
                                       fontWeight: FontWeight.bold,
                                       fontSize: 22,
                                     ),
                                   ),
                                 ),
                               ),
                             ),
               ):const SizedBox(),
          ],
        ),
      ),
    );
  }
}
