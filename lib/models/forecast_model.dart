class Forecast {
  final String day;
  final double temp;
  final String condition;

  Forecast({required this.day, required this.temp, required this.condition});

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      day: json['dt_txt'], 
      temp: json['main']['temp'].toDouble(),
      condition: json['weather'][0]['main'],
    );
  }
}