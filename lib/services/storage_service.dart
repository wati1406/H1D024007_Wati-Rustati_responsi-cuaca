import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:responsi_cuaca/models/location.dart';

// Service untuk menangani Local Storage via SharedPreferences.
// Memastikan data favorit, riwayat pencarian, dan preferensi tetap tersimpan
// saat aplikasi ditutup dan dibuka kembali.
class StorageService {
  static const String _keyFavorites = 'favorite_locations';
  static const String _keySearchHistory = 'search_history';
  static const String _keyLastLocation = 'last_selected_location';
  static const String _keyTemperatureUnit = 'temperature_unit';
  static const String _keyThemeMode = 'app_theme_mode';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // --- LOKASI FAVORIT ---
  List<LocationModel> getFavorites() {
    final List<String>? jsonList = _prefs.getStringList(_keyFavorites);
    if (jsonList == null || jsonList.isEmpty) return [];

    try {
      return jsonList
          .map((item) => LocationModel.fromJson(jsonDecode(item)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> addFavorite(LocationModel location) async {
    final favorites = getFavorites();
    if (!favorites.any((item) => item.latitude == location.latitude && item.longitude == location.longitude)) {
      favorites.add(location);
      final jsonList = favorites.map((item) => jsonEncode(item.toJson())).toList();
      return await _prefs.setStringList(_keyFavorites, jsonList);
    }
    return true;
  }

  Future<bool> removeFavorite(LocationModel location) async {
    final favorites = getFavorites();
    favorites.removeWhere((item) => item.latitude == location.latitude && item.longitude == location.longitude);
    final jsonList = favorites.map((item) => jsonEncode(item.toJson())).toList();
    return await _prefs.setStringList(_keyFavorites, jsonList);
  }

  bool isFavorite(LocationModel location) {
    final favorites = getFavorites();
    return favorites.any((item) => item.latitude == location.latitude && item.longitude == location.longitude);
  }

  // --- RIWAYAT PENCARIAN ---
  List<LocationModel> getSearchHistory() {
    final List<String>? jsonList = _prefs.getStringList(_keySearchHistory);
    if (jsonList == null || jsonList.isEmpty) return [];

    try {
      return jsonList
          .map((item) => LocationModel.fromJson(jsonDecode(item)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> addToSearchHistory(LocationModel location) async {
    final history = getSearchHistory();
    // Hapus duplikasi jika sudah pernah dicari
    history.removeWhere((item) => item.latitude == location.latitude && item.longitude == location.longitude);
    // Masukkan ke posisi paling awal (terbaru)
    history.insert(0, location);
    // Batasi maksimum 10 riwayat
    if (history.length > 10) {
      history.removeRange(10, history.length);
    }
    final jsonList = history.map((item) => jsonEncode(item.toJson())).toList();
    return await _prefs.setStringList(_keySearchHistory, jsonList);
  }

  Future<bool> clearSearchHistory() async {
    return await _prefs.remove(_keySearchHistory);
  }

  // --- LOKASI TERAKHIR DIPILIH ---
  LocationModel? getLastSelectedLocation() {
    final String? jsonStr = _prefs.getString(_keyLastLocation);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      return LocationModel.fromJson(jsonDecode(jsonStr));
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveLastSelectedLocation(LocationModel location) async {
    return await _prefs.setString(_keyLastLocation, jsonEncode(location.toJson()));
  }

  // --- PENGATURAN SUHU (°C / °F) ---
  String getTemperatureUnit() {
    return _prefs.getString(_keyTemperatureUnit) ?? 'celsius';
  }

  Future<bool> saveTemperatureUnit(String unit) async {
    return await _prefs.setString(_keyTemperatureUnit, unit);
  }

  // --- PENGATURAN TEMA (system / light / dark) ---
  String getThemeMode() {
    return _prefs.getString(_keyThemeMode) ?? 'system';
  }

  Future<bool> saveThemeMode(String mode) async {
    return await _prefs.setString(_keyThemeMode, mode);
  }
}
