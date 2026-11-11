import 'package:flutter/material.dart';

import 'app_state.dart';
import 'coleta_state.dart';

/// Os três jeitos de usar o EcoScan, escolhidos no cadastro.
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
        Papel.usuario => 'Recebo orientação e peço a coleta dos meus resíduos',
        Papel.coletador => 'Busco resíduos com meu veículo e levo ao destino certo',
        Papel.empresa => 'Cooperativa ou empresa com equipe de coleta',
      };
  IconData get icon => switch (this) {
        Papel.usuario => Icons.person_outline_rounded,
        Papel.coletador => Icons.local_shipping_outlined,
        Papel.empresa => Icons.business_outlined,
      };
}

class Conta {
  Conta({required this.nome, required this.email, required this.senha, required this.papel, this.telefone = ''});
  String nome;
  String email;
  String senha;
  String telefone;
  final Papel papel;
}

/// Contas e sessão (só frontend: tudo fica na memória do app).
class Sessao extends ChangeNotifier {
  /// Contas de demonstração (senha 123456), uma para cada papel.
  static const senhaDemo = '123456';

  final List<Conta> contas = [
    Conta(nome: 'Diego Prestes', email: 'usuario@ecoscan.app', senha: senhaDemo, papel: Papel.usuario, telefone: '(91) 9 8888-0000'),
    Conta(nome: 'João Batista', email: 'coletador@ecoscan.app', senha: senhaDemo, papel: Papel.coletador, telefone: '(91) 9 8222-3333'),
    Conta(nome: 'Cooperativa Recicla Pará', email: 'empresa@ecoscan.app', senha: senhaDemo, papel: Papel.empresa, telefone: '(91) 3200-0000'),
  ];

  Conta? atual;

  Conta? contaDemo(Papel p) => contas.firstWhere((c) => c.papel == p && c.senha == senhaDemo);

  /// Entra com e-mail e senha. Devolve a conta, ou null se não bater.
  // [API acesso] mutation login(email, senha) → token + conta com papel (usuario | coletador | empresa)
  Conta? entrar(String email, String senha) {
    final e = email.trim().toLowerCase();
    for (final c in contas) {
      if (c.email.toLowerCase() == e && c.senha == senha) {
        _abrir(c);
        return c;
      }
    }
    return null;
  }

  /// Cadastro novo: a conta já entra logada no papel escolhido.
  // [API acesso] mutation cadastrarConta(input) → cria a conta já com o papel escolhido
  void cadastrar(Conta c) {
    contas.removeWhere((x) => x.email.toLowerCase() == c.email.toLowerCase());
    contas.add(c);
    _abrir(c);
  }

  void _abrir(Conta c) {
    atual = c;
    if (c.papel == Papel.usuario) {
      app.carregarConta(c);
    } else {
      coleta.usarPerfil(c.email);
    }
    notifyListeners();
  }

  // [API acesso] apagar o token salvo no aparelho (logout)
  void sair() {
    atual = null;
    notifyListeners();
  }
}

final sessao = Sessao();
