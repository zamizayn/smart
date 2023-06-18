import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:smart_station/providers/CloudProvider/cloud_provider.dart';
import 'package:smart_station/screens/home_screen/cloud/imageview.dart';
import 'package:smart_station/screens/home_screen/cloud/pdfview.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/bottomSection.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/topSection.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../../Widgets/ExpandableFabClass.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:smart_station/screens/home_screen/chat/widget/image_section.dart';
import 'package:smart_station/screens/home_screen/letter/letter_pdf_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_compress/video_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:smart_station/screens/home_screen/chat/widget/audioPlaying.dart';
import 'package:smart_station/screens/home_screen/chat/widget/video_section.dart';
import 'package:smart_station/screens/home_screen/chat/widget/pdf_section.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class CloudTabScreen extends StatefulWidget {
  // const CloudDetailScreen({Key? key}) : super(key: key);
  String phonenumber;
  String parentId;
  late final Function() onPressed;
  late final String tooltip;
  late final IconData icon;

  CloudTabScreen({Key? key, required this.phonenumber, required this.parentId})
      : super(key: key);

  @override
  State<CloudTabScreen> createState() => _CloudTabScreenState();
}

class _CloudTabScreenState extends State<CloudTabScreen>
    with TickerProviderStateMixin {
  // final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final _searchController = TextEditingController();
  final TextEditingController _textEditingController = TextEditingController();
  var searchStatus = false;
  FocusNode focusNode = FocusNode();

  final _searchController2 = TextEditingController();
  final TextEditingController _textEditingController2 = TextEditingController();
  var searchStatus2 = false;
  FocusNode focusNode2 = FocusNode();


  late TabController _tabController;
  TextEditingController _nameController = TextEditingController();
  int _currVal = 1;
  String _currText = '';
  String folderName = '';
  //int _selectedOption = 1;
  int _selectedOption = 0;
  List<String> imageType = ['jpg', 'jpeg', 'png', 'image'];
  //List<List<dynamic>> subCloudSentData = [];
  // List<List<dynamic>> subCloudData = [];
  List<List<dynamic>> subCloudSendData = [];
  List<List<dynamic>> subCloudReceiveData = [];

  Future<void> openFile(String url) async {
    // String fileUrl = 'https://example.com/myfile.pdf';
    String fileUrl = url;
    // const fileUrl = 'https://creativeapplab.in/smartstation/api/uploads/cloud/5363/samplepptx4.pptx';
    if (await canLaunchUrl(Uri.parse(fileUrl))) {
      await launchUrl(Uri.parse(fileUrl));
    } else {
      throw 'Could not launch $fileUrl';
    }
  }

  Future<void> openFile2(String url) async {
    if (await launch(url)) {
      String fileName = url.split('/').last;
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      String filePath = '$tempPath/$fileName';
      Dio dio = Dio();
      await dio.download(url, filePath);
      if (await File(filePath).exists()) {
        String extension = "jpeg";
        // String extension = p.extension(filePath);
        String mimeType;
        switch (extension.toLowerCase()) {
          case '.jpg':
          case '.jpeg':
            mimeType = 'image/jpeg';
            break;
          case '.png':
            mimeType = 'image/png';
            break;
          case '.pdf':
            mimeType = 'application/pdf';
            break;
          default:
            mimeType = 'application/octet-stream';
        }
        await launch(
          filePath,
          // headers: <String, String>{'Content-type': mimeType},
        );
      } else {
        print('File not found: $filePath');
      }
    } else {
      print('Could not launch URL: $url');
    }
  }

  Future<String> _getLocalPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory!.path;
  }

  String notifiationName = "";
  var filePath;

  Future<void> checkPermissionAndDownloadFile(
      String url, String filename, context) async {
    filename = Uri.parse(url).pathSegments.last;
    print(url);
    notifiationName = filename;
    print(notifiationName);
    var status = await Permission.storage.status;
    print(status.isGranted);

    if (!status.isGranted) {
      status = await Permission.storage.request();
      print(status.isGranted);
    }
    if (status.isGranted) {
      print("granted");
      await downloadFile(url, filename, context);
      showNotification(notifiationName, 'Download complete');
      // Handle permission denied case
      return;
    }
  }

  Future<File> downloadFile(String url, String filename, context) async {
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;

    // var tempDir = await getApplicationDocumentsDirectory();
    if (Platform.isAndroid) {
      var tempDir = await getExternalStorageDirectory();
      File? file;
      if (tempDir != null) {
        //file = File("${tempDir.path}/$filename");
        final file = File('/storage/emulated/0/Download/$filename');
        // var tempDir1 = await getExternalStorageDirectory();
        var tempDir = Platform.isAndroid
            ? await getExternalStorageDirectory() //FOR ANDROID
            : await getApplicationDocumentsDirectory(); //FOR iOS
        // File file = File(tempDir!.path + filename);
        await file.writeAsBytes(bytes);
        String filePath = file.path;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded file to $filePath'),
          ),
        );
      } else {
        throw Exception('Failed to get temporary directory.');
      }
      return file!;
    } else {
      var tempDir = await getApplicationDocumentsDirectory();
      File? file;
      if (tempDir != null) {
        file = File("${tempDir.path}/$filename");
        await file.writeAsBytes(bytes);
        String filePath = file.path;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded file to $filePath'),
          ),
        );
      } else {
        throw Exception('Failed to get temporary directory.');
      }
      return file!;
    }
  }

  Future<File> downloadFile1(String url, String filename, context) async {
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;
    final file = File('/storage/emulated/0/Download/$filename');
    // var tempDir1 = await getExternalStorageDirectory();
    var tempDir = Platform.isAndroid
        ? await getExternalStorageDirectory() //FOR ANDROID
        : await getApplicationDocumentsDirectory(); //FOR iOS
    // File file = File(tempDir!.path + filename);
    await file.writeAsBytes(bytes);

    filePath = file.path;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloaded file to ${file.path}'),
      ),
    );
    return file;
  }

  // Future<void> checkPermissionAndDownloadFile(
  //     String url, String filename) async {
  //   filename = Uri.parse(url).pathSegments.last;
  //   notifiationName = filename;
  //   print(notifiationName);
  //   var status = await Permission.storage.status;
  //   if (!status.isGranted) {
  //     status = await Permission.storage.request();
  //     if (!status.isGranted) {
  //       // Handle permission denied case
  //       return;
  //     }
  //   }
  //   await downloadFiles(url, filename,context);
  // }
  //
  // Future<File> downloadFiles(String url, String filename, context) async {
  //   final response = await http.get(Uri.parse(url));
  //   final bytes = response.bodyBytes;
  //   final file = File('/storage/emulated/0/Download/$filename');
  //   await file.writeAsBytes(bytes);
  //   String filePath =file.path;
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('Downloaded file to ${file.path}'),
  //     ),
  //   );
  //   return file;
  // }

  // Future<File> downloadFiles(String url, String filename) async {
  //   var response = await http.get(Uri.parse(url));
  //   var bytes = response.bodyBytes;
  //   final downloadsDirectory = await DownloadsPathProvider.downloadsDirectory;
  //   String filePath = '${downloadsDirectory!.path}/$filename';
  //   print(filePath);
  //   File file = File(filePath);
  //   await file.writeAsBytes(bytes);
  //   return file;
  // }

  Future<void> showNotification(String title, String body) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 66,
        channelKey: 'downloaded_pdf',
        title: title,
        body: body,
      ),
    );
  }

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
    print("fd");
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    var cloud = Provider.of<CloudProvider>(context, listen: false);
    cloud.getCloudSublist(widget.parentId, context);

    print(cloud.filteredSent.length);
    print("fdd");
    print(cloud.filteredSent);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    setState(() {
      // do something when the selected tab changes
      print("Selected tabcloud: ${_tabController.index}");
      if (_tabController.index == 1) {
        if (subCloudSendData.length == 0) {
          folderName = widget.phonenumber;
        } else {
          folderName = subCloudSendData.last[1];
        }
      } else {
        if (subCloudReceiveData.length == 0) {
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
    TabBar _tabBar = TabBar(
      controller: _tabController,
      indicator: const BoxDecoration(color: Colors.black45),
      tabs: [
        const Tab(
          text: "Received",
        ),
        const Tab(
          text: "Sent",
        ),
      ],
    );
    return Consumer<CloudProvider>(
      builder: (context, cloud, child) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            //extendBodyBehindAppBar: false,
            resizeToAvoidBottomInset:false,
            appBar:
            //Commented on 3rd May
            // AppBar(
            //   elevation: 0,
            //   backgroundColor: Colors.black26,
            //   title: _tabController.index==1?
            //   Text(
            //       subCloudSendData.length>0? folderName:this.widget.phonenumber,
            //       style: TextStyle(
            //         fontSize: 18,
            //         fontWeight: FontWeight.w400,
            //         color: Colors.white,
            //       )
            //   ):
            //   Text(
            //       subCloudReceiveData.length>0? folderName:this.widget.phonenumber,
            //       style: TextStyle(
            //         fontSize: 18,
            //         fontWeight: FontWeight.w400,
            //         color: Colors.white,
            //       )),
            //   bottom: PreferredSize(
            //     preferredSize: _tabBar.preferredSize,
            //     child: Material(
            //       color: Colors.black45,
            //       child: _tabBar,
            //     ),
            //   ),
            // ),
            PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Container(
                color: Colors.black38, // Set the background color here
                child: SafeArea(
                  child: AppBar(
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        print("back");
                        if (_tabController.index == 1) {
                          if (subCloudSendData.length > 1) {
                            subCloudSendData.removeLast();
                            print(" print(subCloudSendData.last[0]);");
                            print(subCloudSendData.last[0]);

                            setState(() {
                              folderName = subCloudSendData.last[1];
                              subCloudSendData.length == 0
                                  ? cloud.getCloudSublist(
                                  widget.parentId, context)
                                  : cloud.getSubCloudSubList(
                                  subCloudSendData.last[0],
                                  "sent",
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
                            print(" print(subCloudReceiveData.last[0]);");
                            print(subCloudReceiveData.last[0]);

                            setState(() {
                              folderName = subCloudReceiveData.last[1];
                              subCloudReceiveData.length == 0
                                  ? cloud.getCloudSublist(
                                  widget.parentId, context)
                                  : cloud.getSubCloudSubList(
                                  subCloudReceiveData.last[0],
                                  "receive",
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
                    elevation: 0,
                    backgroundColor: Colors
                        .transparent, // Set the app bar background color as transparent
                    title: _tabController.index == 1
                        ?
                    // Text(
                    //         subCloudSendData.length > 0
                    //             ? folderName
                    //             : this.widget.phonenumber,
                    //         style: const TextStyle(
                    //           fontSize: 18,
                    //           fontWeight: FontWeight.w400,
                    //           color: Colors.white,
                    //         ))
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!searchStatus)
                          Text(
                            subCloudSendData.length > 0 ? folderName : widget.phonenumber,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),

                        if (searchStatus)
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                color: Colors.grey[200],
                              ),
                              child: TextField(
                                focusNode: focusNode,
                                controller: _textEditingController,
                                onChanged: (value) {
                                  // search(value);
                                  print("value");
                                  cloud.searchSendData(value);
                                  searchStatus = true;
                                },
                                textAlignVertical: TextAlignVertical.top,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Search...',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                ),
                              ),
                            ),
                          ),
                        IconButton(
                          iconSize: 25,
                          icon: Icon(
                            searchStatus ? Icons.close : Icons.search,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              searchStatus = !searchStatus;
                              _textEditingController.text = '';
                              if (searchStatus) {
                                focusNode.requestFocus();
                              } else {
                                //  search('');
                                cloud.searchSendData('');
                              }
                            });
                          },
                        ),
                      ],
                    )
                        :
                    // Text(
                    //         subCloudReceiveData.length > 0
                    //             ? folderName
                    //             : this.widget.phonenumber,
                    //         style: const TextStyle(
                    //           fontSize: 18,
                    //           fontWeight: FontWeight.w400,
                    //           color: Colors.white,
                    //         )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!searchStatus2)
                          Text(
                            subCloudReceiveData.length > 0 ? folderName : widget.phonenumber,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),

                        if (searchStatus2)
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                color: Colors.grey[200],
                              ),
                              child: TextField(
                                focusNode: focusNode2,
                                controller: _textEditingController2,
                                onChanged: (value) {
                                  // search(value);
                                  print("value");
                                  cloud.searchReceivedData(value);
                                  searchStatus2 = true;
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Search...',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                ),
                              ),
                            ),
                          ),
                        IconButton(
                          iconSize: 25,
                          icon: Icon(
                            searchStatus2 ? Icons.close : Icons.search,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              searchStatus2 = !searchStatus2;
                              _textEditingController2.text = '';
                              if (searchStatus2) {
                                focusNode2.requestFocus();
                              } else {
                                //  search('');
                                cloud.searchReceivedData('');
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    bottom: PreferredSize(
                      preferredSize: _tabBar.preferredSize,
                      child: Material(
                        color: Colors.black45,
                        child: _tabBar,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            body: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(splashBg),
                    fit: BoxFit.cover,
                  )),
              child: TabBarView(
                controller: _tabController,
                children: [
                  Container(
                      child: cloud.filteredReceived.isNotEmpty
                          ? Column(
                        children: [
                          // Container(
                          //   height: 50,
                          //   width: MediaQuery.of(context).size.width,
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(20.0),
                          //     color: Colors.grey[200],
                          //   ),
                          //   child: TextField(
                          //     // controller: _textEditingController,
                          //     onChanged: (value) {
                          //       // search(value);
                          //       cloud.searchReceivedData(value);
                          //     },
                          //     decoration: const InputDecoration(
                          //       border: InputBorder.none,
                          //       hintText: 'Search...',
                          //       contentPadding: EdgeInsets.symmetric(
                          //           horizontal: 16.0),
                          //       // prefixIcon: Icon(Icons.search),
                          //     ),
                          //   ),
                          // ),
                          // SizedBox(
                          //   height: 20,
                          // ),
                          Expanded(
                            child: GridView.builder(
                              itemCount: cloud.filteredReceived.length,
                              gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1.1,
                                crossAxisSpacing: 55,
                                mainAxisSpacing: 20,
                              ),
                              itemBuilder: (context, index) {
                                DateFormat dateFormat =
                                DateFormat("yyyy-MM-dd HH:mm:ss");
                                DateFormat dateFormat2 =
                                DateFormat("dd/MM/yyyy hh:mm a");
                                DateFormat timeFormat =
                                DateFormat("hh:mm a");

                                DateTime dateTime = dateFormat.parse(
                                    cloud.receiveData[index]
                                    ["created_datetime"]);
                                DateTime expDateTime = dateFormat.parse(
                                    cloud.filteredReceived[index]
                                    ["end_datetime"]);
                                var createDate = dateFormat2
                                    .format(dateTime)
                                    .toLowerCase();
                                var expDate = "";
                                if (cloud.filteredReceived[index]
                                ["view_type"] !=
                                    "life_time") {
                                  expDate = "Exp: " +
                                      dateFormat2
                                          .format(expDateTime)
                                          .toLowerCase();
                                }

                                if (cloud.filteredReceived[index]
                                ["file_type"] ==
                                    "folder") {
                                  return Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          print("sujina");
                                          List<dynamic> newItem = [
                                            cloud.filteredReceived[index]
                                            ["id"],
                                            cloud.filteredReceived[index]
                                            ["name"]
                                          ];
                                          subCloudReceiveData
                                              .add(newItem);

                                          // var cloudR = Provider.of<CloudProvider>(context,listen: false);
                                          setState(() {
                                            folderName =
                                            subCloudReceiveData
                                                .last[1];
                                            cloud.getSubCloudSubList(
                                                subCloudReceiveData
                                                    .last[0],
                                                "receive",
                                                context);
                                          });
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  5)),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Container(
                                                  height: MediaQuery.of(
                                                      context)
                                                      .size
                                                      .width /
                                                      3 -
                                                      40,
                                                  child: Image.asset(
                                                      folderIcon)),
                                              Positioned(
                                                child: Text(
                                                  createDate,
                                                  textAlign:
                                                  TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 10.0,
                                                    // other text styles
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              child: Text(
                                                cloud.filteredReceived[
                                                index]['name'],
                                                textAlign:
                                                TextAlign.center,
                                                overflow:
                                                TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: const TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight:
                                                  FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment:
                                            Alignment.centerRight,
                                            child:
                                            PopupMenuButton<String>(
                                              itemBuilder:
                                                  (BuildContext context) {
                                                return <
                                                    PopupMenuEntry<
                                                        String>>[
                                                  PopupMenuItem<String>(
                                                    value: 'name',
                                                    child: Row(
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            cloud.filteredReceived[
                                                            index]
                                                            ["name"],
                                                            overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuItem<String>(
                                                    value: 'date',
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            const Icon(Icons
                                                                .calendar_month),
                                                            const SizedBox(
                                                                width: 8),
                                                            Text(
                                                                createDate),
                                                          ],
                                                        ),
                                                        (cloud.filteredReceived[
                                                        index]
                                                        [
                                                        "view_type"] !=
                                                            "life_time")
                                                            ? Row(
                                                          children: [
                                                            const Icon(
                                                                Icons
                                                                    .calendar_month,
                                                                color:
                                                                Colors.transparent),
                                                            const SizedBox(
                                                                width:
                                                                8),
                                                            Text(
                                                                expDate),
                                                          ],
                                                        )
                                                            : Row(
                                                          children: [
                                                            const Icon(
                                                                Icons
                                                                    .calendar_month,
                                                                color:
                                                                Colors.transparent),
                                                            const SizedBox(
                                                                width:
                                                                8),
                                                            const Text(
                                                                "Exp: Unlimited"),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuItem<String>(
                                                    value: 'download',
                                                    child: Row(
                                                      children: [
                                                        const Icon(Icons
                                                            .download),
                                                        const SizedBox(
                                                            width: 8),
                                                        const Text(
                                                            'Download'),
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuItem<String>(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                            Icons.delete),
                                                        const SizedBox(
                                                            width: 8),
                                                        const Text(
                                                            'Delete'),
                                                      ],
                                                    ),
                                                  ),
                                                ];
                                              },
                                              onSelected: (String value) {
                                                if (value == 'edit') {
                                                  // handle edit option here
                                                } else if (value ==
                                                    'download') {
                                                  print("ggggg");
                                                  checkPermissionAndDownloadFile(
                                                      cloud.filteredReceived[
                                                      index][
                                                      "file_path"],
                                                      cloud.filteredReceived[
                                                      index]
                                                      ["name"],
                                                      context)
                                                      .then((value) {
                                                    showNotification(
                                                        notifiationName,
                                                        "Download complete");
                                                  });
                                                } else if (value ==
                                                    'delete') {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                    context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            "Confirm Delete"),
                                                        content: const Text(
                                                            "Are you sure you want to delete this folder?"),
                                                        actions: [
                                                          TextButton(
                                                            child: const Text(
                                                                "Cancel"),
                                                            onPressed:
                                                                () {
                                                              Navigator.of(
                                                                  context)
                                                                  .pop();
                                                            },
                                                          ),
                                                          TextButton(
                                                            child: const Text(
                                                                "Delete"),
                                                            onPressed:
                                                                () {
                                                              // handle delete here
                                                              var parentFolderId =
                                                                  widget
                                                                      .parentId;
                                                              var typeId =
                                                                  "parent_folder_id";

                                                              if (!subCloudReceiveData
                                                                  .isEmpty) {
                                                                parentFolderId =
                                                                subCloudReceiveData
                                                                    .last[0];
                                                                typeId =
                                                                "subparent_folder_id";
                                                              }
                                                              print(cloud.receiveData[
                                                              index]
                                                              ["id"]);
                                                              print(
                                                                  parentFolderId);
                                                              print(
                                                                  typeId);
                                                              cloud.deleteSubfolder(
                                                                  parentFolderId,
                                                                  cloud.filteredReceived[index]
                                                                  [
                                                                  "id"],
                                                                  typeId,
                                                                  "receive",
                                                                  context);
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }
                                              },
                                              child: Container(
                                                padding:
                                                const EdgeInsets.all(
                                                    1),
                                                decoration:
                                                const BoxDecoration(
                                                  shape:
                                                  BoxShape.rectangle,
                                                  color:
                                                  Colors.transparent,
                                                ),
                                                child: const Center(
                                                  child: Icon(
                                                      Icons.more_vert,
                                                      color: Colors.green,
                                                      size: 20),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // const SizedBox(height: 5,),
                                      // Flexible(
                                      //   child: Container(
                                      //     child: Text(
                                      //       expDate,
                                      //       textAlign: TextAlign.center,
                                      //       overflow: TextOverflow.ellipsis,
                                      //       style: const TextStyle(
                                      //         fontSize: 10.0,
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  );
                                } else
                                  return (imageType.contains(
                                      cloud.receiveData[index]
                                      ["file_type"]))
                                      ? InkWell(
                                    onTap: () {
                                      var parentFolderId =
                                          widget.parentId;
                                      var typeId =
                                          "parent_folder_id";

                                      if (!subCloudReceiveData
                                          .isEmpty) {
                                        parentFolderId =
                                        subCloudReceiveData
                                            .last[0];
                                        typeId =
                                        "subparent_folder_id";
                                      }
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) => ImageView(imageUrl: cloud.filteredReceived[index]["file_path"],parent_folder_id:parentFolderId,file_id:cloud.filteredReceived[index]["id"],typeId: typeId,type:"receive",ctx:context),
                                      //   ),
                                      // );
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) => ImageSection(
                                                  imageUrl: cloud
                                                      .filteredReceived[
                                                  index][
                                                  "file_path"])));
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          height:
                                          MediaQuery.of(context)
                                              .size
                                              .width /
                                              3 -
                                              40,
                                          width: 100,
                                          decoration: BoxDecoration(
                                              image:
                                              DecorationImage(
                                                  image: NetworkImage(
                                                      cloud.filteredReceived[
                                                      index]
                                                      [
                                                      "file_path"]
                                                    // file_path
                                                  ),
                                                  //image:AssetImage(pdfIcon),
                                                  fit: BoxFit
                                                      .cover)),
                                        ),
                                        // if(expDate!="")
                                        //   Positioned(
                                        //     bottom: 10,
                                        //     // right: 5,
                                        //     child: Container(
                                        //       color: Colors.black.withOpacity(0.7),
                                        //       width: MediaQuery.of(context).size.width,
                                        //       padding: const EdgeInsets.only(left: 8,right: 8,top: 8,bottom: 8),
                                        //       child: Text(
                                        //         expDate,
                                        //         //textAlign: TextAlign.center,
                                        //         style: const TextStyle(color: Colors.white, fontSize: 10),
                                        //       ),
                                        //     ),
                                        //   ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                child: Text(
                                                  cloud.filteredReceived[
                                                  index]
                                                  ['name'],
                                                  textAlign:
                                                  TextAlign
                                                      .center,
                                                  overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                                  maxLines: 2,
                                                  style:
                                                  const TextStyle(
                                                    fontSize: 14.0,
                                                    fontWeight:
                                                    FontWeight
                                                        .normal,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment
                                                  .centerRight,
                                              child:
                                              PopupMenuButton<
                                                  String>(
                                                itemBuilder:
                                                    (BuildContext
                                                context) {
                                                  return <
                                                      PopupMenuEntry<
                                                          String>>[
                                                    PopupMenuItem<
                                                        String>(
                                                      value: 'name',
                                                      child: Row(
                                                        children: [
                                                          Flexible(
                                                            child:
                                                            Text(
                                                              cloud.filteredReceived[index]
                                                              [
                                                              "name"],
                                                              overflow:
                                                              TextOverflow.ellipsis,
                                                              maxLines:
                                                              2,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    PopupMenuItem<
                                                        String>(
                                                      value: 'date',
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                  Icons.calendar_month),
                                                              const SizedBox(
                                                                  width: 8),
                                                              Text(
                                                                  createDate),
                                                            ],
                                                          ),
                                                          (cloud.filteredReceived[index]["view_type"] !=
                                                              "life_time")
                                                              ? Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.calendar_month,
                                                                color: Colors.transparent,
                                                              ),
                                                              const SizedBox(width: 8),
                                                              Text(expDate),
                                                            ],
                                                          )
                                                              :
                                                          //SizedBox(height: 8,),
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.calendar_month,
                                                                color: Colors.transparent,
                                                              ),
                                                              const SizedBox(width: 8),
                                                              const Text("Exp: Unlimited"),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    PopupMenuItem<
                                                        String>(
                                                      value:
                                                      'download',
                                                      child: Row(
                                                        children: [
                                                          const Icon(
                                                              Icons
                                                                  .download),
                                                          const SizedBox(
                                                              width:
                                                              8),
                                                          const Text(
                                                              'Download'),
                                                        ],
                                                      ),
                                                    ),
                                                    PopupMenuItem<
                                                        String>(
                                                      value:
                                                      'delete',
                                                      child: Row(
                                                        children: [
                                                          const Icon(
                                                              Icons
                                                                  .delete),
                                                          const SizedBox(
                                                              width:
                                                              8),
                                                          const Text(
                                                              'Delete'),
                                                        ],
                                                      ),
                                                    ),
                                                  ];
                                                },
                                                onSelected:
                                                    (String value) {
                                                  if (value ==
                                                      'edit') {
                                                    // handle edit option here
                                                  } else if (value ==
                                                      'download') {
                                                    // print("downloadreceiveimage");
                                                    checkPermissionAndDownloadFile(
                                                        cloud.filteredReceived[index]
                                                        [
                                                        "file_path"],
                                                        cloud.filteredReceived[index]
                                                        [
                                                        "name"],
                                                        context)
                                                        .then(
                                                            (value) {
                                                          showNotification(
                                                              notifiationName,
                                                              "Download complete");
                                                        });
                                                  } else if (value ==
                                                      'delete') {
                                                    print("delete");
                                                    showDialog(
                                                      context:
                                                      context,
                                                      builder:
                                                          (BuildContext
                                                      context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              "Confirm Delete"),
                                                          content:
                                                          const Text(
                                                              "Are you sure you want to delete this file?"),
                                                          actions: [
                                                            TextButton(
                                                              child:
                                                              const Text("Cancel"),
                                                              onPressed:
                                                                  () {
                                                                Navigator.of(context).pop();
                                                              },
                                                            ),
                                                            TextButton(
                                                              child:
                                                              const Text("Delete"),
                                                              onPressed:
                                                                  () {
                                                                // handle delete here
                                                                var parentFolderId =
                                                                    widget.parentId;
                                                                var typeId =
                                                                    "parent_folder_id";

                                                                if (!subCloudReceiveData.isEmpty) {
                                                                  parentFolderId = subCloudReceiveData.last[0];
                                                                  typeId = "subparent_folder_id";
                                                                }
                                                                print(cloud.receiveData[index]["id"]);
                                                                print(parentFolderId);
                                                                print(typeId);
                                                                cloud.deleteCloudFile(
                                                                    parentFolderId,
                                                                    cloud.filteredReceived[index]["id"],
                                                                    typeId,
                                                                    "receive",
                                                                    context);
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }
                                                },
                                                child: Container(
                                                  padding:
                                                  const EdgeInsets
                                                      .all(1),
                                                  decoration:
                                                  const BoxDecoration(
                                                    shape: BoxShape
                                                        .rectangle,
                                                    color: Colors
                                                        .transparent,
                                                  ),
                                                  child:
                                                  const Center(
                                                    child: Icon(
                                                        Icons
                                                            .more_vert,
                                                        color: Colors
                                                            .green,
                                                        size: 20),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    /*Container(
                                                        decoration: BoxDecoration(
                                                            image: DecorationImage(
                                                                image: NetworkImage(
                                                                    cloud.filteredReceived[index]["file_path"]
                                                                  // file_path
                                                                ),
                                                                //image:AssetImage(pdfIcon),
                                                                fit: BoxFit.cover
                                                            )
                                                        ),
                                                      ),*/
                                  )
                                      : InkWell(
                                    onTap: () {
                                      var parentFolderId =
                                          widget.parentId;
                                      var typeId =
                                          "parent_folder_id";

                                      if (!subCloudReceiveData
                                          .isEmpty) {
                                        parentFolderId =
                                        subCloudReceiveData
                                            .last[0];
                                        typeId =
                                        "subparent_folder_id";
                                      }
                                      (cloud.filteredReceived[index]
                                      ["file_type"] ==
                                          "pdf")
                                          ?
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) => PdfView(pdfUrl: cloud.filteredReceived[index]["file_path"],parent_folder_id:parentFolderId,file_id:cloud.filteredReceived[index]["id"],typeId: typeId,type:"receive",ctx:context),
                                      //   ),
                                      // ):
                                      Navigator.of(context)
                                          .push(
                                          MaterialPageRoute(
                                              builder:
                                                  (_) =>
                                                  ChatPdfView(
                                                    pdf:
                                                    cloud.filteredReceived[index]["file_path"],
                                                    fileName:
                                                    cloud.receiveData[index]["name"],
                                                  )))
                                          : (cloud.filteredReceived[
                                      index][
                                      "file_type"] ==
                                          "mp3")
                                          ? Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  AudioPlayingScreen(
                                                      fPath: cloud.filteredReceived[index]["file_path"])))
                                          : (cloud.filteredReceived[index]["file_type"] == "mp4")
                                          ? Navigator.of(context).push(MaterialPageRoute(builder: (_) => VideoSection(videoUrl: cloud.filteredReceived[index]["file_path"])))
                                          :
                                      // Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatPdfView (pdf: cloud.filteredReceived[index]["file_path"],fileName:cloud.filteredReceived[index]["name"] ,)));
                                      openFile2(cloud.filteredReceived[index]["file_path"]);
                                      // _launchURL();
                                      //Navigator.of(context).push(MaterialPageRoute(builder: (_) => AudioPlayingScreen(fPath: cloud.filteredReceived[index]["file_path"])));
                                      // Navigator.push(context, MaterialPageRoute(builder: (context)=>LetterPdfView(pdf: cloud.filteredReceived[index]["file_path"])));
                                    },
                                    child: Column(
                                      children: [
                                        (cloud.filteredReceived[index]
                                        ["file_type"] ==
                                            "pdf")
                                            ? const Icon(
                                          Icons
                                              .picture_as_pdf,
                                          color: Colors.red,
                                          size: 100.0,
                                        )
                                            : (cloud.filteredReceived[
                                        index][
                                        "file_type"] ==
                                            "mp4")
                                            ? const Icon(
                                          Icons
                                              .video_file_rounded,
                                          color:
                                          Colors.red,
                                          size: 100.0,
                                        )
                                            : (cloud.filteredReceived[index]["file_type"] ==
                                            "mp3" ||
                                            cloud.filteredReceived[index]["file_type"] ==
                                                "m4a")
                                            ? Icon(
                                          Icons
                                              .audio_file_outlined,
                                          color: Colors
                                              .orange
                                              .shade600,
                                          size: 100.0,
                                        )
                                            : (cloud.filteredReceived[index]["file_type"] ==
                                            "pptx" ||
                                            cloud.filteredReceived[index]["file_type"] ==
                                                "ppt")
                                            ? Image.asset(
                                          pptIcon,
                                          fit: BoxFit
                                              .cover,
                                          height:
                                          100,
                                          width:
                                          100,
                                        )
                                            : (cloud.filteredReceived[index]["file_type"] == "docx" || cloud.filteredReceived[index]["file_type"] == "doc")
                                            ? Image.asset(
                                          documentIcon,
                                          fit:
                                          BoxFit.cover,
                                          height:
                                          100,
                                          width:
                                          100,
                                        )
                                            : Image.asset(
                                          docIcon,
                                          fit:
                                          BoxFit.cover,
                                          height:
                                          100,
                                          width:
                                          100,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            // String videoName = path.basenameWithoutExtension(widget.videoUrl);
                                            Expanded(
                                              child: Container(
                                                child: Text(
                                                  cloud.filteredReceived[
                                                  index]
                                                  ['name'],
                                                  textAlign:
                                                  TextAlign
                                                      .center,
                                                  overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                                  maxLines: 2,
                                                  style:
                                                  const TextStyle(
                                                    fontSize: 14.0,
                                                    fontWeight:
                                                    FontWeight
                                                        .normal,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment
                                                  .centerRight,
                                              child:
                                              PopupMenuButton<
                                                  String>(
                                                itemBuilder:
                                                    (BuildContext
                                                context) {
                                                  return <
                                                      PopupMenuEntry<
                                                          String>>[
                                                    PopupMenuItem<
                                                        String>(
                                                      value: 'name',
                                                      child: Row(
                                                        children: [
                                                          Flexible(
                                                            child:
                                                            Text(
                                                              cloud.filteredReceived[index]
                                                              [
                                                              "name"],
                                                              overflow:
                                                              TextOverflow.ellipsis,
                                                              maxLines:
                                                              2,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    PopupMenuItem<
                                                        String>(
                                                      value: 'date',
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                  Icons.calendar_month),
                                                              const SizedBox(
                                                                  width: 8),
                                                              Text(
                                                                  createDate),
                                                            ],
                                                          ),
                                                          (cloud.filteredReceived[index]["view_type"] !=
                                                              "life_time")
                                                              ? Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.calendar_month,
                                                                color: Colors.transparent,
                                                              ),
                                                              const SizedBox(width: 8),
                                                              Text(expDate),
                                                            ],
                                                          )
                                                              :
                                                          //SizedBox(height: 8,),
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.calendar_month,
                                                                color: Colors.transparent,
                                                              ),
                                                              const SizedBox(width: 8),
                                                              const Text("Exp: Unlimited"),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    PopupMenuItem<
                                                        String>(
                                                      value:
                                                      'download',
                                                      child: Row(
                                                        children: [
                                                          const Icon(
                                                              Icons
                                                                  .download),
                                                          const SizedBox(
                                                              width:
                                                              8),
                                                          const Text(
                                                              'Download'),
                                                        ],
                                                      ),
                                                    ),
                                                    PopupMenuItem<
                                                        String>(
                                                      value:
                                                      'delete',
                                                      child: Row(
                                                        children: [
                                                          const Icon(
                                                              Icons
                                                                  .delete),
                                                          const SizedBox(
                                                              width:
                                                              8),
                                                          const Text(
                                                              'Delete'),
                                                        ],
                                                      ),
                                                    ),
                                                  ];
                                                },
                                                onSelected:
                                                    (String value) {
                                                  if (value ==
                                                      'edit') {
                                                    // handle edit option here
                                                  } else if (value ==
                                                      'download') {
                                                    // print("downloadreceiveimage");
                                                    checkPermissionAndDownloadFile(
                                                        cloud.filteredReceived[index]
                                                        [
                                                        "file_path"],
                                                        cloud.filteredReceived[index]
                                                        [
                                                        "name"],
                                                        context)
                                                        .then(
                                                            (value) {
                                                          showNotification(
                                                              notifiationName,
                                                              "Download complete");
                                                        });
                                                  } else if (value ==
                                                      'delete') {
                                                    print("delete");
                                                    showDialog(
                                                      context:
                                                      context,
                                                      builder:
                                                          (BuildContext
                                                      context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              "Confirm Delete"),
                                                          content:
                                                          const Text(
                                                              "Are you sure you want to delete this file?"),
                                                          actions: [
                                                            TextButton(
                                                              child:
                                                              const Text("Cancel"),
                                                              onPressed:
                                                                  () {
                                                                Navigator.of(context).pop();
                                                              },
                                                            ),
                                                            TextButton(
                                                              child:
                                                              const Text("Delete"),
                                                              onPressed:
                                                                  () {
                                                                // handle delete here
                                                                var parentFolderId =
                                                                    widget.parentId;
                                                                var typeId =
                                                                    "parent_folder_id";

                                                                if (!subCloudReceiveData.isEmpty) {
                                                                  parentFolderId = subCloudReceiveData.last[0];
                                                                  typeId = "subparent_folder_id";
                                                                }
                                                                print(cloud.receiveData[index]["id"]);
                                                                print(parentFolderId);
                                                                print(typeId);
                                                                cloud.deleteCloudFile(
                                                                    parentFolderId,
                                                                    cloud.filteredReceived[index]["id"],
                                                                    typeId,
                                                                    "receive",
                                                                    context);
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }
                                                },
                                                child: Container(
                                                  padding:
                                                  const EdgeInsets
                                                      .all(1),
                                                  decoration:
                                                  const BoxDecoration(
                                                    shape: BoxShape
                                                        .rectangle,
                                                    color: Colors
                                                        .transparent,
                                                  ),
                                                  child:
                                                  const Center(
                                                    child: Icon(
                                                        Icons
                                                            .more_vert,
                                                        color: Colors
                                                            .green,
                                                        size: 20),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                              },
                            ),
                          ),
                        ],
                      )
                          : const Center(
                        child: Text(
                          'No File',
                          style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                      )),
                  Scaffold(
                    resizeToAvoidBottomInset: false,
                    body: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(splashBg),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: cloud.filteredSent.isEmpty
                          ? const Center(
                        child: Text(
                          'No File',
                          style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                      )
                          :
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Container(
                          //   height: 50,
                          //   width: MediaQuery.of(context).size.width,
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(20.0),
                          //     color: Colors.grey[200],
                          //   ),
                          //   child: TextField(
                          //     // controller: _textEditingController,
                          //     onChanged: (value) {
                          //       // search(value);
                          //       cloud.searchSendData(value);
                          //     },
                          //     decoration: const InputDecoration(
                          //       border: InputBorder.none,
                          //       hintText: 'Search...',
                          //       contentPadding: EdgeInsets.symmetric(
                          //           horizontal: 16.0),
                          //       // prefixIcon: Icon(Icons.search),
                          //     ),
                          //   ),
                          // ),
                          // SizedBox(
                          //   height: 20,
                          // ),
                          Expanded(
                            child: GridView.builder(
                              itemCount: cloud.filteredSent.length,
                              gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1.1,
                                crossAxisSpacing: 55,
                                mainAxisSpacing: 20,
                              ),
                              itemBuilder: (context, index) {
                                DateFormat dateFormat =
                                DateFormat("yyyy-MM-dd HH:mm:ss");
                                DateFormat dateFormat2 =
                                DateFormat("dd/MM/yyyy hh:mm a");
                                DateFormat timeFormat =
                                DateFormat("hh:mm a");

                                DateTime dateTime = dateFormat.parse(
                                    cloud.filteredSent[index]
                                    ["created_datetime"]);
                                DateTime expDateTime = dateFormat.parse(
                                    cloud.filteredSent[index]
                                    ["end_datetime"]);
                                var createDate = dateFormat2
                                    .format(dateTime)
                                    .toLowerCase();
                                var expDate = "";
                                if (cloud.filteredSent[index]
                                ["view_type"] !=
                                    "life_time") {
                                  expDate = "Exp: " +
                                      dateFormat2
                                          .format(expDateTime)
                                          .toLowerCase();
                                }

                                if (cloud.filteredSent[index]
                                ["file_type"] ==
                                    "folder") {
                                  return Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          print("sujina2");
                                          List<dynamic> newItem = [
                                            cloud.filteredSent[index]
                                            ["id"],
                                            cloud.filteredSent[index]
                                            ["name"],
                                            cloud.filteredSent[index]
                                            ["end_datetime"]
                                          ];
                                          print("newitem");
                                          print(newItem);

                                          print(cloud.filteredSent[index]
                                          ["end_datetime"]);

                                          subCloudSendData.add(newItem);
                                          var cloudR =
                                          Provider.of<CloudProvider>(
                                              context,
                                              listen: false);

                                          setState(() {
                                            print(_tabController.index);
                                            print("foldername");
                                            folderName =
                                            subCloudSendData.last[1];
                                            print(folderName);
                                            cloud.getSubCloudSubList(
                                                subCloudSendData.last[0],
                                                "sent",
                                                context);
                                          });
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  5)),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Container(
                                                  height: MediaQuery.of(
                                                      context)
                                                      .size
                                                      .width /
                                                      3 -
                                                      40,
                                                  child: Image.asset(
                                                      folderIcon)),
                                              Positioned(
                                                child: Text(
                                                  createDate,
                                                  textAlign:
                                                  TextAlign.center,
                                                  style: const TextStyle(
                                                      fontSize: 10.0
                                                    // other text styles
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      // Text(cloud.filteredSent[index]['name']),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              child: Text(
                                                cloud.filteredSent[index]
                                                ['name'],
                                                textAlign:
                                                TextAlign.center,
                                                overflow:
                                                TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: const TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight:
                                                  FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment:
                                            Alignment.centerRight,
                                            child:
                                            PopupMenuButton<String>(
                                              itemBuilder:
                                                  (BuildContext context) {
                                                return <
                                                    PopupMenuEntry<
                                                        String>>[
                                                  PopupMenuItem<String>(
                                                    value: 'name',
                                                    child: Row(
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            cloud.filteredSent[
                                                            index]
                                                            ["name"],
                                                            overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuItem<String>(
                                                    value: 'date',
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            const Icon(Icons
                                                                .calendar_month),
                                                            const SizedBox(
                                                                width: 8),
                                                            Text(
                                                                createDate),
                                                          ],
                                                        ),
                                                        (cloud.filteredSent[
                                                        index]
                                                        [
                                                        "view_type"] !=
                                                            "life_time")
                                                            ? Row(
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .calendar_month,
                                                              color:
                                                              Colors.transparent,
                                                            ),
                                                            const SizedBox(
                                                                width:
                                                                8),
                                                            Text(
                                                                expDate),
                                                          ],
                                                        )
                                                            :
                                                        //SizedBox(height: 8,),
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .calendar_month,
                                                              color:
                                                              Colors.transparent,
                                                            ),
                                                            const SizedBox(
                                                                width:
                                                                8),
                                                            const Text(
                                                                "Exp: Unlimited"),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuItem<String>(
                                                    value: 'download',
                                                    child: Row(
                                                      children: [
                                                        const Icon(Icons
                                                            .download),
                                                        const SizedBox(
                                                            width: 8),
                                                        const Text(
                                                            'Download'),
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuItem<String>(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                            Icons.delete),
                                                        const SizedBox(
                                                            width: 8),
                                                        const Text(
                                                            'Delete'),
                                                      ],
                                                    ),
                                                  ),
                                                ];
                                              },
                                              onSelected: (String value) {
                                                if (value == 'edit') {
                                                  // handle edit option here
                                                } else if (value ==
                                                    'download') {
                                                  print("check");
                                                } else if (value ==
                                                    'delete') {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                    context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            "Confirm Delete"),
                                                        content: const Text(
                                                            "Are you sure you want to delete this folder?"),
                                                        actions: [
                                                          TextButton(
                                                            child: const Text(
                                                                "Cancel"),
                                                            onPressed:
                                                                () {
                                                              Navigator.of(
                                                                  context)
                                                                  .pop();
                                                            },
                                                          ),
                                                          TextButton(
                                                            child: const Text(
                                                                "Delete"),
                                                            onPressed:
                                                                () {
                                                              // handle delete here
                                                              var parentFolderId =
                                                                  widget
                                                                      .parentId;
                                                              var typeId =
                                                                  "parent_folder_id";

                                                              if (!subCloudSendData
                                                                  .isEmpty) {
                                                                parentFolderId =
                                                                subCloudSendData
                                                                    .last[0];
                                                                typeId =
                                                                "subparent_folder_id";
                                                              }
                                                              print(cloud.filteredSent[
                                                              index]
                                                              ["id"]);
                                                              print(
                                                                  parentFolderId);
                                                              print(
                                                                  typeId);
                                                              cloud.deleteSubfolder(
                                                                  parentFolderId,
                                                                  cloud.filteredSent[index]
                                                                  [
                                                                  "id"],
                                                                  typeId,
                                                                  "sent",
                                                                  context);
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }
                                              },
                                              child: Container(
                                                padding:
                                                const EdgeInsets.all(
                                                    1),
                                                decoration:
                                                const BoxDecoration(
                                                  shape:
                                                  BoxShape.rectangle,
                                                  color:
                                                  Colors.transparent,
                                                ),
                                                child: const Center(
                                                  child: Icon(
                                                      Icons.more_vert,
                                                      color: Colors.green,
                                                      size: 20),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // const SizedBox(height: 5,),
                                      // Flexible(
                                      //   child: new Container(
                                      //     // padding: new EdgeInsets.only(right: 13.0),
                                      //     child: Text(
                                      //       expDate,
                                      //       textAlign: TextAlign.center,
                                      //       overflow: TextOverflow.ellipsis,
                                      //       style: const TextStyle(
                                      //         fontSize: 10.0,
                                      //         // fontFamily: 'Roboto',
                                      //         //color: new Color(0xFF212121),
                                      //         //fontWeight: FontWeight.bold,
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  );
                                } else
                                  return (imageType.contains(
                                      cloud.filteredSent[index]
                                      ["file_type"]))
                                      ? InkWell(
                                    onTap: () {
                                      var parentFolderId =
                                          widget.parentId;
                                      var typeId =
                                          "parent_folder_id";

                                      if (!subCloudSendData
                                          .isEmpty) {
                                        parentFolderId =
                                        subCloudSendData
                                            .last[0];
                                        typeId =
                                        "subparent_folder_id";
                                      }
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) => ImageView(imageUrl: cloud.filteredSent[index]["file_path"],parent_folder_id:parentFolderId,file_id:cloud.filteredSent[index]["id"],typeId: typeId,type:"sent",ctx:context),
                                      //   ),
                                      // );
                                      //sujith
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) => ImageSection(
                                                  imageUrl: cloud
                                                      .filteredSent[
                                                  index][
                                                  "file_path"])));
                                      //openFile2(cloud.filteredSent[index]["file_path"]);
                                      // downloadAndLaunchFile
                                      // openFile("/data/user/0/com.cal.smartstation/cache/IMG-20230419-WA00091.jpg");
                                      // downloadAndLaunchFile(cloud.filteredSent[index]["file_path"]);
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 100,
                                          width: 100,
                                          decoration: BoxDecoration(
                                              image:
                                              DecorationImage(
                                                  image: NetworkImage(
                                                      cloud.filteredSent[
                                                      index]
                                                      [
                                                      "file_path"]
                                                    // file_path
                                                  ),
                                                  //image:AssetImage(pdfIcon),
                                                  fit: BoxFit
                                                      .cover)),
                                        ),
                                        // if(expDate!="")
                                        //   Positioned(
                                        //     bottom: 10,
                                        //     // right: 5,
                                        //     child: Container(
                                        //       color: Colors.black.withOpacity(0.7),
                                        //       width: MediaQuery.of(context).size.width,
                                        //       padding: const EdgeInsets.only(left: 8,right: 8,top: 8,bottom: 8),
                                        //       child: Text(
                                        //         expDate,
                                        //         //textAlign: TextAlign.center,
                                        //         style: const TextStyle(color: Colors.white, fontSize: 10),
                                        //       ),
                                        //     ),
                                        //   ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                child: Text(
                                                  cloud.filteredSent[
                                                  index]
                                                  ['name'],
                                                  textAlign:
                                                  TextAlign
                                                      .center,
                                                  overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                                  maxLines: 2,
                                                  style:
                                                  const TextStyle(
                                                    fontSize: 14.0,
                                                    fontWeight:
                                                    FontWeight
                                                        .normal,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment
                                                  .centerRight,
                                              child:
                                              PopupMenuButton<
                                                  String>(
                                                itemBuilder:
                                                    (BuildContext
                                                context) {
                                                  return <
                                                      PopupMenuEntry<
                                                          String>>[
                                                    PopupMenuItem<
                                                        String>(
                                                      value: 'name',
                                                      child: Row(
                                                        children: [
                                                          Flexible(
                                                            child:
                                                            Text(
                                                              cloud.filteredSent[index]
                                                              [
                                                              "name"],
                                                              overflow:
                                                              TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    PopupMenuItem<
                                                        String>(
                                                      value: 'date',
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                  Icons.calendar_month),
                                                              const SizedBox(
                                                                  width: 8),
                                                              Text(
                                                                  createDate),
                                                            ],
                                                          ),
                                                          (cloud.filteredSent[index]["view_type"] !=
                                                              "life_time")
                                                              ? Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.calendar_month,
                                                                color: Colors.transparent,
                                                              ),
                                                              const SizedBox(width: 8),
                                                              Text(expDate),
                                                            ],
                                                          )
                                                              :
                                                          //SizedBox(height: 8,),
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.calendar_month,
                                                                color: Colors.transparent,
                                                              ),
                                                              const SizedBox(width: 8),
                                                              const Text("Exp: Unlimited"),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    PopupMenuItem<
                                                        String>(
                                                      value:
                                                      'download',
                                                      child: Row(
                                                        children: [
                                                          const Icon(
                                                              Icons
                                                                  .download),
                                                          const SizedBox(
                                                              width:
                                                              8),
                                                          const Text(
                                                              'Download'),
                                                        ],
                                                      ),
                                                    ),
                                                    PopupMenuItem<
                                                        String>(
                                                      value:
                                                      'delete',
                                                      child: Row(
                                                        children: [
                                                          const Icon(
                                                              Icons
                                                                  .delete),
                                                          const SizedBox(
                                                              width:
                                                              8),
                                                          const Text(
                                                              'Delete'),
                                                        ],
                                                      ),
                                                    ),
                                                  ];
                                                },
                                                onSelected:
                                                    (String value) {
                                                  if (value ==
                                                      'edit') {
                                                    // handle edit option here
                                                  } else if (value ==
                                                      'download') {
                                                    print("mmmmm");
                                                    checkPermissionAndDownloadFile(
                                                        cloud.filteredSent[index]
                                                        [
                                                        "file_path"],
                                                        cloud.filteredSent[index]
                                                        [
                                                        "name"],
                                                        context)
                                                        .then(
                                                            (value) {
                                                          showNotification(
                                                              notifiationName,
                                                              "Download complete");
                                                        });
                                                  } else if (value ==
                                                      'delete') {
                                                    showDialog(
                                                      context:
                                                      context,
                                                      builder:
                                                          (BuildContext
                                                      context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              "Confirm Delete"),
                                                          content:
                                                          const Text(
                                                              "Are you sure you want to delete this file?"),
                                                          actions: [
                                                            TextButton(
                                                              child:
                                                              const Text("Cancel"),
                                                              onPressed:
                                                                  () {
                                                                Navigator.of(context).pop();
                                                              },
                                                            ),
                                                            TextButton(
                                                              child:
                                                              const Text("Delete"),
                                                              onPressed:
                                                                  () {
                                                                // handle delete here
                                                                var parentFolderId =
                                                                    widget.parentId;
                                                                var typeId =
                                                                    "parent_folder_id";

                                                                if (!subCloudSendData.isEmpty) {
                                                                  parentFolderId = subCloudSendData.last[0];
                                                                  typeId = "subparent_folder_id";
                                                                }
                                                                print(cloud.filteredSent[index]["id"]);
                                                                print(parentFolderId);
                                                                print(typeId);
                                                                cloud.deleteCloudFile(
                                                                    parentFolderId,
                                                                    cloud.filteredSent[index]["id"],
                                                                    typeId,
                                                                    "sent",
                                                                    context);
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }
                                                },
                                                child: Container(
                                                  padding:
                                                  const EdgeInsets
                                                      .all(1),
                                                  decoration:
                                                  const BoxDecoration(
                                                    shape: BoxShape
                                                        .rectangle,
                                                    color: Colors
                                                        .transparent,
                                                  ),
                                                  child:
                                                  const Center(
                                                    child: Icon(
                                                        Icons
                                                            .more_vert,
                                                        color: Colors
                                                            .green,
                                                        size: 20),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                      : InkWell(
                                    onTap: () {
                                      var parentFolderId =
                                          widget.parentId;
                                      var typeId =
                                          "parent_folder_id";

                                      print("sujina");

                                      if (!subCloudSendData
                                          .isEmpty) {
                                        parentFolderId =
                                        subCloudSendData
                                            .last[0];
                                        typeId =
                                        "subparent_folder_id";
                                      }

                                      print("sujina");
                                      print(
                                          cloud.filteredSent[index]
                                          ["file_path"]);
                                      //String filePath = cloud.filteredSent[index]["file_path"];
                                      String filePath =
                                      cloud.filteredSent[index]
                                      ["file_path"];

                                      (cloud.filteredSent[index]
                                      ["file_type"] ==
                                          "pdf")
                                          ? Navigator.of(context)
                                          .push(
                                          MaterialPageRoute(
                                              builder:
                                                  (_) =>
                                                  ChatPdfView(
                                                    pdf:
                                                    cloud.filteredSent[index]["file_path"],
                                                    fileName:
                                                    cloud.filteredSent[index]["name"],
                                                  )))
                                          : (cloud.filteredSent[index]["file_type"] ==
                                          "mp3")
                                          ? Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  AudioPlayingScreen(
                                                      fPath: cloud.filteredSent[index][
                                                      "file_path"])))
                                          : (cloud.filteredSent[index]["file_type"] ==
                                          "m4a")
                                          ? Navigator.of(context)
                                          .push(MaterialPageRoute(builder: (_) => AudioPlayingScreen(fPath: cloud.filteredSent[index]["file_path"])))
                                          : (cloud.filteredSent[index]["file_type"] == "mp4")
                                          ? Navigator.of(context).push(MaterialPageRoute(builder: (_) => VideoSection(videoUrl: cloud.filteredSent[index]["file_path"])))
                                          :
                                      // Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatPdfView (pdf: cloud.filteredReceived[index]["file_path"],fileName:cloud.filteredReceived[index]["name"] ,)));
                                      openFile2(cloud.filteredSent[index]["file_path"]);

                                      // launchUrl(Uri.parse(cloud.filteredSent[index]["file_path"]));
                                      // Navigator.of(context).push(MaterialPageRoute(builder: (_) => AudioPlayingScreen(fPath: cloud.filteredSent[index]["file_path"])));
                                    },
                                    child: Column(
                                      children: [
                                        (cloud.filteredSent[index]
                                        ["file_type"] ==
                                            "mp4")
                                            ? const Icon(
                                          Icons
                                              .video_file_rounded,
                                          color: Colors.red,
                                          size: 100.0,
                                        )
                                            : (cloud.filteredSent[index][
                                        "file_type"] ==
                                            "mp3" ||
                                            cloud.filteredSent[index][
                                            "file_type"] ==
                                                "m4a")
                                            ? Icon(
                                          Icons
                                              .audio_file_outlined,
                                          color: Colors
                                              .orange
                                              .shade600,
                                          size: 100.0,
                                        )
                                            : (cloud.filteredSent[index]["file_type"] ==
                                            "pptx" ||
                                            cloud.filteredSent[index]["file_type"] ==
                                                "ppt")
                                            ? Image.asset(
                                          pptIcon,
                                          fit: BoxFit
                                              .cover,
                                          height: 100,
                                          width: 100,
                                        )
                                            : (cloud.filteredSent[index]["file_type"] == "docx" ||
                                            cloud.filteredSent[index]["file_type"] ==
                                                "doc")
                                            ? Image.asset(
                                          documentIcon,
                                          fit: BoxFit
                                              .cover,
                                          height:
                                          100,
                                          width:
                                          100,
                                        )
                                            : Image.asset(
                                          docIcon,
                                          fit: BoxFit
                                              .cover,
                                          height:
                                          100,
                                          width:
                                          100,
                                        ),
                                        // Icon(
                                        //   Icons.file_present_sharp,
                                        //   color: Colors.green,
                                        //   size: 100.0,
                                        // ),
                                        // if(expDate!="")
                                        //   Positioned(
                                        //     bottom: 10,
                                        //     // right: 5,
                                        //     child: Container(
                                        //       color: Colors.black.withOpacity(0.7),
                                        //       width: MediaQuery.of(context).size.width,
                                        //       padding: const EdgeInsets.only(left: 8,right: 8,top: 8,bottom: 8),
                                        //       child: Text(
                                        //         expDate,
                                        //         //textAlign: TextAlign.center,
                                        //         style: const TextStyle(color: Colors.white, fontSize: 10),
                                        //       ),
                                        //     ),
                                        //   ),
                                        SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                child: Text(
                                                  cloud.filteredSent[
                                                  index]
                                                  ['name'],
                                                  textAlign:
                                                  TextAlign
                                                      .center,
                                                  overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                                  maxLines: 2,
                                                  style:
                                                  const TextStyle(
                                                    fontSize: 14.0,
                                                    fontWeight:
                                                    FontWeight
                                                        .normal,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment
                                                  .centerRight,
                                              child:
                                              PopupMenuButton<
                                                  String>(
                                                itemBuilder:
                                                    (BuildContext
                                                context) {
                                                  return <
                                                      PopupMenuEntry<
                                                          String>>[
                                                    PopupMenuItem<
                                                        String>(
                                                      value: 'name',
                                                      child: Row(
                                                        children: [
                                                          Flexible(
                                                            child:
                                                            Text(
                                                              cloud.filteredSent[index]
                                                              [
                                                              "name"],
                                                              overflow:
                                                              TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    PopupMenuItem<
                                                        String>(
                                                      value: 'date',
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                  Icons.calendar_month),
                                                              const SizedBox(
                                                                  width: 8),
                                                              Text(
                                                                  createDate),
                                                            ],
                                                          ),
                                                          (cloud.filteredSent[index]["view_type"] !=
                                                              "life_time")
                                                              ? Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.calendar_month,
                                                                color: Colors.transparent,
                                                              ),
                                                              const SizedBox(width: 8),
                                                              Text(expDate),
                                                            ],
                                                          )
                                                              :
                                                          //SizedBox(height: 8,),
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.calendar_month,
                                                                color: Colors.transparent,
                                                              ),
                                                              const SizedBox(width: 8),
                                                              const Text("Exp: Unlimited"),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    PopupMenuItem<
                                                        String>(
                                                      value:
                                                      'download',
                                                      child: Row(
                                                        children: [
                                                          const Icon(
                                                              Icons
                                                                  .download),
                                                          const SizedBox(
                                                              width:
                                                              8),
                                                          const Text(
                                                              'Download'),
                                                        ],
                                                      ),
                                                    ),
                                                    PopupMenuItem<
                                                        String>(
                                                      value:
                                                      'delete',
                                                      child: Row(
                                                        children: [
                                                          const Icon(
                                                              Icons
                                                                  .delete),
                                                          const SizedBox(
                                                              width:
                                                              8),
                                                          const Text(
                                                              'Delete'),
                                                        ],
                                                      ),
                                                    ),
                                                  ];
                                                },
                                                onSelected:
                                                    (String value) {
                                                  if (value ==
                                                      'edit') {
                                                    // handle edit option here
                                                  } else if (value ==
                                                      'download') {
                                                    print("kkkkk");
                                                    checkPermissionAndDownloadFile(
                                                        cloud.filteredSent[index]
                                                        [
                                                        "file_path"],
                                                        cloud.filteredSent[index]
                                                        [
                                                        "name"],
                                                        context)
                                                        .then(
                                                            (value) {
                                                          showNotification(
                                                              notifiationName,
                                                              "Download complete");
                                                        });
                                                  } else if (value ==
                                                      'delete') {
                                                    showDialog(
                                                      context:
                                                      context,
                                                      builder:
                                                          (BuildContext
                                                      context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              "Confirm Delete"),
                                                          content:
                                                          const Text(
                                                              "Are you sure you want to delete this file?"),
                                                          actions: [
                                                            TextButton(
                                                              child:
                                                              const Text("Cancel"),
                                                              onPressed:
                                                                  () {
                                                                Navigator.of(context).pop();
                                                              },
                                                            ),
                                                            TextButton(
                                                              child:
                                                              const Text("Delete"),
                                                              onPressed:
                                                                  () {
                                                                // handle delete here
                                                                var parentFolderId =
                                                                    widget.parentId;
                                                                var typeId =
                                                                    "parent_folder_id";

                                                                if (!subCloudSendData.isEmpty) {
                                                                  parentFolderId = subCloudSendData.last[0];
                                                                  typeId = "subparent_folder_id";
                                                                }
                                                                print(cloud.filteredSent[index]["id"]);
                                                                print(parentFolderId);
                                                                print(typeId);
                                                                cloud.deleteCloudFile(
                                                                    parentFolderId,
                                                                    cloud.filteredSent[index]["id"],
                                                                    typeId,
                                                                    "sent",
                                                                    context);
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }
                                                },
                                                child: Container(
                                                  padding:
                                                  const EdgeInsets
                                                      .all(1),
                                                  decoration:
                                                  const BoxDecoration(
                                                    shape: BoxShape
                                                        .rectangle,
                                                    color: Colors
                                                        .transparent,
                                                  ),
                                                  child:
                                                  const Center(
                                                    child: Icon(
                                                        Icons
                                                            .more_vert,
                                                        color: Colors
                                                            .green,
                                                        size: 20),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    floatingActionButton: ExpandableFabClass(
                      distanceBetween: 80.0,
                      subChildren: [
                        ActionButton(
                          label: "Upload Folder",
                          onPressed: () {
                            showModalBottomSheet<void>(
                              context: context,
                              builder: (BuildContext context) {
                                if (subCloudSendData.length > 0) {
                                  return BottomSheetRadioList(
                                      folderId: subCloudSendData.last[0],
                                      type: "subparent_folder_id",
                                      endDateTime: subCloudSendData.last[2]);
                                } else {
                                  return BottomSheetRadioList(
                                    folderId: widget.parentId,
                                    type: "parent_folder_id",
                                    endDateTime: "life_time",
                                  );
                                }
                              },
                            );
                          },
                          icon: const Icon(Icons.folder),
                        ),
                        ActionButton(
                          label: "Upload File ",
                          onPressed: () {
                            showModalBottomSheet<void>(
                              context: context,
                              builder: (BuildContext context) {
                                if (subCloudSendData.length > 0) {
                                  return BottomSheetFileUpload(
                                    folderId: subCloudSendData.last[0],
                                    type: "subparent_folder_id",
                                    endDateTime: subCloudSendData.last[2],
                                  );
                                } else {
                                  return BottomSheetFileUpload(
                                      folderId: widget.parentId,
                                      type: "parent_folder_id",
                                      endDateTime: "life_time");
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
          ),
        );
      },
    );
  }
}

class BottomSheetRadioList extends StatefulWidget {
  final String folderId;
  final String type;
  final String endDateTime;

  const BottomSheetRadioList(
      {Key? key,
        required this.folderId,
        required this.type,
        required this.endDateTime})
      : super(key: key);
  @override
  _BottomSheetRadioListState createState() => _BottomSheetRadioListState();
}

class _BottomSheetRadioListState extends State<BottomSheetRadioList> {
  int _selectedOption = 0;
  String _selectedOption2 = "hourly";
  int _selectedOption1 = 1;
  TextEditingController _nameController = TextEditingController();

  TextEditingController _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime now = DateTime.now();
    print(widget.endDateTime);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now,
      // lastDate: DateTime(2101),
      lastDate: widget.endDateTime == "0000-00-00 00:00:00"
          ? DateTime(2101)
          : widget.endDateTime == "life_time"
          ? DateTime(2101)
          : dateFormat.parse(widget.endDateTime),
      selectableDayPredicate: (DateTime date) =>
          date.isAfter(now.subtract(const Duration(days: 1))),
    );
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (pickedTime != null) {
        final DateTime newDateTime = DateTime(picked.year, picked.month,
            picked.day, pickedTime.hour, pickedTime.minute);
        if (newDateTime.isBefore(now)) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Please select a time in the future.")));
        } else {
          _selectedDate = newDateTime;
          _dateController.text =
              _selectedDate.toString().replaceAll(".000", "");
        }
      }
    }
  }

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
                    decoration: new BoxDecoration(
                      image: DecorationImage(
                        image: new AssetImage(folderIcon),
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
                        "Access Type",
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
                            title: const Text("Unlimited View"),
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
                            title: const Text("Limited View"),
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
                            child: TextFormField(
                              controller: _dateController,
                              onTap: () => _selectDateTime(context),
                              decoration: const InputDecoration(
                                labelText: 'Date and Time',
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              readOnly: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a date and time';
                                }
                                return null;
                              },
                            ),
                          ),
                          // Expanded(
                          //   child:
                          //   DropdownButton<int>(
                          //     value: _selectedOption1,
                          //     items: List.generate(100, (index) {
                          //       return DropdownMenuItem(
                          //         child: Text(
                          //           "${index + 1}",
                          //           style: TextStyle(fontSize: 20),
                          //         ),
                          //         value: index + 1,
                          //       );
                          //     }),
                          //     onChanged: (value) {
                          //       setState(() {
                          //         _selectedOption1 = value!;
                          //       });
                          //     },
                          //   ),
                          // ),
                          // SizedBox(width: 8.0),
                          // //access_period 1- hourly 2- days 3- months 4- year 5- life_time
                          // Expanded(
                          //   child: DropdownButton(
                          //     value: _selectedOption2,
                          //     items: [
                          //       DropdownMenuItem(
                          //         child: Text('Hour(s)'),
                          //         value: "hourly",
                          //       ),
                          //       DropdownMenuItem(
                          //         child: Text('Day(s)'),
                          //         value: "days",
                          //       ),
                          //       DropdownMenuItem(
                          //         child: Text('Month(s)'),
                          //         value: "months",
                          //       ),
                          //       DropdownMenuItem(
                          //         child: Text('Year(s)'),
                          //         value: "year",
                          //       ),
                          //     ],
                          //     onChanged: (value) {
                          //       setState(() {
                          //         _selectedOption2 = value!;
                          //       });
                          //     },
                          //   ),
                          // ),
                        ],
                      ),
                    )
                        : const Text(""),
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
                              String period = "";
                              _selectedOption == 0
                                  ? period = "life_time"
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
                                  _dateController.text,
                                  context);
                            },
                            child: const Text(
                              "Submit",
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
  final String endDateTime;
  const BottomSheetFileUpload(
      {Key? key,
        required this.folderId,
        required this.type,
        required this.endDateTime})
      : super(key: key);
  @override
  _BottomSheetFileUploadState createState() => _BottomSheetFileUploadState();
}

class _BottomSheetFileUploadState extends State<BottomSheetFileUpload> {
  int _selectedOption = 0;
  String _selectedOption2 = "hourly";
  int _selectedOption1 = 1;
  TextEditingController _nameController = TextEditingController();
  File? _file;
  String? _type;
  bool _isLoading = false;

  TextEditingController _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  List<String> imageType = ['jpg', 'jpeg', 'png', 'image'];

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now,
      // lastDate: DateTime(2101),
      lastDate: widget.endDateTime == "0000-00-00 00:00:00"
          ? DateTime(2101)
          : widget.endDateTime == "life_time"
          ? DateTime(2101)
          : dateFormat.parse(widget.endDateTime),
      selectableDayPredicate: (DateTime date) =>
          date.isAfter(now.subtract(const Duration(days: 1))),
    );
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (pickedTime != null) {
        final DateTime newDateTime = DateTime(picked.year, picked.month,
            picked.day, pickedTime.hour, pickedTime.minute);
        if (newDateTime.isBefore(now)) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Please select a time in the future.")));
        } else {
          _selectedDate = newDateTime;
          _dateController.text =
              _selectedDate.toString().replaceAll(".000", "");
        }
      }
    }
  }

  Future getFile() async {
    //final pick = await ImagePicker().pickVideo(source: source);

    FilePickerResult? pick = await FilePicker.platform.pickFiles(
      /* type: FileType.custom,
                      // multiple: false,
                      allowedExtensions: [
                        'pdf','png','jpg','jpeg'
                      ],*/
      type: FileType.custom,
      // multiple: false,
      allowedExtensions: [
        'pdf',
        'png',
        'jpg',
        'jpeg',
        'pptx',
        'mp4',
        'mp3',
        'docx',
        'zip',
        'xlsx',
        'm4a',
        'doc',
        'ppt',
        'xls'
      ],
    );

    if (pick != null) {
      setState(() {
        _isLoading = true;
      });

      _isLoading ? buildShowDialog(context!) : Container();
      // final thumbnailFile = await VideoCompress.getFileThumbnail(pick.files.first.path!,
      //     quality: 50, // default(100)
      //     position: -1 // default(-1)
      // );

      if (pick != null && pick.files.isNotEmpty) {
        setState(() {
          String type = pick.files.first.extension.toString();
          _file = File(pick.files.first.path!);
          _type = type;
          print("type");
          print(type);
          if (_type != "mp4") {
            _isLoading = false;
            Navigator.of(context).pop();
            exit;
          }
          print(type);
          if (type == "pdf") {
          } else {}
        });

        // Use the selected file
      }

      if (_type == "mp4") {
        final info = await VideoCompress.compressVideo(
          pick.files.first.path.toString(),
          //quality: VideoQuality.DefaultQuality,
          quality: VideoQuality.MediumQuality,
          deleteOrigin: false,
        );
        if (info != null &&
            pick != null &&
            pick.files.isNotEmpty &&
            _type == "mp4") {
          setState(() {
            String type = pick.files.first.extension.toString();
            _file = File(pick.files.first.path!);
            _type = type;

            _file = File(info!.path.toString());
            _isLoading = false;
            Navigator.of(context).pop();

            print(type);
            if (type == "pdf") {
            } else {}
          });

          // Use the selected file
        }
        //final compressedFile = File(info.path.toString());
      } else {
        print("NULL");
      }
    }
  }

  Future getFile2() async {
    FilePickerResult? pick = await FilePicker.platform.pickFiles();

    if (pick != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final info = await VideoCompress.compressVideo(
          pick.files.first.path!,
          quality: VideoQuality.DefaultQuality,
          deleteOrigin: false,
        );

        setState(() {
          String type = pick.files.first.extension.toString();
          _file = File(pick.files.first.path!);
          _type = type;

          if (type != "mp4") {
            _isLoading = false;
          }
        });

        Navigator.of(context).pop(); // close the loading dialog
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  buildShowDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(leftGreen),
              ));
        });
  }

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
                  onTap: () {
                    getFile();
                  }
                  /*async {
                    print("TEST");
                    // getFooterPic();
                    FilePickerResult? result =
                    await FilePicker
                        .platform
                        .pickFiles(
                     /* type: FileType.custom,
                      // multiple: false,
                      allowedExtensions: [
                        'pdf','png','jpg','jpeg'
                      ],*/
                    );
                    if (result != null && result.files.isNotEmpty) {
                      setState(() {

                        String type = result.files.first.extension.toString();
                        _file = File(result.files.first.path!);
                        _type = type;
                       if(type=="mp4"){
                          final info = await VideoCompress.compressVideo(
                            result.files.first.path!,
                            quality: VideoQuality.DefaultQuality,
                            deleteOrigin: false,
                          );
                          if (info != null) {
                            final compressedFile = File(info.path.toString());
                          }
                        }

                        print(type);
                        if(type=="pdf"){

                        }
                        else{

                        }
                      });


                      // Use the selected file
                    }
                  }*/
                  ,
                  //imageType.contains(
                  child: DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(12),
                      dashPattern: [8, 4],
                      strokeWidth: 2,
                      color: Colors.black87,
                      // child: _file != null && _type!="pdf"
                      child: _file != null && imageType.contains(_type)
                          ? Image.file(
                        _file!,
                        height: 150,
                        width: 330,
                        fit: BoxFit.contain,
                      )
                          : (_file != null && _type == "pdf")
                          ? Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 100, vertical: 50),
                          child: _file != null && _type == "pdf"
                              ? Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(8),
                            ),
                            child:
                            Image(image: AssetImage(pdfIcon)),
                          )
                              : const Text("UPLOAD"))
                          : Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 100, vertical: 50),
                          child: _file != null && _type != "pdf"
                              ? Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(8),
                            ),
                            child: _type == "docx"
                                ? Image(
                                image: AssetImage(docIcon))
                                : _type == "mp4"
                                ? const Icon(
                              Icons.video_file_sharp,
                              color: Colors.red,
                              size: 60.0,
                            )
                                : _type == "mp3"
                                ? Icon(
                              Icons
                                  .audio_file_outlined,
                              color: Colors
                                  .orange.shade600,
                              size: 60.0,
                            )
                                : Image(
                                image: AssetImage(
                                    docIcon)),
                            /* Icon(
                            Icons.file_present_sharp,
                            color: Colors.green,6374
                            size: 60.0,
                          ),*/
                          )
                              : const Text("UPLOAD"))),
                ),
                const SizedBox(
                    height: 40,
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        "Access Type",
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
                            title: const Text("Unlimited View"),
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
                            title: const Text("Limited View"),
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
                            child: TextFormField(
                              controller: _dateController,
                              onTap: () => _selectDateTime(context),
                              decoration: const InputDecoration(
                                labelText: 'Date and Time',
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              readOnly: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a date and time';
                                }
                                return null;
                              },
                            ),
                          ),
                          // Expanded(
                          //   child:
                          //   DropdownButton<int>(
                          //     value: _selectedOption1,
                          //     items: List.generate(100, (index) {
                          //       return DropdownMenuItem(
                          //         child: Text(
                          //           "${index + 1}",
                          //           style: TextStyle(fontSize: 20),
                          //         ),
                          //         value: index + 1,
                          //       );
                          //     }),
                          //     onChanged: (value) {
                          //       setState(() {
                          //         _selectedOption1 = value!;
                          //       });
                          //     },
                          //   ),
                          // ),
                          // SizedBox(width: 8.0),
                          // //access_period 1- hourly 2- days 3- months 4- year 5- life_time
                          // Expanded(
                          //   child: DropdownButton(
                          //     value: _selectedOption2,
                          //     items: [
                          //       DropdownMenuItem(
                          //         child: Text('Hour(s)'),
                          //         value: "hourly",
                          //       ),
                          //       DropdownMenuItem(
                          //         child: Text('Day(s)'),
                          //         value: "days",
                          //       ),
                          //       DropdownMenuItem(
                          //         child: Text('Month(s)'),
                          //         value: "months",
                          //       ),
                          //       DropdownMenuItem(
                          //         child: Text('Year(s)'),
                          //         value: "year",
                          //       ),
                          //     ],
                          //     onChanged: (value) {
                          //       setState(() {
                          //         _selectedOption2 = value!;
                          //       });
                          //     },
                          //   ),
                          // ),
                        ],
                      ),
                    )
                        : const Text(""),
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
                              String period = "";
                              _selectedOption == 0
                                  ? period = "life_time"
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
                                  _dateController.text,
                                  _file,
                                  context);
                            },
                            child: const Text(
                              "Submit",
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
