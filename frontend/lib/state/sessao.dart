import 'package:flutter/material.dart';

import 'app_state.dart';
import 'coleta_state.dart';

enum Papel { usuario, coletador, empresa }

extension PapelInfo on Papel {
  String get label => switch (this) {
        Papel.usuario => 'Usuário',
        Papel.coletador => 'Coletador',
        Papel.empresa => 'Empresa',
      };

  String get titulo => switch (this) {
        Papel.usuario => 'Quero descartar',
        Papel.coletador => 'Faço coletas',
        Papel.empresa => 'Sou uma empresa de coleta',
      };

  String get descricao => switch (this) {
        Papel.usuario =>
          'Recebo orientação e peço a coleta dos meus resíduos',
        Papel.coletador =>
          'Busco resíduos com meu veículo e levo ao destino certo',
        Papel.empresa =>
          'Cooperativa ou empresa com equipe de coleta',
      };

  IconData get icon => switch (this) {
        Papel.usuario => Icons.person_outline_rounded,
        Papel.coletador => Icons.local_shipping_outlined,
        Papel.empresa => Icons.business_outlined,
      };
}

class Conta {
  Conta({
    this.id,
    required this.nome,
    required this.email,
    this.senha = '',
    required this.papel,
    this.telefone = '',
  });

  final int? id;
  String nome;
  String email;
  String senha;
  String telefone;
  final Papel papel;
}

class Sessao extends ChangeNotifier {
  static const senhaDemo = '123456';

  final List<Conta> contas = [
    Conta(
      nome: 'Diego Prestes',
      email: 'usuario@ecoscan.app',
      senha: senhaDemo,
      papel: Papel.usuario,
      telefone: '(91) 9 8888-0000',
    ),
    Conta(
      nome: 'João Batista',
      email: 'coletador@ecoscan.app',
      senha: senhaDemo,
      papel: Papel.coletador,
      telefone: '(91) 9 8222-3333',
    ),
    Conta(
      nome: 'Cooperativa Recicla Pará',
      email: 'empresa@ecoscan.app',
      senha: senhaDemo,
      papel: Papel.empresa,
      telefone: '(91) 3200-0000',
    ),
  ];

  Conta? atual;

  String? token;
  int? usuarioId;

  bool get autenticado => atual != null && token != null;

  Conta? contaDemo(Papel papel) {
    for (final conta in contas) {
      if (conta.papel == papel && conta.senha == senhaDemo) {
        return conta;
      }
    }

    return null;
  }

  Conta? entrar(String email, String senha) {
    final emailNormalizado = email.trim().toLowerCase();

    for (final conta in contas) {
      if (conta.email.toLowerCase() == emailNormalizado &&
          conta.senha == senha) {
        token = null;
        usuarioId = null;
        _abrir(conta);
        return conta;
      }
    }

    return null;
  }

  void abrirAutenticada({
    required Map<String, dynamic> usuario,
    required String accessToken,
    String telefone = '',
  }) {
    final papelTexto = usuario['papel']?.toString();

    final papel = Papel.values.firstWhere(
      (p) => p.name == papelTexto,
      orElse: () => Papel.usuario,
    );

    final conta = Conta(
      id: usuario['id'] is int
          ? usuario['id'] as int
          : int.tryParse(usuario['id']?.toString() ?? ''),
      nome: usuario['nome']?.toString() ?? '',
      email: usuario['email']?.toString() ?? '',
      papel: papel,
      telefone: telefone,
    );

    token = accessToken;
    usuarioId = conta.id;

    _abrir(conta);
  }

  void cadastrar(Conta conta) {
    contas.removeWhere(
      (x) => x.email.toLowerCase() == conta.email.toLowerCase(),
    );

    contas.add(conta);
    token = null;
    usuarioId = null;
    _abrir(conta);
  }

  void _abrir(Conta conta) {
    atual = conta;

    if (conta.papel == Papel.usuario) {
      app.carregarConta(conta);

      if (autenticado) {
        app.carregarHistoricoRemoto();
      } else {
        app.limparHistoricoRemoto();
      }
    } else {
      app.limparHistoricoRemoto();
      coleta.usarPerfil(conta.email);
    }

    notifyListeners();
  }

  void sair() {
    atual = null;
    token = null;
    usuarioId = null;

    app.limparHistoricoRemoto();

    notifyListeners();
  }
}

final sessao = Sessao();