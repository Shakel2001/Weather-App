class WeatherModel {
  final String cityName;
  final double temperature;
  final String description;
  final String icon;
  final int aqi;
  final double rainProbability;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.aqi,
    required this.rainProbability,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json, Map<String, dynamic>? airQualityJson) {
    double rainProb = 0;
    if (json['rain'] != null && json['rain']['1h'] != null) {
      rainProb = double.tryParse(json['rain']['1h'].toString()) ?? 0;
    }

    int aqi = 1;
    if (airQualityJson != null) {
      aqi = airQualityJson['list'][0]['main']['aqi'];
    }

    return WeatherModel(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      aqi: aqi,
      rainProbability: rainProb,
    );
  }
}
