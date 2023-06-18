import 'package:flutter/material.dart';

import '../../../../../utils/constants/app_constants.dart';
import '../../../../../utils/constants/urls.dart';
import '../image_section.dart';
import '../pdf_section.dart';
import '../video_section.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;

const double BUBBLE_RADIUS = 16;

///basic chat bubble type
///
///chat bubble [BorderRadius] can be customized using [bubbleRadius]
///chat bubble color can be customized using [color]
///chat bubble tail can be customized  using [tail]
///chat bubble display message can be changed using [text]
///[text] is the only required parameter
///message sender can be changed using [isSender]
///[sent],[delivered] and [seen] can be used to display the message state
///chat bubble [TextStyle] can be customized using [textStyle]

class GroupBubble extends StatelessWidget {
  final double bubbleRadius;
  final bool isSender;
  final Color color;
  final String text;
  final String? messageType;
  final String forwardStatus;
  final String? messageSenter;
  final String? rplyMessage;
  final String? rplyMessageType;
  final String? rplyMessageSenter;
  final Color rplyColor;
  final String? thumbnail;
  final String? optionalText;
  final DateTime time;
  final bool isDeleted;
  final bool isStarred;
  final bool tail;
  final bool sent;
  final bool delivered;
  final bool seen;
  final TextStyle textStyle;

  const GroupBubble({
    Key? key,
    required this.text,
    required this.time,
    this.messageType,
    required this.forwardStatus,
    this.optionalText,
    this.isDeleted = false,
    this.isStarred = false,
    this.messageSenter,
    this.rplyMessage,
    this.rplyMessageSenter,
    this.rplyMessageType,
    this.thumbnail,
    this.bubbleRadius = BUBBLE_RADIUS,
    this.isSender = true,
    this.color = Colors.white70,
    this.rplyColor = Colors.white70,
    this.tail = true,
    this.sent = false,
    this.delivered = false,
    this.seen = false,
    this.textStyle = const TextStyle(
      color: Colors.black87,
      fontSize: 16,
    ),
  }) : super(key: key);

  ///chat bubble builder method
  @override
  Widget build(BuildContext context) {
    bool stateTick = false;
    Icon? stateIcon;
    bool isLink = false;
    if (messageType == 'text') {
      isLink = isTextLink(text);
    }
    TimeOfDay myTime = TimeOfDay.fromDateTime(time);
    if (sent) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done,
        size: 18,
        color: Color(0xFF97AD8E),
      );
    }
    if (delivered) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done_all,
        size: 18,
        color: Color(0xFF97AD8E),
      );
    }
    if (seen) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done_all,
        size: 18,
        color: Color(0xFF92DEDA),
      );
    }

    return Row(
      children: <Widget>[
        isSender
            ? const Expanded(
                child: SizedBox(
                  width: 5,
                ),
              )
            : Container(),
        Container(
          color: Colors.transparent,
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(bubbleRadius),
                  topRight: Radius.circular(bubbleRadius),
                  bottomLeft: Radius.circular(tail
                      ? isSender
                          ? bubbleRadius
                          : 0
                      : BUBBLE_RADIUS),
                  bottomRight: Radius.circular(tail
                      ? isSender
                          ? 0
                          : bubbleRadius
                      : BUBBLE_RADIUS),
                ),
              ),
              child: Stack(
                children: <Widget>[
                  if (messageType == 'text')
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: isSender
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        isSender
                            ? const SizedBox()
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  messageSenter.toString(),
                                  style: TextStyle(
                                    color: Colors.green[900],
                                    fontSize: 17,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                        if ('$rplyMessage' == '')
                          Padding(
                            padding: stateTick
                                ? const EdgeInsets.fromLTRB(12, 6, 28, 6)
                                : const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 12),
                            child: isDeleted
                                ? Row(
                                    children: [
                                      Icon(Icons.block,
                                          color: Colors.grey[100]),
                                      Text(
                                        text,
                                        style: TextStyle(
                                          color: Colors.grey[100],
                                          fontStyle: FontStyle.italic,
                                        ),
                                        textAlign: TextAlign.left,
                                      )
                                    ],
                                  )
                                : isLink ?
                            TextButton(
                                onPressed: () => _launchURL(text),
                                child: forwardStatus != '' ?
                                    Column(
                                      crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          forwardStatus,
                                          style: TextStyle(
                                            color: Colors.grey[300],
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic
                                          ),
                                        ),
                                        Text(
                                          text,
                                          style: TextStyle(
                                            color: Colors.white,
                                            decoration: TextDecoration.underline,
                                          ),
                                          textAlign: TextAlign.left,
                                        )
                                      ],
                                    ) :
                                Text(
                              text,
                              style: TextStyle(
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                              ),
                              textAlign: TextAlign.left,
                            )) : forwardStatus != '' ?
                             Column(
                               crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                               children: [
                                 Text(
                                   forwardStatus,
                                   style: TextStyle(
                                     color: Colors.grey[300],
                                     fontStyle: FontStyle.italic,
                                     fontSize: 12,
                                   ),
                                 ),
                                 Text(
                                   text,
                                   style: textStyle,
                                   textAlign: TextAlign.left,
                                 ),
                               ],
                             ) :
                            Text(
                                    text,
                                    style: textStyle,
                                    textAlign: TextAlign.left,
                                  ),
                          )
                        else if (rplyMessageType == 'text')
                          Padding(
                            padding: stateTick
                                ? const EdgeInsets.fromLTRB(12, 6, 28, 6)
                                : const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 12),
                            child: isDeleted
                                ? Row(
                                    children: [
                                      Icon(Icons.block,
                                          color: Colors.grey[100]),
                                      Text(
                                        text,
                                        style: TextStyle(
                                          color: Colors.grey[100],
                                          fontStyle: FontStyle.italic,
                                        ),
                                        textAlign: TextAlign.left,
                                      )
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment: isSender
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: rplyColor,
                                        ),
                                        child: Column(
                                          crossAxisAlignment: isSender
                                              ? CrossAxisAlignment.start
                                              : CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '$rplyMessageSenter',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontStyle: FontStyle.italic,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '$rplyMessage',
                                              style: const TextStyle(
                                                fontStyle: FontStyle.italic,
                                                color: Colors.white,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                     isLink ? TextButton(onPressed: () => _launchURL(text), child: Text(
                                       text,
                                       style: TextStyle(
                                         color: Colors.white,
                                         decoration: TextDecoration.underline,
                                       ),
                                       textAlign: TextAlign.left,
                                     )) : Text(
                                        text,
                                        style: textStyle,
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                          )
                        else if (rplyMessageType == 'image')
                          Padding(
                            padding: stateTick
                                ? const EdgeInsets.fromLTRB(12, 6, 28, 6)
                                : const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 12),
                            child: isDeleted
                                ? Row(
                                    children: [
                                      Icon(Icons.block,
                                          color: Colors.grey[100]),
                                      Text(
                                        text,
                                        style: TextStyle(
                                          color: Colors.grey[100],
                                          fontStyle: FontStyle.italic,
                                        ),
                                        textAlign: TextAlign.left,
                                      )
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment: isSender
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: rplyColor,
                                        ),
                                        child: Row(
                                          // mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '$rplyMessageSenter',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontStyle: FontStyle.italic,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Row(
                                                  children: const [
                                                    Icon(Icons.image,
                                                        color: Colors.white),
                                                    Text(
                                                      'Photo',
                                                      style: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                            const Spacer(),
                                            SizedBox(
                                              height: 40,
                                              width: 40,
                                              child: Image.network(
                                                  "$rplyMessage",
                                                  fit: BoxFit.cover),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        text,
                                        style: textStyle,
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                          )
                        else if (rplyMessageType == 'video')
                          Padding(
                            padding: stateTick
                                ? const EdgeInsets.fromLTRB(12, 6, 28, 6)
                                : const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 12),
                            child: isDeleted
                                ? Row(
                                    children: [
                                      Icon(Icons.block,
                                          color: Colors.grey[100]),
                                      Text(
                                        text,
                                        style: TextStyle(
                                          color: Colors.grey[100],
                                          fontStyle: FontStyle.italic,
                                        ),
                                        textAlign: TextAlign.left,
                                      )
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: rplyColor,
                                        ),
                                        child: Row(
                                          // mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '$rplyMessageSenter',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontStyle: FontStyle.italic,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Row(
                                                  children: const [
                                                    Icon(
                                                        Icons
                                                            .ondemand_video_outlined,
                                                        color: Colors.white),
                                                    Text(
                                                      'Video',
                                                      style: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                            const Spacer(),
                                            Stack(
                                              children: [
                                                SizedBox(
                                                  height: 40,
                                                  width: 40,
                                                  child: Image.network(
                                                      '$rplyMessage',
                                                      fit: BoxFit.cover),
                                                ),
                                                const Positioned(
                                                  top: 6,
                                                  left: 0,
                                                  right: 0,
                                                  child: Icon(
                                                      Icons.play_circle_outline,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        text,
                                        style: textStyle,
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                          )
                        else if (rplyMessageType == 'doc')
                          Padding(
                            padding: stateTick
                                ? const EdgeInsets.fromLTRB(12, 6, 28, 6)
                                : const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 12),
                            child: isDeleted
                                ? Row(
                                    children: [
                                      Icon(Icons.block,
                                          color: Colors.grey[100]),
                                      Text(
                                        text,
                                        style: TextStyle(
                                          color: Colors.grey[100],
                                          fontStyle: FontStyle.italic,
                                        ),
                                        textAlign: TextAlign.left,
                                      )
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: rplyColor,
                                        ),
                                        child: Row(
                                          // mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '$rplyMessageSenter',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontStyle: FontStyle.italic,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  rplyMessage!.split('/').last,
                                                  style: const TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              ],
                                            ),
                                            const Spacer(),
                                            SizedBox(
                                              height: 40,
                                              width: 40,
                                              child: Image.asset(pdfIcon),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        text,
                                        style: textStyle,
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                          )
                        else if (rplyMessageType == 'voice')
                          Padding(
                            padding: stateTick
                                ? const EdgeInsets.fromLTRB(12, 6, 28, 6)
                                : const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 12),
                            child: isDeleted
                                ? Row(
                                    children: [
                                      Icon(Icons.block,
                                          color: Colors.grey[100]),
                                      Text(
                                        text,
                                        style: TextStyle(
                                          color: Colors.grey[100],
                                          fontStyle: FontStyle.italic,
                                        ),
                                        textAlign: TextAlign.left,
                                      )
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: rplyColor,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '$rplyMessageSenter',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontStyle: FontStyle.italic,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Row(
                                              children: const [
                                                Icon(Icons.mic,
                                                    color: Colors.white),
                                                Text(
                                                  'Voice Message',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontStyle: FontStyle.italic,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        text,
                                        style: textStyle,
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                          ),
                        if (!isDeleted)
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 8, bottom: 4, left: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (isStarred)
                                  const Icon(
                                    Icons.star,
                                    size: 10,
                                    color: Colors.amber,
                                  ),
                                Text(myTime.format(context), style: textStyle)
                              ],
                            ),
                          ),
                      ],
                    ),
                  if (messageType == 'image')
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: isSender
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        isSender
                            ? const SizedBox()
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  messageSenter.toString(),
                                  style: TextStyle(
                                    color: Colors.green[900],
                                    fontSize: 17,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                        Padding(
                          padding: stateTick
                              ? const EdgeInsets.fromLTRB(12, 6, 28, 6)
                              : const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 12),
                          child: isDeleted
                              ? Row(
                                  children: [
                                    Icon(Icons.block, color: Colors.grey[100]),
                                    Text(
                                      text,
                                      style: TextStyle(
                                        color: Colors.grey[100],
                                        fontStyle: FontStyle.italic,
                                      ),
                                      textAlign: TextAlign.left,
                                    )
                                  ],
                                )
                              : InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ImageSection(imageUrl: text)));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: forwardStatus != '' ?
                                        Column(
                                          crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              forwardStatus,
                                              style: TextStyle(
                                                color: Colors.grey[300],
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 200,
                                              height: 180,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 0, right: 6),
                                                child: Container(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                    BorderRadius.circular(15),
                                                    child: Image(
                                                      image: NetworkImage(text),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ) :
                                    SizedBox(
                                      width: 200,
                                      height: 180,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 0, right: 6),
                                        child: Container(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: Image(
                                              image: NetworkImage(text),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        if (!isDeleted)
                          if (optionalText != '' || optionalText != '')
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 8, bottom: 4, left: 16),
                              child: Text(
                                '$optionalText',
                                style: textStyle,
                              ),
                            ),
                        if (!isDeleted)
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 8, bottom: 4, left: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (isStarred)
                                  const Icon(
                                    Icons.star,
                                    size: 10,
                                    color: Colors.amber,
                                  ),
                                Text(myTime.format(context), style: textStyle)
                              ],
                            ),
                          ),
                      ],
                    ),
                  if (messageType == 'video')
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: isSender
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        isSender
                            ? const SizedBox()
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  messageSenter.toString(),
                                  style: TextStyle(
                                    color: Colors.green[900],
                                    fontSize: 17,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                        Padding(
                          padding: stateTick
                              ? const EdgeInsets.fromLTRB(12, 6, 28, 6)
                              : const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 12),
                          child: isDeleted
                              ? Row(
                                  children: [
                                    Icon(Icons.block, color: Colors.grey[100]),
                                    Text(
                                      text,
                                      style: TextStyle(
                                        color: Colors.grey[100],
                                        fontStyle: FontStyle.italic,
                                      ),
                                      textAlign: TextAlign.left,
                                    )
                                  ],
                                )
                              : InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                VideoSection(videoUrl: text)));
                                  },
                                  child: forwardStatus != '' ?
                                      Column(
                                        crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            forwardStatus,
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 12,
                                              color: Colors.grey[300]
                                            ),
                                          ),
                                          SizedBox(
                                            width: 200,
                                            height: 180,
                                            child: Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                  BorderRadius.circular(15),
                                                  child: SizedBox(
                                                    child: Padding(
                                                      padding:
                                                      const EdgeInsets.all(3.0),
                                                      child: SizedBox(
                                                        width: 200,
                                                        height: 180,
                                                        child: Padding(
                                                          padding:
                                                          const EdgeInsets.only(
                                                              left: 0, right: 6),
                                                          child: Container(
                                                            child: ClipRRect(
                                                              borderRadius:
                                                              BorderRadius.circular(
                                                                  15),
                                                              child: Image(
                                                                image: NetworkImage(
                                                                    '$thumbnail' !=
                                                                        '' ||
                                                                        '$thumbnail' !=
                                                                            null
                                                                        ? '$thumbnail'
                                                                        : 'https://oncologytubecom.cdn.ypt.me/view/img/video-placeholder-gray.png'),
                                                                fit: BoxFit.cover,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  // bottom: 2,
                                                  // right: 4,
                                                  child: Container(
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons
                                                            .play_circle_outline_outlined,
                                                        color: Colors.white,
                                                        size: 50,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ) :
                                  SizedBox(
                                    width: 200,
                                    height: 180,
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: SizedBox(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              child: SizedBox(
                                                width: 200,
                                                height: 180,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 0, right: 6),
                                                  child: Container(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      child: Image(
                                                        image: NetworkImage(
                                                            '$thumbnail' !=
                                                                        '' ||
                                                                    '$thumbnail' !=
                                                                        null
                                                                ? '$thumbnail'
                                                                : 'https://oncologytubecom.cdn.ypt.me/view/img/video-placeholder-gray.png'),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          // bottom: 2,
                                          // right: 4,
                                          child: Container(
                                            child: const Center(
                                              child: Icon(
                                                Icons
                                                    .play_circle_outline_outlined,
                                                color: Colors.white,
                                                size: 50,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                        if (!isDeleted)
                          if (optionalText != '' || optionalText != '')
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 8, bottom: 4, left: 16),
                              child: Text(
                                '$optionalText',
                                style: textStyle,
                              ),
                            ),
                        if (!isDeleted)
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 8, bottom: 4, left: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (isStarred)
                                  const Icon(
                                    Icons.star,
                                    size: 10,
                                    color: Colors.amber,
                                  ),
                                Text(myTime.format(context), style: textStyle)
                              ],
                            ),
                          ),
                      ],
                    ),
                  if (messageType == 'doc')
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: isSender
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        isSender
                            ? const SizedBox()
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  messageSenter.toString(),
                                  style: TextStyle(
                                    color: Colors.green[900],
                                    fontSize: 17,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                        Padding(
                          padding: stateTick
                              ? const EdgeInsets.fromLTRB(12, 6, 28, 6)
                              : const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 12),
                          child: isDeleted
                              ? Row(
                                  children: [
                                    Icon(Icons.block, color: Colors.grey[100]),
                                    Text(
                                      text,
                                      style: TextStyle(
                                        color: Colors.grey[100],
                                        fontStyle: FontStyle.italic,
                                      ),
                                      textAlign: TextAlign.left,
                                    )
                                  ],
                                )
                              : InkWell(
                                  onTap: () {
                                    // "url"
                                    String file = text.split('/').last;
                                    String extensionFile = file.split('.').last;
                                    print(text);
                                    if (extensionFile == 'pdf') {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ChatPdfView(
                                                  fileName:
                                                      text.split('/').last,
                                                  pdf: text)));
                                    } else {
                                      _launchURL(text);
                                    }
                                    // Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPdfView(fileName: text.split('/').last, pdf: text)));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: forwardStatus != '' ?
                                        Column(
                                          crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              forwardStatus,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                SizedBox(
                                                  width: 200,
                                                  height: 180,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(
                                                        left: 0, right: 6),
                                                    child: Container(
                                                      child: ClipRRect(
                                                        borderRadius:
                                                        BorderRadius.circular(15),
                                                        child: Image(
                                                          image: AssetImage(docIcon),
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                 const SizedBox(height: 5,),
                                                Text(path.basename(text),style: const TextStyle(color: Colors.white),)
                                              ],
                                            ),
                                          ],
                                        ) :
                                    Column(
                                      children: [
                                        SizedBox(
                                          width: 200,
                                          height: 180,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 0, right: 6),
                                            child: Container(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: Image(
                                                  image: AssetImage(docIcon),
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                         const SizedBox(height: 5,),
                                                Text(path.basename(text),style: const TextStyle(color: Colors.white),)
                                              ],
                                    ),
                                  ),
                                ),
                        ),
                        if (!isDeleted)
                          if (optionalText != '' || optionalText != '')
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 8, bottom: 4, left: 16),
                              child: Text(
                                '$optionalText',
                                style: textStyle,
                              ),
                            ),
                        if (!isDeleted)
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 8, bottom: 4, left: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (isStarred)
                                  const Icon(
                                    Icons.star,
                                    size: 10,
                                    color: Colors.amber,
                                  ),
                                Text(myTime.format(context), style: textStyle)
                              ],
                            ),
                          ),
                      ],
                    ),
                  stateIcon != null && stateTick
                      ? Positioned(
                          bottom: 4,
                          right: 6,
                          child: stateIcon,
                        )
                      : const SizedBox(
                          width: 1,
                        ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchURL(url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $uri');
    }
  }

  bool isTextLink(String text) {
    final RegExp urlRegex = RegExp(
      r'^(?:http|https):\/\/[^\s/$.?#].[^\s]*$',
      caseSensitive: false,
    );
    return urlRegex.hasMatch(text);
  }
}
