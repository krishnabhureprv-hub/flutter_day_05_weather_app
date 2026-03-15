import 'package:flutter/material.dart';

class ForecastTile extends StatelessWidget {
  final String day;
  final String temp;
  final String icon;

  const ForecastTile({super.key, required this.day, required this.temp, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Text(day.substring(5, 10), style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 5),
          const Icon(Icons.cloud, color: Colors.white, size: 30),
          const SizedBox(height: 5),
          Text("$temp°", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}