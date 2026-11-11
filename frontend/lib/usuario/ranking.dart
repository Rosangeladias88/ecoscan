import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ecoscan/core/core.dart';

import '../data/ranking.dart';
import '../state/app_state.dart';

/// Hall da Fama: quem mais descartou resíduos do jeito certo.
class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});
  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

const _ouro = Color(0xFFD4A72C);
const _prata = Color(0xFFA3ADA6);
const _bronze = Color(0xFFC07A3E);
Color corMedalha(int pos) => switch (pos) { 1 => _ouro, 2 => _prata, 3 => _bronze, _ => AppColors.line };

class Posicao {
  final int pos;
  final String nome, bairro, iniciais;
  final int descartes;
  final bool voce;
  final Uint8List? foto;
  const Posicao(this.pos, this.nome, this.bairro, this.iniciais, this.descartes, {this.voce = false, this.foto});
}

/// Monta o ranking do período com o usuário incluído.
List<Posicao> montarRanking(int periodo) {
  final lista = <(String, String, String, int, bool)>[
    for (final p in participantes) (p.nome, p.bairro, p.iniciais, p.descartes(periodo), false),
    (app.nome, app.bairro.split(',').first, app.iniciais, app.descartesNoPeriodo(periodo), true),
  ];
  // Mais descartes primeiro; no empate, o usuário fica na frente (incentivo).
  lista.sort((a, b) {
    final c = b.$4.compareTo(a.$4);
    if (c != 0) return c;
    return (b.$5 ? 1 : 0).compareTo(a.$5 ? 1 : 0);
  });
  return [
    for (var i = 0; i < lista.length; i++)
      Posicao(i + 1, lista[i].$1, lista[i].$2, lista[i].$3, lista[i].$4,
          voce: lista[i].$5, foto: lista[i].$5 ? app.fotoPerfil : null),
  ];
}

class _RankingScreenState extends State<RankingScreen> {
  int _periodo = 1; // Mês

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final r = montarRanking(_periodo);
        final eu = r.firstWhere((p) => p.voce);
        final top = r.take(3).toList();
        final resto = r.skip(3).toList();
        return SafeArea(
          bottom: false,
          child: ListView(padding: const EdgeInsets.fromLTRB(24, 16, 24, 24), children: [
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Hall da Fama', style: AppText.display),
                  const SizedBox(height: 4),
                  Text('Quem mais descartou do jeito certo', style: AppText.caption.copyWith(fontSize: 15)),
                ]),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: const Color(0x26D4A72C), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.emoji_events_rounded, color: _ouro, size: 26),
              ),
            ]),
            const SizedBox(height: 20),
            Segmented(options: periodos, selected: _periodo, onChanged: (i) => setState(() => _periodo = i)),
            const SizedBox(height: 24),
            _Podio(key: ValueKey(_periodo), top: top),
            const SizedBox(height: 20),
            _SuaPosicao(eu: eu, ranking: r, periodo: _periodo),
            const SizedBox(height: 22),
            const SectionLabel('Classificação'),
            GroupCard(children: [for (final p in resto) _Linha(p)]),
            const SizedBox(height: 14),
            Row(children: [
              const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.muted),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Cada consulta de descarte e cada coleta conta 1 ponto.', style: AppText.caption),
              ),
            ]),
          ]),
        );
      },
    );
  }
}

// ---------------------------------------------------------------- Pódio
class _Podio extends StatelessWidget {
  const _Podio({super.key, required this.top});
  final List<Posicao> top;

  @override
  Widget build(BuildContext context) {
    // Ordem visual: 2º · 1º · 3º
    final ordem = [if (top.length > 1) top[1], top[0], if (top.length > 2) top[2]];
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      for (final p in ordem) Expanded(child: _Degrau(p: p)),
    ]);
  }
}

class _Degrau extends StatelessWidget {
  const _Degrau({required this.p});
  final Posicao p;

  @override
  Widget build(BuildContext context) {
    final altura = switch (p.pos) { 1 => 120.0, 2 => 92.0, _ => 72.0 };
    final avatar = p.pos == 1 ? 68.0 : 56.0;
    final cor = corMedalha(p.pos);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      if (p.pos == 1) const Icon(Icons.workspace_premium_rounded, color: _ouro, size: 28) else const SizedBox(height: 8),
      const SizedBox(height: 4),
      Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: cor, width: 3)),
        child: Avatar(p.iniciais, size: avatar, dark: p.voce, bytes: p.foto),
      ),
      const SizedBox(height: 8),
      Text(p.voce ? 'Você' : p.nome.split(' ').first,
          maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.t(14, FontWeight.w700, AppColors.ink)),
      Text('${p.descartes} descartes', style: AppText.caption.copyWith(fontSize: 12)),
      const SizedBox(height: 10),
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 500 + (3 - p.pos) * 150),
        curve: Curves.easeOutCubic,
        builder: (_, v, __) => Container(
          height: altura * v,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: p.pos == 1 ? AppColors.primary : AppColors.primarySoft,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border(top: BorderSide(color: cor, width: 4)),
          ),
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 10),
          child: v > 0.5
              ? Text('${p.pos}º',
                  style: AppText.t(22, FontWeight.w700, p.pos == 1 ? AppColors.accent : AppColors.primary))
              : null,
        ),
      ),
    ]);
  }
}

// ---------------------------------------------------------------- Sua posição
class _SuaPosicao extends StatelessWidget {
  const _SuaPosicao({required this.eu, required this.ranking, required this.periodo});
  final Posicao eu;
  final List<Posicao> ranking;
  final int periodo;

  @override
  Widget build(BuildContext context) {
    final String msg;
    if (eu.pos == 1) {
      msg = 'Você está no topo! Continue descartando certo.';
    } else {
      final acima = ranking[eu.pos - 2];
      final faltam = acima.descartes - eu.descartes + 1;
      msg = 'Faltam $faltam ${faltam == 1 ? 'descarte' : 'descartes'} para passar ${acima.nome.split(' ').first}.';
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Row(children: [
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
          child: Text('${eu.pos}º', style: AppText.t(19, FontWeight.w700, AppColors.accent)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Sua posição · ${eu.descartes} descartes', style: AppText.t(15, FontWeight.w700, AppColors.ink)),
            const SizedBox(height: 3),
            Text(msg, style: AppText.t(13, FontWeight.w500, AppColors.primary, height: 1.35)),
          ]),
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------- Linha da lista
class _Linha extends StatelessWidget {
  const _Linha(this.p);
  final Posicao p;
  @override
  Widget build(BuildContext context) => Container(
        color: p.voce ? AppColors.accentSoft : null,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(children: [
          SizedBox(
            width: 30,
            child: Text('${p.pos}º', style: AppText.t(14, FontWeight.w700, p.voce ? AppColors.primary : AppColors.muted)),
          ),
          Avatar(p.iniciais, size: 40, dark: p.voce, bytes: p.foto),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.voce ? '${p.nome} (você)' : p.nome,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.bodyStrong),
              const SizedBox(height: 2),
              Text(p.bairro, style: AppText.caption),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${p.descartes}', style: AppText.t(16, FontWeight.w700, AppColors.primary)),
            Text('descartes', style: AppText.caption.copyWith(fontSize: 11)),
          ]),
        ]),
      );
}
