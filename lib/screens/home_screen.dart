import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _cityController = TextEditingController();

  void _fetchByCity() {
    final city = _cityController.text.trim();
    if (city.isNotEmpty) {
      Provider.of<WeatherProvider>(context, listen: false)
          .fetchWeatherByCity(city);
    }
  }

  void _fetchByLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      Provider.of<WeatherProvider>(context, listen: false)
          .fetchWeatherByLocation(position.latitude, position.longitude);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Location error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WeatherProvider>(context);
    final isDark = provider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () => provider.toggleTheme(),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                hintText: 'Search city',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _fetchByCity,
                ),
              ),
              onSubmitted: (_) => _fetchByCity(),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.my_location),
              label: const Text('Detect My Location'),
              onPressed: _fetchByLocation,
            ),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.errorMessage.isNotEmpty
                  ? Center(
                child: Text(
                  provider.errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              )
                  : provider.weather != null
                  ? _buildWeatherCard(provider)
                  : const Center(
                child: Text("Search or detect your location"),
              ),
            ),
            const SizedBox(height: 20),
            if (provider.favoriteCities.isNotEmpty) ...[
              const Text("Favorite Locations",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
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
                          child: Center(child: Text(city)),
                        ),
                      ),
                    );
                  },
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(WeatherProvider provider) {
    final weather = provider.weather!;
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 500),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                weather.cityName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Image.network(
                "https://openweathermap.org/img/wn/${weather.icon}@2x.png",
                height: 80,
              ),
              Text("${weather.temperature}°C",
                  style: Theme.of(context).textTheme.headlineLarge),
              Text(weather.description,
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text("Air Quality Index: ${weather.aqi}",
                  style: const TextStyle(fontSize: 16)),
              Text("Rain Probability: ${weather.rainProbability} mm/h",
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.favorite_border),
                label: const Text("Add to Favorites"),
                onPressed: () =>
                    provider.addFavorite(weather.cityName),
              )
            ],
          ),
        ),
      ),
    );
  }
}
