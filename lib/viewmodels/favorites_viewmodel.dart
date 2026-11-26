import 'package:flutter/foundation.dart';
import 'package:responsi_cuaca/models/location.dart';
import 'package:responsi_cuaca/services/storage_service.dart';

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

  void loadData() {
    _favorites = _storageService.getFavorites();
    _history = _storageService.getSearchHistory();
    notifyListeners();
  }

  Future<void> removeFavorite(LocationModel location) async {
    await _storageService.removeFavorite(location);
    loadData();
  }

  Future<void> clearHistory() async {
    await _storageService.clearSearchHistory();
    loadData();
  }
}
