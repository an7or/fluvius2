import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluvius2/app/shared.dart';
import 'package:geolocator/geolocator.dart';
import 'package:invert_colors/invert_colors.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'app/model.dart';

class Configuration extends StatelessWidget {
  Configuration({Key? key}) : super(key: key);

  var configName = [
    "Swimming Pool Water",
    "Chlorine Tablets",
    "Min. Chlorine Level",
    "Max. Chlorine Level",
    "Pump Duration Time",
    "Ionizer Duration Time",
    "Ionizer Timer 1 Mode",
    "Ionizer Timer 2 Mode",
    "Ionizer Timer 3 Mode",
    "Ionizer Timer 1 Set",
    "Ionizer Timer 2 Set",
    "Ionizer Timer 3 Set",
    "Location"
  ];
  var configUnit = [
    "[LITRE]",
    "[U]",
    "[PPM]",
    "[PPM]",
    "[MINUTES]",
    "[MINUTES]",
    "[ON/OFF]",
    "[ON/OFF]",
    "[ON/OFF]",
    "[HH:MM]",
    "[HH:MM]",
    "[HH:MM]",
    "[LATITUDE, LONGITUDE]"
  ];
  var configIcon = [
    "pool.png",
    "tablet.png",
    "chlorine.png",
    "chlorine.png",
    "pump.png",
    "ion.png",
    "toggle.png",
    "toggle.png",
    "toggle.png",
    "timer.png",
    "timer.png",
    "timer.png",
    "location.png"
  ];

  Future<void> getPosition(context) async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: 'Location permissions are denied');
      return;
    }

    Fluttertoast.showToast(msg: 'Getting location data...');
    Geolocator.getCurrentPosition().then((value) {
      Provider.of<Fluvius>(context, listen: false).latitude = value.latitude;
      Provider.of<Fluvius>(context, listen: false).longitude = value.longitude;
      Fluttertoast.showToast(msg: 'Location updated.');
    });
  }

  Widget modifyOption(context, index, fluvius) {
    var config = fluvius.config();
    switch (index) {
      case 0:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                config[index] -= 1000;
                fluvius.setConfig(index, config[index]);
              },
              icon: const Icon(Icons.remove_circle),
            ),
            Text(
              fluvius.config()[index].toString(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () {
                config[index] += 1000;
                fluvius.setConfig(index, config[index]);
              },
              icon: const Icon(Icons.add_circle),
            ),
          ],
        );
      case 1:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                config[index] -= 1;
                fluvius.setConfig(index, config[index]);
              },
              icon: const Icon(Icons.remove_circle),
            ),
            Text(
              fluvius.config()[index].toString(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () {
                config[index] += 1;
                fluvius.setConfig(index, config[index]);
              },
              icon: const Icon(Icons.add_circle),
            ),
          ],
        );
      case 4:
      case 5:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                config[index] -= 10;
                fluvius.setConfig(index, config[index]);
              },
              icon: const Icon(Icons.remove_circle),
            ),
            Text(
              fluvius.config()[index].toString(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () {
                config[index] += 10;
                fluvius.setConfig(index, config[index]);
              },
              icon: const Icon(Icons.add_circle),
            ),
          ],
        );
      case 2:
      case 3:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                config[index] -= 0.1;
                fluvius.setConfig(index, config[index]);
              },
              icon: const Icon(Icons.remove_circle),
            ),
            Text(
              fluvius.config()[index].toStringAsFixed(1),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () {
                config[index] += 0.1;
                fluvius.setConfig(index, config[index]);
              },
              icon: const Icon(Icons.add_circle),
            ),
          ],
        );
      case 9:
      case 10:
      case 11:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                fluvius.config()[index].toString(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                  onPressed: () async {
                    TimeOfDay time = TimeOfDay(
                        hour: int.parse(config[index].split(":")[0]), minute: int.parse(config[index].split(":")[1]));
                    time = (await showTimePicker(context: context, initialTime: time))!;
                    config[index] = time.hour.toString().padLeft(2, '0') + ":" + time.minute.toString().padLeft(2, '0');
                    fluvius.setConfig(index, config[index]);
                  },
                  child: const Text("Change Time"))
            ],
          ),
        );
      case 12:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fluvius.config()[index].toString(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    fluvius.config()[index + 1].toString(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ElevatedButton(onPressed: () => getPosition(context), child: const Text("Update"))
            ],
          ),
        );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuration"),
        actions: [
          IconButton(
              onPressed: () {
                try {
                  var userID = FirebaseAuth.instance.currentUser!.uid;
                  var ref = FirebaseDatabase.instance.ref(userID + "/" + deviceID + "/config");
                  var conf = Provider.of<Fluvius>(context, listen: false).configToJson();
                  ref.update(conf);
                  Fluttertoast.showToast(msg: "Data saved on server.");
                } on FirebaseException catch (e) {
                  Fluttertoast.showToast(msg: e.message!);
                }
              },
              icon: const Icon(Icons.save))
        ],
      ),
      body: ListView.builder(
          itemCount: 13,
          cacheExtent: double.infinity,
          padding: const EdgeInsets.all(10),
          itemBuilder: (context, index) {
            var userID = FirebaseAuth.instance.currentUser!.uid;
            var ref = FirebaseDatabase.instance.ref(userID + "/" + deviceID + "/config");
            ref.get().then((value) {
              Map<dynamic, dynamic> json = value.value as Map<dynamic, dynamic>;
              Provider.of<Fluvius>(context, listen: false).configFromJson(json);
            });
            return Card(
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              elevation: 3,
              child: Consumer<Fluvius>(
                builder: (context, fluvius, child) {
                  return Column(
                    children: [
                      ListTile(
                        leading: isDarkMode
                            ? InvertColors(child: Image.asset("assets/" + configIcon[index], width: 35, height: 35))
                            : Image.asset("assets/" + configIcon[index], width: 35, height: 35),
                        title: Text(configName[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(configUnit[index]),
                        trailing: index >= 6 && index <= 8
                            ? ToggleSwitch(
                                totalSwitches: 2,
                                minWidth: 50,
                                labels: const ["OFF", "ON"],
                                initialLabelIndex: fluvius.config()[index] ? 1 : 0,
                                onToggle: (val) {
                                  fluvius.setConfig(index, val == 1 ? true : false);
                                },
                              )
                            : const SizedBox.shrink(),
                      ),
                      modifyOption(context, index, fluvius)
                    ],
                  );
                },
              ),
            );
          }),
    );
  }
}
