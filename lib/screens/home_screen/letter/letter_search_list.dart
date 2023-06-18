import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/LetterProvider/letter_provider.dart';
import '../../../utils/constants/app_constants.dart';
import 'letter_detail_screen.dart';
import 'package:html/parser.dart';
class LetterSearchList extends StatefulWidget {
  const LetterSearchList({super.key});

  @override
  State<LetterSearchList> createState() => _LetterSearchListState();
}
List filter = [];
class _LetterSearchListState extends State<LetterSearchList> {
  @override
  //List filter = [];
  void initState() {
    filter=LetterProvider().filteredLetter;
    // TODO: implement initState
    super.initState();
  }
  TextEditingController searchController =TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Consumer<LetterProvider>(
        builder: (context, letter, child) {
          search(String val) {
              filter = letter.filteredLetter.where((element) =>
                      element['from'].toString().toLowerCase().contains(searchController.text.toLowerCase())
                     
                    ).toList();
                    print(searchController.text);
                    print('-------------------------');
                    print(filter);
                 
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
                controller: searchController,
                onChanged: (value) {
                 setState(() {
                      filter = letter.filteredLetter.where((element) =>
                      element['from'].toString().toLowerCase().contains(searchController.text.toLowerCase() )
                     ||  element['subject'].toString().toLowerCase().contains(searchController.text.toLowerCase() )
                     ||  element['body'].toString().toLowerCase().contains(searchController.text.toLowerCase() )
                    ).toSet().toList();
                 });
                  //search(value);
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
           body: Center(
              child: //Text("Email devi"),
              ListView.builder(
                /*padding: EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 15,
          ),*/
                itemCount: filter.length,
                itemBuilder: (context, index) {
                  
                 //print("selectedLetter--------------$selectedLetter");
                  final document = parse(filter[index]['body']);
                  //final String parsedString = parse(document.body?.text).documentElement.text;
                  Uri url = Uri.parse(filter[index]['profile_pic']);
                  DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
                  DateFormat dateFormat2 = DateFormat('dd-MM-yyyy');
                  DateFormat dateFormat3 = DateFormat('hh:mm a');
                  DateTime dateTime =
                  dateFormat.parse(filter[index]['datetime']);
                  String formattedDate = dateFormat2.format(dateTime);
                  String formattedTime = dateFormat3.format(dateTime);
                  print(filter[index]['from'].contains(searchController.text));
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15,),
                    child:
                    filter[index]['type']=='date'  ?
                    Column(
                      children: const [
                     
                      ],
                    )  :
                    InkWell(
                      onTap: (){
                        Email email = Email(
                          sender: filter[index]['from'],
                          letter_id: filter[index]['id'],
                          receiver: filter[index]['to'],
                          bcc: filter[index]['bcc'],
                          cc: filter[index]['cc'],
                          status: filter[index]['approval_status'],
                          subject: filter[index]['subject'],
                          message: filter[index]['body'],
                          date: filter[index]['datetime'],
                          pdf:  filter[index]['letter_path'],
                          profilePic: filter[index]['profile_pic'],
                        );
                          Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (_) =>LetterDetailScreen(email: email) ));
                      },
                     
                      child: Column(
                        children: [
                          const SizedBox(height: 15,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Card(
                                color: Colors.grey[300],
                                child: CircleAvatar(
                                    maxRadius: 28,
                                    backgroundImage: NetworkImage(filter[index]['profile_pic'])
                                  /*isValidLink(url) == false ? NetworkImage(user.data[index]['profile_pic'])
                                    : NetworkImage("https://cdn.pixabay.com/photo/2019/08/11/18/59/icon-4399701_1280.png")*/
                                ),),
                              //SizedBox(width: 5),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: const BorderRadius.all(Radius.circular(15))
                                ),
                                width: MediaQuery.of(context).size.width/1.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left:10.0,right: 10.0,top: 10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width/2-40,
                                            child: Text(
                                              filter[index]['from'],
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width:20,
                                          ),
                                          Text(
                                            formattedTime.toLowerCase(),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        filter[index]['subject'],
                                        style: TextStyle(
                                            fontSize: 13,
                                            //fontWeight:letter.inboxData[index]['mail_read_status'].toString()=="0" ? FontWeight.bold:FontWeight.normal,
                                            color: filter[index]['mail_read_status'].toString()=='0' ? Colors.grey : Colors.black
                                          // fontWeight: FontWeight.bold,
                                        ),
                                          
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            height: 40,
                                            width: MediaQuery.of(context).size.width/1.9,
                                            child: Text(
                                              parse(document.body?.text).documentElement!.text,
                                              maxLines: 2,
                                              style: TextStyle(
                                                color: filter[index]['mail_read_status'].toString()=='0' ? Colors.grey : Colors.black,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400,
                                          
                                              ),
                                            ),
                                          ),
                                          //const Spacer(),
                                          //Icon(Icons.star,color:filter[index]['starred_status']==1?Colors.yellow :Colors.white,)
                                        ],
                                      ),
                                    ],
                                  ),
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
    );});
  }
}