import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluvius2/report.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'home.dart';
import 'app/model.dart';
import 'login.dart';
import 'signup.dart';
import 'configuration.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ChangeNotifierProvider(create: (context) => Fluvius(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  bool isLoggedIn() {
    bool loggedin = false;
    if (FirebaseAuth.instance.currentUser != null) loggedin = true;
    return loggedin;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fluvius 2',
      theme: ThemeData(
        textTheme: GoogleFonts.didactGothicTextTheme(Theme.of(context).textTheme),
      ),
      darkTheme: ThemeData.dark(),
      home: isLoggedIn() == false ? LoginPage() : HomePage(),
      routes: {
        "/LoginPage": (context) => LoginPage(),
        "/SignupPage": (context) => SignupPage(),
        "/HomePage": (context) => HomePage(),
        "/Configuration": (context) => Configuration(),
        "/Report": (context) => Report(),
      },
    );
  }
}
