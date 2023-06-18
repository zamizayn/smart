import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/CloudProvider/cloud_provider.dart';
import 'package:smart_station/screens/home_screen/cloud/cloud_tab.dart';
import 'package:smart_station/screens/home_screen/cloud/contact_list.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/bottomSection.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/topSection.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:smart_station/providers/UserProvider/user_provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';

class CloudScreen extends StatefulWidget {
  const CloudScreen({Key? key}) : super(key: key);

  @override
  State<CloudScreen> createState() => _CloudScreenState();
}

class _CloudScreenState extends State<CloudScreen> {
  final _searchController = TextEditingController();
  final TextEditingController _textEditingController = TextEditingController();
  List<dynamic> _cloudData = [];
  List<dynamic> _filteredData = [];
  var searchStatus = false;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    print('fd');
    super.initState();

    var cloud = Provider.of<CloudProvider>(context, listen: false);
    cloud.getCloudParentList(context);
    setState(() {
      _cloudData = cloud.parentData;
      _filteredData = _cloudData;
      print(cloud.parentData.length);
    });
    var userP = Provider.of<UserProvider>(context, listen: false);
    var auth = Provider.of<AuthProvider>(context, listen: false);
  }

  List selectedFolderId = [];
  @override
  void dispose() {
    _searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void search(String val) {
    print(val);
    if (val.isEmpty) {
      setState(() {
        _filteredData = _cloudData;
        print(_filteredData);
      });
    } else {
      final fnd = _cloudData.where((element) {
        final name = element['phone'].toString().toLowerCase();
        final input = val.toLowerCase();
        return name.contains(input);
      }).toList();
      setState(() {
        _filteredData = fnd;
        print('_filteredData');
        print(_filteredData.length);
      });
    }
  }

  // search(String val) {
  //   print(val);
  //   if (val.isEmpty) {
  //     _filteredData= _cloudData;
  //   }
  //   else{
  //     final fnd = _cloudData.where((element) {
  //       final name = element['phone'].toString().toLowerCase();
  //       final input = val.toLowerCase();
  //       return name.contains(input);
  //     }).toList();
  //     // print(found);
  //     print("::::::[NAME]::::::");
  //     print(fnd);
  //     print("::::::[NAME]::::::");
  //
  //     setState(() {
  //       _filteredData= fnd;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<CloudProvider>(
      builder: (context, cloud, child) {
        print(_cloudData);
        if (_cloudData.isEmpty) {
          print('_cloudData');

          _cloudData = cloud.parentData;
          _filteredData = _cloudData;
        }
//Change background shrink
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            clipBehavior: Clip.none,
            children: [
              const TopSection(),
              Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(splashBg),
                      fit: BoxFit.fill,
                    )),
              ),
              Positioned(
                top: 40,
                left: 0,
                right: 20,
                child: Row(
                  children: const [
                    BackButton(color: Colors.white),
                    Text(
                      'Cloud ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              (searchStatus == true)
                  ? Positioned(
                      top: 40,
                      left: 110,
                      right: 40,
                      child: SizedBox(
                        // key: UniqueKey(),
                        height: 40,
                        // width: double.infinity,
                        child: Center(
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
                              search(value);
                              searchStatus=true;
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search...',
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 16.0),
                              // prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        )),
                      ),
                    )
                  : const SizedBox(
                      width: 0,
                    ),
              Positioned(
                top: 38,
                //left:0,
                right: 0,
                child: (searchStatus == false)
                    ? IconButton(
                        iconSize: 25,
                        icon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // ...
                          setState(() {
                            searchStatus = true;
                            _textEditingController.text = '';
                            focusNode.requestFocus();

                          });
                        },
                      )
                    : IconButton(
                        iconSize: 25,
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            searchStatus = false;

                            search('');
                          });
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 100.0, left: 10, right: 10),
                child: Stack(
                  children: [
                    GridView.builder(
                      itemCount: _filteredData.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 30,
                      ),
                      itemBuilder: (context, index) {
                        print(_filteredData.length);
                        return Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => CloudTabScreen(
                                              phonenumber: _filteredData[index]
                                                  ['phone'],
                                              parentId: _filteredData[index]
                                                  ['id'],
                                            )));
                              },
                              onLongPress: () {
                                print('longpress');
                                if (selectedFolderId.contains(
                                    _filteredData[index]['id'].toString())) {
                                  setState(() {
                                    selectedFolderId.remove(
                                        _filteredData[index]['id'].toString());
                                  });
                                } else {
                                  setState(() {
                                    selectedFolderId.add(
                                        _filteredData[index]['id'].toString());
                                  });
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: selectedFolderId.contains(
                                            _filteredData[index]['id']
                                                .toString())
                                        ? Colors.grey
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Stack(
                                    alignment: AlignmentDirectional.center,
                                    children: [
                                      Container(
                                          alignment: Alignment.topCenter,
                                          decoration: BoxDecoration(
                                              //color: Colors.lime,

                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Image.asset(folderIcon)),
                                      Center(
                                        child: CircleAvatar(
                                          child: CircleAvatar(
                                            radius: 60,
                                            backgroundImage: NetworkImage(
                                                _filteredData[index]
                                                    ['profile_pic']),
                                            //  backgroundImage: NetworkImage("https://images.unsplash.com/photo-1579202673506-ca3ce28943ef"),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // padding if needed
                            const SizedBox(
                              height: 5,
                            ),
                            Text(_filteredData[index]['phone']),
                          ],
                        );
                      },
                    ),
                    if (_filteredData.isEmpty)
                      const Center(
                        child: Text(
                          'No File',
                          style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                      )
                  ],
                ),
              ),
              const Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: BottomSectionTransp(),
              ),
              Positioned(
                bottom: 20,
                right: 10,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FloatingActionButton(
                      onPressed: () async {
                        // your action here

                        String refresh = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ContactList()));
                        if (refresh == 'refresh') {
                          setState(() {
                            var cloud = Provider.of<CloudProvider>(context,
                                listen: false);
                            cloud.getCloudParentList(context);
                            setState(() {
                              _cloudData = cloud.parentData;
                              _filteredData = _cloudData;
                              print(cloud.parentData.length);
                            });
                          });
                        }
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (_) => CreateGroupScreen()));
                      },
                      backgroundColor: Colors.green,
                      elevation: 4.0,
                      heroTag: null,
                      isExtended: true,
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
