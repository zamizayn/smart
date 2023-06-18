import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/EmailProvider/email_provider.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class EmailComposeScreen extends StatefulWidget {
  final List emailList;
  String replayBody = '';
  String replayEmail = '';
  String replaySubject = '';
  bool forwardbool = false;

  EmailComposeScreen(
      {super.key,
      required this.emailList,
      required this.replayBody,
      required this.replayEmail,
      required this.replaySubject,
      required this.forwardbool});

  @override
  State<EmailComposeScreen> createState() => _EmailComposeScreenState();
}

class _EmailComposeScreenState extends State<EmailComposeScreen> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _ccController = TextEditingController();
  final TextEditingController _bccController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final FocusNode _fromFocusNode = FocusNode();
  final FocusNode _toFocusNode = FocusNode();
  final FocusNode _ccFocusNode = FocusNode();
  final FocusNode _bccFocusNode = FocusNode();
  final FocusNode _subjectFocusNode = FocusNode();
  final FocusNode _bodyFocusNode = FocusNode();
  List allEmails = [];

  var expr = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"); 
  List attachments = [];
  bool showBcc = false;
  List fileData = [];
  final List<String> _tochips = [];
  final List<String> _ccchips = [];
  final List<String> _bccchips = [];

  late List toEmailSearchList = widget.emailList;
  late List ccEmailSearchList = widget.emailList;
  late List bccEmailSearchList = widget.emailList;

  void toOnSearch(String searchText) {
    setState(() {
      print(toEmailSearchList);
      toEmailSearchList = widget.emailList.where((email) {
        String name = email['name'].toString().toLowerCase();
        String companyMail = email['company_mail'].toString().toLowerCase();

        return name.contains(searchText.toLowerCase()) ||
            companyMail.contains(searchText.toLowerCase());
      }).toList();
    });
  }

  void bccOnSearch(String searchText) {
    setState(() {
      print(bccEmailSearchList);
      bccEmailSearchList = widget.emailList.where((email) {
        String name = email['name'].toString().toLowerCase();
        String companyMail = email['company_mail'].toString().toLowerCase();

        return name.contains(searchText.toLowerCase()) ||
            companyMail.contains(searchText.toLowerCase());
      }).toList();
    });
  }

  void ccOnSearch(String searchText) {
    setState(() {
      print(ccEmailSearchList);
      ccEmailSearchList = widget.emailList.where((email) {
        String name = email['name'].toString().toLowerCase();
        String companyMail = email['company_mail'].toString().toLowerCase();

        return name.contains(searchText.toLowerCase()) ||
            companyMail.contains(searchText.toLowerCase());
      }).toList();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _subjectController.text = widget.replaySubject;
  }

  @override
  Widget build(BuildContext context) {
    print(widget.replayBody);
    print('_________-----------------------------');
    print(toEmailSearchList);
    return Scaffold(
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            _fromFocusNode.unfocus();
            _toFocusNode.unfocus();
            _ccFocusNode.unfocus();
            _bccFocusNode.unfocus();
            _subjectFocusNode.unfocus();
            _bodyFocusNode.unfocus();
          },
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Stack(children: [
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: Container(
                      height: 120,
                      color: Colors.black38,
                    ),
                  ),

                  // TopSection2(),
                  Positioned(
                    top: 50,
                    right: 20,
                    child: Row(
                      children: [
                        IconButton(
                            icon: const Icon(
                              Icons.attachment,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              openFilePicker();
                            }),
                        IconButton(
                          onPressed: () {
                            print(_bccchips.join(','));
                            if (widget.replayBody.isNotEmpty &&
                                widget.forwardbool == false) {
                              print('replay Mail');
                              _replayMail(context);
                            } else if (widget.forwardbool == true) {
                              print('Forward Mail');
                              print(_bodyController.text + widget.replayBody);
                              _ForwardMail(context);
                            } else {
                              print('send mail');
                              _sendMail(context);
                            }
                          },
                          icon: const Icon(Icons.send, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: 0,
                    right: 20,
                    child: Row(
                      children: [
                        // BackButton(color: Colors.white)
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back_sharp,
                              color: Colors.white),
                        ),
                        Text(
                          widget.replayBody.isNotEmpty &&
                                  widget.forwardbool == false
                              ? 'Replay Email'
                              : widget.forwardbool == true
                                  ? 'Forward Email'
                                  : 'Compose',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
                /* Padding(
                    padding: EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _fromController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'From',
                      ),
                    ),
                  ),*/
                _tochips.isNotEmpty
                    ? SizedBox(
                        width: 360,
                        child: Column(
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.start,
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: List<Widget>.generate(
                                _tochips.length,
                                (int index) {
                                  return Chip(
                                    label: Text(_tochips[index]),
                                    onDeleted: () {
                                      setState(() {
                                        _tochips.removeAt(index);
                                      });
                                    },
                                  );
                                },
                              ).toList(),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(),
                widget.replayBody.isNotEmpty && widget.forwardbool == false
                    ? const SizedBox()
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                            controller: _toController,
                            focusNode: _toFocusNode,
                            onChanged: toOnSearch,
                            decoration: InputDecoration(
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('To'),
                                ),
                                suffixIcon: _ccchips.isEmpty &&
                                        _bccchips.isEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          setState(() {
                                            showBcc = !showBcc;
                                          });
                                        },
                                        icon: showBcc == false
                                            ? const Icon(Icons.arrow_drop_up)
                                            : const Icon(
                                                Icons.arrow_drop_down_outlined),
                                      )
                                    : const SizedBox())),
                      ),
                _toController.text.length > 1 && _toFocusNode.hasFocus
                    ? Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: toEmailSearchList.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  print(
                                      toEmailSearchList[index]['profile_pic']);
                                  _tochips.add(toEmailSearchList[index]
                                          ['company_mail']
                                      .toString());
                                  _toController.clear();
                                });
                              },
                              child: SizedBox(
                                height: 50,
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: toEmailSearchList[index]
                                                  ['profile_pic'] ==
                                              ''
                                          ? Image.asset(
                                              contactIcon,
                                              //allEmails[index]['profile_pic'],
                                              width: 40,
                                              height: 40,
                                            )
                                          : Image.network(
                                              toEmailSearchList[index]
                                                  ['profile_pic'],
                                              width: 40,
                                              height: 40,
                                            ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          toEmailSearchList[index]['name'],
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.5,
                                          child: AutoSizeText(
                                            toEmailSearchList[index]
                                                    ['company_mail']
                                                .toString(),
                                            maxLines: 3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : const SizedBox(),
                _toController.text.isNotEmpty && _toFocusNode.hasFocus
                    ? Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: InkWell(
                          onTap: () {
                            if (expr.hasMatch(_toController.text)) {
                              setState(() {
                                _tochips.add(_toController.text);
                                _toController.clear();
                              });
                            } else {
                              setState(() {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  duration: Duration(milliseconds: 1000),
                                  content: Text(
                                      'Please enter a valid email address'),
                                ));
                              });
                            }
                          },
                          child: SizedBox(
                            height: 50,
                            child: Row(
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle),
                                  child: Image.asset(
                                    contactIcon,
                                    width: 40,
                                    height: 40,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Add Recipent',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          1.5,
                                      child: AutoSizeText(
                                        _toController.text.toString(),
                                        maxLines: 3,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
                SizedBox(
                  width: 360,
                  child: Column(
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.start,
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: List<Widget>.generate(
                          _ccchips.length,
                          (int index) {
                            return Chip(
                              label: Text(_ccchips[index]),
                              onDeleted: () {
                                setState(() {
                                  _ccchips.removeAt(index);
                                });
                              },
                            );
                          },
                        ).toList(),
                      ),
                    ],
                  ),
                ),
                _ccchips.isNotEmpty || _bccchips.isNotEmpty || showBcc == true
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _ccController,
                          focusNode: _ccFocusNode,
                          onChanged: ccOnSearch,
                          decoration: const InputDecoration(
                            //  border: OutlineInputBorder(),
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Cc'),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
                _ccController.text.length > 1 && _ccFocusNode.hasFocus
                    ? Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: ccEmailSearchList.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  print(
                                      ccEmailSearchList[index]['profile_pic']);
                                  _ccController.clear();
                                  _ccchips.add(ccEmailSearchList[index]
                                          ['company_mail']
                                      .toString());
                                });
                              },
                              child: SizedBox(
                                height: 50,
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: ccEmailSearchList[index]
                                                  ['profile_pic'] ==
                                              ''
                                          ? Image.asset(
                                              contactIcon,
                                              //allEmails[index]['profile_pic'],
                                              width: 40,
                                              height: 40,
                                            )
                                          : Image.network(
                                              ccEmailSearchList[index]
                                                  ['profile_pic'],
                                              width: 40,
                                              height: 40,
                                            ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ccEmailSearchList[index]['name'],
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.5,
                                          child: AutoSizeText(
                                            ccEmailSearchList[index]
                                                    ['company_mail']
                                                .toString(),
                                            maxLines: 3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : const SizedBox(),
                _ccController.text.length > 1 && _ccFocusNode.hasFocus
                    ? Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: InkWell(
                          onTap: () {
                            if (expr.hasMatch(_ccController.text)) {
                              setState(() {
                                _ccchips.add(_ccController.text);
                                _ccController.clear();
                              });
                            } else {
                              setState(() {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  duration: Duration(milliseconds: 1000),
                                  content: Text(
                                      'Please enter a valid email address'),
                                ));
                              });
                            }
                          },
                          child: SizedBox(
                            height: 50,
                            child: Row(
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle),
                                  child: Image.asset(
                                    contactIcon,
                                    width: 40,
                                    height: 40,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Add Recipent',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          1.5,
                                      child: AutoSizeText(
                                        _ccController.text.toString(),
                                        maxLines: 3,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
                SizedBox(
                  width: 360,
                  child: Column(
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.start,
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: List<Widget>.generate(
                          _bccchips.length,
                          (int index) {
                            return Chip(
                              label: Text(_bccchips[index]),
                              onDeleted: () {
                                setState(() {
                                  _bccchips.removeAt(index);
                                });
                              },
                            );
                          },
                        ).toList(),
                      ),
                    ],
                  ),
                ),
                _ccchips.isNotEmpty || _bccchips.isNotEmpty || showBcc == true
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _bccController,
                          focusNode: _bccFocusNode,
                          onChanged: bccOnSearch,
                          decoration: const InputDecoration(
                            // border: OutlineInputBorder(),
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Bcc'),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
                _bccController.text.length > 1 && _bccFocusNode.hasFocus
                    ? Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: ListView.builder(
                          itemCount: bccEmailSearchList.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  print(
                                      bccEmailSearchList[index]['profile_pic']);
                                  _bccController.clear();
                                  _bccchips.add(bccEmailSearchList[index]
                                          ['company_mail']
                                      .toString());
                                });
                              },
                              child: SizedBox(
                                height: 60,
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: bccEmailSearchList[index]
                                                  ['profile_pic'] ==
                                              ''
                                          ? Image.asset(
                                              contactIcon,
                                              //allEmails[index]['profile_pic'],
                                              width: 40,
                                              height: 40,
                                            )
                                          : Image.network(
                                              bccEmailSearchList[index]
                                                  ['profile_pic'],
                                              width: 40,
                                              height: 40,
                                            ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          bccEmailSearchList[index]['name'],
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.5,
                                          child: AutoSizeText(
                                            bccEmailSearchList[index]
                                                    ['company_mail']
                                                .toString(),
                                            maxLines: 3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : const SizedBox(),
                _bccController.text.length > 1 && _bccFocusNode.hasFocus
                    ? Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (expr.hasMatch(_bccController.text)) {
                                _bccchips.add(_bccController.text);

                                _bccController.clear();
                              } else {
                                setState(() {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    duration: Duration(milliseconds: 1000),
                                    content: Text(
                                        'Please enter a valid email address'),
                                  ));
                                });
                              }
                            });
                          },
                          child: SizedBox(
                            height: 50,
                            child: Row(
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle),
                                  child: Image.asset(
                                    contactIcon,
                                    width: 40,
                                    height: 40,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Add Recipent',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          1.5,
                                      child: AutoSizeText(
                                        _bccController.text.toString(),
                                        maxLines: 3,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
                widget.forwardbool == true
                    ? const SizedBox()
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          focusNode: _subjectFocusNode,
                          controller: _subjectController,
                          onTap: () {
                            setState(() {
                              showBcc = false;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Subject',
                          ),
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    focusNode: _bodyFocusNode,
                    controller: _bodyController,
                    onTap: () {
                      setState(() {
                        showBcc = false;
                      });
                    },
                    maxLines: null,
                    //expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                        hintText: 'Compose email', border: InputBorder.none),
                  ),
                ),
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(
                      children: <Widget>[
                        for (var i = 0; i < attachments.length; i++)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Expanded(
                                  flex: 0,
                                  child: Container(
                                      margin: const EdgeInsets.all(10),
                                      width: 100,
                                      height: 100,
                                      child: path
                                                  .extension(attachments[i])
                                                  .replaceAll('.', '') ==
                                              'jpg'
                                          ? Image.file(File(attachments[i]),
                                              fit: BoxFit.cover)
                                          : path
                                                      .extension(attachments[i])
                                                      .replaceAll('.', '') ==
                                                  'jpeg'
                                              ? Image.file(File(attachments[i]),
                                                  fit: BoxFit.cover)
                                              : path.extension(attachments[i]).replaceAll('.', '') ==
                                                      'png'
                                                  ? Image.file(
                                                      File(attachments[i]),
                                                      fit: BoxFit.cover)
                                                  : path.extension(attachments[i]).replaceAll('.', '') ==
                                                          'pdf'
                                                      ? Image.asset(pdfIcon,
                                                          fit: BoxFit.cover)
                                                      : path
                                                                  .extension(attachments[i])
                                                                  .replaceAll('.', '') ==
                                                              'json'
                                                          ? Image.asset(json, fit: BoxFit.cover)
                                                          : path.extension(attachments[i]).replaceAll('.', '') == 'mp3'
                                                              ? Image.asset(mp3, fit: BoxFit.cover)
                                                              : path.extension(attachments[i]).replaceAll('.', '') == 'text'
                                                                  ? Image.asset(text, fit: BoxFit.cover)
                                                                  : Image.asset(docIcon, fit: BoxFit.cover))),
                              IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: () {
                                  print(path
                                      .extension(attachments[i])
                                      .replaceAll('.', ''));
                                  _removeAttachment(i);
                                },
                              )
                            ],
                          ),
                        /*  Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                                icon: Icon(Icons.attach_file),
                                onPressed: () {
                                  _openImagePicker(ImageSource.gallery);
                                }),
                          ),*/
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openFilePicker() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'pdf',
        'json',
        'mp3',
        'text',
        'mp4',
        'avi',
        'mkv',
        'ppt',
        'zip',
        'rar',
        'xlsx',
        'xls',
        'xlsm',
        'doc',
        'docx'
      ],
    ) as FilePickerResult;

    List<File> files = result.paths.map((path) => File(path!)).toList();

    setState(() {
      attachments.addAll(files.map((file) => file.path).toList());
      fileData.addAll(files);
    });
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
      attachments.removeAt(index);
      fileData.removeAt(index);
    });
  }

  void _replayMail(contexts) {
    print(
        '_________________________________________________________________------------------------------');
    print(_bodyController.text);
    print(widget.replayEmail);
    print(
        '_________________________________________________________________------------------------------');
    var mailP = Provider.of<EmailProvider>(contexts, listen: false);
    mailP.sendMail(
        widget.replayEmail, _bodyController.text + widget.replayBody, context,
        ccMail: '',
        bccMail: '',
        subject: _subjectController.text,
        attachment: fileData);

    print('response of mail');
  }

  void _sendMail(contexts) {
    if (_tochips.isNotEmpty) {
      print(_bodyController.text);
      var mailP = Provider.of<EmailProvider>(contexts, listen: false);
      mailP.sendMail(_tochips.join(','), _bodyController.text, context,
          ccMail: _ccchips.join(','),
          bccMail: _bccchips.join(','),
          subject: _subjectController.text,
          attachment: fileData);
      print('____________________dcfgvbhjn___________________________________');
      print(_bccchips.join(','));
    } else {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: const Text('Add To Mail.'),
                content: TextButton(
                    onPressed: (() {
                      Navigator.pop(context);
                    }),
                    child: const Text('OK')),
              ));
    }

    // if (_fromController.text != null ||
    //     _tochips != null ||
    //     _bodyController.text != null) {
    //   if (expr.hasMatch(_fromController.text) || expr.hasMatch(_tochips[1])) {
    //     mailP.sendMail(_fromController.text, _tochips.join(","),
    //         _bodyController.text, context,
    //         ccMail: _ccController.text,
    //         bccMail: _bccController.text,
    //         subject: _subjectController.text,
    //         attachment: fileData);
    //   } else {
    //     showDialog(
    //         context: context,
    //         builder: (_) => AlertDialog(
    //               title: Text('Error'),
    //               content: Text('Email is not valid'),
    //             ));
    //   }
    // } else {
    //   showDialog(
    //       context: context,
    //       builder: (_) => AlertDialog(
    //             title: Text('Error'),
    //             content: Text('From , to and body required'),
    //           ));
    // }

    print('Send Email');
    // print(mailP.resMessage);
  }

  void _ForwardMail(contexts) {
    if (_tochips.isNotEmpty) {
      print(_bodyController.text);
      var mailP = Provider.of<EmailProvider>(contexts, listen: false);
      mailP.sendMail(
          _tochips.join(','), _bodyController.text + widget.replayBody, context,
          ccMail: _ccchips.join(','),
          bccMail: _bccchips.join(','),
          subject: '',
          attachment: fileData);
      print('____________________dcfgvbhjn___________________________________');
      print(_bccchips.join(','));
    } else {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: const Text('Add To Mail.'),
                content: TextButton(
                    onPressed: (() {
                      Navigator.pop(context);
                    }),
                    child: const Text('OK')),
              ));
    }

    print('Forward Email');
    // print(mailP.resMessage);
  }
}
