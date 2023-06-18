import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/LetterProvider/letter_provider.dart';
import 'package:smart_station/screens/home_screen/letter/letter_compose_screen.dart';
import 'package:smart_station/screens/home_screen/letter/letter_pdf_view.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
class LetterForwardScreen extends StatefulWidget {
  final pdf;
  final letter_id;
  const LetterForwardScreen({super.key,required this.pdf,required this.letter_id});

  @override
  State<LetterForwardScreen> createState() => _LetterForwardScreenState();
}

class _LetterForwardScreenState extends State<LetterForwardScreen> {

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
  bool showBcc = false;
  var emailValidate = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _ccController = TextEditingController();
  final TextEditingController _bccController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();

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
  void initState() {
    _subjectController.text='Forwarded Letter';
    _focusNode.addListener(_onFocusChange);
    _bccfocusNode.addListener(_onBccFocusChange);
    _ccfocusNode.addListener(_onCcFocusChange);
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: AppBar(
          backgroundColor:  const Color(0xff999999),
          title: const Text('Forward Letter'),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                var letter = Provider.of<LetterProvider>(context, listen: false);
                if(_selectedChips.isEmpty){
                  ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
                    duration: Duration(milliseconds: 1000),
                    content: Text('Please enter to email'),
                  ));
                }
                else{
                  // letter.forwardLetter(toMail, context, ccMail, bccMail, subject, id)
                  letter.forwardLetter(_selectedChips.join(','), context, _ccChipsList.join(','),
                      _bccChipsList.join(','), _subjectController.text, widget.letter_id);
                }
                //_sendMail(context);
              },
              icon: const Icon(Icons.send),
            )
          ],
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
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

                    const SizedBox(width: 10,),
                    _ccChipsList.isEmpty && _bccChipsList.isEmpty?
                    IconButton(
                        onPressed: () {
                          setState(() {
                            showBcc = !showBcc;
                          });
                        },
                        icon:  showBcc
                            ? const Icon(Icons.arrow_drop_up)
                            : const Icon(Icons.arrow_drop_down_outlined))
                        :const SizedBox()
                    // SizedBox(width: 15,),
                    // IconButton(
                    //   onPressed: () {
                    //      _sendMail(context);
                    //   },
                    //   icon: Icon(Icons.contact_mail )),

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
              showBcc || _ccChipsList.isNotEmpty || _bccChipsList.isNotEmpty
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
                child: Row(
                  children: [
                    const Text('Subject',style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10,),
                    SizedBox(
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
                    ),],
                ),
              ),
              const Divider(thickness: 2,),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>LetterPdfView(pdf: widget.pdf)));
                  },
                  child: Container(
                      height: MediaQuery.of(context).size.height / 4,
                      width: MediaQuery.of(context).size.width / 1.2,
                      color: Colors.grey.shade200,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 60,
                            ),
                            const Icon(
                              Icons.file_copy,
                              size: 40,
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              children: const [
                                Icon(Icons.picture_as_pdf),
                                SizedBox(
                                  width: 15,
                                ),
                                Text('Letter Name'),
                                SizedBox(
                                  width: 30,
                                ),
                                Icon(Icons.download),
                              ],
                            )
                          ],
                        ),
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}