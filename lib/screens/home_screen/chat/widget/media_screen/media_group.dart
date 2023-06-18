import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/screens/home_screen/chat/widget/media_screen/links_group_section.dart';
import 'package:smart_station/screens/home_screen/chat/widget/media_screen/links_section.dart';
import 'package:smart_station/utils/constants/app_constants.dart';

import '../../../../../providers/UserProvider/user_provider.dart';
import '../../api/individual_chat_section.dart';
import '../../models/group_media_model.dart';
import 'doc_group_section.dart';
import 'image_video_group.dart';

class MediaGroup extends StatefulWidget {
  String recName;
  String recId;
  MediaGroup({Key? key, required this.recName, required this.recId})
      : super(key: key);

  @override
  State<MediaGroup> createState() => _MediaHomeState();
}

class _MediaHomeState extends State<MediaGroup> with TickerProviderStateMixin {
  final GlobalKey _menuKey = GlobalKey();
  late TabController _tabController;
  TextEditingController _searchController = TextEditingController();
  // List<Media> medias = [];
  // List<Media> docs = [];
  var tabIndex = 0;
  String? myData;
  bool searchStatus = false;

  @override
  void initState() {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    getchatMediaGroup(auth.userId, auth.accessToken, widget.recId)
        .then((value) {
      myData = value;
    });
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
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
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
        title: searchStatus && _tabController.index != 0 ?
        Container(
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
        :Text(widget.recName),
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
        child: FutureBuilder<dynamic>(
          future:
              getchatMediaGroup(auth.userId, auth.accessToken, widget.recId),
          builder: (context, snapshot) {
            print('data');
            print(snapshot);
            //  dynamic jsonData = jsonDecode(snapshot.data);
            if (snapshot.connectionState == ConnectionState.done) {
              // print(snapshot.data);
              _tabController.animation!.addListener(() {
                if (!_tabController.indexIsChanging) {
                  setState(() {
                    tabIndex = _tabController.index;
                  });
                }
              });
              // for (int i = 0; i < snapshot.data!.data.medias.length; i++) {
              //   if (snapshot.data!.data.medias[i].type != 'date') {
              //     medias = snapshot.data!.data.medias;
              //   }
              // }

              // for (int i = 0; i < snapshot.data!.data.docs.length; i++) {
              //   if (snapshot.data!.data.docs[i].type != 'date') {
              //     docs = snapshot.data!.data.medias;
              //   }
              // }

              // docs = snapshot.data!.data.docs;
              return TabBarView(
                physics: const BouncingScrollPhysics(),
                controller: _tabController,
                children: [
                  snapshot.data != null
                      ? AudVidImgSectionGrp(mediaList: snapshot.data)
                      : Container(),
                  DocSectionGrp(docsArray: snapshot.data),
                  LinksGroupSection(linksList: snapshot.data),
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
        // child: Builder(
        //   builder: (context) {
        //     _tabController.animation!.addListener(() {
        //       if (!_tabController.indexIsChanging) {
        //         setState(() {
        //           tabIndex = _tabController.index;
        //
        //         });
        //       }
        //     });
        //     return TabBarView(
        //       physics: BouncingScrollPhysics(),
        //       controller: _tabController,
        //       children: [
        //         AudVidImgSection(recId: widget.recId),
        //         DocSection(),
        //         LinksSection(),
        //
        //       ],
        //     );
        //   },
        // ),
      ),
    );
  }
}
