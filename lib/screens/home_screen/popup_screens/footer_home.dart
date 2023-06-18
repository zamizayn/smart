import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/screens/home_screen/popup_screens/footer_add.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/bottomSection.dart';
import 'package:smart_station/screens/home_screen/popup_screens/widget/topSection.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:smart_station/providers/AccountProvider/account_provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_station/screens/home_screen/popup_screens/imageview.dart';


class FooterHome extends StatefulWidget {
   const FooterHome({Key? key}) : super(key: key);

  @override
  State<FooterHome> createState() => _FooterHomeState();
}

class _FooterHomeState extends State<FooterHome> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('hhhh');
    var account = Provider.of<AccountProvider>(context,listen: false);
    account.getFooter(context);
  }
  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        width: MediaQuery.of(context).size.width-50,
        content: Center(child: Text(message,style: const TextStyle(color: Colors.white),)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, account, child) {
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
                top: 40,
                left: 0,
                right: 20,

                child: Row(
                  children: [
                    const BackButton(color: Colors.white),
                    const Text(
                      'Footer List',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),

                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () =>
                          Navigator.push(context, MaterialPageRoute(builder: (
                              _) => const FooterAddScreen())),
                      child:
                      Tooltip(
                      message: 'Add Footer',
                      child: Container(
                        width: 35,
                        height: 21,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[200],
                        ),
                        child: Center(
                            child: Image(
                              width: 18,
                              height: 18,
                              image: AssetImage(plus_Icon),
                            )
                        ),
                      ),
                    ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 90,
                // right: 20,
                bottom: 20,
                child: SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  /*height: MediaQuery
                        .of(context)
                        .size
                        .height / 3,*/
                  // color: Colors.red,
                  child:
                  (account.footData.isNotEmpty)?
                  ListView.builder(

                    itemCount: account.footData.length,
                    itemBuilder: (context, index) {
                    var name = account.footData[index]['name'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40,
                            vertical: 20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(account.footData[index]['name'],
                                  style: const TextStyle(
                                      fontSize: 17, color: Colors.grey),),
                                account.footData[index]['default'] == false ?
                                InkWell(
                                    onTap: () {
                                      showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) => AlertDialog(
                                          title: const Text('Footer Image'),
                                          content: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(30.0),
                                              color: Colors.white,
                                            ),
                                            padding: const EdgeInsets.all(0.0),
                                            child: Text.rich(
                                              TextSpan(
                                                text: 'Do you want to set ',
                                                style: const TextStyle(fontSize: 16),
                                                children: [
                                                  TextSpan(
                                                    text: '$name',
                                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  const TextSpan(
                                                    text: ' as default footer?',
                                                  ),
                                                ],
                                              ),
                                            )
                                            ,
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {

                                                account.setDefaultFooter(
                                                    account.footData[index]['id'],account.footData[index]['name'], context);

                                              },
                                              child: const Text(
                                                'YES',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, 'Cancel'),
                                              child: const Text(
                                                'NO',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),

                                          ],
                                        ),
                                      );

                                    },
                                    child: const Text('Set as primary',
                                        style: TextStyle(
                                            fontSize: 17, color: Colors.green))
                                )
                                    : const Text('Primary', style: TextStyle(
                                    fontSize: 17, color: Colors.green))
                              ],
                            ),
                            const SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                DottedBorder(
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(12),
                                  dashPattern: const [8, 4],
                                  strokeWidth: 2,
                                  color: account.footData[index]['default'] == true
                                      ? Colors.green
                                      : Colors.grey,
                                  child:
                                  InkWell(
                                    onTap:(){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ImageView(imageUrl: account.footData[index]['image'],name:account.footData[index]['name'],ctx:context),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      child:
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child:
                                        ClipRect( child: Image.network(account.footData[index]['image'],
                                          width: MediaQuery.of(context).size.width/1.6,
                                          height: 80,
                                          fit: BoxFit.contain,)),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap:() {
                                    (account.footData[index]['default'] == true)?
                                    showToast('Set another one as primary then only can delete')
                                        :
                                    showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) => AlertDialog(
                                        title: const Text('Footer Image'),
                                        content: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(30.0),
                                            color: Colors.white,
                                          ),
                                          padding: const EdgeInsets.all(0.0),
                                          child: const Text('Do you want to delete this footer?'),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              account.removeFooter(account.footData[index]['id'], context);
                                            },
                                            child: const Text(
                                              'YES',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, 'Cancel'),
                                            child: const Text(
                                              'NO',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: Tooltip(
                                      message: 'Delete Footer',
                                      child: ImageIcon(AssetImage(trashIcon),color: Colors.grey[600],size: 30,)
                                  ),
                                )

                              ],
                            ),
                          ],

                        ),
                      );
                    },
                  ):
                  const Center(child:Text(
                    'No footer found',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey
                    ),
                  ),),

                ),
              ),
              const Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child:
                BottomSectionTransp(),
              ),

            ],
          ),
        );
      }
    );
  }
}
