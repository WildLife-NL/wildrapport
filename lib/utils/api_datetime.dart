/// Parses API / user moment strings for internal storage (UTC).
DateTime parseApiMomentToUtc(String? raw) {
  final value = (raw ?? '').trim();
  if (value.isEmpty) return DateTime.now().toUtc();

  final parsed = DateTime.tryParse(value);
  if (parsed == null) return DateTime.now().toUtc();

  final hasExplicitTimezone =
      RegExp(r'(Z|[+\-]\d{2}:\d{2})$').hasMatch(value);
  if (!hasExplicitTimezone) {
    // Naive ISO string: treat as local wall-clock (user input / API without offset).
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
