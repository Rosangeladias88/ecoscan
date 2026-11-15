// Ajusta o AndroidManifest.xml gerado pelo `flutter create`:
// - INTERNET (mapa e fontes; sem ela o APK de release fica sem mapa)
// - ACCESS_FINE/COARSE_LOCATION (localização em tempo real nos mapas)
// - CÂMERA (opcional, com --camera) e câmera não obrigatória para instalar
// - permite abrir o Google Maps ("Como chegar") e o discador ("Ligar")
// - nome do app na tela do celular
//
// Uso, na pasta do projeto:
//   dart run tool/preparar_android.dart . "EcoScan" --camera
import 'dart:io';

void main(List<String> args) {
  if (args.length < 2) {
    stderr.writeln('Uso: dart run tool/preparar_android.dart <pasta_do_app> "<Nome do app>" [--camera]');
    exit(64);
  }
  final pasta = args[0];
  final nome = args[1];
  final camera = args.contains('--camera');

  final f = File('$pasta/android/app/src/main/AndroidManifest.xml');
  if (!f.existsSync()) {
    stderr.writeln('Pasta android não encontrada em "$pasta". Rode antes, dentro da pasta do app:\n'
        '  flutter create . --project-name ecoscan --org br.unama.ecoscan --platforms android');
    exit(1);
  }
  var s = f.readAsStringSync();
  final feito = <String>[];

  String depoisDoManifest(String xml, String linhas) =>
      xml.replaceFirstMapped(RegExp(r'<manifest[^>]*>'), (m) => '${m[0]}\n$linhas');

  if (!s.contains('android.permission.INTERNET')) {
    s = depoisDoManifest(s, '    <uses-permission android:name="android.permission.INTERNET" />');
    feito.add('internet');
  }
  if (!s.contains('android.permission.ACCESS_FINE_LOCATION')) {
    s = depoisDoManifest(
        s,
        '    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />\n'
        '    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />');
    feito.add('localização');
  }
  if (camera && !s.contains('android.permission.CAMERA')) {
    s = depoisDoManifest(
        s,
        '    <uses-permission android:name="android.permission.CAMERA" />\n'
        '    <uses-feature android:name="android.hardware.camera" android:required="false" />');
    feito.add('câmera');
  }

  const intents = '        <intent>\n'
      '            <action android:name="android.intent.action.VIEW" />\n'
      '            <data android:scheme="https" />\n'
      '        </intent>\n'
      '        <intent>\n'
      '            <action android:name="android.intent.action.DIAL" />\n'
      '            <data android:scheme="tel" />\n'
      '        </intent>\n';
  if (!s.contains('android:scheme="tel"')) {
    if (s.contains('<queries>')) {
      s = s.replaceFirst('<queries>', '<queries>\n$intents');
    } else {
      s = s.replaceFirst('</manifest>', '    <queries>\n$intents    </queries>\n</manifest>');
    }
    feito.add('mapas e telefone');
  }

  final label = RegExp(r'android:label="[^"]*"');
  if (label.hasMatch(s) && !s.contains('android:label="$nome"')) {
    s = s.replaceFirst(label, 'android:label="$nome"');
    feito.add('nome "$nome"');
  }

  f.writeAsStringSync(s);
  stdout.writeln(feito.isEmpty ? 'AndroidManifest já estava pronto.' : 'AndroidManifest atualizado: ${feito.join(', ')}.');

  if (camera) _corrigirCameraX(pasta);
}

/// Correção do plugin da câmera (camera_android_camerax) com Gradle 9:
/// o camera-core 1.5.x declara `concurrent-futures` só em tempo de execução, e o
/// Gradle 9 deixa de vê-lo na compilação ("CallbackToFutureAdapter not found").
/// Adicionar a dependência explicitamente resolve. Não traz biblioteca nova.
void _corrigirCameraX(String pasta) {
  const marca = '// EcoScan: correção camera_android_camerax + Gradle 9';
  const bloco = '''

$marca
subprojects {
    if (name == "camera_android_camerax") {
        plugins.withId("com.android.library") {
            dependencies.add("implementation", "androidx.concurrent:concurrent-futures:1.2.0")
        }
    }
}
''';
  for (final nomeArq in ['build.gradle.kts', 'build.gradle']) {
    final g = File('$pasta/android/$nomeArq');
    if (!g.existsSync()) continue;
    final txt = g.readAsStringSync();
    if (txt.contains(marca)) {
      stdout.writeln('Correção da câmera já estava aplicada.');
      return;
    }
    // build.gradle (Groovy) aceita a mesma sintaxe deste bloco.
    g.writeAsStringSync(txt + bloco);
    stdout.writeln('Correção da câmera aplicada em android/$nomeArq.');
    return;
  }
}
