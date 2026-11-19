import 'package:flutter/material.dart';
import 'package:ecoscan/core/core.dart';

import '../acesso/login.dart';
import '../state/app_state.dart';
import '../state/sessao.dart';

class AcompanharScreen extends StatelessWidget {
  const AcompanharScreen({super.key, required this.pedidoId});
  final String pedidoId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: app,
          builder: (context, _) {
            final p = app.pedidoPorId(pedidoId);
            if (p == null) return const Center(child: Text('Pedido não encontrado'));
            final (IconData icone, String titulo, String sub) = switch (p.status) {
              StatusPedido.enviado => (Icons.schedule_rounded, 'Solicitação enviada', 'Aguardando um coletador ou empresa aceitar'),
              StatusPedido.aceito => (Icons.check_rounded, 'Coleta aceita', 'Retirada ${p.data.toLowerCase()}, ${p.periodo.toLowerCase()}'),
              StatusPedido.concluido => (Icons.eco_rounded, 'Coleta concluída', 'Obrigado por descartar certo!'),
              StatusPedido.recusado => (Icons.close_rounded, 'Pedido recusado', 'Tente outra data'),
            };
            final etapa = switch (p.status) {
              StatusPedido.enviado => 1,
              StatusPedido.aceito => 2,
              StatusPedido.concluido => 3,
              StatusPedido.recusado => 1,
            };
            return Column(children: [
              TopBar(
                title: 'Pedido #${p.id}',
                close: true,
                onBack: () => Navigator.of(context).popUntil((r) => r.isFirst),
              ),
              Expanded(
                child: ListView(padding: const EdgeInsets.fromLTRB(24, 10, 24, 24), children: [
                  FadeIn(
                    child: SoftCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                            child: IconBox(
                              key: ValueKey(p.status),
                              icon: icone,
                              size: 52,
                              radius: 16,
                              bg: p.status == StatusPedido.recusado ? AppColors.dangerSoft : (p.status == StatusPedido.enviado ? AppColors.warnSoft : AppColors.primary),
                              fg: p.status == StatusPedido.recusado ? AppColors.danger : (p.status == StatusPedido.enviado ? AppColors.warn : AppColors.accent),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(titulo, style: AppText.t(21, FontWeight.w700, AppColors.ink, ls: -0.5)),
                              const SizedBox(height: 3),
                              Text(sub, style: AppText.caption.copyWith(fontSize: 14)),
                            ]),
                          ),
                        ]),
                        const SizedBox(height: 18),
                        ProgressSegments(total: 3, done: etapa, height: 6),
                        const SizedBox(height: 8),
                        Row(children: [
                          for (final (i, l) in const [(1, 'Enviado'), (2, 'Aceito'), (3, 'Concluído')])
                            Expanded(
                              child: Text(l,
                                  textAlign: i == 1 ? TextAlign.left : (i == 3 ? TextAlign.right : TextAlign.center),
                                  style: AppText.t(11, i <= etapa ? FontWeight.w600 : FontWeight.w500,
                                      i <= etapa ? AppColors.ink : AppColors.muted)),
                            ),
                        ]),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const SectionLabel('Quem vai coletar'),
                  if (p.prestador != null)
                    SoftCard(
                      padding: const EdgeInsets.all(14),
                      child: Row(children: [
                        const Avatar('RP'),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(p.prestador!, style: AppText.bodyStrong),
                            const SizedBox(height: 5),
                            if (p.selo) const Tag('Projeto de ressocialização', icon: Icons.groups_outlined),
                          ]),
                        ),
                        CircleBtn(
                          icon: Icons.phone_outlined,
                          onTap: () async {
                            // Figma: "Sheet · Ligar"
                            final ok = await showConfirmSheet(
                              context,
                              title: 'Ligar para quem vai coletar?',
                              subtitle: '${p.prestador} · ${app.telefonePrestador}',
                              confirm: 'Ligar agora',
                            );
                            if (ok) await ligarPara(app.telefonePrestador);
                          },
                        ),
                      ]),
                    )
                  else
                    SoftCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          const IconBox(
                              icon: Icons.search_rounded, size: 36, radius: 18, bg: AppColors.warnSoft, fg: AppColors.warn),
                          const SizedBox(width: 12),
                          Expanded(child: Text('Procurando quem colete perto de você…', style: AppText.bodyStrong)),
                        ]),
                        const SizedBox(height: 12),
                        const LinearProgressIndicator(
                          minHeight: 4,
                          color: AppColors.primary,
                          backgroundColor: AppColors.primarySoft,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        const SizedBox(height: 10),
                        Text('Coletadores e empresas da região recebem seu pedido. Você é avisado quando alguém aceitar.',
                            style: AppText.caption),
                        const SizedBox(height: 12),
                        // Demonstração no mesmo celular: entrar como quem coleta e aceitar
                        Material(
                          color: AppColors.accentSoft,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              sessao.sair();
                              Navigator.of(context).pushAndRemoveUntil(
                                fadeRoute(LoginScreen(email: sessao.contaDemo(Papel.coletador)?.email)),
                                (_) => false,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(children: [
                                const Icon(Icons.swap_horiz_rounded, size: 18, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text('Demonstração: entrar como coletador para aceitar',
                                      style: AppText.t(13, FontWeight.w600, AppColors.primary)),
                                ),
                                const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.primary),
                              ]),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  const SizedBox(height: 22),
                  const SectionLabel('Detalhes'),
                  GroupCard(children: [
                    ListRow(
                      icon: p.icon,
                      leading: PhotoThumb(bytes: p.foto, icon: p.icon, size: 40),
                      title: p.titulo,
                      subtitle: p.quantidade,
                    ),
                    ListRow(icon: Icons.location_on_outlined, title: 'Endereço', subtitle: p.endereco),
                    ListRow(icon: Icons.calendar_today_outlined, title: 'Data', subtitle: '${p.data} · ${p.periodo}'),
                    if (p.obs.isNotEmpty) ListRow(icon: Icons.notes_rounded, title: 'Observação', subtitle: p.obs),
                  ]),
                ]),
              ),
              ActionBar(children: [
                EcoButton(
                  label: 'Voltar ao início',
                  kind: BtnKind.secondary,
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                ),
              ]),
            ]);
          },
        ),
      ),
    );
  }
}
