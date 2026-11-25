import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:responsi_cuaca/models/location.dart';
import 'package:responsi_cuaca/models/weather.dart';

// Service untuk menangani semua panggilan HTTP GET ke Open-Meteo REST API.
// Memisahkan logika jaringan dari UI/ViewModel sesuai prinsip MVVM.
class WeatherService {
  static const String _geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const String _forecastBaseUrl =
      'https://api.open-meteo.com/v1/forecast';

  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  // 1. HTTP GET Geocoding API: Mencari kota berdasarkan nama query
  // URL: https://geocoding-api.open-meteo.com/v1/search?name=...&count=10&language=id
  Future<List<LocationModel>> searchLocations(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return [];
    }

    final uri = Uri.parse(
      '$_geocodingBaseUrl?name=${Uri.encodeComponent(cleanQuery)}&count=10&language=id',
    );

    try {
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('results') && data['results'] is List) {
          final results = data['results'] as List;
          return results
              .map(
                (item) =>
                    LocationModel.fromOpenMeteoJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        // Jika data['results'] tidak ada, berarti kota tidak ditemukan (data kosong)
        return [];
      } else {
        throw HttpException(
          'Gagal mencari lokasi. Status code: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw const SocketException(
        'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.',
      );
    } catch (e) {
      if (e is SocketException || e is HttpException) rethrow;
      throw Exception('Terjadi kesalahan saat memuat data pencarian: $e');
    }
  }

  // 2. HTTP GET Forecast API: Mengambil data cuaca berdasarkan koordinat
  // Parameter sesuai PDF: latitude, longitude, current, daily, timezone=auto
  Future<WeatherModel> fetchWeather({
    required double latitude,
    required double longitude,
    String temperatureUnit = 'celsius',
  }) async {
    final queryParams = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
      'timezone': 'auto',
    };

    if (temperatureUnit == 'fahrenheit') {
      queryParams['temperature_unit'] = 'fahrenheit';
    }

    final uri = Uri.parse(_forecastBaseUrl).replace(
      queryParameters: queryParams,
    );

    try {
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        throw HttpException(
          'Gagal mengambil data cuaca. Status code: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw const SocketException(
        'Tidak dapat terhubung ke server Open-Meteo. Pastikan internet Anda aktif.',
      );
    } catch (e) {
      if (e is SocketException || e is HttpException) rethrow;
      throw Exception('Terjadi kesalahan saat memuat data cuaca: $e');
    }
  }
}
