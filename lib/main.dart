import 'dart:async';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_station/firebase_options.dart';
import 'package:smart_station/providers/AccountProvider/account_provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';
import 'package:smart_station/providers/AuthProvider/lost_phone_provider.dart';
import 'package:smart_station/providers/AuthProvider/otp_verify_provider.dart';
import 'package:smart_station/providers/ChatDetailProvider/chatdetail_provider.dart';
import 'package:smart_station/providers/ChatFuntionProvider/chatFunctionProvider.dart';
import 'package:smart_station/providers/CloudProvider/cloud_provider.dart';
import 'package:smart_station/providers/EmailProvider/email_provider.dart';
import 'package:smart_station/providers/InfoProvider/individualChatInfoProvider.dart';
import 'package:smart_station/providers/LetterProvider/letter_provider.dart';
import 'package:smart_station/providers/NotificationProvider/notification_provider.dart';
import 'package:smart_station/providers/ProfileProvider/profile_provider.dart';
import 'package:smart_station/providers/RecentChatProvider/recentchat_provider.dart';
import 'package:smart_station/providers/UserProvider/user_provider.dart';
import 'package:smart_station/screens/callAndNotification/callNotification.dart';
import 'package:smart_station/screens/home_screen/group/group_info_screen.dart';
import 'package:smart_station/providers/GroupProvider/group_provider.dart';
import 'package:smart_station/providers/AccountProvider/privacy_provider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:smart_station/utils/constants/urls.dart';
import 'screens/splash_screen/splash_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/widgets.dart';

Future<void> main() async {
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
          channelKey: 'call_channel',
          channelName: 'Call Channel',
          channelDescription: 'Channel of calling',
          defaultColor: Colors.redAccent,
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          locked: true,
          defaultRingtoneType: DefaultRingtoneType.Ringtone),
      NotificationChannel(
          channelKey: 'Missed_CAll',
          channelName: 'Miss Call Channel',
          channelDescription: 'Channel of calling',
          defaultColor: Colors.redAccent,
          ledColor: const Color.fromARGB(255, 30, 13, 13),
          importance: NotificationImportance.Min,
          channelShowBadge: true,
          locked: true),
      NotificationChannel(
          channelKey: 'downloaded_pdf',
          channelName: 'Downloaded PDFs',
          channelDescription: 'PDFs downloaded from the app',
          defaultColor: Colors.tealAccent,
          ledColor: Colors.tealAccent,
          playSound: true,
          enableVibration: true),
      NotificationChannel(
          channelKey: 'chat_messages',
          channelName: 'chat notification',
          channelDescription: 'for message notification',
          defaultColor: Colors.tealAccent,
          ledColor: Colors.tealAccent,
          playSound: true,
          enableVibration: true)
    ],
  );

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'smart_station',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
      NotificationServices.firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late AppLifecycleState _lifecycleState;
  // ignore: prefer_typing_uninitialized_variables
  var uId;

  final IO.Socket _socket = IO.io(AppUrls.appSocketUrl,
      IO.OptionBuilder().setTransports(['websocket']).build());

  _connectSocket() {
    _socket.connect();
    _socket.onConnect((data) => print('Connection established'));
    _socket.onConnectError((data) => print('Connect Error $data'));
    _socket.onDisconnect((data) => print('Socket.IO disconneted'));
  }

  _destroySocket() {
    _socket.disconnect();
  }

  void details() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      uId = prefs.getString('userId');
    });
  }

  // List<Contact> contacts = [];
  // bool isLoading = true;

  /// ***************[Phone Contact Fetching Permission]*****************
  void getContactPermossion() async {
    if (await Permission.contacts.isGranted) {
      ///***************[Fetch Contacts]**************
      fetchContacts();
    } else {
      ///***************[Request Permission]**************
      await Permission.contacts.request();
    }
    /* final PermissionStatus status = await Permission.contacts.status;
    if (status == PermissionStatus.granted) {
      // Permission is granted
      fetchContacts();
    } else {
      // Request permission to access the user's contacts
      print('Request permission to access the users contacts');
      final PermissionStatus newStatus = await Permission.contacts.request();
      if (newStatus == PermissionStatus.granted) {
        // Permission is granted
        fetchContacts();
      } else {
        // Permission is denied or permanently denied
      }
    }*/
  }

  /// ****************[Get Phone Contacts]********************
  void fetchContacts() async {
    phoneContacts = await ContactsService.getContacts();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    getContactPermossion();
    _connectSocket();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OtpVerifyProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => RecentChatProvider()),
        ChangeNotifierProvider(create: (_) => ChatDetailProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => EmailProvider()),
        ChangeNotifierProvider(create: (_) => LetterProvider()),
        ChangeNotifierProvider(create: (_) => CloudProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => InfoProvider()),
        ChangeNotifierProvider(create: (_) => LostPhoneProvider()),
        ChangeNotifierProvider(create: (_) => PrivacyProvider()),
        ChangeNotifierProvider(create: (_) => PinChatProvider()),
      ],
      child: MaterialApp(
          title: 'Fin Smart Station',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          routes: {
            '/groupInfo': (context) => const GroupInfoScreen(),
          },
          theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: 'd-din',
            pageTransitionsTheme: const PageTransitionsTheme(builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            }),
          ),
          home: const SplashScreen()
          // home: GetStarted(),
          ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _lifecycleState = state;
    });

    if (_lifecycleState == AppLifecycleState.paused) {
      print('SDDFFGHGHGHGHGH');
      print(userId);
      print('SDDFFGHGHGHGHGH');
      if (_socket.connected) {
        _socket.emit('dis', {'s_id': userId});
      } else {
        _connectSocket();
        _socket.emit('dis', {'s_id': userId});
      }
    }

    if (_lifecycleState == AppLifecycleState.resumed) {
      _socket.connect();
      _socket
          .emit('chat_list', {'user_id': userId, 'accessToken': accessToken});
      _socket.on('chat_list', (data) => print('ADDED'));
    }

    super.didChangeAppLifecycleState(state);
  }
}
