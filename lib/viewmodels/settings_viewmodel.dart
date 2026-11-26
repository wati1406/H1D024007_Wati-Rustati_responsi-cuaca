import 'package:flutter/material.dart';
import 'package:responsi_cuaca/services/storage_service.dart';

class SettingsViewModel extends ChangeNotifier {
  final StorageService _storageService;

  SettingsViewModel({required StorageService storageService})
      : _storageService = storageService {
    _loadSettings();
  }

  String _temperatureUnit = 'celsius';
  ThemeMode _themeMode = ThemeMode.system;

  String get temperatureUnit => _temperatureUnit;
  ThemeMode get themeMode => _themeMode;

  void _loadSettings() {
    _temperatureUnit = _storageService.getTemperatureUnit();
    final modeStr = _storageService.getThemeMode();
    if (modeStr == 'light') {
      _themeMode = ThemeMode.light;
    } else if (modeStr == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setTemperatureUnit(String unit) async {
    if (_temperatureUnit == unit) return;
    _temperatureUnit = unit;
    await _storageService.saveTemperatureUnit(unit);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    String modeStr = 'system';
    if (mode == ThemeMode.light) modeStr = 'light';
    if (mode == ThemeMode.dark) modeStr = 'dark';
    await _storageService.saveThemeMode(modeStr);
    notifyListeners();
  }
}
