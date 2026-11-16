import 'package:ecoscan/core/core.dart';
import 'package:flutter/material.dart';

import '../state/coleta_state.dart';
import '../state/sessao.dart';
import 'rotas.dart';

import '../services/auth_service.dart';


/// Cadastro em 2 passos:
/// 1) a pessoa escolhe o papel: Usuário, Coletador ou Empresa;
/// 2) preenche o formulário daquele papel e a conta é criada nele.
class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});
  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  int _passo = 1;
  Papel _papel = Papel.usuario;

  // Comuns
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _tel = TextEditingController();
  final _doc = TextEditingController();
  // Coletador e empresa
  TipoEmpresa _tipoEmpresa = TipoEmpresa.cooperativa;
  Veiculo _veiculo = Veiculo.triciclo;
  final Set<CategoriaId> _materiais = {CategoriaId.diaADia, CategoriaId.eletronicos};
  bool _ressocializacao = false;

  @override
  void dispose() {
    for (final c in [_nome, _email, _senha, _tel, _doc]) {
      c.dispose();
    }
    super.dispose();
  }

  void _voltar() {
    if (_passo == 2) {
      setState(() => _passo = 1);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _criar() async {
    final coleta_ = _papel != Papel.usuario;
    if (_nome.text.trim().length < 2) {
      return toast(context, _papel == Papel.empresa ? 'Digite o nome da empresa' : 'Digite seu nome');
    }
    if (coleta_ && _doc.text.replaceAll(RegExp(r'\D'), '').length < 11) {
      return toast(context, _papel == Papel.empresa ? 'Digite o CNPJ' : 'Digite o CPF');
    }
    if (coleta_ && _tel.text.replaceAll(RegExp(r'\D'), '').length < 10) return toast(context, 'Digite o telefone com DDD');
    if (!_email.text.contains('@')) return toast(context, 'Digite um e-mail válido');
    if (_senha.text.length < 6) return toast(context, 'A senha precisa ter 6 caracteres ou mais');
    if (coleta_ && _materiais.isEmpty) return toast(context, 'Escolha pelo menos um tipo de material');

    final email = _email.text.trim().toLowerCase();
    if (coleta_) {
      coleta.registrar(PerfilColeta(
        nome: _nome.text.trim(),
        papel: _papel,
        email: email,
        telefone: _tel.text.trim(),
        documento: _doc.text.trim(),
        tipoEmpresa: _tipoEmpresa,
        veiculo: _veiculo,
        materiais: {..._materiais},
        bairros: {'Nazaré', 'Umarizal', 'São Brás'},
        ressocializacao: _ressocializacao,
      ));
    }
    try {
  await AuthService(
    baseUrl: 'http://192.168.100.10:3004',
  ).cadastrar(
    nome: _nome.text.trim(),
    email: email,
    senha: _senha.text,
  );
} catch (erro) {
  if (!mounted) return;
  toast(context, 'Não foi possível criar a conta. Verifique a conexão.');
  return;
}

if (!mounted) return;
    sessao.cadastrar(Conta(nome: _nome.text.trim(), email: email, senha: _senha.text, papel: _papel, telefone: _tel.text.trim()));
    toast(context, switch (_papel) {
      Papel.usuario => 'Conta criada! Bem-vindo ao EcoScan',
      Papel.coletador => 'Cadastro de coletador concluído!',
      Papel.empresa => 'Empresa cadastrada! Agora adicione sua equipe',
    });
    Navigator.of(context).pushAndRemoveUntil(fadeRoute(inicioDoPapel(_papel)), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _passo == 1,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _passo = 1);
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Row(children: [
                CircleBtn(icon: Icons.arrow_back_rounded, onTap: _voltar),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Passo $_passo de 2', style: AppText.t(12, FontWeight.w500, AppColors.muted)),
                    Text(_passo == 1 ? 'Criar conta' : 'Cadastro · ${_papel.label}',
                        style: AppText.t(17, FontWeight.w700, AppColors.ink)),
                  ]),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
              child: ProgressSegments(total: 2, done: _passo),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _passo == 1 ? _escolha() : _formulario(),
              ),
            ),
            ActionBar(children: [
              if (_passo == 1)
                EcoButton(label: 'Continuar como ${_papel.label.toLowerCase()}', onPressed: () => setState(() => _passo = 2))
              else ...[
                EcoButton(
                  label: switch (_papel) {
                    Papel.usuario => 'Criar conta de usuário',
                    Papel.coletador => 'Criar conta de coletador',
                    Papel.empresa => 'Criar conta da empresa',
                  },
                  onPressed: _criar,
                ),
                const SizedBox(height: 10),
                Text('Ao continuar, você aceita os Termos e a Privacidade.',
                    textAlign: TextAlign.center, style: AppText.t(12, FontWeight.w400, AppColors.muted)),
              ],
            ]),
          ]),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- Passo 1
  Widget _escolha() => ListView(key: const ValueKey(1), padding: const EdgeInsets.fromLTRB(24, 24, 24, 24), children: [
        Text('Como você vai usar o EcoScan?', style: AppText.display),
        const SizedBox(height: 6),
        Text('Cada perfil tem as suas funções. Você escolhe uma vez, no cadastro.',
            style: AppText.caption.copyWith(fontSize: 15)),
        const SizedBox(height: 22),
        for (final p in Papel.values) ...[
          _OpcaoPapel(papel: p, selecionado: _papel == p, onTap: () => setState(() => _papel = p)),
          const SizedBox(height: 12),
        ],
      ]);

  // ---------------------------------------------------------------- Passo 2
  Widget _formulario() {
    final coleta_ = _papel != Papel.usuario;
    final empresa = _papel == Papel.empresa;
    return ListView(key: ValueKey('form-$_papel'), padding: const EdgeInsets.fromLTRB(24, 20, 24, 24), children: [
      Row(children: [
        IconBox(icon: _papel.icon, size: 44, active: true),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_papel.titulo, style: AppText.t(16, FontWeight.w700, AppColors.ink)),
            Text(_papel.descricao, style: AppText.caption),
          ]),
        ),
        TextButton(onPressed: () => setState(() => _passo = 1), child: const Text('Trocar')),
      ]),
      const SizedBox(height: 20),
      if (empresa) ...[
        _rotulo('Tipo de empresa'),
        Segmented(
          options: [for (final t in TipoEmpresa.values) t.label],
          selected: _tipoEmpresa.index,
          onChanged: (i) => setState(() => _tipoEmpresa = TipoEmpresa.values[i]),
        ),
        const SizedBox(height: 18),
      ],
      _rotulo(empresa ? 'Dados da empresa' : 'Seus dados'),
      AppField(label: empresa ? 'Nome da empresa' : 'Nome completo', icon: Icons.badge_outlined, controller: _nome),
      if (coleta_) ...[
        const SizedBox(height: 12),
        AppField(label: empresa ? 'CNPJ' : 'CPF', icon: Icons.numbers_rounded, controller: _doc, keyboard: TextInputType.number),
        const SizedBox(height: 12),
        AppField(label: 'Telefone com DDD', icon: Icons.phone_outlined, controller: _tel, keyboard: TextInputType.phone),
      ],
      const SizedBox(height: 12),
      AppField(label: 'E-mail', icon: Icons.mail_outline_rounded, controller: _email, keyboard: TextInputType.emailAddress),
      const SizedBox(height: 12),
      AppField(label: 'Senha', hint: 'Mínimo de 6 caracteres', icon: Icons.lock_outline_rounded, controller: _senha, obscure: true),
      if (_papel == Papel.coletador) ...[
        const SizedBox(height: 22),
        _rotulo('Qual veículo você usa?'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final v in Veiculo.values)
            ChoiceChip(
              label: Text(v.label),
              avatar: Icon(v.icon, size: 18, color: _veiculo == v ? Colors.white : AppColors.primary),
              selected: _veiculo == v,
              showCheckmark: false,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              side: BorderSide(color: _veiculo == v ? AppColors.primary : AppColors.line),
              labelStyle: AppText.t(13, FontWeight.w600, _veiculo == v ? Colors.white : AppColors.ink),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (_) => setState(() => _veiculo = v),
            ),
        ]),
        const SizedBox(height: 8),
        Text(_veiculo.grande ? 'Você poderá levar volumosos e entulho.' : 'Volumosos e entulho vão aparecer com aviso de veículo.',
            style: AppText.caption.copyWith(fontSize: 12)),
      ],
      if (coleta_) ...[
        const SizedBox(height: 22),
        _rotulo(empresa ? 'Quais materiais vocês recolhem?' : 'Quais materiais você recolhe?'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final c in categorias)
            FilterChip(
              label: Text(c.nome),
              avatar: Icon(c.icon, size: 18, color: _materiais.contains(c.id) ? Colors.white : AppColors.primary),
              selected: _materiais.contains(c.id),
              showCheckmark: false,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              side: BorderSide(color: _materiais.contains(c.id) ? AppColors.primary : AppColors.line),
              labelStyle: AppText.t(13, FontWeight.w600, _materiais.contains(c.id) ? Colors.white : AppColors.ink),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (v) => setState(() => v ? _materiais.add(c.id) : _materiais.remove(c.id)),
            ),
        ]),
        const SizedBox(height: 8),
        Text('Você só recebe pedidos desses materiais.', style: AppText.caption.copyWith(fontSize: 12)),
        const SizedBox(height: 18),
        SoftCard(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: SwitchListTile(
            value: _ressocializacao,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _ressocializacao = v),
            title: Text('Projeto de ressocialização', style: AppText.bodyStrong),
            subtitle: Text(
                empresa
                    ? 'Nossa equipe inclui pessoas em ressocialização. O selo aparece para os usuários.'
                    : 'Participo de um projeto de ressocialização. O selo aparece para os usuários.',
                style: AppText.caption),
          ),
        ),
      ],
    ]);
  }

  Widget _rotulo(String t) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(t, style: AppText.label));
}

class _OpcaoPapel extends StatelessWidget {
  const _OpcaoPapel({required this.papel, required this.selecionado, required this.onTap});
  final Papel papel;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final itens = switch (papel) {
      Papel.usuario => ['Foto e orientação de descarte', 'Mapa de pontos de descarte', 'Pedir coleta e Hall da Fama'],
      Papel.coletador => ['Pedidos perto de você', 'Rota até o local', 'Aviso se o pedido não cabe no veículo'],
      Papel.empresa => ['Pedidos da sua região', 'Equipe de coletadores', 'Escolhe quem faz cada coleta'],
    };
    return GestureDetector(
      onTap: onTap,
      child: SoftCard(
        border: selecionado ? AppColors.primary : null,
        color: selecionado ? AppColors.accentSoft : null,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            IconBox(icon: papel.icon, size: 44, active: selecionado),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(papel.label, style: AppText.t(16, FontWeight.w700, AppColors.ink)),
                Text(papel.titulo, style: AppText.caption),
              ]),
            ),
            RadioDot(on: selecionado),
          ]),
          const SizedBox(height: 10),
          for (final i in itens)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 56),
              child: Row(children: [
                Icon(Icons.check_rounded, size: 15, color: selecionado ? AppColors.primary : AppColors.muted),
                const SizedBox(width: 6),
                Expanded(child: Text(i, style: AppText.t(13, FontWeight.w500, AppColors.ink))),
              ]),
            ),
        ]),
      ),
    );
  }
}
