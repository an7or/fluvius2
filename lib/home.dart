import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluvius2/app/shared.dart';
import 'package:invert_colors/invert_colors.dart';
import 'package:provider/provider.dart';
import 'app/model.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var sensorName = [
    "Water Temperature",
    "Chlorine level",
    "Conductivity",
    "Turbidity Level",
    "Pump State",
    "Ionizer State"
  ];
  var sensorUnit = ["[°C]", "[PPM]", "[PPM]", "[NTU]", "[ON/OFF]", "[ON/OFF]"];
  var sensorIcon = ["temp.png", "chlorine.png", "conduct.png", "turbi.png", "pump.png", "ion.png"];

  fireLogout(context) async {
    Fluttertoast.showToast(msg: "Signing out...");
    await FirebaseAuth.instance.signOut().then((v) => Navigator.pushReplacementNamed(context, '/LoginPage'));
  }

  updateData(context) {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (FirebaseAuth.instance.currentUser == null) {
        timer.cancel();
        return;
      }
      try {
        var userID = FirebaseAuth.instance.currentUser!.uid;
        var path = userID + "/" + deviceID + "/realtime";
        var ref = FirebaseDatabase.instance.ref(path);
        ref.get().then((value) {
          if (value.value == null) return;
          Map<dynamic, dynamic> json = value.value as Map<dynamic, dynamic>;
          Provider.of<Fluvius>(context, listen: false).sensorsFromJson(json);
        });
      } on FirebaseException {
        Fluttertoast.showToast(msg: "Data load failed!");
      } catch (e) {
        Fluttertoast.showToast(msg: "Something went wrong!");
      }
    });
  }

  checkUserType() {
    try {
      FirebaseAuth.instance.currentUser!.reload();
      if (FirebaseAuth.instance.currentUser == null) return;
      var id = FirebaseAuth.instance.currentUser!.uid;
      var ref = FirebaseDatabase.instance.ref(id);
      userEmail = FirebaseAuth.instance.currentUser!.email!;
      ref.get().then((value) {
        Map<dynamic, dynamic> map = value.value! as Map<dynamic, dynamic>;
        userType = map['userType'] as String;
        deviceID = map['deviceID'] as String;
        setState(() {});
      });
    } on FirebaseException catch (e) {
      Fluttertoast.showToast(msg: e.message!);
    }
  }

  @override
  void initState() {
    super.initState();
    checkUserType();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    isDarkMode = brightness == Brightness.dark;
    if (FirebaseAuth.instance.currentUser == null) fireLogout(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: userType == 'admin'
            ? IconButton(
                onPressed: () => Navigator.of(context).pushNamed("/Report"),
                icon: Image.asset("assets/chart.png", width: 26, height: 26))
            : const SizedBox.shrink(),
        title: const Center(child: Text("Fluvius 2")),
        actions: [
          if (userType == 'admin')
            IconButton(
                onPressed: () => Navigator.of(context).pushNamed("/Configuration"),
                icon: Image.asset("assets/conf.png", width: 30, height: 30)),
          IconButton(onPressed: () => fireLogout(context), icon: const Icon(Icons.logout)),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(clipBehavior: Clip.none, children: [
            ListTile(
              tileColor: isDarkMode ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
              leading: const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 35, color: Colors.white)),
              title: const Text("Welcome,", style: TextStyle(color: Colors.white54)),
              subtitle: Text(FirebaseAuth.instance.currentUser!.email!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            ),
            Positioned(
              right: 35,
              bottom: -28,
              child: CircleAvatar(
                  backgroundColor: Theme.of(context).disabledColor,
                  radius: 30,
                  child: Image.asset("assets/nig.png", width: 35, height: 35)),
            ),
          ]),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder(
                future: updateData(context),
                builder: (context, data) {
                  return ListView.builder(
                      itemCount: 6,
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(top: 10, bottom: 10),
                          elevation: 3,
                          child: Consumer<Fluvius>(
                            builder: (context, fluvius, child) {
                              return ListTile(
                                leading: isDarkMode
                                    ? InvertColors(
                                        child: Image.asset("assets/" + sensorIcon[index], width: 35, height: 35))
                                    : Image.asset("assets/" + sensorIcon[index], width: 35, height: 35),
                                title: Text(sensorName[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(sensorUnit[index]),
                                trailing: Container(
                                    color: index < 4
                                        ? isDarkMode
                                            ? Colors.black54
                                            : Colors.grey[200]
                                        : index == 4
                                            ? fluvius.pumpBg
                                            : fluvius.ionBg,
                                    width: 70,
                                    height: 50,
                                    child: Center(
                                        child: Text(fluvius.sensors()[index], style: const TextStyle(fontSize: 25)))),
                              );
                            },
                          ),
                        );
                      });
                }),
          ),
        ],
      ),
    );
  }
}
