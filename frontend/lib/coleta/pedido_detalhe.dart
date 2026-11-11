import 'package:ecoscan/core/core.dart';
import 'package:flutter/material.dart';

import '../state/coleta_state.dart';
import 'pedidos.dart';

/// Detalhe do pedido: mapa do local, material, contato e ações.
class PedidoDetalheScreen extends StatelessWidget {
  const PedidoDetalheScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: coleta,
          builder: (context, _) {
            final p = coleta.porId(id);
            if (p == null) return const Center(child: Text('Pedido não encontrado'));
            final r = p.residuo;
            return Column(children: [
              TopBar(title: 'Pedido #${p.id}'),
              Expanded(
                child: ListView(padding: const EdgeInsets.fromLTRB(24, 10, 24, 24), children: [
                  // Mapa do local da coleta
                  SoftCard(
                    padding: EdgeInsets.zero,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: SizedBox(
                        height: 170,
                        child: EcoMapa(
                          interativo: false,
                          centro: p.posicao,
                          zoom: 15,
                          marcadores: [ecoPin(ponto: p.posicao, icon: p.icon, selecionado: true)],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Material
                  SoftCard(
                    child: Row(children: [
                      IconBox(icon: p.icon, size: 52, radius: 16, active: true),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Tag(p.categoria),
                          const SizedBox(height: 6),
                          Text(p.titulo, style: AppText.title),
                          const SizedBox(height: 2),
                          Text(p.quantidade, style: AppText.caption.copyWith(fontSize: 14)),
                        ]),
                      ),
                      StatusBadge(p.status),
                    ]),
                  ),
                  if (!coleta.cabeNoVeiculo(p)) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppColors.warnSoft, borderRadius: BorderRadius.circular(16)),
                      child: Row(children: [
                        const Icon(Icons.warning_amber_rounded, size: 20, color: AppColors.warn),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text('Precisa de carro ou caminhão. Seu veículo: ${coleta.perfil.veiculo.label.toLowerCase()}.',
                              style: AppText.t(13, FontWeight.w600, AppColors.warn)),
                        ),
                      ]),
                    ),
                  ],
                  if (r != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(16)),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Icon(Icons.recycling_rounded, size: 20, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text('Destino: ${r.destino}. ${r.alerta}.',
                              style: AppText.t(13, FontWeight.w500, AppColors.primary, height: 1.4)),
                        ),
                      ]),
                    ),
                  ],
                  const SizedBox(height: 22),
                  const SectionLabel('Retirada'),
                  GroupCard(children: [
                    ListRow(icon: Icons.person_outline_rounded, title: p.solicitante, subtitle: p.tipoSolicitante),
                    ListRow(
                      icon: Icons.location_on_outlined,
                      title: 'Endereço',
                      subtitle: '${p.endereco} · ${formatarDistancia(coleta.distancia(p))} ${coleta.origemDistancia}',
                    ),
                    ListRow(icon: Icons.calendar_today_outlined, title: 'Quando', subtitle: '${p.data} · ${p.periodo}'),
                    if (p.responsavel != null)
                      ListRow(icon: Icons.badge_outlined, title: 'Responsável', subtitle: p.responsavel),
                    if (p.obs.isNotEmpty) ListRow(icon: Icons.notes_rounded, title: 'Observação', subtitle: p.obs),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                      child: EcoButton(
                        label: 'Como chegar',
                        icon: Icons.directions_outlined,
                        kind: BtnKind.secondary,
                        compact: true,
                        onPressed: () => abrirRota(p.posicao.latitude, p.posicao.longitude),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: EcoButton(
                        label: 'Ligar',
                        icon: Icons.phone_outlined,
                        kind: BtnKind.secondary,
                        compact: true,
                        onPressed: () async {
                          final ok = await showConfirmSheet(
                            context,
                            title: 'Ligar para ${p.solicitante}?',
                            subtitle: p.telefone,
                            confirm: 'Ligar agora',
                          );
                          if (ok) await ligarPara(p.telefone);
                        },
                      ),
                    ),
                  ]),
                ]),
              ),
              _acoes(context, p),
            ]);
          },
        ),
      ),
    );
  }

  Widget _acoes(BuildContext context, PedidoColeta p) {
    switch (p.status) {
      case StatusPedido.enviado:
        if (p.recusadoPor.contains(coleta.perfil.nome)) {
          return ActionBar(children: [Text('Você recusou este pedido.', style: AppText.t(14, FontWeight.w500, AppColors.muted))]);
        }
        return ActionBar(children: [
          Row(children: [
            Expanded(
              child: EcoButton(
                label: 'Recusar',
                kind: BtnKind.secondary,
                onPressed: () async {
                  if (await confirmarRecusa(context)) {
                    coleta.recusar(p);
                    if (context.mounted) {
                      toast(context, 'Pedido recusado');
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: EcoButton(label: 'Aceitar coleta', onPressed: () => aceitarPedido(context, p)),
            ),
          ]),
        ]);
      case StatusPedido.aceito:
        if (p.aceitoPor != coleta.perfil.nome) {
          return ActionBar(children: [Text('Aceito por ${p.aceitoPor}', style: AppText.t(14, FontWeight.w500, AppColors.muted))]);
        }
        return ActionBar(children: [
          EcoButton(
            label: 'Marcar como concluída',
            icon: Icons.check_rounded,
            onPressed: () {
              coleta.concluir(p);
              toast(context, 'Coleta concluída · o usuário foi avisado');
            },
          ),
        ]);
      case StatusPedido.concluido:
        return ActionBar(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.task_alt_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Coleta concluída ${dataCurta(p.concluidoEm ?? DateTime.now())}',
                style: AppText.t(15, FontWeight.w600, AppColors.primary)),
          ]),
        ]);
      case StatusPedido.recusado:
        return const SizedBox.shrink();
    }
  }
}
