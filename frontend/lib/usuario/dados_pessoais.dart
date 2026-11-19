import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecoscan/core/core.dart';

import '../state/app_state.dart';

/// Figma: "v2 Dados pessoais" (+ "Sheet · Foto de perfil")
class DadosPessoaisScreen extends StatefulWidget {
  const DadosPessoaisScreen({super.key});
  @override
  State<DadosPessoaisScreen> createState() => _DadosPessoaisScreenState();
}

class _DadosPessoaisScreenState extends State<DadosPessoaisScreen> {
  late final _nome = TextEditingController(text: app.nome);
  late final _email = TextEditingController(text: app.email);
  late final _tel = TextEditingController(text: app.telefone);
  late final _end = TextEditingController(text: app.endereco);

  @override
  void dispose() {
    for (final c in [_nome, _email, _tel, _end]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _foto() async {
    final opcoes = ['Tirar foto', 'Escolher da galeria', if (app.fotoPerfil != null) 'Remover foto'];
    final i = await showOptionsSheet(context, title: 'Foto de perfil', options: opcoes, selected: -1, confirm: 'Continuar');
    if (i == null || i < 0) return;
    if (i == 2) {
      app.definirFotoPerfil(null);
      return;
    }
    try {
      final x = await ImagePicker().pickImage(
        source: i == 0 ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 600,
        imageQuality: 80,
      );
      if (x != null) app.definirFotoPerfil(await x.readAsBytes());
    } catch (_) {
      if (mounted) toast(context, 'Não foi possível abrir a ${i == 0 ? 'câmera' : 'galeria'}');
    }
  }

  void _salvar() {
    if (!_email.text.contains('@')) return toast(context, 'Digite um e-mail válido');
    app.atualizarDados(nome: _nome.text, email: _email.text, telefone: _tel.text, endereco: _end.text);
    toast(context, 'Dados atualizados');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          const TopBar(title: 'Dados pessoais'),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(24, 14, 24, 24), children: [
              ListenableBuilder(
                listenable: app,
                builder: (context, _) => Column(children: [
                  GestureDetector(
                    onTap: _foto,
                    child: Avatar(app.iniciais, size: 72, dark: true, bytes: app.fotoPerfil),
                  ),
                  TextButton(
                    onPressed: _foto,
                    child: const Text('Alterar foto'),
                  ),
                ]),
              ),
              const SizedBox(height: 8),
              AppField(label: 'Nome completo', icon: Icons.person_outline_rounded, controller: _nome),
              const SizedBox(height: 12),
              AppField(label: 'E-mail', icon: Icons.mail_outline_rounded, controller: _email, keyboard: TextInputType.emailAddress),
              const SizedBox(height: 12),
              AppField(label: 'Telefone', icon: Icons.phone_outlined, controller: _tel, keyboard: TextInputType.phone),
              const SizedBox(height: 12),
              AppField(label: 'Endereço de retirada', icon: Icons.location_on_outlined, controller: _end),
            ]),
          ),
          ActionBar(children: [EcoButton(label: 'Salvar alterações', onPressed: _salvar)]),
        ]),
      ),
    );
  }
}
