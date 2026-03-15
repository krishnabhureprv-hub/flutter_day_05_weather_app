import 'package:flutter/material.dart';

class CustomLoader extends StatelessWidget {
  const CustomLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.lightBlueAccent),
          SizedBox(height: 20),
          Text("Fetching weather data", style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}