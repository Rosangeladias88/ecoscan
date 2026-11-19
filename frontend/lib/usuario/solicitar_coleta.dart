import 'package:flutter/material.dart';
import 'package:ecoscan/core/core.dart';

import '../state/app_state.dart';
import 'acompanhar.dart';

/// Figma: "v2 Solicitar coleta" — cada linha abre um painel (Sheet · ...).
class SolicitarColetaScreen extends StatefulWidget {
  const SolicitarColetaScreen({super.key, required this.residuo});
  final Residuo residuo;
  @override
  State<SolicitarColetaScreen> createState() => _SolicitarColetaScreenState();
}

const _diasSemana = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
const _mesesCurtos = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
const _periodos = ['Manhã · 8h às 12h', 'Tarde · 13h às 17h'];

String plural(String u, int n) {
  if (n == 1) return '1 $u';
  final p = switch (u) {
    'pneu' => 'pneus',
    'saco' => 'sacos',
    'pote' => 'potes',
    'sofá' => 'sofás',
    'móvel' => 'móveis',
    'colchão' => 'colchões',
    'lâmpada' => 'lâmpadas',
    'aparelho' => 'aparelhos',
    'carregador' => 'carregadores',
    _ => '${u}s',
  };
  return '$n $p';
}

class _SolicitarColetaScreenState extends State<SolicitarColetaScreen> {
  int _qtd = 1;
  late final _rua = TextEditingController(text: app.endereco);
  final _compl = TextEditingController();
  final _obs = TextEditingController();
  int _dia = 1; // índice em _datas
  int _periodo = 0;
  bool _enviando = false;

  late final List<String> _datas = [
    'Hoje',
    'Amanhã',
    _rotuloData(DateTime.now().add(const Duration(days: 2))),
    _rotuloData(DateTime.now().add(const Duration(days: 3))),
  ];

  static String _rotuloData(DateTime d) => '${_diasSemana[d.weekday - 1]}, ${d.day} ${_mesesCurtos[d.month - 1]}';

  @override
  void dispose() {
    _rua.dispose();
    _compl.dispose();
    _obs.dispose();
    super.dispose();
  }

  String get _qtdTxt => plural(widget.residuo.unidade, _qtd);
  String get _enderecoTxt => _compl.text.trim().isEmpty ? _rua.text.trim() : '${_rua.text.trim()} · ${_compl.text.trim()}';

  Future<void> _quantidade() async {
    final u = widget.residuo.unidade;
    final v = await showCounterSheet(
      context,
      title: 'Quantidade',
      subtitle: 'Quanto de ${widget.residuo.nome.toLowerCase()}?',
      value: _qtd,
      label: (n) => plural(u, n),
      hint: u == 'garrafa' ? (n) => '≈ ${n * 2} litros' : null,
    );
    if (v != null) setState(() => _qtd = v);
  }

  Future<void> _endereco() async {
    final antes = (_rua.text, _compl.text);
    final ok = await showFieldsSheet(context, title: 'Endereço de retirada', confirm: 'Salvar endereço', fields: [
      AppField(label: 'Rua, número e bairro', icon: Icons.location_on_outlined, controller: _rua),
      AppField(label: 'Complemento', hint: 'Apto, bloco, referência', icon: Icons.info_outline_rounded, controller: _compl),
    ]);
    if (!ok || _rua.text.trim().isEmpty) {
      _rua.text = antes.$1;
      _compl.text = antes.$2;
    }
    setState(() {});
  }

  Future<void> _data() async {
    final i = await showOptionsSheet(context, title: 'Quando retirar?', options: _datas, selected: _dia);
    if (i != null) setState(() => _dia = i);
  }

  Future<void> _periodoSheet() async {
    final i = await showOptionsSheet(context, title: 'Qual período?', options: _periodos, selected: _periodo);
    if (i != null) setState(() => _periodo = i);
  }

  Future<void> _observacao() async {
    final antes = _obs.text;
    final ok = await showFieldsSheet(
      context,
      title: 'Observação',
      subtitle: 'Ajude quem vai coletar a encontrar o resíduo.',
      fields: [AppField(label: 'Ex.: deixar na portaria', icon: Icons.notes_rounded, controller: _obs)],
    );
    if (!ok) _obs.text = antes;
    setState(() {});
  }

  Future<void> _enviar() async {
    setState(() => _enviando = true);
    await Future.delayed(const Duration(milliseconds: 700)); // simula a API de consultas
    if (!mounted) return;
    final p = app.criarPedido(
      residuo: widget.residuo,
      quantidade: _qtdTxt,
      endereco: _enderecoTxt,
      data: _datas[_dia],
      periodo: _periodo == 0 ? 'Manhã' : 'Tarde',
      obs: _obs.text.trim(),
    );
    Navigator.of(context).pushAndRemoveUntil(fadeRoute(AcompanharScreen(pedidoId: p.id)), (r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.residuo;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          const TopBar(title: 'Solicitar coleta'),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(24, 14, 24, 24), children: [
              SoftCard(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  PhotoThumb(bytes: app.fotoAtual, icon: r.icon, size: 48),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(r.nome, style: AppText.bodyStrong),
                      const SizedBox(height: 2),
                      Text(r.cat.nome, style: AppText.caption),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 22),
              const SectionLabel('Detalhes da retirada'),
              GroupCard(children: [
                ListRow(icon: Icons.inventory_2_outlined, title: 'Quantidade', value: _qtdTxt, onTap: _quantidade),
                ListRow(icon: Icons.location_on_outlined, title: 'Endereço', subtitle: _enderecoTxt, onTap: _endereco),
                ListRow(icon: Icons.calendar_today_outlined, title: 'Data', value: _datas[_dia], onTap: _data),
                ListRow(icon: Icons.schedule_rounded, title: 'Período', value: _periodo == 0 ? 'Manhã' : 'Tarde', onTap: _periodoSheet),
                ListRow(
                  icon: Icons.info_outline_rounded,
                  title: 'Observação',
                  subtitle: _obs.text.trim().isEmpty ? 'Opcional' : _obs.text.trim(),
                  onTap: _observacao,
                ),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                const Icon(Icons.local_shipping_outlined, size: 18, color: AppColors.muted),
                const SizedBox(width: 10),
                Expanded(child: Text('Um coletador ou empresa da região confirma a retirada pelo app.', style: AppText.caption)),
              ]),
            ]),
          ),
          ActionBar(children: [
            _enviando
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5)),
                  )
                : EcoButton(label: 'Enviar solicitação', onPressed: _enviar),
          ]),
        ]),
      ),
    );
  }
}
