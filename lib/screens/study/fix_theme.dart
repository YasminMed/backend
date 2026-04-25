// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final dir = Directory('c:/src/flutter-apps/skillora/lib/screens/study');
  final files = dir.listSync().whereType<File>().where(
    (f) => f.path.endsWith('.dart'),
  );

  final regexSurface = RegExp(
    r'\(?Theme\.of\(context\)\.brightness\s*==\s*Brightness\.dark\s*\?\s*const Color\(0xFF1E1E1E\)\s*:\s*Colors\.white\)?',
  );

  final regexText = RegExp(
    r'\(?Theme\.of\(context\)\.brightness\s*==\s*Brightness\.dark\s*\?\s*Colors\.white\s*:\s*Colors\.black87\)?',
  );

  final regexBg = RegExp(
    r'\(?Theme\.of\(context\)\.brightness\s*==\s*Brightness\.dark\s*\?\s*Colors\.black\s*:\s*Colors\.white\)?',
  );

  for (final file in files) {
    String content = file.readAsStringSync();

    content = content.replaceAll(
      regexSurface,
      'AppColors.getSurfaceColor(context)',
    );
    content = content.replaceAll(regexText, 'AppColors.getTextColor(context)');
    content = content.replaceAll(
      regexBg,
      'AppColors.getBackgroundColor(context)',
    );

    file.writeAsStringSync(content);
    print('Processed ${file.path}');
  }
}

