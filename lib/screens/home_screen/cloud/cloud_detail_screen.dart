import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/CloudProvider/cloud_provider.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/bottomSection.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/topSection.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../../Widgets/ExpandableFabClass.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:smart_station/screens/home_screen/chat/widget/image_section.dart';

class CloudDetailScreen extends StatefulWidget {
  // const CloudDetailScreen({Key? key}) : super(key: key);
  String phonenumber;
  String parentId;
  late final Function() onPressed;
  late final String tooltip;
  late final IconData icon;

  CloudDetailScreen(
      {Key? key, required this.phonenumber, required this.parentId})
      : super(key: key);

  @override
  State<CloudDetailScreen> createState() => _CloudDetailScreenState();
}

class _CloudDetailScreenState extends State<CloudDetailScreen>
    with TickerProviderStateMixin {
  // final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  late TabController _tabController;
  final TextEditingController _nameController = TextEditingController();
  final int _currVal = 1;
  final String _currText = '';
  String folderName = '';
  //int _selectedOption = 1;
  int _selectedOption = 0;
  List<String> imageType = ['jpg', 'jpeg', 'png', 'image'];
  //List<List<dynamic>> subCloudSentData = [];
  // List<List<dynamic>> subCloudData = [];
  List<List<dynamic>> subCloudSendData = [];
  List<List<dynamic>> subCloudReceiveData = [];

  void _updateSelectedOption(int value) {
    setState(() {
      _selectedOption = value;
    });
  }

  void onSelectionChanged(int value) {
    setState(() {
      _selectedOption = value;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    print('fd');

    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    var cloud = Provider.of<CloudProvider>(context, listen: false);
    cloud.getCloudSublist(widget.parentId, context);

    print(cloud.sendData.length);
    print('fdd');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    setState(() {
      // do something when the selected tab changes
      print('Selected tab: ${_tabController.index}');
      if (_tabController.index == 1) {
        if (subCloudSendData.isEmpty) {
          folderName = widget.phonenumber;
        } else {
          folderName = subCloudSendData.last[1];
        }
      } else {
        if (subCloudReceiveData.isEmpty) {
          folderName = widget.phonenumber;
        } else {
          folderName = subCloudReceiveData.last[1];
        }
        //folderName = subCloudReceiveData.last[1];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int activeTabIndex = DefaultTabController.of(context).index;
    return Consumer<CloudProvider>(
      builder: (context, cloud, child) {
        return Scaffold(
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
                left: 0,
                right: 20,
                child: Row(
                  children: [
                    // BackButton(color: Colors.white),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        print('back');
                        if (_tabController.index == 1) {
                          if (subCloudSendData.length > 1) {
                            subCloudSendData.removeLast();
                            print(' print(subCloudSendData.last[0]);');
                            print(subCloudSendData.last[0]);

                            setState(() {
                              folderName = subCloudSendData.last[1];
                              subCloudSendData.isEmpty
                                  ? cloud.getCloudSublist(
                                      widget.parentId, context)
                                  : cloud.getSubCloudSubList(
                                      subCloudSendData.last[0],
                                      'sent',
                                      context);
                            });
                          } else if (subCloudSendData.length == 1) {
                            setState(() {
                              cloud.getCloudSublist(widget.parentId, context);
                              subCloudSendData.removeLast();
                            });
                          } else {
                            Navigator.pop(context);
                          }
                        } else {
                          if (subCloudReceiveData.length > 1) {
                            subCloudReceiveData.removeLast();
                            print(' print(subCloudReceiveData.last[0]);');
                            print(subCloudReceiveData.last[0]);

                            setState(() {
                              folderName = subCloudReceiveData.last[1];
                              subCloudReceiveData.isEmpty
                                  ? cloud.getCloudSublist(
                                      widget.parentId, context)
                                  : cloud.getSubCloudSubList(
                                      subCloudReceiveData.last[0],
                                      'receive',
                                      context);
                            });
                          } else if (subCloudReceiveData.length == 1) {
                            setState(() {
                              cloud.getCloudSublist(widget.parentId, context);
                              subCloudReceiveData.removeLast();
                            });
                          } else {
                            Navigator.pop(context);
                          }
                        }
                      },
                    ),
                    _tabController.index == 1
                        ? Text(
                            subCloudSendData.isNotEmpty
                                ? folderName
                                : widget.phonenumber,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ))
                        : Text(
                            subCloudReceiveData.isNotEmpty
                                ? folderName
                                : widget.phonenumber,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            )),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 100.0, left: 00, right: 00),
                child: DefaultTabController(
                  length: 2,
                  child: Scaffold(
                    body: Column(
                      children: <Widget>[
                        // construct the profile details widget here

                        // the tab bar with two items
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: SizedBox(
                            height: 80,
                            child: AppBar(
                              // backgroundColor: const Color(0xFF0099a9),
                              backgroundColor: Colors.white10,
                              bottom: TabBar(
                                controller: _tabController,
                                indicatorColor: Colors.white,
                                tabs: const [
                                  Tab(
                                    // icon: Icon(Icons.directions_bike),
                                    text: 'Received',
                                  ),
                                  Tab(
                                    /* icon: Icon(Icons.directions_car,
 ),*/
                                    text: 'Sent',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // create widgets for each tab bar here
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // first tab bar view widget
                              Container(
                                  child: GridView.builder(
                                itemCount: cloud.receiveData.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: .8,
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 30,
                                ),
                                itemBuilder: (context, index) {
                                  if (cloud.receiveData[index]['file_type'] ==
                                      'folder') {
                                    return Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            List<dynamic> newItem = [
                                              cloud.receiveData[index]['id'],
                                              cloud.receiveData[index]['name']
                                            ];
                                            subCloudReceiveData.add(newItem);

                                            // var cloudR = Provider.of<CloudProvider>(context,listen: false);
                                            setState(() {
                                              folderName =
                                                  subCloudReceiveData.last[1];
                                              cloud.getSubCloudSubList(
                                                  subCloudReceiveData.last[0],
                                                  'receive',
                                                  context);
                                            });
                                            /* setState(() {
 //cloud.getSubCloudSubList(widget.parentId,"receive",context);
 });*/
                                          },
                                          child: Container(
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Image.asset(folderIcon)),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),

                                        // Text(cloud.sendData[index]['name']),
                                        Flexible(
                                          child: Container(
                                            // padding: new EdgeInsets.only(right: 13.0),
                                            child: Text(
                                              cloud.receiveData[index]['name'],
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12.0,
                                                // fontFamily: 'Roboto',
                                                //color: new Color(0xFF212121),
                                                //fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return (imageType.contains(cloud
                                            .receiveData[index]['file_type']))
                                        ? InkWell(
                                            onTap: () {
                                              Get.to(
                                                  () => ImageSection(
                                                      imageUrl: cloud
                                                              .receiveData[
                                                          index]['file_path']),
                                                  transition: Transition.zoom);
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //     builder: (context) => ImageView(imageUrl: "https://creativeapplab.in/smartstation/api/uploads/profile/image15.png"),
                                              //   ),
                                              // );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                          cloud.receiveData[
                                                                  index]
                                                              ['file_path']
                                                          // file_path
                                                          ),
                                                      //image:AssetImage(pdfIcon),
                                                      fit: BoxFit.cover)),
                                            ),
                                          )
                                        : InkWell(
                                            onTap: () {
                                              /* SfPdfViewer.network(
                                              cloud.receiveData[index]["file_path"],
                                              key: _pdfViewerKey,
                                            );*/
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      /*image: NetworkImage(
 "https://images.unsplash.com/photo-1579202673506-ca3ce28943ef"
 ),*/
                                                      image:
                                                          AssetImage(pdfIcon),
                                                      fit: BoxFit.cover)),
                                            ),
                                          );
                                  }
                                },
                              )),

                              // second tab bar viiew widget
                              Scaffold(
                                body: Container(
                                  child: GridView.builder(
                                    itemCount: cloud.sendData.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: .8,
                                      crossAxisSpacing: 15,
                                      mainAxisSpacing: 30,
                                    ),
                                    itemBuilder: (context, index) {
                                      if (cloud.sendData[index]['file_type'] ==
                                          'folder') {
                                        return Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                print('sujina2');
                                                List<dynamic> newItem = [
                                                  cloud.sendData[index]['id'],
                                                  cloud.sendData[index]['name']
                                                ];
                                                print('newitem');
                                                print(newItem);
                                                subCloudSendData.add(newItem);
                                                var cloudR =
                                                    Provider.of<CloudProvider>(
                                                        context,
                                                        listen: false);

                                                setState(() {
                                                  print(_tabController.index);
                                                  print('foldername');
                                                  folderName =
                                                      subCloudSendData.last[1];
                                                  print(folderName);
                                                  cloud.getSubCloudSubList(
                                                      subCloudSendData.last[0],
                                                      'sent',
                                                      context);
                                                });
                                              },
                                              child: Container(
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child:
                                                      Image.asset(folderIcon)),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),

                                            // Text(cloud.sendData[index]['name']),
                                            Flexible(
                                              child: Container(
                                                // padding: new EdgeInsets.only(right: 13.0),
                                                child: Text(
                                                  cloud.sendData[index]['name'],
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 12.0,
                                                    // fontFamily: 'Roboto',
                                                    //color: new Color(0xFF212121),
                                                    //fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      } else {
                                        return (imageType.contains(cloud
                                                .sendData[index]['file_type']))
                                            ? Container(
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: NetworkImage(
                                                            cloud.sendData[
                                                                    index]
                                                                ['file_path']
                                                            // file_path
                                                            ),
                                                        //image:AssetImage(pdfIcon),
                                                        fit: BoxFit.cover)),
                                              )
                                            : Container(
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        /*image: NetworkImage(
 "https://images.unsplash.com/photo-1579202673506-ca3ce28943ef"
 ),*/
                                                        image:
                                                            AssetImage(pdfIcon),
                                                        fit: BoxFit.cover)),
                                              );
                                      }
                                    },
                                  ),
                                ),
                                floatingActionButton: ExpandableFabClass(
                                  distanceBetween: 80.0,
                                  subChildren: [
                                    ActionButton(
                                      label: 'Upload Folder ',
                                      onPressed: () {
                                        showModalBottomSheet<void>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            if (subCloudSendData.isNotEmpty) {
                                              return BottomSheetRadioList(
                                                  folderId:
                                                      subCloudSendData.last[0],
                                                  type: 'subparent_folder_id');
                                            } else {
                                              return BottomSheetRadioList(
                                                folderId: widget.parentId,
                                                type: 'parent_folder_id',
                                              );
                                            }
                                          },
                                        );
                                      },
                                      icon: const Icon(Icons.folder),
                                    ),
                                    ActionButton(
                                      label: 'Upload File ',
                                      onPressed: () {
                                        showModalBottomSheet<void>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            if (subCloudSendData.isNotEmpty) {
                                              return BottomSheetFileUpload(
                                                  folderId:
                                                      subCloudSendData.last[0],
                                                  type: 'subparent_folder_id');
                                            } else {
                                              return BottomSheetFileUpload(
                                                folderId: widget.parentId,
                                                type: 'parent_folder_id',
                                              );
                                            }
                                            //return BottomSheetFileUpload(folderId:widget.parentId);
                                          },
                                        );
                                      },
                                      icon: const Icon(Icons.file_open_sharp),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
      },
    );
  }
}

class BottomSheetRadioList extends StatefulWidget {
  final String folderId;
  final String type;
  const BottomSheetRadioList(
      {Key? key, required this.folderId, required this.type})
      : super(key: key);
  @override
  _BottomSheetRadioListState createState() => _BottomSheetRadioListState();
}

class _BottomSheetRadioListState extends State<BottomSheetRadioList> {
  int _selectedOption = 0;
  String _selectedOption2 = 'hourly';
  int _selectedOption1 = 1;
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: SizedBox(
          height: 400,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                  child: Container(
                    height: 70.0,
                    width: 180.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(folderIcon),
                        fit: BoxFit.scaleDown,
                      ),
                      borderRadius: BorderRadius.circular(80.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: SizedBox(
                    height: 50,
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        fillColor: Colors.grey[100],
                        filled: true,
                        hintText: 'Folder name',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                    height: 40,
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        'Access Type',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    )),
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: RadioListTile(
                            title: const Text('Unlimited View'),
                            value: 0,
                            groupValue: _selectedOption,
                            onChanged: (value) {
                              setState(() {
                                _selectedOption = 0;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile(
                            title: const Text('Limited View'),
                            value: 1,
                            groupValue: _selectedOption,
                            onChanged: (value) {
                              setState(() {
                                _selectedOption = 1;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _selectedOption == 1
                        ? Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: DropdownButton<int>(
                                    value: _selectedOption1,
                                    items: List.generate(100, (index) {
                                      return DropdownMenuItem(
                                        value: index + 1,
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                      );
                                    }),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedOption1 = value!;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                //access_period 1- hourly 2- days 3- months 4- year 5- life_time
                                Expanded(
                                  child: DropdownButton(
                                    value: _selectedOption2,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'hourly',
                                        child: Text('Hour(s)'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'days',
                                        child: Text('Day(s)'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'months',
                                        child: Text('Month(s)'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'year',
                                        child: Text('Year(s)'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedOption2 = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const Text(''),
                    SizedBox(
                      width: 120,
                      height: 40,
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
                          child: InkWell(
                            onTap: () {
                              print(_nameController.text);
                              print(_selectedOption);
                              print(_selectedOption1);
                              print(_selectedOption2);
                              print(widget.folderId);
                              String period = '';
                              _selectedOption == 0
                                  ? period = 'life_time'
                                  : period = _selectedOption2;
                              String folderId = widget.folderId;

                              var cloud = Provider.of<CloudProvider>(context,
                                  listen: false);
                              cloud.createSubFolder(
                                  widget.folderId,
                                  _nameController.text,
                                  period,
                                  _selectedOption1.toString(),
                                  widget.type,
                                  '',
                                  context);
                            },
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
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
      ),
    );
  }
}

class BottomSheetFileUpload extends StatefulWidget {
  final String folderId;
  final String type;
  const BottomSheetFileUpload(
      {Key? key, required this.folderId, required this.type})
      : super(key: key);
  @override
  _BottomSheetFileUploadState createState() => _BottomSheetFileUploadState();
}

class _BottomSheetFileUploadState extends State<BottomSheetFileUpload> {
  int _selectedOption = 0;
  String _selectedOption2 = 'hourly';
  int _selectedOption1 = 1;
  final TextEditingController _nameController = TextEditingController();
  File? _file;
  String? _type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: SizedBox(
          height: 400,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 20),
                InkWell(
                  onTap: () async {
                    print('TEST');
                    // getFooterPic();
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      // multiple: false,
                      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
                    );
                    if (result != null && result.files.isNotEmpty) {
                      setState(() {
                        String type = result.files.first.extension.toString();
                        _file = File(result.files.first.path!);
                        _type = type;
                        print(type);
                        if (type == 'pdf') {
                        } else {}
                      });

                      // Use the selected file
                    }
                  },
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(12),
                    dashPattern: const [8, 4],
                    strokeWidth: 2,
                    color: Colors.black87,
                    child: _file != null && _type != 'pdf'
                        ? Image.file(
                            _file!,
                            height: 150,
                            width: 330,
                            fit: BoxFit.contain,
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 100, vertical: 50),
                            child: _file != null && _type == 'pdf'
                                ? Container(
                                    height: 60,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Image(image: AssetImage(pdfIcon)),
                                  )
                                : const Text('UPLOAD')),
                  ),
                ),
                const SizedBox(
                    height: 40,
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        'Access Type',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    )),
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: RadioListTile(
                            title: const Text('Unlimited View'),
                            value: 0,
                            groupValue: _selectedOption,
                            onChanged: (value) {
                              setState(() {
                                _selectedOption = 0;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile(
                            title: const Text('Limited View'),
                            value: 1,
                            groupValue: _selectedOption,
                            onChanged: (value) {
                              setState(() {
                                _selectedOption = 1;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _selectedOption == 1
                        ? Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: DropdownButton<int>(
                                    value: _selectedOption1,
                                    items: List.generate(100, (index) {
                                      return DropdownMenuItem(
                                        value: index + 1,
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                      );
                                    }),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedOption1 = value!;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                //access_period 1- hourly 2- days 3- months 4- year 5- life_time
                                Expanded(
                                  child: DropdownButton(
                                    value: _selectedOption2,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'hourly',
                                        child: Text('Hour(s)'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'days',
                                        child: Text('Day(s)'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'months',
                                        child: Text('Month(s)'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'year',
                                        child: Text('Year(s)'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedOption2 = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const Text(''),
                    SizedBox(
                      width: 120,
                      height: 40,
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
                          child: InkWell(
                            onTap: () {
                              print(_nameController.text);
                              print(_selectedOption);
                              print(_selectedOption1);
                              print(_selectedOption2);
                              print(widget.folderId);
                              String period = '';
                              _selectedOption == 0
                                  ? period = 'life_time'
                                  : period = _selectedOption2;
                              var cloud = Provider.of<CloudProvider>(context,
                                  listen: false);
                              /* String? file_type,
 String? type,
 String? folderId,
 String? access_period,
 String? period_limit,
 File? ftr,*/

                              // {"user_id":"54","accessToken":"54","parent_folder_id":"1","file":"http:/localhost/api/uploads/cloud/551/testing","access_period":"life_time","period_limit":"","file_type":"image"}
                              cloud.uploadFile(
                                  _type,
                                  widget.type,
                                  widget.folderId,
                                  period,
                                  _selectedOption1.toString(),
                                  '',
                                  _file,
                                  context);
                            },
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
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
      ),
    );
  }
}
