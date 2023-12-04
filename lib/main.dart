import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:siklabproject/users/fragments/changePasswordPage.dart';
import 'package:siklabproject/users/fragments/forgotPasswordPage.dart';
//import 'package:siklabproject/hotlines.dart';
import 'package:siklabproject/users/authentication/loginPage.dart';
import 'package:siklabproject/users/authentication/signUpPage.dart';
import 'package:siklabproject/users/fragments/newUserDashboard.dart';
import 'package:siklabproject/users/fragments/testReport.dart';
import 'package:siklabproject/users/userPreferences/user_preferences.dart';
import 'package:siklabproject/users/fragments/userProfile.dart';
//import 'package:siklabproject/userDashboard.dart';
//import 'package:siklabproject/userReportPage.dart';
//import 'package:siklabproject/userSettingsPage.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.getInitialMessage();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Siklab Application',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      navigatorKey: navigatorKey,
      home: FutureBuilder(
          future: RememberUser.readUser(),
          builder: (context, dataSnapshot) {
            if (dataSnapshot.data == null) {
              return const MyHomePage();
            } else {
              String _mobileNumber = '';

              return newUserDashboard(_mobileNumber);
            }
          }),
      //initialRoute: "/Home",
      routes: {
        "/Home": (context) => const MyHomePage(),
        "/LoginPage": (context) => loginPage(),
        //"/UserDashboard": (context) => newUserDashboard(),
        // "/SignUpPage": (context) => sign(),
        "/SignUpPage": (context) => signUpPage(),
        // "/UserSettings": (context) => userSettingsPage(),
        "/ForgotPasswordPage": (context) => forgotPasswordPage(),
        //"/ChangePasswordPage": (context) => changePasswordPage(),
        "/UserProfile": (context) => userProfile('09190012251'),
        // "/ReportFirePage": (context) => userReportPage(),
        // "/HotlinesPage": (context) => Hotlines(),
        "/UserReport": (context) => userReportPagev2('09190012251'),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/LoginPage');
      },
      child: Scaffold(
        body: Container(
          alignment: Alignment.center,
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(255, 0, 0, .61),
                    Color.fromRGBO(255, 0, 0, 1),
                    Color.fromRGBO(255, 0, 0, .61),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.5, 1],
                  tileMode: TileMode.clamp)),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/firefighter.png', height: 175, width: 175),
                const Text(
                  "SIKLAB",
                  style: TextStyle(fontSize: 48.0, color: Colors.white),
                ),
                const Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      "Tap the screen to continue",
                      style: TextStyle(fontSize: 18.0, color: Colors.white),
                    )),
              ]),
        ),
      ),
    );
  }
}
