import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'dart:math' as Math;
class EEGGraphScreen extends StatefulWidget {
  @override
  _EEGGraphScreenState createState() => _EEGGraphScreenState();
}

class _EEGGraphScreenState extends State<EEGGraphScreen> {
  List<FlSpot> eegData = [];
  List<List<dynamic>> csvData = [];
  int currentIndex = 0;
  Timer? timer;
  bool isDataLoaded = false;
  
  // Window size for display (how many data points to show at once)
  final int displayWindow = 200;
  
  // Initial Y-axis bounds to prevent NaN errors
  double minY = -100;
  double maxY = 100;

  @override
  void initState() {
    super.initState();
    loadCSV();
  }

  Future<void> loadCSV() async {
    try {
      final rawData = await rootBundle.loadString('assets/EEG_Data.csv');
      csvData = const CsvToListConverter().convert(rawData);
      
      // Skip header row if present
      if (csvData.isNotEmpty && csvData[0][0].toString().toLowerCase() == 'time' || 
          csvData[0][3].toString().toLowerCase().contains('eeg')) {
        csvData.removeAt(0);
      }

      // Pre-process first few rows to establish initial Y range
      for (int i = 0; i < Math.min(20, csvData.length); i++) {
        if (csvData[i].length > 3) {
          double y = double.tryParse(csvData[i][3].toString()) ?? 0.0;
          if (!y.isNaN && !y.isInfinite) {
            if (y < minY) minY = y;
            if (y > maxY) maxY = y;
          }
        }
      }
      
      // Add padding to initial range
      double padding = (maxY - minY) * 0.2;
      minY -= padding;
      maxY += padding;
      
      setState(() {
        isDataLoaded = true;
      });
      
      startSimulation();
    } catch (e) {
      print("Error loading CSV: $e");
    }
  }

  void startSimulation() {
    timer = Timer.periodic(Duration(milliseconds: 16), (Timer t) {
      if (currentIndex < csvData.length) {
        setState(() {
          // Skip invalid rows
          if (csvData[currentIndex].length <= 3) {
            currentIndex++;
            return;
          }
          
          // Safe parsing
          double x = currentIndex.toDouble(); 
          double y = double.tryParse(csvData[currentIndex][3].toString()) ?? 0.0;
          
          // Skip NaN or infinite values
          if (y.isNaN || y.isInfinite) {
            currentIndex++;
            return;
          }
          
          // Update min and max Y values with dampening to reduce shakiness
          if (y < minY) minY = minY * 0.95 + y * 0.05;
          if (y > maxY) maxY = maxY * 0.95 + y * 0.05;
          
          eegData.add(FlSpot(x, y));
          
          // Keep only the last 'displayWindow' points
          if (eegData.length > displayWindow) {
            eegData.removeAt(0);
          }
          
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
    if (!isDataLoaded) {
      return Scaffold(
        appBar: AppBar(title: Text('EEG Live Graph')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // Calculate visible X-axis range
    double minX = eegData.isEmpty ? 0 : eegData.first.x;
    double maxX = eegData.isEmpty ? displayWindow.toDouble() : eegData.last.x;
    
    return Scaffold(
      appBar: AppBar(title: Text('EEG Live Graph')),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: eegData.isEmpty 
                  ? Center(child: Text("Preparing data..."))
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          drawHorizontalLine: true,
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.black12, width: 1),
                        ),
                        minX: minX,
                        maxX: maxX,
                        minY: minY,
                        maxY: maxY,
                        lineBarsData: [
                          LineChartBarData(
                            spots: eegData,
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 2,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                      ),
                    ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Points: ${eegData.length}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Progress: ${(currentIndex * 100 / csvData.length).toStringAsFixed(1)}%',
                      style: TextStyle(fontWeight: FontWeight.bold),
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

// Add this to fix any imports
