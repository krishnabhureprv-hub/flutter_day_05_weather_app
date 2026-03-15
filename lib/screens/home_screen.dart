import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';

class AdvancedWeatherHome extends StatefulWidget {
  const AdvancedWeatherHome({super.key});

  @override
  State<AdvancedWeatherHome> createState() => _AdvancedWeatherHomeState();
}

class _AdvancedWeatherHomeState extends State<AdvancedWeatherHome> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeIn));
    _mainController.forward();

    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wp = Provider.of<WeatherProvider>(context, listen: false);
      if (wp.weather == null) wp.fetchWeather("Mumbai");
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.blueGrey[900]?.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Search City", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter city name...",
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            onPressed: () {
              if (_searchController.text.isNotEmpty) {
                context.read<WeatherProvider>().fetchWeather(_searchController.text);
                _searchController.clear();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text("Search"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WeatherProvider>();
    final w = wp.weather;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _getDynamicColors(w?.mainCondition),
          ),
        ),
        child: Stack(
          children: [
            _buildBackgroundElements(),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: wp.isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : w == null 
                    ? _buildErrorUI(wp)
                    : RefreshIndicator(
                        onRefresh: () => wp.fetchWeather(w.cityName),
                        color: Colors.white,
                        backgroundColor: Colors.transparent,
                        child: CustomScrollView(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            _buildSliverHeader(w),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  children: [
                                    _buildMainTemperature(w),
                                    const SizedBox(height: 40),
                                    _buildHorizontalForecast(),
                                    const SizedBox(height: 30),
                                    _buildStatGrid(w),
                                    const SizedBox(height: 30),
                                    _buildAdvancedChartSection(),
                                    const SizedBox(height: 30),
                                    _buildSunPhaseIndicator(w),
                                    const SizedBox(height: 30)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundElements() {
    return Positioned(
      top: -50,
      right: -50,
      child: Opacity(
        opacity: 0.3,
        child: Container(
          width: 300,
          height: 300,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.white, blurRadius: 100, spreadRadius: 50)],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverHeader(dynamic w) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Column(
        children: [
          Text(w.cityName, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          Text(DateFormat('EEEE, MMM d').format(DateTime.now()), style: const TextStyle(fontSize: 14, color: Colors.white70)),
        ],
      ),
      leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu_rounded)),
      actions: [IconButton(onPressed: _showSearchDialog, icon: const Icon(Icons.search_rounded))],
    );
  }

  Widget _buildMainTemperature(dynamic w) {
    return Column(
      children: [

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Icon(
            _getWeatherIcon(w.mainCondition),
            size: 160,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(colors: [Colors.white, Colors.white60]).createShader(bounds),
          child: Text("${w.temperature.round()}°", style: const TextStyle(fontSize: 110, fontWeight: FontWeight.w100)),
        ),
        Text(w.mainCondition.toUpperCase(), style: const TextStyle(fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.w300)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.keyboard_arrow_up, color: Colors.white60),
            Text("${w.temperature.round() + 2}°", style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 15),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white60),
            Text("${w.temperature.round() - 3}°", style: const TextStyle(fontSize: 16)),
          ],
        ),
      ],
    );
  }

  Widget _buildHorizontalForecast() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("24-HOUR FORECAST", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white54)),
        const SizedBox(height: 15),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: 10,
            itemBuilder: (context, index) => _buildForecastItem(index),
          ),
        ),
      ],
    );
  }

  Widget _buildForecastItem(int index) {
    return Container(
      width: 75,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("${index + 1}h", style: const TextStyle(fontSize: 12, color: Colors.white70)),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Icon(Icons.wb_cloudy_rounded, size: 24, color: Colors.white)),
          Text("${24 + index}°", style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatGrid(dynamic w) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: 1.5,
      children: [
        _buildGlassTile("WIND", "${w.windSpeed} km/h", Icons.air_rounded, Colors.blueAccent),
        _buildGlassTile("HUMIDITY", "${w.humidity}%", Icons.water_drop_rounded, Colors.cyanAccent),
        _buildGlassTile("FEELS LIKE", "${w.temperature.round()}°", Icons.thermostat_rounded, Colors.orangeAccent),
        _buildGlassTile("PRESSURE", "1014 hPa", Icons.speed_rounded, Colors.purpleAccent),
      ],
    );
  }

  Widget _buildGlassTile(String label, String value, IconData icon, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 20),
                  Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38)),
                ],
              ),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedChartSection() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("TEMP TREND", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white54)),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 3), FlSpot(2, 4), FlSpot(4, 3.5), FlSpot(6, 5), FlSpot(8, 4), FlSpot(10, 4.8)],
                    isCurved: true,
                    color: Colors.white,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: Colors.white.withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunPhaseIndicator(dynamic w) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(30)),
      child: Stack(
        children: [
          Center(child: CustomPaint(size: const Size(double.infinity, 100), painter: SunArcPainter())),
          const Positioned(bottom: 0, left: 30, child: _SunTime(label: "SUNRISE", time: "06:14 AM")),
          const Positioned(bottom: 0, right: 30, child: _SunTime(label: "SUNSET", time: "06:52 PM")),
        ],
      ),
    );
  }

  Widget _buildErrorUI(WeatherProvider wp) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off_rounded, size: 80, color: Colors.white24),
          const SizedBox(height: 20),
          const Text("City not found", style: TextStyle(fontSize: 18, color: Colors.white70)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => wp.fetchWeather("Mumbai"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white24),
            child: const Text("Try Again", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  List<Color> _getDynamicColors(String? condition) {
    switch (condition) {
      case 'Rain': return [const Color(0xFF203A43), const Color(0xFF2C5364)];
      case 'Clear': return [const Color(0xFF2980B9), const Color(0xFF6DD5FA)];
      case 'Clouds': return [const Color(0xFF485563), const Color(0xFF29323c)];
      default: return [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)];
    }
  }

  IconData _getWeatherIcon(String? condition) {
    switch (condition) {
      case 'Rain': return Icons.umbrella_rounded;
      case 'Clear': return Icons.wb_sunny_rounded;
      case 'Clouds': return Icons.cloud_rounded;
      default: return Icons.wb_cloudy_rounded;
    }
  }
}

class _SunTime extends StatelessWidget {
  final String label, time;
  const _SunTime({required this.label, required this.time});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label, style: const TextStyle(fontSize: 10, color: Colors.white38)),
      Text(time, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
    ]);
  }
}

class SunArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white24..style = PaintingStyle.stroke..strokeWidth = 2.0;
    final path = Path();
    path.moveTo(40, size.height);
    path.quadraticBezierTo(size.width / 2, -20, size.width - 40, size.height);
    canvas.drawPath(path, paint);
    final sunPaint = Paint()..color = Colors.yellowAccent..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.3), 6, sunPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}