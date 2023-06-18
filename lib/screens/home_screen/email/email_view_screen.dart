import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/AuthProvider/auth_provider.dart';
import '../../../utils/constants/app_constants.dart';
import '../popup_screens/widget/bottomSection.dart';
import 'apiServices.dart';
import 'emailAttachmentView.dart';
import 'email_compose_screen.dart';

class EmailViewScreen extends StatefulWidget {
  String emailId;
  List allEmaildetails;
  EmailViewScreen(
      {super.key, required this.emailId, required this.allEmaildetails});
  @override
  State<EmailViewScreen> createState() => _EmailViewScreenState();
}

class _EmailViewScreenState extends State<EmailViewScreen> {
  bool tomeButtonBool = false;
  bool undoPressed = false;

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    return FutureBuilder(
      future:
          get_inbox_mail_details(auth.userId, auth.accessToken, widget.emailId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: const Color(0xff999999),
              toolbarHeight: 100,
              elevation: 0,
              leading: IconButton(
                  onPressed: (() {
                    Navigator.pop(context, 'Refresh');
                  }),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                  )),
              actions: [
                // IconButton(
                //     onPressed: (() {}),
                //     icon: const Icon(
                //       Icons.archive,
                //       color: Colors.white,
                //       size: 30,
                //     )),
                IconButton(
                    onPressed: (() {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(seconds: 5),
                        content: const Text('Deleted'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            undoPressed = true;
                          },
                        ),
                      ));

                      Future.delayed(const Duration(seconds: 5), () {
                        if (undoPressed == true) {
                          print('hello');
                          undoPressed = false;
                        } else {
                          deleteEmail(auth.userId, auth.accessToken,
                                  widget.emailId, 'inbox')
                              .then((value) {
                            Navigator.pop(context, 'Refresh');

                            print(value.body);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              getmail_list(auth.userId, auth.accessToken, '');
                            });
                          });
                        }
                      });
                    }),
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 30,
                    )),
                // InkWell(
                //   onTap: () {},
                //   child: Image.asset(
                //     countIcon,
                //     color: Colors.white,
                //     height: 35,
                //     width: 35,
                //   ),
                // ),
                // IconButton(
                //     onPressed: (() {}),
                //     icon: const Icon(
                //       Icons.more_vert,
                //       color: Colors.white,
                //       size: 30,
                //     ))
              ],
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    snapshot.data!.data.subject,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30),
                                  ),
                                ),
                                Chip(
                                  label: const Text(
                                    'Inbox',
                                    style: TextStyle(),
                                  ),
                                  backgroundColor: Colors.grey.shade300,
                                ),
                              ],
                            ),
                          ),
                          // IconButton(
                          //   onPressed: () {},
                          //   icon: const Icon(
                          //     Icons.star_border,
                          //     color: Colors.black,
                          //     size: 30,
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey.shade700,
                            radius: 40,
                            child: const Center(
                                child: Text(
                              'N',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 55),
                            )),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            height: 70,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 250,
                                      child: Text(
                                        snapshot.data!.data.from,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 15,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('MMM dd').format(
                                          snapshot.data!.data.createdDatetime),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: 290,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'to me ',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (tomeButtonBool == false) {
                                              tomeButtonBool = true;
                                            } else {
                                              tomeButtonBool = false;
                                            }
                                          });
                                        },
                                        child: const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const Spacer(),
                                      InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        EmailComposeScreen(
                                                          forwardbool: false,
                                                          replayBody:
                                                              "<div class=><div class=\"aHl\"></div><div id=\":xx\" tabindex=\"-1\"></div><div id=\":y8\" class=\"ii gt adO\" jslog=\"20277; u014N:xr6bB; 1:WyIjdGhyZWFkLWY6MTc1OTc5OTQyNTM2MTM4Mzk3MyIsbnVsbCxudWxsLG51bGwsbnVsbCxudWxsLG51bGwsbnVsbCxudWxsLG51bGwsbnVsbCxudWxsLG51bGwsW11d; 4:WyIjbXNnLWE6cjQ4NjE5NzQ5NTQ0ODQ4NTQ2NzQiLG51bGwsW11d\"><div id=\":y9\" class=\"a3s aiL \"><div dir=\"ltr\"></div><br><div class=\"gmail_quote\"><div dir=\"ltr\" class=\"gmail_attr\">On ${DateFormat('EEEE, MMMM d, y h:mm a').format(snapshot.data!.data.createdDatetime)},&lt;<a href=\"mailto:${snapshot.data!.data.to.join(",")}\" target=\"_blank\">${snapshot.data!.data.to.join(",")}</a>&gt; wrote:<br></div><blockquote class=\"gmail_quote\" style=\"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex\"><div dir=\"auto\">${snapshot.data!.data.body}</div><div class=\"yj6qo\"></div><div class=\"adL\"></div></blockquote></div><div class=\"adL\"></div></div></div><div id=\":xs\" class=\"ii gt\" style=\"display:none\"><div id=\":xr\" class=\"a3s aiL \"></div></div><div class=\"hi\"></div></div>",
                                                          emailList: const [],
                                                          replayEmail: snapshot
                                                              .data!.data.to
                                                              .join(','),
                                                          replaySubject:
                                                              'Re:${snapshot.data!.data.subject}',
                                                        )));
                                          },
                                          child:
                                              const Icon(Icons.reply_rounded)),
                                      // InkWell(
                                      //     onTap: () {},
                                      //     child: const Icon(Icons.more_vert))
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      tomeButtonBool == true
                          ? Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('From: ${snapshot.data!.data.from}',
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700)),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "To: ${snapshot.data!.data.to.join(",")}",
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Date: ${DateFormat('MMM dd, yyyy, h:mm a').format(snapshot.data!.data.createdDatetime)}",
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox(),
                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        height: 30,
                        color: Colors.grey.shade200,
                      ),
                      Html(
                        data: snapshot.data!.data.body,
                        style: {
                          'body': Style(
                            fontSize: FontSize(20),
                            fontWeight: FontWeight.normal,
                          ),
                        },
                      ),
                      Container(
                        height: 30,
                        color: Colors.grey.shade200,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: SizedBox(
                          width: 300,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.data.attachments.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  InkWell(
                                    onTap: (() async {
                                      if (path.extension(snapshot.data!.data
                                                  .attachments[index]) ==
                                              '.jpg' ||
                                          path.extension(snapshot.data!.data
                                                  .attachments[index]) ==
                                              '.jpeg' ||
                                          path.extension(snapshot.data!.data
                                                  .attachments[index]) ==
                                              '.png' ||
                                          path.extension(snapshot.data!.data
                                                  .attachments[index]) ==
                                              '.pdf') {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    EmailAttachmentView(
                                                      filetype: path.extension(
                                                          snapshot.data!.data
                                                                  .attachments[
                                                              index]),
                                                      pdfUrl: snapshot
                                                          .data!
                                                          .data
                                                          .attachments[index],
                                                    )));
                                      } else {
                                        if (await canLaunch(snapshot
                                            .data!.data.attachments[index])) {
                                          await launch(snapshot
                                              .data!.data.attachments[index]);
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Could not launch ${snapshot.data!.data.attachments[index]}'),
                                            ),
                                          );
                                        }
                                      }
                                    }),
                                    child: Container(
                                        height: 250,
                                        width: 400,
                                        color: Colors.grey.shade200,
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const SizedBox(
                                                height: 60,
                                              ),
                                              const Icon(
                                                Icons.file_copy,
                                                size: 40,
                                              ),
                                              const SizedBox(
                                                height: 50,
                                              ),
                                              const Spacer(),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  path.extension(snapshot
                                                                  .data!
                                                                  .data
                                                                  .attachments[
                                                              index]) ==
                                                          '.png'
                                                      ? const Icon(Icons.image)
                                                      : const Icon(
                                                          Icons.picture_as_pdf),
                                                  const SizedBox(
                                                    width: 30,
                                                  ),
                                                  //const Icon(Icons.download),
                                                ],
                                              )
                                            ],
                                          ),
                                        )),
                                  ),
                                  const SizedBox(
                                    height: 25,
                                  )
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 70),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                height: 60,
                                width: 110,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    elevation: 0,
                                    side: BorderSide(
                                        width: 1, color: Colors.grey.shade400),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25)),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => EmailComposeScreen(
                                                  replayBody:
                                                      "<div class=><div class=\"aHl\"></div><div id=\":xx\" tabindex=\"-1\"></div><div id=\":y8\" class=\"ii gt adO\" jslog=\"20277; u014N:xr6bB; 1:WyIjdGhyZWFkLWY6MTc1OTc5OTQyNTM2MTM4Mzk3MyIsbnVsbCxudWxsLG51bGwsbnVsbCxudWxsLG51bGwsbnVsbCxudWxsLG51bGwsbnVsbCxudWxsLG51bGwsW11d; 4:WyIjbXNnLWE6cjQ4NjE5NzQ5NTQ0ODQ4NTQ2NzQiLG51bGwsW11d\"><div id=\":y9\" class=\"a3s aiL \"><div dir=\"ltr\"></div><br><div class=\"gmail_quote\"><div dir=\"ltr\" class=\"gmail_attr\">On ${DateFormat('EEEE, MMMM d, y h:mm a').format(snapshot.data!.data.createdDatetime)},&lt;<a href=\"mailto:${snapshot.data!.data.to.join(",")}\" target=\"_blank\">${snapshot.data!.data.to.join(",")}</a>&gt; wrote:<br></div><blockquote class=\"gmail_quote\" style=\"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex\"><div dir=\"auto\">${snapshot.data!.data.body}</div><div class=\"yj6qo\"></div><div class=\"adL\"></div></blockquote></div><div class=\"adL\"></div></div></div><div id=\":xs\" class=\"ii gt\" style=\"display:none\"><div id=\":xr\" class=\"a3s aiL \"></div></div><div class=\"hi\"></div></div>",
                                                  emailList: const [],
                                                  replayEmail: snapshot
                                                      .data!.data.to
                                                      .join(','),
                                                  replaySubject:
                                                      'Re:${snapshot.data!.data.subject}',
                                                  forwardbool: false,
                                                )));
                                  },
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.reply_rounded,
                                        color: Colors.black,
                                      ),
                                      Text(
                                        'Replay',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 60,
                                width: 120,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    elevation: 0,
                                    side: BorderSide(
                                        width: 1, color: Colors.grey.shade400),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25)),
                                  ),
                                  onPressed: () {
                                    List allemails = snapshot.data!.data.to +
                                        snapshot.data!.data.cc +
                                        snapshot.data!.data.bcc;
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => EmailComposeScreen(
                                                  replayBody:
                                                      "<div class=><div class=\"aHl\"></div><div id=\":xx\" tabindex=\"-1\"></div><div id=\":y8\" class=\"ii gt adO\" jslog=\"20277; u014N:xr6bB; 1:WyIjdGhyZWFkLWY6MTc1OTc5OTQyNTM2MTM4Mzk3MyIsbnVsbCxudWxsLG51bGwsbnVsbCxudWxsLG51bGwsbnVsbCxudWxsLG51bGwsbnVsbCxudWxsLG51bGwsW11d; 4:WyIjbXNnLWE6cjQ4NjE5NzQ5NTQ0ODQ4NTQ2NzQiLG51bGwsW11d\"><div id=\":y9\" class=\"a3s aiL \"><div dir=\"ltr\"></div><br><div class=\"gmail_quote\"><div dir=\"ltr\" class=\"gmail_attr\">On ${DateFormat('EEEE, MMMM d, y h:mm a').format(snapshot.data!.data.createdDatetime)},&lt;<a href=\"mailto:${snapshot.data!.data.to.join(",")}\" target=\"_blank\">${snapshot.data!.data.to.join(",")}</a>&gt; wrote:<br></div><blockquote class=\"gmail_quote\" style=\"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex\"><div dir=\"auto\">${snapshot.data!.data.body}</div><div class=\"yj6qo\"></div><div class=\"adL\"></div></blockquote></div><div class=\"adL\"></div></div></div><div id=\":xs\" class=\"ii gt\" style=\"display:none\"><div id=\":xr\" class=\"a3s aiL \"></div></div><div class=\"hi\"></div></div>",
                                                  emailList: const [],
                                                  replayEmail:
                                                      allemails.join(','),
                                                  replaySubject:
                                                      'Re:${snapshot.data!.data.subject}',
                                                  forwardbool: false,
                                                )));
                                    print(allemails.join(','));
                                  },
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.reply_all_sharp,
                                        color: Colors.black,
                                      ),
                                      Text(
                                        'Replay all',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 60,
                                width: 110,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    elevation: 0,
                                    side: BorderSide(
                                        width: 1, color: Colors.grey.shade400),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25)),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => EmailComposeScreen(
                                                  forwardbool: true,
                                                  emailList:
                                                      widget.allEmaildetails,
                                                  replayEmail: '',
                                                  replaySubject: '',
                                                  replayBody:
                                                      "<div class=\"gmail_quote\"><div dir=\"ltr\" class=\"gmail_attr\">---------- Forwarded message ---------<br>From: <strong class=\"gmail_sendername\" dir=\"auto\"></strong> <span dir=\"auto\">&lt;<a href=\"${snapshot.data!.data.from}\" target=\"_blank\">${snapshot.data!.data.from}</a>&gt;</span><br>Date:${DateFormat('EEEE, MMMM d, y h:mm a').format(snapshot.data!.data.createdDatetime)}<br>Subject:${snapshot.data!.data.subject}<br>To: &lt;<a href=\"mailto:fss.reshma@gmail.com\" target=\"_blank\">${snapshot.data!.data.to.join(",")}</a>&gt;<br></div><br><br><div dir=\"ltr\">${snapshot.data!.data.body}</div><div class=\"yj6qo\"></div><div class=\"adL\"></div></div>",
                                                )));
                                  },
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.forward,
                                        color: Colors.black,
                                      ),
                                      Text(
                                        'Forward',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          // Row(
                          //   children: [
                          //     Spacer(),
                          //     SizedBox(
                          //       height: 60,
                          //       width: 110,
                          //       child: ElevatedButton(
                          //         style: ElevatedButton.styleFrom(
                          //           backgroundColor: Colors.white,
                          //           elevation: 0,
                          //           side: BorderSide(
                          //               width: 1, color: Colors.grey.shade400),
                          //           shape: RoundedRectangleBorder(
                          //               borderRadius: BorderRadius.circular(25)),
                          //         ),
                          //         onPressed: () {},
                          //         child: Row(
                          //           children: [
                          //             Icon(
                          //               Icons.check_box_outlined,
                          //               color: Colors.green,
                          //             ),
                          //             Text(
                          //               "Approve",
                          //               style: TextStyle(
                          //                   color: Colors.black,
                          //                   fontWeight: FontWeight.bold),
                          //             ),
                          //           ],
                          //         ),
                          //       ),
                          //     ),
                          //     SizedBox(
                          //       width: 25,
                          //     ),
                          //     SizedBox(
                          //       height: 60,
                          //       width: 110,
                          //       child: ElevatedButton(
                          //         style: ElevatedButton.styleFrom(
                          //           backgroundColor: Colors.white,
                          //           elevation: 0,
                          //           side: BorderSide(
                          //               width: 1, color: Colors.grey.shade400),
                          //           shape: RoundedRectangleBorder(
                          //               borderRadius: BorderRadius.circular(25)),
                          //         ),
                          //         onPressed: () {},
                          //         child: Row(
                          //           children: [
                          //             Text(
                          //               "Reject",
                          //               style: TextStyle(
                          //                   color: Colors.black,
                          //                   fontWeight: FontWeight.bold),
                          //             ),
                          //             Icon(
                          //               Icons.cancel_presentation_sharp,
                          //               color: Colors.red,
                          //             ),
                          //           ],
                          //         ),
                          //       ),
                          //     ),
                          //     Spacer(),
                          //   ],
                          // )
                        ],
                      )
                    ]),
              ),
            ),
            bottomNavigationBar: Container(
              color: Colors.grey[300],
              height: 100,
              child: Column(
                children: const [
                  SizedBox(
                    height: 35,
                  ),
                  Center(child: BottomSectionTransp()),
                ],
              ),
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
