import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsi_cuaca/viewmodels/settings_viewmodel.dart';
import 'package:responsi_cuaca/viewmodels/weather_viewmodel.dart';

// View: Screen Pengaturan
// Mengatur pilihan satuan suhu (°C / °F) dan preferensi tema aplikasi (Terang, Gelap, Ikut Sistem).
// Menerapkan MVVM: perubahan preferensi diproses lewat SettingsViewModel & WeatherViewModel.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // SEKSI 1: SATUAN SUHU
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.thermostat_outlined, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Satuan Suhu',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih satuan temperatur yang akan diminta ke Open-Meteo API.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  Consumer2<SettingsViewModel, WeatherViewModel>(
                    builder: (context, settingsVm, weatherVm, _) {
                      return SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'celsius',
                              label: Text('Celsius (°C)'),
                              icon: Icon(Icons.ac_unit),
                            ),
                            ButtonSegment(
                              value: 'fahrenheit',
                              label: Text('Fahrenheit (°F)'),
                              icon: Icon(Icons.wb_sunny_outlined),
                            ),
                          ],
                          selected: {settingsVm.temperatureUnit},
                          onSelectionChanged: (newSelection) {
                            final val = newSelection.first;
                            settingsVm.setTemperatureUnit(val);
                            weatherVm.setTemperatureUnit(val);
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // SEKSI 2: TEMA TAMPILAN
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.palette_outlined, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Tema Aplikasi',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih mode tampilan Material Design terpusat.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  Consumer<SettingsViewModel>(
                    builder: (context, settingsVm, _) {
                      return SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<ThemeMode>(
                          segments: const [
                            ButtonSegment(
                              value: ThemeMode.system,
                              label: Text('Sistem'),
                              icon: Icon(Icons.brightness_auto),
                            ),
                            ButtonSegment(
                              value: ThemeMode.light,
                              label: Text('Terang'),
                              icon: Icon(Icons.light_mode),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              label: Text('Gelap'),
                              icon: Icon(Icons.dark_mode),
                            ),
                          ],
                          selected: {settingsVm.themeMode},
                          onSelectionChanged: (newSelection) {
                            settingsVm.setThemeMode(newSelection.first);
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // SEKSI 3: TENTANG APLIKASI
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Tentang Aplikasi',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aplikasi Cuaca Responsi Flutter\nData cuaca diambil langsung dari Open-Meteo REST API (Forecast & Geocoding).\nArsitektur MVVM dengan State Management Provider.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
