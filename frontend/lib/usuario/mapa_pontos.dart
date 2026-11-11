import 'package:ecoscan/core/core.dart';
import 'package:flutter/material.dart';

import '../data/pontos.dart';

/// Mapa de pontos de descarte com localização em tempo real,
/// filtro por categoria ou por material.
class MapaPontosScreen extends StatefulWidget {
  const MapaPontosScreen({super.key, this.residuo, this.categoria});

  /// Quando vem da Orientação: mostra só os pontos que aceitam este material.
  final Residuo? residuo;
  final CategoriaId? categoria;

  @override
  State<MapaPontosScreen> createState() => _MapaPontosScreenState();
}

class _MapaPontosScreenState extends State<MapaPontosScreen> {
  final _mapa = MapController();
  late CategoriaId? _cat = widget.categoria;
  late Residuo? _residuo = widget.residuo;
  String? _sel;
  bool _pronto = false;
  bool _centralizou = false;

  @override
  void initState() {
    super.initState();
    localizacao.addListener(_aoMudarLocalizacao);
    localizacao.iniciar(); // pede a permissão na primeira vez
  }

  @override
  void dispose() {
    localizacao.removeListener(_aoMudarLocalizacao);
    super.dispose();
  }

  /// Na primeira posição recebida, leva o mapa até você.
  void _aoMudarLocalizacao() {
    final p = localizacao.posicao;
    if (p != null && _pronto && !_centralizou) {
      _centralizou = true;
      _mapa.move(p, 14.5);
    }
  }

  List<PontoDescarte> _visiveis() {
    final l = pontos.todos.where((p) {
      if (_residuo != null) return p.aceita.contains(_residuo!.id);
      if (_cat != null) return p.aceitaCategoria(_cat!);
      return true;
    }).toList();
    l.sort((a, b) => distanciaKm(posicaoUsuario, a.posicao).compareTo(distanciaKm(posicaoUsuario, b.posicao)));
    return l;
  }

  void _selecionar(PontoDescarte p) {
    setState(() => _sel = p.id);
    if (_pronto) _mapa.move(p.posicao, 15);
    _detalhes(p);
  }

  Future<void> _detalhes(PontoDescarte p) async {
    final km = distanciaKm(posicaoUsuario, p.posicao);
    await showEcoSheet<void>(context, title: p.nome, subtitle: '${p.tipo} · ${formatarDistancia(km)}', children: [
      InfoRows([
        (Icons.location_on_outlined, p.endereco),
        (Icons.schedule_rounded, p.horario),
        if (!p.exemplo) (Icons.verified_outlined, 'Cadastrado por ${p.criadoPor}'),
      ]),
      Text('Recebe', style: AppText.label),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final id in p.aceita)
          Builder(builder: (_) {
            final r = residuoPorId(id);
            final destaque = _residuo?.id == id;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: destaque ? AppColors.primary : AppColors.subtle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(r.icon, size: 14, color: destaque ? AppColors.accent : AppColors.muted),
                const SizedBox(width: 6),
                Text(r.nome, style: AppText.t(12, FontWeight.w600, destaque ? Colors.white : AppColors.ink)),
              ]),
            );
          }),
      ]),
      Builder(
        builder: (ctx) => EcoButton(
          label: 'Como chegar',
          icon: Icons.directions_outlined,
          onPressed: () async {
            final ok = await abrirRota(p.posicao.latitude, p.posicao.longitude);
            if (!ok && ctx.mounted) toast(ctx, 'Não foi possível abrir o mapa.');
          },
        ),
      ),
      if (p.exemplo)
        Text('Ponto de exemplo para demonstração: confirme o horário antes de ir.',
            textAlign: TextAlign.center, style: AppText.caption.copyWith(fontSize: 12)),
    ]);
    if (mounted) setState(() => _sel = null);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([localizacao, pontos]),
      builder: (context, _) {
        final lista = _visiveis();
        final filtros = <(String, VoidCallback, bool)>[
          if (_residuo != null) (_residuo!.nome, () {}, true),
          ('Todos', () => setState(() { _cat = null; _residuo = null; }), _cat == null && _residuo == null),
          for (final c in categorias)
            (c.curto, () => setState(() { _cat = c.id; _residuo = null; }), _cat == c.id && _residuo == null),
        ];
        return Scaffold(
          body: Stack(children: [
            Positioned.fill(
              child: EcoMapa(
                controller: _mapa,
                centro: posicaoUsuario,
                zoom: 13.3,
                onPronto: () {
                  _pronto = true;
                  _aoMudarLocalizacao();
                },
                marcadores: [
                  for (final p in lista)
                    ecoPin(
                      ponto: p.posicao,
                      icon: p.icon,
                      cor: p.exemplo ? AppColors.primary : AppColors.leafDark,
                      selecionado: _sel == p.id,
                      onTap: () => _selecionar(p),
                    ),
                ],
              ),
            ),
            // Topo: voltar + título + filtros
            SafeArea(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(children: [
                    CircleBtn(icon: Icons.arrow_back_rounded, onTap: () => Navigator.of(context).maybePop()),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), boxShadow: AppShadows.soft),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Pontos de descarte', style: AppText.t(15, FontWeight.w700, AppColors.ink)),
                          Row(children: [
                            Icon(
                              localizacao.ativa ? Icons.my_location_rounded : Icons.location_disabled_outlined,
                              size: 12,
                              color: localizacao.ativa ? const Color(0xFF2F7DE1) : AppColors.muted,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text('${lista.length} pontos · ${localizacao.mensagem.toLowerCase()}',
                                  maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.caption.copyWith(fontSize: 12)),
                            ),
                          ]),
                        ]),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      for (final f in filtros)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Material(
                            color: f.$3 ? AppColors.primary : AppColors.surface,
                            borderRadius: BorderRadius.circular(999),
                            elevation: 1,
                            shadowColor: const Color(0x22000000),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(999),
                              onTap: f.$2,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                child: Text(f.$1, style: AppText.t(13, FontWeight.w600, f.$3 ? Colors.white : AppColors.ink)),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ]),
            ),
            // Botão "minha localização"
            Positioned(
              right: 16,
              bottom: MediaQuery.of(context).size.height * 0.28 + 16,
              child: BotaoMinhaLocalizacao(onCentralizar: (p) {
                if (_pronto) _mapa.move(p, 15);
              }),
            ),
            // Lista arrastável com os pontos mais próximos
            DraggableScrollableSheet(
              initialChildSize: 0.28,
              minChildSize: 0.14,
              maxChildSize: 0.7,
              builder: (context, scroll) => Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: AppShadows.top,
                ),
                child: ListView(controller: scroll, padding: EdgeInsets.zero, children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                    child: Text(_residuo != null ? 'Onde descartar ${_residuo!.nome.toLowerCase()}' : 'Mais perto de você',
                        style: AppText.section),
                  ),
                  if (lista.isEmpty)
                    const EmptyState(
                      icon: Icons.location_off_outlined,
                      title: 'Nenhum ponto encontrado',
                      text: 'Tente outra categoria ou solicite a coleta pelo app.',
                    ),
                  for (final p in lista)
                    ListRow(
                      icon: p.icon,
                      title: p.nome,
                      subtitle: p.exemplo ? p.tipo : 'Novo · ${p.tipo}',
                      value: formatarDistancia(distanciaKm(posicaoUsuario, p.posicao)),
                      onTap: () => _selecionar(p),
                    ),
                  SizedBox(height: 16 + MediaQuery.of(context).padding.bottom),
                ]),
              ),
            ),
          ]),
        );
      },
    );
  }
}

/// Mini mapa para o Início: mostra os pontos e você, e abre o mapa completo.
class MiniMapaPontos extends StatelessWidget {
  const MiniMapaPontos({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([localizacao, pontos]),
      builder: (context, _) {
        final perto = [...pontos.todos]
          ..sort((a, b) => distanciaKm(posicaoUsuario, a.posicao).compareTo(distanciaKm(posicaoUsuario, b.posicao)));
        final p = perto.isEmpty ? null : perto.first;
        void abrir() => Navigator.of(context).push(slideRoute(const MapaPontosScreen()));
        return SoftCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(children: [
              SizedBox(
                height: 150,
                child: Stack(children: [
                  Positioned.fill(
                    child: EcoMapa(
                      // a chave muda quando a localização chega, para recentralizar
                      key: ValueKey(localizacao.ativa),
                      interativo: false,
                      centro: posicaoUsuario,
                      zoom: 13,
                      marcadores: [
                        for (final x in pontos.todos)
                          ecoPin(ponto: x.posicao, icon: x.icon, cor: x.exemplo ? AppColors.primary : AppColors.leafDark),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: Material(color: Colors.transparent, child: InkWell(onTap: abrir)),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(999), boxShadow: AppShadows.soft),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.open_in_full_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text('Abrir mapa', style: AppText.t(12, FontWeight.w600, AppColors.primary)),
                        ]),
                      ),
                    ),
                  ),
                ]),
              ),
              if (p != null)
                ListRow(
                  icon: p.icon,
                  title: p.nome,
                  subtitle: '${localizacao.ativa ? 'Mais perto de você' : 'Mais perto'} · '
                      '${formatarDistancia(distanciaKm(posicaoUsuario, p.posicao))}',
                  onTap: abrir,
                ),
            ]),
          ),
        );
      },
    );
  }
}
