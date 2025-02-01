import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AQIPage(),
    );
  }
}

class AQIPage extends StatefulWidget {
  const AQIPage({super.key});

  @override
  State<AQIPage> createState() => _AQIPageState();
}

class _AQIPageState extends State<AQIPage> {
  String city = "Bangkok";
  int aqi = 0;
  double temperature = 0.0;
  String status = "Loading...";
  String lastUpdated = "";

  double futureData1 = 0.0;
  double futureData2 = 0.0;
  double futureData3 = 0.0;
  double futureData4 = 0.0;
  double futureData5 = 0.0;
  double futureData6 = 0.0;

  Future<void> fetchData() async {
    const token = "3c659e171185255bb94993819b88572bfa6f6b7e";
    final url = Uri.parse("https://api.waqi.info/feed/$city/?token=$token");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          aqi = data['data']['aqi'];
          temperature = data['data']['iaqi']['t']['v'].toDouble();
          status = getAQIStatus(aqi);
          lastUpdated = _getFormattedDateTime();

          // กำหนดค่าตัวอย่างของข้อมูลการทำนาย (6 วันข้างหน้า)
          futureData1 = 75;
          futureData2 = 85;
          futureData3 = 95;
          futureData4 = 105;
          futureData5 = 115;
          futureData6 = 125;
        });
      } else {
        setState(() {
          status = "Error fetching data";
        });
      }
    } catch (e) {
      setState(() {
        status = "Network error";
      });
    }
  }

  String getAQIStatus(int aqi) {
    if (aqi <= 50) return "Good";
    if (aqi <= 100) return "Moderate";
    if (aqi <= 150) return "Unhealthy for Sensitive Groups";
    if (aqi <= 200) return "Unhealthy";
    if (aqi <= 300) return "Very Unhealthy";
    return "Hazardous";
  }

  String _getFormattedDateTime() {
    final now = DateTime.now();
    return "${now.day}-${now.month}-${now.year} ${now.hour}:${now.minute}:${now.second}";
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    Color aqiColor = getAQIColor(aqi);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Air Quality Index (AQI)"),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(  // Make the entire body scrollable
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                city,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: aqiColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "$aqi",
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                status,
                style: TextStyle(
                  fontSize: 20,
                  color: aqiColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Temperature: ${temperature.toStringAsFixed(1)}°C",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                "Last updated: $lastUpdated",
                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: fetchData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  "Refresh",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // แสดงข้อมูลการทำนาย 6 วันข้างหน้า
              Text(
                "Predicted AQI for next 6 days:",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: aqiColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Day 1: $futureData1",
                style: TextStyle(fontSize: 18),
              ),
              Text(
                "Day 2: $futureData2",
                style: TextStyle(fontSize: 18),
              ),
              Text(
                "Day 3: $futureData3",
                style: TextStyle(fontSize: 18),
              ),
              Text(
                "Day 4: $futureData4",
                style: TextStyle(fontSize: 18),
              ),
              Text(
                "Day 5: $futureData5",
                style: TextStyle(fontSize: 18),
              ),
              Text(
                "Day 6: $futureData6",
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color getAQIColor(int aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    if (aqi <= 300) return Colors.purple;
    return Colors.brown;
  }
}
