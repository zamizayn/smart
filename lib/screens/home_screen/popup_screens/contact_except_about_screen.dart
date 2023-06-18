import 'package:flutter/material.dart';
import 'package:smart_station/providers/AccountProvider/privacy_provider.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/topSection.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/UserProvider/user_provider.dart';

class ContactExceptAboutScreen extends StatefulWidget {
  //const ContactExceptSettingsScreen({Key? key}) : super(key: key);
  String type;
  ContactExceptAboutScreen({Key? key, required this.type}) : super(key: key);

  @override
  State<ContactExceptAboutScreen> createState() =>
      _ContactExceptAboutScreenState();
}

class _ContactExceptAboutScreenState extends State<ContactExceptAboutScreen> {
  final TextEditingController _textEditingController = TextEditingController();

  var searchStatus = false;
  var selectAll = false;
  var count = 0;
  Set<int> selectedIndices;

  _ContactExceptAboutScreenState() : selectedIndices = <int>{};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Initialize values or perform any setup tasks here
    print('Initializing MyWidget');
    print('Initializing MyWidgetddd');
    var user = Provider.of<UserProvider>(context, listen: false);
    // user.userList(context:context);
    var privacy = Provider.of<PrivacyProvider>(context, listen: false);

    selectedIndices.addAll(privacy.blockedStatusUsers
        .where((user) => user['excepted_user_status'])
        .map<int>((user) => int.parse(user['user_id'])));

    count = selectedIndices.length;
  }

  @override
  void dispose() {
    setState(() {
      selectedIndices.clear();
    });
    print('Dispose used');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Call super.build to enable automaticKeepAlive
    /*return Consumer2<UserProvider,PrivacyProvider>(
        builder: (context, user,privacy, child) {

          search(String val) {
            if (val.isEmpty) {
              privacy.getExceptedUsersAbout((context));
            }
            else{
              final fnd = user.data.where((element) {
                final name = element['name'].toString().toLowerCase();
                final input = val.toLowerCase();
                return name.contains(input);
              }).toList();
              // print(found);
              print("::::::[NAME]::::::");
              print(fnd);
              print("::::::[NAME]::::::");

              setState(() {
                user.getActualData(fnd);
              });
            }
          }

          return Scaffold(
            body: Stack(
              clipBehavior: Clip.none,
              children: [
                TopSection(),
                Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(splashBg), fit: BoxFit.fill)),
                ),
                Positioned(
                  top: 22,

                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top:15.0),
                        child: BackButton(color: Colors.white),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:13.0),
                        child: Text(
                          "My contacts except...",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  top: 65,
                  left: 60,
                  child: Row(
                    children: [
                      (count==0)?
                      Text(
                      //  user.data.length.toString() + " contacts",
                        "No contacts excluded",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ):
                      Text(
                        //  user.data.length.toString() + " contacts",
                        (count==1)?
                        "1 contact excluded": count.toString()+" contacts excluded",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
                (searchStatus==true)?
                Positioned(
                  top: 40,
                  left: 50,
                  right: 40,
                  child: SizedBox(
                    // key: UniqueKey(),
                    height: 40,
                    // width: double.infinity,
                    child: Center(
                        child:
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.grey[200],
                          ),
                          child: TextField(
                            controller: _textEditingController,
                            onChanged: (value) {
                              search(value);
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search...',
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                              // prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        )

                    ),
                  ),
                ):SizedBox(width: 0,),
                Positioned(
                  top: 38,
                  //left:0,
                  right: 40,
                  child:
                  (searchStatus==false)?
                  IconButton(
                    iconSize: 25,
                    icon: const Icon(Icons.search,color: Colors.white,),
                    onPressed: () {
                      // ...
                      setState(() {
                        searchStatus=true;
                        _textEditingController?.text="";
                      });

                    },
                  )
                      :SizedBox(width: 0,)
                  //     :
                  // IconButton(
                  //   iconSize: 25,
                  //   icon: const Icon(Icons.close,color: Colors.white,),
                  //   onPressed: () {
                  //     setState(() {
                  //       searchStatus=false;
                  //
                  //       search("");
                  //     });
                  //   },
                  // ),
                ),
                Positioned(
                  top: 38,
                  //left:0,
                  right: 0,
                  child: (searchStatus==false)?
                  IconButton(
                    iconSize: 25,
                    icon: const Icon(Icons.playlist_add_check,color: Colors.white,),
                    onPressed: () {
                      // ...
                      print("selectAll");
                      print(selectAll);
                      setState(() {
                        (selectAll==true)?
                        selectAll = false:selectAll = true;
                        print(selectAll);
                        if (selectAll) {
                          selectedIndices = Set<int>.from(
                            List.generate(user.data.length, (index) => int.parse(user.data[index]['user_id'])),
                          );
                        } else {
                          selectedIndices.clear();
                        }
                        count = selectedIndices.length;
                      });

                    },
                  ):
                  IconButton(
                    iconSize: 25,
                    icon: const Icon(Icons.close,color: Colors.white,),
                    onPressed: () {
                      setState(() {
                        searchStatus=false;

                        search("");
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top:90.0),
                  child:

                  ListView.builder(
                    itemCount: user.data.length,
                    itemBuilder: (BuildContext context, int index) {
                     // Contact contact = _contacts[index];
                      //bool isChecked = selectedIndices.contains(user.data[index]['user_id']);
                      bool isChecked = selectedIndices.contains(int.parse(user.data[index]['user_id']));
                      // return CheckboxListTile(
                      //   activeColor: Colors.red,
                      //   value: isChecked,
                      //   onChanged: (bool? value) {
                      //     print("Before: $selectedIndices");
                      //     print(value);
                      //     setState(() {
                      //       if (value != null && value) {
                      //         selectedIndices.add(int.parse(user.data[index]['user_id']));
                      //       } else {
                      //         selectedIndices.remove(int.parse(user.data[index]['user_id']));
                      //       }
                      //     });
                      //     print("After: $selectedIndices");
                      //   },
                      //
                      //   title: Text(user.data[index]['name']),
                      //   subtitle: Text(user.data[index]['about']),
                      //   secondary: CircleAvatar(
                      //     backgroundImage: NetworkImage(user.data[index]['profile_pic']),
                      //   ),
                      // );
                     // bool isChecked = selectedIndices.contains(int.parse(user.data[index]['user_id']));

                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                        child: InkWell(
                          onTap: (){
                            setState(() {
                              if (isChecked) {
                                selectedIndices.remove(int.parse(user.data[index]['user_id']));
                                isChecked = false;
                              } else {
                                selectedIndices.add(int.parse(user.data[index]['user_id']));
                                isChecked = true;
                              }
                              count = selectedIndices.length;
                            });
                          },
                          child: Row(
                            children: [

                              Container(
                                width: 60,
                                height: 60,
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(15)),
                                child: CircleAvatar(
                                  backgroundImage: user.data[index]['profile_pic'] !=
                                      null
                                      ? NetworkImage(
                                      user.data[index]['profile_pic'])
                                      : NetworkImage(
                                      'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png'),
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.data[index]['name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    SizedBox(height: 5),

                                    Container(
                                      padding: new EdgeInsets.only(right: 0.0),
                                      width: MediaQuery.of(context).size.width - 180,
                                      child: new Text(
                                        user.data[index]['about'],
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                        style: TextStyle(
                                          color:  Color(0xFF9B9898)
                                          ,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Transform.scale(
                                scale: 1.2,
                                child: Checkbox(
                                  value: isChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value != null && value) {
                                        selectedIndices.add(int.parse(user.data[index]['user_id']));
                                      } else {
                                        selectedIndices.remove(int.parse(user.data[index]['user_id']));
                                      }
                                      isChecked = selectedIndices.contains(int.parse(user.data[index]['user_id'])); // Update isChecked based on new selectedIndices list
                                      count = selectedIndices.length;
                                    });
                                  },
                                  shape: CircleBorder(),
                                  checkColor: Colors.white,
                                  activeColor: Colors.red,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  // You can adjust the size of the checkbox by using the below code
                                  // visualDensity: VisualDensity.comfortable,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );


                    },
                  ),
                ),

              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: rightGreen,
              onPressed: () {
                // Do something with selected contacts
                print(selectedIndices);
                print("selectedIndices");
                var selected = selectedIndices.toString().replaceAll("{", "");

                switch(widget.type) {
                  case "lastseen": {
                    (selectedIndices.isEmpty)?
                    privacy.setLastseenStatus(1, selectedIndices.toString(), context!):
                    privacy.setLastseenStatus(
                        2, selectedIndices.toString(), context!);
                  }
                  break;

                  case "about": {
                    (selectedIndices.isEmpty)?
                    privacy.setAboutStatus(1, selectedIndices.toString(), context!):
                    privacy.setAboutStatus(
                        2, selected.replaceAll("}", ""), context!);
                  }
                  break;

                  case "profile": {
                    (selectedIndices.isEmpty)?
                    privacy.setProfileStatus(1, selectedIndices.toString(), context!):
                    privacy.setProfileStatus(
                        2, selectedIndices.toString(), context!);
                  }
                  break;

                  case "group": {
                    (selectedIndices.isEmpty)?
                    privacy.setGroupStatus(1, selectedIndices.toString(), context!):
                    privacy.setGroupStatus(
                        2, selectedIndices.toString(), context!);
                  }
                  break;

                  default: {
                    //statements;
                  }
                  break;
                }

                print(selectedIndices.toString());


              },
              child: Icon(Icons.check),
            ),
          );
        }
    );*/
    return Consumer2<UserProvider, PrivacyProvider>(
        builder: (context, user1, privacy, child) {
      // privacy.blockedStatusUsers.forEach((user) =>  selectedIndices.add(int.parse(user['user_id'])));
      search(String val) {
        if (val.isEmpty) {
          privacy.getExceptedUsersAbout(context);
        } else {
          final fnd = privacy.blockedStatusUsers.where((element) {
            final name = element['name'].toString().toLowerCase();
            final input = val.toLowerCase();
            return name.contains(input);
          }).toList();
          // print(found);
          print('::::::[NAME]::::::');
          print(fnd);
          print('::::::[NAME]::::::');

          setState(() {
            privacy.getActualBlockedData(fnd);
          });
        }
      }

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
              top: 22,
              child: Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.only(top: 15.0),
                    child: BackButton(color: Colors.white),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 13.0),
                    child: Text(
                      'My contacts except...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              top: 65,
              left: 60,
              child: Row(
                children: [
                  (count == 0)
                      ? const Text(
                          //  user.data.length.toString() + " contacts",
                          'No contacts excluded',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          //  user.data.length.toString() + " contacts",
                          (count == 1)
                              ? '1 contact excluded'
                              : '$count contacts excluded',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        )
                ],
              ),
            ),
            (searchStatus == true)
                ? Positioned(
                    top: 40,
                    left: 50,
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
                          controller: _textEditingController,
                          onChanged: (value) {
                            search(value);
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
                right: 40,
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
                          });
                        },
                      )
                    : const SizedBox(
                        width: 0,
                      )
                //     :
                // IconButton(
                //   iconSize: 25,
                //   icon: const Icon(Icons.close,color: Colors.white,),
                //   onPressed: () {
                //     setState(() {
                //       searchStatus=false;
                //
                //       search("");
                //     });
                //   },
                // ),
                ),
            Positioned(
              top: 38,
              //left:0,
              right: 0,
              child: (searchStatus == false)
                  ? IconButton(
                      iconSize: 25,
                      icon: const Icon(
                        Icons.playlist_add_check,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // ...
                        print('selectAll');
                        print(selectAll);
                        setState(() {
                          (selectAll == true)
                              ? selectAll = false
                              : selectAll = true;
                          print(selectAll);
                          if (selectAll) {
                            selectedIndices = Set<int>.from(
                              List.generate(
                                  privacy.blockedStatusUsers.length,
                                  (index) => int.parse(privacy
                                      .blockedStatusUsers[index]['user_id'])),
                            );
                          } else {
                            selectedIndices.clear();
                          }
                          count = selectedIndices.length;
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
              padding: const EdgeInsets.only(top: 90.0),
              child: ListView.builder(
                itemCount: privacy.blockedStatusUsers.length,
                itemBuilder: (BuildContext context, int index) {
                  // Contact contact = _contacts[index];
                  //bool isChecked = selectedIndices.contains(user.data[index]['user_id']);

                  bool isChecked = selectedIndices.contains(
                      int.parse(privacy.blockedStatusUsers[index]['user_id']));
                  // bool isChecked = privacy.blockedStatusUsers[index]['excepted_user_status']?true:false;
                  print('isChecked : ');
                  print(selectedIndices);
                  print(
                      privacy.blockedStatusUsers[index]['user_id'].toString());
                  print(privacy.blockedStatusUsers[index]
                      ['excepted_user_status']);

                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (isChecked) {
                            selectedIndices.remove(int.parse(
                                privacy.blockedStatusUsers[index]['user_id']));
                            isChecked = false;
                          } else {
                            selectedIndices.add(int.parse(
                                privacy.blockedStatusUsers[index]['user_id']));
                            isChecked = true;
                          }
                          count = selectedIndices.length;
                        });
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(15)),
                            child: CircleAvatar(
                              backgroundImage: privacy.blockedStatusUsers[index]
                                          ['profile_pic'] !=
                                      null
                                  ? NetworkImage(privacy
                                      .blockedStatusUsers[index]['profile_pic'])
                                  : const NetworkImage(
                                      'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png'),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  privacy.blockedStatusUsers[index]['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                /*SizedBox(height: 5),

                                    Container(
                                      padding: new EdgeInsets.only(right: 0.0),
                                      width: MediaQuery.of(context).size.width - 180,
                                      child: new Text(
                                        privacy.blockedStatusUsers[index]['about'],
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                        style: TextStyle(
                                          color:  Color(0xFF9B9898)
                                          ,
                                        ),
                                      ),
                                    ),*/
                              ],
                            ),
                          ),
                          Transform.scale(
                            scale: 1.2,
                            child: Checkbox(
                              value: isChecked,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value != null && value) {
                                    selectedIndices.add(int.parse(privacy
                                        .blockedStatusUsers[index]['user_id']));
                                  } else {
                                    selectedIndices.remove(int.parse(privacy
                                        .blockedStatusUsers[index]['user_id']));
                                  }
                                  isChecked = selectedIndices.contains(
                                      int.parse(privacy
                                              .blockedStatusUsers[index][
                                          'user_id'])); // Update isChecked based on new selectedIndices list
                                  count = selectedIndices.length;
                                });
                              },
                              shape: const CircleBorder(),
                              checkColor: Colors.white,
                              activeColor: Colors.red,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              // You can adjust the size of the checkbox by using the below code
                              // visualDensity: VisualDensity.comfortable,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        /*floatingActionButton: FloatingActionButton(
              backgroundColor: rightGreen,
              onPressed: () {
                // Do something with selected contacts
                print(selectedIndices);
                print("selectedIndices");
                var selected = selectedIndices.toString().replaceAll("{", "");

                switch(widget.type) {
                  case "lastseen": {
                    (selectedIndices.isEmpty)?
                    privacy.setLastseenStatus(1, selectedIndices.toString(), context!):
                    privacy.setLastseenStatus(
                        2, selected.replaceAll("}", ""), context!);
                  }
                  break;

                  case "about": {
                    (selectedIndices.isEmpty)?
                    privacy.setAboutStatus(1, selectedIndices.toString(),"except" ,context!):
                    privacy.setAboutStatus(
                        2, selected.replaceAll("}", ""),"except", context!);
                  }
                  break;

                  case "profile": {
                    (selectedIndices.isEmpty)?
                    privacy.setProfileStatus(1, selectedIndices.toString(), context!):
                    privacy.setProfileStatus(
                        2, selected.replaceAll("}", ""), context!);
                  }
                  break;

                  case "group": {
                    print("llll");
                    (selectedIndices.isEmpty)?
                    privacy.setGroupStatus(1, selectedIndices.toString(), context!):
                    privacy.setGroupStatus(
                        2, selected.replaceAll("}", ""), context!);
                  }
                  break;

                  default: {
                    //statements;
                  }
                  break;
                }

                print(selectedIndices.toString());


              },
              child: Icon(Icons.check),
            ),*/
      );
    });
  }
}
