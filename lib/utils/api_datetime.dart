final _explicitTimezonePattern = RegExp(r'(Z|[+\-]\d{2}:\d{2})$');

bool apiTimestampHasExplicitTimezone(String value) =>
    _explicitTimezonePattern.hasMatch(value.trim());

/// Parses timestamps from Wildlife backend JSON (alarms, detections, interactions).
/// Returns null when the value is missing or not a real date/time.
DateTime? tryParseBackendTimestampToUtc(String? raw) {
  final value = (raw ?? '').trim();
  if (value.isEmpty) return null;
  if (value.startsWith('{') || value.startsWith('Instance of')) return null;

  try {
    DateTime? parsed;

    if (RegExp(r'^\d{10,}$').hasMatch(value)) {
      final digits = int.tryParse(value);
      if (digits == null || digits < 1000000000) return null;
      final ms = digits > 9999999999 ? digits : digits * 1000;
      parsed = DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
    } else if (apiTimestampHasExplicitTimezone(value)) {
      parsed = DateTime.parse(value).toUtc();
    } else if (RegExp(r'\d{4}').hasMatch(value)) {
      parsed = _parseLooseIsoDateTime(value);
    }

    if (parsed == null || parsed.year < 1970) return null;
    return parsed;
  } catch (_) {
    return null;
  }
}

DateTime? _parseLooseIsoDateTime(String value) {
  var normalized = value.trim();

  // e.g. 2024-06-01 14:30:00 (space between date and time)
  if (normalized.contains(' ') && !normalized.contains('T')) {
    normalized = normalized.replaceFirst(' ', 'T');
  } else if (!normalized.contains('T') &&
      RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(normalized)) {
    normalized = '${normalized}T00:00:00';
  }

  if (!apiTimestampHasExplicitTimezone(normalized)) {
    normalized = '${normalized}Z';
  }
  return DateTime.parse(normalized).toUtc();
}

/// Parses timestamps from Wildlife backend JSON; falls back to now if invalid.
DateTime parseBackendTimestampToUtc(String? raw) {
  return tryParseBackendTimestampToUtc(raw) ?? DateTime.now().toUtc();
}

/// Parses API / user moment strings for internal storage (UTC).
DateTime parseApiMomentToUtc(String? raw) {
  final value = (raw ?? '').trim();
  if (value.isEmpty) return DateTime.now().toUtc();

  final parsed = DateTime.tryParse(value);
  if (parsed == null) return DateTime.now().toUtc();

  if (!apiTimestampHasExplicitTimezone(value)) {
    // Naive ISO string: treat as local wall-clock (user input in forms).
    return parsed.toUtc();
  }

  return parsed.isUtc ? parsed : parsed.toUtc();
}

/// Wall-clock date/time in the device timezone for UI labels.
DateTime toLocalWallClock(DateTime dateTime) => dateTime.toLocal();

String formatLocalDate(DateTime? dateTime) {
  if (dateTime == null) return '--';
  final local = toLocalWallClock(dateTime);
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  return '$day-$month-${local.year}';
}

String formatLocalTime(DateTime? dateTime) {
  if (dateTime == null) return '--';
  final local = toLocalWallClock(dateTime);
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
