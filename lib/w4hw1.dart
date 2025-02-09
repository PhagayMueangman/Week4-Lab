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

  Color getAQIColor(int aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    if (aqi <= 300) return Colors.purple;
    return Colors.brown;
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    Color aqiColor = getAQIColor(aqi); // สีสำหรับกรอบและข้อความ status

    return Scaffold(
      appBar: AppBar(
        title: const Text("Air Quality Index (AQI)"),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
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
                color: aqiColor, // สีของข้อความ status ตามสีของ AQI
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Temperature: ${temperature.toStringAsFixed(1)}°C",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          ],
        ),
      ),
    );
  }
}
