// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final dir = Directory('c:/src/flutter-apps/skillora/lib/screens/study');
  final files = dir.listSync().whereType<File>().where(
    (f) => f.path.endsWith('.dart'),
  );

  final regexSurfaceMixin = RegExp(
    r'colors:\s*\[\s*AppColors\.getSurfaceColor\(context\),\s*AppColors\.(limeGreen|softGreen|lime|grey|accent|primary)\.withOpacity\([0-9.]+\),?\s*\],?',
  );
  final regexSurfaceMixin2 = RegExp(
    r'colors:\s*\[\s*AppColors\.getSurfaceColor\(context\),\s*note\.categoryColor\(context\)\.withOpacity\([0-9.]+\),?\s*\],?',
  );
  final regexMainBg = RegExp(
    r'colors:\s*\[\s*AppColors\.limeGreen\.withOpacity\([0-9.]+\),\s*AppColors\.getSurfaceColor\(context\),\s*AppColors\.softGreen\.withOpacity\([0-9.]+\),?\s*\],?',
  );
  final regexMainBg2 = RegExp(
    r'colors:\s*\[\s*AppColors\.limeGreen\.withOpacity\([0-9.]+\),\s*AppColors\.getBackgroundColor\(context\),\s*AppColors\.softGreen\.withOpacity\([0-9.]+\),?\s*\],?',
  );

  for (final file in files) {
    String content = file.readAsStringSync();
    bool modified = false;

    String newContent = content.replaceAllMapped(regexSurfaceMixin, (match) {
      modified = true;
      final original = match.group(0)!;
      return 'colors: Theme.of(context).brightness == Brightness.dark ? [AppColors.getSurfaceColor(context), AppColors.getSurfaceColor(context)] : $original';
    });

    newContent = newContent.replaceAllMapped(regexSurfaceMixin2, (match) {
      modified = true;
      final original = match.group(0)!;
      return 'colors: Theme.of(context).brightness == Brightness.dark ? [AppColors.getSurfaceColor(context), AppColors.getSurfaceColor(context)] : $original';
    });

    newContent = newContent.replaceAllMapped(regexMainBg, (match) {
      modified = true;
      final original = match.group(0)!;
      return 'colors: Theme.of(context).brightness == Brightness.dark ? [AppColors.getBackgroundColor(context), AppColors.getBackgroundColor(context), AppColors.getBackgroundColor(context)] : $original';
    });

    newContent = newContent.replaceAllMapped(regexMainBg2, (match) {
      modified = true;
      final original = match.group(0)!;
      return 'colors: Theme.of(context).brightness == Brightness.dark ? [AppColors.getBackgroundColor(context), AppColors.getBackgroundColor(context), AppColors.getBackgroundColor(context)] : $original';
    });

    if (modified) {
      file.writeAsStringSync(newContent);
      print('Processed ${file.path}');
    }
  }
}

