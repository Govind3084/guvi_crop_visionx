import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'weather.dart';
import 'screens/fertilizer_calculator.dart';
import 'screens/community_screen.dart';
import 'screens/market_screen.dart';
import 'screens/plant_scanner_screen.dart';
import 'widgets/scheme_carousel.dart';
import 'widgets/language_selector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale('en'), // English
        Locale('ta'), // Tamil
        Locale('hi'), // Hindi
        Locale('ml'), // Malayalam
        Locale('kn'), // Kannada
        Locale('te'), // Telugu
      ],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'app.title'.tr(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: HomeDashboard(),
    );
  }
}

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> with SingleTickerProviderStateMixin {
  int _currentIndex = 2; // Start at home
  Map<String, dynamic>? weatherData;
  bool isLoadingWeather = true;
  String? errorMessage;

  // Add government schemes data
  final List<GovernmentScheme> governmentSchemes = [
    GovernmentScheme(
      title: 'PM-KISAN',
      description: 'Direct income support of ₹6000 per year to farmers',
      image: 'assets/schemes/pmkisan.png',
    ),
    GovernmentScheme(
      title: 'Soil Health Card',
      description: 'Free soil testing and recommendations for farmers',
      image: 'assets/schemes/soil.png',
    ),
    GovernmentScheme(
      title: 'KCC Scheme',
      description: 'Kisan Credit Card for easy farm loans',
      image: 'assets/schemes/kcc.png',
    ),
    GovernmentScheme(
      title: 'PMFBY',
      description: 'Pradhan Mantri Fasal Bima Yojana - Crop insurance scheme',
      image: 'assets/schemes/pmfby.png',
    ),
    GovernmentScheme(
      title: 'PKVY',
      description: 'Paramparagat Krishi Vikas Yojana for organic farming',
      image: 'assets/schemes/pkvy.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    setState(() {
      isLoadingWeather = true;
      errorMessage = null;
    });

    try {
      final data = await WeatherService.getWeatherByLocation();
      
      if (mounted) {
        setState(() {
          weatherData = data;
          isLoadingWeather = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          weatherData = null;
          isLoadingWeather = false;
          errorMessage = e.toString();
        });
        
        // Show location permission guidance with fixed settings opener
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: () async {
                // Open app settings on iOS, location settings on Android
                if (await Geolocator.isLocationServiceEnabled()) {
                  await Geolocator.openAppSettings();
                } else {
                  await Geolocator.openLocationSettings();
                }
              },
            ),
          ),
        );
      }
    }
  }

  String getWeatherCondition() {
    if (weatherData == null) {
      return errorMessage ?? 'Unable to fetch weather data';
    }
    // Fix: Use the correct method name from WeatherService
    return WeatherService.getFarmingAdvice(weatherData!);
  }

  Color getWeatherConditionColor() {
    if (weatherData == null) return const Color(0xFFE65100);

    try {
      final condition = weatherData!['condition']['main'].toLowerCase();
      final temp = weatherData!['temperature']['current'];

      if (condition.contains('rain') || condition.contains('drizzle')) {
        return const Color(0xFF1976D2);
      } else if (condition.contains('thunderstorm')) {
        return const Color(0xFFD32F2F);
      } else if (temp > 35 || temp < 10) {
        return const Color(0xFFE65100);
      } else {
        return const Color(0xFF2E7D32);
      }
    } catch (e) {
      return const Color(0xFFE65100);
    }
  }



  void _navigateToScreen(BuildContext context, int index) {
    if (index == _currentIndex && index != 2) return; // Don't reload same screen except home
    
    setState(() => _currentIndex = index);
    
    switch (index) {
      case 0: // Fertilizer
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FertilizerCalculatorScreen(),
          ),
        );
        break;
      case 1: // Plant Scanner
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PlantScannerScreen(),
          ),
        );
        break;
      case 3: // Community
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CommunityScreen(),
          ),
        );
        break;
      case 4: // Market
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MarketScreen(),
          ),
        );
        break;
      case 2: // Home
      default:
        // Already set current index above
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        title: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
            children: [
              TextSpan(text: 'Crop Vision'),
              TextSpan(
                text: 'X',
                style: TextStyle(color: Colors.green.shade700),
              ),
            ],
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: LanguageSelector(),
          ),
        ],
      ),
      
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                // Weather Card - GPS Data Only
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1F5FE),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            weatherData != null 
                              ? (weatherData!['condition']['main'].toLowerCase().contains('rain') 
                                  ? Icons.cloud_outlined 
                                  : Icons.wb_sunny) 
                            : Icons.gps_fixed,
                            color: Colors.orange,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                weatherData != null 
                                  ? weatherData!['location']['name']
                                  : 'Getting Location...',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: fetchWeatherData,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF2E7D32).withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.my_location, size: 16, color: Color(0xFF2E7D32)),
                                  SizedBox(width: 4),
                                  Text(
                                    'update'.tr(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF2E7D32),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (isLoadingWeather)
                        Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 8),
                            Text('weather.loading'.tr(), 
                              style: TextStyle(color: Colors.grey)),
                          ],
                        )
                      else if (weatherData != null)
                        Column(
                          children: [
                            // Show exact GPS location with coordinates
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.gps_fixed, size: 16, color: Color(0xFF2E7D32)),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${weatherData!['location']['name']}, ${weatherData!['location']['country']}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF2E7D32),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${'weather.gps_coordinates'.tr()}: ${weatherData!['location']['coordinates']['latitude'].toStringAsFixed(4)}, ${weatherData!['location']['coordinates']['longitude'].toStringAsFixed(4)}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildWeatherInfo(
                                  Icons.thermostat,
                                  'weather.temperature'.tr(),
                                  '${weatherData!['temperature']['current']}${weatherData!['temperature']['unit']}',
                                ),
                                _buildWeatherInfo(
                                  Icons.water_drop,
                                  'weather.humidity'.tr(),
                                  '${weatherData!['humidity']['value']}${weatherData!['humidity']['unit']}',
                                ),
                                _buildWeatherInfo(
                                  Icons.air,
                                  'weather.wind'.tr(),
                                  '${weatherData!['wind']['speed']['value']} ${weatherData!['wind']['speed']['unit']}',
                                ),
                              ],
                            ),
                          ],
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    'weather.location_error'.tr(),
                                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                errorMessage ?? 'weather.enable_permission'.tr(),
                                style: const TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              weatherData != null ? Icons.agriculture : Icons.info_outline,
                              color: getWeatherConditionColor(),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                getWeatherCondition(),
                                style: TextStyle(
                                  color: getWeatherConditionColor(),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Add Schemes Carousel
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'schemes.title'.tr(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ),
                const SchemeCarousel(),

                const SizedBox(height: 24),

                // Add bottom padding
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      // Removed floating action button
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.white,
        ),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            selectedItemColor: const Color(0xFF2E7D32),
            unselectedItemColor: Colors.grey[600],
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(height: 2),
            unselectedLabelStyle: const TextStyle(height: 2),
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.calculate),
                label: 'fertilizer.title'.tr(),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.document_scanner),
                label: 'plant_scanner.title'.tr(),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'app.home'.tr(),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.groups),
                label: 'app.community'.tr(),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'app.market'.tr(),
              ),
            ],
            onTap: (index) => _navigateToScreen(context, index),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherInfo(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Color(0xFF1976D2), size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
          ),
        ),
      ],
    );
  }


}

class FeaturePlaceholderScreen extends StatelessWidget {
  final String title;
  const FeaturePlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            Text(
              '$title\nComing Soon!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GovernmentScheme {
  final String title;
  final String description;
  final String image;

  GovernmentScheme({
    required this.title,
    required this.description,
    required this.image,
  });
}