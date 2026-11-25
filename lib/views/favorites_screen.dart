import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsi_cuaca/models/location.dart';
import 'package:responsi_cuaca/viewmodels/favorites_viewmodel.dart';
import 'package:responsi_cuaca/viewmodels/weather_viewmodel.dart';

// View: Screen Favorit & Riwayat
// Mengelola daftar kota favorit yang disimpan pengguna serta riwayat pencarian.
// Menggunakan FavoritesViewModel dan WeatherViewModel (MVVM).
class FavoritesScreen extends StatelessWidget {
  final VoidCallback onLocationChosen;

  const FavoritesScreen({super.key, required this.onLocationChosen});

  void _selectLocation(BuildContext context, LocationModel location) {
    context.read<WeatherViewModel>().selectLocation(location);
    onLocationChosen();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi Favorit & Riwayat'),
      ),
      body: Consumer<FavoritesViewModel>(
        builder: (context, vm, child) {
          final favorites = vm.favorites;
          final history = vm.history;

          if (favorites.isEmpty && history.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border_rounded, size: 64, color: colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada favorit',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tandai ikon hati pada cuaca atau hasil pencarian untuk menyimpan lokasi favorit Anda.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // BAGIAN 1: DAFTAR FAVORIT
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.redAccent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Lokasi Favorit (${favorites.length})',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (favorites.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'Belum ada favorit',
                        style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
                      ),
                    ),
                  ),
                )
              else
                ...favorites.map((loc) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(Icons.location_city, color: colorScheme.onPrimaryContainer),
                      ),
                      title: Text(loc.name, style: theme.textTheme.titleMedium),
                      subtitle: Text(
                        loc.fullDisplayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        tooltip: 'Hapus dari favorit',
                        onPressed: () => vm.removeFavorite(loc),
                      ),
                      onTap: () => _selectLocation(context, loc),
                    ),
                  );
                }),

              const SizedBox(height: 24),

              // BAGIAN 2: RIWAYAT PENCARIAN
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.history, color: colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Riwayat Terakhir (${history.length})',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (history.isNotEmpty)
                    TextButton(
                      onPressed: () => vm.clearHistory(),
                      child: const Text('Hapus Riwayat'),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              if (history.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'Belum ada riwayat pencarian',
                        style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
                      ),
                    ),
                  ),
                )
              else
                ...history.map((loc) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(Icons.access_time, color: colorScheme.outline),
                      title: Text(loc.name, style: theme.textTheme.titleMedium),
                      subtitle: Text(
                        loc.fullDisplayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _selectLocation(context, loc),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
