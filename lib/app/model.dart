import 'package:flutter/material.dart';

class Fluvius extends ChangeNotifier {
  // sensors variables
  String temp = "0", chlorine = "0.0", conductivity = "0";
  String turbidity = "0.0", pumpState = "OFF", ionizerState = "OFF";
  Color pumpBg = Colors.redAccent;
  Color ionBg = Colors.redAccent;
  // config variables
  int poolWater = 0, tablets = 0;
  double minLevel = 0.0, maxLevel = 0.0;
  int pumpTimer = 0, ionTimer = 0;
  bool timer1Flag = false, timer2Flag = false, timer3Flag = false;
  String timer1 = "00:00", timer2 = "00:00", timer3 = "00:00";
  double latitude = 0.0, longitude = 0.0;

  void sensorsFromJson(Map<dynamic, dynamic> json) {
    temp = json['temp'] as String;
    chlorine = json['chlorine'] as String;
    conductivity = json['conductivity'] as String;
    turbidity = json['turbidity'] as String;
    pumpState = json['pump'] as String;
    ionizerState = json['ionizer'] as String;
    pumpBg = valBgColor(pumpState);
    ionBg = valBgColor(ionizerState);
    notifyListeners();
  }

  Map<String, dynamic> sensorsToJson() {
    return {
      'temp': temp,
      'chlorine': chlorine,
      'conductivity': conductivity,
      'turbidity': turbidity,
      'pump': pumpState,
      'ionizer': ionizerState
    };
  }

  List<String> sensors() {
    return [temp, chlorine, conductivity, turbidity, pumpState, ionizerState];
  }

  Map<String, dynamic> configToJson() {
    return {
      'poolWater': poolWater.toString(),
      'tablets': tablets.toString(),
      'minLevel': minLevel.toStringAsFixed(1),
      'maxLevel': maxLevel.toStringAsFixed(1),
      'pumpTimer': pumpTimer.toString(),
      'ionTimer': ionTimer.toString(),
      't1Flag': timer1Flag ? "1" : "0",
      't2Flag': timer2Flag ? "1" : "0",
      't3Flag': timer3Flag ? "1" : "0",
      'timer1': timer1.toString(),
      'timer2': timer2.toString(),
      'timer3': timer3.toString(),
      'latitude': latitude.toString(),
      'longitude': longitude.toString()
    };
  }

  void configFromJson(Map<dynamic, dynamic> json) {
    poolWater = int.parse(json['poolWater']);
    tablets = int.parse(json['tablets']);
    minLevel = double.parse(json['minLevel']);
    maxLevel = double.parse(json['maxLevel']);
    pumpTimer = int.parse(json['pumpTimer']);
    ionTimer = int.parse(json['ionTimer']);
    timer1Flag = json['t1Flag'] == "1" ? true : false;
    timer2Flag = json['t2Flag'] == "1" ? true : false;
    timer3Flag = json['t3Flag'] == "1" ? true : false;
    timer1 = json['timer1'] as String;
    timer2 = json['timer2'] as String;
    timer3 = json['timer3'] as String;
    latitude = double.parse(json['latitude']);
    longitude = double.parse(json['longitude']);
    notifyListeners();
  }

  List<dynamic> config() {
    return [
      poolWater,
      tablets,
      minLevel,
      maxLevel,
      pumpTimer,
      ionTimer,
      timer1Flag,
      timer2Flag,
      timer3Flag,
      timer1,
      timer2,
      timer3,
      latitude,
      longitude
    ];
  }

  void setConfig(index, value) {
    switch (index) {
      case 0:
        poolWater = value;
        break;
      case 1:
        tablets = value;
        break;
      case 2:
        minLevel = value;
        break;
      case 3:
        maxLevel = value;
        break;
      case 4:
        pumpTimer = value;
        break;
      case 5:
        ionTimer = value;
        break;
      case 6:
        timer1Flag = value;
        break;
      case 7:
        timer2Flag = value;
        break;
      case 8:
        timer3Flag = value;
        break;
      case 9:
        timer1 = value;
        break;
      case 10:
        timer2 = value;
        break;
      case 11:
        timer3 = value;
        break;
      case 12:
        latitude = value;
        break;
      case 13:
        longitude = value;
        break;
    }
    notifyListeners();
  }

  valBgColor(value) {
    if (value == "ON") {
      return Colors.greenAccent;
    } else if (value == "OFF") {
      return Colors.redAccent;
    } else {
      return Colors.grey[200];
    }
  }
}
