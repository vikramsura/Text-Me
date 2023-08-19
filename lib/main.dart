// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:whats_app/data_All/appDetails.dart';
import 'package:whats_app/data_All/app_color.dart';
import 'package:whats_app/data_All/font_sizes.dart';
import 'package:whats_app/firebaseMessage.dart';
import 'package:whats_app/provider/home_provider.dart';
import 'package:whats_app/provider/profile_provider.dart';
import 'package:whats_app/provider/phone_provider.dart';
import 'package:whats_app/ui_design/phone_number.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:whats_app/ui_design/profile_sign_up.dart';

import 'data_All/SharedPreferences.dart';
import 'ui_design/home.dart';
import 'ui_design/verify.dart';

var uuid = Uuid();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: AppDetails.appFirebaseApiKey,
      appId: AppDetails.appFirebaseID,
      messagingSenderId: AppDetails.appMsgId,
      storageBucket: AppDetails.appStorageBucket,
      projectId: AppDetails.appProjectId,
    ),
  );
  await FirebaseApps().initNotification();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return PhoneProvider();
      },
      child: ChangeNotifierProvider(
        create: (_) {
          return HomeProvider();
        },
        child: ChangeNotifierProvider(
          create: (_) {
            return ProfileProvider();
          },
          child: ChangeNotifierProvider(
            create: (_) {
              return HomeProvider();
            },
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Text.Me',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,
              ),
              home: MyHomePage(),
            ),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  AppLifecycleState? appLifecycleState;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      appLifecycleState = state;
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  void dispose() {
    0;super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight(MediaQuery.of(context).size.height);
    return SafeArea(
      child: Scaffold(
          body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Icon(
                  Icons.messenger_outlined,
                  size: AppFontSize.font130,
                  color: AppColor.amber,
                ),
                Positioned(
                  left: AppFontSize.font20,
                  bottom: AppFontSize.font80,
                  child: Text(
                    "Text Me...",
                    style: TextStyle(
                        fontSize: AppFontSize.font20,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Positioned(
                  left: AppFontSize.font40,
                  top: AppFontSize.font40,
                  child: Icon(
                    Icons.edit_note_outlined,
                    size: AppFontSize.font50,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: AppFontSize.font30,
            ),
            SpinKitFadingCircle(
              size: AppFontSize.font50,
              itemBuilder: (BuildContext context, int index) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: index.isEven ? Colors.amber : Colors.black,
                      backgroundBlendMode: BlendMode.color),
                );
              },
            ),
          ],
        ),
      )),
    );
  }

  getData() async {
    await LocalDataSaver.getUserLogin().then((value) async {
      if (value == true) {
        Provider.of<ProfileProvider>(context, listen: false).currentUserData();
        await getUserDetails();
        await FirebaseApps().initNotification();
        print(UserDetails.userId);
        if (appLifecycleState == AppLifecycleState.paused) {
          FirebaseFirestore.instance
              .collection("users")
              .doc(UserDetails.userId)
              .update({'userOnline': "Away"});
        } else if (appLifecycleState == AppLifecycleState.resumed) {
          FirebaseFirestore.instance
              .collection("users")
              .doc(UserDetails.userId)
              .update({'userOnline': "Active"});
        } else if (appLifecycleState == AppLifecycleState.inactive) {
          FirebaseFirestore.instance
              .collection("users")
              .doc(UserDetails.userId)
              .update({'userOnline': "Offline"});
        }
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Home()));
        });
      } else {
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Phone_No()));
        });
      }
    });
  }
}
