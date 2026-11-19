import 'package:flutter/material.dart';
import 'package:ecoscan/core/core.dart';

import 'cadastro.dart';
import 'login.dart';

/// "Como funciona": explica o app em 3 passos antes do login.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const _passos = [
    (Icons.photo_camera_outlined, 'Tire uma foto', 'Ou envie uma imagem da galeria'),
    (Icons.checklist_rounded, 'Escolha o material', 'Você seleciona o tipo de resíduo'),
    (Icons.eco_outlined, 'Receba a orientação', 'E peça a coleta, se precisar'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const EcoLockup(leaf: 28, text: 18),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).pushReplacement(fadeRoute(const LoginScreen())),
                child: Text('Pular', style: AppText.t(14, FontWeight.w600, AppColors.muted)),
              ),
            ]),
            const SizedBox(height: 40),
            FadeIn(child: Text('Descarte certo\nem 3 passos', style: AppText.display)),
            const SizedBox(height: 8),
            FadeIn(delay: 80, child: Text('Simples, rápido e sem dúvida.', style: AppText.caption.copyWith(fontSize: 15))),
            const SizedBox(height: 32),
            for (var i = 0; i < _passos.length; i++)
              FadeIn(
                delay: 200 + i * 140,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SoftCard(
                    child: Row(children: [
                      IconBox(icon: _passos[i].$1, size: 48, radius: 14, active: i == 0),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(_passos[i].$2, style: AppText.t(16, FontWeight.w600, AppColors.ink)),
                          const SizedBox(height: 3),
                          Text(_passos[i].$3, style: AppText.caption),
                        ]),
                      ),
                      Text('${i + 1}', style: AppText.t(20, FontWeight.w700, AppColors.line)),
                    ]),
                  ),
                ),
              ),
            const Spacer(),
            Row(children: [
              const Icon(Icons.local_shipping_outlined, size: 18, color: AppColors.muted),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Faz coletas ou tem uma empresa de coleta? Escolha seu perfil no cadastro.',
                    style: AppText.caption),
              ),
            ]),
            const SizedBox(height: 16),
            EcoButton(
              label: 'Começar',
              onPressed: () => Navigator.of(context).push(slideRoute(const CadastroScreen())),
            ),
            const SizedBox(height: 6),
            EcoButton(
              label: 'Já tenho conta',
              kind: BtnKind.text,
              onPressed: () => Navigator.of(context).push(fadeRoute(const LoginScreen())),
            ),
          ]),
        ),
      ),
    );
  }
}
