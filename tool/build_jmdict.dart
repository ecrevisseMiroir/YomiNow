/// Builds `assets/dict/jmdict.db.gz`. Run from the repository root after
/// `flutter pub get`. On first use, `dart run` has sqlite3's build hook fetch
/// a prebuilt SQLite library (a GitHub release download, cached in
/// `.dart_tool`), so that run needs network access:
///
///     dart run tool/build_jmdict.dart --jmdict-xml JMdict_e.gz
///     dart run tool/build_jmdict.dart --jamdict-db jamdict.db --common-only
///
/// The uncompressed intermediate is kept in `tool/.cache/jmdict.db`. Next to
/// the `.gz` a one-line `.version` file (SHA-256 and length of the gzip) is
/// written; commit both, the app reads the small one to detect a new asset.
library;

import 'dart:io';

import 'package:path/path.dart' as p;

import 'src/jmdict_builder.dart';

const _usage = '''
Usage: dart run tool/build_jmdict.dart (--jmdict-xml <file> | --jamdict-db <file>) [options]

  --jmdict-xml <file>   Official JMdict_e (plain or .gz) from
                        https://www.edrdg.org/pub/Nihongo/JMdict_e.gz
  --jamdict-db <file>   jamdict-data SQLite database (jamdict.db)
  --out <file>          Output (default: assets/dict/jmdict.db.gz)
  --common-only         Keep only entries with a common form (smaller)
''';

Future<void> main(List<String> args) async {
  String? xmlPath;
  String? jamdictPath;
  var out = 'assets/dict/jmdict.db.gz';
  var commonOnly = false;

  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--jmdict-xml':
        xmlPath = _valueOf(args, ++i);
      case '--jamdict-db':
        jamdictPath = _valueOf(args, ++i);
      case '--out':
        out = _valueOf(args, ++i);
      case '--common-only':
        commonOnly = true;
      case '-h' || '--help':
        stdout.write(_usage);
        return;
      default:
        _fail('Unknown argument: ${args[i]}');
    }
  }
  if ((xmlPath == null) == (jamdictPath == null)) {
    _fail('Pass exactly one of --jmdict-xml and --jamdict-db.');
  }

  final dbPath = p.join(
    p.dirname(Platform.script.toFilePath()),
    '.cache',
    'jmdict.db',
  );
  final stats = xmlPath != null
      ? await buildFromJmdictXml(
          xmlPath,
          dbPath: dbPath,
          gzPath: out,
          commonOnly: commonOnly,
        )
      : await buildFromJamdict(
          jamdictPath!,
          dbPath: dbPath,
          gzPath: out,
          commonOnly: commonOnly,
        );

  stdout
    ..writeln('Entries: ${stats.entries}')
    ..writeln('Terms:   ${stats.terms}')
    ..writeln('Raw db:  ${_megabytes(stats.dbBytes)} ($dbPath)')
    ..writeln('Gzipped: ${_megabytes(stats.gzBytes)} ($out)')
    ..writeln('Version: ${stats.fingerprint} (${versionPathFor(out)})');
}

String _valueOf(List<String> args, int index) => index < args.length
    ? args[index]
    : _fail('${args[index - 1]} needs a value.');

String _megabytes(int bytes) =>
    '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';

Never _fail(String message) {
  stderr
    ..writeln(message)
    ..write(_usage);
  exit(64);
}
