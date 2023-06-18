import 'package:flutter/material.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:smart_station/screens/home_screen/cloud/cloud_screen.dart';
import 'package:smart_station/providers/CloudProvider/cloud_provider.dart';
import 'package:provider/provider.dart';

class BottomContainer extends StatelessWidget {
  const BottomContainer({Key? key}) : super(key: key);


  void _showBottomSheet(BuildContext context) {
    var cloud = Provider.of<CloudProvider>(context,listen: false);
    cloud.getCloudParentList(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 120,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),

            ),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 20,
              ),
              Container(
               /* decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1.0,
                    ),
                  ),
                ),*/
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);

                           Navigator.push(context, MaterialPageRoute(builder: (_) => const CloudScreen()));
                          },
                          icon: ImageIcon(AssetImage(cloudIcon), color: rightGreen, size: 80),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          'Cloud',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.shopping_cart,color: rightGreen,size: 40,),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          'eShop',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: ImageIcon(AssetImage(dollarIcon), color: rightGreen, size: 60),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          'Payment',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            ],
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
        height: 80,
      width: MediaQuery.of(context).size.width,
      color: Colors.grey[300],
      child:   Center(
          child: SizedBox(
            height: 27,
            child: Image(image: AssetImage(transpLogo)),
          ),
        ),
        ),
      
        Positioned(
          right: 10,
          top: 10,
          child:  Container(
            padding: const EdgeInsets.only(right: 7),
              child: IconButton(
                  onPressed: () {
                    _showBottomSheet(context);
                   // Navigator.push(context, MaterialPageRoute(builder: (_) => CloudScreen()));
                  },
                  icon: Icon(
                    Icons.add,
                    color: rightGreen,
                    size: 40,
                  ))),)
      ],
    );
    // return Container(
    //   height: 80,
    //   width: MediaQuery.of(context).size.width,
    //   color: Colors.grey[300],
    //   child: Row(
    //     children: [
    //       Spacer(),
    //       SizedBox(
    //         height: 27,
    //         child: Image(image: AssetImage(transpLogo)),
    //       ),
    //       Spacer(),
    //       Container(
    //         padding: EdgeInsets.only(right: 7),
    //           child: IconButton(
    //               onPressed: () {
    //                 _showBottomSheet(context);
    //                // Navigator.push(context, MaterialPageRoute(builder: (_) => CloudScreen()));
    //               },
    //               icon: Icon(
    //                 Icons.add,
    //                 color: rightGreen,
    //                 size: 40,
    //               ))),
    //     ],
    //   ),
    // );
  }
}
