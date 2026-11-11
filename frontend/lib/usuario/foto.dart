import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ecoscan/core/core.dart';

import '../state/app_state.dart';
import 'material_escolha.dart';

/// Figma: "v2 Passo 1 · Foto"
/// Câmera ao vivo dentro do app (plugin `camera`). Antes de abrir, pede a
/// permissão de câmera com uma explicação (plugin `permission_handler`).
/// A galeria continua com `image_picker`, que no Android não pede permissão.
class FotoScreen extends StatefulWidget {
  const FotoScreen({super.key, this.fonteInicial});
  final ImageSource? fonteInicial;
  @override
  State<FotoScreen> createState() => _FotoScreenState();
}

enum _Cam { verificando, pedir, negada, bloqueada, iniciando, pronta, indisponivel }

class _FotoScreenState extends State<FotoScreen> with WidgetsBindingObserver {
  final _picker = ImagePicker();
  CameraController? _ctrl;
  List<CameraDescription> _cams = const [];
  int _camIdx = -1;
  bool _flash = false;
  bool _capturando = false;
  bool _abrindoGaleria = false;
  bool _pedindo = false;
  bool _iniciando = false;
  _Cam _cam = _Cam.verificando;

  bool get _aoVivo => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _recuperarFotoPerdida();
    if (widget.fonteInicial == ImageSource.gallery) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _galeria());
    }
    if (_aoVivo) {
      _verificar();
    } else {
      _cam = _Cam.indisponivel; // ex.: teste no Chrome → só galeria
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ctrl?.dispose();
    super.dispose();
  }

  /// No Android a câmera precisa ser liberada quando o app sai da tela
  /// e reaberta quando ele volta (inclusive ao voltar das Configurações).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_aoVivo) return;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      final c = _ctrl;
      if (c != null) {
        _ctrl = null;
        c.dispose();
        if (mounted) setState(() {});
      }
    } else if (state == AppLifecycleState.resumed) {
      _verificar();
    }
  }

  // ---------------------------------------------------------------- Permissão
  Future<void> _verificar() async {
    if (_pedindo || _iniciando) return;
    final st = await Permission.camera.status;
    if (!mounted) return;
    if (st.isGranted) {
      if (_ctrl == null) await _iniciarCamera();
    } else if (st.isPermanentlyDenied) {
      setState(() => _cam = _Cam.bloqueada);
    } else {
      setState(() => _cam = _cam == _Cam.negada ? _Cam.negada : _Cam.pedir);
    }
  }

  Future<void> _pedirPermissao() async {
    _pedindo = true;
    final st = await Permission.camera.request();
    _pedindo = false;
    if (!mounted) return;
    if (st.isGranted) {
      await _iniciarCamera();
    } else if (st.isPermanentlyDenied) {
      setState(() => _cam = _Cam.bloqueada);
    } else {
      setState(() => _cam = _Cam.negada);
    }
  }

  // ---------------------------------------------------------------- Câmera
  Future<void> _iniciarCamera() async {
    if (_iniciando || !mounted) return;
    _iniciando = true;
    setState(() => _cam = _Cam.iniciando);
    try {
      if (_cams.isEmpty) _cams = await availableCameras();
      if (_cams.isEmpty) {
        if (mounted) setState(() => _cam = _Cam.indisponivel);
        return;
      }
      if (_camIdx < 0) {
        final traseira = _cams.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
        _camIdx = traseira >= 0 ? traseira : 0;
      }
      final antigo = _ctrl;
      _ctrl = null;
      await antigo?.dispose();
      final c = CameraController(
        _cams[_camIdx],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await c.initialize();
      try {
        await c.setFlashMode(_flash ? FlashMode.always : FlashMode.off);
      } catch (_) {}
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() {
        _ctrl = c;
        _cam = _Cam.pronta;
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() => _cam = e.code.contains('AccessDenied') ? _Cam.negada : _Cam.indisponivel);
    } finally {
      _iniciando = false;
    }
  }

  Future<void> _fotografar() async {
    final c = _ctrl;
    if (c == null || !c.value.isInitialized || c.value.isTakingPicture) return;
    setState(() => _capturando = true);
    try {
      final x = await c.takePicture();
      app.definirFoto(await x.readAsBytes());
      HapticFeedback.mediumImpact();
    } catch (_) {
      if (mounted) toast(context, 'Não foi possível tirar a foto. Tente de novo.');
    } finally {
      if (mounted) setState(() => _capturando = false);
    }
  }

  Future<void> _trocarCamera() async {
    if (_cams.length < 2) return;
    _camIdx = (_camIdx + 1) % _cams.length;
    await _iniciarCamera();
  }

  Future<void> _alternarFlash() async {
    setState(() => _flash = !_flash);
    try {
      await _ctrl?.setFlashMode(_flash ? FlashMode.always : FlashMode.off);
    } catch (_) {}
  }

  // ---------------------------------------------------------------- Galeria
  Future<void> _galeria() async {
    if (_abrindoGaleria) return;
    setState(() => _abrindoGaleria = true);
    try {
      final x = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 80);
      if (x != null) app.definirFoto(await x.readAsBytes());
    } catch (_) {
      if (mounted) toast(context, 'Não foi possível abrir a galeria.');
    } finally {
      if (mounted) setState(() => _abrindoGaleria = false);
    }
  }

  /// Android: em celulares com pouca memória o sistema pode fechar o app
  /// enquanto a galeria está aberta. Isto recupera a foto quando ele volta.
  Future<void> _recuperarFotoPerdida() async {
    if (!_aoVivo) return;
    try {
      final r = await _picker.retrieveLostData();
      final f = r.file ?? (r.files != null && r.files!.isNotEmpty ? r.files!.first : null);
      if (f != null) app.definirFoto(await f.readAsBytes());
    } catch (_) {}
  }

  void _continuar() => Navigator.of(context).push(slideRoute(const MaterialScreen()));

  // ---------------------------------------------------------------- Tela
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.dark,
        body: SafeArea(
          child: ListenableBuilder(
            listenable: app,
            builder: (context, _) {
              final foto = app.fotoAtual;
              return Column(children: [
                const StepHeader(step: 1, title: 'Foto do resíduo', dark: true),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF2B352D), Color(0xFF1A221C)],
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: foto != null
                              ? Image.memory(foto, key: const ValueKey('foto'), fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                              : KeyedSubtree(key: ValueKey(_cam), child: _visor()),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: foto == null ? _controlesCaptura() : _controlesConfirmar(),
                ),
              ]);
            },
          ),
        ),
      ),
    );
  }

  Widget _visor() {
    switch (_cam) {
      case _Cam.pronta:
        final c = _ctrl;
        if (c == null || !c.value.isInitialized) return _carregando();
        return Stack(fit: StackFit.expand, children: [
          ClipRect(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(width: 100, height: 100 * c.value.aspectRatio, child: CameraPreview(c)),
            ),
          ),
          Center(child: SizedBox(width: 220, height: 240, child: CustomPaint(painter: _CantosPainter()))),
          Positioned(
            top: 12,
            right: 12,
            child: _BotaoRedondo(
              icon: _flash ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              onTap: _alternarFlash,
              size: 40,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(child: _pilula('Centralize o resíduo')),
          ),
        ]);
      case _Cam.pedir:
        return _AvisoPermissao(
          icon: Icons.photo_camera_outlined,
          titulo: 'Permitir acesso à câmera',
          texto: 'O EcoScan usa a câmera só para fotografar o resíduo. Você pode mudar isso quando quiser nas configurações do celular.',
          botao: 'Permitir câmera',
          onBotao: _pedirPermissao,
          onGaleria: _galeria,
        );
      case _Cam.negada:
        return _AvisoPermissao(
          icon: Icons.no_photography_outlined,
          titulo: 'Câmera não permitida',
          texto: 'Sem a câmera, você ainda pode enviar uma foto da galeria ou continuar sem foto.',
          botao: 'Tentar de novo',
          onBotao: _pedirPermissao,
          onGaleria: _galeria,
        );
      case _Cam.bloqueada:
        return _AvisoPermissao(
          icon: Icons.lock_outline_rounded,
          titulo: 'Acesso à câmera bloqueado',
          texto: 'Para usar a câmera, abra as configurações do EcoScan e vá em Permissões → Câmera → Permitir.',
          botao: 'Abrir configurações',
          onBotao: () => openAppSettings(),
          onGaleria: _galeria,
        );
      case _Cam.indisponivel:
        return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              width: 220,
              height: 240,
              child: CustomPaint(
                painter: _CantosPainter(),
                child: const Center(child: Icon(Icons.photo_library_outlined, color: AppColors.white70, size: 44)),
              ),
            ),
            const SizedBox(height: 18),
            _pilula('Envie uma foto da galeria'),
          ]),
        );
      case _Cam.verificando:
      case _Cam.iniciando:
        return _carregando();
    }
  }

  Widget _carregando() => const Center(
        child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)),
      );

  Widget _pilula(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: const Color(0x59000000), borderRadius: BorderRadius.circular(999)),
        child: Text(t, style: AppText.t(13, FontWeight.w500, Colors.white)),
      );

  Widget _controlesCaptura() {
    final pronta = _cam == _Cam.pronta && _ctrl != null;
    final VoidCallback disparo = pronta
        ? _fotografar
        : (_cam == _Cam.pedir || _cam == _Cam.negada)
            ? _pedirPermissao
            : _galeria;
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _BotaoRedondo(icon: Icons.photo_library_outlined, gradient: true, onTap: _galeria),
        GestureDetector(
          onTap: disparo,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: pronta || _cam == _Cam.indisponivel ? 1 : 0.5,
            child: Container(
              width: 78,
              height: 78,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
              child: _capturando || _abrindoGaleria
                  ? const Padding(
                      padding: EdgeInsets.all(18),
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : Container(decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
            ),
          ),
        ),
        pronta && _cams.length > 1
            ? _BotaoRedondo(icon: Icons.cameraswitch_outlined, onTap: _trocarCamera)
            : _BotaoRedondo(icon: Icons.arrow_forward_rounded, onTap: _continuar),
      ]),
      const SizedBox(height: 14),
      GestureDetector(
        onTap: _continuar,
        child: Text(
          pronta ? 'Toque para fotografar  ·  Continuar sem foto' : 'Continuar sem foto',
          style: AppText.t(12, FontWeight.w500, AppColors.white70),
        ),
      ),
    ]);
  }

  Widget _controlesConfirmar() => Column(children: [
        Row(children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text('Foto pronta', style: AppText.t(15, FontWeight.w600, Colors.white))),
          TextButton(
            onPressed: () => app.definirFoto(null),
            child: Text('Tirar outra', style: AppText.t(14, FontWeight.w600, AppColors.accent)),
          ),
        ]),
        const SizedBox(height: 10),
        Material(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _continuar,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(child: Text('Usar esta foto', style: AppText.t(15, FontWeight.w700, AppColors.primary))),
            ),
          ),
        ),
      ]);
}

/// Explicação antes do pedido de permissão (e telas de negada/bloqueada).
class _AvisoPermissao extends StatelessWidget {
  const _AvisoPermissao({
    required this.icon,
    required this.titulo,
    required this.texto,
    required this.botao,
    required this.onBotao,
    required this.onGaleria,
  });
  final IconData icon;
  final String titulo, texto, botao;
  final VoidCallback onBotao, onGaleria;

  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(color: AppColors.white10, shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.accent, size: 32),
            ),
            const SizedBox(height: 18),
            Text(titulo, textAlign: TextAlign.center, style: AppText.t(20, FontWeight.w700, Colors.white, ls: -0.4)),
            const SizedBox(height: 8),
            Text(texto, textAlign: TextAlign.center, style: AppText.t(14, FontWeight.w400, AppColors.white70, height: 1.45)),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: Material(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: onBotao,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Center(child: Text(botao, style: AppText.t(15, FontWeight.w700, AppColors.primary))),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: onGaleria,
              child: Text('Usar foto da galeria', style: AppText.t(14, FontWeight.w600, Colors.white)),
            ),
          ]),
        ),
      );
}

class _CantosPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const l = 36.0, r = 18.0;
    void canto(double x, double y, double dx, double dy) {
      final path = Path()
        ..moveTo(x, y + dy * l)
        ..lineTo(x, y + dy * r)
        ..quadraticBezierTo(x, y, x + dx * r, y)
        ..lineTo(x + dx * l, y);
      canvas.drawPath(path, p);
    }

    canto(0, 0, 1, 1);
    canto(s.width, 0, -1, 1);
    canto(0, s.height, 1, -1);
    canto(s.width, s.height, -1, -1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BotaoRedondo extends StatelessWidget {
  const _BotaoRedondo({required this.icon, required this.onTap, this.gradient = false, this.size = 52});
  final IconData icon;
  final VoidCallback onTap;
  final bool gradient;
  final double size;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: gradient ? null : const Color(0x40000000),
            gradient: gradient ? const LinearGradient(colors: [Color(0xFFEDBD54), Color(0xFFC78526)]) : null,
            borderRadius: BorderRadius.circular(gradient ? 14 : size / 2),
          ),
          child: Icon(icon, color: Colors.white, size: size * 0.42),
        ),
      );
}
