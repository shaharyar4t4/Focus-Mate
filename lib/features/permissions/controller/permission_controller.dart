import 'package:flutter/material.dart';
import '../../../core/services/permission_service.dart';

class PermissionController extends ChangeNotifier {
  bool _usageAccess = false;
  bool _overlay = false;
  bool _notifications = false;
  bool _isChecking = false;

  bool get usageAccess => _usageAccess;
  bool get overlay => _overlay;
  bool get notifications => _notifications;
  bool get isChecking => _isChecking;

  bool get allGranted => _usageAccess && _overlay && _notifications;

  /// Re-reads the current state of every permission. Called on screen open and
  /// whenever the app returns to the foreground (the user grants Usage Access
  /// and Overlay from system settings, i.e. outside the app).
  Future<void> refresh() async {
    _isChecking = true;
    notifyListeners();

    _usageAccess = await PermissionService.hasUsageAccess();
    _overlay = await PermissionService.hasOverlayPermission();
    _notifications = await PermissionService.hasNotificationPermission();

    _isChecking = false;
    notifyListeners();
  }

  Future<void> requestUsageAccess() async {
    await PermissionService.openUsageAccessSettings();
    // State is re-checked via refresh() on app resume.
  }

  Future<void> requestOverlay() async {
    await PermissionService.requestOverlayPermission();
    await refresh();
  }

  Future<void> requestNotifications() async {
    await PermissionService.requestNotificationPermission();
    await refresh();
  }
}
