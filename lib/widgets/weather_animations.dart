import 'dart:math';
import 'package:flutter/material.dart';

class DynamicWeatherAnimation extends StatefulWidget {
  final String condition;
  const DynamicWeatherAnimation({super.key, required this.condition});

  @override
  State<DynamicWeatherAnimation> createState() => _DynamicWeatherAnimationState();
}

class _DynamicWeatherAnimationState extends State<DynamicWeatherAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(200, 200),
          painter: WeatherPainter(
            condition: widget.condition,
            animationValue: _controller.value,
          ),
        );
      },
    );
  }
}

class WeatherPainter extends CustomPainter {
  final String condition;
  final double animationValue;

  WeatherPainter({required this.condition, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    if (condition.toLowerCase().contains('sun') || condition.toLowerCase().contains('clear')) {
      _drawSun(canvas, center, size);
    } else if (condition.toLowerCase().contains('cloud')) {
      _drawClouds(canvas, center, size);
    } else if (condition.toLowerCase().contains('rain')) {
      _drawRain(canvas, center, size);
    } else {
      _drawSun(canvas, center, size);
    }
  }

  void _drawSun(Canvas canvas, Offset center, Size size) {
    final paint = Paint()..color = Colors.yellowAccent.withOpacity(0.8)..style = PaintingStyle.fill;
    canvas.drawCircle(center, 40, paint);

    final rayPaint = Paint()..color = Colors.yellowAccent.withOpacity(0.5)..strokeWidth = 4..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      double angle = (i * 45) * (pi / 180) + (animationValue * 2 * pi * 0.1);
      Offset start = Offset(center.dx + 50 * cos(angle), center.dy + 50 * sin(angle));
      Offset end = Offset(center.dx + 70 * cos(angle), center.dy + 70 * sin(angle));
      canvas.drawLine(start, end, rayPaint);
    }
  }

  void _drawClouds(Canvas canvas, Offset center, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.8)..style = PaintingStyle.fill;
    double offset = sin(animationValue * 2 * pi) * 10;
    
    canvas.drawCircle(Offset(center.dx - 30 + offset, center.dy), 30, paint);
    canvas.drawCircle(Offset(center.dx + offset, center.dy - 20), 35, paint);
    canvas.drawCircle(Offset(center.dx + 35 + offset, center.dy), 30, paint);
  }

  void _drawRain(Canvas canvas, Offset center, Size size) {
    _drawClouds(canvas, center, size);
    final paint = Paint()..color = Colors.blueAccent..strokeWidth = 2..strokeCap = StrokeCap.round;

    for (int i = 0; i < 5; i++) {
      double xPos = center.dx - 40 + (i * 20);
      double yStart = center.dy + 20 + ((animationValue + i * 0.2) % 1.0) * 40;
      canvas.drawLine(Offset(xPos, yStart), Offset(xPos - 5, yStart + 10), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}