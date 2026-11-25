import 'package:flutter/foundation.dart';
import 'package:responsi_cuaca/models/location.dart';
import 'package:responsi_cuaca/services/storage_service.dart';
import 'package:responsi_cuaca/services/weather_service.dart';

enum SearchState { initial, loading, loaded, empty, error }

// ViewModel untuk fitur pencarian lokasi kota.
// Mengatur state pencarian, pemanggilan Geocoding API via WeatherService,
// serta sinkronisasi riwayat dan favorit lewat StorageService.
class SearchViewModel extends ChangeNotifier {
  final WeatherService _weatherService;
  final StorageService _storageService;

  SearchViewModel({
    required WeatherService weatherService,
    required StorageService storageService,
  })  : _weatherService = weatherService,
        _storageService = storageService {
    loadSearchHistory();
  }

  SearchState _state = SearchState.initial;
  List<LocationModel> _searchResults = [];
  List<LocationModel> _searchHistory = [];
  String? _errorMessage;
  String _currentQuery = '';

  SearchState get state => _state;
  List<LocationModel> get searchResults => _searchResults;
  List<LocationModel> get searchHistory => _searchHistory;
  String? get errorMessage => _errorMessage;
  String get currentQuery => _currentQuery;

  bool get isLoading => _state == SearchState.loading;
  bool get isEmpty => _state == SearchState.empty;
  bool get isError => _state == SearchState.error;
  bool get isLoaded => _state == SearchState.loaded;

  // Memuat riwayat pencarian dari SharedPreferences
  void loadSearchHistory() {
    _searchHistory = _storageService.getSearchHistory();
    notifyListeners();
  }

  // Melakukan HTTP GET ke Open-Meteo Geocoding API
  Future<void> searchLocations(String query) async {
    final clean = query.trim();
    _currentQuery = clean;

    if (clean.isEmpty) {
      _searchResults = [];
      _state = SearchState.initial;
      notifyListeners();
      return;
    }

    _state = SearchState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _weatherService.searchLocations(clean);
      _searchResults = results;

      if (results.isEmpty) {
        _state = SearchState.empty; // Kondisi data kosong
      } else {
        _state = SearchState.loaded;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _state = SearchState.error; // Kondisi error
    } finally {
      notifyListeners();
    }
  }

  // Coba lagi pencarian terakhir saat kondisi error
  Future<void> retrySearch() async {
    if (_currentQuery.isNotEmpty) {
      await searchLocations(_currentQuery);
    }
  }

  // Cek apakah suatu lokasi sudah ada di favorit
  bool isFavorite(LocationModel location) {
    return _storageService.isFavorite(location);
  }

  // Toggle status favorit untuk lokasi tertentu
  Future<void> toggleFavorite(LocationModel location) async {
    if (isFavorite(location)) {
      await _storageService.removeFavorite(location);
    } else {
      await _storageService.addFavorite(location);
    }
    notifyListeners();
  }

  // Simpan ke riwayat dan local storage saat pengguna memilih kota
  Future<void> onLocationSelected(LocationModel location) async {
    await _storageService.addToSearchHistory(location);
    await _storageService.saveLastSelectedLocation(location);
    loadSearchHistory();
  }

  // Hapus seluruh riwayat pencarian
  Future<void> clearHistory() async {
    await _storageService.clearSearchHistory();
    loadSearchHistory();
  }
}
