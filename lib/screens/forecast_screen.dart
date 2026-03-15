import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final forecastList = context.watch<WeatherProvider>().forecast;

    return Scaffold(
      appBar: AppBar(
        title: const Text("5-Day Forecast"),
        backgroundColor: const Color(0xFF1D3354),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1D3354), Color(0xFF467599)],
          ),
        ),
        child: forecastList.isEmpty
            ? const Center(child: Text("No forecast data available", style: TextStyle(color: Colors.white)))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: forecastList.length,
                itemBuilder: (context, index) {
                  final dayData = forecastList[index];
                  return Card(
                    color: Colors.white.withOpacity(0.1),
                    margin: const EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      leading: const Icon(Icons.wb_sunny, color: Colors.orangeAccent),
                      title: Text(
                        dayData.day,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        dayData.condition,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Text(
                        "${dayData.temp.round()}°C",
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}