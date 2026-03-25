import 'dart:io';

void main() {
  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    print('Fout: pubspec.yaml niet gevonden. Run vanuit de projectroot.');
    exit(1);
  }

  final now = DateTime.now();
  final version = '${now.year % 100}.${_pad(now.month)}.${_pad(now.day)}+1';
  final content = pubspec.readAsStringSync();
  final versionRegex = RegExp(r'^version:\s*[\d.]+\+\d+\s*$', multiLine: true);

  if (!versionRegex.hasMatch(content)) {
    print('Fout: Geen version-regel gevonden in pubspec.yaml.');
    exit(1);
  }

  final newContent = content.replaceFirst(versionRegex, 'version: $version\n');
  pubspec.writeAsStringSync(newContent);
  print('Version bijgewerkt naar: $version');
}

String _pad(int n) => n.toString().padLeft(2, '0');
