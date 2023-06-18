import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/screens/home_screen/chat/widget/media_screen/doc_section.dart';
import 'package:smart_station/screens/home_screen/chat/widget/media_screen/image_video_audio.dart';
import 'package:smart_station/screens/home_screen/chat/widget/media_screen/links_section.dart';
import 'package:smart_station/utils/constants/app_constants.dart';

import '../../../../../providers/UserProvider/user_provider.dart';
import '../../api/individual_chat_section.dart';
import '../../models/individualChat/individualMediaModel.dart';

class MediaHome extends StatefulWidget {
  String recName;
  String recId;
  MediaHome({Key? key, required this.recName, required this.recId})
      : super(key: key);

  @override
  State<MediaHome> createState() => _MediaHomeState();
}

class _MediaHomeState extends State<MediaHome> with TickerProviderStateMixin {
  final GlobalKey _menuKey = GlobalKey();
  late TabController _tabController;
  TextEditingController _searchController = TextEditingController();
  List<Doc> medias = [];
  List<Doc> docs = [];
  var tabIndex = 0;
  bool searchStatus = false;

  populateMedia(List<Doc> mediaData) {
    List<Doc> temp = [];
    for (int i = 0; i < mediaData.length; i++) {
      if (mediaData[i].type != 'date') {
        medias = mediaData;
      }
    }
  }

  populateDoc(List<Doc> docData) {
    List<Doc> temp = [];
    for (int i = 0; i < docData.length; i++) {
      if (docData[i].type != 'date') {
        docs = docData;
      }
    }
  }

  @override
  void initState() {
    var searchPro = Provider.of<UserProvider>(context, listen: false);
    searchPro.searchMedia('');
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _tabController = TabController(
      initialIndex: 0,
      length: 3,
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    // var searchPro = Provider.of<UserProvider>(context, listen: false);
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    // searchPro.clearSearch();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      // Do something with the current index here
      print('Current index: ${_tabController.index}');
      setState(() {}); // Rebuild the widget tree
    }
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    var searchPro = Provider.of<UserProvider>(context, listen: false);
    // searchPro.clearSearch();
    print("RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRr");
    TabBar tabBar = TabBar(
      controller: _tabController,
      indicator: BoxDecoration(color: Colors.grey[200]),
      onTap: (value) {
        setState(() {
          tabIndex = value;
        });
      },
      tabs: const [
        Tab(
          child: Text(
            'MEDIA',
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
        ),
        Tab(
          child: Text(
            'DOCS',
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
        ),
        Tab(
          child: Text(
            'LINKS',
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
        ),
      ],
    );
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black26,
        title: searchStatus && _tabController.index != 0
            ? Container(
              height: 35,
              decoration: BoxDecoration(
                 color: Colors.grey[200], // Background color of the TextField
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                  
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    searchPro.searchMedia(_searchController.text);
                  },
                ),
            )
            : Text(widget.recName),
        bottom: PreferredSize(
          preferredSize: tabBar.preferredSize,
          child: Material(
            elevation: 0,
            color: Colors.black26,
            child: tabBar,
          ),
        ),
        actions: [
          _tabController.index != 0
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      searchStatus = !searchStatus;
                      if (!searchStatus) {
                        searchPro.searchMedia('');
                        _searchController.text = "";
                      }
                    });
                  },
                  icon:  (!searchStatus)?Icon(Icons.search):Icon(Icons.close))
              : Container()
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(splashBg), fit: BoxFit.cover)),
        child: FutureBuilder(
          future: getchatMedia(auth.userId, auth.accessToken, widget.recId),
          builder: (context, snapshot) {
            print(snapshot.data);
            if (snapshot.connectionState == ConnectionState.done) {
              _tabController.animation!.addListener(() {
                if (!_tabController.indexIsChanging) {
                  setState(() {
                    tabIndex = _tabController.index;
                  });
                }
              });

              // populateMedia(snapshot.data!.data.medias);
              // populateDoc(snapshot.data!.data.docs);
              // docs = snapshot.data!.data.docs;
              return TabBarView(
                physics: const BouncingScrollPhysics(),
                controller: _tabController,
                children: [
                  AudVidImgSection(mediaList: snapshot.data),
                  DocSection(docsList: snapshot.data),
                  LinksSection(linkList: snapshot.data),
                ],
              );
            } else {
              return const Scaffold(
                body: Center(
                  child: SpinKitSpinningLines(color: Colors.green),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
