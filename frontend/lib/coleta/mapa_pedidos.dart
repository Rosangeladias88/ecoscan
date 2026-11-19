import 'package:ecoscan/core/core.dart';
import 'package:flutter/material.dart';

import '../data/pontos.dart';
import '../state/coleta_state.dart';
import 'pedido_detalhe.dart';
import 'pedidos.dart';

/// Mapa de quem coleta, com localização em tempo real.
/// - Pedidos: novos (âmbar) e aceitos (verde) da região.
/// - Pontos de descarte (só EMPRESA): ver, cadastrar e remover pontos no mapa.
class MapaPedidosScreen extends StatefulWidget {
  const MapaPedidosScreen({super.key});
  @override
  State<MapaPedidosScreen> createState() => _MapaPedidosScreenState();
}

class _MapaPedidosScreenState extends State<MapaPedidosScreen> {
  final _mapa = MapController();
  bool _pronto = false;
  int _modo = 0; // 0 pedidos · 1 pontos (empresa)
  int _filtro = 0; // 0 todos · 1 novos · 2 aceitos
  String? _sel;
  bool _escolhendoLocal = false;

  @override
  void initState() {
    super.initState();
    localizacao.iniciar();
  }

  void _centralizar(LatLng p, [double zoom = 15]) {
    if (_pronto) _mapa.move(p, zoom);
  }

  // ---------------------------------------------------------------- Pontos (empresa)
  Future<void> _confirmarLocal() async {
    final local = _pronto ? _mapa.camera.center : (localizacao.posicao ?? coleta.sede);
    final perfil = coleta.perfil;
    final nome = TextEditingController();
    final endereco = TextEditingController();
    final horario = TextEditingController(text: 'Seg a sex · 8h às 17h');
    // Começa marcando os materiais que a empresa recolhe
    final aceita = <String>{
      for (final r in residuos)
        if (perfil.materiais.contains(r.categoria)) r.id,
    };
    final ok = await showEcoSheet<bool>(context, title: 'Novo ponto de descarte', subtitle: 'Ele aparece na hora no mapa dos usuários.', children: [
      AppField(label: 'Nome do ponto', hint: 'Ex.: Ecoponto da cooperativa', icon: Icons.place_outlined, controller: nome),
      AppField(label: 'Endereço', hint: 'Rua, número · bairro', icon: Icons.location_on_outlined, controller: endereco),
      AppField(label: 'Horário', icon: Icons.schedule_rounded, controller: horario),
      Text('Materiais que o ponto recebe', style: AppText.label),
      StatefulBuilder(
        builder: (ctx, setS) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final c in categorias) ...[
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 6),
              child: Row(children: [
                Icon(c.icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(c.nome, style: AppText.t(13, FontWeight.w700, AppColors.ink)),
              ]),
            ),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final r in residuosDa(c.id))
                FilterChip(
                  label: Text(r.nome),
                  selected: aceita.contains(r.id),
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  side: BorderSide(color: aceita.contains(r.id) ? AppColors.primary : AppColors.line),
                  labelStyle: AppText.t(12, FontWeight.w600, aceita.contains(r.id) ? Colors.white : AppColors.ink),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  visualDensity: VisualDensity.compact,
                  onSelected: (v) => setS(() => v ? aceita.add(r.id) : aceita.remove(r.id)),
                ),
            ]),
          ],
        ]),
      ),
      Builder(builder: (ctx) => EcoButton(label: 'Publicar ponto', icon: Icons.add_location_alt_outlined, onPressed: () => Navigator.of(ctx).pop(true))),
    ]);
    final n = nome.text.trim(), e = endereco.text.trim(), h = horario.text.trim();
    nome.dispose();
    endereco.dispose();
    horario.dispose();
    if (ok != true || !mounted) return;
    if (n.length < 3) return toast(context, 'Dê um nome ao ponto');
    if (aceita.isEmpty) return toast(context, 'Escolha pelo menos um material');
    final p = pontos.adicionar(
      nome: n,
      endereco: e.isEmpty ? 'Endereço não informado' : e,
      horario: h.isEmpty ? 'Horário não informado' : h,
      posicao: local,
      aceita: aceita.toList(),
      empresa: perfil.nome,
      tipoEmpresa: perfil.tipoEmpresa.label,
    );
    setState(() {
      _escolhendoLocal = false;
      _sel = p.id;
    });
    toast(context, 'Ponto publicado: os usuários já veem no mapa');
  }

  Future<void> _detalhesPonto(PontoDescarte p) async {
    setState(() => _sel = p.id);
    final meu = p.criadoPor == coleta.perfil.nome;
    final remover = await showEcoSheet<bool>(context, title: p.nome, subtitle: p.tipo, children: [
      InfoRows([
        (Icons.location_on_outlined, p.endereco),
        (Icons.schedule_rounded, p.horario),
        (Icons.recycling_rounded, p.aceita.map((id) => residuoPorId(id).nome).join(', ')),
      ]),
      if (meu)
        Builder(
          builder: (ctx) => EcoButton(
            label: 'Remover ponto',
            icon: Icons.delete_outline_rounded,
            kind: BtnKind.danger,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        )
      else
        Text(p.exemplo ? 'Ponto de exemplo da demonstração.' : 'Cadastrado por ${p.criadoPor}.',
            style: AppText.caption, textAlign: TextAlign.center),
    ]);
    if (!mounted) return;
    if (remover == true) {
      final ok = await showConfirmSheet(
        context,
        title: 'Remover "${p.nome}"?',
        subtitle: 'O ponto sai do mapa dos usuários.',
        confirm: 'Remover',
        destructive: true,
      );
      if (ok) {
        pontos.remover(p.id);
        if (mounted) toast(context, 'Ponto removido');
      }
    }
    if (mounted) setState(() => _sel = null);
  }

  // ---------------------------------------------------------------- Tela
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([coleta, pontos, localizacao]),
      builder: (context, _) {
        final empresa = coleta.perfil.empresa;
        final modoPontos = empresa && _modo == 1;
        final visiveis = switch (_filtro) {
          1 => coleta.novos,
          2 => coleta.aceitos,
          _ => [...coleta.novos, ...coleta.aceitos],
        };
        final sel = _sel == null ? null : coleta.porId(_sel!);
        final selVisivel = !modoPontos && sel != null && visiveis.contains(sel) ? sel : null;
        final meusPontos = pontos.daEmpresa(coleta.perfil.nome);

        final marcadores = <Marker>[
          if (!localizacao.ativa) ecoPin(ponto: coleta.sede, icon: Icons.warehouse_outlined, cor: AppColors.ink),
          if (!modoPontos)
            for (final p in visiveis)
              ecoPin(
                ponto: p.posicao,
                icon: p.icon,
                cor: p.status == StatusPedido.enviado ? AppColors.warn : AppColors.primary,
                selecionado: _sel == p.id,
                onTap: () {
                  setState(() => _sel = p.id);
                  _centralizar(p.posicao, 14.5);
                },
              )
          else if (!_escolhendoLocal)
            for (final p in pontos.todos)
              ecoPin(
                ponto: p.posicao,
                icon: p.icon,
                cor: p.criadoPor == coleta.perfil.nome ? AppColors.leafDark : AppColors.muted,
                selecionado: _sel == p.id,
                onTap: () => _detalhesPonto(p),
              ),
        ];

        return Stack(children: [
          Positioned.fill(
            child: EcoMapa(
              controller: _mapa,
              centro: localizacao.posicao ?? coleta.sede,
              zoom: 13.2,
              onPronto: () => _pronto = true,
              onTapMapa: () => setState(() => _sel = null),
              marcadores: marcadores,
            ),
          ),
          // Mira central ao escolher o local de um novo ponto
          if (_escolhendoLocal)
            const IgnorePointer(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 44),
                  child: Icon(Icons.location_on, size: 52, color: AppColors.leafDark, shadows: [Shadow(color: Color(0x55000000), blurRadius: 8)]),
                ),
              ),
            ),
          // Topo
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), boxShadow: AppShadows.soft),
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (_escolhendoLocal) ...[
                    Text('Onde fica o ponto?', style: AppText.t(16, FontWeight.w700, AppColors.ink)),
                    const SizedBox(height: 2),
                    Text('Arraste o mapa até o pino ficar em cima do local.', style: AppText.caption),
                  ] else ...[
                    Row(children: [
                      Expanded(
                        child: Text(modoPontos ? 'Pontos de descarte' : 'Pedidos na sua região',
                            style: AppText.t(16, FontWeight.w700, AppColors.ink)),
                      ),
                      if (!modoPontos) ...[
                        _legenda(AppColors.warn, 'Novo'),
                        const SizedBox(width: 10),
                        _legenda(AppColors.primary, 'Aceito'),
                      ] else ...[
                        _legenda(AppColors.leafDark, 'Seus'),
                        const SizedBox(width: 10),
                        _legenda(AppColors.muted, 'Outros'),
                      ],
                    ]),
                    Row(children: [
                      Icon(localizacao.ativa ? Icons.my_location_rounded : Icons.location_disabled_outlined,
                          size: 12, color: localizacao.ativa ? const Color(0xFF2F7DE1) : AppColors.muted),
                      const SizedBox(width: 4),
                      Text(localizacao.mensagem, style: AppText.caption.copyWith(fontSize: 12)),
                    ]),
                    const SizedBox(height: 10),
                    if (empresa) ...[
                      Segmented(
                        options: const ['Pedidos', 'Pontos de descarte'],
                        selected: _modo,
                        onChanged: (i) => setState(() {
                          _modo = i;
                          _sel = null;
                        }),
                      ),
                      if (!modoPontos) const SizedBox(height: 8),
                    ],
                    if (!modoPontos)
                      Segmented(
                        options: const ['Todos', 'Novos', 'Aceitos'],
                        selected: _filtro,
                        onChanged: (i) => setState(() {
                          _filtro = i;
                          _sel = null;
                        }),
                      ),
                  ],
                ]),
              ),
            ),
          ),
          ),
          // Botão "minha localização"
          Positioned(
            right: 16,
            bottom: _escolhendoLocal ? 180 : 150,
            child: BotaoMinhaLocalizacao(onCentralizar: (p) => _centralizar(p)),
          ),
          // Rodapé
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (c, a) => FadeTransition(
                opacity: a,
                child: SlideTransition(position: Tween(begin: const Offset(0, 0.2), end: Offset.zero).animate(a), child: c),
              ),
              child: _rodape(context, modoPontos, visiveis.length, meusPontos.length, selVisivel),
            ),
          ),
        ]);
      },
    );
  }

  Widget _rodape(BuildContext context, bool modoPontos, int nPedidos, int nMeusPontos, PedidoColeta? sel) {
    if (_escolhendoLocal) {
      return Container(
        key: const ValueKey('escolher'),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), boxShadow: AppShadows.soft),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          EcoButton(label: 'Confirmar local', icon: Icons.check_rounded, onPressed: _confirmarLocal),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: EcoButton(
                label: 'Meu local',
                icon: Icons.my_location_rounded,
                kind: BtnKind.secondary,
                compact: true,
                onPressed: () async {
                  if (localizacao.posicao == null) await localizacao.iniciar();
                  final p = localizacao.posicao;
                  if (p != null) {
                    _centralizar(p, 17);
                  } else if (context.mounted) {
                    toast(context, localizacao.mensagem);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: EcoButton(
                label: 'Cancelar',
                kind: BtnKind.text,
                compact: true,
                onPressed: () => setState(() => _escolhendoLocal = false),
              ),
            ),
          ]),
        ]),
      );
    }
    if (modoPontos) {
      return Container(
        key: const ValueKey('pontos'),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), boxShadow: AppShadows.soft),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(
            nMeusPontos == 0
                ? 'Sua empresa ainda não tem pontos no mapa.'
                : '$nMeusPontos ${nMeusPontos == 1 ? 'ponto seu' : 'pontos seus'} no mapa · toque em um para ver ou remover',
            style: AppText.t(13, FontWeight.w500, AppColors.ink),
          ),
          const SizedBox(height: 10),
          EcoButton(
            label: 'Adicionar ponto de descarte',
            icon: Icons.add_location_alt_outlined,
            onPressed: () {
              setState(() {
                _escolhendoLocal = true;
                _sel = null;
              });
              final p = localizacao.posicao;
              if (p != null) _centralizar(p, 16);
            },
          ),
        ]),
      );
    }
    if (sel != null) {
      return CardPedido(
        key: ValueKey(sel.id),
        p: sel,
        onTap: () => Navigator.of(context).push(slideRoute(PedidoDetalheScreen(id: sel.id))),
        acoes: [
          ('Ver pedido', BtnKind.primary, () => Navigator.of(context).push(slideRoute(PedidoDetalheScreen(id: sel.id)))),
        ],
      );
    }
    return Container(
      key: const ValueKey('dica'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: AppShadows.soft),
      child: Row(children: [
        const Icon(Icons.touch_app_outlined, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text('$nPedidos pedidos no mapa · toque em um pino para ver', style: AppText.t(13, FontWeight.w500, AppColors.ink)),
        ),
      ]),
    );
  }

  Widget _legenda(Color c, String t) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(t, style: AppText.t(11, FontWeight.w600, AppColors.muted)),
      ]);
}
