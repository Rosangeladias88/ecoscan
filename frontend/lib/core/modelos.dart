/// Modelos e utilidades usados pelos dois apps.

enum StatusPedido { enviado, aceito, concluido, recusado }

extension StatusLabel on StatusPedido {
  String get label => switch (this) {
        StatusPedido.enviado => 'Pendente',
        StatusPedido.aceito => 'Aceita',
        StatusPedido.concluido => 'Concluída',
        StatusPedido.recusado => 'Recusada',
      };
}

const _meses = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];

/// "hoje", "ontem" ou "4 nov".
String dataCurta(DateTime d) {
  final hoje = DateTime.now();
  final a = DateTime(hoje.year, hoje.month, hoje.day);
  final b = DateTime(d.year, d.month, d.day);
  final diff = a.difference(b).inDays;
  if (diff == 0) return 'hoje';
  if (diff == 1) return 'ontem';
  return '${d.day} ${_meses[d.month - 1]}';
}

/// "4 de nov".
String dataLonga(DateTime d) => '${d.day} de ${_meses[d.month - 1]}';

/// Iniciais de um nome: "Diego Prestes" → "DP".
String iniciaisDe(String nome) {
  final p = nome.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
  if (p.isEmpty) return '?';
  if (p.length == 1) return p.first.substring(0, 1).toUpperCase();
  return (p.first[0] + p.last[0]).toUpperCase();
}
