import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsi_cuaca/utils/weather_code.dart';
import 'package:responsi_cuaca/viewmodels/weather_viewmodel.dart';

// View: Weather Screen (Layar Utama Cuaca).
// Menampilkan cuaca saat ini dan prakiraan cuaca harian sesuai spesifikasi Open-Meteo API.
// Menerapkan MVVM: View hanya membaca state dari WeatherViewModel dan memanggil method-nya.
class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuaca Terkini'),
        actions: [
          Consumer<WeatherViewModel>(
            builder: (context, vm, _) {
              if (vm.selectedLocation == null) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(
                  vm.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: vm.isFavorite ? Colors.redAccent : null,
                ),
                tooltip: vm.isFavorite ? 'Hapus dari Favorit' : 'Simpan sebagai Favorit',
                onPressed: () => vm.toggleFavorite(),
              );
            },
          ),
        ],
      ),
      body: Consumer<WeatherViewModel>(
        builder: (context, vm, child) {
          // 1. Kondisi Loading
          if (vm.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Mengambil data cuaca dari Open-Meteo...',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          // 2. Kondisi Error
          if (vm.isError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 64, color: colorScheme.error),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal Memuat Cuaca',
                      style: theme.textTheme.titleLarge?.copyWith(color: colorScheme.error),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vm.errorMessage ?? 'Terjadi kesalahan pada koneksi atau server.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => vm.fetchWeather(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          // 3. Kondisi Data Kosong
          if (vm.isEmpty || vm.weather == null || vm.selectedLocation == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off_rounded, size: 64, color: colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(
                      'Belum Ada Lokasi Dipilih',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Silakan cari nama kota di tab Pencarian untuk melihat cuaca.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
                    ),
                  ],
                ),
              ),
            );
          }

          // 4. Kondisi Sukses (Data Terisi)
          final weather = vm.weather!;
          final location = vm.selectedLocation!;
          final current = weather.current;
          final unitSymbol = vm.temperatureUnit == 'fahrenheit' ? '°F' : '°C';
          final forecastItems = weather.daily.toForecastItems();

          return RefreshIndicator(
            onRefresh: () => vm.fetchWeather(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // CARD UTAMA: Lokasi, Suhu Terkini, dan Kondisi Cuaca
                  Card(
                    color: colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on, size: 20, color: colorScheme.onPrimaryContainer),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  location.name,
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (location.country != null || location.admin1 != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              [
                                if (location.admin1 != null && location.admin1 != location.name) location.admin1!,
                                if (location.country != null) location.country!,
                              ].join(', '),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 16),
                          Icon(
                            WeatherCodeHelper.getIcon(current.weatherCode),
                            size: 72,
                            color: colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            WeatherCodeHelper.getDescription(current.weatherCode),
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${current.temperature2m.toStringAsFixed(1)}$unitSymbol',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // INFORMASI TAMBAHAN (Field API: kelembapan, angin, curah hujan, suhu dirasakan)
                  Text(
                    'Informasi Cuaca Terkini',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = (constraints.maxWidth - 12) / 2;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildDetailCard(
                            theme: theme,
                            width: cardWidth,
                            icon: Icons.thermostat_rounded,
                            label: 'Terasa Seperti',
                            value: '${current.apparentTemperature.toStringAsFixed(1)}$unitSymbol',
                          ),
                          _buildDetailCard(
                            theme: theme,
                            width: cardWidth,
                            icon: Icons.water_drop_outlined,
                            label: 'Kelembapan',
                            value: '${current.relativeHumidity2m}%',
                          ),
                          _buildDetailCard(
                            theme: theme,
                            width: cardWidth,
                            icon: Icons.air_rounded,
                            label: 'Kecepatan Angin',
                            value: '${current.windSpeed10m.toStringAsFixed(1)} km/h',
                          ),
                          _buildDetailCard(
                            theme: theme,
                            width: cardWidth,
                            icon: Icons.grain_rounded,
                            label: 'Curah Hujan',
                            value: '${current.precipitation.toStringAsFixed(1)} mm',
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // PRAKIRAAN BEBERAPA HARI KE DEPAN (Daily Forecast)
                  Text(
                    'Prakiraan Cuaca 7 Hari ke Depan',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: forecastItems.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (context, index) {
                        final item = forecastItems[index];
                        final dayText = index == 0 ? 'Hari Ini' : WeatherCodeHelper.formatDayName(item.date);
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Icon(
                            WeatherCodeHelper.getIcon(item.weatherCode),
                            color: colorScheme.primary,
                            size: 28,
                          ),
                          title: Text(
                            dayText,
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Row(
                            children: [
                              Text(WeatherCodeHelper.getDescription(item.weatherCode)),
                              const SizedBox(width: 8),
                              Icon(Icons.umbrella_rounded, size: 14, color: colorScheme.secondary),
                              const SizedBox(width: 2),
                              Text('${item.precipitationProbabilityMax}%'),
                            ],
                          ),
                          trailing: Text(
                            '${item.tempMin.toStringAsFixed(0)}° / ${item.tempMax.toStringAsFixed(0)}$unitSymbol',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailCard({
    required ThemeData theme,
    required double width,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = theme.colorScheme;
    return SizedBox(
      width: width,
      child: Card(
        color: colorScheme.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 28, color: colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
