import 'package:flutter/material.dart';
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
      _filteredApps = _installedApps
          .where(
            (app) =>
                (app.name ?? '').toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                (app.packageName ?? '').toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }
  }

  Future<void> loadSavedLimits() async {
    _savedLimits = await _repository.getLimits();
    notifyListeners();
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
