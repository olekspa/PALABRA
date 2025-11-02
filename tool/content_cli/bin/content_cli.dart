import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:collection/collection.dart';
import 'package:palabra/data_core/data_core.dart';
import 'package:path/path.dart' as p;

const _allowedLevels = <String>{'a1', 'a2', 'b1', 'b2'};
final _familyPattern = RegExp(r'^[a-z0-9_]+$');

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show usage information.',
    );

  parser
      .addCommand('validate')
      .addOption(
        'source',
        abbr: 's',
        valueHelp: 'path',
        help: 'Directory containing leveled vocabulary JSON files.',
        defaultsTo: 'assets/vocabulary/spanish',
      );

  parser.addCommand('ingest')
    ..addOption(
      'source',
      abbr: 's',
      valueHelp: 'path',
      help: 'Directory containing leveled vocabulary JSON files.',
      defaultsTo: 'assets/vocabulary/spanish',
    )
    ..addOption(
      'db-dir',
      abbr: 'd',
      valueHelp: 'path',
      help: 'Directory where the Isar database should be stored.',
      defaultsTo: p.join('build', 'isar'),
    )
    ..addFlag(
      'reset',
      defaultsTo: true,
      help: 'Clear existing vocabulary entries before ingesting.',
    );

  try {
    final results = parser.parse(arguments);
    if (results['help'] as bool) {
      _printUsage(parser);
      return;
    }

    final command = results.command;
    switch (command?.name) {
      case 'validate':
        final source =
            command?['source'] as String? ?? 'assets/vocabulary/spanish';
        final report = await _validateVocabulary(source);
        _emitValidationReport(report);
        if (report.errors.isNotEmpty) {
          exitCode = 1;
        }
        return;
      case 'ingest':
        final source =
            command?['source'] as String? ?? 'assets/vocabulary/spanish';
        final dbDir = command?['db-dir'] as String? ?? p.join('build', 'isar');
        final reset = command?['reset'] as bool? ?? true;

        final report = await _validateVocabulary(source);
        _emitValidationReport(report);
        if (report.errors.isNotEmpty) {
          stderr.writeln(
            'Ingestion aborted due to ${report.errors.length} '
            'validation error(s).',
          );
          exitCode = 1;
          return;
        }
        await _ingestVocabulary(
          report.records,
          Directory(dbDir),
          resetCollection: reset,
        );
        return;
      default:
        _printUsage(parser);
    }
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    _printUsage(parser);
    exitCode = 64; // EX_USAGE
  }
}

void _printUsage(ArgParser parser) {
  stdout
    ..writeln('Palabra content tooling')
    ..writeln()
    ..writeln('Usage: dart run tool/content_cli/bin/content_cli.dart <command>')
    ..writeln()
    ..writeln('Commands:')
    ..writeln('  validate [-s path]   Validate vocabulary JSON files.')
    ..writeln(
      '  ingest   [-s path] [-d dbDir] [--reset/--no-reset] '
      'Import vocabulary into Isar.',
    )
    ..writeln()
    ..writeln(parser.usage);
}

Future<ValidationReport> _validateVocabulary(String rootPath) async {
  final directory = Directory(rootPath);
  if (!directory.existsSync()) {
    return ValidationReport(
      records: <VocabRecord>[],
      errors: <String>['Path not found: $rootPath'],
    );
  }

  final files = directory
      .listSync()
      .whereType<File>()
      .where((file) => file.path.toLowerCase().endsWith('.json'))
      .sorted((a, b) => a.path.compareTo(b.path))
      .toList();

  if (files.isEmpty) {
    return ValidationReport(
      records: <VocabRecord>[],
      errors: <String>['No JSON files found under $rootPath'],
    );
  }

  final seenIds = <String>{};
  final errors = <String>[];
  final records = <VocabRecord>[];

  for (final file in files) {
    final fileLevel = p.basenameWithoutExtension(file.path);
    if (!_allowedLevels.contains(fileLevel)) {
      errors.add(
        '${file.path}: filename level "$fileLevel" is not one of '
        '${_allowedLevels.join(', ')}.',
      );
      continue;
    }

    final contents = await file.readAsString();
    dynamic payload;
    try {
      payload = json.decode(contents);
    } on FormatException catch (error) {
      errors.add('${file.path}: invalid JSON (${error.message}).');
      continue;
    }

    if (payload is! List) {
      errors.add('${file.path}: top-level JSON must be an array.');
      continue;
    }

    for (final (index, raw) in payload.indexed) {
      if (raw is! Map<String, dynamic>) {
        errors.add('${file.path}#$index: entry must be an object.');
        continue;
      }

      final context = '${file.path}#$index';
      final id = (raw['id'] ?? '').toString().trim();
      final en = (raw['en'] ?? raw['english'] ?? '').toString().trim();
      final es = (raw['es'] ?? raw['spanish'] ?? '').toString().trim();
      final level = (raw['level'] ?? fileLevel).toString().trim();
      final family = (raw['family'] ?? '').toString().trim();
      final topic = (raw['topic'] ?? '').toString().trim();

      var entryValid = true;

      if (id.isEmpty) {
        errors.add('$context: missing id.');
        entryValid = false;
      } else if (!seenIds.add(id)) {
        errors.add('$context: duplicate id "$id".');
        entryValid = false;
      } else if (!_matchesLevelPattern(id, fileLevel)) {
        errors.add(
          '$context: id "$id" must start with "${fileLevel}_0001" style '
          'pattern.',
        );
        entryValid = false;
      }

      if (en.isEmpty) {
        errors.add('$context: missing English text.');
        entryValid = false;
      }

      if (es.isEmpty) {
        errors.add('$context: missing Spanish text.');
        entryValid = false;
      }

      if (!_allowedLevels.contains(level)) {
        errors.add('$context: invalid level "$level".');
        entryValid = false;
      } else if (level != fileLevel) {
        errors.add(
          '$context: level "$level" does not match filename level '
          '"$fileLevel".',
        );
        entryValid = false;
      }

      if (family.isEmpty) {
        errors.add('$context: missing family slug.');
        entryValid = false;
      } else if (!_familyPattern.hasMatch(family)) {
        errors.add(
          '$context: family "$family" must match '
          '${_familyPattern.pattern}.',
        );
        entryValid = false;
      }

      if (topic.isEmpty) {
        errors.add('$context: missing topic.');
        entryValid = false;
      }

      if (entryValid) {
        records.add(
          VocabRecord(
            id: id,
            en: en,
            es: es,
            level: level,
            family: family,
            topic: topic,
            sourceFile: file.path,
            index: index,
          ),
        );
      }
    }
  }

  return ValidationReport(records: records, errors: errors);
}

Future<void> _ingestVocabulary(
  List<VocabRecord> records,
  Directory directory, {
  required bool resetCollection,
}) async {
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  stdout.writeln('Opening Isar database at ${directory.path} ...');
  final database = await AppDatabase.open(directory);

  try {
    if (resetCollection) {
      stdout.writeln('Clearing existing vocabulary collection...');
      await database.isar.writeTxn(() async {
        await database.isar.vocabItems.clear();
      });
    }

    final items = records
        .map(
          (record) => VocabItem()
            ..itemId = record.id
            ..english = record.en
            ..spanish = record.es
            ..level = record.level
            ..family = record.family
            ..topic = record.topic,
        )
        .toList();

    stdout.writeln('Writing ${items.length} vocabulary entries...');
    await database.isar.writeTxn(() async {
      await database.isar.vocabItems.putAllByItemId(items);
    });

    final counts = records
        .groupListsBy((record) => record.level)
        .map((level, levelRecords) => MapEntry(level, levelRecords.length));
    stdout.writeln('Ingestion complete:');
    for (final entry in counts.entries.sortedBy((entry) => entry.key)) {
      stdout.writeln('  - ${entry.key}: ${entry.value}');
    }
  } finally {
    await database.close();
  }
}

void _emitValidationReport(ValidationReport report) {
  if (report.errors.isEmpty) {
    stdout.writeln(
      'Validation successful — ${report.records.length} entries across '
      '${report.levelCounts.length} level(s).',
    );
  } else {
    for (final message in report.errors) {
      stderr.writeln(message);
    }
    stderr.writeln(
      'Validation completed with ${report.errors.length} error(s).',
    );
  }

  if (report.records.isNotEmpty) {
    stdout.writeln('Record counts:');
    for (final entry in report.levelCounts.entries.sortedBy((e) => e.key)) {
      stdout.writeln('  - ${entry.key}: ${entry.value}');
    }
  }
}

bool _matchesLevelPattern(String id, String level) {
  final pattern = RegExp('^$level\\_[0-9]{4,}\$');
  return pattern.hasMatch(id);
}

class VocabRecord {
  VocabRecord({
    required this.id,
    required this.en,
    required this.es,
    required this.level,
    required this.family,
    required this.topic,
    required this.sourceFile,
    required this.index,
  });

  final String id;
  final String en;
  final String es;
  final String level;
  final String family;
  final String topic;
  final String sourceFile;
  final int index;
}

class ValidationReport {
  ValidationReport({required this.records, required this.errors});

  final List<VocabRecord> records;
  final List<String> errors;

  Map<String, int> get levelCounts => records
      .groupListsBy((record) => record.level)
      .map((level, levelRecords) => MapEntry(level, levelRecords.length));
}
