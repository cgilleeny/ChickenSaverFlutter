import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

import './helpers/custom_material_color.dart';
import './providers/register.dart';
import './screens/sunset_alert_screen.dart';
import './screens/alarms_screen.dart';
// import './models/alarm.dart';
import '../providers/alarms.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // late FirebaseMessaging messaging;
  // String? _token;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // messaging = FirebaseMessaging.instance;
    // if (Platform.isIOS) {
    //   messaging
    //       .requestPermission(
    //         alert: true,
    //         badge: true,
    //         sound: true,
    //         announcement: true,
    //         carPlay: true,
    //         criticalAlert: true,
    //         provisional: false,
    //       )
    //       .then((settings) => {
    //             if (settings.authorizationStatus ==
    //                 AuthorizationStatus.authorized)
    //               {
    //                 messaging.getAPNSToken().then((value) {
    //                   print("ios token recieved");
    //                   print(value);
    //                   var register =
    //                       Provider.of<Register>(context, listen: false);
    //                   register.token = value;
    //                 })
    //               }
    //           });
    // } else {
    //   messaging.getToken().then((value) {
    //     print("android token recieved");
    //     print(value);
    //     // _token = value;
    //     var register = Provider.of<Register>(context, listen: false);
    //     register.token = value;
    //   });
    // }

    // FirebaseMessaging.onMessage.listen((RemoteMessage event) {
    //   print("message recieved");
    //   print(event.notification!.body);
    // });
    // FirebaseMessaging.onMessageOpenedApp.listen((message) {
    //   print('Message clicked!');
    // });
    // FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    //   print("newToken: $newToken");
    //   _token = newToken;
    // });
  }

  @override
  Widget build(BuildContext context) {
    final customMaterialColor = CustomMaterialColor();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Register(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Alarms(),
        ),
      ],
      child: MaterialApp(
          title: 'Chicken Saver',
          theme: ThemeData(
            dividerTheme: DividerThemeData(
              color: customMaterialColor.create(
                Color(0xFF165774),
              ),
            ),
            appBarTheme: AppBarTheme(
                titleTextStyle: TextStyle(
              color: customMaterialColor.create(
                Color(0xFF0c3040),
              ),
              fontFamily: 'Noteworthy',
              fontWeight: FontWeight.bold,
            )),
            primarySwatch: customMaterialColor.create(
              Color(0xFF2BAAE2),
            ),
            cardColor: customMaterialColor.create(
              Color(0xFFFFEDA3),
            ),
            backgroundColor: customMaterialColor.create(
              Color(0xFFFFD62F),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: customMaterialColor.create(
                  Color(0xFF0c3040),
                ),
                // backgroundColor: Colors.white,
                textStyle: TextStyle(
                  fontFamily: 'Noteworthy',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            textTheme: TextTheme(
              bodyText1: TextStyle(
                color: Colors.white,
                fontFamily: 'Noteworthy',
                fontWeight: FontWeight.normal,
              ),
              headline4: TextStyle(
                color: customMaterialColor.create(
                  Color(0xFF165774),
                )[300],
                fontFamily: 'Noteworthy',
                fontWeight: FontWeight.normal,
              ),
              headline6: TextStyle(
                color: customMaterialColor.create(
                  Color(0xFF165774),
                ),
                fontFamily: 'Noteworthy',
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          home: Consumer<Register>(
            builder: (ctx, register, _) => FutureBuilder(
              future: register.tryStoredRegistration(),
              builder: (ctx, registerResultSnapshot) =>
                  register.isRegistered == null
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : register.isRegistered!
                          ? SunsetAlertScreen()
                          : SunsetAlertScreen(),
            ),
          ),
          routes: {
            // ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            // CartScreen.routeName: (ctx) => CartScreen(),
            // OrdersScreen.routeName: (ctx) => OrdersScreen(),
            // UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            // EditProductScreen.routeName: (ctx) => EditProductScreen(),
          }),
    );
  }
}


