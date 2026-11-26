import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:responsi_cuaca/models/location.dart';
import 'package:responsi_cuaca/models/weather.dart';

class WeatherService {
  static const String _geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const String _forecastBaseUrl =
      'https://api.open-meteo.com/v1/forecast';

  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

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
        return [];
      } else {
        throw HttpException(
          'Gagal mencari lokasi. Status code: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw const SocketException('Tidak dapat terhubung ke server.');
    } catch (e) {
      if (e is SocketException || e is HttpException) rethrow;
      throw Exception('Terjadi kesalahan saat mencari kota: $e');
    }
  }

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
      'temperature_unit': temperatureUnit,
    };

    final uri = Uri.parse(_forecastBaseUrl).replace(queryParameters: queryParams);

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
        'Tidak ada koneksi internet. Periksa koneksi Anda.',
      );
    } catch (e) {
      if (e is SocketException || e is HttpException) rethrow;
      throw Exception('Gagal memproses data cuaca: $e');
    }
  }
}
