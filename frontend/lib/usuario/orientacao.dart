import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ecoscan/core/core.dart';

import '../state/app_state.dart';
import '../data/pontos.dart';
import 'mapa_pontos.dart';
import 'solicitar_coleta.dart';

class OrientacaoScreen extends StatefulWidget {
  const OrientacaoScreen({
    super.key,
    required this.residuo,
    this.doHistorico = false,
    this.foto,
  });

  final Residuo residuo;
  final bool doHistorico;
  final Uint8List? foto;

  @override
  State<OrientacaoScreen> createState() => _OrientacaoScreenState();
}

class _OrientacaoScreenState extends State<OrientacaoScreen> {
  bool _salvando = false;

  Future<void> _salvar() async {
    if (_salvando) return;

    setState(() => _salvando = true);

    try {
      await app.salvarConsultaCompleta();

      if (!mounted) return;

      toast(context, 'Consulta salva no histórico');

      Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      if (!mounted) return;

      final mensagem = e.toString().replaceFirst('Exception: ', '');

      toast(context, mensagem);
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final residuo = widget.residuo;
    final foto = widget.foto;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            widget.doHistorico
                ? const TopBar(title: 'Orientação')
                : const StepHeader(step: 3, title: 'Orientação'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                children: [
                  FadeIn(
                    child: Row(
                      children: [
                        PhotoThumb(
                          bytes: foto,
                          icon: residuo.icon,
                          size: 60,
                          radius: 14,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Tag(residuo.cat.nome, icon: residuo.cat.icon),
                              const SizedBox(height: 6),
                              Text(residuo.nome, style: AppText.title),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeIn(
                    delay: 100,
                    child: SoftCard(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Como descartar',
                            style: AppText.t(
                              15,
                              FontWeight.w700,
                              AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          for (var i = 0; i < residuo.passos.length; i++)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                border: i < residuo.passos.length - 1
                                    ? const Border(
                                        bottom: BorderSide(
                                          color: AppColors.line,
                                        ),
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primarySoft,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${i + 1}',
                                      style: AppText.t(
                                        13,
                                        FontWeight.w700,
                                        AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      residuo.passos[i],
                                      style: AppText.t(
                                        15,
                                        FontWeight.w500,
                                        AppColors.ink,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FadeIn(
                    delay: 180,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.dangerSoft,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.danger,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              residuo.alerta,
                              style: AppText.t(
                                14,
                                FontWeight.w600,
                                AppColors.danger,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FadeIn(
                    delay: 240,
                    child: GroupCard(
                      children: [
                        ListRow(
                          icon: Icons.recycling_rounded,
                          title: residuo.destino,
                          subtitle: residuo.destinoDetalhe,
                        ),
                        Builder(
                          builder: (context) {
                            final n = pontos.todos
                                .where((p) => p.aceita.contains(residuo.id))
                                .length;

                            return ListRow(
                              icon: Icons.map_outlined,
                              title: 'Onde descartar perto de você',
                              subtitle: n == 0
                                  ? 'Nenhum ponto no mapa · peça a coleta'
                                  : '$n ${n == 1 ? 'ponto aceita' : 'pontos aceitam'} este material',
                              onTap: () => Navigator.of(context).push(
                                slideRoute(
                                  MapaPontosScreen(residuo: residuo),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  if (!residuo.coletavel) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.warnSoft,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 20,
                            color: AppColors.warn,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Este resíduo não é coletado em casa. Entregue no ponto indicado.',
                              style: AppText.t(
                                13,
                                FontWeight.w500,
                                AppColors.warn,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!widget.doHistorico)
              ActionBar(
                children: [
                  if (residuo.coletavel) ...[
                    EcoButton(
                      label: 'Solicitar coleta',
                      icon: Icons.local_shipping_outlined,
                      onPressed: () => Navigator.of(context).push(
                        slideRoute(
                          SolicitarColetaScreen(residuo: residuo),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    EcoButton(
                      label: _salvando ? 'Salvando...' : 'Salvar no histórico',
                      kind: BtnKind.text,
                      compact: true,
                      onPressed: _salvando
                          ? null
                          : () {
                              _salvar();
                            },
                    ),
                  ] else
                    EcoButton(
                      label: _salvando ? 'Salvando...' : 'Salvar no histórico',
                      onPressed: _salvando
                          ? null
                          : () {
                              _salvar();
                            },
                    ),
                ],
              )
            else if (residuo.coletavel)
              ActionBar(
                children: [
                  EcoButton(
                    label: 'Solicitar coleta',
                    kind: BtnKind.secondary,
                    icon: Icons.local_shipping_outlined,
                    onPressed: () {
                      app.iniciarConsulta();
                      app.escolherResiduo(residuo);

                      Navigator.of(context).push(
                        slideRoute(
                          SolicitarColetaScreen(residuo: residuo),
                        ),
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}