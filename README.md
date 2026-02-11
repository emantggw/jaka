# JAKA

`jaka` is a Dart CLI for generating Android `.jks` keystores using values from `android/key.properties`.

It supports:
- Interactive mode with prompts
- Flag-based mode for CI or repeatable scripts
- Custom output directory for the generated `.jks`

## Install

```bash
dart pub global activate jaka
```

If your global pub cache bin folder is not on `PATH`, add it:

- Windows: `%LOCALAPPDATA%\Pub\Cache\bin`
- macOS/Linux: `$HOME/.pub-cache/bin`

## Quick Start

1. Ensure your Android module has `key.properties`.
2. Run:

```bash
jaka create
```

3. Follow prompts.

## Expected `key.properties`

`jaka` requires these keys:

```properties
storePassword=yourStorePassword
keyPassword=yourKeyPassword
keyAlias=upload
storeFile=upload-keystore.jks
```

`storeFile` defines the generated filename.  
The output folder is chosen by prompt or `--output-path`.

## Usage

```bash
jaka <command> [options]
```

Commands:
- `create` Generate Android JKS keystore
- `help` Show help

Create options:
- `-a, --android-path` Path to Android directory that must contain `key.properties` (default: `android`)
- `-p, --output-path` Folder to store the generated `.jks` (default: value of `--android-path`, otherwise `android`)
- `-c, --country` Country code, for example `ET`
- `-o, --company` Organization/company name
- `--city` City/locality
- `--state` State/region
- `--org-unit` Organizational unit
- `--common-name` Certificate common name (default: `Android Release`)

## Examples

Interactive:

```bash
jaka create
```

Non-interactive:

```bash
jaka create ^
  --android-path android ^
  --output-path C:\keys ^
  --country ET ^
  --company "Acme Inc" ^
  --city "Addis Ababa" ^
  --state "Addis Ababa" ^
  --org-unit "Mobile" ^
  --common-name "Android Release"
```

## Notes

- Requires `keytool` (included with JDK).
- The command fails early if `key.properties` is missing from the selected Android path.

## Author

- `emantggw`
- Contact: https://t.me/emantggw

## License

This package is licensed under the MIT License. See `LICENSE`.
