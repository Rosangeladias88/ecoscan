import 'package:ecoscan/core/core.dart';
import 'package:flutter/material.dart';

import '../state/coleta_state.dart';
import 'equipe.dart';
import 'mapa_pedidos.dart';
import 'pedidos.dart';
import 'perfil.dart';

/// Área de coleta. As abas mudam conforme o papel:
/// - Coletador: Pedidos · Mapa · Perfil
/// - Empresa:   Pedidos · Mapa · Equipe · Perfil
class ShellColeta extends StatefulWidget {
  const ShellColeta({super.key});
  @override
  State<ShellColeta> createState() => _ShellColetaState();
}

class _ShellColetaState extends State<ShellColeta> {
  int _aba = 0;

  @override
  Widget build(BuildContext context) {
    final empresa = coleta.perfil.empresa;
    final abas = <(IconData, IconData, String, Widget)>[
      (Icons.inbox_outlined, Icons.inbox_rounded, 'Pedidos', const PedidosScreen()),
      (Icons.map_outlined, Icons.map_rounded, 'Mapa', const MapaPedidosScreen()),
      if (empresa) (Icons.groups_outlined, Icons.groups_rounded, 'Equipe', const EquipeScreen()),
      (empresa ? Icons.business_outlined : Icons.person_outline_rounded,
          empresa ? Icons.business_rounded : Icons.person_rounded, 'Perfil', const PerfilColetaScreen()),
    ];
    final aba = _aba.clamp(0, abas.length - 1);

    return Scaffold(
      body: IndexedStack(index: aba, children: [for (final a in abas) a.$4]),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: AppColors.surface, boxShadow: AppShadows.top),
        padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + MediaQuery.of(context).padding.bottom),
        child: Row(children: [
          for (var i = 0; i < abas.length; i++)
            Expanded(
              child: InkResponse(
                onTap: () => setState(() => _aba = i),
                radius: 32,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    decoration: BoxDecoration(
                      color: aba == i ? AppColors.primarySoft : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Icon(aba == i ? abas[i].$2 : abas[i].$1, size: 24, color: aba == i ? AppColors.primary : AppColors.muted),
                  ),
                  const SizedBox(height: 4),
                  Text(abas[i].$3,
                      style: AppText.t(11, aba == i ? FontWeight.w700 : FontWeight.w500, aba == i ? AppColors.primary : AppColors.muted)),
                ]),
              ),
            ),
        ]),
      ),
    );
  }
}
