import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ecoscan/core/core.dart';

import 'onboarding.dart';

/// Abertura animada:
/// 1) a folha surge (fade + escala)  2) um anel se expande
/// 3) a folha diminui e o nome "EcoScan" entra  4) o slogan aparece
/// Depois a folha "voa" (Hero) para a tela Como funciona.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));

  @override
  void initState() {
    super.initState();
    _c.forward().whenComplete(() async {
      await Future.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(fadeRoute(const OnboardingScreen()));
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _seg(double a, double b, [Curve curve = Curves.easeOutCubic]) =>
      curve.transform(((_c.value - a) / (b - a)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final appear = _seg(0.0, 0.32, Curves.easeOutBack);
            final ring = _seg(0.12, 0.72, Curves.easeOut);
            final lockup = _seg(0.48, 0.80);
            final slogan = _seg(0.72, 1.0);
            final leafSize = 96 - 40 * lockup;
            return Stack(alignment: Alignment.center, children: [
              // Anel que se expande e some
              Transform.scale(
                scale: 0.3 + ring * 2.4,
                child: Opacity(
                  opacity: (math.sin(math.pi * ring) * 0.35).clamp(0.0, 1.0),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accent, width: 1.5),
                    ),
                  ),
                ),
              ),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Opacity(
                    opacity: appear.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 0.6 + 0.4 * appear,
                      child: Hero(
                        tag: 'eco-leaf',
                        child: EcoLeaf(size: leafSize, veinColor: AppColors.primary),
                      ),
                    ),
                  ),
                  SizedBox(width: 12 * lockup),
                  ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: lockup,
                      child: Opacity(
                        opacity: lockup,
                        child: const EcoWordmark(size: 36, color: Colors.white),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 14),
                Opacity(
                  opacity: slogan,
                  child: Transform.translate(
                    offset: Offset(0, 8 * (1 - slogan)),
                    child: Text('Descarte certo, sem dúvida',
                        style: AppText.t(15, FontWeight.w500, AppColors.accent)),
                  ),
                ),
              ]),
            ]);
          },
        ),
      ),
    );
  }
}
