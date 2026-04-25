// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final dir = Directory('c:/src/flutter-apps/skillora/lib/screens/study');
  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    bool modified = false;

    if (content.contains(': [')) {
      content = content.replaceAll(': [', ': [');
      modified = true;
    }

    if (modified) {
      file.writeAsStringSync(content);
      print('Fixed syntax in ${file.path}');
    }
  }
}

