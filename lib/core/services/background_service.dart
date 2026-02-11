import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
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
        onForeground: onStart,
      ),
    );
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    // Only available for flutter 3.0.0 and later
    DartPluginRegistrant.ensureInitialized();
    print('[BackgroundService] onStart called');

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
        print(
          '[BackgroundService] Checking usage for ${limit.packageName} (Limit: ${limit.timeLimitInMinutes}m)',
        );

        // Find usage for this app
        try {
          final usageInfo = infos.firstWhere(
            (info) => info.packageName == limit.packageName,
          );

          final int usageMinutes = usageInfo.usage.inMinutes;
          print(
            '[BackgroundService] Usage for ${limit.packageName}: $usageMinutes minutes',
          );

          if (usageMinutes >= limit.timeLimitInMinutes) {
            // Widen the check window to 5 minutes to catch lagging usage stats
            final DateTime checkWindowStart = now.subtract(
              const Duration(minutes: 5),
            );
            List<AppUsageInfo> recentInfos = await AppUsage().getAppUsage(
              checkWindowStart,
              now,
            );

            final isRecentlyUsed = recentInfos.any(
              (info) =>
                  info.packageName == limit.packageName &&
                  info.usage.inSeconds > 0, // Check for any usage in window
            );

            if (isRecentlyUsed) {
              print(
                '[BackgroundService] App ${limit.packageName} is legally active. Blocking...',
              );
              // Proactively minimize the app by going to Home
              // awaiting the intent launch might block the isolate slightly but it's okay for background service
              try {
                final intent = AndroidIntent(
                  action: 'android.intent.action.MAIN',
                  category: 'android.intent.category.HOME',
                  flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
                );
                await intent.launch();
                print('[BackgroundService] Home intent launched');
              } catch (e) {
                print("[BackgroundService] Error launching home intent: $e");
              }

              await _showOverlay(limit.appName);
            } else {
              print(
                '[BackgroundService] App ${limit.packageName} limit reached but not recently used (inactive).',
              );
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
    print('[BackgroundService] Attempting to show overlay for $appName');
    if (await FlutterOverlayWindow.isActive()) {
      print('[BackgroundService] Overlay already active');
      return;
    }

    bool permission = await FlutterOverlayWindow.isPermissionGranted();
    if (!permission) {
      print('[BackgroundService] Overlay permission NOT granted');
      return;
    }

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
