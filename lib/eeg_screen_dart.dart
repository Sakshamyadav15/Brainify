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
  final int displayWindow = 50;
  
  // New speed factor (1.0 is normal speed)
  double speedFactor = 1.0;
  
  // Amplification factor for making graph more dramatic
  double amplificationFactor = 1.5;
  
  // Y-axis bounds with max capped at 100
  double minY = -130;
  double maxY = 130; // Max is now fixed at 100

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
            // Cap max Y at 100
            if (y > maxY) maxY = 100;
          }
        }
      }
      
      // Add padding to initial range for minimum only
      double padding = (maxY - minY) * 0.2;
      minY -= padding;
      // Keep maxY at 100
      
      setState(() {
        isDataLoaded = true;
      });
      
      startSimulation();
    } catch (e) {
      print("Error loading CSV: $e");
    }
  }

  // Function to amplify the signal to make it more dramatic
  double amplifySignal(double value) {
    // Calculate the mean/baseline (assuming it's around 0)
    double baseline = 0;
    
    // Amplify the deviation from baseline
    double deviation = value - baseline;
    double amplifiedDeviation = deviation * amplificationFactor;
    
    // Return the amplified value but respect the limits
    double result = baseline + amplifiedDeviation;
    
    // Cap at max 100
    if (result > 100) return 100;
    if (result < -100) return -100;
    
    return result;
  }

  void startSimulation() {
    // Calculate interval based on speed factor (smaller interval = faster speed)
    int interval = (16 / speedFactor).round();
    
    timer = Timer.periodic(Duration(milliseconds: interval), (Timer t) {
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
          
          // Amplify the signal to make it more dramatic
          y = amplifySignal(y);
          
          // Cap y value at 100
          if (y > 100) y = 100;
          
          // Update minY with dampening but keep maxY capped at 100
          if (y < minY) minY = minY * 0.95 + y * 0.05;
          
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

  // Method to change speed factor
  void changeSpeed(double newSpeed) {
    timer?.cancel();
    setState(() {
      speedFactor = newSpeed;
    });
    startSimulation();
  }
  
  // Method to change amplification factor
  void changeAmplification(double newAmplification) {
    setState(() {
      amplificationFactor = newAmplification;
      
      // Clear existing data and restart to apply new amplification
      eegData.clear();
      currentIndex = Math.max(0, currentIndex - displayWindow);
      
      timer?.cancel();
      startSimulation();
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
                        maxY: 100, // Fixed maxY to 100
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
              // Speed control slider
              Row(
                children: [
                  Text('Speed: '),
                  Expanded(
                    child: Slider(
                      value: speedFactor,
                      min: 0.25,
                      max: 4.0,
                      divisions: 15,
                      label: speedFactor.toStringAsFixed(2) + 'x',
                      onChanged: (value) {
                        changeSpeed(value);
                      },
                    ),
                  ),
                  Text('${speedFactor.toStringAsFixed(2)}x'),
                ],
              ),
              SizedBox(height: 8),
              // Amplification control slider
              Row(
                children: [
                  Text('Amplify: '),
                  Expanded(
                    child: Slider(
                      value: amplificationFactor,
                      min: 1.0,
                      max: 3.0,
                      divisions: 10,
                      label: amplificationFactor.toStringAsFixed(1) + 'x',
                      onChanged: (value) {
                        changeAmplification(value);
                      },
                    ),
                  ),
                  Text('${amplificationFactor.toStringAsFixed(1)}x'),
                ],
              ),
              SizedBox(height: 8),
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