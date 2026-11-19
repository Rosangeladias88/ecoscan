import 'package:ecoscan/core/core.dart';
import 'package:flutter/material.dart';

import '../acesso/login.dart';
import '../state/coleta_state.dart';
import '../state/sessao.dart';

/// Perfil de quem coleta.
/// Coletador: dados, CPF e veículo. Empresa: dados, CNPJ, tipo e equipe.
class PerfilColetaScreen extends StatefulWidget {
  const PerfilColetaScreen({super.key});
  @override
  State<PerfilColetaScreen> createState() => _PerfilColetaScreenState();
}

class _PerfilColetaScreenState extends State<PerfilColetaScreen> {
  final _nome = TextEditingController();
  final _tel = TextEditingController();
  final _email = TextEditingController();

  @override
  void dispose() {
    _nome.dispose();
    _tel.dispose();
    _email.dispose();
    super.dispose();
  }

  PerfilColeta get _p => coleta.perfil;

  Future<void> _dados() async {
    _nome.text = _p.nome;
    _tel.text = _p.telefone;
    _email.text = _p.email;
    final ok = await showFieldsSheet(context, title: _p.empresa ? 'Dados da empresa' : 'Seus dados', fields: [
      AppField(label: _p.empresa ? 'Nome da empresa' : 'Nome', icon: Icons.badge_outlined, controller: _nome),
      AppField(label: 'Telefone', icon: Icons.phone_outlined, controller: _tel, keyboard: TextInputType.phone),
      AppField(label: 'E-mail', icon: Icons.mail_outline_rounded, controller: _email, keyboard: TextInputType.emailAddress),
    ]);
    if (!ok) return;
    final antigo = _p.nome;
    coleta.atualizar(() {
      if (_nome.text.trim().isNotEmpty) _p.nome = _nome.text.trim();
      _p.telefone = _tel.text.trim();
      if (_email.text.contains('@')) _p.email = _email.text.trim();
      // Mantém os pedidos ligados ao perfil depois de trocar o nome
      for (final x in coleta.pedidos.where((x) => x.aceitoPor == antigo)) {
        x.aceitoPor = _p.nome;
      }
    });
    final c = sessao.atual;
    if (c != null) {
      c.nome = _p.nome;
      c.telefone = _p.telefone;
    }
    if (mounted) toast(context, 'Dados atualizados');
  }

  Future<void> _veiculo() async {
    final i = await showOptionsSheet(
      context,
      title: 'Seu veículo',
      subtitle: 'Volumosos e entulho precisam de carro ou caminhão.',
      options: [for (final v in Veiculo.values) v.label],
      selected: _p.veiculo.index,
      confirm: 'Salvar',
    );
    if (i != null) coleta.atualizar(() => _p.veiculo = Veiculo.values[i]);
  }

  Future<void> _tipoEmpresa() async {
    final i = await showOptionsSheet(
      context,
      title: 'Tipo de empresa',
      options: [for (final t in TipoEmpresa.values) t.label],
      selected: _p.tipoEmpresa.index,
      confirm: 'Salvar',
    );
    if (i != null) coleta.atualizar(() => _p.tipoEmpresa = TipoEmpresa.values[i]);
  }

  /// Seleção de várias opções com chips.
  Future<void> _chips<T>({
    required String title,
    String? subtitle,
    required List<T> opcoes,
    required String Function(T) rotulo,
    required Set<T> atuais,
    required void Function(Set<T>) salvar,
  }) async {
    final sel = {...atuais};
    final ok = await showEcoSheet<bool>(context, title: title, subtitle: subtitle, children: [
      StatefulBuilder(
        builder: (ctx, setS) => Wrap(spacing: 8, runSpacing: 8, children: [
          for (final o in opcoes)
            FilterChip(
              label: Text(rotulo(o)),
              selected: sel.contains(o),
              showCheckmark: true,
              checkmarkColor: Colors.white,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              side: BorderSide(color: sel.contains(o) ? AppColors.primary : AppColors.line),
              labelStyle: AppText.t(13, FontWeight.w600, sel.contains(o) ? Colors.white : AppColors.ink),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (v) => setS(() => v ? sel.add(o) : sel.remove(o)),
            ),
        ]),
      ),
      Builder(builder: (ctx) => EcoButton(label: 'Salvar', onPressed: () => Navigator.of(ctx).pop(true))),
    ]);
    if (ok == true) {
      salvar(sel);
      if (mounted) toast(context, 'Salvo');
    }
  }

  void _sobre() => showEcoSheet<void>(context, title: 'Sobre o EcoScan', children: [
        Text('Um app para quem descarta e para quem coleta: usuários recebem orientação e pedem a coleta; coletadores e empresas recebem os pedidos da sua região.',
            style: AppText.body),
        Text('Equipe', style: AppText.label),
        Text('Rosangela Dias · Yago Martins · Diego Prestes · Thalia Leite', style: AppText.t(14, FontWeight.w500, AppColors.ink)),
        Text('Versão 1.0 (MVP)', style: AppText.caption.copyWith(fontSize: 12)),
      ]);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: coleta,
      builder: (context, _) {
        final p = _p;
        return SafeArea(
          bottom: false,
          child: ListView(padding: const EdgeInsets.fromLTRB(24, 20, 24, 24), children: [
            Center(child: Avatar(p.iniciais, size: 72, dark: true)),
            const SizedBox(height: 10),
            Center(child: Text(p.nome, textAlign: TextAlign.center, style: AppText.title)),
            const SizedBox(height: 2),
            Center(
              child: Text(p.empresa ? p.tipoLabel : 'Coletador · ${p.veiculo.label}',
                  style: AppText.caption.copyWith(fontSize: 14)),
            ),
            if (p.ressocializacao) ...[
              const SizedBox(height: 8),
              const Center(child: Tag('Projeto de ressocialização', icon: Icons.groups_outlined)),
            ],
            const SizedBox(height: 18),
            SoftCard(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(children: [
                _stat('${coleta.concluidos.length}', 'coletas'),
                Container(width: 1, height: 32, color: AppColors.line),
                _stat('${coleta.concluidasNoMes}', 'no mês'),
                Container(width: 1, height: 32, color: AppColors.line),
                p.empresa ? _stat('${p.equipe.length}', 'na equipe') : _stat('${p.materiais.length}', 'categorias'),
              ]),
            ),
            const SizedBox(height: 22),
            SectionLabel(p.empresa ? 'Empresa' : 'Seus dados'),
            GroupCard(children: [
              ListRow(
                icon: Icons.badge_outlined,
                title: p.empresa ? 'Dados da empresa' : 'Dados pessoais',
                subtitle: '${p.docLabel} ${p.documento}',
                onTap: _dados,
              ),
              if (p.empresa)
                ListRow(icon: Icons.business_outlined, title: 'Tipo de empresa', value: p.tipoEmpresa.label, onTap: _tipoEmpresa)
              else
                ListRow(icon: p.veiculo.icon, title: 'Veículo', value: p.veiculo.label, onTap: _veiculo),
              ListRow(
                icon: Icons.recycling_rounded,
                title: 'Materiais recolhidos',
                subtitle: p.materiais.isEmpty
                    ? 'Nenhum'
                    : categorias.where((c) => p.materiais.contains(c.id)).map((c) => c.curto).join(', '),
                onTap: () => _chips<CategoriaId>(
                  title: 'Materiais recolhidos',
                  subtitle: 'Você só recebe pedidos destes materiais.',
                  opcoes: CategoriaId.values,
                  rotulo: (id) => categorias.firstWhere((c) => c.id == id).nome,
                  atuais: p.materiais,
                  salvar: (s) => coleta.atualizar(() => p.materiais = s),
                ),
              ),
              ListRow(
                icon: Icons.map_outlined,
                title: 'Área de atendimento',
                subtitle: '${p.bairros.length} bairros',
                onTap: () => _chips<String>(
                  title: 'Área de atendimento',
                  subtitle: 'Bairros onde você faz coleta.',
                  opcoes: ColetaState.todosBairros,
                  rotulo: (b) => b,
                  atuais: p.bairros,
                  salvar: (s) => coleta.atualizar(() => p.bairros = s),
                ),
              ),
            ]),
            const SizedBox(height: 22),
            const SectionLabel('Preferências'),
            GroupCard(children: [
              SwitchListTile(
                value: p.notificacoes,
                activeColor: AppColors.primary,
                onChanged: (v) => coleta.atualizar(() => p.notificacoes = v),
                secondary: const IconBox(icon: Icons.notifications_none_rounded),
                title: Text('Avisar novos pedidos', style: AppText.bodyStrong),
              ),
              SwitchListTile(
                value: p.ressocializacao,
                activeColor: AppColors.primary,
                onChanged: (v) => coleta.atualizar(() => p.ressocializacao = v),
                secondary: const IconBox(icon: Icons.groups_outlined),
                title: Text('Selo de ressocialização', style: AppText.bodyStrong),
              ),
              ListRow(icon: Icons.info_outline_rounded, title: 'Sobre o EcoScan', onTap: _sobre),
            ]),
            const SizedBox(height: 16),
            EcoButton(
              label: 'Sair da conta',
              icon: Icons.logout_rounded,
              kind: BtnKind.danger,
              onPressed: () {
                sessao.sair();
                Navigator.of(context).pushAndRemoveUntil(fadeRoute(const LoginScreen()), (_) => false);
              },
            ),
          ]),
        );
      },
    );
  }

  Widget _stat(String n, String l) => Expanded(
        child: Column(children: [
          Text(n, style: AppText.t(20, FontWeight.w700, AppColors.primary)),
          const SizedBox(height: 2),
          Text(l, style: AppText.caption.copyWith(fontSize: 12)),
        ]),
      );
}
