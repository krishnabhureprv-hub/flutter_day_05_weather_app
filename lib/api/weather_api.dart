import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  final String apiKey;

  WeatherService(this.apiKey);

  Future<Weather> fetchCurrentWeather(String cityName) async {
    final url = '$_baseUrl/weather?q=$cityName&appid=$apiKey&units=metric';
    
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return Weather.fromJson(jsonDecode(response.body));
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'City nahi mili');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  Future<List<Forecast>> fetchForecast(String cityName) async {
    final url = '$_baseUrl/forecast?q=$cityName&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['list'];

        return list
            .where((item) => item['dt_txt'].contains("12:00:00"))
            .map((item) => Forecast.fromJson(item))
            .toList();
      } else {
        throw Exception('Forecast data fetch nahi ho paya');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  Future<Weather> fetchWeatherByCoords(double lat, double lon) async {
    final url = '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Location based weather failed');
    }
  }
}