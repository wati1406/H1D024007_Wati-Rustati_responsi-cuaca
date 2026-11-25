import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsi_cuaca/utils/weather_code.dart';
import 'package:responsi_cuaca/viewmodels/settings_viewmodel.dart';
import 'package:responsi_cuaca/viewmodels/weather_viewmodel.dart';

// View: Weather Screen (Layar Utama Cuaca).
// Menampilkan cuaca saat ini dengan kartu latar adaptif kondisi cuaca,
// tombol kecil pengatur tema & satuan suhu, serta prakiraan 7 hari bebas overflow.
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
          // Tombol kecil pengatur Satuan Suhu (°C / °F)
          Consumer2<WeatherViewModel, SettingsViewModel>(
            builder: (context, weatherVm, settingsVm, _) {
              final isCelsius = settingsVm.temperatureUnit == 'celsius';
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: ActionChip(
                  avatar: Icon(
                    Icons.thermostat_outlined,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  label: Text(
                    isCelsius ? '°C' : '°F',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    final newUnit = isCelsius ? 'fahrenheit' : 'celsius';
                    settingsVm.setTemperatureUnit(newUnit);
                    weatherVm.setTemperatureUnit(newUnit);
                  },
                ),
              );
            },
          ),
          // Tombol kecil pengatur Tema (Sistem / Gelap)
          Consumer<SettingsViewModel>(
            builder: (context, settingsVm, _) {
              final isDark = settingsVm.themeMode == ThemeMode.dark;
              return IconButton(
                icon: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.brightness_auto_rounded,
                  color: isDark ? Colors.amber : null,
                ),
                tooltip: isDark ? 'Tema: Gelap (Klik untuk ikut Sistem)' : 'Tema: Ikut Sistem (Klik untuk Gelap)',
                onPressed: () {
                  settingsVm.setThemeMode(isDark ? ThemeMode.system : ThemeMode.dark);
                },
              );
            },
          ),
          // Tombol favorit
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
                      'Silakan cari nama kota di tab Cari untuk melihat cuaca.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
                    ),
                  ],
                ),
              ),
            );
          }

          // 4. Kondisi Sukses
          final weather = vm.weather!;
          final location = vm.selectedLocation!;
          final current = weather.current;
          final unitSymbol = vm.temperatureUnit == 'fahrenheit' ? '°F' : '°C';
          final forecastItems = weather.daily.toForecastItems();
          final isSunnyWeather = WeatherCodeHelper.isSunny(current.weatherCode);

          return RefreshIndicator(
            onRefresh: () => vm.fetchWeather(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // CARD UTAMA: Foto Adaptif Cuaca + Shadow Kuning Cerah + Tipografi Rapi
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        if (isSunnyWeather)
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.45),
                            blurRadius: 22,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          )
                        else
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          // 1. Gambar Background Foto sesuai kondisi
                          Positioned.fill(
                            child: Image.network(
                              WeatherCodeHelper.getBackgroundImageUrl(current.weatherCode),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(color: colorScheme.primaryContainer);
                              },
                            ),
                          ),
                          // 2. Lapisan Overlay Gelap agar seluruh teks putih terbaca kontras & jelas
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.40),
                                    Colors.black.withValues(alpha: 0.75),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // 3. Konten Teks Informasi Kota & Cuaca (Layout Bersih, Proporsional)
                          Padding(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Baris Nama Kota & Region
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 18, color: Colors.white),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        location.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if (location.country != null || location.admin1 != null) ...[
                                  const SizedBox(height: 2),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 24),
                                    child: Text(
                                      [
                                        if (location.admin1 != null && location.admin1 != location.name)
                                          location.admin1!,
                                        if (location.country != null) location.country!,
                                      ].join(', '),
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 24),

                                // Baris Suhu Utama & Ikon Cuaca
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${current.temperature2m.toStringAsFixed(1)}$unitSymbol',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 42,
                                            fontWeight: FontWeight.bold,
                                            height: 1.0,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.20),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            WeatherCodeHelper.getDescription(current.weatherCode),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      WeatherCodeHelper.getIcon(current.weatherCode),
                                      size: 58,
                                      color: isSunnyWeather ? Colors.amberAccent : Colors.white,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // INFORMASI TAMBAHAN (Suhu rasa, kelembapan, angin, curah hujan)
                  Text(
                    'Informasi Cuaca Terkini',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
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

                  const SizedBox(height: 22),

                  // PRAKIRAAN BEBERAPA HARI KE DEPAN (Bebas dari Overflow Strip Kuning/Merah)
                  Text(
                    'Prakiraan Cuaca 7 Hari ke Depan',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: forecastItems.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (context, index) {
                        final item = forecastItems[index];
                        final dayText = index == 0 ? 'Hari Ini' : WeatherCodeHelper.formatDayName(item.date);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              // Ikon cuaca
                              Icon(
                                WeatherCodeHelper.getIcon(item.weatherCode),
                                color: colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              // Hari dan deskripsi kondisi (Expanded agar tidak overflow)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dayText,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            WeatherCodeHelper.getDescription(item.weatherCode),
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: colorScheme.onSurfaceVariant,
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(Icons.umbrella_rounded, size: 12, color: colorScheme.secondary),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${item.precipitationProbabilityMax}%',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontSize: 11,
                                            color: colorScheme.secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Rentang Suhu Min / Max
                              Text(
                                '${item.tempMin.toStringAsFixed(0)}° / ${item.tempMax.toStringAsFixed(0)}$unitSymbol',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
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
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
        ),
        color: colorScheme.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 24, color: colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
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
