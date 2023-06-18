// import 'package:flutter/material.dart';
//
// class ImageSection extends StatefulWidget {
//   String imageUrl;
//
//   ImageSection({Key? key, required this.imageUrl}) : super(key: key);
//
//   @override
//   State<ImageSection> createState() => _ImageSectionState();
// }
//
// class _ImageSectionState extends State<ImageSection> {
//   @override
//   void initState() {
//     print('########################3');
//     print(widget.imageUrl);
//     print('########################3');
//     super.initState();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Stack(
//         children: [
//           SizedBox(
//             height: MediaQuery.of(context).size.height,
//             width: double.infinity,
//             child: Image(
//               image: NetworkImage(widget.imageUrl),
//               fit: BoxFit.contain,
//             ),
//           ),
//           Positioned(
//             top: 20,
//             child: IconButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
//           )
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
//
// class ImageSection extends StatefulWidget {
//   final String imageUrl;
//
//   ImageSection({Key? key, required this.imageUrl}) : super(key: key);
//
//   @override
//   State<ImageSection> createState() => _ImageSectionState();
// }

import 'package:flutter/material.dart';

class ImageSection extends StatelessWidget {
  final String imageUrl;

  ImageSection({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Hero(
            tag: imageUrl,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
