import 'package:flutter/foundation.dart';
import 'package:responsi_cuaca/models/location.dart';
import 'package:responsi_cuaca/services/storage_service.dart';

// ViewModel untuk Layar Favorit dan Riwayat.
// Berfungsi mengelola daftar favorit dan riwayat pencarian secara terpusat dari Local Storage.
class FavoritesViewModel extends ChangeNotifier {
  final StorageService _storageService;

  FavoritesViewModel({required StorageService storageService})
      : _storageService = storageService {
    loadData();
  }

  List<LocationModel> _favorites = [];
  List<LocationModel> _history = [];

  List<LocationModel> get favorites => _favorites;
  List<LocationModel> get history => _history;

  // Memuat data favorit dan riwayat dari StorageService
  void loadData() {
    _favorites = _storageService.getFavorites();
    _history = _storageService.getSearchHistory();
    notifyListeners();
  }

  // Hapus satu lokasi dari daftar favorit
  Future<void> removeFavorite(LocationModel location) async {
    await _storageService.removeFavorite(location);
    loadData();
  }

  // Hapus semua riwayat pencarian
  Future<void> clearHistory() async {
    await _storageService.clearSearchHistory();
    loadData();
  }
}
