import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecoscan/core/core.dart';

import '../state/app_state.dart';
import 'acompanhar.dart';
import 'home_shell.dart';
import 'orientacao.dart';
import 'mapa_pontos.dart';
import 'ranking.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onVerHistorico, required this.onVerPerfil, required this.onVerRanking});
  final VoidCallback onVerHistorico;
  final VoidCallback onVerPerfil;
  final VoidCallback onVerRanking;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final recentes = app.historico.take(2).toList();
        final eu = montarRanking(1).firstWhere((p) => p.voce);
        return SafeArea(
          bottom: false,
          child: ListView(padding: const EdgeInsets.fromLTRB(24, 16, 24, 24), children: [
            const Align(alignment: Alignment.centerLeft, child: EcoLockup(leaf: 28, text: 20, hero: false)),
            const SizedBox(height: 18),
            // Saudação
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Olá, ${app.primeiroNome}', style: AppText.t(26, FontWeight.w700, AppColors.ink, ls: -0.8)),
                  const SizedBox(height: 4),
                  Text('Descubra como e onde descartar cada resíduo.', style: AppText.caption.copyWith(fontSize: 15)),
                ]),
              ),
              GestureDetector(onTap: onVerPerfil, child: Avatar(app.iniciais, bytes: app.fotoPerfil)),
            ]),
            const SizedBox(height: 20),
            // Para que serve o app
            const FadeIn(child: _ComoFunciona()),
            const SizedBox(height: 16),
            const FadeIn(delay: 40, child: _CardEscanear()),
            const SizedBox(height: 16),
            // Seu impacto
            FadeIn(
              delay: 60,
              child: Row(children: [
                _Numero(
                  valor: '${app.historico.where((h) => h.pedido == null).length}',
                  rotulo: 'consultas',
                  icon: Icons.center_focus_weak_rounded,
                  onTap: onVerHistorico,
                ),
                const SizedBox(width: 10),
                _Numero(
                  valor: '${app.historico.where((h) => h.pedido != null).length}',
                  rotulo: 'coletas',
                  icon: Icons.local_shipping_outlined,
                  onTap: onVerHistorico,
                ),
                const SizedBox(width: 10),
                _Numero(
                  valor: '${eu.pos}º',
                  rotulo: 'no ranking',
                  icon: Icons.emoji_events_outlined,
                  onTap: onVerRanking,
                ),
              ]),
            ),
            const SizedBox(height: 28),
            // Categorias
            const SectionLabel('Ou escolha o tipo de resíduo'),
            FadeIn(
              delay: 120,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                for (final c in categorias)
                  _Categoria(c, onTap: () => abrirCategoria(context, c.id)),
              ]),
            ),
            const SizedBox(height: 28),
            // Mini mapa de pontos de descarte
            SectionLabel('Onde descartar perto de você',
                action: 'Ver mapa',
                onAction: () => Navigator.of(context).push(slideRoute(const MapaPontosScreen()))),
            const FadeIn(delay: 160, child: MiniMapaPontos()),
            const SizedBox(height: 28),
            // Recentes
            SectionLabel('Recente', action: recentes.isEmpty ? null : 'Ver tudo', onAction: onVerHistorico),
            if (recentes.isEmpty)
              const SoftCard(
                child: EmptyState(
                    icon: Icons.history_rounded,
                    title: 'Nada por aqui ainda',
                    text: 'Suas consultas aparecem aqui.'),
              )
            else
              FadeIn(
                delay: 220,
                child: GroupCard(children: [
                  for (final h in recentes)
                    ListRow(
                      icon: h.icon,
                      leading: h.foto != null ? PhotoThumb(bytes: h.foto, icon: h.icon, size: 40) : null,
                      title: h.titulo,
                      subtitle: h.subtitulo,
                      trailing: h.pedido != null ? StatusBadge(h.pedido!.status) : null,
                      onTap: () => abrirItemHistorico(context, h),
                    ),
                ]),
              ),
            const SizedBox(height: 16),
            // Atalho para o Hall da Fama
            Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: onVerRanking,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: AppColors.white10, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.emoji_events_rounded, color: Color(0xFFD4A72C), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Hall da Fama', style: AppText.t(15, FontWeight.w700, Colors.white)),
                        const SizedBox(height: 2),
                        Text('Você está em ${eu.pos}º lugar este mês',
                            style: AppText.t(13, FontWeight.w500, AppColors.accent)),
                      ]),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.white),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                const Icon(Icons.tips_and_updates_outlined, size: 20, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Pilhas e lâmpadas nunca vão no lixo comum.',
                      style: AppText.t(13, FontWeight.w500, AppColors.primary)),
                ),
              ]),
            ),
          ]),
        );
      },
    );
  }
}

void abrirItemHistorico(BuildContext context, ItemHistorico h) {
  if (h.pedido != null) {
    Navigator.of(context).push(slideRoute(AcompanharScreen(pedidoId: h.pedido!.id)));
  } else if (h.residuo != null) {
    Navigator.of(context).push(slideRoute(OrientacaoScreen(residuo: h.residuo!, doHistorico: true, foto: h.foto)));
  }
}

class _CardEscanear extends StatelessWidget {
  const _CardEscanear();
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(24)),
      child: Stack(children: [
        const Positioned(
          right: -24,
          top: -24,
          child: Opacity(opacity: 0.12, child: EcoLeaf(size: 170, veinColor: AppColors.primary)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Escanear resíduo', style: AppText.t(22, FontWeight.w700, Colors.white, ls: -0.5)),
            const SizedBox(height: 6),
            Text('Foto  →  Material  →  Orientação', style: AppText.t(13, FontWeight.w500, AppColors.accent)),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(
                child: EcoButton(
                  label: 'Abrir câmera',
                  icon: Icons.photo_camera_outlined,
                  kind: BtnKind.light,
                  compact: true,
                  onPressed: () => iniciarEscaneamento(context, fonte: ImageSource.camera),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: AppColors.white15,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => iniciarEscaneamento(context, fonte: ImageSource.gallery),
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(Icons.photo_library_outlined, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _Categoria extends StatelessWidget {
  const _Categoria(this.c, {required this.onTap});
  final Categoria c;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Column(children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.soft,
            ),
            child: Icon(c.icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(height: 8),
          Text(c.curto, style: AppText.t(12, FontWeight.w500, AppColors.ink)),
        ]),
      );
}

class _Numero extends StatelessWidget {
  const _Numero({required this.valor, required this.rotulo, required this.icon, required this.onTap});
  final String valor, rotulo;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(height: 8),
                Text(valor, style: AppText.t(22, FontWeight.w700, AppColors.ink, ls: -0.5)),
                Text(rotulo, style: AppText.t(12, FontWeight.w500, AppColors.muted)),
              ]),
            ),
          ),
        ),
      );
}

/// Explica em 3 passos para que serve o EcoScan.
class _ComoFunciona extends StatelessWidget {
  const _ComoFunciona();

  @override
  Widget build(BuildContext context) {
    Widget passo(int n, IconData icon, String titulo, String texto) => Expanded(
          child: Column(children: [
            Stack(clipBehavior: Clip.none, children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: Text('$n', style: AppText.t(11, FontWeight.w700, Colors.white)),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Text(titulo, textAlign: TextAlign.center, style: AppText.t(13, FontWeight.w700, AppColors.ink)),
            const SizedBox(height: 2),
            Text(texto, textAlign: TextAlign.center, style: AppText.t(11, FontWeight.w500, AppColors.muted, height: 1.3)),
          ]),
        );

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(22)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Como funciona', style: AppText.t(15, FontWeight.w700, AppColors.primary)),
        const SizedBox(height: 2),
        Text('Não sabe onde jogar algo? O EcoScan te orienta.',
            style: AppText.t(13, FontWeight.w500, AppColors.primary)),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          passo(1, Icons.photo_camera_outlined, 'Fotografe', 'Tire foto do resíduo'),
          passo(2, Icons.category_outlined, 'Confirme', 'Diga qual é o material'),
          passo(3, Icons.place_outlined, 'Descarte', 'Veja onde levar ou peça coleta'),
        ]),
      ]),
    );
  }
}
