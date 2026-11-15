import 'package:flutter/material.dart';

import '../theme.dart';

/// Logo oficial do EcoScan (imagens em assets/logo/).
///
/// - ecoscan_folha.png        → símbolo (as duas folhas)
/// - ecoscan_nome.png         → "EcoScan" verde (fundos claros)
/// - ecoscan_nome_branco.png  → "EcoScan" branco (fundos verdes/escuros)
/// - ecoscan_logo.png         → logo completo (folha + nome)

/// Símbolo do EcoScan. [size] é a altura/largura máxima.
/// ([veinColor] fica por compatibilidade: a imagem já tem as cores certas.)
class EcoLeaf extends StatelessWidget {
  const EcoLeaf({super.key, this.size = 48, this.veinColor = Colors.white});
  final double size;
  final Color veinColor;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: Image.asset('assets/logo/ecoscan_folha.png', fit: BoxFit.contain, filterQuality: FilterQuality.medium),
      );
}

/// Nome "EcoScan". Escolhe sozinho a versão branca quando [color] é clara.
class EcoWordmark extends StatelessWidget {
  const EcoWordmark({super.key, this.size = 26, this.color = AppColors.primary});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final branco = color.computeLuminance() > 0.5;
    return Image.asset(
      branco ? 'assets/logo/ecoscan_nome_branco.png' : 'assets/logo/ecoscan_nome.png',
      height: size * 0.92,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'EcoScan',
    );
  }
}

/// Folha + nome. A folha usa Hero para "voar" entre as telas de abertura.
class EcoLockup extends StatelessWidget {
  const EcoLockup({
    super.key,
    this.leaf = 44,
    this.text = 26,
    this.color = AppColors.primary,
    this.veinColor = AppColors.bg,
    this.hero = true,
  });
  final double leaf, text;
  final Color color, veinColor;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    Widget l = EcoLeaf(size: leaf, veinColor: veinColor);
    if (hero) l = Hero(tag: 'eco-leaf', child: l);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      l,
      SizedBox(width: leaf * 0.2),
      EcoWordmark(size: text, color: color),
    ]);
  }
}
