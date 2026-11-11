/// Participantes de exemplo do Hall da Fama (o app é só frontend).
/// Quando houver backend, esta lista vem da API.
class Participante {
  final String nome;
  final String bairro;
  final int semana, mes, geral;
  const Participante(this.nome, this.bairro, this.semana, this.mes, this.geral);

  int descartes(int periodo) => switch (periodo) { 0 => semana, 1 => mes, _ => geral };

  String get iniciais {
    final p = nome.split(' ');
    return (p.first[0] + p.last[0]).toUpperCase();
  }
}

// [Fora das 5 APIs] Hall da Fama: poderia ser calculado pela API de histórico
const participantes = <Participante>[
  Participante('Ana Souza', 'Marco', 4, 14, 48),
  Participante('Carlos Lima', 'Umarizal', 3, 11, 41),
  Participante('Júlia Ramos', 'Batista Campos', 5, 16, 37),
  Participante('Pedro Alves', 'Pedreira', 2, 9, 33),
  Participante('Mariana Costa', 'Nazaré', 3, 12, 29),
  Participante('Rafael Nunes', 'Cremação', 1, 7, 25),
  Participante('Beatriz Melo', 'Guamá', 4, 10, 22),
  Participante('Lucas Pinto', 'Jurunas', 2, 6, 18),
  Participante('Fernanda Reis', 'São Brás', 1, 5, 15),
  Participante('Thiago Rocha', 'Marambaia', 3, 8, 12),
  Participante('Camila Duarte', 'Sacramenta', 0, 3, 9),
];

const periodos = ['Semana', 'Mês', 'Geral'];
