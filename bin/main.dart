import 'dart:io';
import 'create.dart';

const _ansiReset = '\x1B[0m';
const _ansiRed = '\x1B[31m';
const _ansiCyan = '\x1B[36m';
const _ansiYellow = '\x1B[33m';

String _color(String text, String code) => '$code$text$_ansiReset';

void main(List<String> args) {
  if (args.isEmpty) {
    showWelcome();
    exit(0);
  }

  switch (args.first) {
    case 'create':
      runCreate(args.skip(1).toList());
      break;

    case 'help':
    case '--help':
    case '-h':
      showWelcome();
      break;

    default:
      stderr.writeln(
        '${_color('[ERROR]', _ansiRed)} Unknown command: ${_color(args.first, _ansiYellow)}\n',
      );
      showWelcome();
      exit(1);
  }
}

void showWelcome() {
  print('');
  print(_color('JAKA - Android Keystore Generator', _ansiCyan));
  print('Secure. Simple. Developer-first.');
  print('');
  print(_color('USAGE:', _ansiYellow));
  print('  jaka <command> [options]');
  print('');
  print(_color('COMMANDS:', _ansiYellow));
  print('  create        Generate Android JKS keystore');
  print('  help          Show this help message');
  print('');
  print(_color('EXAMPLES:', _ansiYellow));
  print('  jaka create');
  print(
    '  jaka create --android-path projects\\example1\\android --country ET --company "Your Company" --city "Addis Ababa"',
  );
  print(
    '  jaka create --android-path android --output-path C:\\keys --country ET --company "Your Company"',
  );
  print('');
  print(_color('TIP:', _ansiYellow));
  print('  Run "jaka create" without options for interactive mode.');
  print('');
}
