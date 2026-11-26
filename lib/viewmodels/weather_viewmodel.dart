import 'package:flutter/foundation.dart';
import 'package:responsi_cuaca/models/location.dart';
import 'package:responsi_cuaca/models/weather.dart';
import 'package:responsi_cuaca/services/storage_service.dart';
import 'package:responsi_cuaca/services/weather_service.dart';

enum WeatherState { initial, loading, loaded, empty, error }

class WeatherViewModel extends ChangeNotifier {
  final WeatherService _weatherService;
  final StorageService _storageService;

  WeatherViewModel({
    required WeatherService weatherService,
    required StorageService storageService,
  })  : _weatherService = weatherService,
        _storageService = storageService;

  WeatherState _state = WeatherState.initial;
  WeatherModel? _weather;
  LocationModel? _selectedLocation;
  String? _errorMessage;
  String _temperatureUnit = 'celsius';
  bool _isFavorite = false;

  WeatherState get state => _state;
  WeatherModel? get weather => _weather;
  LocationModel? get selectedLocation => _selectedLocation;
  String? get errorMessage => _errorMessage;
  String get temperatureUnit => _temperatureUnit;
  bool get isFavorite => _isFavorite;

  bool get isLoading => _state == WeatherState.loading;
  bool get isError => _state == WeatherState.error;
  bool get isEmpty => _state == WeatherState.empty;
  bool get isLoaded => _state == WeatherState.loaded;

  Future<void> initializeWeather({String? preferredUnit}) async {
    if (preferredUnit != null) {
      _temperatureUnit = preferredUnit;
    } else {
      _temperatureUnit = _storageService.getTemperatureUnit();
    }

    LocationModel? lastLocation = _storageService.getLastSelectedLocation();

    if (lastLocation == null) {
      final favorites = _storageService.getFavorites();
      if (favorites.isNotEmpty) {
        lastLocation = favorites.first;
      }
    }

    final initialLocation = lastLocation ??
        LocationModel(
          id: 1627896,
          name: 'Semarang',
          latitude: -6.9932,
          longitude: 110.4203,
          country: 'Indonesia',
          admin1: 'Jawa Tengah',
        );

    await selectLocation(initialLocation);
  }

  Future<void> selectLocation(LocationModel location) async {
    _selectedLocation = location;
    _checkFavoriteStatus();
    await _storageService.saveLastSelectedLocation(location);
    await _storageService.addToSearchHistory(location);
    await fetchWeather();
  }

  Future<void> fetchWeather() async {
    if (_selectedLocation == null) {
      _state = WeatherState.empty;
      notifyListeners();
      return;
    }

    _state = WeatherState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _weatherService.fetchWeather(
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        temperatureUnit: _temperatureUnit,
      );

      _weather = result;
      _state = WeatherState.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _state = WeatherState.error;
    } finally {
      _checkFavoriteStatus();
      notifyListeners();
    }
  }

  Future<void> setTemperatureUnit(String unit) async {
    if (_temperatureUnit == unit) return;
    _temperatureUnit = unit;
    await _storageService.saveTemperatureUnit(unit);
    if (_selectedLocation != null) {
      await fetchWeather();
    }
  }

  Future<void> toggleFavorite() async {
    if (_selectedLocation == null) return;

    if (_isFavorite) {
      await _storageService.removeFavorite(_selectedLocation!);
      _isFavorite = false;
    } else {
      await _storageService.addFavorite(_selectedLocation!);
      _isFavorite = true;
    }
    notifyListeners();
  }

  void _checkFavoriteStatus() {
    if (_selectedLocation != null) {
      _isFavorite = _storageService.isFavorite(_selectedLocation!);
    } else {
      _isFavorite = false;
    }
  }
}
