import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: AQIPage(),
    );
  }
}

class AQIPage extends StatefulWidget {
  @override
  State<AQIPage> createState() => _AQIPageState();
}

class _AQIPageState extends State<AQIPage> {
  String city = "Bangkok";
  int aqi = 0;
  double temperature = 0.0;
  String status = "Loading...";
  List<int> forecastAQI = List.filled(6, 0);

  Future<void> fetchData() async {
    const token = "3c659e171185255bb94993819b88572bfa6f6b7e";
    final url = Uri.parse("https://api.waqi.info/feed/$city/?token=$token");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          aqi = data['data']['aqi'];
          temperature = (data['data']['iaqi']?['t']?['v'] ?? 0.0).toDouble();
          status = getAQIStatus(aqi);
          
          for (int i = 0; i < 6; i++) {
            forecastAQI[i] = data['data']['forecast']?['daily']?['pm25']?[i]?['avg'] ?? 0;
          }
        });
      } else {
        setState(() {
          status = "Error fetching data (Code: ${response.statusCode})";
        });
      }
    } catch (e) {
      setState(() {
        status = "Network error: $e";
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
  Color aqiColor = getAQIColor(aqi);

  return Scaffold(
    appBar: AppBar(
      title: const Text("Air Quality Index (AQI)"),
      centerTitle: true,
      backgroundColor: Colors.blueGrey,
    ),
    body: SingleChildScrollView(  // ห่อ Column ด้วย SingleChildScrollView
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextField(
            onSubmitted: (value) {
              setState(() {
                city = value;
              });
              fetchData();
            },
            decoration: const InputDecoration(
              labelText: "Enter city name",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
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
          Row(
            children: [
              Flexible(
                child: Column(
                  children: List.generate(3, (index) => buildAQICard(index)),
                ),
              ),
              Flexible(
                child: Column(
                  children: List.generate(3, (index) => buildAQICard(index + 3)),
                ),
              ),
            ],
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


  Widget buildAQICard(int index) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: getAQIColor(forecastAQI[index]),
          child: Text(
            "${forecastAQI[index]}",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text("Day ${index + 1}"),
        subtitle: Text("AQI Forecast: ${forecastAQI[index]}"),
      ),
    );
  }
}
