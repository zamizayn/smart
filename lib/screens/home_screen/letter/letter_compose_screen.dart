import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/LetterProvider/letter_provider.dart';
//import 'package:smart_station/screens/home_screen/letter/letter_view.dart';
import 'package:smart_station/screens/home_screen/letter/preview.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/bottomSection.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_station/utils/constants/urls.dart';
import 'package:smart_station/providers/AccountProvider/account_provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dart:io';
List emailList=[];
List nameList=[];

class LetterComposeScreen extends StatefulWidget {
  const LetterComposeScreen({Key? key}) : super(key: key);

  @override
  State<LetterComposeScreen> createState() => _LetterComposeScreenState();
}

class _LetterComposeScreenState extends State<LetterComposeScreen> {
  bool _isTextFieldSelected = false;
  void _onFocusChange() {
    setState(() {
      _isTextFieldSelected = _focusNode.hasFocus;
      print('changed');
    });
  }
  bool _isCcSelected = false;
  void _onCcFocusChange() {
    setState(() {
      _isCcSelected = _ccfocusNode.hasFocus;
      print('changed');
    });
  }
  bool _isBccSelected = false;
  void _onBccFocusChange() {
    setState(() {
      _isBccSelected = _bccfocusNode.hasFocus;
      print('changed');
    });
  }
  List filteredList=emailList;
  List ccList=emailList;
  List bccList=emailList;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var account = Provider.of<AccountProvider>(context,listen: false);
    account.getSignature(context);
    account.getStamp(context);
    account.getHeader(context);
    account.getFooter(context);
    _focusNode.addListener(_onFocusChange);
    _bccfocusNode.addListener(_onBccFocusChange);
    _ccfocusNode.addListener(_onCcFocusChange);
    filteredList=emailList;
    List ccList=emailList;
    List bccList=emailList;
    
      // var letter = Provider.of<LetterProvider>(context,listen: false);
      // letter.getDefaultStamp(context);
      // print("=======================[SIGNATURE]==========================");
      // //print(letter.stampData.first['default_header']);

      // print("=======================[SIGNATURE]==========================");
      // for (var i = 0; i < letter.stampData.length; i++) {
      //   Stamp=AppUrls.appBaseUrl+letter.stampData[i]['default_signature'];
      //   Signature=AppUrls.appBaseUrl+letter.stampData[i]["default_stamp"];
      //   Header=AppUrls.appBaseUrl+letter.stampData[i]["default_header"];
      //   Footer=AppUrls.appBaseUrl+letter.stampData[i]["default_footer"];
      // }
    

  }
  var emailValidate = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _ccController = TextEditingController();
  final TextEditingController _bccController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _addressToController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  String Header='';
  String Footer='';
  String Stamp='';
  String Signature='';
   String defaultHeader='';
  String defaultFooter='';
  String defaultStamp='';
  String defaultSignature='';
  List attachments = [];
  bool showBcc = false;
  List fileData = [];
  List<ListItem> attachmentItems = [];
  final FocusNode _focusNode = FocusNode();
  final FocusNode _bccfocusNode = FocusNode();
  final FocusNode _ccfocusNode = FocusNode();
  String letterSent='';
  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _bccfocusNode.removeListener(_onBccFocusChange);
    _bccfocusNode.dispose();
    _ccfocusNode.removeListener(_onCcFocusChange);
    _ccfocusNode.dispose();
    super.dispose();
  }
  final List<String> _selectedChips = [];
  final List<String> _bccChipsList = [];
  final List<String> _ccChipsList = [];
  List<Widget> _buildChips() {
    return _selectedChips.map((chip) {
      return InputChip(
        label: Text(chip),
        onDeleted: () {
          setState(() {
            _selectedChips.remove(chip);
          });
          // if (widget.onChanged != null) {
          //   widget.onChanged(_selectedChips);
          // }
        },
      );
    }).toList();
  }
  List<Widget> _bccChips() {
    return _bccChipsList.map((chip) {
      return InputChip(
        label: Text(chip),
        onDeleted: () {
          setState(() {
            _bccChipsList.remove(chip);
          });
          // if (widget.onChanged != null) {
          //   widget.onChanged(_selectedChips);
          // }
        },
      );
    }).toList();
  }
  List<Widget> _ccChips() {
    return _ccChipsList.map((chip) {
      return InputChip(
        label: Text(chip),
        onDeleted: () {
          setState(() {
            _ccChipsList.remove(chip);
          });
          // if (widget.onChanged != null) {
          //   widget.onChanged(_selectedChips);
          // }
        },
      );
    }).toList();
  }

  @override

  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
        builder: (context, account, child)
        {
          return WillPopScope(
            onWillPop: ()  async{
              if(_selectedChips.isNotEmpty || _addressToController.text.isNotEmpty 
                      ||_bodyController.text.isNotEmpty || _ccChipsList.isNotEmpty || 
                      _bccChipsList.isNotEmpty || _subjectController.text.isNotEmpty){
                            LetterProvider().draftLetter(_selectedChips.join(','),
                                 _addressToController.text, _bodyController.text, 
                                  Header, Footer, Signature, Stamp, context, _ccChipsList.join(','), 
                                 _bccChipsList.join(','), _subjectController.text,'').then((value) {
                                  var data = jsonDecode(value.body);
                                   if(data['status']==true){
                                    print('inside snackbar');
                                      // ScaffoldMessenger.of(context).showSnackBar(
                                      //   SnackBar(
                                      //     width: MediaQuery.of(context).size.width-50,
                                      //     content: Center(child: Text("Message saved as draft",style: TextStyle(color: Colors.white),)),
                                      //     duration: Duration(seconds: 4),
                                      //     behavior: SnackBarBehavior.floating,
                                      //   backgroundColor: Color.fromRGBO(0, 0, 0, 0.5),
                                      //   shape: RoundedRectangleBorder(
                                      //   borderRadius: BorderRadius.circular(20),
                                      //     ),
                                      //   ),
                                      // );
                                    }
                                 });
                      }
                      return false;
            },
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(100.0),
                child: AppBar(
                  leading: IconButton(
                    onPressed: (){
                      if(Stamp== ''){
                        Stamp=defaultStamp;
                      }
                      if(Signature== ''){
                        Signature=defaultSignature;
                      }
                      if(Header== ''){
                        Header=defaultHeader;
                      }
                      if(Footer== ''){
                        Footer=defaultFooter;
                      }
                      if(_selectedChips.isNotEmpty || _addressToController.text.isNotEmpty 
                      ||_bodyController.text.isNotEmpty || _ccChipsList.isNotEmpty || 
                      _bccChipsList.isNotEmpty || _subjectController.text.isNotEmpty){
                            LetterProvider().draftLetter(_selectedChips.join(','),
                                 _addressToController.text, _bodyController.text, 
                                  Header, Footer, Signature, Stamp, context, _ccChipsList.join(','), 
                                 _bccChipsList.join(','), _subjectController.text,'').then((value) {
                                  var data = jsonDecode(value.body);
                                   if(data['status']==true){
                                    print('inside snackbar');
                                      // ScaffoldMessenger.of(context).showSnackBar(
                                      //   SnackBar(
                                      //     width: MediaQuery.of(context).size.width-50,
                                      //     content: Center(child: Text("Message saved as draft",style: TextStyle(color: Colors.white),)),
                                      //     duration: Duration(seconds: 4),
                                      //     behavior: SnackBarBehavior.floating,
                                      //   backgroundColor: Color.fromRGBO(0, 0, 0, 0.5),
                                      //   shape: RoundedRectangleBorder(
                                      //   borderRadius: BorderRadius.circular(20),
                                      //     ),
                                      //   ),
                                      // );
                                   // Navigator.pop(context);
                                    }
                                 });
                      }
                      else{
                        Navigator.pop(context);
                      }
               },
                   icon: const Icon(Icons.arrow_back)),
                  backgroundColor:  const Color(0xff999999),
                  title: const Text('Compose Letter'),
                  actions: <Widget>[
                    IconButton(
                      onPressed: () {
                        _sendMail(context);
                      },
                      icon: const Icon(Icons.send),
                    )
                  ],
                ),
              ),
              body: FutureBuilder(
                  future:LetterProvider().getDefaultStamp(context),
                  builder: (context, snapshot) {
                    if(snapshot.hasData){
                      if(snapshot.data[0]['default_stamp'] != ''){
                        defaultStamp=AppUrls.appBaseUrl+snapshot.data[0]['default_stamp'];
                      }
                      if(snapshot.data[0]['default_signature'] !=''){
                        defaultSignature=AppUrls.appBaseUrl+snapshot.data[0]['default_signature'];
                      }
                      if(snapshot.data[0]['default_header'] !=''){
                        defaultHeader=AppUrls.appBaseUrl+snapshot.data[0]['default_header'];
                      }
                      if(snapshot.data[0]['default_footer'] !=''){
                        defaultFooter=AppUrls.appBaseUrl+snapshot.data[0]['default_footer'];
                    }
          
                return  Container(
                // height: MediaQuery.of(context).size.height-200,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                     
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text('To',style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 10,),
                                    Column(
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width/1.4,
                                          child: Wrap(
                                            children: [
                                              ..._buildChips(),
                                              TextFormField(
                                                controller: _toController,
                                                focusNode: _focusNode,
          
                                                onFieldSubmitted: (value) {
                                                  if( _selectedChips.contains(_toController.text)){
                                                    ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
                                                      duration: Duration(milliseconds: 1000),
                                                      content: Text('Already Selected'),
                                                    ));
                                                  }
                                                  else  if(emailValidate.hasMatch(_toController.text)){
                                                    setState(() {
                                                      _selectedChips.add(_toController.text.toString().trim());
                                                      _toController.clear();
                                                    });
                                                  }
                                                  else{
                                                    ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
                                                      duration: Duration(milliseconds: 1000),
                                                      content: Text('Please enter a valid email address'),
                                                    ));
                                                  }
                                                  // if (widget.onChanged != null) {
                                                  //   widget.onChanged(_selectedChips);
                                                  // }
                                                },
                                                onChanged: (value) {
                                                  //print(value.substring(start));
                                                  setState(() {
                                                    List<String> values = _toController.text.split(',');
                                                    String lastValue = values.last.trim();
                                                    print(filteredList);
                                                    filteredList = emailList.where((item) =>( item['email'].toLowerCase().contains(lastValue.toLowerCase())
                                                        ||item['name'].toLowerCase().contains(lastValue.toLowerCase())
                                                    )).toSet().toList();
                                                  });
          
                                                } ,
                                                decoration: const InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: 'To',
          
                                                ),
          
                                              ),
                                            ],
                                          ),
                                        ),
          
                                      ],
                                    ),
          
                                  ],
                                ),
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        showBcc = !showBcc;
                                      });
                                    },
                                    icon:  showBcc
                                        ? const Icon(Icons.arrow_drop_up)
                                        : const Icon(Icons.arrow_drop_down_outlined)),
                              ],
                            ),
                          ),
                          const Divider(thickness: 2,),
                          _isTextFieldSelected  && _toController.text.isNotEmpty? filteredList.isEmpty?
                          Column(
                            children: [
                              Container(
                                // height: 200,
                                width: MediaQuery.of(context).size.width/1.1,
                                decoration: BoxDecoration(color: Colors.grey[300]),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      if( _selectedChips.contains(_toController.text)){
                                        ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
                                          duration: Duration(milliseconds: 1000),
                                          content: Text('Already Selected'),
                                        ));
                                      }
                                      else if(emailValidate.hasMatch(_toController.text)){
                                        setState(() {
                                          _selectedChips.add(_toController.text.toString().trim());
                                          _toController.clear();
                                        });
                                      }
                                      else{
                                        ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
                                          duration: Duration(milliseconds: 1000),
                                          content: Text('Please enter a valid email address'),
                                        ));
                                      }
                                    },
                                    child: Container(
                                      // height: 50,
                                      //decoration: BoxDecoration(border: Border.all()),
                                      child: Row(
                                        children: [
                                          Container(
                                            decoration: const BoxDecoration(shape: BoxShape.circle),
                                            child: Image.asset(contactIcon,width: 40,height: 40,),
                                          ),
                                          const SizedBox(width: 10,),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Add Recipent',style: TextStyle(fontSize: 18),),
                                              SizedBox(
                                                width: MediaQuery.of(context).size.width/1.5,
                                                child: AutoSizeText(_toController.text.toString(),
                                                  maxLines: 3,
                                                ),
                                              ),
          
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ):Container(
                            height: 200,
                            width: MediaQuery.of(context).size.width/1.1,
                            decoration: BoxDecoration(color: Colors.grey[300]),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: ListView.builder(
                                itemCount: filteredList.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: Container(
                                      //height: 50,
                                      // decoration: BoxDecoration(border: Border(bottom: BorderSide())),
                                      child:  GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if( _selectedChips.contains(filteredList[index]['email'])){
                                              ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
                                                duration: Duration(milliseconds: 1000),
                                                content: Text('Already Selected'),
                                              ));
                                            }
                                            else{
                                              _selectedChips.add(filteredList[index]['email'].trim());
                                              _toController.clear();
                                            }
                                          });
                                         
                                        },
                                        child: Container(
                                          // height: 50,
                                          //decoration: BoxDecoration(border: Border.all()),
                                          child: Row(
                                            children: [
                                              Container(
                                                  decoration: const BoxDecoration(shape: BoxShape.circle),
                                                  child: CircleAvatar(
                                                    backgroundImage: NetworkImage(filteredList[index]['profilePic'],),
                                                    radius: 20,
                                                  )
                                                //Image.network(filteredList[index]['profilePic'],width: 40,height: 40,),
                                              ),
                                              const SizedBox(width: 10,),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(filteredList[index]['name'],style: const TextStyle(fontSize: 18),),
                                                  SizedBox(
                                                    width: MediaQuery.of(context).size.width/1.5,
                                                    child: AutoSizeText(filteredList[index]['email'],
                                                      maxLines: 3,
                                                    ),
                                                  ),
          
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        //Text(filteredList[index])
                                      ),
          
                                    ),
                                  );
                                },
                              ),
                            ),
                          ):Container(),
                          showBcc
                              ? Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: [
                                    const Text('Cc',style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 10,),
                                    Column(
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width/1.4,
                                          child: Wrap(
                                            children: [
                                              ..._ccChips(),
                                              TextFormField(
                                                controller: _ccController,
                                                focusNode: _ccfocusNode,
          
                                                onFieldSubmitted: (value) {
                                                  if( _ccChipsList.contains(_ccController.text)){
                                                    ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
                                                      duration: Duration(milliseconds: 1000),
                                                      content: Text('Already Selected'),
                                                    ));
                                                  }
                                                  else  if(emailValidate.hasMatch(_ccController.text)){
                                                    setState(() {
                                                      _ccChipsList.add(_ccController.text.toString().trim());
                                                      _ccController.clear();
                                                    });
                                                  }
                                                  else{
                                                    ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
                                                      duration: Duration(milliseconds: 1000),
                                                      content: Text('Please enter a valid email address'),
                                                    ));
                                                  }
                                                  // if (widget.onChanged != null) {
                                                  //   widget.onChanged(_selectedChips);
                                                  // }
                                                },
                                                onChanged: (value) {
                                                  //print(value.substring(start));
                                                  setState(() {
                                                    List<String> values = _ccController.text.split(',');
                                                    String lastValue = values.last.trim();
                                                    print(ccList);
                                                    ccList = emailList.where((item) =>( item['email'].toLowerCase().contains(lastValue.toLowerCase())
                                                        ||item['name'].toLowerCase().contains(lastValue.toLowerCase())
                                                    )).toSet().toList();
                                                  });
          
                                                } ,
                                                decoration: const InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: 'Cc',
          
                                                ),
          
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(thickness: 2,),
                              _isCcSelected  && _ccController.text.isNotEmpty? ccList.isEmpty?
                              Column(
                                children: [
                                  Container(
                                    // height: 200,
                                    width: MediaQuery.of(context).size.width/1.1,
                                    decoration: BoxDecoration(color: Colors.grey[300]),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          if( _ccChipsList.contains(_ccController.text)){
                                            ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
                                              duration: Duration(milliseconds: 1000),
                                              content: Text('Already Selected'),
                                            ));
                                          }
                                          else if(emailValidate.hasMatch(_ccController.text)){
                                            setState(() {
                                              _ccChipsList.add(_ccController.text.toString().trim());
                                              _ccController.clear();
                                            });
                                          }
                                          else{
                                            ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
                                              duration: Duration(milliseconds: 1000),
                                              content: Text('Please enter a valid email address'),
                                            ));
                                          }
                                        },
                                        child: Container(
                                          // height: 50,
                                          //decoration: BoxDecoration(border: Border.all()),
                                          child: Row(
                                            children: [
                                              Container(
                                                decoration: const BoxDecoration(shape: BoxShape.circle),
                                                child: Image.asset(contactIcon,width: 40,height: 40,),
                                              ),
                                              const SizedBox(width: 10,),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text('Add Recipent',style: TextStyle(fontSize: 18),),
                                                  SizedBox(
                                                    width: MediaQuery.of(context).size.width/1.5,
                                                    child: AutoSizeText(_ccController.text.toString(),
                                                      maxLines: 3,
                                                    ),
                                                  ),
          
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ):Container(
                                height: 200,
                                width: MediaQuery.of(context).size.width/1.1,
                                decoration: BoxDecoration(color: Colors.grey[300]),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: ListView.builder(
                                    itemCount: ccList.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                        child: Container(
                                          //height: 50,
                                          // decoration: BoxDecoration(border: Border(bottom: BorderSide())),
                                          child:  GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if( _ccChipsList.contains(ccList[index]['email'])){
                                                  ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
                                                    duration: Duration(milliseconds: 1000),
                                                    content: Text('Already Selected'),
                                                  ));
                                                }
                                                else{
                                                  _ccChipsList.add(ccList[index]['email'].trim());
                                                  _ccController.clear();
                                                }
                                              });
                                             
                                            },
                                            child: Container(
                                              // height: 50,
                                              //decoration: BoxDecoration(border: Border.all()),
                                              child: Row(
                                                children: [
                                                  Container(
                                                      decoration: const BoxDecoration(shape: BoxShape.circle),
                                                      child: CircleAvatar(
                                                        backgroundImage: NetworkImage(ccList[index]['profilePic'],),
                                                        radius: 20,
                                                      )
                                                    //Image.network(filteredList[index]['profilePic'],width: 40,height: 40,),
                                                  ),
                                                  const SizedBox(width: 10,),
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(ccList[index]['name'],style: const TextStyle(fontSize: 18),),
                                                      SizedBox(
                                                        width: MediaQuery.of(context).size.width/1.5,
                                                        child: AutoSizeText(ccList[index]['email'],
                                                          maxLines: 3,
                                                        ),
                                                      ),
          
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            //Text(filteredList[index])
                                          ),
          
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ):Container(),
          
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: [
                                    const Text('Bcc',style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 10,),
                                    Column(
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width/1.4,
                                          child: Wrap(
                                            children: [
                                              ..._bccChips(),
                                              TextFormField(
                                                controller: _bccController,
                                                focusNode: _bccfocusNode,
          
                                                onFieldSubmitted: (value) {
                                                  if( _bccChipsList.contains(_bccController.text)){
                                                    ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
                                                      duration: Duration(milliseconds: 1000),
                                                      content: Text('Already Selected'),
                                                    ));
                                                  }
                                                  else  if(emailValidate.hasMatch(_bccController.text)){
                                                    setState(() {
                                                      _bccChipsList.add(_bccController.text.toString().trim());
                                                      _bccController.clear();
                                                    });
                                                  }
                                                  else{
                                                    ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
                                                      duration: Duration(milliseconds: 1000),
                                                      content: Text('Please enter a valid email address'),
                                                    ));
                                                  }
                                                  // if (widget.onChanged != null) {
                                                  //   widget.onChanged(_selectedChips);
                                                  // }
                                                },
                                                onChanged: (value) {
                                                  //print(value.substring(start));
                                                  setState(() {
                                                    List<String> values = _bccController.text.split(',');
                                                    String lastValue = values.last.trim();
                                                    print(bccList);
                                                    bccList = emailList.where((item) =>( item['email'].toLowerCase().contains(lastValue.toLowerCase())
                                                        ||item['name'].toLowerCase().contains(lastValue.toLowerCase())
                                                    )).toSet().toList();
                                                  });
          
                                                } ,
                                                decoration: const InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: 'Bcc',
          
                                                ),
          
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
          
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(thickness: 2,),
          
                              _isBccSelected  && _bccController.text.isNotEmpty? bccList.isEmpty?
                              Column(
                                children: [
                                  Container(
                                    // height: 200,
                                    width: MediaQuery.of(context).size.width/1.1,
                                    decoration: BoxDecoration(color: Colors.grey[300]),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          if( _bccChipsList.contains(_bccController.text)){
                                            ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
                                              duration: Duration(milliseconds: 1000),
                                              content: Text('Already Selected'),
                                            ));
                                          }
                                          else if(emailValidate.hasMatch(_bccController.text)){
                                            setState(() {
                                              _bccChipsList.add(_bccController.text.toString().trim());
                                              _bccController.clear();
                                            });
                                          }
                                          else{
                                            ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
                                              duration: Duration(milliseconds: 1000),
                                              content: Text('Please enter a valid email address'),
                                            ));
                                          }
                                        },
                                        child: Container(
                                          // height: 50,
                                          //decoration: BoxDecoration(border: Border.all()),
                                          child: Row(
                                            children: [
                                              Container(
                                                decoration: const BoxDecoration(shape: BoxShape.circle),
                                                child: Image.asset(contactIcon,width: 40,height: 40,),
                                              ),
                                              const SizedBox(width: 10,),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text('Add Recipent',style: TextStyle(fontSize: 18),),
                                                  SizedBox(
                                                    width: MediaQuery.of(context).size.width/1.5,
                                                    child: AutoSizeText(_bccController.text.toString(),
                                                      maxLines: 3,
                                                    ),
                                                  ),
          
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ):Container(
                                height: 200,
                                width: MediaQuery.of(context).size.width/1.1,
                                decoration: BoxDecoration(color: Colors.grey[300]),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: ListView.builder(
                                    itemCount: bccList.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                        child: Container(
                                          //height: 50,
                                          // decoration: BoxDecoration(border: Border(bottom: BorderSide())),
                                          child:  GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if( _bccChipsList.contains(bccList[index]['email'])){
                                                  ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
                                                    duration: Duration(milliseconds: 1000),
                                                    content: Text('Already Selected'),
                                                  ));
                                                }
                                                else{
                                                  _bccChipsList.add(bccList[index]['email'].trim());
                                                  _bccController.clear();
                                                }
                                              });
                                             
                                            },
                                            child: Container(
                                              // height: 50,
                                              //decoration: BoxDecoration(border: Border.all()),
                                              child: Row(
                                                children: [
                                                  Container(
                                                      decoration: const BoxDecoration(shape: BoxShape.circle),
                                                      child: CircleAvatar(
                                                        backgroundImage: NetworkImage(bccList[index]['profilePic'],),
                                                        radius: 20,
                                                      )
                                                    //Image.network(filteredList[index]['profilePic'],width: 40,height: 40,),
                                                  ),
                                                  const SizedBox(width: 10,),
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(bccList[index]['name'],style: const TextStyle(fontSize: 18),),
                                                      SizedBox(
                                                        width: MediaQuery.of(context).size.width/1.5,
                                                        child: AutoSizeText(bccList[index]['email'],
                                                          maxLines: 3,
                                                        ),
                                                      ),
          
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            //Text(filteredList[index])
                                          ),
          
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ):Container(),
          
                            ],
                          )
                              : Container(),
          
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                     print('headdata---------${account.headData.length}');
                                    if(account.headData.isEmpty){
                                      print('true');
                                            return const AlertDialog(
                                              title: Text('No Header'),
                                               content: Text('Add header from setting'),
                                            );
                                          }
                                    else{
                                    return Dialog(
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: account.headData.length,
                                        itemBuilder: (context, index) {
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              const SizedBox(height: 15,),
                                              Text(account
                                                  .headData[index]['name'],
                                                style: const TextStyle(
                                                    fontSize: 17,
                                                    color: Colors
                                                        .grey),),
                                              const SizedBox(height: 10,),
                                              InkWell(
                                                onTap: () {
                                                  // Close the dialog and pass back the selected item
                                                  setState(() {
                                                    //attachments.add(account.signData[index]['image']);
                                                    // String typeToRemove = 'head';
                                                    // List<ListItem> newItems = attachmentItems.where((item) => item.type != typeToRemove).toList();
                                                    // attachmentItems = newItems;
                                                    // attachmentItems.add( ListItem(account.headData[index]['image'], 'head'));
                                                    Header=account.headData[index]['image'];
          
                                                  });
                                                  Navigator.pop(context, account.headData[index]['id']);
                                                },
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .center,
                                                  children: [
                                                    DottedBorder(
                                                      borderType: BorderType
                                                          .RRect,
                                                      radius: const Radius
                                                          .circular(12),
                                                      dashPattern: const [8, 4],
                                                      strokeWidth: 2,
                                                      color: account
                                                          .headData[index]['default'] ==
                                                          true
                                                          ? Colors.green
                                                          : Colors.grey,
                                                      child:
                                                      Container(
                                                        child:
                                                        Padding(
                                                          padding: const EdgeInsets
                                                              .all(5.0),
                                                          child: ClipRect(
                                                              child: Image
                                                                  .network(
                                                                account
                                                                    .headData[index]['image'],
                                                                width: MediaQuery
                                                                    .of(
                                                                    context)
                                                                    .size
                                                                    .width /
                                                                    1.9,
                                                                height: 80,
                                                                fit: BoxFit
                                                                    .contain,)),
                                                        ),
                                                      ),
                                                    ),
          
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 15,)
                                            ],
          
                                          );
                                        
                                        },
                                      ),
                                    );}
                                  },
                                );
          
                              },
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width/1.6,
                                    child: const Text('Add Header',style: TextStyle(fontWeight: FontWeight.bold),),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(thickness: 2,),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                const Text('Addressed To',style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(width: 10,),
                                Flexible(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width/1.4,
                                    child: TextFormField(
                                      controller: _addressToController,
                                      onTap: () {
                                        setState(() {
                                          showBcc = false;
                                        });
                                      },
                                      decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Addressed To'
                                      ),
                                    ),
                                  ),
                                ),],
                            ),
                          ),
                          const Divider(thickness: 2,),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                const Text('Subject',style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(width: 10,),
                                Flexible(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width/1.3,
                                    child: TextFormField(
                                      controller: _subjectController,
                                      onTap: () {
                                        setState(() {
                                          showBcc = false;
                                        });
                                      },
                                      decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Subject'
                                      ),
                                    ),
                                  ),
                                ),],
                            ),
                          ),
                          const Divider(thickness: 2,),
                        ],
                      ),
          
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Body',style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10,),
                          SizedBox(
                            width: MediaQuery.of(context).size.width/1.1,
                            child: TextFormField(
                              controller: _bodyController,
                              onTap: () {
                                setState(() {
                                  showBcc = false;
                                });
                              },
                              maxLines: 15,
                              // expands: true,
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Body'
                              ),
                            ),
                          ),
                          // Text("Add Footer",style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(thickness: 2,),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              if(account.footData.isEmpty){
                                      print('true');
                                            return const AlertDialog(
                                              title: Text('No Footer'),
                                              content: Text('Add footer from setting'),
                                            );
                                          }
                              else{
                              return Dialog(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: account.footData.length,
                                  itemBuilder: (context, index) {
                                    
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: 15,),
                                        Text(account
                                            .footData[index]['name'],
                                          style: const TextStyle(
                                              fontSize: 17,
                                              color: Colors
                                                  .grey),),
                                        const SizedBox(height: 10,),
                                        InkWell(
                                          onTap: () {
                                            // Close the dialog and pass back the selected item
                                            setState(() {
                                              //attachments.add(account.signData[index]['image']);
                                              // String typeToRemove = 'foot';
          
                                              // List<ListItem> newItems = attachmentItems.where((item) => item.type != typeToRemove).toList();
                                              // attachmentItems = newItems;
          
                                              // attachmentItems.add( ListItem(account.footData[index]['image'], 'foot'));
                                              Footer=account.footData[index]['image'];
                                            });
                                            Navigator.pop(context, account.footData[index]['id']);
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              DottedBorder(
                                                borderType: BorderType
                                                    .RRect,
                                                radius: const Radius
                                                    .circular(12),
                                                dashPattern: const [8, 4],
                                                strokeWidth: 2,
                                                color: account
                                                    .footData[index]['default'] ==
                                                    true
                                                    ? Colors.green
                                                    : Colors.grey,
                                                child:
                                                Container(
                                                  child:
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .all(5.0),
                                                    child: ClipRect(
                                                        child: Image
                                                            .network(
                                                          account
                                                              .footData[index]['image'],
                                                          width: MediaQuery
                                                              .of(
                                                              context)
                                                              .size
                                                              .width /
                                                              1.8,
                                                          height: 80,
                                                          fit: BoxFit
                                                              .contain,)),
                                                  ),
                                                ),
                                              ),
          
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 15,)
                                      ],
          
                                    );
                                          
                                  },
                                  
                                ),
                              );
                            }
                            },
          
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width/1.6,
                                child: const Text('Add Footer',style: TextStyle(fontWeight: FontWeight.bold),),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(thickness: 2,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        //crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width/2.2,
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey),
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(15),
                                    bottomLeft: Radius.circular(15))
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: GestureDetector(
                                onTap: () {
          
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      if(account.signData.isEmpty){
                                      print('true');
                                            return const AlertDialog(
                                              title: Text('No Signature'),
                                               content: Text('Add signature from setting'),
                                            );
                                          }
                                    else{
                                      return Dialog(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: account.signData.length,
                                          itemBuilder: (context, index) {
                                             
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                const SizedBox(height: 15,),
                                                Text(account
                                                    .signData[index]['name'],
                                                  style: const TextStyle(
                                                      fontSize: 17,
                                                      color: Colors
                                                          .grey),),
                                                const SizedBox(height: 10,),
                                                InkWell(
                                                  onTap: () {
                                                    // Close the dialog and pass back the selected item
                                                    setState(() {
                                                      //attachments.add(account.signData[index]['image']);
          
                                                      // String typeToRemove = 'sign';
          
                                                      // List<ListItem> newItems = attachmentItems.where((item) => item.type != typeToRemove).toList();
                                                      // attachmentItems = newItems;
          
                                                      // attachmentItems.add( ListItem(account.signData[index]['image'], 'sign'));
                                                      Signature=account.signData[index]['image'];
          
                                                    });
                                                    Navigator.pop(context, account.signData[index]['id']);
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      DottedBorder(
                                                        borderType: BorderType
                                                            .RRect,
                                                        radius: const Radius
                                                            .circular(12),
                                                        dashPattern: const [8, 4],
                                                        strokeWidth: 2,
                                                        color: account
                                                            .signData[index]['default'] ==
                                                            true
                                                            ? Colors.green
                                                            : Colors.grey,
                                                        child:
                                                        Container(
                                                          child:
                                                          Padding(
                                                            padding: const EdgeInsets
                                                                .all(5.0),
                                                            child: ClipRect(
                                                                child: Image
                                                                    .network(
                                                                  account
                                                                      .signData[index]['image'],
                                                                  width: MediaQuery
                                                                      .of(
                                                                      context)
                                                                      .size
                                                                      .width /
                                                                      1.8,
                                                                  height: 80,
                                                                  fit: BoxFit
                                                                      .contain,)),
                                                          ),
                                                        ),
                                                      ),
          
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 15,)
                                              ],
          
                                            );
                                          
                                          },
                                        ),
                                      );}
                                    },
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(border: Border.all(color: Colors.transparent)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text('Signature',style: TextStyle(fontWeight: FontWeight.bold)),
                                      Icon(Icons.arrow_drop_down,color: Colors.grey,)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width:  MediaQuery.of(context).size.width/2.2,
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey),
                                borderRadius: const BorderRadius.only(topRight: Radius.circular(15),
                                    bottomRight: Radius.circular(15))
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      if(account.stampData.isEmpty){
                                      print('true');
                                            return const AlertDialog(
                                              title: Text('No Stamp'),
                                               content: Text('Add stamp from setting'),
                                            );
                                          }
                                    else{
                                      return Dialog(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: account.stampData.length,
                                          itemBuilder: (context, index) {
                                             
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                const SizedBox(height: 15,),
                                                Text(account
                                                    .stampData[index]['name'],
                                                  style: const TextStyle(
                                                      fontSize: 17,
                                                      color: Colors
                                                          .grey),),
                                                const SizedBox(height: 10,),
                                                InkWell(
                                                  onTap: () {
                                                    // Close the dialog and pass back the selected item
                                                    setState(() {
                                                      // String typeToRemove = 'stamp';
          
                                                      // List<ListItem> newItems = attachmentItems.where((item) => item.type != typeToRemove).toList();
                                                      // attachmentItems = newItems;
          
                                                      // attachmentItems.add( ListItem(account.stampData[index]['image'], 'stamp'));
                                                      Stamp=account.stampData[index]['image'];
                                                    });
                                                    Navigator.pop(context, account.stampData[index]['id']);
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      DottedBorder(
                                                        borderType: BorderType
                                                            .RRect,
                                                        radius: const Radius
                                                            .circular(12),
                                                        dashPattern: const [8, 4],
                                                        strokeWidth: 2,
                                                        color: account
                                                            .stampData[index]['default'] ==
                                                            true
                                                            ? Colors.green
                                                            : Colors.grey,
                                                        child:
                                                        Container(
                                                          child:
                                                          Padding(
                                                            padding: const EdgeInsets
                                                                .all(5.0),
                                                            child: ClipRect(
                                                                child: Image
                                                                    .network(
                                                                  account
                                                                      .stampData[index]['image'],
                                                                  width: MediaQuery
                                                                      .of(
                                                                      context)
                                                                      .size
                                                                      .width /
                                                                      1.8,
                                                                  height: 80,
                                                                  fit: BoxFit
                                                                      .contain,)),
                                                          ),
                                                        ),
                                                      ),
          
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 15,)
                                              ],
          
                                            );
                                          
                                          },
                                        ),
                                      );
                                    }
                                    },
                                  );
          
                                },
                                child: Container(
                                  decoration: BoxDecoration(border: Border.all(color: Colors.transparent)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Icon(Icons.arrow_drop_down,color: Colors.grey,),
                                      Text('Stamp',style: TextStyle(fontWeight: FontWeight.bold)),
          
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      )
          
                    ],
                  ),
                ),
              );
                    }
                    else{
                      return const Center(child: CircularProgressIndicator(),);
                    }
                  }),
                  bottomNavigationBar: BottomAppBar(
                child:  Container(
                  height: 70.0,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  color: Colors.grey[300],
                  child:  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      BottomSectionTransp(),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
    );

  }

  Future _openImagePicker(ImageSource source) async {
    // final pick = await ImagePicker().getImage(source: ImageSource.gallery);

    final pick = await ImagePicker().pickImage(source: source);
    // if (image == null) return null;

    if (pick != null) {
      setState(() {
        attachments.add(pick.path);
        fileData.add(File(pick.path));
      });
      print('attachments');
      print(attachments);
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      print('index');
      print(index);
      //attachments.removeAt(index);
      attachmentItems.removeAt(index);
      // fileData.removeAt(index);
    });
  }

  void _sendMail(contexts) {
    print(_bodyController.text);
    var mailP = Provider.of<LetterProvider>(contexts, listen: false);
    var expr = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    // var header ="";
    // var footer ="";
    // var signature ="";
    // var stamp ="";
    String typeToTake = 'Type A';
    for (var i = 0; i < _selectedChips.length; i++) {
      letterSent='$letterSent${_selectedChips[i]},';
    }
   
    print('$letterSent\n$_bodyController.\n$_addressToController\n$Header\n$Footer\n$Signature\n$Stamp');
    if(_selectedChips.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
        duration: Duration(milliseconds: 1000),
        content: Text('Please enter email'),
      ));
    }
    else{
      if(Stamp== ''){
        Stamp=defaultStamp;
      }
      if(Signature== ''){
        Signature=defaultSignature;
      }
      if(Header== ''){
        Header=defaultHeader;
      }
      if(Footer== ''){
        Footer=defaultFooter;
      }
      Navigator.push(context, MaterialPageRoute(builder: (context)=>PreviewScreen(
        address: _addressToController.text,subject:_subjectController.text ,
        body: _bodyController.text,
        sent:_selectedChips.join(',') ,cc: _ccChipsList.join(','),bcc: _bccChipsList.join(','),sign: Signature ,stamp: Stamp,header: Header,footer: Footer ,)));
    }

   

    print('response of mail');
    // print(mailP.resMessage);
  }
}
class ListItem {
  String path;
  String type;

  ListItem(this.path, this.type);
}