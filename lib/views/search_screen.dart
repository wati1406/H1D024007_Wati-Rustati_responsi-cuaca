import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsi_cuaca/models/location.dart';
import 'package:responsi_cuaca/viewmodels/search_viewmodel.dart';
import 'package:responsi_cuaca/viewmodels/weather_viewmodel.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback onLocationChosen;

  const SearchScreen({super.key, required this.onLocationChosen});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSelect(LocationModel location) {
    final searchVm = context.read<SearchViewModel>();
    searchVm.onLocationSelected(location);

    final weatherVm = context.read<WeatherViewModel>();
    weatherVm.selectLocation(location);

    widget.onLocationChosen();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Kota'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Masukkan nama kota (contoh: Jakarta, Bandung)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<SearchViewModel>().searchLocations('');
                        },
                      )
                    : null,
              ),
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                setState(() {});
              },
              onSubmitted: (value) {
                context.read<SearchViewModel>().searchLocations(value);
              },
            ),
          ),
          Expanded(
            child: Consumer<SearchViewModel>(
              builder: (context, vm, child) {
                if (vm.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: colorScheme.primary),
                        const SizedBox(height: 16),
                        Text(
                          'Mencari lokasi dari Geocoding API...',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                if (vm.isError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off_rounded, size: 64, color: colorScheme.error),
                          const SizedBox(height: 16),
                          Text(
                            'Gagal Mencari Lokasi',
                            style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.error),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            vm.errorMessage ?? 'Gagal terhubung ke Geocoding API.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () => vm.retrySearch(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (vm.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_off_rounded, size: 64, color: colorScheme.outline),
                          const SizedBox(height: 16),
                          Text(
                            'Kota Tidak Ditemukan',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tidak ada hasil untuk kata kunci "${vm.currentQuery}". Coba periksa ejaan atau cari kota lain.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (vm.isLoaded && vm.searchResults.isNotEmpty) {
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: vm.searchResults.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final loc = vm.searchResults[index];
                      final isFav = vm.isFavorite(loc);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorScheme.primaryContainer,
                          child: Icon(Icons.location_city, color: colorScheme.onPrimaryContainer),
                        ),
                        title: Text(loc.name, style: theme.textTheme.titleMedium),
                        subtitle: Text(
                          [
                            if (loc.admin1 != null && loc.admin1 != loc.name) loc.admin1!,
                            if (loc.country != null) loc.country!,
                          ].join(', '),
                          style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.redAccent : null,
                          ),
                          tooltip: isFav ? 'Hapus dari favorit' : 'Tambah ke favorit',
                          onPressed: () => vm.toggleFavorite(loc),
                        ),
                        onTap: () => _onSelect(loc),
                      );
                    },
                  );
                }

                if (vm.searchHistory.isNotEmpty) {
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Riwayat Pencarian',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () => vm.clearHistory(),
                            child: const Text('Hapus Semua'),
                          ),
                        ],
                      ),
                      ...vm.searchHistory.map((loc) {
                        final isFav = vm.isFavorite(loc);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(Icons.history, color: colorScheme.primary),
                            title: Text(loc.name, style: theme.textTheme.titleMedium),
                            subtitle: Text(
                              loc.fullDisplayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.redAccent : null,
                              ),
                              onPressed: () => vm.toggleFavorite(loc),
                            ),
                            onTap: () => _onSelect(loc),
                          ),
                        );
                      }),
                    ],
                  );
                }

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_rounded, size: 64, color: colorScheme.outline),
                        const SizedBox(height: 16),
                        Text(
                          'Cari Kota Impian Anda',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ketik nama kota pada kolom di atas untuk melihat informasi cuaca lengkap dari Open-Meteo.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
