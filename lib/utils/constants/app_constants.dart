import 'dart:async';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:smart_station/utils/constants/urls.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../screens/home_screen/chat/models/chat_List_model.dart';
import '../../screens/home_screen/chat/models/individualChat/messageModel.dart';

String splashLogo = 'assets/images/splash.gif';
String splashBg = 'assets/images/bg_pattern.png';
String topBg = 'assets/images/unnamed.png';
String mainLogo = 'assets/images/ic_main_logo_use.png';
String transpLogo = 'assets/images/login_logo_use.png';
String noFlag = 'assets/images/noFlag.png';
String menuIcon = 'assets/images/ic_menu_use.png';
String searchIcon = 'assets/images/ic_search_use.png';
String chatIcon = 'assets/images/ic_chat_use.png';
String letterIcon = 'assets/images/ic_letter_use.png';
String mailIcon = 'assets/images/ic_mail_use.png';
String plusIcon = 'assets/images/ic_plus_use.png';
String accountIcon = 'assets/images/account.png';
String contactIcon = 'assets/images/contact.png';
String helpIcon = 'assets/images/haelp_icon.png';
String notificationIcon = 'assets/images/notifications.png';
String greenLogo = 'assets/images/greenLogo.png';
String smileyIcon = 'assets/images/message.png';
String microPhoneIcon = 'assets/images/microphone.png';
String phoneIcon = 'assets/images/phoneChat.png';
String videoIcon = 'assets/images/videoChat.png';
String pdfIcon = 'assets/images/pdfIcon.jpg';
String json = 'assets/images/json.png';
String mp3 = 'assets/images/MP3.png';
String text = 'assets/images/text.png';
String composeIcon = 'assets/images/compose_mail.png';
String countIcon = 'assets/images/mail_icon.png';
String folderIcon = 'assets/images/folder_bg.png';
String cameraIcon = 'assets/images/camera.png';
String smileIcon = 'assets/images/smile.png';
String barCode = 'assets/images/barcode.png';
String defaultImage = 'assets/images/default.png';
String dollarIcon = 'assets/images/ic_dollar.png';
String cloudIcon = 'assets/images/ic_cloud.png';
String attachIcon = 'assets/images/ic_attachment.png';
String changePhoneIcon = 'assets/images/changephonenumber.png';
String ringBack = 'assets/audio/ringBackTone.wav';
String privacyIcon = 'assets/images/privacyIcon.png';
String securityIcon = 'assets/images/securityIcon.png';
String signatureIcon = 'assets/images/signatureIcon.png';
String stampIcon = 'assets/images/stampIcon.png';
String headerIcon = 'assets/images/letter.png';
String plus_Icon = 'assets/images/plusIcon.png';
String trashIcon = 'assets/images/trashIcon.png';
String fileIcon = 'assets/images/file.png';
String docIcon = 'assets/images/doc.png';
String wordIcon = 'assets/images/docx.png';
String IndianFlag = 'assets/images/IndianFlag.png';
String pptIcon = 'assets/images/pptIcon.png';
String pinIcon = 'assets/images/pin.png';
String unpinIcon = 'assets/images/unpin.png';
String documentIcon = 'assets/images/docIcon.png';
String excelIcon = 'assets/images/excel_logo.png';

String userId = '';
String accessToken = '';
const zegoappid = 684213027;
const zegoappsign =
    'e53c1e82fd9be54d016d1d7b687613a96f26cbda5ad8e2579c2b9e3254ba2302';

String agAppId = '38716816d350473d92b6604a83d1a6d1';
String agChannelName = 'videoaudio';
String agAppToken =
    '007eJxTYPhouGcGz7Pw6acya/vzrb7OdVnXbXTi+pz2gNUT7Zdp2SxRYDC2MDc0szA0SzE2NTAxN06xNEoyMzMwSbQwTjFMNEsx7Kp9ktwQyMiwUHYOKyMDBIL4XAxpOaUlqUUlqcUlDAwAVBUifg==';

bool isUploading = false;

List<Contact> phoneContacts = [];

List individualChatId = [];
List groupChatId = [];

List chatProcessing = [];

clearData() {
  individualChatId.clear();
  groupChatId.clear();
  chatProcessing.clear();
}

StreamController<IndividualChatModel> chatController =
    StreamController<IndividualChatModel>();

StreamController<ChatList> chat_List_StreamController =
    StreamController<ChatList>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Color textGreen = const Color(0xff18937b);
Color rightGreen = const Color(0xff00c412);
Color leftGreen = const Color(0xff1b5e20);
