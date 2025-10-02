import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class WeatherService {
  static const String _apiKey = 'e4d32c1671e395545f9aaf0e3ee8ed96';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  // Get current GPS location with better error handling
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // Test if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled. Please enable GPS in Settings';
      }

      // Request permission
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied. Please enable in Settings';
      }

      // Get current position with high accuracy
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 5),
      );
    } catch (e) {
      print('Location Error: $e');
      rethrow; // Rethrow to handle in the UI
    }
  }

  // Fetch real-time weather for GPS coordinates
  static Future<Map<String, dynamic>?> getWeatherByLocation() async {
    try {
      // Get current location
      final position = await getCurrentLocation();
      if (position == null) return null;

      print('📍 Got location: ${position.latitude}, ${position.longitude}');
      
      // Fetch weather data
      final url = '$_baseUrl/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _formatWeatherData(data);
      } else {
        throw 'Failed to fetch weather data: ${response.statusCode}';
      }
    } catch (e) {
      print('Error getting weather: $e');
      rethrow; // Rethrow to handle in UI
    }
  }

  // Format raw API data to clean JSON
  static Map<String, dynamic> _formatWeatherData(Map<String, dynamic> rawData) {
    try {
      final weather = rawData['weather'][0];
      final main = rawData['main'];
      final wind = rawData['wind'] ?? {};
      
      return {
        'location': {
          'name': rawData['name'] ?? 'Unknown Location',
          'country': rawData['sys']['country'] ?? 'Unknown',
          'coordinates': {
            'latitude': (rawData['coord']['lat'] ?? 0.0).toDouble(),
            'longitude': (rawData['coord']['lon'] ?? 0.0).toDouble(),
          }
        },
        'temperature': {
          'current': (main['temp'] ?? 0).round(),
          'feels_like': (main['feels_like'] ?? 0).round(),
          'min': (main['temp_min'] ?? 0).round(),
          'max': (main['temp_max'] ?? 0).round(),
          'unit': '°C'
        },
        'condition': {
          'main': weather['main'] ?? 'Clear',
          'description': weather['description'] ?? 'Clear sky',
          'icon': weather['icon'] ?? '01d',
          'code': weather['id'] ?? 800
        },
        'humidity': {
          'value': main['humidity'] ?? 50,
          'unit': '%'
        },
        'wind': {
          'speed': {
            'value': ((wind['speed'] ?? 0) * 3.6).round(),
            'unit': 'km/h'
          },
          'direction': wind['deg'] ?? 0,
          'gust': wind['gust'] != null ? ((wind['gust'] * 3.6).round()) : null
        },
        'pressure': {
          'value': main['pressure'] ?? 1013,
          'unit': 'hPa'
        },
        'visibility': {
          'value': ((rawData['visibility'] ?? 10000) / 1000).toDouble(),
          'unit': 'km'
        },
        'timestamp': {
          'updated': DateTime.now().toIso8601String(),
          'sunrise': rawData['sys']['sunrise'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(rawData['sys']['sunrise'] * 1000).toIso8601String()
            : DateTime.now().toIso8601String(),
          'sunset': rawData['sys']['sunset'] != null
            ? DateTime.fromMillisecondsSinceEpoch(rawData['sys']['sunset'] * 1000).toIso8601String()
            : DateTime.now().toIso8601String(),
        },
        'raw_data': rawData
      };
    } catch (e) {
      print('🚨 Error formatting weather data: $e');
      // Return a basic format with error info
      return {
        'location': {
          'name': 'Error Location',
          'country': 'Unknown',
          'coordinates': {'latitude': 0.0, 'longitude': 0.0}
        },
        'temperature': {'current': 25, 'unit': '°C'},
        'condition': {'main': 'Unknown', 'description': 'Data formatting error'},
        'humidity': {'value': 50, 'unit': '%'},
        'wind': {'speed': {'value': 10, 'unit': 'km/h'}},
        'error': 'Failed to format weather data',
        'raw_data': rawData
      };
    }
  }

  // Enhanced fallback city-based weather
  static Future<Map<String, dynamic>?> getCurrentWeather(String cityName) async {
    try {
      print('🏙️ Fetching fallback weather for city: $cityName');
      final url = '$_baseUrl/weather?q=$cityName,IN&appid=$_apiKey&units=metric';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));

      print('📊 City weather API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final rawData = json.decode(response.body);
        print('✅ City weather data received for: ${rawData['name']}');
        return _formatWeatherData(rawData);
      } else {
        print('❌ City weather API Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('🚨 Exception in city weather fetch: $e');
      return null;
    }
  }

  // Get farming advice based on weather conditions
  static String getFarmingAdvice(Map<String, dynamic> weatherData) {
    try {
      final condition = weatherData['condition']['main'].toLowerCase();
      final temp = weatherData['temperature']['current'];
      final humidity = weatherData['humidity']['value'];
      final location = weatherData['location']['name'];

      if (condition.contains('rain') || condition.contains('drizzle')) {
        return 'Rain detected in $location - Cover crops and ensure proper drainage';
      } else if (condition.contains('thunderstorm')) {
        return 'Storm warning in $location - Secure equipment and protect livestock';
      } else if (temp > 35) {
        return 'High temperature in $location (${temp}°C) - Increase irrigation and provide shade';
      } else if (temp < 10) {
        return 'Cold weather in $location (${temp}°C) - Protect crops from frost';
      } else if (humidity > 80) {
        return 'High humidity in $location (${humidity}%) - Monitor for fungal diseases';
      } else if (humidity < 30) {
        return 'Low humidity in $location (${humidity}%) - Ensure adequate watering';
      } else {
        return 'Perfect farming conditions in $location - Great day for fieldwork';
      }
    } catch (e) {
      print('🚨 Error getting farming advice: $e');
      return 'Unable to analyze weather conditions for farming advice';
    }
  }
}
      