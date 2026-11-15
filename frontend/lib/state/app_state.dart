import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:ecoscan/core/core.dart';

import '../data/pontos.dart';
import 'coleta_state.dart';
import 'sessao.dart';

class Consulta {
  final Residuo residuo;
  final DateTime data;
  final Uint8List? foto;
  Consulta(this.residuo, this.data, [this.foto]);
}

class Pedido {
  final String id;
  final String titulo;
  final IconData icon;
  final Residuo? residuo;
  final Uint8List? foto;
  final String quantidade;
  final String endereco;
  final String data;
  final String periodo;
  final String obs;
  final DateTime criado;
  StatusPedido status;
  String? prestador;
  bool selo = true; // selo de ressocialização de quem aceitou

  Pedido({
    required this.id,
    required this.titulo,
    required this.icon,
    this.residuo,
    this.foto,
    required this.quantidade,
    required this.endereco,
    required this.data,
    required this.periodo,
    this.obs = '',
    required this.criado,
    this.status = StatusPedido.enviado,
    this.prestador,
  });
}

class ItemHistorico {
  final String titulo;
  final String subtitulo;
  final IconData icon;
  final DateTime data;
  final Pedido? pedido;
  final Residuo? residuo;
  final Uint8List? foto;
  ItemHistorico({
    required this.titulo,
    required this.subtitulo,
    required this.icon,
    required this.data,
    this.pedido,
    this.residuo,
    this.foto,
  });
  bool get isColeta => pedido != null;
}

/// Estado da área do USUÁRIO (quem descarta). Só frontend, sem servidor.
/// A área de quem coleta (coletador e empresa) fica em coleta_state.dart.
class AppState extends ChangeNotifier {
  String nome = 'Diego Prestes';
  String email = 'diego.prestes@email.com';
  String telefone = '(91) 9 8888-0000';
  String bairro = 'Nazaré, Belém';
  String endereco = 'Rua das Mangueiras, 120 · Nazaré';
  String nomePrestador = 'Cooperativa Recicla Pará';
  String telefonePrestador = '(91) 3200-0000';
  Uint8List? fotoPerfil;

  // Notificações (Perfil → Notificações)
  bool notifStatus = true;
  bool notifDicas = true;
  bool notifNovidades = false;

  final List<Consulta> consultas = [];
  final List<Pedido> pedidos = [];

  // Consulta em andamento (Passo 1 → 3)
  Uint8List? fotoAtual;
  Residuo? residuoAtual;
  bool _consultaSalva = false;

  int _seq = 2489;

  AppState() {
    final now = DateTime.now();
    consultas.addAll([
      Consulta(residuoPorId('celular'), now.subtract(const Duration(days: 1))),
      Consulta(residuoPorId('pilhas'), now.subtract(const Duration(days: 14))),
    ]);
    pedidos.addAll([
      Pedido(
        id: 'ECO-2471',
        titulo: 'Colchão',
        icon: Icons.bed_outlined,
        residuo: residuoPorId('colchao'),
        quantidade: '1 colchão',
        endereco: endereco,
        data: '28 out',
        periodo: 'Manhã',
        criado: now.subtract(const Duration(days: 11)),
        status: StatusPedido.concluido,
        prestador: nomePrestador,
      ),
      Pedido(
        id: 'ECO-2477',
        titulo: 'Lâmpadas',
        icon: Icons.lightbulb_outline,
        residuo: residuoPorId('lampadas'),
        quantidade: '4 lâmpadas',
        endereco: endereco,
        data: 'Sex',
        periodo: 'Tarde',
        criado: now.subtract(const Duration(days: 3)),
      ),
    ]);
  }

  String get primeiroNome => nome.trim().split(' ').first;

  /// "Diego P."
  String get nomeCurto {
    final p = nome.trim().split(RegExp(r'\s+'));
    return p.length == 1 ? p.first : '${p.first} ${p.last[0]}.';
  }
  String get iniciais {
    final p = nome.trim().split(RegExp(r'\s+'));
    if (p.length == 1) return p.first.substring(0, 1).toUpperCase();
    return (p.first[0] + p.last[0]).toUpperCase();
  }

  // ---------- Conta
  void carregarConta(Conta c) {
    nome = c.nome;
    email = c.email;
    if (c.telefone.isNotEmpty) telefone = c.telefone;
    notifyListeners();
  }

  // [API acesso] mutation atualizarUsuario(input)
  void atualizarDados({required String nome, required String email, required String telefone, required String endereco}) {
    if (nome.trim().isNotEmpty) this.nome = nome.trim();
    if (email.contains('@')) this.email = email.trim();
    this.telefone = telefone.trim();
    if (endereco.trim().isNotEmpty) this.endereco = endereco.trim();
    notifyListeners();
  }

  // [API fotos] upload da foto de perfil → URL salva na conta
  void definirFotoPerfil(Uint8List? bytes) {
    fotoPerfil = bytes;
    notifyListeners();
  }

  void definirNotificacoes({bool? status, bool? dicas, bool? novidades}) {
    notifStatus = status ?? notifStatus;
    notifDicas = dicas ?? notifDicas;
    notifNovidades = novidades ?? notifNovidades;
    notifyListeners();
  }

  // ---------- Consulta
  void iniciarConsulta() {
    fotoAtual = null;
    residuoAtual = null;
    _consultaSalva = false;
  }

  // [API fotos] upload da foto do resíduo → fotoId usado na consulta e no pedido
  void definirFoto(Uint8List? bytes) {
    fotoAtual = bytes;
    notifyListeners();
  }

  void escolherResiduo(Residuo r) {
    residuoAtual = r;
    _consultaSalva = false;
    notifyListeners();
  }

  // [API consultas] mutation registrarConsulta(residuoId, fotoId?)
  void salvarConsulta() {
    if (residuoAtual == null || _consultaSalva) return;
    consultas.add(Consulta(residuoAtual!, DateTime.now(), fotoAtual));
    _consultaSalva = true;
    notifyListeners();
  }

  // ---------- Coleta
  // [API consultas] mutation solicitarColeta(input) → pedido com id e status "enviado"
  Pedido criarPedido({
    required Residuo residuo,
    required String quantidade,
    required String endereco,
    required String data,
    required String periodo,
    String obs = '',
  }) {
    _consultaSalva = true; // a coleta já aparece no histórico
    this.endereco = endereco;
    final p = Pedido(
      id: 'ECO-${++_seq}',
      titulo: residuo.nome,
      icon: residuo.icon,
      residuo: residuo,
      foto: fotoAtual,
      quantidade: quantidade,
      endereco: endereco,
      data: data,
      periodo: periodo,
      obs: obs,
      criado: DateTime.now(),
    );
    pedidos.add(p);
    notifyListeners();
    // O pedido aparece para coletadores e empresas (mesmo app, outra conta).
    coleta.receberDoUsuario(PedidoColeta(
      id: p.id,
      titulo: p.titulo,
      icon: p.icon,
      residuoId: residuo.id,
      solicitante: nomeCurto,
      tipoSolicitante: 'Usuário · ${bairro.split(',').first}',
      telefone: telefone,
      quantidade: quantidade,
      endereco: endereco,
      data: data,
      periodo: periodo,
      obs: obs,
      posicao: posicaoUsuario,
      criado: p.criado,
    ));
    return p;
  }

  Pedido? pedidoPorId(String id) {
    for (final p in pedidos) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Quem coleta aceitou ou concluiu um pedido deste usuário.
  // [API consultas] com backend: query pedido(id) / subscription statusDoPedido(id)
  void atualizarPedidoDoUsuario(String id, StatusPedido status, String quem, String telefone, bool selo) {
    final p = pedidoPorId(id);
    if (p == null) return;
    p.status = status;
    p.prestador = quem;
    p.selo = selo;
    telefonePrestador = telefone;
    notifyListeners();
  }

  // ---------- Histórico (só do usuário)
  // [API histórico] query historico(usuarioId) → consultas + coletas
  List<ItemHistorico> get historico {
    final itens = <ItemHistorico>[
      for (final c in consultas)
        ItemHistorico(
          titulo: c.residuo.nome,
          subtitulo: 'Consulta · ${dataCurta(c.data)}',
          icon: c.residuo.icon,
          data: c.data,
          residuo: c.residuo,
          foto: c.foto,
        ),
      for (final p in pedidos)
        ItemHistorico(
          titulo: p.titulo,
          subtitulo: 'Coleta · ${dataCurta(p.criado)}',
          icon: p.icon,
          data: p.criado,
          pedido: p,
          residuo: p.residuo,
          foto: p.foto,
        ),
    ];
    itens.sort((a, b) => b.data.compareTo(a.data));
    return itens;
  }

  int get totalColetas => pedidos.length;

  /// Descartes do usuário no período (0 semana · 1 mês · 2 geral) — usado no Hall da Fama.
  int descartesNoPeriodo(int periodo) {
    final dias = switch (periodo) { 0 => 7, 1 => 30, _ => 100000 };
    final limite = DateTime.now().subtract(Duration(days: dias));
    final c = consultas.where((x) => x.data.isAfter(limite)).length;
    final p = pedidos.where((x) => x.criado.isAfter(limite)).length;
    return c + p;
  }
}

final app = AppState();
