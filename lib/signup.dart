import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluvius2/app/model.dart';
import 'package:fluvius2/app/shared.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatelessWidget {
  SignupPage({Key? key}) : super(key: key);

  var email = TextEditingController();
  var pass = TextEditingController();
  var confirmPass = TextEditingController();
  var deviceID = TextEditingController();

  fireSignup(context) async {
    if (pass.text != confirmPass.text) {
      Fluttertoast.showToast(msg: "Password doesn't matched!");
      return;
    }
    if (deviceID.text == "" || deviceID.text.isEmpty) {
      Fluttertoast.showToast(msg: "Device ID empty!");
      return;
    }
    try {
      Fluttertoast.showToast(msg: 'Working, Please wait...');
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email.text, password: pass.text);

      var userID = FirebaseAuth.instance.currentUser!.uid;
      userID = FirebaseAuth.instance.currentUser!.uid;
      var ref = FirebaseDatabase.instance.ref(userID);
      var perams = {'userType': 'user', 'deviceID': deviceID.text, 'createdOn': DateTime.now().toString()};
      var conf = Provider.of<Fluvius>(context, listen: false).configToJson();
      var sensors = Provider.of<Fluvius>(context, listen: false).sensorsToJson();
      ref.set(perams);

      ref = FirebaseDatabase.instance.ref(userID + "/" + deviceID.text + "/config");
      ref.set(conf);

      ref = FirebaseDatabase.instance.ref(userID + "/" + deviceID.text + "/realtime");
      ref.update(sensors);

      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, '/HomePage');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Fluttertoast.showToast(msg: "The password provided is too weak.");
      } else if (e.code == 'email-already-in-use') {
        Fluttertoast.showToast(msg: "The account already exists for that email.");
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
      //resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Image.asset("assets/fluvius2_logo2.png", scale: 1.5),
                    const SizedBox(height: 20),
                    Image.asset("assets/nig.png", scale: 1.5),
                    const SizedBox(height: 30),
                    Column(
                      children: [
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
                          obscureText: true,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.password),
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
                            hintText: 'Password',
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: confirmPass,
                          obscureText: true,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.password),
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
                            hintText: 'Confirm Password',
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: deviceID,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.perm_device_info),
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
                            hintText: 'Your device ID',
                          ),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(130, 45),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            ),
                            child: const Text("Signup", style: TextStyle(fontSize: 18)),
                            onPressed: () => fireSignup(context)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
