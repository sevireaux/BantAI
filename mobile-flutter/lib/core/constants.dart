/// Centralized configuration. In a real deployment, override these via
/// --dart-define at build time rather than editing this file directly —
/// see the README's Flutter setup section.
class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api', // 10.0.2.2 = host machine, from the Android emulator
  );

  // Referenced only in this constants file and in AndroidManifest.xml's
  // placeholder — the real key lives in android/local.properties, which is
  // gitignored. See README "Google Maps setup".
  static const googleMapsApiKeyPlaceholder = 'YOUR_GOOGLE_MAPS_API_KEY';
}

class ReportStatus {
  static const pending = 'Pending';
  static const verified = 'Verified';
  static const inProgress = 'In Progress';
  static const resolved = 'Resolved';
  static const closed = 'Closed';
  static const rejected = 'Rejected';
  static const duplicate = 'Duplicate';
  static const cancelled = 'Cancelled';
}

class Severity {
  static const low = 'Low';
  static const moderate = 'Moderate';
  static const high = 'High';
  static const critical = 'Critical';
}

class AttentionReason {
  static const options = [
    'urgent',
    'significant',
    'recurring',
    'access-related',
    'safety-related',
    'long-pending',
  ];
}
