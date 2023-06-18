import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/screens/home_screen/letter/letter_detail_screen.dart';

import '../../../providers/LetterProvider/letter_provider.dart';
import 'package:html/parser.dart';

class LetterInboxScreen extends StatefulWidget {
  const LetterInboxScreen({Key? key}) : super(key: key);

  @override
  State<LetterInboxScreen> createState() => _LetterInboxScreenState();
}

class _LetterInboxScreenState extends State<LetterInboxScreen> {
  @override
  var letter;
    @override
  void initState() {
    // TODO: implement initState
    print('fd');
    super.initState();
    setState(() {
     letter = Provider.of<LetterProvider>(context,listen: false);
    letter.getInboxList(context);
    print(letter.inboxData.length);
    
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
    preferredSize: const Size.fromHeight(90.0), // Set the height of the app bar
    child: Container(
      // decoration: BoxDecoration(
      //       image: DecorationImage(
      //         image: AssetImage(splashBg),
      //         fit: BoxFit.fill,
      //       ),
      // ),
        color: Colors.black38,
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0),
            child: Row(
              children: const [
                BackButton(color: Colors.white),
                  Text(
                  'Letter Inbox',
                  style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                    ),
                  )
                  ],
                ),
              ),
            ),
          ),
      body:Center(
              child: //Text("Email devi"),
              ListView.builder(
                /*padding: EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 15,
          ),*/
                itemCount: letter.inboxData.length,
                itemBuilder: (context, index) {
                  final document = parse(letter.inboxData[index]['body']);
                  //final String parsedString = parse(document.body?.text).documentElement.text;
                  Uri url = Uri.parse(letter.inboxData[index]['profile_pic']);
                  DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
                  DateFormat dateFormat2 = DateFormat('dd-MM-yyyy');
                  DateFormat dateFormat3 = DateFormat('hh:mm a');
                  DateTime dateTime =
                  dateFormat.parse(letter.inboxData[index]['datetime']);
                  String formattedDate = dateFormat2.format(dateTime);
                  String formattedTime = dateFormat3.format(dateTime);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                    child:
                    letter.inboxData[index]['type']=='date'  ?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:[
                        Center(child: Text(
                          formattedDate,
                        )
                        ),
                      ],
                    )  :
                    InkWell(
                      onTap: (){
                        Email email = Email(
                          sender: letter.inboxData[index]['from'],
                          letter_id: letter.inboxData[index]['id'],
                          receiver: letter.inboxData[index]['to'],
                          bcc: letter.inboxData[index]['bcc'],
                          cc: letter.inboxData[index]['cc'],
                          status:letter.inboxData[index]['approval_status'],
                          subject: letter.inboxData[index]['subject'],
                          message: letter.inboxData[index]['body'],
                          date: letter.inboxData[index]['datetime'],
                          pdf:  letter.inboxData[index]['letter_path'],
                          profilePic: letter.inboxData[index]['profile_pic'],
                        );


                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LetterDetailScreen(email: email),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Card(
                            color: Colors.grey[300],
                            child: CircleAvatar(
                                maxRadius: 28,
                                backgroundImage: NetworkImage(letter.inboxData[index]['profile_pic'])
                              /*isValidLink(url) == false ? NetworkImage(user.data[index]['profile_pic'])
                                : NetworkImage("https://cdn.pixabay.com/photo/2019/08/11/18/59/icon-4399701_1280.png")*/
                            ),),
                          //SizedBox(width: 5),
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: const BorderRadius.all(Radius.circular(15))
                                ),
                                width: MediaQuery.of(context).size.width/1.35,
                                child: Padding(
                                  padding: const EdgeInsets.only(left:10.0,right: 10.0,top: 10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width/1.75-30,
                                            child: Flexible(
                                              child: Text(
                                                letter.inboxData[index]['from'],
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
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
                                        letter.inboxData[index]['subject'],
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: letter.inboxData[index]['mail_read_status']=='0' ? Colors.grey : Colors.black
                                          // fontWeight: FontWeight.bold,
                                        ),

                                      ),
                                      SizedBox(
                                        height: 45,
                                        child: Text(
                                          parse(document.body?.text).documentElement!.text,
                                          maxLines: 2,
                                          style: TextStyle(
                                            color: letter.inboxData[index]['mail_read_status']=='0' ? Colors.grey : Colors.black,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,

                                          ),
                                        ),
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
            ),
   
    );
  }
}
