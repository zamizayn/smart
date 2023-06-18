import 'package:flutter/material.dart';
import 'package:smart_station/providers/AccountProvider/account_provider.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';

class SecuritySwitchScreen extends StatefulWidget {
  const SecuritySwitchScreen({Key? key}) : super(key: key);

  @override
  State<SecuritySwitchScreen> createState() => _SecuritySwitchScreenState();
}

class _SecuritySwitchScreenState extends State<SecuritySwitchScreen> {
  var pin1 = TextEditingController();
  var pin2 = TextEditingController();
  var pin3 = TextEditingController();
  var pin4 = TextEditingController();
  FocusNode pin4Focus = FocusNode();
  FocusNode pin3Focus = FocusNode();
  FocusNode pin2Focus = FocusNode();
  FocusNode pin1Focus = FocusNode();
  var confirmStatus = false;
  bool submitStatus=false;
  var section1 = '';
  var section2 = '';
  bool _obscureStatus = true;

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    var account = Provider.of<AccountProvider>(context, listen: false);
   // heading = auth.securityStatus=="1" ? "Deactivate Pin" : "New Pin";
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
          'Security',
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
      body:Container(
         height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
             decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(splashBg), fit: BoxFit.fill)),
        child: auth.securityStatus=='1' ?
        Column(
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
                      'Deactivate Pin',
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
                          if(confirmStatus==false){
                            section1 = pin1.text +
                                  pin2.text +
                                  pin3.text +
                                  pin4.text ;
                                  print('pin1------------------${section1.length}');
                                  if(section1.length==4){
                                    setState(() {
                                      confirmStatus=true;
                                    });
                                  }
                          }
                        }
                        else{
                           setState(() {
                            confirmStatus=false;
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
                                  print('pin2------------------${section1.length}');
                                  if(section1.length==4){
                                    setState(() {
                                      confirmStatus=true;
                                    });
                                  }
                          }
                        }
                        else{
                          FocusScope.of(context).previousFocus();
                           setState(() {
                            confirmStatus=false;
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
                          if(confirmStatus==false){
                            section1 = pin1.text +
                                  pin2.text +
                                  pin3.text +
                                  pin4.text ;
                                  print('pin3------------------${section1.length}');
                                  if(section1.length==4){
                                    setState(() {
                                      confirmStatus=true;
                                    });
                                    
                                  }
                          }
                        }
                        else{
                          FocusScope.of(context).previousFocus();
                           setState(() {
                            confirmStatus=false;
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
                          if(confirmStatus==false){
                            section1 = pin1.text +
                                  pin2.text +
                                  pin3.text +
                                  pin4.text ;
                                  print('pin4------------------${section1.length}');
                                  if(section1.length==4){
                                    setState(() {
                                      confirmStatus=true;
                                    });
                                    
                                  }
                          }
                         
                        }
                        else{
                          FocusScope.of(context).previousFocus();
                          setState(() {
                            confirmStatus=false;
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
              confirmStatus==true?
               InkWell(
                onTap: () {
                  account.deactivateSecurityPin(auth.accessToken, auth.userId, section1, context);
                
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
                      'New Pin' : 'Confirm Pin',
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
                      focusNode: pin1Focus,
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
                                      pin1Focus.unfocus();
                                      if(section1!=section2){
                                         ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        width: MediaQuery.of(context).size.width-50,
                                        content: const Center(child: Text('Incorrect Pin',style: TextStyle(color: Colors.white),)),
                                        duration: const Duration(seconds: 3),
                                        behavior: SnackBarBehavior.floating,
                                      backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
                                      shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                    );
                                      }
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
                      focusNode: pin2Focus,
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
                                      pin2Focus.unfocus();
                                      if(section1!=section2){
                                         ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        width: MediaQuery.of(context).size.width-50,
                                        content: const Center(child: Text('Incorrect Pin',style: TextStyle(color: Colors.white),)),
                                        duration: const Duration(seconds: 3),
                                        behavior: SnackBarBehavior.floating,
                                      backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
                                      shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                    );
                                      }
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
                      focusNode: pin3Focus,
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
                                      pin3Focus.unfocus();
                                      if(section1!=section2){
                                         ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        width: MediaQuery.of(context).size.width-50,
                                        content: const Center(child: Text('Incorrect Pin',style: TextStyle(color: Colors.white),)),
                                        duration: const Duration(seconds: 3),
                                        behavior: SnackBarBehavior.floating,
                                      backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
                                      shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                    );
                                      }
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
                                      pin4Focus.unfocus();
                                      if(section1!=section2){
                                         ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        width: MediaQuery.of(context).size.width-50,
                                        content: const Center(child: Text('Incorrect Pin',style: TextStyle(color: Colors.white),)),
                                        duration: const Duration(seconds: 3),
                                        behavior: SnackBarBehavior.floating,
                                      backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
                                      shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                    );
                                      }
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
               ): const SizedBox(),
                      // section1!=section2 && submitStatus==true?     
                      //      Text("Incorrect Pin",style: TextStyle(fontSize:18,fontWeight: FontWeight.bold ),):SizedBox()
          ],
        )
        
      ) 
      // Stack(
      //   clipBehavior: Clip.none,
      //   children: [
      //     TopSection(),
      //     Container(
      //       decoration: BoxDecoration(
      //           image: DecorationImage(
      //               image: AssetImage(splashBg), fit: BoxFit.fill)),
      //     ),
      //     Positioned(
      //       top: 40,
      //       child: Row(
      //         children: [
      //           BackButton(color: Colors.white),
      //           Text(
      //             "Security",
      //             style: TextStyle(
      //               fontSize: 18,
      //               fontWeight: FontWeight.w400,
      //               color: Colors.white,
      //             ),
      //           )
      //         ],
      //       ),
      //     ),
      //     Positioned(
      //       top: 170,
      //       child: Padding(
      //         padding: EdgeInsets.symmetric(horizontal: 25),
      //         child: Container(
      //           width: MediaQuery.of(context).size.width / 1.2,
      //           height: MediaQuery.of(context).size.height / 3,
      //           // color: Colors.red,

      //           child: Column(
      //             children: [
      //           Container(
      //           child: Column(
      //           children: [
      //             SizedBox(
      //             width:50,
      //             child: Image(
      //               image: AssetImage(notificationIcon),
      //             ),
      //           ),

      //           ],
      //         ),
      //       ),
      //           SizedBox(
      //             height: 20,
      //           ),
      //               Positioned(
      //                 left: 10,
      //                 right: 10,
      //                 child: Text(
      //                   auth.securityStatus=="1" ?
      //                   "Deactivate Pin" :
      //                   confirmStatus==false  ?
      //                   "New Pin" : "Confirm Pin",
      //                   style: TextStyle(
      //                     fontSize: 20,
      //                     fontWeight: FontWeight.bold,
      //                     color: Colors.teal,
      //                   ),
      //                   textAlign: TextAlign.center,
      //                 ),
      //               ),
      //               SizedBox(
      //                 height: 20,
      //               ),

      //             ],
      //           ),
      //         ),
      //       ),
      //     ),
      //     Positioned(
      //         top: 280,

      //         left: MediaQuery.of(context).size.width / 4,
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: [
      //             SizedBox(
      //               height: 40,
      //               width: 40,

      //               child:
      //               TextFormField(
      //                 controller: pin1,
      //                 style: Theme.of(context).textTheme.headline6,
      //                 onChanged: (value) {
      //                   if (value.length == 1) {
      //                     setState(() {
      //                       if(auth.securityStatus=="1"){
      //                         section1 = pin1.text +
      //                             pin2.text +
      //                             pin3.text +
      //                             pin4.text ;
      //                         if (section1.length == 4){
      //                           print("deactivate api");
      //                         }
      //                         else {
      //                           FocusScope.of(context).nextFocus();
      //                         }
      //                       }

      //                      else if(section1.length != 4) {
      //                         section1 = pin1.text +
      //                             pin2.text +
      //                             pin3.text +
      //                             pin4.text ;
      //                         if (section1.length != 4){
      //                           FocusScope.of(context).nextFocus();
      //                         }
      //                         else if (section1.length == 4 && section2.isEmpty && confirmStatus == false) {
      //                                   confirmStatus = true;
      //                                   pin1.text = "";
      //                                   pin2.text = "";
      //                                   pin3.text = "";
      //                                   pin4.text = "";
      //                                 }
      //                        else if (section2.length != 4) {
      //                          print("section2");
      //                               section2 = pin1.text +
      //                                   pin2.text +
      //                                   pin3.text +
      //                                   pin4.text ;
      //                                 if (section2.length == 4)
      //                                 {
      //                                   print("new pin api");
      //                                 }
      //                                 else {
      //                                 FocusScope.of(context).nextFocus();
      //                                }
      //                             }
      //                         else {
      //                           FocusScope.of(context).nextFocus();
      //                         }
      //                       }
      //                     });
      //                   }
      //                 },
      //                 textAlign: TextAlign.center,
      //                 decoration: InputDecoration(
      //                   hintText: '*',
      //                   contentPadding: EdgeInsets.all(5),
      //                   enabledBorder: OutlineInputBorder(
      //                     borderSide: BorderSide(
      //                       color: Colors.grey,
      //                     ),
      //                   ),
      //                   border: OutlineInputBorder(
      //                     borderSide: BorderSide(
      //                       color: Colors.grey,
      //                     ),
      //                   ),
      //                   focusedBorder: OutlineInputBorder(
      //                     borderSide: BorderSide(
      //                       color: Colors.grey,
      //                     ),
      //                   ),
      //                 ),
      //                 keyboardType: TextInputType.number,
      //                 // textAlign: TextAlign.center,
      //                 textAlignVertical: TextAlignVertical.center,
      //                 inputFormatters: [
      //                   LengthLimitingTextInputFormatter(1),
      //                   FilteringTextInputFormatter.digitsOnly,
      //                 ],
      //               ),
      //             ),
      //             SizedBox(width: 10),
      //             SizedBox(
      //               height: 40,
      //               width: 40,
      //               child: TextFormField(
      //                 controller: pin2,
      //                 style: Theme.of(context).textTheme.headline6,
      //                 onChanged: (value) {
      //                   if (value.length == 1) {
      //                     FocusScope.of(context).nextFocus();
      //                     //
      //                   }
      //                   else{
      //                     FocusScope.of(context).previousFocus();
      //                   }
      //                 },
      //                 decoration: InputDecoration(
      //                   hintText: '*',
      //                   contentPadding: EdgeInsets.symmetric( vertical: 10,horizontal: 13),
      //                   enabledBorder: OutlineInputBorder(
      //                     borderSide: BorderSide(
      //                       color: Colors.grey,
      //                     ),
      //                   ),
      //                   border: OutlineInputBorder(
      //                     borderSide: BorderSide(
      //                       color: Colors.grey,
      //                     ),
      //                   ),
      //                   focusedBorder: OutlineInputBorder(
      //                     borderSide: BorderSide(
      //                       color: Colors.grey,
      //                     ),
      //                   ),
      //                 ),
      //                 keyboardType: TextInputType.number,
      //                 textAlign: TextAlign.center,
      //                 inputFormatters: [
      //                   LengthLimitingTextInputFormatter(1),
      //                   FilteringTextInputFormatter.digitsOnly,
      //                 ],
      //               ),
      //             ),
      //             SizedBox(width: 10),
      //             SizedBox(
      //               height: 40,
      //               width: 40,
      //               child: TextFormField(
      //                 controller: pin3,
      //                 style: Theme.of(context).textTheme.headline6,
      //                 onChanged: (value) {
      //                   if (value.length == 1) {
      //                     FocusScope.of(context).nextFocus();
      //                   }
      //                   else{
      //                     FocusScope.of(context).previousFocus();
      //                   }
      //                 },
      //                 decoration: InputDecoration(
      //                   hintText: '*',
      //                   contentPadding: EdgeInsets.symmetric( vertical: 10,horizontal: 13),
      //                   enabledBorder: OutlineInputBorder(
      //                     borderSide: BorderSide(
      //                       color: Colors.grey,
      //                     ),
      //                   ),
      //                   border: OutlineInputBorder(
      //                     borderSide: BorderSide(
      //                       color: Colors.grey,
      //                     ),
      //                   ),
      //                   focusedBorder: OutlineInputBorder(
      //                     borderSide: BorderSide(
      //                       color: Colors.grey,
      //                     ),
      //                   ),
      //                 ),
      //                 keyboardType: TextInputType.number,
      //                 textAlign: TextAlign.center,
      //                 inputFormatters: [
      //                   LengthLimitingTextInputFormatter(1),
      //                   FilteringTextInputFormatter.digitsOnly,
      //                 ],
      //               ),
      //             ),
      //             SizedBox(width: 10),
      //             SizedBox(
      //               height: 40,
      //               width: 40,
      //               child: TextFormField(
      //                 controller: pin4,
      //                 style: Theme.of(context).textTheme.headline6,
      //                 onChanged: (value) {
      //                   if (value.length == 1) {
      //                     setState(() {
      //                       if(auth.securityStatus=="1"){
      //                         section1 = pin1.text +
      //                             pin2.text +
      //                             pin3.text +
      //                             pin4.text ;
      //                         if (section1.length == 4){
      //                           print("deactivate api");
      //                         }
      //                         else {
      //                           FocusScope.of(context).nextFocus();
      //                         }
      //                       }

      //                       else if(section1.length != 4) {
      //                         section1 = pin1.text +
      //                             pin2.text +
      //                             pin3.text +
      //                             pin4.text ;
      //                         if (section1.length != 4){
      //                           FocusScope.of(context).nextFocus();
      //                         }
      //                         else if (section1.length == 4 && section2.isEmpty && confirmStatus == false) {
      //                           confirmStatus = true;
      //                           pin1.text = "";
      //                           pin2.text = "";
      //                           pin3.text = "";
      //                           pin4.text = "";
      //                         }
      //                         else if (section2.length != 4) {
      //                           print("section2");
      //                           section2 = pin1.text +
      //                               pin2.text +
      //                               pin3.text +
      //                               pin4.text ;
      //                           if (section2.length == 4)
      //                           {
      //                             print("new pin api");
      //                           }
      //                           else {
      //                             FocusScope.of(context).nextFocus();
      //                           }
      //                         }
      //                         else {
      //                           FocusScope.of(context).nextFocus();
      //                         }
      //                       }
      //                     });
      //                   }
      //                   else{
      //                     FocusScope.of(context).previousFocus();
      //                   }

      //                 },
      //                 decoration: InputDecoration(
      //                   hintText: '*',
      //                   contentPadding: EdgeInsets.symmetric( vertical: 10,horizontal: 13),
      //                   enabledBorder: OutlineInputBorder(
      //                     borderSide: BorderSide(
      //                       color: Colors.grey,
      //                     ),
      //                   ),
      //                   border: OutlineInputBorder(
      //                     borderSide: BorderSide(
      //                       color: Colors.grey,
      //                     ),
      //                   ),
      //                   focusedBorder: OutlineInputBorder(
      //                     borderSide: BorderSide(
      //                       color: Colors.grey,
      //                     ),
      //                   ),
      //                 ),
      //                 keyboardType: TextInputType.number,
      //                 textAlign: TextAlign.center,
      //                 inputFormatters: [
      //                   LengthLimitingTextInputFormatter(1),
      //                   FilteringTextInputFormatter.digitsOnly,
      //                 ],
      //               ),
      //             ),

      //           ],
      //         )),
      //         Positioned(
      //           bottom: 120,
      //           left: 30,
      //           right: 30,
      //           child: confirmStatus == true ?
      //             Center(
      //               child: SizedBox(
      //                             width: MediaQuery.of(context).size.width / 3,
      //                             child: Container(
      //                               padding: EdgeInsets.all(8),
      //                               decoration: BoxDecoration(
      //                                 gradient: LinearGradient(
      //                                     begin: Alignment.topLeft,
      //                                     end: Alignment.bottomRight,
      //                                     colors: [
      //                                       textGreen,
      //                                       textGreen,
      //                                       rightGreen,
      //                                     ]),
      //                                 borderRadius: BorderRadius.circular(50),
      //                               ),
      //                               child: Center(
      //                                 child: Text("Submit",
      //                                   style: TextStyle(
      //                                     color: Colors.white,
      //                                     fontWeight: FontWeight.bold,
      //                                     fontSize: 22,
      //                                   ),
      //                                 ),
      //                               ),
      //                             ),
      //                           ),
      //             ):SizedBox()
      //           ),
      //     Positioned(
      //       bottom: 50,
      //       left: 0,
      //       right: 0,
      //       child:
      //       BottomSectionTransp(),
      //     )
      //   ],
      // ),
    );
  }
}
