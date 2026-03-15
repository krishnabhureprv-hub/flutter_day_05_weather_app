import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../api/weather_api.dart';
import '../utils/constants.dart';

class WeatherProvider with ChangeNotifier {
  Weather? _weather;
  List<Forecast> _forecast = [];
  bool _isLoading = false;
  String _errorMessage = '';

  final WeatherService _service = WeatherService(AppConstants.apiKey);

  Weather? get weather => _weather;
  List<Forecast> get forecast => _forecast;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchWeather(String cityName) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _weather = await _service.fetchCurrentWeather(cityName);

      _forecast = await _service.fetchForecast(cityName);
      
    } catch (error) {
      _errorMessage = error.toString().replaceAll('Exception:', '');
      _weather = null;
      _forecast = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWeatherByLocation(double lat, double lon) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _weather = await _service.fetchWeatherByCoords(lat, lon);
      _forecast = await _service.fetchForecast(_weather!.cityName);
    } catch (error) {
      _errorMessage = "Location based data load nahi ho paya.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}