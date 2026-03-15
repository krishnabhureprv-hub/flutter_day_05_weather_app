String getWeatherAnimation(String? condition) {
  if (condition == null) return 'assets/animations/sunny.json';
  switch (condition.toLowerCase()) {
    case 'clouds':
    case 'mist':
    case 'smoke':
      return 'assets/animations/cloudy.json';
    case 'rain':
    case 'drizzle':
      return 'assets/animations/rainy.json';
    case 'thunderstorm':
      return 'assets/animations/storm.json';
    default:
      return 'assets/animations/sunny.json';
  }
}