import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecoscan/core/core.dart';

import '../state/app_state.dart';
import 'foto.dart';
import 'historico.dart';
import 'home.dart';
import 'material_escolha.dart';
import 'perfil.dart';
import 'ranking.dart';

/// Inicia o fluxo de consulta (Passo 1: foto).
void iniciarEscaneamento(BuildContext context, {ImageSource? fonte}) {
  app.iniciarConsulta();
  Navigator.of(context).push(slideRoute(FotoScreen(fonteInicial: fonte)));
}

/// Atalho pelas categorias: pula a foto e abre o Passo 2 já na categoria.
void abrirCategoria(BuildContext context, CategoriaId id) {
  app.iniciarConsulta();
  Navigator.of(context).push(slideRoute(MaterialScreen(categoriaInicial: id)));
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _aba = 0; // 0 Início · 1 Ranking (Hall da Fama) · 2 Histórico · 3 Perfil

  void _ir(int i) => setState(() => _aba = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _aba, children: [
        HomeScreen(onVerHistorico: () => _ir(2), onVerPerfil: () => _ir(3), onVerRanking: () => _ir(1)),
        const RankingScreen(),
        const HistoricoScreen(),
        const PerfilScreen(),
      ]),
      bottomNavigationBar: _TabBar(
        aba: _aba,
        onTap: _ir,
        onScan: () => iniciarEscaneamento(context),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.aba, required this.onTap, required this.onScan});
  final int aba;
  final ValueChanged<int> onTap;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    Widget item(int i, IconData off, IconData on, String label) {
      final ativo = aba == i;
      return Expanded(
        child: InkResponse(
          onTap: () => onTap(i),
          radius: 32,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(ativo ? on : off, size: 24, color: ativo ? AppColors.primary : AppColors.muted),
            const SizedBox(height: 4),
            Text(label,
                style: AppText.t(11, ativo ? FontWeight.w700 : FontWeight.w500,
                    ativo ? AppColors.primary : AppColors.muted)),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: ativo ? 4 : 0,
              height: 4,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            ),
          ]),
        ),
      );
    }

    // Altura fixa: a barra fica sempre embaixo e nunca estica pela tela.
    final baixo = MediaQuery.of(context).padding.bottom;
    return Container(
      height: 72 + baixo,
      decoration: const BoxDecoration(color: AppColors.surface, boxShadow: AppShadows.top),
      padding: EdgeInsets.fromLTRB(8, 10, 8, 6 + baixo),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        item(0, Icons.home_outlined, Icons.home_rounded, 'Início'),
        item(1, Icons.emoji_events_outlined, Icons.emoji_events_rounded, 'Ranking'),
        Expanded(
          child: Center(
            heightFactor: 1,
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onScan,
                child: const SizedBox(
                  width: 56,
                  height: 46,
                  child: Icon(Icons.center_focus_weak_rounded, color: AppColors.accent, size: 24),
                ),
              ),
            ),
          ),
        ),
        item(2, Icons.history_rounded, Icons.history_rounded, 'Histórico'),
        item(3, Icons.person_outline_rounded, Icons.person_rounded, 'Perfil'),
      ]),
    );
  }
}
