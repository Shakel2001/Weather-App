import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../services/location_service.dart';
import '../models/weather_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _cityController = TextEditingController();

  // Search button enabled only if input is not empty
  bool get _isSearchEnabled => _cityController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _cityController.addListener(() {
      setState(() {}); // Update search button state
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _fetchByCity() {
    final city = _cityController.text.trim();
    if (city.isNotEmpty) {
      Provider.of<WeatherProvider>(context, listen: false)
          .fetchWeatherByCity(city);
      FocusScope.of(context).unfocus();
    }
  }

  void _fetchByLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      Provider.of<WeatherProvider>(context, listen: false)
          .fetchWeatherByLocation(position.latitude, position.longitude);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location error: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 600;
      return Scaffold(
        appBar: AppBar(
          title: const Text('Weather'),
          actions: [
            Consumer<WeatherProvider>(
              builder: (context, provider, _) => IconButton(
                icon: Icon(
                    provider.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
                tooltip:
                provider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: () => provider.toggleTheme(),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              _buildSearchBar(),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.my_location),
                label: const Text('Detect My Location'),
                onPressed: _fetchByLocation,
              ),
              const SizedBox(height: 20),
              Consumer<WeatherProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return _buildLoadingPlaceholder(isWide: isWide);
                  } else if (provider.errorMessage.isNotEmpty) {
                    return _buildErrorWidget(provider.errorMessage, provider);
                  } else if (provider.weather != null) {
                    return _buildWeatherCard(provider, isWide);
                  } else {
                    return const Center(
                      child: Text(
                        "Search or detect your location",
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              Consumer<WeatherProvider>(
                builder: (context, provider, _) {
                  if (provider.favoriteCities.isEmpty) return const SizedBox();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Favorite Locations",
                        style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 110,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: provider.favoriteCities.length,
                          itemBuilder: (context, index) {
                            final city = provider.favoriteCities[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              child: InkWell(
                                onTap: () {
                                  _cityController.text = city;
                                  _fetchByCity();
                                },
                                onLongPress: () {
                                  provider.removeFavorite(city);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Center(
                                      child: Text(city,
                                          style: const TextStyle(fontSize: 16))),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _cityController,
      decoration: InputDecoration(
        hintText: 'Search city',
        suffixIcon: IconButton(
          icon: Icon(Icons.search,
              color: _isSearchEnabled
                  ? Colors.blue
                  : Colors.grey), // Greyed out if disabled
          onPressed: _isSearchEnabled ? _fetchByCity : null,
          tooltip: _isSearchEnabled ? 'Search' : 'Enter city name',
        ),
      ),
      textInputAction: TextInputAction.search,
      onSubmitted: (_) {
        if (_isSearchEnabled) _fetchByCity();
      },
    );
  }

  Widget _buildWeatherCard(WeatherProvider provider, bool isWide) {
    final weather = provider.weather!;
    final isFavorite = provider.favoriteCities.contains(weather.cityName);

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 500),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: isWide
              ? Row(
            children: [
              _buildLeftColumn(weather, isFavorite, provider),
              const SizedBox(width: 50),
              _buildRightColumn(weather),
            ],
          )
              : Column(
            children: [
              _buildLeftColumn(weather, isFavorite, provider),
              const SizedBox(height: 20),
              _buildRightColumn(weather),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftColumn(
      WeatherModel weather, bool isFavorite, WeatherProvider provider) {
    return Expanded(
      child: Column(
        children: [
          Text(
            weather.cityName,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Image.network(
            "https://openweathermap.org/img/wn/${weather.icon}@4x.png",
            height: 120,
            width: 120,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.cloud_off, size: 120),
          ),
          const SizedBox(height: 8),
          Text(
            "${weather.temperature.toStringAsFixed(1)} °C",
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w600),
          ),
          Text(
            weather.description,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            label: Text(isFavorite ? "Remove from Favorites" : "Add to Favorites"),
            style: ElevatedButton.styleFrom(
              backgroundColor: isFavorite ? Colors.redAccent : null,
            ),
            onPressed: () {
              if (isFavorite) {
                provider.removeFavorite(weather.cityName);
              } else {
                provider.addFavorite(weather.cityName);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRightColumn(WeatherModel weather) {
    // Example additional stats display in a column
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(Icons.air, "Air Quality Index", weather.aqi.toString()),
          const SizedBox(height: 10),
          _infoRow(Icons.grain, "Rain Probability", "${weather.rainProbability} mm/h"),
          // TODO: Add more weather info (humidity, wind, UV, etc.) here
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const Spacer(),
        Text(value),
      ],
    );
  }

  Widget _buildLoadingPlaceholder({required bool isWide}) {
    // Simple placeholder widget while loading
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: isWide ? 200 : 350,
          child: Center(
            child: CircularProgressIndicator(strokeWidth: 5),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message, WeatherProvider provider) {
    return Card(
      color: Colors.red.shade100,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Error",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 10),
            Text(message, style: TextStyle(color: Colors.red.shade700)),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              onPressed: () {
                if (_cityController.text.trim().isNotEmpty) {
                  provider.fetchWeatherByCity(_cityController.text.trim());
                } else if (provider.weather != null) {
                  // refetch for current loaded city
                  provider.fetchWeatherByCity(provider.weather!.cityName);
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

