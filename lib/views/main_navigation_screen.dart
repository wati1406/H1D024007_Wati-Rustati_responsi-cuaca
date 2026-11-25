import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsi_cuaca/viewmodels/favorites_viewmodel.dart';
import 'package:responsi_cuaca/views/favorites_screen.dart';
import 'package:responsi_cuaca/views/search_screen.dart';
import 'package:responsi_cuaca/views/settings_screen.dart';
import 'package:responsi_cuaca/views/weather_screen.dart';

// Layar Utama yang menampung NavigationBar dengan 4 tab:
// 1. Cuaca (WeatherScreen)
// 2. Cari (SearchScreen)
// 3. Favorit (FavoritesScreen)
// 4. Pengaturan (SettingsScreen)
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _navigateToWeatherTab() {
    setState(() {
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const WeatherScreen(),
      SearchScreen(
        onLocationChosen: _navigateToWeatherTab,
      ),
      FavoritesScreen(
        onLocationChosen: _navigateToWeatherTab,
      ),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
          // Jika berpindah ke tab Favorit, refresh data favorit
          if (index == 2) {
            context.read<FavoritesViewModel>().loadData();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.cloud_outlined),
            selectedIcon: Icon(Icons.cloud),
            label: 'Cuaca',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Cari',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorit',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}
