import 'package:ecoscan/core/core.dart';
import 'package:flutter/material.dart';

import '../state/sessao.dart';
import 'cadastro.dart';
import 'rotas.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.email});

  /// E-mail já preenchido (ex.: vindo da demonstração).
  final String? email;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final _email = TextEditingController(text: widget.email ?? '');
  late final _senha = TextEditingController(text: widget.email != null ? Sessao.senhaDemo : '');
  late final _recuperar = TextEditingController();
  bool _ver = false;
  bool _carregando = false;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    _recuperar.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    final mail = _email.text.trim();
    if (!mail.contains('@')) return toast(context, 'Digite um e-mail válido');
    if (_senha.text.isEmpty) return toast(context, 'Digite a senha');
    setState(() => _carregando = true);
    await Future.delayed(const Duration(milliseconds: 500)); // simula a API de acesso
    if (!mounted) return;
    final conta = sessao.entrar(mail, _senha.text);
    setState(() => _carregando = false);
    if (conta == null) return toast(context, 'E-mail ou senha incorretos');
    Navigator.of(context).pushAndRemoveUntil(fadeRoute(inicioDoPapel(conta.papel)), (_) => false);
  }

  void _demo(Papel p) {
    final c = sessao.contaDemo(p);
    if (c == null) return;
    _email.text = c.email;
    _senha.text = c.senha;
    _entrar();
  }

  Future<void> _recuperarSenha() async {
    _recuperar.text = _email.text;
    final ok = await showFieldsSheet(
      context,
      title: 'Recuperar senha',
      subtitle: 'Vamos enviar um link para o seu e-mail.',
      confirm: 'Enviar link',
      cancel: 'Cancelar',
      fields: [AppField(label: 'E-mail', icon: Icons.mail_outline_rounded, controller: _recuperar, keyboard: TextInputType.emailAddress)],
    );
    if (ok && mounted) toast(context, 'Link enviado para ${_recuperar.text.trim()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.symmetric(horizontal: 24), children: [
          const SizedBox(height: 40),
          const EcoLockup(leaf: 44, text: 26),
          const SizedBox(height: 6),
          Text('Descarte certo, sem dúvida', style: AppText.caption),
          const SizedBox(height: 36),
          Text('Entrar', style: AppText.display),
          const SizedBox(height: 4),
          Text('Usuários, coletadores e empresas entram por aqui.', style: AppText.caption.copyWith(fontSize: 15)),
          const SizedBox(height: 24),
          AppField(label: 'E-mail', icon: Icons.mail_outline_rounded, controller: _email, keyboard: TextInputType.emailAddress),
          const SizedBox(height: 12),
          AppField(
            label: 'Senha',
            icon: Icons.lock_outline_rounded,
            controller: _senha,
            obscure: !_ver,
            suffix: IconButton(
              icon: Icon(_ver ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AppColors.muted),
              onPressed: () => setState(() => _ver = !_ver),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _recuperarSenha,
              child: Text('Esqueci a senha', style: AppText.t(13, FontWeight.w600, AppColors.primary)),
            ),
          ),
          const SizedBox(height: 4),
          _carregando
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2.5)),
                  ),
                )
              : EcoButton(label: 'Entrar', onPressed: _entrar),
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(slideRoute(const CadastroScreen())),
              child: Text.rich(TextSpan(style: AppText.t(14, FontWeight.w400, AppColors.muted), children: [
                const TextSpan(text: 'Não tem conta? '),
                TextSpan(text: 'Criar conta', style: AppText.t(14, FontWeight.w700, AppColors.primary)),
              ])),
            ),
          ),
          const SizedBox(height: 28),
          // Contas de demonstração: entram com um toque em cada papel
          SectionLabel('Contas de demonstração'),
          GroupCard(children: [
            for (final p in Papel.values)
              ListRow(
                icon: p.icon,
                title: p.label,
                subtitle: sessao.contaDemo(p)?.email,
                value: 'Entrar',
                onTap: () => _demo(p),
              ),
          ]),
          const SizedBox(height: 8),
          Text('Senha das contas de demonstração: ${Sessao.senhaDemo}',
              textAlign: TextAlign.center, style: AppText.caption.copyWith(fontSize: 12)),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}
