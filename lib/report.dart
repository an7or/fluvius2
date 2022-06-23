import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluvius2/app/shared.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class Temperature {
  DateTime date;
  double temp;
  Temperature(this.temp, this.date);
}

class Chlorine {
  DateTime date;
  double chlorine;
  Chlorine(this.chlorine, this.date);
}

class Report extends StatefulWidget {
  Report({Key? key}) : super(key: key);

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  static var n = DateTime.now().toString();
  DateTime reportFrom = DateTime.parse(n.split(" ")[0]);
  DateTime reportTo = DateTime.parse(n.split(" ")[0]);
  List<charts.Series<dynamic, DateTime>> tempSeries = [], chlorineSeries = [];
  bool showChart = false;

  fireGetReport() {
    try {
      var userID = FirebaseAuth.instance.currentUser!.uid;
      var ref = FirebaseDatabase.instance.ref(userID + "/" + deviceID + "/report");
      List<Map<DateTime, dynamic>> range = [];
      int days = 0;
      ref.get().then((value) {
        Map<dynamic, dynamic> json = value.value as Map<dynamic, dynamic>;
        json.forEach((key, value) {
          var d = key.toString().split('-');
          var date = DateTime(int.parse(d[0]), int.parse(d[1]), int.parse(d[2]));
          if (date.isAtSameMomentAs(reportFrom) ||
              date.isAtSameMomentAs(reportTo) ||
              (date.isAfter(reportFrom) && date.isBefore(reportTo))) {
            range.add({DateTime.parse(key.toString()): value});
            days++;
          }
        });
        Fluttertoast.showToast(msg: "Reporting for " + days.toString() + " days.");
        //-------------------------------------------
        List<Temperature> tempData = [];
        List<Chlorine> chlorineData = [];
        for (var element in range) {
          element.forEach((date, hourMap) {
            Map<dynamic, dynamic> hours = hourMap as Map<dynamic, dynamic>;
            hours.forEach((hour, valueMap) {
              Map<dynamic, dynamic> values = valueMap as Map<dynamic, dynamic>;
              var d = DateTime(date.year, date.month, date.day, int.parse(hour));
              var t = double.parse(values['temp']);
              var c = double.parse(values['chlorine']);
              tempData.add(Temperature(t, d));
              chlorineData.add(Chlorine(c, d));
            });
          });
        }
        //-------------------------------------------
        var series1 = charts.Series<Temperature, DateTime>(
          id: 'Temp',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (Temperature temp, _) => temp.date,
          measureFn: (Temperature temp, _) => temp.temp,
          data: tempData,
        );
        tempSeries.clear();
        tempSeries.add(series1);
        var series2 = charts.Series<Chlorine, DateTime>(
          id: 'chlorine',
          colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
          domainFn: (Chlorine temp, _) => temp.date,
          measureFn: (Chlorine temp, _) => temp.chlorine,
          data: chlorineData,
        );
        chlorineSeries.clear();
        chlorineSeries.add(series2);
        //-------------------------------------------
        showChart = true;
        setState(() {});
        //-------------------------------------------
      });
    } on FirebaseException catch (e) {
      Fluttertoast.showToast(msg: e.message!);
    } catch (e) {
      Fluttertoast.showToast(msg: "Something went wrong!");
    }
  }

  Widget displayChart() {
    return Column(children: [
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Water Temperature [°C]", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      SizedBox(
        height: 300,
        width: double.infinity,
        child: Card(
          child: charts.TimeSeriesChart(
            tempSeries,
            defaultInteractions: true,
            animate: true,
            defaultRenderer: charts.LineRendererConfig(includeArea: true, includePoints: true),
          ),
        ),
      ),
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Chlorine Level [PPM]", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      SizedBox(
        height: 300,
        width: double.infinity,
        child: Card(
          child: charts.TimeSeriesChart(
            chlorineSeries,
            defaultInteractions: true,
            animate: true,
            defaultRenderer: charts.LineRendererConfig(includeArea: true, includePoints: true),
          ),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Chart"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Report From:",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          reportFrom = (await showDatePicker(
                              context: context,
                              firstDate: DateTime(2022),
                              initialDate: DateTime.now(),
                              lastDate: DateTime.now()))!;
                          fireGetReport();
                        },
                        child: Text(reportFrom.toString().split(' ')[0],
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Report To: ",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          reportTo = (await showDatePicker(
                              context: context,
                              firstDate: reportFrom,
                              initialDate: DateTime.now(),
                              lastDate: DateTime.now()))!;
                          fireGetReport();
                        },
                        child: Text(reportTo.toString().split(' ')[0],
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              ),
              if (showChart == true)
                displayChart()
              else
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text("Select date range to display charts.", style: TextStyle(fontSize: 20)),
                )
            ],
          ),
        ),
      ),
    );
  }
}
