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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AQIPage(),
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
  List<Map<String, dynamic>> dailyForecast = [];
  List<Map<String, dynamic>> hourlyForecast = [];
  String lastUpdated = "";

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
          lastUpdated = formatDateTime(DateTime.now());
          
          dailyForecast = List.generate(6, (index) {
            return {
              'date': formatDate(DateTime.now().add(Duration(days: index))),
              'aqi': (aqi + index * 10) % 300,
              'temperature': (temperature + index).toStringAsFixed(1),
            };
          });

          hourlyForecast = List.generate(6, (index) {
            return {
              'time': formatTime(DateTime.now().add(Duration(hours: index * 3))),
              'aqi': (aqi + index * 5) % 300,
              'temperature': (temperature + (index * 0.5)).toStringAsFixed(1),
            };
          });
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

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  String formatTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:00";
  }

  String formatDateTime(DateTime dateTime) {
    return "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Last Updated: $lastUpdated", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(city, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                const Text("🌍", style: TextStyle(fontSize: 28)),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: aqiColor, borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  Text("$aqi", style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(status, style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                  Text("Temp: ${temperature.toStringAsFixed(1)}°C", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text("6-Day & Hourly Forecast", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Column(
              children: List.generate(6, (index) => ListTile(
                title: Text("${dailyForecast[index]['date']} - AQI: ${dailyForecast[index]['aqi']}, Temp: ${dailyForecast[index]['temperature']}°C"),
                subtitle: Text("${hourlyForecast[index]['time']} - AQI: ${hourlyForecast[index]['aqi']}, Temp: ${hourlyForecast[index]['temperature']}°C"),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
