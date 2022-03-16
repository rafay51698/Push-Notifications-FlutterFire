import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'green.dart';
import 'red.dart';
import 'services/local_notification_service.dart';

// Receive message when the app is in background solution for on Message
Future<void> backgroundHandler(RemoteMessage message) async {
  print(message.data.toString());
  print(message.notification!.title);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
      );
  // Recieve message when app is in background , solution for onMessage
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(
        title: "Push Notification",
      ),
      routes: {
        "red": (_) => const RedPage(),
        "green": (_) => const GreenPage()
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();

    LocalNotificationServices.initialize(context);

    // FirebaseMessaging.instance.getInitialMessage();

// Gives you the message on which user taps and it gives the app from terminatedState
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        final routeFromMesssage = message.data["route"];
        Navigator.of(context).pushNamed(routeFromMesssage);
      }
    });

// Foreground Work
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        print(message.notification!.title);
        print(message.notification!.body);
      }
// This work for heads of notification for both when the app is in foreground or in background
      LocalNotificationServices.display(message);
    });

// When the app is in background but opened and user taps on the notification

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final routeFromMesssage = message.data["route"];

      Navigator.of(context).pushNamed(routeFromMesssage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Container(
          child: const Center(
            child: const Text(
              "You will recieve message soon",
              style: TextStyle(fontSize: 34),
            ),
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
