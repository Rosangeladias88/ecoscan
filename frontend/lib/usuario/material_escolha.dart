import 'package:flutter/material.dart';
import 'package:ecoscan/core/core.dart';

import '../state/app_state.dart';
import 'orientacao.dart';

/// Passo 2 de 3: escolha MANUAL do material (categorias em acordeão + busca).
class MaterialScreen extends StatefulWidget {
  const MaterialScreen({super.key, this.categoriaInicial});
  final CategoriaId? categoriaInicial;
  @override
  State<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  late CategoriaId? _aberta = widget.categoriaInicial ?? app.residuoAtual?.categoria;
  late Residuo? _sel = app.residuoAtual;
  String _busca = '';

  void _continuar() {
    app.escolherResiduo(_sel!);
    Navigator.of(context).push(slideRoute(OrientacaoScreen(residuo: _sel!, foto: app.fotoAtual)));
  }

  @override
  Widget build(BuildContext context) {
    final q = _busca.trim().toLowerCase();
    final resultados = q.isEmpty ? <Residuo>[] : residuos.where((r) => r.nome.toLowerCase().contains(q)).toList();
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          const StepHeader(step: 2, title: 'Qual é o material?'),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(24, 10, 24, 24), children: [
              _fotoAnexada(context),
              const SizedBox(height: 14),
              AppField(
                label: 'Buscar material',
                hint: 'Ex.: óleo, pilha, sofá',
                icon: Icons.search_rounded,
                onChanged: (v) => setState(() => _busca = v),
              ),
              const SizedBox(height: 16),
              if (q.isNotEmpty) ...[
                if (resultados.isEmpty)
                  const EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Nada encontrado',
                      text: 'Tente outro nome ou escolha pela categoria.')
                else
                  GroupCard(children: [for (final r in resultados) _item(r, mostrarCategoria: true)]),
              ] else ...[
                Text('Toque na categoria e selecione o tipo de resíduo.', style: AppText.caption),
                const SizedBox(height: 12),
                for (final c in categorias) ...[_categoria(c), const SizedBox(height: 12)],
              ],
            ]),
          ),
          ActionBar(children: [
            EcoButton(label: _sel == null ? 'Selecione um material' : 'Continuar', onPressed: _sel == null ? null : _continuar),
          ]),
        ]),
      ),
    );
  }

  Widget _fotoAnexada(BuildContext context) {
    final foto = app.fotoAtual;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: foto != null ? AppColors.primarySoft : AppColors.subtle,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        foto != null
            ? PhotoThumb(bytes: foto, icon: Icons.image_outlined, size: 40)
            : const IconBox(icon: Icons.image_not_supported_outlined, bg: AppColors.surface, fg: AppColors.muted),
        const SizedBox(width: 12),
        Expanded(
          child: Text(foto != null ? 'Foto anexada' : 'Sem foto · pode continuar normalmente',
              style: AppText.t(14, FontWeight.w600, foto != null ? AppColors.primary : AppColors.muted)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: Text(foto != null ? 'Trocar' : 'Adicionar', style: AppText.t(13, FontWeight.w600, AppColors.primary)),
        ),
      ]),
    );
  }

  Widget _categoria(Categoria c) {
    final aberta = _aberta == c.id;
    final itens = residuosDa(c.id);
    final temSel = _sel?.categoria == c.id;
    return SoftCard(
      padding: EdgeInsets.zero,
      border: aberta ? AppColors.primary : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Column(children: [
          InkWell(
            onTap: () => setState(() => _aberta = aberta ? null : c.id),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
              child: Row(children: [
                IconBox(icon: c.icon, active: aberta),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c.nome, style: AppText.bodyStrong),
                    if (temSel && !aberta) ...[
                      const SizedBox(height: 2),
                      Text(_sel!.nome, style: AppText.t(12, FontWeight.w600, AppColors.leafDark)),
                    ],
                  ]),
                ),
                Text('${itens.length} itens', style: AppText.caption),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: aberta ? 0.5 : 0,
                  duration: const Duration(milliseconds: 220),
                  child: const Icon(Icons.expand_more_rounded, color: AppColors.muted),
                ),
              ]),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: aberta
                ? Column(children: [
                    const Divider(height: 1, color: AppColors.line),
                    for (final r in itens) _item(r),
                  ])
                : const SizedBox(width: double.infinity),
          ),
        ]),
      ),
    );
  }

  Widget _item(Residuo r, {bool mostrarCategoria = false}) {
    final on = _sel?.id == r.id;
    return Material(
      color: on ? AppColors.accentSoft : Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _sel = r),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 13, 16, 13),
          child: Row(children: [
            RadioDot(on: on),
            const SizedBox(width: 12),
            Icon(r.icon, size: 18, color: on ? AppColors.primary : AppColors.muted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(r.nome, style: AppText.t(14, on ? FontWeight.w600 : FontWeight.w400, AppColors.ink)),
            ),
            if (mostrarCategoria) Text(r.cat.curto, style: AppText.caption),
          ]),
        ),
      ),
    );
  }
}
