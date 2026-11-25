import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:responsi_cuaca/services/storage_service.dart';
import 'package:responsi_cuaca/services/weather_service.dart';
import 'package:responsi_cuaca/theme/app_theme.dart';
import 'package:responsi_cuaca/viewmodels/favorites_viewmodel.dart';
import 'package:responsi_cuaca/viewmodels/search_viewmodel.dart';
import 'package:responsi_cuaca/viewmodels/settings_viewmodel.dart';
import 'package:responsi_cuaca/viewmodels/weather_viewmodel.dart';
import 'package:responsi_cuaca/views/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi SharedPreferences untuk Local Storage
  final sharedPreferences = await SharedPreferences.getInstance();
  final storageService = StorageService(sharedPreferences);
  final weatherService = WeatherService();

  runApp(
    MultiProvider(
      providers: [
        // Services
        Provider<WeatherService>.value(value: weatherService),
        Provider<StorageService>.value(value: storageService),

        // ViewModels
        ChangeNotifierProvider<WeatherViewModel>(
          create: (_) => WeatherViewModel(
            weatherService: weatherService,
            storageService: storageService,
          )..initializeWeather(),
        ),
        ChangeNotifierProvider<SearchViewModel>(
          create: (_) => SearchViewModel(
            weatherService: weatherService,
            storageService: storageService,
          ),
        ),
        ChangeNotifierProvider<FavoritesViewModel>(
          create: (_) => FavoritesViewModel(
            storageService: storageService,
          ),
        ),
        ChangeNotifierProvider<SettingsViewModel>(
          create: (_) => SettingsViewModel(
            storageService: storageService,
          ),
        ),
      ],
      child: const ResponsiCuacaApp(),
    ),
  );
}

class ResponsiCuacaApp extends StatelessWidget {
  const ResponsiCuacaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Mendengarkan perubahan tema dari SettingsViewModel
    return Consumer<SettingsViewModel>(
      builder: (context, settingsVm, child) {
        return MaterialApp(
          title: 'Responsi Cuaca',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settingsVm.themeMode,
          home: const MainNavigationScreen(),
        );
      },
    );
  }
}
