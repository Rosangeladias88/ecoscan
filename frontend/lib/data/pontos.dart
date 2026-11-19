import 'package:ecoscan/core/core.dart';
import 'package:flutter/material.dart';

/// Pontos de descarte. Começam com EXEMPLOS (Belém-PA, nomes genéricos e
/// localização aproximada) e as EMPRESAS podem cadastrar novos pelo mapa.
class PontoDescarte {
  final String id;
  final String nome;
  final String tipo;
  final String endereco;
  final String horario;
  final LatLng posicao;
  final List<String> aceita; // ids de resíduos (data/residuos.dart)
  final IconData icon;
  final String? criadoPor; // empresa que cadastrou (null = exemplo)
  const PontoDescarte({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.endereco,
    required this.horario,
    required this.posicao,
    required this.aceita,
    required this.icon,
    this.criadoPor,
  });

  bool get exemplo => criadoPor == null;

  bool aceitaCategoria(CategoriaId c) => aceita.any((r) => residuoPorId(r).categoria == c);
}

const _exemplos = <PontoDescarte>[
  PontoDescarte(
    id: 'eco-nazare',
    nome: 'Ecoponto Nazaré',
    tipo: 'Ecoponto',
    endereco: 'Av. Nazaré · Nazaré',
    horario: 'Seg a sáb · 8h às 17h',
    posicao: LatLng(-1.4535, -48.4840),
    aceita: ['colchao', 'travesseiro', 'sofa', 'moveis', 'entulho', 'pneus'],
    icon: Icons.recycling_rounded,
  ),
  PontoDescarte(
    id: 'eletro-batista',
    nome: 'Coletor de eletrônicos',
    tipo: 'Shopping · Batista Campos',
    endereco: 'Batista Campos',
    horario: 'Todos os dias · 10h às 22h',
    posicao: LatLng(-1.4590, -48.4905),
    aceita: ['celular', 'cabos', 'carregadores', 'pilhas', 'lampadas'],
    icon: Icons.smartphone_outlined,
  ),
  PontoDescarte(
    id: 'farmacia-umarizal',
    nome: 'Farmácia com coletor',
    tipo: 'Farmácia · Umarizal',
    endereco: 'Umarizal',
    horario: 'Todos os dias · 7h às 22h',
    posicao: LatLng(-1.4440, -48.4880),
    aceita: ['medicamentos'],
    icon: Icons.medication_outlined,
  ),
  PontoDescarte(
    id: 'oleo-saobras',
    nome: 'Ponto de óleo de cozinha',
    tipo: 'Feira · São Brás',
    endereco: 'São Brás',
    horario: 'Ter a dom · 6h às 13h',
    posicao: LatLng(-1.4495, -48.4720),
    aceita: ['oleo'],
    icon: Icons.water_drop_outlined,
  ),
  PontoDescarte(
    id: 'coop-marco',
    nome: 'Cooperativa de reciclagem',
    tipo: 'Cooperativa · Marco',
    endereco: 'Marco',
    horario: 'Seg a sex · 8h às 16h',
    posicao: LatLng(-1.4300, -48.4650),
    aceita: ['roupas', 'retalhos', 'oleo', 'cabos', 'moveis'],
    icon: Icons.groups_outlined,
  ),
  PontoDescarte(
    id: 'pneus-pedreira',
    nome: 'Borracharia parceira',
    tipo: 'Coleta de pneus · Pedreira',
    endereco: 'Pedreira',
    horario: 'Seg a sáb · 7h às 18h',
    posicao: LatLng(-1.4380, -48.4740),
    aceita: ['pneus'],
    icon: Icons.trip_origin,
  ),
  PontoDescarte(
    id: 'eco-guama',
    nome: 'Ecoponto Guamá',
    tipo: 'Ecoponto',
    endereco: 'Guamá',
    horario: 'Seg a sáb · 8h às 17h',
    posicao: LatLng(-1.4700, -48.4650),
    aceita: ['entulho', 'moveis', 'colchao', 'sofa', 'pneus'],
    icon: Icons.recycling_rounded,
  ),
  PontoDescarte(
    id: 'super-umarizal',
    nome: 'Coletor de pilhas e lâmpadas',
    tipo: 'Supermercado · Umarizal',
    endereco: 'Umarizal',
    horario: 'Todos os dias · 7h às 22h',
    posicao: LatLng(-1.4470, -48.4950),
    aceita: ['pilhas', 'lampadas'],
    icon: Icons.battery_full,
  ),
];

/// Lista de pontos compartilhada pelo app inteiro.
// [Fora das 5 APIs] pontos de descarte: com backend, viriam da API de materiais
class PontosState extends ChangeNotifier {
  final List<PontoDescarte> _lista = [..._exemplos];
  int _seq = 0;

  List<PontoDescarte> get todos => List.unmodifiable(_lista);
  List<PontoDescarte> daEmpresa(String nome) => _lista.where((p) => p.criadoPor == nome).toList();

  /// Empresa cadastra um ponto: aparece na hora no mapa dos usuários.
  PontoDescarte adicionar({
    required String nome,
    required String endereco,
    required String horario,
    required LatLng posicao,
    required List<String> aceita,
    required String empresa,
    required String tipoEmpresa,
  }) {
    final p = PontoDescarte(
      id: 'novo-${++_seq}',
      nome: nome,
      tipo: '$tipoEmpresa · $empresa',
      endereco: endereco,
      horario: horario,
      posicao: posicao,
      aceita: aceita,
      icon: Icons.recycling_rounded,
      criadoPor: empresa,
    );
    _lista.add(p);
    notifyListeners();
    return p;
  }

  void remover(String id) {
    _lista.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}

final pontos = PontosState();

/// Posição padrão (Nazaré) quando a localização em tempo real está desligada.
const posicaoPadrao = LatLng(-1.4521, -48.4800);

/// Onde o usuário está agora: GPS em tempo real, ou Nazaré se estiver desligado.
LatLng get posicaoUsuario => localizacao.posicao ?? posicaoPadrao;
