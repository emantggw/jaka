import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as p;

const _ansiReset = '\x1B[0m';
const _ansiRed = '\x1B[31m';
const _ansiGreen = '\x1B[32m';
const _ansiCyan = '\x1B[36m';
const _ansiYellow = '\x1B[33m';

String _color(String text, String code) => '$code$text$_ansiReset';

void runCreate(List<String> arguments) {
  final parser = ArgParser()
    ..addOption('android-path', abbr: 'a')
    ..addOption('output-path', abbr: 'p')
    ..addOption('country', abbr: 'c')
    ..addOption('company', abbr: 'o')
    ..addOption('city')
    ..addOption('state', defaultsTo: '')
    ..addOption('org-unit', defaultsTo: '')
    ..addOption('common-name', defaultsTo: 'Android Release');

  final args = parser.parse(arguments);

  String ask(String label, {String? defaultValue}) {
    stdout.write(
      '${_color(label, _ansiYellow)}${defaultValue != null ? ' [$defaultValue]' : ''}: ',
    );
    final input = stdin.readLineSync();
    return (input == null || input.trim().isEmpty)
        ? (defaultValue ?? '')
        : input.trim();
  }

  String androidPath =
      args['android-path'] ??
          ask(
            'Android path (must contain key.properties)',
            defaultValue: 'android',
          );

  void fail(String msg) {
    stderr.writeln('${_color('[ERROR]', _ansiRed)} $msg');
    exit(1);
  }

  final androidDir = Directory(androidPath);
  if (!androidDir.existsSync()) {
    fail('Android directory not found: $androidPath');
  }

  final keyPropsPath = p.join(androidDir.path, 'key.properties');
  final keyProps = File(keyPropsPath);
  if (!keyProps.existsSync()) {
    fail('key.properties not found. Expected at: $keyPropsPath');
  }

  String outputPath = args['output-path'] ??
      ask('Where to store generated JKS', defaultValue: androidPath);
  String country = args['country'] ?? ask('Country code (e.g. ET)');
  String company = args['company'] ?? ask('Company / Organization');
  String city = args['city'] ?? ask('City / Locality');
  String state = args['state'] ?? ask('State / Region');
  String orgUnit = args['org-unit'] ?? ask('Org Unit (OU)');
  String commonName = args['common-name'] ??
      ask('Common Name (CN)', defaultValue: 'Android Release');

  final props = <String, String>{};
  for (final line in keyProps.readAsLinesSync()) {
    if (line.trim().isEmpty || line.startsWith('#')) continue;
    final parts = line.split('=');
    if (parts.length == 2) {
      props[parts[0].trim()] = parts[1].trim();
    }
  }

  for (final k in ['storePassword', 'keyPassword', 'keyAlias', 'storeFile']) {
    if (!props.containsKey(k)) {
      fail('Missing $k in key.properties');
    }
  }

  final outputDir = Directory(outputPath);
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  final storeFileName = p.basename(props['storeFile']!);
  final keystorePath = p.join(outputDir.path, storeFileName);

  final dname =
      'CN=$commonName, OU=$orgUnit, O=$company, L=$city, S=$state, C=$country';

  print('');
  print('${_color('[INFO]', _ansiCyan)} Generating Android keystore');
  print('${_color('Android dir:', _ansiYellow)} ${androidDir.path}');
  print('${_color('JKS dir:', _ansiYellow)} ${outputDir.path}');
  print('${_color('Alias:', _ansiYellow)} ${props['keyAlias']}');
  print('${_color('Output:', _ansiYellow)} $keystorePath');
  print('${_color('DName:', _ansiYellow)} $dname');
  print('');

  final result = Process.runSync(
    'keytool',
    [
      '-genkeypair',
      '-v',
      '-keystore',
      keystorePath,
      '-storetype',
      'JKS',
      '-keyalg',
      'RSA',
      '-keysize',
      '2048',
      '-validity',
      '10000',
      '-alias',
      props['keyAlias']!,
      '-storepass',
      props['storePassword']!,
      '-keypass',
      props['keyPassword']!,
      '-dname',
      dname,
    ],
    runInShell: true,
  );

  stdout.write(result.stdout);
  stderr.write(result.stderr);

  if (result.exitCode != 0) {
    fail('Keystore generation failed');
  }

  print('\n${_color('[OK]', _ansiGreen)} Keystore generated successfully');
}
