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
    if (airQualityJson != null &&
        airQualityJson['list'] != null &&
        airQualityJson['list'] is List &&
        (airQualityJson['list'] as List).isNotEmpty &&
        airQualityJson['list'][0]['main'] != null &&
        airQualityJson['list'][0]['main']['aqi'] != null) {
      aqi = airQualityJson['list'][0]['main']['aqi'];
    }

    final cityName = json['name'] ?? 'Unknown';
    final temperature = (json['main']?['temp'] is num)
        ? (json['main']['temp'] as num).toDouble() : 0.0;
    final weatherList = json['weather'] as List?;
    final weatherObj = weatherList != null && weatherList.isNotEmpty ? weatherList[0] : {};
    final description = weatherObj['description'] ?? 'No description';
    final icon = weatherObj['icon'] ?? '';

    return WeatherModel(
      cityName: cityName,
      temperature: temperature,
      description: description,
      icon: icon,
      aqi: aqi,
      rainProbability: rainProb,
    );
  }

  Map<String, dynamic> toJson() => {
    'cityName': cityName,
    'temperature': temperature,
    'description': description,
    'icon': icon,
    'aqi': aqi,
    'rainProbability': rainProbability,
  };

  @override
  String toString() => toJson().toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is WeatherModel &&
              runtimeType == other.runtimeType &&
              cityName == other.cityName &&
              temperature == other.temperature &&
              description == other.description &&
              icon == other.icon &&
              aqi == other.aqi &&
              rainProbability == other.rainProbability;

  @override
  int get hashCode =>
      cityName.hashCode ^
      temperature.hashCode ^
      description.hashCode ^
      icon.hashCode ^
      aqi.hashCode ^
      rainProbability.hashCode;
}
