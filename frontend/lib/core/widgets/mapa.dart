import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../localizacao.dart';
import '../theme.dart';
import 'sheets.dart';

/// Centro padrão dos mapas: Nazaré, Belém (PA).
const belemNazare = LatLng(-1.4521, -48.4800);

/// Mapa do EcoScan (OpenStreetMap — gratuito, sem chave de API).
/// Precisa de internet para carregar os mapas.
class EcoMapa extends StatelessWidget {
  const EcoMapa({
    super.key,
    required this.marcadores,
    this.centro = belemNazare,
    this.zoom = 13.5,
    this.interativo = true,
    this.controller,
    this.onTapMapa,
    this.onPronto,
    this.mostrarVoce = true,
  });

  final List<Marker> marcadores;
  final LatLng centro;
  final double zoom;
  final bool interativo;
  final MapController? controller;
  final VoidCallback? onTapMapa;

  /// Chamado quando o mapa terminou de abrir (só então dá para mover a câmera).
  final VoidCallback? onPronto;

  /// Mostra o ponto azul da localização em tempo real (se estiver ligada).
  final bool mostrarVoce;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: centro,
        initialZoom: zoom,
        minZoom: 10,
        maxZoom: 18,
        backgroundColor: AppColors.subtle,
        interactionOptions: InteractionOptions(
          flags: interativo ? InteractiveFlag.all & ~InteractiveFlag.rotate : InteractiveFlag.none,
        ),
        onTap: onTapMapa == null ? null : (_, __) => onTapMapa!(),
        onMapReady: onPronto,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'br.unama.ecoscan',
        ),
        MarkerLayer(markers: marcadores),
        // Ponto azul "você está aqui", atualizado em tempo real
        if (mostrarVoce)
          ListenableBuilder(
            listenable: localizacao,
            builder: (context, _) {
              final p = localizacao.posicao;
              if (p == null) return const SizedBox.shrink();
              return MarkerLayer(markers: [marcadorVoce(p)]);
            },
          ),
        const SimpleAttributionWidget(source: Text('OpenStreetMap')),
      ],
    );
  }
}

/// Ponto azul pulsante da localização atual.
Marker marcadorVoce(LatLng p) => Marker(
      point: p,
      width: 44,
      height: 44,
      child: const _PontoAzul(),
    );

class _PontoAzul extends StatefulWidget {
  const _PontoAzul();
  @override
  State<_PontoAzul> createState() => _PontoAzulState();
}

class _PontoAzulState extends State<_PontoAzul> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Stack(alignment: Alignment.center, children: [
          Container(
            width: 18 + 26 * _c.value,
            height: 18 + 26 * _c.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2F7DE1).withAlpha((90 * (1 - _c.value)).round()),
            ),
          ),
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFF2F7DE1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 6)],
            ),
          ),
        ]),
      );
}

/// Botão redondo "minha localização" para colocar sobre os mapas.
/// Liga o GPS se precisar e centraliza o mapa em você.
class BotaoMinhaLocalizacao extends StatelessWidget {
  const BotaoMinhaLocalizacao({super.key, required this.onCentralizar});
  final void Function(LatLng) onCentralizar;

  Future<void> _tocar(BuildContext context) async {
    final p = localizacao.posicao;
    if (p != null) {
      onCentralizar(p);
      return;
    }
    final ok = await localizacao.iniciar();
    if (ok) {
      // espera a primeira posição chegar (até ~8 s)
      for (var i = 0; i < 16 && localizacao.posicao == null; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
      final p2 = localizacao.posicao;
      if (p2 != null) onCentralizar(p2);
      return;
    }
    if (!context.mounted) return;
    final abrir = await showConfirmSheet(
      context,
      title: localizacao.mensagem,
      subtitle: localizacao.estado == EstadoLocalizacao.gpsDesligado
          ? 'Ligue a localização do celular para ver onde você está no mapa.'
          : 'Para ver onde você está, permita o acesso à localização do EcoScan.',
      confirm: 'Abrir configurações',
      cancel: 'Agora não',
    );
    if (abrir) await localizacao.abrirConfiguracoes();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: localizacao,
        builder: (context, _) {
          final ligada = localizacao.posicao != null;
          return Material(
            color: AppColors.surface,
            shape: const CircleBorder(),
            elevation: 3,
            shadowColor: const Color(0x33000000),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => _tocar(context),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  ligada ? Icons.my_location_rounded : Icons.location_searching_rounded,
                  color: ligada ? const Color(0xFF2F7DE1) : AppColors.primary,
                ),
              ),
            ),
          );
        },
      );
}

/// Pino redondo com ícone, usado nos dois apps.
Marker ecoPin({
  required LatLng ponto,
  required IconData icon,
  Color cor = AppColors.primary,
  bool selecionado = false,
  VoidCallback? onTap,
}) {
  final s = selecionado ? 46.0 : 36.0;
  return Marker(
    point: ponto,
    width: s,
    height: s,
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: selecionado ? 3 : 2),
          boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: Icon(icon, color: Colors.white, size: s * 0.48),
      ),
    ),
  );
}

/// Distância em km entre dois pontos.
double distanciaKm(LatLng a, LatLng b) => const Distance().as(LengthUnit.Meter, a, b) / 1000;

/// "850 m" ou "1,4 km".
String formatarDistancia(double km) =>
    km < 1 ? '${(km * 1000).round()} m' : '${km.toStringAsFixed(1).replaceAll('.', ',')} km';
