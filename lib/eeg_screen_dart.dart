import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class EEGGraphScreen extends StatefulWidget {
  @override
  _EEGGraphScreenState createState() => _EEGGraphScreenState();
}

class _EEGGraphScreenState extends State<EEGGraphScreen> {
  List<FlSpot> eegData = [];
  List<List<dynamic>> csvData = [];
  int currentIndex = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    loadCSV();
  }

  Future<void> loadCSV() async {
  final rawData = await rootBundle.loadString('assets/EEG_Data.csv');
  csvData = const CsvToListConverter().convert(rawData);

  // Debug: Print first few rows to check for null values
  for (int i = 0; i < 5; i++) {
    print("Row $i: ${csvData[i]}");
  }

  startSimulation();
}


  void startSimulation() {
  timer = Timer.periodic(Duration(milliseconds: 4), (Timer t) {
    if (currentIndex < csvData.length) {
      setState(() {
        // Safe parsing
        double x = double.tryParse(csvData[currentIndex][0].toString()) ?? 0.0;
        double y = double.tryParse(csvData[currentIndex][3].toString()) ?? 0.0;

        eegData.add(FlSpot(x, y));
        currentIndex++;
      });
    } else {
      t.cancel();
    }
  });
}


  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('EEG Live Graph')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: eegData,
                isCurved: true,
                color: Colors.blue,  // Change from colors: [Colors.blue] to color: Colors.blue
                dotData: FlDotData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}