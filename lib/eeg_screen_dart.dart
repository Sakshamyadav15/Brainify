// Flutter core packages
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// Chart visualization
import 'package:fl_chart/fl_chart.dart';

// Data processing
import 'package:csv/csv.dart';
import 'dart:math' as Math;

// File operations
import 'package:path_provider/path_provider.dart';

// Date/time formatting
import 'package:intl/intl.dart';

class EEGGraphScreen extends StatefulWidget {
  const EEGGraphScreen({super.key});

  @override
  _EEGGraphScreenState createState() => _EEGGraphScreenState();
}

class _EEGGraphScreenState extends State<EEGGraphScreen> {
  List<FlSpot> eegData = [];
  List<List<dynamic>> csvData = [];
  List<Map<String, dynamic>> processedData = []; // For saving complete data
  int currentIndex = 0;
  Timer? timer;
  bool isDataLoaded = false;
  bool isRecording = false;
  bool isSaving = false;

  // Patient information
  final TextEditingController patientIdController = TextEditingController();
  String? savedFileName;

  // Window size for display (in milliseconds)
  final int timeWindowMs = 5000; // 5-second window

  // Amplification factor for making graph more dramatic
  double amplificationFactor = 1.5;

  // Y-axis bounds
  double minY = -130;
  double maxY = 130;

  // Time tracking
  double startTimeMs = 0;
  double currentTimeMs = 0;
  double lastTimestamp = 0;

  // Real-time simulation
  Stopwatch stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    loadCSV();
  }

  Future<void> loadCSV() async {
    try {
      final rawData = await rootBundle.loadString('assets/EEG_Data.csv');
      csvData = const CsvToListConverter().convert(rawData);

      // Skip header row if present - FIXED: added proper parentheses
      if (csvData.isNotEmpty && 
          ((csvData[0].isNotEmpty && csvData[0][0].toString().toLowerCase() == 'time') || 
           (csvData[0].length > 3 && csvData[0][3].toString().toLowerCase().contains('eeg')))) {
        csvData.removeAt(0);
      }

      // Pre-process first few rows to establish initial Y range
      if (csvData.isNotEmpty && csvData[0].isNotEmpty) {
        // Get start time from first row - FIXED: added null check
        if (csvData[0].length > 0) {
          startTimeMs = _parseTimeToMs(csvData[0][0].toString());
          currentTimeMs = startTimeMs;
          lastTimestamp = startTimeMs;
        }

        // Pre-process to establish initial Y range
        for (int i = 0; i < Math.min(20, csvData.length); i++) {
          if (csvData[i].length > 3) {
            double y = double.tryParse(csvData[i][3].toString()) ?? 0.0;
            if (!y.isNaN && !y.isInfinite) {
              if (y < minY) minY = y;
              if (y > maxY) maxY = y;
            }
          }
        }

        // Add padding to Y range
        double padding = (maxY - minY) * 0.2;
        minY -= padding;
        maxY += padding;

        // Cap Y range consistently - FIXED: made bounds consistent
        if (maxY > 100) maxY = 100;
        if (minY < -100) minY = -100;
      }

      setState(() {
        isDataLoaded = true;
      });
    } catch (e) {
      print("Error loading CSV: $e");
      // FIXED: Show error in UI
      setState(() {
        isDataLoaded = true; // Still mark as loaded to show error message
      });
      // Show error in UI on next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading CSV data: $e'))
        );
      });
    }
  }

  // Function to parse time strings to milliseconds - FIXED: improved robustness
  double _parseTimeToMs(String timeStr) {
    try {
      if (timeStr.isEmpty) return 0;
      
      // Handle various time formats
      if (timeStr.contains(':')) {
        // Format like "HH:MM:SS.mmm"
        List<String> parts = timeStr.split(':');
        if (parts.isEmpty) return 0;
        
        double hours = double.tryParse(parts[0]) ?? 0;
        double minutes = parts.length > 1 ? double.tryParse(parts[1]) ?? 0 : 0;
        double seconds = 0;

        if (parts.length > 2) {
          seconds = double.tryParse(parts[2]) ?? 0;
        }

        return (hours * 3600000) + (minutes * 60000) + (seconds * 1000);
      } else {
        // Assume it's already in milliseconds or seconds
        double time = double.tryParse(timeStr) ?? 0;
        // If it's very small, assume it's in seconds and convert to ms
        if (time < 1000 && time > 0) {
          return time * 1000;
        }
        return time;
      }
    } catch (e) {
      print("Error parsing time: $e");
      return 0;
    }
  }

  // Function to amplify the signal - FIXED: use minY/maxY instead of hardcoded values
  double amplifySignal(double value) {
    // Calculate the mean/baseline (assuming it's around 0)
    double baseline = 0;

    // Amplify the deviation from baseline
    double deviation = value - baseline;
    double amplifiedDeviation = deviation * amplificationFactor;

    // Return the amplified value but respect the limits
    double result = baseline + amplifiedDeviation;

    // Cap at maxY and minY values
    if (result > maxY) return maxY;
    if (result < minY) return minY;

    return result;
  }

  // FIXED: Optimized data processing with batch updates
  void startRealTimeStreaming() {
    if (patientIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter Patient ID'))
      );
      return;
    }
    
    // Reset data for new recording
    eegData.clear();
    processedData.clear();
    currentIndex = 0;

    // Start the stopwatch for real-time tracking
    stopwatch.reset();
    stopwatch.start();

    setState(() {
      isRecording = true;
    });

    // Set up a timer that runs at approximately display refresh rate
    timer = Timer.periodic(Duration(milliseconds: 16), (Timer t) {
      if (currentIndex < csvData.length) {
        // Get real elapsed time
        final realElapsedMs = stopwatch.elapsedMilliseconds;

        // Process data points up to the current time
        bool dataAdded = false;
        List<FlSpot> newSpots = [];
        double latestTimestamp = currentTimeMs;

        while (currentIndex < csvData.length) {
          // Skip invalid rows
          if (csvData[currentIndex].length <= 3) {
            currentIndex++;
            continue;
          }

          // Get time from CSV
          double timestamp = _parseTimeToMs(
            csvData[currentIndex][0].toString(),
          );
          double relativeTime = timestamp - startTimeMs;

          // Break if this data point is in the future according to our real-time simulation
          if (relativeTime > realElapsedMs) {
            break;
          }

          // Safe parsing of EEG value
          double y = double.tryParse(csvData[currentIndex][3].toString()) ?? 0.0;

          // Skip NaN or infinite values
          if (y.isNaN || y.isInfinite || timestamp <= 0) {
            currentIndex++;
            continue;
          }

          // Amplify the signal for display (original data is saved un-amplified)
          double amplifiedY = amplifySignal(y);

          // Update timestamps
          latestTimestamp = timestamp;
          
          // Add data point with time-based x-axis
          dataAdded = true;

          // Save original data for export
          processedData.add({
            'timestamp': timestamp,
            'relative_time': relativeTime,
            'raw_value': y,
            'amplified_value': amplifiedY,
          });

          // Add to temporary list for batch update
          newSpots.add(FlSpot(timestamp, amplifiedY));
          
          currentIndex++;
        }
        
        // Batch update UI if we have new data
        if (dataAdded) {
          setState(() {
            currentTimeMs = latestTimestamp;
            lastTimestamp = latestTimestamp;
            
            // Add new spots to graph data
            eegData.addAll(newSpots);
            
            // Keep only the points within the time window for display
            double windowStartTime = latestTimestamp - timeWindowMs;
            eegData.removeWhere((spot) => spot.x < windowStartTime);
            
            // Update minY with dampening but keep maxY capped
            double lowestPoint = eegData.fold(double.infinity, 
                (prev, spot) => spot.y < prev ? spot.y : prev);
            if (lowestPoint < minY) {
              minY = minY * 0.95 + lowestPoint * 0.05;
              // Ensure minY doesn't go below -100
              if (minY < -100) minY = -100;
            }
          });
        }

        // If we reached the end of the data, update the UI one last time
        if (!dataAdded && currentIndex >= csvData.length) {
          setState(() {
            isRecording = false;
          });
          t.cancel();
          stopwatch.stop();
        }
      } else {
        setState(() {
          isRecording = false;
        });
        t.cancel();
        stopwatch.stop();
      }
    });
  }

  void stopRecording() {
    timer?.cancel();
    stopwatch.stop();
    setState(() {
      isRecording = false;
    });
  }

  // Method to change amplification factor
  void changeAmplification(double newAmplification) {
    setState(() {
      amplificationFactor = newAmplification;

      // Update displayed data with new amplification factor
      if (eegData.isNotEmpty && processedData.isNotEmpty) {
        eegData.clear();

        // Reprocess visible data
        double currentTime = processedData.last['timestamp'];
        double windowStartTime = currentTime - timeWindowMs;

        for (var dataPoint in processedData) {
          if (dataPoint['timestamp'] >= windowStartTime) {
            double amplifiedY = amplifySignal(dataPoint['raw_value']);
            eegData.add(FlSpot(dataPoint['timestamp'], amplifiedY));
          }
        }
      }
    });
  }

  // Save data to CSV file - FIXED: Added more error handling
  Future<void> saveDataToFile() async {
    if (processedData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No data to save'))
      );
      return;
    }

    if (patientIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter Patient ID'))
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // Get application documents directory
      final directory = await getApplicationDocumentsDirectory();
      if (directory == null) {
        throw Exception('Could not access application documents directory');
      }

      // Create a formatted date string
      final now = DateTime.now();
      final dateFormat = DateFormat('yyyyMMdd_HHmmss');
      final dateString = dateFormat.format(now);

      // Create filename with patient ID
      final sanitizedPatientId = patientIdController.text.trim().replaceAll(
        RegExp(r'[^\w]'),
        '_',
      );
      final filename = 'EEG_${sanitizedPatientId}_$dateString.csv';
      final file = File('${directory.path}/$filename');

      // Prepare CSV data
      List<List<dynamic>> csvDataToWrite = [];

      // Add header
      csvDataToWrite.add([
        'Timestamp (ms)',
        'Relative Time (ms)',
        'Raw EEG Value',
        'Amplified EEG Value',
      ]);

      // Add rows
      for (var data in processedData) {
        csvDataToWrite.add([
          data['timestamp'],
          data['relative_time'],
          data['raw_value'],
          data['amplified_value'],
        ]);
      }

      // Convert to CSV and write to file
      String csv = const ListToCsvConverter().convert(csvDataToWrite);
      await file.writeAsString(csv);

      setState(() {
        isSaving = false;
        savedFileName = filename;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data saved to $filename'))
      );
    } catch (e) {
      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e'))
      );
      print("Error saving data: $e");
    }
  }

  // Method to format time for display
  String formatTime(double ms) {
    int totalSeconds = (ms / 1000).round();
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    int milliseconds = (ms % 1000).round();
    return '$minutes:${seconds.toString().padLeft(2, '0')}.${milliseconds.toString().padLeft(3, '0')}';
  }

  @override
  void dispose() {
    timer?.cancel();
    stopwatch.stop();
    patientIdController.dispose();
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

    return Scaffold(
      appBar: AppBar(title: Text('EEG Live Graph')),
      body: Column(
        children: [
          // Patient ID input field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: patientIdController,
              decoration: InputDecoration(
                labelText: 'Patient ID',
                border: OutlineInputBorder(),
                enabled: !isRecording,
              ),
            ),
          ),

          // Status display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isRecording
                      ? 'Recording: ${formatTime(stopwatch.elapsedMilliseconds.toDouble())}'
                      : 'Ready to record',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isRecording ? Colors.red : Colors.black,
                  ),
                ),
                if (savedFileName != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Saved: $savedFileName',
                        style: TextStyle(color: Colors.green),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: eegData.isEmpty
        ? Center(child: Text('No data available - Start recording'))
        : LineChart(
            LineChartData(
              minX: currentTimeMs - timeWindowMs,
              maxX: currentTimeMs,
              minY: minY,
              maxY: maxY,
              clipData: FlClipData.all(),
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      // Convert to relative time for display
                      double relativeTime = value - startTimeMs;
                      return Text('${(relativeTime / 1000).toStringAsFixed(1)}s');
                    },
                    interval: timeWindowMs / 5,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 50,
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: eegData,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 2,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
  ),
),

// Amplification slider
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0),
  child: Row(
    children: [
      Text('Amplification:'),
      Expanded(
        child: Slider(
          value: amplificationFactor,
          min: 0.5,
          max: 3.0,
          divisions: 25,
          label: amplificationFactor.toStringAsFixed(1),
          onChanged: isRecording ? null : changeAmplification,
        ),
      ),
    ],
  ),
),

// Control buttons
Padding(
  padding: const EdgeInsets.all(16.0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      ElevatedButton.icon(
        icon: Icon(isRecording ? Icons.stop : Icons.play_arrow),
        label: Text(isRecording ? 'Stop' : 'Start'),
        style: ElevatedButton.styleFrom(
          backgroundColor: isRecording ? Colors.red : Colors.green,
          minimumSize: Size(120, 50),
        ),
        onPressed: isRecording ? stopRecording : startRealTimeStreaming,
      ),
      ElevatedButton.icon(
        icon: Icon(Icons.save),
        label: Text('Save Data'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          minimumSize: Size(120, 50),
        ),
        onPressed: isSaving || isRecording || processedData.isEmpty ? null : saveDataToFile,
      ),
    ],
  ),
),
        ],
      ),
    );
  }
}