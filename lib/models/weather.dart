// Model representasi data cuaca Open-Meteo Forecast API
// Sesuai seluruh field yang disyaratkan oleh PDF responsi.

class CurrentWeather {
  final double temperature2m; // current.temperature_2m (Suhu saat ini)
  final int relativeHumidity2m; // current.relative_humidity_2m (Kelembapan)
  final double apparentTemperature; // current.apparent_temperature (Suhu yang dirasakan)
  final double precipitation; // current.precipitation (Curah hujan)
  final int weatherCode; // current.weather_code (Kode kondisi cuaca)
  final double windSpeed10m; // current.wind_speed_10m (Kecepatan angin)
  final String time; // Waktu data cuaca

  CurrentWeather({
    required this.temperature2m,
    required this.relativeHumidity2m,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed10m,
    required this.time,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature2m: (json['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      relativeHumidity2m: (json['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      apparentTemperature:
          (json['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed10m: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      time: json['time'] as String? ?? '',
    );
  }
}

class DailyForecastItem {
  final String date;
  final int weatherCode;
  final double tempMax; // daily.temperature_2m_max (Suhu maksimum harian)
  final double tempMin; // daily.temperature_2m_min (Suhu minimum harian)
  final int
  precipitationProbabilityMax; // daily.precipitation_probability_max (Peluang hujan maksimum)

  DailyForecastItem({
    required this.date,
    required this.weatherCode,
    required this.tempMax,
    required this.tempMin,
    required this.precipitationProbabilityMax,
  });
}

class DailyWeather {
  final List<String> time;
  final List<int> weatherCode;
  final List<double> temperature2mMax;
  final List<double> temperature2mMin;
  final List<int> precipitationProbabilityMax;

  DailyWeather({
    required this.time,
    required this.weatherCode,
    required this.temperature2mMax,
    required this.temperature2mMin,
    required this.precipitationProbabilityMax,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    return DailyWeather(
      time: List<String>.from(json['time'] ?? []),
      weatherCode: (json['weather_code'] as List? ?? [])
          .map((e) => (e as num).toInt())
          .toList(),
      temperature2mMax: (json['temperature_2m_max'] as List? ?? [])
          .map((e) => (e as num).toDouble())
          .toList(),
      temperature2mMin: (json['temperature_2m_min'] as List? ?? [])
          .map((e) => (e as num).toDouble())
          .toList(),
      precipitationProbabilityMax:
          (json['precipitation_probability_max'] as List? ?? [])
              .map((e) => (e as num).toInt())
              .toList(),
    );
  }

  // Helper untuk mengubah array paralel menjadi list item per hari yang mudah dipakai ListView
  List<DailyForecastItem> toForecastItems() {
    final items = <DailyForecastItem>[];
    for (int i = 0; i < time.length; i++) {
      items.add(
        DailyForecastItem(
          date: time[i],
          weatherCode: i < weatherCode.length ? weatherCode[i] : 0,
          tempMax: i < temperature2mMax.length ? temperature2mMax[i] : 0.0,
          tempMin: i < temperature2mMin.length ? temperature2mMin[i] : 0.0,
          precipitationProbabilityMax: i < precipitationProbabilityMax.length
              ? precipitationProbabilityMax[i]
              : 0,
        ),
      );
    }
    return items;
  }
}

class WeatherModel {
  final double latitude;
  final double longitude;
  final String timezone;
  final CurrentWeather current;
  final DailyWeather daily;

  WeatherModel({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.current,
    required this.daily,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      timezone: json['timezone'] as String? ?? 'auto',
      current: CurrentWeather.fromJson(
        json['current'] as Map<String, dynamic>? ?? {},
      ),
      daily: DailyWeather.fromJson(
        json['daily'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
