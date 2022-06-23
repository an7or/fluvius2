import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluvius2/app/shared.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var email = TextEditingController();
  var pass = TextEditingController();
  bool isVisible = false;

  fireLogin(context) async {
    try {
      Fluttertoast.showToast(msg: 'Working, Please wait...');

      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text, password: pass.text);
      var userID = FirebaseAuth.instance.currentUser!.uid;
      var ref = FirebaseDatabase.instance.ref(userID);

      ref.get().then((value) {
        Map<dynamic, dynamic> map = value.value as Map<dynamic, dynamic>;
        userType = map['userType'] as String;
        deviceID = map['deviceID'] as String;
        Navigator.of(context).pushReplacementNamed("/HomePage");
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Fluttertoast.showToast(msg: 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        Fluttertoast.showToast(msg: 'Wrong password provided for that user.');
      } else {
        Fluttertoast.showToast(msg: 'Something wrong! Try again..');
      }
    } on FirebaseException catch (e) {
      Fluttertoast.showToast(msg: e.message!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Image.asset("assets/fluvius2_logo1.png", scale: 1.3),
                  const SizedBox(height: 30),
                  TextField(
                    controller: email,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.email),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
                      hintText: 'E-mail Address',
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: pass,
                    obscureText: !isVisible,
                    decoration: InputDecoration(
                      icon: const Icon(Icons.password),
                      suffixIcon: IconButton(
                          onPressed: () {
                            isVisible = !isVisible;
                            setState(() {});
                          },
                          icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility)),
                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
                      hintText: 'Password',
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed("/SignupPage"),
                      child: const Text("Not Registered? Click here."),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100, 45),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: const Text("Login", style: TextStyle(fontSize: 18)),
                        onPressed: () => fireLogin(context))
                  ]),
                ],
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Stack(alignment: Alignment.center, children: [
                  Image.asset("assets/water.png"),
                  Image.asset("assets/nig.png", scale: 1.5),
                ]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
