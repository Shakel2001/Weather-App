import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  final String apiKey = 'badfc4887c23f920c928ac3584bb057f';

  Future<WeatherModel> getWeatherByCity(String city) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) throw Exception('City not found');

    final weatherJson = jsonDecode(response.body);
    final lat = weatherJson['coord']['lat'];
    final lon = weatherJson['coord']['lon'];

    final airQualityJson = await _getAirQuality(lat, lon);
    return WeatherModel.fromJson(weatherJson, airQualityJson);
  }

  Future<WeatherModel> getWeatherByLocation(double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) throw Exception('Failed to load weather');

    final weatherJson = jsonDecode(response.body);
    final airQualityJson = await _getAirQuality(lat, lon);
    return WeatherModel.fromJson(weatherJson, airQualityJson);
  }

  Future<Map<String, dynamic>?> _getAirQuality(double lat, double lon) async {
    final url =
        'http://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
}
