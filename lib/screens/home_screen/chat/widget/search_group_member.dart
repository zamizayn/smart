import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/providers/ChatDetailProvider/chatdetail_provider.dart';
import 'package:smart_station/providers/UserProvider/user_provider.dart';
import 'package:smart_station/screens/home_screen/chat/api/individual_chat_section.dart';
import 'package:smart_station/screens/home_screen/chat/newConvoScreen.dart';
import 'package:smart_station/utils/constants/app_constants.dart';


class SearchList extends StatefulWidget {
  
   const SearchList({Key? key,}) : super(key: key);

  @override
  State<SearchList> createState() => _SearchListState();
}

class _SearchListState extends State<SearchList> {
  final TextEditingController _textEditingController = TextEditingController();
  // List<dynamic> userData = [];
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, user, child) {
        // final data = jsonDecode(user.resMessage);
        // userData = user.data;

        search(String val) {
          if (val.isEmpty) {
            user.userList(context:context);
          }
          else{
            final fnd = user.data.where((element) {
              final name = element['name'].toString().toLowerCase();
              final input = val.toLowerCase();
              return name.contains(input);
            }).toList();
          // print(found);
          print('::::::[NAME]::::::');
          print(fnd);
          print('::::::[NAME]::::::');

          setState(() {
            user.getActualData(fnd);
          });
        }
        }


        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 0),
              decoration: BoxDecoration(
                color:  Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child:
              TextField(
                controller: _textEditingController,
                onChanged: (value) {

                  search(value);
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search...',
                  prefixIcon: Icon(
                    Icons.search,
                  ),
                ),
              ),
            ),
            leading: BackButton(color: rightGreen),
          ),
          body:
          ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            itemCount: user.data.length,
            itemBuilder: (context, index) {
              var client = http.Client();
              Uri url = Uri.parse(user.data[index]['profile_pic']);

              return Column(
                children: [
                  InkWell(
                    onTap: (){
                      print( user.data[index]['deviceToken']);

                      var cdp = Provider.of<ChatDetailProvider>(context, listen: false);
                      var auth = Provider.of<AuthProvider>(context, listen: false);
                      getPrivateChatDetails(auth.userId, auth.accessToken, user.data[index]['user_id']);
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => NewConversation(rId: user.data[index]['user_id'],
                      toFcm: user.data[index]['deviceToken'], roomId: user.data[index]['room'],
                      )));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(15)),
                            child: CircleAvatar(
                              backgroundImage: user.data[index]['profile_pic'] !=
                                  null
                                  ? NetworkImage(
                                  user.data[index]['profile_pic'])
                                  : const NetworkImage(
                                  'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png'),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.data[index]['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 5),

                                Container(
                                  padding: const EdgeInsets.only(right: 0.0),
                                  width: MediaQuery.of(context).size.width - 140,
                                  child: Text(
                                    user.data[index]['about'],
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style: const TextStyle(
                                      color:  Color(0xFF9B9898)
                                          ,
                                    ),
                                  ),
                                ),

                            ],
                          ),
                          const Spacer(),
                          /*Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              //Text(dateTime.toString().substring(0,10)),
                              Text(formattedDate,
                                  style: TextStyle(fontSize: 12)),
                              if (recent.recentChat[index]['unread_message'] !=
                                  "0")
                                Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: rightGreen,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      recent.recentChat[index]
                                      ['unread_message'],
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                  ),
                                )
                            ],
                          )*/
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Divider(),
                  ),
                ],
              );

             /* return Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                Row(
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
                   /* Card(
                      child:
                      CircleAvatar(
                          maxRadius: 28,
                          backgroundImage: NetworkImage(user.data[index]['profile_pic'])
                          /*isValidLink(url) == false ? NetworkImage(user.data[index]['profile_pic'])
                              : NetworkImage("https://cdn.pixabay.com/photo/2019/08/11/18/59/icon-4399701_1280.png")*/
                    ),),*/
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.data[index]['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user.data[index]['about'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Divider(),
                        ),
                      ],
                    ),
                  ],
                ),
              );*/
            },
          ),
        );

      },

    );
  }
   Future<bool> isValidLink(Uri url) async {
    http.Response response = await http.head(url);
    if (response.statusCode == 404) {
      print('False');
      return false;
    } else {
      print('True');
      return true;
    }
  }

}
