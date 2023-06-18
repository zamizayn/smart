import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/topSection.dart';
import 'package:smart_station/providers/EmailProvider/email_provider.dart';
import 'package:html/parser.dart';

import '../../../providers/AuthProvider/auth_provider.dart';
import 'apiServices.dart';
import 'email_send_view.dart';
import 'email_view_screen.dart';

class EmailSentScreen extends StatefulWidget {
  List allEmaildetails;

  EmailSentScreen({super.key, required this.allEmaildetails});

  @override
  State<EmailSentScreen> createState() => _EmailSentScreenState();
}

class _EmailSentScreenState extends State<EmailSentScreen> {
  var auth;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    auth = Provider.of<AuthProvider>(context, listen: false);

    var email = Provider.of<EmailProvider>(context, listen: false);
    email.getSendList(context);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: get_Send_Box_List(
          auth.userId,
          auth.accessToken,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.data.isEmpty) {
              return Scaffold(
                appBar: AppBar(
                    title: const Text(
                      'Sendbox',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    elevation: 0,
                    backgroundColor: Colors.white,
                    leading: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ))),
                body: const Center(
                  child: Text('No Send Email',
                      style: TextStyle(color: Colors.black, fontSize: 18)),
                ),
              );
            } else {
              print('hasdata');
              debugPrint(snapshot.hasData.toString());
              return Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                    title: const Text(
                      'Sendbox',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    elevation: 0,
                    backgroundColor: Colors.white,
                    leading: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ))),
                body: ListView.builder(
                  itemCount: snapshot.data!.data.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      child: snapshot.data!.data[index].type == 'date'
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                    child: Text(
                                  DateFormat('dd-MM-yyyy').format(
                                      snapshot.data!.data[index].createdAt),
                                )),
                              ],
                            )
                          : InkWell(
                              onTap: (() async {
                                print(snapshot.data!.data[index].type);
                                String Refresh = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => EmailSendView(
                                              allEmaildetails:
                                                  widget.allEmaildetails,
                                              emailId:
                                                  snapshot.data!.data[index].id,
                                            )));

                                print(snapshot.data!.data[index].id);
                              }),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Card(
                                    color: Colors.grey[300],
                                    child: CircleAvatar(
                                        maxRadius: 28,
                                        backgroundImage: NetworkImage(snapshot
                                            .data!.data[index].profilePic)),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(15))),
                                    width: MediaQuery.of(context).size.width /
                                        1.35,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10.0, right: 10.0, top: 10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        1.75 -
                                                    30,
                                                child: Text(
                                                  snapshot
                                                      .data!.data[index].from,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              Text(
                                                DateFormat('hh:mm a').format(
                                                    snapshot.data!.data[index]
                                                        .createdAt),
                                                // formattedTime.toLowerCase(),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            snapshot.data!.data[index].subject,
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.black
                                                // fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          SizedBox(
                                            height: 45,
                                            child: Text(
                                              parse(snapshot
                                                      .data!.data[index].body)
                                                  .documentElement!
                                                  .text,
                                              maxLines: 2,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                          snapshot.data!.data[index].attachments
                                                  .isEmpty
                                              ? const SizedBox()
                                              : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: const [
                                                    Icon(
                                                      Icons.attachment,
                                                      color: Colors.green,
                                                      size: 20.0,
                                                    ),
                                                  ],
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    );
                  },
                ),
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
        },
      );
}
