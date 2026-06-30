import 'package:android_intent_plus/android_intent.dart';
import 'package:app_usage/app_usage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

/// Centralizes the runtime/special permissions that the core blocking feature
/// depends on. Without these granted, usage monitoring and the blocking overlay
/// silently do nothing, so the app must guide the user to grant them.
class PermissionService {
  /// Usage Access (PACKAGE_USAGE_STATS).
  ///
  /// `app_usage` exposes no direct permission check, so we probe it: when the
  /// permission is missing the platform returns an empty list (or throws). Over
  /// a full day a real device always has some usage, so a non-empty result is a
  /// reliable signal that access has been granted.
  static Future<bool> hasUsageAccess() async {
    try {
      final DateTime now = DateTime.now();
      final List<AppUsageInfo> infos = await AppUsage().getAppUsage(
        now.subtract(const Duration(days: 1)),
        now,
      );
      return infos.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Opens the system "Usage access" settings screen. The user must toggle the
  /// app on manually; there is no in-app grant dialog for this permission.
  static Future<void> openUsageAccessSettings() async {
    const intent = AndroidIntent(
      action: 'android.settings.USAGE_ACCESS_SETTINGS',
    );
    await intent.launch();
  }

  /// Display over other apps (SYSTEM_ALERT_WINDOW) — required to show the
  /// blocking overlay on top of the limited app.
  static Future<bool> hasOverlayPermission() =>
      FlutterOverlayWindow.isPermissionGranted();

  static Future<void> requestOverlayPermission() async {
    await FlutterOverlayWindow.requestPermission();
  }

  /// POST_NOTIFICATIONS (Android 13+). The foreground service notification is
  /// what keeps the monitoring service alive, so this should be granted too.
  /// On older Android versions notifications are enabled by default.
  static Future<bool> hasNotificationPermission() async {
    final impl = FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return (await impl?.areNotificationsEnabled()) ?? true;
  }

  static Future<void> requestNotificationPermission() async {
    final impl = FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await impl?.requestNotificationsPermission();
  }

  /// True only when every permission the blocking feature needs is granted.
  static Future<bool> allGranted() async {
    return await hasUsageAccess() &&
        await hasOverlayPermission() &&
        await hasNotificationPermission();
  }
}
