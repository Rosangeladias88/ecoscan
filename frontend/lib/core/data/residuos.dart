import 'package:flutter/material.dart';

enum CategoriaId { volumosos, eletronicos, diaADia, especificos }

class Categoria {
  final CategoriaId id;
  final String nome;
  final String curto;
  final IconData icon;
  const Categoria(this.id, this.nome, this.curto, this.icon);
}

class Residuo {
  final String id;
  final String nome;
  final CategoriaId categoria;
  final IconData icon;
  final List<String> passos;
  final String alerta;
  final String destino;
  final String destinoDetalhe;
  final String unidade; // usado na quantidade da coleta
  final bool coletavel; // false = entrega em ponto específico (ex.: farmácia)
  const Residuo({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.icon,
    required this.passos,
    required this.alerta,
    required this.destino,
    required this.destinoDetalhe,
    this.unidade = 'unidade',
    this.coletavel = true,
  });

  Categoria get cat => categorias.firstWhere((c) => c.id == categoria);
}

const categorias = <Categoria>[
  Categoria(CategoriaId.volumosos, 'Volumosos', 'Volumosos', Icons.weekend_outlined),
  Categoria(CategoriaId.eletronicos, 'Eletrônicos', 'Eletrônicos', Icons.smartphone_outlined),
  Categoria(CategoriaId.diaADia, 'Do dia a dia', 'Dia a dia', Icons.water_drop_outlined),
  Categoria(CategoriaId.especificos, 'Outros específicos', 'Específicos', Icons.lightbulb_outline),
];

// [API materiais] query materiais → categorias, resíduos e orientações (editados no painel React)
const residuos = <Residuo>[
  // ---------- Volumosos
  Residuo(
    id: 'colchao',
    nome: 'Colchão',
    categoria: CategoriaId.volumosos,
    icon: Icons.bed_outlined,
    passos: ['Veja se ainda pode ser doado', 'Proteja da chuva até a retirada', 'Solicite a coleta de volumosos'],
    alerta: 'Não deixe na calçada ou em terrenos baldios',
    destino: 'Espuma, molas e tecido reaproveitados',
    destinoDetalhe: 'Recebido por cooperativas parceiras',
    unidade: 'colchão',
  ),
  Residuo(
    id: 'travesseiro',
    nome: 'Travesseiro',
    categoria: CategoriaId.volumosos,
    icon: Icons.king_bed_outlined,
    passos: ['Se estiver em bom estado, lave e doe', 'Guarde em saco fechado e seco', 'Entregue ou solicite a retirada'],
    alerta: 'Não misture com lixo úmido ou orgânico',
    destino: 'Enchimento vira estofamento ou manta',
    destinoDetalhe: 'Recebido por cooperativas parceiras',
    unidade: 'travesseiro',
  ),
  Residuo(
    id: 'sofa',
    nome: 'Sofá',
    categoria: CategoriaId.volumosos,
    icon: Icons.weekend_outlined,
    passos: ['Veja se pode ser doado ou reformado', 'Retire almofadas e objetos soltos', 'Solicite a coleta de volumosos'],
    alerta: 'Não abandone em vias públicas',
    destino: 'Madeira, espuma e tecido separados',
    destinoDetalhe: 'Recebido por cooperativas parceiras',
    unidade: 'sofá',
  ),
  Residuo(
    id: 'moveis',
    nome: 'Móveis quebrados',
    categoria: CategoriaId.volumosos,
    icon: Icons.chair_outlined,
    passos: ['Retire vidros e espelhos com cuidado', 'Desmonte as peças, se possível', 'Solicite a retirada'],
    alerta: 'Vidros quebrados devem ir bem embrulhados',
    destino: 'Madeira e metal reaproveitados',
    destinoDetalhe: 'Recebido por cooperativas parceiras',
    unidade: 'móvel',
  ),
  // ---------- Eletrônicos
  Residuo(
    id: 'celular',
    nome: 'Celular',
    categoria: CategoriaId.eletronicos,
    icon: Icons.smartphone_outlined,
    passos: ['Faça backup e apague seus dados', 'Retire o chip e o cartão de memória', 'Entregue em ponto de eletrônicos ou solicite a coleta'],
    alerta: 'Não jogue no lixo comum: contém metais pesados',
    destino: 'Metais e plásticos recuperados',
    destinoDetalhe: 'Logística reversa de eletrônicos',
    unidade: 'aparelho',
  ),
  Residuo(
    id: 'cabos',
    nome: 'Cabos',
    categoria: CategoriaId.eletronicos,
    icon: Icons.cable,
    passos: ['Junte e amarre os cabos', 'Separe de outros resíduos', 'Entregue em ponto de eletrônicos'],
    alerta: 'Nunca queime fios para retirar o cobre',
    destino: 'Cobre e plástico reciclados',
    destinoDetalhe: 'Logística reversa de eletrônicos',
    unidade: 'pacote',
  ),
  Residuo(
    id: 'carregadores',
    nome: 'Carregadores',
    categoria: CategoriaId.eletronicos,
    icon: Icons.power_outlined,
    passos: ['Desconecte da tomada e do aparelho', 'Junte com os cabos, se houver', 'Entregue em ponto de eletrônicos'],
    alerta: 'Carregadores estufados ou quentes: não use mais',
    destino: 'Componentes e metais recuperados',
    destinoDetalhe: 'Logística reversa de eletrônicos',
    unidade: 'carregador',
  ),
  Residuo(
    id: 'pilhas',
    nome: 'Pilhas e baterias',
    categoria: CategoriaId.eletronicos,
    icon: Icons.battery_full,
    passos: ['Guarde em pote plástico fechado', 'Isole os polos das baterias com fita', 'Entregue em coletor de lojas ou supermercados'],
    alerta: 'Nunca jogue no lixo comum ou no fogo',
    destino: 'Metais tratados pelos fabricantes',
    destinoDetalhe: 'Logística reversa obrigatória',
    unidade: 'pote',
  ),
  // ---------- Do dia a dia
  Residuo(
    id: 'oleo',
    nome: 'Óleo de cozinha usado',
    categoria: CategoriaId.diaADia,
    icon: Icons.water_drop_outlined,
    passos: ['Espere o óleo esfriar', 'Guarde em garrafa PET fechada', 'Entregue ou solicite a coleta'],
    alerta: 'Nunca jogue na pia ou no ralo',
    destino: 'Vira sabão ou biodiesel',
    destinoDetalhe: 'Recebido por cooperativas parceiras',
    unidade: 'garrafa',
  ),
  Residuo(
    id: 'roupas',
    nome: 'Roupas',
    categoria: CategoriaId.diaADia,
    icon: Icons.checkroom_outlined,
    passos: ['Separe o que ainda pode ser usado', 'Lave e dobre as peças', 'Doe ou solicite a coleta têxtil'],
    alerta: 'Peças molhadas mofam e perdem o reaproveitamento',
    destino: 'Doação ou reciclagem têxtil',
    destinoDetalhe: 'Cooperativas e projetos sociais',
    unidade: 'sacola',
  ),
  Residuo(
    id: 'retalhos',
    nome: 'Retalhos',
    categoria: CategoriaId.diaADia,
    icon: Icons.content_cut,
    passos: ['Separe por tipo de tecido, se possível', 'Guarde em saco limpo e seco', 'Entregue a cooperativas ou ateliês'],
    alerta: 'Não misture com lixo úmido',
    destino: 'Vira artesanato, enchimento ou fio',
    destinoDetalhe: 'Cooperativas e ateliês parceiros',
    unidade: 'sacola',
  ),
  // ---------- Outros específicos
  Residuo(
    id: 'pneus',
    nome: 'Pneus',
    categoria: CategoriaId.especificos,
    icon: Icons.trip_origin,
    passos: ['Não deixe acumular água', 'Guarde em local coberto', 'Leve a borracharias ou solicite a coleta'],
    alerta: 'Água parada no pneu vira criadouro do mosquito da dengue',
    destino: 'Vira asfalto, piso ou combustível',
    destinoDetalhe: 'Pontos de coleta de pneus',
    unidade: 'pneu',
  ),
  Residuo(
    id: 'lampadas',
    nome: 'Lâmpadas',
    categoria: CategoriaId.especificos,
    icon: Icons.lightbulb_outline,
    passos: ['Embale na caixa original ou em jornal', 'Evite quebrar: algumas têm mercúrio', 'Entregue em ponto de coleta de lâmpadas'],
    alerta: 'Se quebrar, ventile o ambiente e não use aspirador',
    destino: 'Vidro, metal e mercúrio separados',
    destinoDetalhe: 'Logística reversa de lâmpadas',
    unidade: 'lâmpada',
  ),
  Residuo(
    id: 'medicamentos',
    nome: 'Medicamentos vencidos',
    categoria: CategoriaId.especificos,
    icon: Icons.medication_outlined,
    passos: ['Mantenha nas embalagens originais', 'Separe as caixas de papel para reciclagem', 'Entregue em farmácias com coletor'],
    alerta: 'Nunca jogue na pia, no vaso ou no lixo comum',
    destino: 'Descarte controlado e seguro',
    destinoDetalhe: 'Coletores em farmácias',
    unidade: 'sacola',
    coletavel: false,
  ),
  Residuo(
    id: 'entulho',
    nome: 'Entulho',
    categoria: CategoriaId.especificos,
    icon: Icons.construction,
    passos: ['Separe entulho de madeira e gesso', 'Use sacos de ráfia resistentes', 'Solicite a retirada'],
    alerta: 'Descarte irregular pode gerar multa',
    destino: 'Vira agregado reciclado para obras',
    destinoDetalhe: 'Empresas de coleta parceiras',
    unidade: 'saco',
  ),
];

List<Residuo> residuosDa(CategoriaId id) => residuos.where((r) => r.categoria == id).toList();
Residuo residuoPorId(String id) => residuos.firstWhere((r) => r.id == id);
