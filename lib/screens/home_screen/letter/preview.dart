import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:smart_station/providers/LetterProvider/letter_provider.dart';


class PreviewScreen extends StatefulWidget {
 final header;
  final address;
  final subject;
  final body;
  final sign;
  final stamp;
  final footer;
  final cc;
  final bcc;
  final sent;
  final String? id;
  const PreviewScreen({Key? key,this.header,this.address,this.subject,this.body,this.sign,this.stamp,this.footer,
  this.cc,this.bcc,this.sent, this.id}) : super(key: key);

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  @override
   String Stamp='';
  String  Signature='';
  String Header='';
  String Footer='';
  @override
  Widget build(BuildContext context) {
     bool undoPressed=false;
   // return const Placeholder();
   return Scaffold(
    appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: AppBar(
          backgroundColor: Colors.black38,
          title: const Text('Preview'),
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  print('id------------${widget.id}');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(seconds: 5),
                        content: const Text('Sent'),
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
                        } else {
                          if(widget.id== null){
                           _sendMail(context);
                          }
                          else{
                            _sendDraftMail(context);
                          }
                        }
                      });
                  
                 
                },
                icon: const Icon(Icons.send),
              )
            ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(border: Border.all()),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Image.network(widget.header,height: 50,width: MediaQuery.of(context).size.width,),
                   const SizedBox(height: 20,),
                   Text('Date : ${DateTime.now().toString().substring(0,10)}',style: const TextStyle(fontSize: 18),),
                    const SizedBox(height:10,),
                   Text('${widget.address}',style: const TextStyle(fontSize: 18),),
                   const SizedBox(height:10,),
                   Text('Subject: ${widget.subject}',style: const TextStyle(fontSize: 18),),
                   const SizedBox(height: 10,),
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 10),
                     child: Text(widget.body,style: const TextStyle(fontSize: 18),),
                   ),
                   const SizedBox(height: 10,),
                  Image.network(widget.sign,height: 50,width: 50,),
                   const SizedBox(height: 10,),
                   Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                     children: [
                      Image.network(widget.stamp,height: 50,width: 50,),
                     ],
                   ),
                   // SizedBox(height: 20,),
                   Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                     children: [
                      Image.asset(barCode,height: 50,width: 50,),
                     ],
                   ),
                   const SizedBox(height: 20,),
                  Image.network(widget.footer,height: 50,width: MediaQuery.of(context).size.width,),
                  ],
                )
            ),
          ),
        ),
      ),
   );
  }
  void _sendMail(contexts) {
    print('normal lettter');
    print('------------------------------------------');
     var mailP = Provider.of<LetterProvider>(context, listen: false);
     print('${widget.sent}\n${widget.body}.\n${widget.address}\n');
                mailP.sendLetter(widget.sent,widget.address,
            widget.body,widget.header,widget.footer,widget.sign,widget.stamp,context,
            ccMail: widget.cc,
            bccMail: widget.bcc,
            subject: widget.subject,
            //attachment: fileData
            );
  }
   void _sendDraftMail(contexts) {
    //  var mailP = Provider.of<LetterProvider>(context, listen: false);
    //  print("${widget.sent}\n${widget.body}.\n${widget.address}\n");
    print('draft letter');
    print('---------------------------------------------');
                LetterProvider().sendDraftLetter(widget.sent,widget.address,
            widget.body,widget.header,widget.footer,widget.sign,widget.stamp,context,
            widget.cc,
             widget.bcc,
             widget.subject,
             widget.id!
            //attachment: fileData
            );
  }
}
