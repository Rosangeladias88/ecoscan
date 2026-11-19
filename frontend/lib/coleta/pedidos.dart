import 'package:ecoscan/core/core.dart';
import 'package:flutter/material.dart';

import '../state/coleta_state.dart';
import 'pedido_detalhe.dart';

/// Aceitar um pedido. Muda conforme o papel:
/// - Coletador: avisa se o pedido não cabe no veículo dele.
/// - Empresa: pergunta quem da equipe vai fazer a coleta.
/// Devolve true se aceitou.
Future<bool> aceitarPedido(BuildContext context, PedidoColeta p) async {
  final perfil = coleta.perfil;
  if (!coleta.cabeNoVeiculo(p)) {
    final ok = await showConfirmSheet(
      context,
      title: 'Pode não caber no seu veículo',
      subtitle: '${p.titulo} costuma precisar de carro ou caminhão, e o seu veículo é: ${perfil.veiculo.label.toLowerCase()}. Aceitar mesmo assim?',
      confirm: 'Aceitar mesmo assim',
      cancel: 'Voltar',
    );
    if (!ok) return false;
  }
  String? responsavel;
  if (perfil.empresa) {
    if (perfil.equipe.isEmpty) {
      if (context.mounted) toast(context, 'Cadastre alguém na aba Equipe para fazer a coleta');
      return false;
    }
    if (!context.mounted) return false;
    // Sugere primeiro quem tem veículo grande quando o pedido é volumoso.
    final equipe = [...perfil.equipe];
    if (p.volumoso) equipe.sort((a, b) => (b.veiculo.grande ? 1 : 0).compareTo(a.veiculo.grande ? 1 : 0));
    final i = await showOptionsSheet(
      context,
      title: 'Quem vai fazer esta coleta?',
      subtitle: p.volumoso ? 'Este pedido precisa de carro ou caminhão.' : '${p.titulo} · ${p.data}, ${p.periodo.toLowerCase()}',
      options: [
        for (final m in equipe)
          '${m.nome} · ${m.veiculo.label}${coleta.emAndamentoCom(m.nome) > 0 ? ' · ${coleta.emAndamentoCom(m.nome)} em andamento' : ''}'
      ],
      selected: 0,
      confirm: 'Aceitar coleta',
    );
    if (i == null) return false;
    responsavel = equipe[i].nome;
  }
  coleta.aceitar(p, responsavel: responsavel);
  if (context.mounted) {
    toast(context, responsavel == null ? 'Coleta aceita · o usuário foi avisado' : 'Coleta aceita · $responsavel vai buscar');
  }
  return true;
}

/// Confirmação antes de recusar.
Future<bool> confirmarRecusa(BuildContext context) => showConfirmSheet(
      context,
      title: 'Recusar este pedido?',
      subtitle: 'Ele sai da sua lista e continua disponível para outros coletadores e empresas.',
      confirm: 'Recusar pedido',
      cancel: 'Voltar',
      destructive: true,
    );

/// Pedidos de coleta: Novos · Aceitos · Concluídos.
class PedidosScreen extends StatefulWidget {
  const PedidosScreen({super.key});
  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  int _aba = 0;

  void _abrir(PedidoColeta p) => Navigator.of(context).push(slideRoute(PedidoDetalheScreen(id: p.id)));

  Future<void> _recusar(PedidoColeta p) async {
    if (await confirmarRecusa(context)) {
      coleta.recusar(p);
      if (mounted) toast(context, 'Pedido recusado');
    }
  }

  Future<void> _aceitar(PedidoColeta p) async {
    if (await aceitarPedido(context, p) && mounted) setState(() => _aba = 1);
  }

  void _concluir(PedidoColeta p) {
    coleta.concluir(p);
    toast(context, 'Coleta concluída · o usuário foi avisado');
    setState(() => _aba = 2);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: coleta,
      builder: (context, _) {
        final perfil = coleta.perfil;
        final novos = coleta.novos;
        final aceitos = coleta.aceitos;
        final concluidos = coleta.concluidos;
        final List<Widget> conteudo = switch (_aba) {
          0 => novos.isEmpty
              ? [const EmptyState(icon: Icons.inbox_outlined, title: 'Nenhum pedido novo', text: 'Pedidos dos materiais que você recolhe aparecem aqui.')]
              : [
                  for (var i = 0; i < novos.length; i++)
                    FadeIn(
                      delay: i * 70,
                      child: CardPedido(
                        p: novos[i],
                        onTap: () => _abrir(novos[i]),
                        acoes: [
                          ('Recusar', BtnKind.secondary, () => _recusar(novos[i])),
                          ('Aceitar', BtnKind.primary, () => _aceitar(novos[i])),
                        ],
                      ),
                    ),
                ],
          1 => aceitos.isEmpty
              ? [const EmptyState(icon: Icons.local_shipping_outlined, title: 'Nenhuma coleta em andamento', text: 'Aceite um pedido na aba Novos.')]
              : [
                  for (final p in aceitos)
                    CardPedido(
                      p: p,
                      onTap: () => _abrir(p),
                      acoes: [
                        ('Como chegar', BtnKind.secondary, () => abrirRota(p.posicao.latitude, p.posicao.longitude)),
                        ('Concluir', BtnKind.primary, () => _concluir(p)),
                      ],
                    ),
                ],
          _ => concluidos.isEmpty
              ? [const EmptyState(icon: Icons.task_alt_rounded, title: 'Nada concluído ainda', text: 'As coletas finalizadas aparecem aqui.')]
              : [
                  GroupCard(children: [
                    for (final p in concluidos)
                      ListRow(
                        icon: p.icon,
                        title: p.titulo,
                        subtitle: [
                          p.tipoSolicitante,
                          if (p.responsavel != null) p.responsavel!,
                          dataCurta(p.concluidoEm ?? p.criado),
                        ].join(' · '),
                        trailing: const StatusBadge(StatusPedido.concluido),
                        onTap: () => _abrir(p),
                      ),
                  ]),
                ],
        };
        return SafeArea(
          bottom: false,
          child: ListView(padding: const EdgeInsets.fromLTRB(24, 16, 24, 24), children: [
            const Align(alignment: Alignment.centerLeft, child: EcoLockup(leaf: 28, text: 20, hero: false)),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${perfil.tipoLabel} · ${perfil.nome}',
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.t(13, FontWeight.w500, AppColors.muted)),
                  Text('Pedidos', style: AppText.display),
                ]),
              ),
              Avatar(perfil.iniciais, dark: true),
            ]),
            const SizedBox(height: 18),
            Row(children: [
              _Resumo('${novos.length}', 'novos', Icons.fiber_new_outlined, destaque: novos.isNotEmpty),
              const SizedBox(width: 10),
              _Resumo('${aceitos.length}', 'em andamento', Icons.local_shipping_outlined),
              const SizedBox(width: 10),
              _Resumo('${coleta.concluidasNoMes}', 'no mês', Icons.task_alt_rounded),
            ]),
            if (!perfil.empresa) ...[
              const SizedBox(height: 10),
              Row(children: [
                Icon(perfil.veiculo.icon, size: 16, color: AppColors.muted),
                const SizedBox(width: 6),
                Text('Seu veículo: ${perfil.veiculo.label}', style: AppText.caption),
              ]),
            ],
            const SizedBox(height: 18),
            Segmented(
              options: [novos.isEmpty ? 'Novos' : 'Novos (${novos.length})', 'Aceitos', 'Concluídos'],
              selected: _aba,
              onChanged: (i) => setState(() => _aba = i),
            ),
            const SizedBox(height: 18),
            for (final w in conteudo) Padding(padding: const EdgeInsets.only(bottom: 12), child: w),
          ]),
        );
      },
    );
  }
}

class _Resumo extends StatelessWidget {
  const _Resumo(this.n, this.label, this.icon, {this.destaque = false});
  final String n, label;
  final IconData icon;
  final bool destaque;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: destaque ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppShadows.soft,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, size: 18, color: destaque ? AppColors.accent : AppColors.primary),
            const SizedBox(height: 8),
            Text(n, style: AppText.t(20, FontWeight.w700, destaque ? Colors.white : AppColors.ink)),
            Text(label, style: AppText.t(11, FontWeight.w500, destaque ? AppColors.white70 : AppColors.muted)),
          ]),
        ),
      );
}

/// Cartão de pedido usado na lista e no mapa.
class CardPedido extends StatelessWidget {
  const CardPedido({super.key, required this.p, required this.onTap, this.acoes = const []});
  final PedidoColeta p;
  final VoidCallback onTap;
  final List<(String, BtnKind, VoidCallback)> acoes;

  @override
  Widget build(BuildContext context) {
    final novo = p.status == StatusPedido.enviado;
    final cabe = coleta.cabeNoVeiculo(p);
    return GestureDetector(
      onTap: onTap,
      child: SoftCard(
        border: novo ? AppColors.primary : null,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            IconBox(icon: p.icon, size: 48, radius: 14),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.titulo, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.bodyStrong),
                const SizedBox(height: 2),
                Text(p.tipoSolicitante, style: AppText.caption),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: novo ? AppColors.accent : AppColors.accentSoft, borderRadius: BorderRadius.circular(6)),
              child: Text(novo ? 'Novo' : 'Aceita', style: AppText.t(11, FontWeight.w700, AppColors.primary)),
            ),
          ]),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _meta(Icons.inventory_2_outlined, p.quantidade),
            _meta(Icons.calendar_today_outlined, '${p.data}, ${p.periodo.toLowerCase()}'),
            _meta(Icons.near_me_outlined, formatarDistancia(coleta.distancia(p))),
            if (!cabe) _meta(Icons.warning_amber_rounded, 'Precisa de carro ou caminhão', alerta: true),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.muted),
            const SizedBox(width: 6),
            Expanded(child: Text(p.endereco, style: AppText.t(12, FontWeight.w500, AppColors.muted))),
          ]),
          if (p.responsavel != null && !novo) ...[
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.badge_outlined, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text('Responsável: ${p.responsavel}', style: AppText.t(12, FontWeight.w600, AppColors.primary)),
            ]),
          ],
          if (acoes.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(children: [
              for (var i = 0; i < acoes.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(child: EcoButton(label: acoes[i].$1, kind: acoes[i].$2, compact: true, onPressed: acoes[i].$3)),
              ],
            ]),
          ],
        ]),
      ),
    );
  }

  Widget _meta(IconData i, String t, {bool alerta = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(color: alerta ? AppColors.warnSoft : AppColors.subtle, borderRadius: BorderRadius.circular(10)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(i, size: 14, color: alerta ? AppColors.warn : AppColors.muted),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Text(t, overflow: TextOverflow.ellipsis, style: AppText.t(12, FontWeight.w500, alerta ? AppColors.warn : AppColors.ink)),
          ),
        ]),
      );
}
