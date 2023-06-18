import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smart_station/screens/home_screen/email/apiServices.dart';
import 'package:html/parser.dart';
import 'package:smart_station/screens/home_screen/email/emailListViewModeal.dart';
import '../../../providers/AuthProvider/auth_provider.dart';
import 'email_view_screen.dart';

class EmailScreen extends StatefulWidget {
  List allEmaildetails;

  EmailScreen({super.key, required this.allEmaildetails});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  @override
  void initState() {
    // TODO: implement initState
    print('fd');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: false);

    return FutureBuilder<GetmailList>(
      future: getmail_list(auth.userId, auth.accessToken, ''),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.data.isEmpty) {
            return const Center(
              child: Text('No Email',
                  style: TextStyle(color: Colors.black, fontSize: 18)),
            );
          } else {
            print('hasdata');
            debugPrint(snapshot.hasData.toString());
            return Scaffold(
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
                                      builder: (_) => EmailViewScreen(
                                            allEmaildetails:
                                                widget.allEmaildetails,
                                            emailId:
                                                snapshot.data!.data[index].id,
                                          )));
                              if (Refresh == 'Refresh') {
                                setState(() {
                                  getmail_list(
                                      auth.userId, auth.accessToken, '');
                                });
                              }
                              print(snapshot.data!.data[index].id);
                            }),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Card(
                                  color: Colors.grey[300],
                                  child: CircleAvatar(
                                      maxRadius: 28,
                                      backgroundImage: NetworkImage(
                                          snapshot.data!.data[index].profilePic)
                                    
                                      ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(15))),
                                  width:
                                      MediaQuery.of(context).size.width / 1.35,
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
                                                snapshot.data!.data[index].from,
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
                                              color: snapshot.data!.data[index]
                                                          .mailReadStatus ==
                                                      '0'
                                                  ? Colors.grey
                                                  : Colors.black
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
                                              color: snapshot.data!.data[index]
                                                          .mailReadStatus ==
                                                      '0'
                                                  ? Colors.grey
                                                  : Colors.black,
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
          return ListView.builder(
            itemCount: 8,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Shimmer.fromColors(
                      direction: ShimmerDirection.ttb,
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: const CircleAvatar(
                        maxRadius: 35,
                      ),
                    ),
                    Flexible(
                      child: Shimmer.fromColors(
                        direction: ShimmerDirection.ltr,
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                            height: 80,
                            width: 280,
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(30),
                            )),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
