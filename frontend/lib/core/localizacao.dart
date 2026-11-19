import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

enum EstadoLocalizacao { desligada, pedindo, ativa, negada, bloqueada, gpsDesligado }

/// Localização em tempo real (GPS) para os mapas.
/// Pede a permissão na primeira vez e depois acompanha a pessoa enquanto
/// o app está aberto.
class Localizacao extends ChangeNotifier {
  LatLng? posicao;
  double? precisaoMetros;
  EstadoLocalizacao estado = EstadoLocalizacao.desligada;

  StreamSubscription<Position>? _sub;
  bool _iniciando = false;

  bool get ativa => posicao != null;

  String get mensagem => switch (estado) {
        EstadoLocalizacao.ativa => posicao == null ? 'Procurando sua localização…' : 'Usando sua localização',
        EstadoLocalizacao.pedindo => 'Aguardando permissão de localização…',
        EstadoLocalizacao.negada => 'Localização não permitida',
        EstadoLocalizacao.bloqueada => 'Localização bloqueada nas configurações',
        EstadoLocalizacao.gpsDesligado => 'GPS do celular desligado',
        EstadoLocalizacao.desligada => 'Localização desligada',
      };

  /// Liga o GPS (pede a permissão se precisar). Devolve true se ligou.
  Future<bool> iniciar() async {
    if (_sub != null) return true;
    if (_iniciando) return false;
    _iniciando = true;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _mudar(EstadoLocalizacao.gpsDesligado);
        return false;
      }
      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) {
        _mudar(EstadoLocalizacao.pedindo);
        p = await Geolocator.requestPermission();
      }
      if (p == LocationPermission.deniedForever) {
        _mudar(EstadoLocalizacao.bloqueada);
        return false;
      }
      if (p != LocationPermission.whileInUse && p != LocationPermission.always) {
        _mudar(EstadoLocalizacao.negada);
        return false;
      }
      _mudar(EstadoLocalizacao.ativa);
      // Posição rápida enquanto o GPS "esquenta"
      try {
        final ultima = await Geolocator.getLastKnownPosition();
        if (ultima != null) _atualizar(ultima);
      } catch (_) {}
      _sub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
      ).listen(_atualizar, onError: (_) {
        _sub?.cancel();
        _sub = null;
        _mudar(EstadoLocalizacao.negada);
      });
      return true;
    } catch (_) {
      _mudar(EstadoLocalizacao.negada);
      return false;
    } finally {
      _iniciando = false;
    }
  }

  /// Abre as configurações certas: do GPS (se desligado) ou do app (permissão).
  Future<void> abrirConfiguracoes() async {
    try {
      if (estado == EstadoLocalizacao.gpsDesligado) {
        await Geolocator.openLocationSettings();
      } else {
        await Geolocator.openAppSettings();
      }
    } catch (_) {}
  }

  void parar() {
    _sub?.cancel();
    _sub = null;
    posicao = null;
    _mudar(EstadoLocalizacao.desligada);
  }

  void _atualizar(Position p) {
    posicao = LatLng(p.latitude, p.longitude);
    precisaoMetros = p.accuracy;
    estado = EstadoLocalizacao.ativa;
    notifyListeners();
  }

  void _mudar(EstadoLocalizacao e) {
    estado = e;
    notifyListeners();
  }
}

final localizacao = Localizacao();
