import 'dart:convert';

class AppLimit {
  final String packageName;
  final String appName;
  final int timeLimitInMinutes;
  final bool isBlocked;
  final int usageToday; // In minutes

  AppLimit({
    required this.packageName,
    required this.appName,
    required this.timeLimitInMinutes,
    this.isBlocked = false,
    this.usageToday = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'packageName': packageName,
      'appName': appName,
      'timeLimitInMinutes': timeLimitInMinutes,
      'isBlocked': isBlocked,
      'usageToday': usageToday,
    };
  }

  factory AppLimit.fromMap(Map<String, dynamic> map) {
    return AppLimit(
      packageName: map['packageName'] ?? '',
      appName: map['appName'] ?? '',
      timeLimitInMinutes: map['timeLimitInMinutes'] ?? 0,
      isBlocked: map['isBlocked'] ?? false,
      usageToday: map['usageToday'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory AppLimit.fromJson(String source) =>
      AppLimit.fromMap(json.decode(source));

  AppLimit copyWith({
    String? packageName,
    String? appName,
    int? timeLimitInMinutes,
    bool? isBlocked,
    int? usageToday,
  }) {
    return AppLimit(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      timeLimitInMinutes: timeLimitInMinutes ?? this.timeLimitInMinutes,
      isBlocked: isBlocked ?? this.isBlocked,
      usageToday: usageToday ?? this.usageToday,
    );
  }
}
