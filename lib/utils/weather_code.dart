import 'package:flutter/material.dart';

// Helper utilitas untuk memetakan WMO Weather Code dari Open-Meteo
// ke dalam deskripsi Bahasa Indonesia dan IconData Material.
class WeatherCodeHelper {
  static String getDescription(int code) {
    switch (code) {
      case 0:
        return 'Cerah';
      case 1:
        return 'Sebagian Besar Cerah';
      case 2:
        return 'Sebagian Berawan';
      case 3:
        return 'Berawan Tebal';
      case 45:
        return 'Berkabut';
      case 48:
        return 'Kabut Rime Mengendap';
      case 51:
        return 'Gerimis Ringan';
      case 53:
        return 'Gerimis Sedang';
      case 55:
        return 'Gerimis Lebat';
      case 56:
      case 57:
        return 'Gerimis Membeku';
      case 61:
        return 'Hujan Ringan';
      case 63:
        return 'Hujan Sedang';
      case 65:
        return 'Hujan Lebat';
      case 66:
      case 67:
        return 'Hujan Membeku';
      case 71:
        return 'Hujan Salju Ringan';
      case 73:
        return 'Hujan Salju Sedang';
      case 75:
        return 'Hujan Salju Lebat';
      case 77:
        return 'Butiran Salju';
      case 80:
        return 'Hujan Lokal Ringan';
      case 81:
        return 'Hujan Lokal Sedang';
      case 82:
        return 'Hujan Lokal Lebat';
      case 85:
      case 86:
        return 'Hujan Salju Lebat Sesaat';
      case 95:
        return 'Badai Petir';
      case 96:
      case 99:
        return 'Badai Petir Disertai Es';
      default:
        return 'Cuaca Tidak Diketahui';
    }
  }

  static IconData getIcon(int code) {
    switch (code) {
      case 0:
        return Icons.wb_sunny_rounded;
      case 1:
      case 2:
        return Icons.wb_cloudy_rounded;
      case 3:
        return Icons.cloud_rounded;
      case 45:
      case 48:
        return Icons.foggy;
      case 51:
      case 53:
      case 55:
        return Icons.grain_rounded;
      case 56:
      case 57:
        return Icons.ac_unit_rounded;
      case 61:
      case 63:
      case 65:
        return Icons.water_drop_rounded;
      case 66:
      case 67:
        return Icons.severe_cold_rounded;
      case 71:
      case 73:
      case 75:
      case 77:
        return Icons.ac_unit_rounded;
      case 80:
      case 81:
      case 82:
        return Icons.umbrella_rounded;
      case 85:
      case 86:
        return Icons.snowing;
      case 95:
      case 96:
      case 99:
        return Icons.thunderstorm_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  // Format hari dari string ISO date (YYYY-MM-DD) ke nama hari dalam Bahasa Indonesia
  static String formatDayName(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final days = [
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu',
      ];
      final dayName = days[date.weekday - 1];
      return '$dayName, ${date.day}/${date.month}';
    } catch (_) {
      return isoDate;
    }
  }
}
