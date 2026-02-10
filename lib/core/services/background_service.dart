import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:app_usage/app_usage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    hide NotificationVisibility;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import '../../features/dashboard/model/app_limit_model.dart';

class AppBackgroundService {
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    /// OPTIONAL, using custom notification channel id
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'my_foreground', // id
      'MY FOREGROUND SERVICE', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.low, // importance must be at low or higher level
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: onStart,

        // auto start service
        autoStart: true,
        isForegroundMode: true,

        notificationChannelId: 'my_foreground',
        initialNotificationTitle: 'Focus Mate Service',
        initialNotificationContent: 'Monitoring app usage...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        // auto start service
        autoStart: true,
        // this will be executed when app is in foreground in separated isolate
        onForeground: onStart,
      ),
    );
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    // Only available for flutter 3.0.0 and later
    DartPluginRegistrant.ensureInitialized();

    // Check system alert window permission if possible or just request user to grant it from main.
    // FlutterOverlayWindow.isPermissionGranted()

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    // Bring to foreground
    Timer.periodic(const Duration(seconds: 15), (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          flutterLocalNotificationsPlugin.show(
            id: 888,
            title: 'Focus Mate Service',
            body: 'Monitoring app usage...',
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                'my_foreground',
                'MY FOREGROUND SERVICE',
                icon: 'ic_bg_service_small',
                ongoing: true,
              ),
            ),
          );
        }
      }

      await checkUsageAndBlock();
    });
  }

  static Future<void> checkUsageAndBlock() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? encoded = prefs.getString('app_limits');
      if (encoded == null) return;

      final List<dynamic> decoded = json.decode(encoded);
      final List<AppLimit> limits = decoded
          .map((e) => AppLimit.fromMap(e as Map<String, dynamic>))
          .toList();

      // Filter limits that have actual time set
      final activeLimits = limits
          .where((l) => l.timeLimitInMinutes > 0)
          .toList();
      if (activeLimits.isEmpty) return;

      final DateTime now = DateTime.now();
      final DateTime startOfDay = DateTime(now.year, now.month, now.day);
      final DateTime endOfDay = now;

      // Fetch usage for today
      // app_usage requires permission. If not granted, this might fail or return empty.
      // We assume permission is granted.
      List<AppUsageInfo> infos = [];
      try {
        infos = await AppUsage().getAppUsage(startOfDay, endOfDay);
      } catch (e) {
        // Permission might not be granted
        print('Error fetching app usage: $e');
        return;
      }

      for (final limit in activeLimits) {
        // Find usage for this app
        try {
          final usageInfo = infos.firstWhere(
            (info) => info.packageName == limit.packageName,
          );

          final int usageMinutes = usageInfo.usage.inMinutes;

          if (usageMinutes >= limit.timeLimitInMinutes) {
            final DateTime oneMinuteAgo = now.subtract(
              const Duration(minutes: 1),
            );
            List<AppUsageInfo> recentInfos = await AppUsage().getAppUsage(
              oneMinuteAgo,
              now,
            );

            final isRecentlyUsed = recentInfos.any(
              (info) =>
                  info.packageName == limit.packageName &&
                  info.usage.inSeconds > 0,
            );

            if (isRecentlyUsed) {
              await _showOverlay(limit.appName);
            }
          }
        } catch (e) {
          // App not found in usage stats (not used today)
          continue;
        }
      }
    } catch (e) {
      print('Error in usage check loop: $e');
    }
  }

  static Future<void> _showOverlay(String appName) async {
    if (await FlutterOverlayWindow.isActive()) return;

    await FlutterOverlayWindow.showOverlay(
      enableDrag: false,
      overlayTitle: "Time's Up!",
      overlayContent: 'Focus Mate Limit Reached',
      flag: OverlayFlag.defaultFlag,
      alignment: OverlayAlignment.center,
      visibility: NotificationVisibility.visibilityPublic,
      positionGravity: PositionGravity.auto,
      height: WindowSize.matchParent,
      width: WindowSize.matchParent,
    );
  }
}
