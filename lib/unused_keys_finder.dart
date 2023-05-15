import 'dart:convert';
import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';

void main() {
  final root = Directory.current.path;
  final rootPosix = root.replaceAll("\\", "/");

  print('Started');
  final stringKeys = getStringKeys(rootPosix);
  print('String keys: ${stringKeys.length}');
  final dartFiles = getDartFiles(rootPosix);
  print('Dart files: ${dartFiles.length}');
  final unusedStringKeys = findUnusedStringKeys(stringKeys, dartFiles);
  print('Translated keys: ${unusedStringKeys.length}');
  for (final stringKey in unusedStringKeys) {
    print(stringKey);
  }
}

Set<String> getStringKeys(String path) {
  final arbFilesGlob = Glob('$path/**.arb');

  final arbFiles = <String>[];
  for (final entity in arbFilesGlob.listSync(followLinks: false)) {
    arbFiles.add(entity.path);
  }

  final stringKeys = <String>{};
  for (final file in arbFiles) {
    final content = File(file).readAsStringSync();
    final map = jsonDecode(content) as Map<String, dynamic>;
    for (final entry in map.entries) {
      if (!entry.key.startsWith('@')) {
        stringKeys.add(entry.key);
      }
    }
  }

  return stringKeys;
}

List<String> getDartFiles(String path) {
  final dartFilesGlob = Glob('$path/lib/**.dart');
  final dartFilesExcludeGlob = Glob('$path/lib/generated/**.dart');

  final dartFilesExclude = <String>[];
  for (final entity in dartFilesExcludeGlob.listSync(followLinks: false)) {
    dartFilesExclude.add(entity.path);
  }

  final dartFiles = <String>[];
  for (final entity in dartFilesGlob.listSync(followLinks: false)) {
    if (!dartFilesExclude.contains(entity.path)) {
      dartFiles.add(entity.path);
    }
  }

  return dartFiles;
}

Set<String> findUnusedStringKeys(Set<String> stringKeys, List<String> files) {
  final unusedStringKeys = stringKeys.toSet();

  for (final file in files) {
    final content = File(file).readAsStringSync();
    if (file.contains('localization/')) {
      print('skipping localization file $file');
      continue;
    }
    for (final stringKey in stringKeys) {
      if (content.contains(stringKey)) {
        unusedStringKeys.remove(stringKey);
      }
    }
  }

  return unusedStringKeys;
}
