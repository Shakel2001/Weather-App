import 'dart:convert';
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
    _favoriteCities.remove(city);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favoriteCities);
    notifyListeners();
  }

  Future<void> fetchWeatherByCity(String city) async {
    _setLoading(true);
    try {
      final data = await _weatherService.getWeatherByCity(city);
      _weather = data;
    } catch (e) {
      _errorMessage = 'Failed to fetch weather: $e';
    }
    _setLoading(false);
  }

  Future<void> fetchWeatherByLocation(double lat, double lon) async {
    _setLoading(true);
    try {
      final data = await _weatherService.getWeatherByLocation(lat, lon);
      _weather = data;
    } catch (e) {
      _errorMessage = 'Failed to fetch weather: $e';
    }
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _errorMessage = '';
    notifyListeners();
  }

  void clearWeather() {
    _weather = null;
    notifyListeners();
  }
}
