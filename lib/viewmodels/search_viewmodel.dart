import 'package:flutter/foundation.dart';
import 'package:responsi_cuaca/models/location.dart';
import 'package:responsi_cuaca/services/storage_service.dart';
import 'package:responsi_cuaca/services/weather_service.dart';

enum SearchState { initial, loading, loaded, empty, error }

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

  void loadSearchHistory() {
    _searchHistory = _storageService.getSearchHistory();
    notifyListeners();
  }

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
        _state = SearchState.empty;
      } else {
        _state = SearchState.loaded;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _state = SearchState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> retrySearch() async {
    if (_currentQuery.isNotEmpty) {
      await searchLocations(_currentQuery);
    }
  }

  bool isFavorite(LocationModel location) {
    return _storageService.isFavorite(location);
  }

  Future<void> toggleFavorite(LocationModel location) async {
    if (isFavorite(location)) {
      await _storageService.removeFavorite(location);
    } else {
      await _storageService.addFavorite(location);
    }
    notifyListeners();
  }

  Future<void> onLocationSelected(LocationModel location) async {
    await _storageService.addToSearchHistory(location);
    loadSearchHistory();
  }

  Future<void> clearHistory() async {
    await _storageService.clearSearchHistory();
    loadSearchHistory();
  }
}
