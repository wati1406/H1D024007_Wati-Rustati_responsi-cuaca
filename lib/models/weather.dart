class CurrentWeather {
  final double temperature2m;
  final int relativeHumidity2m;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed10m;
  final String time;

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
  final double tempMax;
  final double tempMin;
  final int precipitationProbabilityMax;

  DailyForecastItem({
    required this.date,
    required this.weatherCode,
    required this.tempMax,
    required this.tempMin,
    required this.precipitationProbabilityMax,
  });
}

class DailyForecast {
  final List<String> time;
  final List<int> weatherCode;
  final List<double> temperature2mMax;
  final List<double> temperature2mMin;
  final List<int> precipitationProbabilityMax;

  DailyForecast({
    required this.time,
    required this.weatherCode,
    required this.temperature2mMax,
    required this.temperature2mMin,
    required this.precipitationProbabilityMax,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
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

  List<DailyForecastItem> toForecastItems() {
    final List<DailyForecastItem> items = [];
    final count = time.length;
    for (int i = 0; i < count; i++) {
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
  final DailyForecast daily;

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
      timezone: json['timezone'] as String? ?? '',
      current: CurrentWeather.fromJson(
        json['current'] as Map<String, dynamic>? ?? {},
      ),
      daily: DailyForecast.fromJson(
        json['daily'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
