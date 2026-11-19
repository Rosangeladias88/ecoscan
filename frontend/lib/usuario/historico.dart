import 'package:flutter/material.dart';
import 'package:ecoscan/core/core.dart';
import '../state/sessao.dart';

import '../state/app_state.dart';
import 'home.dart';

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  int _filtro = 0;

  @override
  void initState() {
    super.initState();

    if (sessao.autenticado && sessao.atual?.papel == Papel.usuario) {
      app.carregarHistoricoRemoto();
    }
  }

  Future<void> _atualizar() async {
    if (sessao.autenticado && sessao.atual?.papel == Papel.usuario) {
      await app.carregarHistoricoRemoto();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final todos = app.historico;

        final itens = switch (_filtro) {
          1 => todos.where((h) => !h.isColeta).toList(),
          2 => todos.where((h) => h.isColeta).toList(),
          _ => todos,
        };

        final limite = DateTime.now().subtract(
          const Duration(days: 7),
        );

        final semana = itens
            .where((h) => h.data.isAfter(limite))
            .toList();

        final antes = itens
            .where((h) => !h.data.isAfter(limite))
            .toList();

        Widget grupo(String titulo, List<ItemHistorico> lista) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(titulo),
              GroupCard(
                children: [
                  for (final h in lista)
                    ListRow(
                      icon: h.icon,
                      leading: h.foto != null
                          ? PhotoThumb(
                              bytes: h.foto,
                              icon: h.icon,
                              size: 40,
                            )
                          : null,
                      title: h.titulo,
                      subtitle: h.subtitulo,
                      trailing: h.pedido != null
                          ? StatusBadge(h.pedido!.status)
                          : null,
                      onTap: () => abrirItemHistorico(context, h),
                    ),
                ],
              ),
              const SizedBox(height: 22),
            ],
          );
        }

        return SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: _atualizar,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              children: [
                Text('Histórico', style: AppText.display),
                const SizedBox(height: 4),
                Text(
                  'Reveja suas consultas sempre que precisar.',
                  style: AppText.caption.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 20),
                Segmented(
                  options: const [
                    'Todos',
                    'Consultas',
                    'Coletas',
                  ],
                  selected: _filtro,
                  onChanged: (i) => setState(() => _filtro = i),
                ),
                const SizedBox(height: 16),
                if (app.carregandoHistoricoRemoto)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                if (app.erroHistoricoRemoto != null) ...[
                  Text(
                    'Não foi possível atualizar o histórico.',
                    style: AppText.t(
                      14,
                      FontWeight.w600,
                      AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton.icon(
                    onPressed: _atualizar,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                  const SizedBox(height: 12),
                ],
                if (itens.isEmpty && !app.carregandoHistoricoRemoto)
                  const EmptyState(
                    icon: Icons.history_rounded,
                    title: 'Nada por aqui',
                    text:
                        'Quando você fizer uma consulta ou pedir uma coleta, ela aparece aqui.',
                  ),
                if (semana.isNotEmpty)
                  grupo('Esta semana', semana),
                if (antes.isNotEmpty)
                  grupo('Anteriores', antes),
              ],
            ),
          ),
        );
      },
    );
  }
}