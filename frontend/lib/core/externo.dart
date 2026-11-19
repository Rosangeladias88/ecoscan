import 'package:url_launcher/url_launcher.dart';

/// Abre a rota no Google Maps (ou no app de mapas do celular).
Future<bool> abrirRota(double lat, double lng) =>
    _abrir(Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng'));

/// Abre o discador com o número já preenchido.
Future<bool> ligarPara(String telefone) =>
    _abrir(Uri(scheme: 'tel', path: telefone.replaceAll(RegExp(r'[^0-9+]'), '')));

Future<bool> _abrir(Uri u) async {
  try {
    return await launchUrl(u, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
