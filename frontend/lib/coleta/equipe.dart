import 'package:ecoscan/core/core.dart';
import 'package:flutter/material.dart';

import '../state/coleta_state.dart';

/// Só para EMPRESA: pessoas da equipe que fazem as coletas.
class EquipeScreen extends StatefulWidget {
  const EquipeScreen({super.key});
  @override
  State<EquipeScreen> createState() => _EquipeScreenState();
}

class _EquipeScreenState extends State<EquipeScreen> {
  final _nome = TextEditingController();
  final _tel = TextEditingController();

  @override
  void dispose() {
    _nome.dispose();
    _tel.dispose();
    super.dispose();
  }

  Future<void> _adicionar() async {
    _nome.clear();
    _tel.clear();
    var veiculo = Veiculo.carro;
    final ok = await showEcoSheet<bool>(context, title: 'Adicionar à equipe', subtitle: 'Quem vai fazer coletas pela empresa.', children: [
      AppField(label: 'Nome', icon: Icons.person_outline_rounded, controller: _nome),
      AppField(label: 'Telefone', icon: Icons.phone_outlined, controller: _tel, keyboard: TextInputType.phone),
      Text('Veículo', style: AppText.label),
      StatefulBuilder(
        builder: (ctx, setS) => Wrap(spacing: 8, runSpacing: 8, children: [
          for (final v in Veiculo.values)
            ChoiceChip(
              label: Text(v.label),
              avatar: Icon(v.icon, size: 18, color: veiculo == v ? Colors.white : AppColors.primary),
              selected: veiculo == v,
              showCheckmark: false,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              side: BorderSide(color: veiculo == v ? AppColors.primary : AppColors.line),
              labelStyle: AppText.t(13, FontWeight.w600, veiculo == v ? Colors.white : AppColors.ink),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (_) => setS(() => veiculo = v),
            ),
        ]),
      ),
      Builder(builder: (ctx) => EcoButton(label: 'Adicionar', onPressed: () => Navigator.of(ctx).pop(true))),
    ]);
    if (ok != true) return;
    if (_nome.text.trim().length < 2) {
      if (mounted) toast(context, 'Digite o nome da pessoa');
      return;
    }
    coleta.atualizar(() => coleta.perfil.equipe.add(MembroEquipe(_nome.text.trim(), _tel.text.trim(), veiculo)));
    if (mounted) toast(context, '${_nome.text.trim()} entrou na equipe');
  }

  Future<void> _remover(MembroEquipe m) async {
    final andamento = coleta.emAndamentoCom(m.nome);
    final ok = await showConfirmSheet(
      context,
      title: 'Remover ${m.nome}?',
      subtitle: andamento > 0
          ? '${m.nome} tem $andamento coleta(s) em andamento. Elas continuam aceitas, sem responsável.'
          : 'A pessoa sai da equipe e não aparece mais na escolha de responsável.',
      confirm: 'Remover',
      destructive: true,
    );
    if (!ok) return;
    coleta.atualizar(() {
      coleta.perfil.equipe.remove(m);
      for (final p in coleta.aceitos.where((p) => p.responsavel == m.nome)) {
        p.responsavel = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: coleta,
      builder: (context, _) {
        final equipe = coleta.perfil.equipe;
        final grandes = equipe.where((m) => m.veiculo.grande).length;
        return SafeArea(
          bottom: false,
          child: ListView(padding: const EdgeInsets.fromLTRB(24, 16, 24, 24), children: [
            Text(coleta.perfil.nome, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.t(13, FontWeight.w500, AppColors.muted)),
            Text('Equipe', style: AppText.display),
            const SizedBox(height: 4),
            Text('Quem faz as coletas. Ao aceitar um pedido, você escolhe o responsável.',
                style: AppText.caption.copyWith(fontSize: 14)),
            const SizedBox(height: 18),
            SoftCard(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(children: [
                _stat('${equipe.length}', 'pessoas'),
                Container(width: 1, height: 32, color: AppColors.line),
                _stat('$grandes', 'levam volumosos'),
                Container(width: 1, height: 32, color: AppColors.line),
                _stat('${coleta.aceitos.length}', 'em andamento'),
              ]),
            ),
            const SizedBox(height: 22),
            const SectionLabel('Pessoas'),
            if (equipe.isEmpty)
              const SoftCard(
                child: EmptyState(icon: Icons.groups_outlined, title: 'Equipe vazia', text: 'Adicione quem vai fazer as coletas.'),
              )
            else
              GroupCard(children: [
                for (final m in equipe)
                  ListRow(
                    icon: m.veiculo.icon,
                    leading: Avatar(iniciaisDe(m.nome), size: 40),
                    title: m.nome,
                    subtitle: [
                      m.veiculo.label,
                      if (coleta.emAndamentoCom(m.nome) > 0) '${coleta.emAndamentoCom(m.nome)} em andamento',
                    ].join(' · '),
                    chevron: false,
                    trailing: IconButton(
                      tooltip: 'Remover',
                      icon: const Icon(Icons.person_remove_outlined, color: AppColors.muted, size: 20),
                      onPressed: () => _remover(m),
                    ),
                  ),
              ]),
            const SizedBox(height: 14),
            EcoButton(label: 'Adicionar pessoa', icon: Icons.person_add_alt_1_outlined, kind: BtnKind.secondary, onPressed: _adicionar),
          ]),
        );
      },
    );
  }

  Widget _stat(String n, String l) => Expanded(
        child: Column(children: [
          Text(n, style: AppText.t(20, FontWeight.w700, AppColors.primary)),
          const SizedBox(height: 2),
          Text(l, textAlign: TextAlign.center, style: AppText.caption.copyWith(fontSize: 12)),
        ]),
      );
}
