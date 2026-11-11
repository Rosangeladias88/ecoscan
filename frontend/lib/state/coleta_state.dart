import 'package:ecoscan/core/core.dart';
import 'package:flutter/material.dart';

import 'app_state.dart';
import 'sessao.dart';

enum TipoEmpresa { cooperativa, empresa }

extension TipoEmpresaLabel on TipoEmpresa {
  String get label => switch (this) {
        TipoEmpresa.cooperativa => 'Cooperativa',
        TipoEmpresa.empresa => 'Empresa de coleta',
      };
}

/// Veículo do coletador (ou de alguém da equipe da empresa).
enum Veiculo { carrinho, triciclo, moto, carro, caminhao }

extension VeiculoInfo on Veiculo {
  String get label => switch (this) {
        Veiculo.carrinho => 'Carrinho de mão',
        Veiculo.triciclo => 'Bicicleta ou triciclo',
        Veiculo.moto => 'Moto',
        Veiculo.carro => 'Carro ou caminhonete',
        Veiculo.caminhao => 'Caminhão',
      };
  IconData get icon => switch (this) {
        Veiculo.carrinho => Icons.shopping_cart_outlined,
        Veiculo.triciclo => Icons.pedal_bike_outlined,
        Veiculo.moto => Icons.two_wheeler_outlined,
        Veiculo.carro => Icons.directions_car_outlined,
        Veiculo.caminhao => Icons.local_shipping_outlined,
      };

  /// Só carro/caminhonete e caminhão levam volumosos e entulho.
  bool get grande => this == Veiculo.carro || this == Veiculo.caminhao;
}

class MembroEquipe {
  MembroEquipe(this.nome, this.telefone, this.veiculo);
  String nome;
  String telefone;
  Veiculo veiculo;
}

/// Perfil de quem coleta: coletador (pessoa) ou empresa.
class PerfilColeta {
  PerfilColeta({
    required this.nome,
    required this.papel,
    required this.email,
    required this.telefone,
    required this.documento,
    this.tipoEmpresa = TipoEmpresa.cooperativa,
    this.veiculo = Veiculo.triciclo,
    required this.materiais,
    required this.bairros,
    this.ressocializacao = false,
    List<MembroEquipe>? equipe,
  }) : equipe = equipe ?? [];

  String nome;
  final Papel papel;
  String email;
  String telefone;
  String documento;
  TipoEmpresa tipoEmpresa;
  Veiculo veiculo;
  Set<CategoriaId> materiais;
  Set<String> bairros;
  bool ressocializacao;
  bool notificacoes = true;
  final List<MembroEquipe> equipe;

  bool get empresa => papel == Papel.empresa;
  String get tipoLabel => empresa ? tipoEmpresa.label : 'Coletador';
  String get docLabel => empresa ? 'CNPJ' : 'CPF';
  String get iniciais => iniciaisDe(nome);
}

/// Pedido de coleta, visto por quem coleta.
class PedidoColeta {
  PedidoColeta({
    required this.id,
    required this.titulo,
    required this.icon,
    this.residuoId,
    required this.solicitante,
    required this.tipoSolicitante,
    required this.telefone,
    required this.quantidade,
    required this.endereco,
    required this.data,
    required this.periodo,
    this.obs = '',
    required this.posicao,
    required this.criado,
    this.status = StatusPedido.enviado,
    this.aceitoPor,
    this.responsavel,
    this.concluidoEm,
  });

  final String id;
  final String titulo;
  final IconData icon;
  final String? residuoId;
  final String solicitante;
  final String tipoSolicitante;
  final String telefone;
  final String quantidade;
  final String endereco;
  final String data;
  final String periodo;
  final String obs;
  final LatLng posicao;
  final DateTime criado;
  StatusPedido status;
  String? aceitoPor; // nome do coletador ou da empresa
  String? responsavel; // pessoa da equipe (só empresa)
  DateTime? concluidoEm;
  final Set<String> recusadoPor = {}; // perfis que recusaram (outros ainda veem)

  Residuo? get residuo => residuoId == null ? null : residuoPorId(residuoId!);
  String get categoria => residuo?.cat.nome ?? 'Outros';
  bool get volumoso => residuo?.categoria == CategoriaId.volumosos || residuoId == 'entulho' || residuoId == 'pneus';
}

/// Estado da área de COLETA (coletador e empresa). Só frontend.
class ColetaState extends ChangeNotifier {
  static const todosBairros = [
    'Nazaré', 'Umarizal', 'Batista Campos', 'São Brás', 'Marco', 'Cidade Velha',
    'Reduto', 'Pedreira', 'Guamá', 'Jurunas', 'Cremação', 'Marambaia',
  ];

  /// Sede / ponto de partida usado para calcular distâncias.
  final LatLng sede = const LatLng(-1.4400, -48.4760);

  /// Perfis por e-mail (inclui os de demonstração).
  final Map<String, PerfilColeta> perfis = {
    'coletador@ecoscan.app': PerfilColeta(
      nome: 'João Batista',
      papel: Papel.coletador,
      email: 'coletador@ecoscan.app',
      telefone: '(91) 9 8222-3333',
      documento: '123.456.789-00',
      veiculo: Veiculo.triciclo,
      materiais: {CategoriaId.diaADia, CategoriaId.eletronicos, CategoriaId.especificos},
      bairros: {'Nazaré', 'São Brás', 'Marco', 'Umarizal'},
      ressocializacao: true,
    ),
    'empresa@ecoscan.app': PerfilColeta(
      nome: 'Cooperativa Recicla Pará',
      papel: Papel.empresa,
      email: 'empresa@ecoscan.app',
      telefone: '(91) 3200-0000',
      documento: '12.345.678/0001-90',
      tipoEmpresa: TipoEmpresa.cooperativa,
      materiais: {...CategoriaId.values},
      bairros: {'Nazaré', 'Umarizal', 'Batista Campos', 'São Brás', 'Marco', 'Cidade Velha'},
      ressocializacao: true,
      equipe: [
        MembroEquipe('Raimundo Silva', '(91) 9 8444-1111', Veiculo.caminhao),
        MembroEquipe('Ana Costa', '(91) 9 8555-2222', Veiculo.triciclo),
        MembroEquipe('Carlos Lima', '(91) 9 8666-3333', Veiculo.carro),
      ],
    ),
  };

  late PerfilColeta perfil = perfis['empresa@ecoscan.app']!;

  final List<PedidoColeta> pedidos = [];

  ColetaState() {
    final agora = DateTime.now();
    pedidos.addAll([
      PedidoColeta(
        id: 'ECO-2482',
        titulo: 'Óleo de cozinha usado',
        icon: Icons.water_drop_outlined,
        residuoId: 'oleo',
        solicitante: 'Lúcia M.',
        tipoSolicitante: 'Usuário · São Brás',
        telefone: '(91) 9 8777-4444',
        quantidade: '3 garrafas PET (≈ 6 L)',
        endereco: 'Tv. 14 de Março, 1200 · São Brás',
        data: 'Amanhã',
        periodo: 'Manhã',
        obs: 'Deixar na portaria do prédio',
        posicao: const LatLng(-1.4492, -48.4732),
        criado: agora.subtract(const Duration(minutes: 40)),
      ),
      PedidoColeta(
        id: 'ECO-2479',
        titulo: 'Resíduos de açougue',
        icon: Icons.set_meal_outlined,
        solicitante: 'Box 14',
        tipoSolicitante: 'Comerciante · Ver-o-Peso',
        telefone: '(91) 9 8111-2222',
        quantidade: 'Retirada recorrente',
        endereco: 'Mercado Ver-o-Peso · Cidade Velha',
        data: 'Hoje',
        periodo: 'Tarde',
        posicao: const LatLng(-1.4528, -48.5030),
        criado: agora.subtract(const Duration(hours: 2)),
      ),
      PedidoColeta(
        id: 'ECO-2478',
        titulo: 'Embalagens de cosméticos',
        icon: Icons.inventory_2_outlined,
        solicitante: 'Loja parceira',
        tipoSolicitante: 'Comércio · Batista Campos',
        telefone: '(91) 3222-4444',
        quantidade: '3 caixas de embalagens vazias',
        endereco: 'Av. Gentil Bittencourt, 1500 · Batista Campos',
        data: 'Quinta',
        periodo: 'Tarde',
        posicao: const LatLng(-1.4580, -48.4870),
        criado: agora.subtract(const Duration(hours: 5)),
      ),
      PedidoColeta(
        id: 'ECO-2477',
        titulo: 'Lâmpadas',
        icon: Icons.lightbulb_outline,
        residuoId: 'lampadas',
        solicitante: 'Diego P.',
        tipoSolicitante: 'Usuário · Nazaré',
        telefone: '(91) 9 8888-0000',
        quantidade: '4 lâmpadas',
        endereco: 'Rua das Mangueiras, 120 · Nazaré',
        data: 'Sexta',
        periodo: 'Tarde',
        posicao: const LatLng(-1.4527, -48.4812),
        criado: agora.subtract(const Duration(days: 3)),
      ),
      PedidoColeta(
        id: 'ECO-2476',
        titulo: 'Entulho',
        icon: Icons.construction,
        residuoId: 'entulho',
        solicitante: 'Paulo R.',
        tipoSolicitante: 'Usuário · Pedreira',
        telefone: '(91) 9 8999-5555',
        quantidade: '6 sacos de ráfia',
        endereco: 'Passagem Mirandinha, 45 · Pedreira',
        data: 'Sábado',
        periodo: 'Manhã',
        posicao: const LatLng(-1.4385, -48.4735),
        criado: agora.subtract(const Duration(hours: 8)),
      ),
      PedidoColeta(
        id: 'ECO-2475',
        titulo: 'Sofá',
        icon: Icons.weekend_outlined,
        residuoId: 'sofa',
        solicitante: 'Marina S.',
        tipoSolicitante: 'Usuário · Umarizal',
        telefone: '(91) 9 8333-4444',
        quantidade: '1 sofá de 3 lugares',
        endereco: 'Tv. Dom Romualdo de Seixas, 800 · Umarizal',
        data: 'Sexta',
        periodo: 'Manhã',
        obs: 'Apartamento no 2º andar, sem elevador',
        posicao: const LatLng(-1.4455, -48.4890),
        criado: agora.subtract(const Duration(days: 1)),
        status: StatusPedido.aceito,
        aceitoPor: 'Cooperativa Recicla Pará',
        responsavel: 'Raimundo Silva',
      ),
      PedidoColeta(
        id: 'ECO-2474',
        titulo: 'Cabos',
        icon: Icons.cable,
        residuoId: 'cabos',
        solicitante: 'Fernanda R.',
        tipoSolicitante: 'Usuário · Marco',
        telefone: '(91) 9 8123-9876',
        quantidade: '1 pacote',
        endereco: 'Av. Duque de Caxias, 900 · Marco',
        data: 'Hoje',
        periodo: 'Tarde',
        posicao: const LatLng(-1.4335, -48.4675),
        criado: agora.subtract(const Duration(hours: 20)),
        status: StatusPedido.aceito,
        aceitoPor: 'João Batista',
      ),
      PedidoColeta(
        id: 'ECO-2471',
        titulo: 'Colchão',
        icon: Icons.bed_outlined,
        residuoId: 'colchao',
        solicitante: 'Diego P.',
        tipoSolicitante: 'Usuário · Nazaré',
        telefone: '(91) 9 8888-0000',
        quantidade: '1 colchão de solteiro',
        endereco: 'Rua das Mangueiras, 120 · Nazaré',
        data: '28 out',
        periodo: 'Manhã',
        posicao: const LatLng(-1.4510, -48.4790),
        criado: agora.subtract(const Duration(days: 12)),
        status: StatusPedido.concluido,
        aceitoPor: 'Cooperativa Recicla Pará',
        responsavel: 'Raimundo Silva',
        concluidoEm: agora.subtract(const Duration(days: 11)),
      ),
      PedidoColeta(
        id: 'ECO-2468',
        titulo: 'Pilhas e baterias',
        icon: Icons.battery_full,
        residuoId: 'pilhas',
        solicitante: 'Escola parceira',
        tipoSolicitante: 'Usuário · Marco',
        telefone: '(91) 3233-5555',
        quantidade: '2 potes',
        endereco: 'Av. Duque de Caxias · Marco',
        data: '24 out',
        periodo: 'Tarde',
        posicao: const LatLng(-1.4320, -48.4660),
        criado: agora.subtract(const Duration(days: 17)),
        status: StatusPedido.concluido,
        aceitoPor: 'João Batista',
        concluidoEm: agora.subtract(const Duration(days: 16)),
      ),
    ]);
  }

  // ---------- Perfil
  void usarPerfil(String email) {
    final p = perfis[email.toLowerCase()];
    if (p != null) perfil = p;
    notifyListeners();
  }

  // [API acesso] junto com cadastrarConta: dados de coletador/empresa (CPF/CNPJ, veículo, materiais, ressocialização)
  void registrar(PerfilColeta p) {
    perfis[p.email.toLowerCase()] = p;
    perfil = p;
    notifyListeners();
  }

  // [API acesso] mutation atualizarPerfilColeta(input) — veículo, materiais, bairros, equipe
  void atualizar(VoidCallback mudanca) {
    mudanca();
    notifyListeners();
  }

  // ---------- Listas (cada perfil vê os seus)
  bool _atendeMaterial(PedidoColeta p) => p.residuo == null || perfil.materiais.contains(p.residuo!.categoria);

  List<PedidoColeta> _ordenar(Iterable<PedidoColeta> l) =>
      l.toList()..sort((a, b) => (b.concluidoEm ?? b.criado).compareTo(a.concluidoEm ?? a.criado));

  /// Pedidos novos dos materiais que este perfil recolhe.
  // [API consultas] query pedidosDisponiveis(materiais, bairros) — filtrado pelo servidor
  List<PedidoColeta> get novos => _ordenar(pedidos.where(
      (p) => p.status == StatusPedido.enviado && _atendeMaterial(p) && !p.recusadoPor.contains(perfil.nome)));
  List<PedidoColeta> get aceitos => _ordenar(pedidos.where((p) => p.status == StatusPedido.aceito && p.aceitoPor == perfil.nome));
  // [API histórico] query coletasConcluidas(perfilId)
  List<PedidoColeta> get concluidos => _ordenar(pedidos.where((p) => p.status == StatusPedido.concluido && p.aceitoPor == perfil.nome));

  int get concluidasNoMes {
    final limite = DateTime.now().subtract(const Duration(days: 30));
    return concluidos.where((p) => p.concluidoEm?.isAfter(limite) ?? false).length;
  }

  PedidoColeta? porId(String id) {
    for (final p in pedidos) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Distância a partir de onde a pessoa está (GPS) ou, sem GPS, da sede.
  double distancia(PedidoColeta p) => distanciaKm(localizacao.posicao ?? sede, p.posicao);
  String get origemDistancia => localizacao.ativa ? 'de você' : 'da sede';

  /// Coletador com veículo pequeno não leva volumosos/entulho/pneus.
  bool cabeNoVeiculo(PedidoColeta p) => perfil.empresa || !p.volumoso || perfil.veiculo.grande;

  int emAndamentoCom(String membro) => aceitos.where((p) => p.responsavel == membro).length;

  // ---------- Ações
  // [API consultas] mutation aceitarPedido(pedidoId, responsavel?) — o servidor avisa o usuário
  void aceitar(PedidoColeta p, {String? responsavel}) {
    p.status = StatusPedido.aceito;
    p.aceitoPor = perfil.nome;
    p.responsavel = responsavel;
    notifyListeners();
    app.atualizarPedidoDoUsuario(p.id, StatusPedido.aceito, perfil.nome, perfil.telefone, perfil.ressocializacao);
  }

  // [API consultas] mutation recusarPedido(pedidoId)
  void recusar(PedidoColeta p) {
    // Recusar só tira o pedido da lista deste perfil (outros ainda podem aceitar).
    p.recusadoPor.add(perfil.nome);
    notifyListeners();
  }

  // [API consultas] mutation concluirPedido(pedidoId)
  void concluir(PedidoColeta p) {
    p.status = StatusPedido.concluido;
    p.concluidoEm = DateTime.now();
    notifyListeners();
    app.atualizarPedidoDoUsuario(p.id, StatusPedido.concluido, perfil.nome, perfil.telefone, perfil.ressocializacao);
  }

  /// Pedido feito por um usuário no app → aparece para quem coleta.
  // [API consultas] com backend, some: novos pedidos chegam por pedidosDisponiveis (ou subscription)
  void receberDoUsuario(PedidoColeta p) {
    pedidos.add(p);
    notifyListeners();
  }
}

final coleta = ColetaState();
