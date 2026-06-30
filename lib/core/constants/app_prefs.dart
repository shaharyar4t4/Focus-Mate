/// Shared SharedPreferences keys, kept in one place so producers and consumers
/// of a value can never drift apart on the string name.
class AppPrefs {
  /// Whether the user has finished the onboarding flow at least once.
  static const String onboardingDone = 'onboarding_done';
}
