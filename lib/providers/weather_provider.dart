import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();

  WeatherModel? _weather;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isDarkMode = false;
  List<String> _favoriteCities = [];

  WeatherModel? get weather => _weather;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isDarkMode => _isDarkMode;
  List<String> get favoriteCities => _favoriteCities;

  WeatherProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('darkMode') ?? false;
    _favoriteCities = prefs.getStringList('favorites') ?? [];
    notifyListeners();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    notifyListeners();
  }

  void addFavorite(String city) async {
    if (!_favoriteCities.contains(city)) {
      _favoriteCities.add(city);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorites', _favoriteCities);
      notifyListeners();
    }
  }

  void removeFavorite(String city) async {
    final removed = _favoriteCities.remove(city);
    if (removed) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorites', _favoriteCities);
      notifyListeners();
    }
  }

  Future<void> fetchWeatherByCity(String city) async {
    _setLoading(true);
    try {
      final data = await _weatherService.getWeatherByCity(city);
      _weather = data;
      _errorMessage = ''; // clear previous errors on success
    } catch (e) {
      _errorMessage = _parseError(e.toString());
      _weather = null;
    }
    _setLoading(false);
  }

  Future<void> fetchWeatherByLocation(double lat, double lon) async {
    _setLoading(true);
    try {
      final data = await _weatherService.getWeatherByLocation(lat, lon);
      _weather = data;
      _errorMessage = ''; // clear previous errors on success
    } catch (e) {
      _errorMessage = _parseError(e.toString());
      _weather = null;
    }
    _setLoading(false);
  }

  String _parseError(String error) {
    // Custom user-friendly error parsing
    if (error.toLowerCase().contains('city not found')) {
      return 'City not found. Please check the city name.';
    }
    if (error.toLowerCase().contains('location services are disabled')) {
      return 'Location services are disabled. Please enable location.';
    }
    if (error.toLowerCase().contains('permission')) {
      return 'Location permissions are denied. Please grant permissions.';
    }
    // Fall back generic message
    return 'Failed to fetch weather. Please check your internet connection and try again.';
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  void clearWeather() {
    _weather = null;
    _errorMessage = '';
    notifyListeners();
  }
}
