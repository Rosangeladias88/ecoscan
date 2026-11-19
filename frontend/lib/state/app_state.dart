import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ecoscan/core/core.dart';

import '../data/pontos.dart';
import '../services/history_service.dart';
import '../services/materials_service.dart';
import '../services/photos_service.dart';
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
  bool selo = true;

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

class AppState extends ChangeNotifier {
  final _photosService = PhotosService();
  final _materialsService = MaterialsService();
  final _historyService = HistoryService();

  String nome = 'Diego Prestes';
  String email = 'diego.prestes@email.com';
  String telefone = '(91) 9 8888-0000';
  String bairro = 'Nazaré, Belém';
  String endereco = 'Rua das Mangueiras, 120 · Nazaré';
  String nomePrestador = 'Cooperativa Recicla Pará';
  String telefonePrestador = '(91) 3200-0000';
  Uint8List? fotoPerfil;

  bool notifStatus = true;
  bool notifDicas = true;
  bool notifNovidades = false;

  final List<Consulta> consultas = [];
  final List<Consulta> consultasRemotas = [];
  final List<Pedido> pedidos = [];

  final Map<int, String> _nomesMateriais = {};

  bool carregandoHistoricoRemoto = false;
  String? erroHistoricoRemoto;

  Uint8List? fotoAtual;
  Residuo? residuoAtual;

  int? _fotoBackendId;
  bool _consultaSalva = false;

  int _seq = 2489;

  AppState() {
    final now = DateTime.now();

    consultas.addAll([
      Consulta(
        residuoPorId('celular'),
        now.subtract(const Duration(days: 1)),
      ),
      Consulta(
        residuoPorId('pilhas'),
        now.subtract(const Duration(days: 14)),
      ),
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

  String get nomeCurto {
    final p = nome.trim().split(RegExp(r'\s+'));
    return p.length == 1 ? p.first : '${p.first} ${p.last[0]}.';
  }

  String get iniciais {
    final p = nome.trim().split(RegExp(r'\s+'));

    if (p.length == 1) {
      return p.first.substring(0, 1).toUpperCase();
    }

    return (p.first[0] + p.last[0]).toUpperCase();
  }

  List<Consulta> get consultasExibidas =>
      sessao.autenticado ? consultasRemotas : consultas;

  void carregarConta(Conta c) {
    nome = c.nome;
    email = c.email;

    if (c.telefone.isNotEmpty) {
      telefone = c.telefone;
    }

    notifyListeners();
  }

  void atualizarDados({
    required String nome,
    required String email,
    required String telefone,
    required String endereco,
  }) {
    if (nome.trim().isNotEmpty) {
      this.nome = nome.trim();
    }

    if (email.contains('@')) {
      this.email = email.trim();
    }

    this.telefone = telefone.trim();

    if (endereco.trim().isNotEmpty) {
      this.endereco = endereco.trim();
    }

    notifyListeners();
  }

  void definirFotoPerfil(Uint8List? bytes) {
    fotoPerfil = bytes;
    notifyListeners();
  }

  void definirNotificacoes({
    bool? status,
    bool? dicas,
    bool? novidades,
  }) {
    notifStatus = status ?? notifStatus;
    notifDicas = dicas ?? notifDicas;
    notifNovidades = novidades ?? notifNovidades;
    notifyListeners();
  }

  void iniciarConsulta() {
    fotoAtual = null;
    residuoAtual = null;
    _fotoBackendId = null;
    _consultaSalva = false;
    notifyListeners();
  }

  void definirFoto(Uint8List? bytes) {
    fotoAtual = bytes;
    _fotoBackendId = null;
    notifyListeners();
  }

  void escolherResiduo(Residuo r) {
    residuoAtual = r;
    _consultaSalva = false;
    notifyListeners();
  }

  void salvarConsulta() {
    if (residuoAtual == null || _consultaSalva) {
      return;
    }

    consultas.add(
      Consulta(residuoAtual!, DateTime.now(), fotoAtual),
    );

    _consultaSalva = true;
    notifyListeners();
  }

  Future<int> _obterMaterialId(Residuo residuo) async {
    if (_nomesMateriais.isEmpty) {
      final materiais = await _materialsService.listarMateriais();

      for (final material in materiais) {
        final id = int.tryParse(material['id']?.toString() ?? '');
        final nome = material['nome']?.toString();

        if (id != null && nome != null) {
          _nomesMateriais[id] = nome;
        }
      }
    }

    final nomeLocal = _normalizar(residuo.nome);

    for (final entrada in _nomesMateriais.entries) {
      if (_normalizar(entrada.value) == nomeLocal) {
        return entrada.key;
      }
    }

    throw Exception(
      'O material "${residuo.nome}" não foi encontrado na API.',
    );
  }

  Residuo? _obterResiduoLocal(String nomeMaterial) {
    final nomeNormalizado = _normalizar(nomeMaterial);

    for (final residuo in residuos) {
      if (_normalizar(residuo.nome) == nomeNormalizado) {
        return residuo;
      }
    }

    return null;
  }

  String _normalizar(String valor) {
    return valor
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[áàâãä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòôõö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll('ç', 'c');
  }

  Future<void> salvarConsultaCompleta() async {
    if (residuoAtual == null || _consultaSalva) {
      return;
    }

    if (!sessao.autenticado) {
      salvarConsulta();
      return;
    }

    if (sessao.atual?.papel != Papel.usuario) {
      throw Exception('Esta função está disponível para contas de usuário.');
    }

    final token = sessao.token;

    if (token == null || token.isEmpty) {
      throw Exception('Sua sessão expirou. Entre novamente.');
    }

    final residuo = residuoAtual!;
    final materialId = await _obterMaterialId(residuo);

    if (fotoAtual != null && _fotoBackendId == null) {
      final respostaFoto = await _photosService.enviarFoto(
        fotoAtual!,
        token: token,
      );

      _fotoBackendId = int.tryParse(
        respostaFoto['id']?.toString() ?? '',
      );

      if (_fotoBackendId == null) {
        throw Exception('A API não retornou o ID da foto enviada.');
      }
    }

    final resposta = await _historyService.criarConsulta(
      token: token,
      materialId: materialId,
      fotografiaId: _fotoBackendId,
    );

    final dataTexto = resposta['criadaEm']?.toString();

    final data = dataTexto != null
        ? DateTime.tryParse(dataTexto) ?? DateTime.now()
        : DateTime.now();

    consultasRemotas.insert(
      0,
      Consulta(residuo, data, fotoAtual),
    );

    _consultaSalva = true;
    erroHistoricoRemoto = null;
    notifyListeners();
  }

  Future<void> carregarHistoricoRemoto() async {
    if (!sessao.autenticado ||
        sessao.atual?.papel != Papel.usuario ||
        carregandoHistoricoRemoto) {
      return;
    }

    final token = sessao.token;

    if (token == null || token.isEmpty) {
      return;
    }

    carregandoHistoricoRemoto = true;
    erroHistoricoRemoto = null;
    notifyListeners();

    try {
      final materiais = await _materialsService.listarMateriais();

      _nomesMateriais.clear();

      for (final material in materiais) {
        final id = int.tryParse(material['id']?.toString() ?? '');
        final nome = material['nome']?.toString();

        if (id != null && nome != null) {
          _nomesMateriais[id] = nome;
        }
      }

      final registros = await _historyService.listarHistorico(token);

      if (sessao.token != token) {
        return;
      }

      final novasConsultas = <Consulta>[];

      for (final registro in registros) {
        final materialId = int.tryParse(
          registro['materialId']?.toString() ?? '',
        );

        if (materialId == null) {
          continue;
        }

        final nomeMaterial = _nomesMateriais[materialId];

        if (nomeMaterial == null) {
          continue;
        }

        final residuo = _obterResiduoLocal(nomeMaterial);

        if (residuo == null) {
          continue;
        }

        final dataTexto = registro['criadaEm']?.toString();

        final data = dataTexto != null
            ? DateTime.tryParse(dataTexto) ?? DateTime.now()
            : DateTime.now();

        novasConsultas.add(
          Consulta(residuo, data),
        );
      }

      consultasRemotas
        ..clear()
        ..addAll(novasConsultas);
    } catch (e) {
      erroHistoricoRemoto = e.toString();
    } finally {
      carregandoHistoricoRemoto = false;
      notifyListeners();
    }
  }

  void limparHistoricoRemoto() {
    consultasRemotas.clear();
    erroHistoricoRemoto = null;
    carregandoHistoricoRemoto = false;
    notifyListeners();
  }

  Pedido criarPedido({
    required Residuo residuo,
    required String quantidade,
    required String endereco,
    required String data,
    required String periodo,
    String obs = '',
  }) {
    _consultaSalva = true;
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

    coleta.receberDoUsuario(
      PedidoColeta(
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
      ),
    );

    return p;
  }

  Pedido? pedidoPorId(String id) {
    for (final p in pedidos) {
      if (p.id == id) {
        return p;
      }
    }

    return null;
  }

  void atualizarPedidoDoUsuario(
    String id,
    StatusPedido status,
    String quem,
    String telefone,
    bool selo,
  ) {
    final p = pedidoPorId(id);

    if (p == null) {
      return;
    }

    p.status = status;
    p.prestador = quem;
    p.selo = selo;
    telefonePrestador = telefone;
    notifyListeners();
  }

  List<ItemHistorico> get historico {
    final itens = <ItemHistorico>[
      for (final c in consultasExibidas)
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

  int descartesNoPeriodo(int periodo) {
    final dias = switch (periodo) {
      0 => 7,
      1 => 30,
      _ => 100000,
    };

    final limite = DateTime.now().subtract(Duration(days: dias));

    final c = consultasExibidas
        .where((x) => x.data.isAfter(limite))
        .length;

    final p = pedidos
        .where((x) => x.criado.isAfter(limite))
        .length;

    return c + p;
  }
}

final app = AppState();