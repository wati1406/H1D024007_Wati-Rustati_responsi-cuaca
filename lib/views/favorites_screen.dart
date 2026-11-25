import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsi_cuaca/models/location.dart';
import 'package:responsi_cuaca/viewmodels/favorites_viewmodel.dart';
import 'package:responsi_cuaca/viewmodels/weather_viewmodel.dart';

// View: Screen Lokasi Favorit
// Menampilkan daftar lokasi favorit yang disimpan pengguna.
// Menerapkan MVVM: View hanya membaca FavoritesViewModel & WeatherViewModel.
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
        title: const Text('Lokasi Favorit'),
      ),
      body: Consumer<FavoritesViewModel>(
        builder: (context, vm, child) {
          final favorites = vm.favorites;

          if (favorites.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border_rounded, size: 64, color: colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(
                      'Belum Ada Lokasi Favorit',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tandai ikon hati pada layar Cuaca atau hasil Cari untuk menyimpan lokasi favorit Anda di sini.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: favorites.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final loc = favorites[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(Icons.location_city, color: colorScheme.onPrimaryContainer),
                  ),
                  title: Text(
                    loc.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    loc.fullDisplayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    tooltip: 'Hapus dari favorit',
                    onPressed: () => vm.removeFavorite(loc),
                  ),
                  onTap: () => _selectLocation(context, loc),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
