import 'package:shared_preferences/shared_preferences.dart';
import '../model/app_limit_model.dart';
import 'dart:convert';

class DashboardRepository {
  static const String _storageKey = 'app_limits';

  Future<void> saveLimit(AppLimit limit) async {
    final prefs = await SharedPreferences.getInstance();
    final List<AppLimit> currentLimits = await getLimits();

    // Check if exists, if so update, else add
    final index = currentLimits.indexWhere(
      (element) => element.packageName == limit.packageName,
    );
    if (index != -1) {
      currentLimits[index] = limit;
    } else {
      currentLimits.add(limit);
    }

    final String encoded = json.encode(
      currentLimits.map((e) => e.toMap()).toList(),
    );
    await prefs.setString(_storageKey, encoded);
  }

  Future<List<AppLimit>> getLimits() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_storageKey);
    if (encoded == null) return [];

    final List<dynamic> decoded = json.decode(encoded);
    return decoded.map((e) => AppLimit.fromMap(e)).toList();
  }

  Future<void> deleteLimit(String packageName) async {
    final prefs = await SharedPreferences.getInstance();
    final List<AppLimit> currentLimits = await getLimits();

    currentLimits.removeWhere((element) => element.packageName == packageName);

    final String encoded = json.encode(
      currentLimits.map((e) => e.toMap()).toList(),
    );
    await prefs.setString(_storageKey, encoded);
  }
}
