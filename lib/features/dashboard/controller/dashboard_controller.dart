import 'package:app_usage/app_usage.dart';
import 'package:flutter/foundation.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import '../model/app_limit_model.dart';
import '../data/dashboard_repo.dart';

class DashboardController extends ChangeNotifier {
  final DashboardRepository _repository = DashboardRepository();

  List<AppInfo> _installedApps = [];
  List<AppInfo> _filteredApps = [];
  List<AppLimit> _savedLimits = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<AppInfo> get installedApps => _filteredApps;
  List<AppLimit> get savedLimits => _savedLimits;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await fetchInstalledApps();
    await loadSavedLimits();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchInstalledApps() async {
    // using named parameters for version 2.0.1+
    _installedApps = await InstalledApps.getInstalledApps(
      withIcon: true,
      excludeSystemApps: false,
    );
    _filterApps();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _filterApps();
    notifyListeners();
  }

  void _filterApps() {
    if (_searchQuery.isEmpty) {
      _filteredApps = List.from(_installedApps);
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredApps = _installedApps
          .where(
            (app) =>
                app.name.toLowerCase().contains(query) ||
                app.packageName.toLowerCase().contains(query),
          )
          .toList();
    }
  }

  Future<void> loadSavedLimits() async {
    _savedLimits = await _repository.getLimits();
    await _refreshUsage();
    notifyListeners();
  }

  /// Fills each saved limit's [AppLimit.usageToday] with the real minutes used
  /// today, read from the system usage stats. Requires Usage Access; if it's
  /// missing the call returns empty/throws and usage stays at 0.
  Future<void> _refreshUsage() async {
    if (_savedLimits.isEmpty) return;
    try {
      final DateTime now = DateTime.now();
      final DateTime startOfDay = DateTime(now.year, now.month, now.day);
      final List<AppUsageInfo> infos = await AppUsage().getAppUsage(
        startOfDay,
        now,
      );

      final Map<String, int> usageByPackage = {
        for (final info in infos) info.packageName: info.usage.inMinutes,
      };

      _savedLimits = _savedLimits
          .map(
            (limit) => limit.copyWith(
              usageToday: usageByPackage[limit.packageName] ?? 0,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('[Dashboard] Error loading usage: $e');
    }
  }

  Future<void> addOrUpdateLimit(AppLimit limit) async {
    await _repository.saveLimit(limit);
    await loadSavedLimits();
  }

  Future<void> removeLimit(String packageName) async {
    await _repository.deleteLimit(packageName);
    await loadSavedLimits();
  }

  bool isLimitReached(String packageName) {
    final limit = _savedLimits.firstWhere(
      (element) => element.packageName == packageName,
      orElse: () =>
          AppLimit(packageName: '', appName: '', timeLimitInMinutes: -1),
    );

    if (limit.timeLimitInMinutes == -1) return false;
    return limit.usageToday >= limit.timeLimitInMinutes;
  }
}
