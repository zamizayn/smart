import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../providers/AccountProvider/account_provider.dart';
import '../../../providers/AuthProvider/auth_provider.dart';
import '../../../utils/constants/app_constants.dart';
class SecurityPasscodeChange extends StatefulWidget {
  const SecurityPasscodeChange({super.key});

  @override
  State<SecurityPasscodeChange> createState() => _SecurityPasscodeChangeState();
}

class _SecurityPasscodeChangeState extends State<SecurityPasscodeChange> {
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
  var section1 = '';
  var section2 = '';
  bool _obscureStatus = true;
  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    var account = Provider.of<AccountProvider>(context, listen: false);
    return  Scaffold(
            resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
    preferredSize: const Size.fromHeight(80.0), // Set the height of the app bar
    child: Container(
      // decoration: BoxDecoration(
      //       image: DecorationImage(
      //         image: AssetImage(splashBg),
      //         fit: BoxFit.fill,
      //       ),
      // ),
      color: Colors.black38,
      child: Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: Row(
          children: const [
        BackButton(color: Colors.white),
        Text(
          'Change passcode',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        )
          ],
        ),
      ),
    ),
  ),
      body: Container(
         height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
             decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(splashBg), fit: BoxFit.fill)),
        child:changeStatus==false? Column(
          children: [
            const SizedBox(height: 170,),
             SizedBox(
                    width:50,
                    child: Image(
                      image: AssetImage(privacyIcon),
                    ),
             ),
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
                    height: 40,
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
                    height: 40,
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
                    height: 40,
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
                    height: 40,
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
                         changeStatus=true;
                        _obscureStatus=true;
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
        )
        :Column(
         // mainAxisAlignment: MainAxisAlignment.center,
         crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 170,),
             SizedBox(
                    width:50,
                    child: Image(
                      image: AssetImage(privacyIcon),
                    ),
             ),
            const SizedBox(
                height: 20,
              ),
              Text(
                      confirmStatus==false  ?
                      'Enter New Pin' : 'Confirm Pin',
                      style: const TextStyle(
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
                    height: 40,
                    width: 40,
                    child: TextFormField(
                      obscureText: _obscureStatus,
                      obscuringCharacter: '•',
                      controller: pin1,
                      style: Theme.of(context).textTheme.titleLarge,
                      onChanged: (value) {
                       if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                          if(confirmStatus==false){
                            section1 = pin1.text +
                                  pin2.text +
                                  pin3.text +
                                  pin4.text ;
                                  print('pin1------------------${section1.length}');
                                  if(section1.length==4){
                                    setState(() {
                                      confirmStatus=true;
                                      _obscureStatus=true;
                                      pin1.clear();
                                      pin2.clear();
                                      pin3.clear();
                                      pin4.clear();
                                    });
                                  }
                          }
                          else{
                            section2 = pin1.text +
                                  pin2.text +
                                  pin3.text +
                                  pin4.text ;
                                  if(section2.length==4){
                                    setState(() {
                                      submitStatus=true;
                                    });
                                  }
                          }
                        }
                        else{
                           setState(() {
                            submitStatus=false;
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
                    height: 40,
                    width: 40,
                    child: TextFormField(
                      obscureText: _obscureStatus,
                      obscuringCharacter: '•',
                      controller: pin2,
                      style: Theme.of(context).textTheme.titleLarge,
                      onChanged: (value) {
                         if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                          if(confirmStatus==false){
                            section1 = pin1.text +
                                  pin2.text +
                                  pin3.text +
                                  pin4.text ;
                                  print('pin1------------------${section1.length}');
                                  if(section1.length==4){
                                    setState(() {
                                      confirmStatus=true;
                                      _obscureStatus=true;
                                        pin1.clear();
                                      pin2.clear();
                                      pin3.clear();
                                      pin4.clear();
                                    });
                                  }
                          }
                          else{
                            section2 = pin1.text +
                                  pin2.text +
                                  pin3.text +
                                  pin4.text ;
                                  if(section2.length==4){
                                    setState(() {
                                      submitStatus=true;
                                    });
                                  }
                          }
                        }
                        else{
                           setState(() {
                            submitStatus=false;
                          });
                          FocusScope.of(context).previousFocus();
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
                    height: 40,
                    width: 40,
                    child: TextFormField(
                      obscureText: _obscureStatus,
                      obscuringCharacter: '•',
                      controller: pin3,
                      style: Theme.of(context).textTheme.titleLarge,
                      onChanged: (value) {
                          if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                          if(confirmStatus==false){
                            section1 = pin1.text +
                                  pin2.text +
                                  pin3.text +
                                  pin4.text ;
                                  print('pin1------------------${section1.length}');
                                  if(section1.length==4){
                                    setState(() {
                                      confirmStatus=true;
                                      _obscureStatus=true;
                                        pin1.clear();
                                      pin2.clear();
                                      pin3.clear();
                                      pin4.clear();
                                    });
                                  }
                          }
                          else{
                            section2 = pin1.text +
                                  pin2.text +
                                  pin3.text +
                                  pin4.text ;
                                  if(section2.length==4){
                                    setState(() {
                                      submitStatus=true;
                                    });
                                  }
                          }
                        }
                        else{
                           setState(() {
                            submitStatus=false;
                          });
                          FocusScope.of(context).previousFocus();
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
                    height: 40,
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
                          if(confirmStatus==false){
                            section1 = pin1.text +
                                  pin2.text +
                                  pin3.text +
                                  pin4.text ;
                                  if(section1.length==4){
                                    setState(() {
                                      confirmStatus=true; 
                                      _obscureStatus=true;
                                       pin1.clear();
                                      pin2.clear();
                                      pin3.clear();
                                      pin4.clear();
                                    });
                                  }
                              
                               print('new pin----------$section1');
                               
                          }
                          else{
                             section2 = pin1.text +
                                  pin2.text +
                                  pin3.text +
                                  pin4.text ;
                                  if(section2.length==4){
                                    setState(() {
                                      submitStatus=true;
                                    });
                                  }
                                  print('confirm pin--------$section2');
                          }
                        }
                        else{
                          FocusScope.of(context).previousFocus();
                          setState(() {
                            submitStatus=false;
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
              ),
              const SizedBox(height: 20,),
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
              
              section1==section2 && submitStatus==true?
               InkWell(
                onTap: () {
                  account.updateSecurityPin(auth.accessToken, auth.userId, section1, context);
                
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
                      section1!=section2 && submitStatus==true?     
                           const Text('Incorrect Pin',style: TextStyle(fontSize:16 ),):const SizedBox()
          ],
        )
      ),
    );
  }
}