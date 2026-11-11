import 'package:flutter/material.dart';
import 'package:ecoscan/core/core.dart';

import '../state/app_state.dart';
import 'dados_pessoais.dart';
import '../acesso/login.dart';
import '../state/sessao.dart';

/// Figma: "v2 Perfil"
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  // Figma: "Sheet · Notificações"
  Future<void> _notificacoes(BuildContext context) => showEcoSheet<void>(context, title: 'Notificações', children: [
        ListenableBuilder(
          listenable: app,
          builder: (ctx, _) {
            Widget linha(String t, bool v, ValueChanged<bool> on) => SwitchListTile(
                  value: v,
                  onChanged: on,
                  activeColor: AppColors.primary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Text(t, style: AppText.t(15, FontWeight.w500, AppColors.ink)),
                );
            return Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(children: [
                linha('Status das coletas', app.notifStatus, (v) => app.definirNotificacoes(status: v)),
                const Divider(height: 1, color: AppColors.line),
                linha('Dicas de descarte', app.notifDicas, (v) => app.definirNotificacoes(dicas: v)),
                const Divider(height: 1, color: AppColors.line),
                linha('Novidades do EcoScan', app.notifNovidades, (v) => app.definirNotificacoes(novidades: v)),
              ]),
            );
          },
        ),
        Builder(builder: (ctx) => EcoButton(label: 'Pronto', onPressed: () => Navigator.of(ctx).pop())),
      ]);

  // Figma: "Sheet · Privacidade"
  Future<void> _privacidade(BuildContext context) => showEcoSheet<void>(
        context,
        title: 'Privacidade',
        subtitle: 'Seus dados são usados só para orientar descartes e agendar coletas. Você pode apagar sua conta quando quiser.',
        children: [
          Builder(builder: (ctx) => EcoButton(label: 'Entendi', kind: BtnKind.secondary, onPressed: () => Navigator.of(ctx).pop())),
        ],
      );

  // Figma: "Sheet · Sobre"
  Future<void> _sobre(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        builder: (ctx) => Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.of(ctx).padding.bottom),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: EcoLockup(leaf: 36, text: 22, hero: false, veinColor: AppColors.surface),
            ),
            const SizedBox(height: 14),
            Text('Orientação de descarte e conexão com quem coleta, recebe e reaproveita resíduos.', style: AppText.body),
            const SizedBox(height: 16),
            Text('Equipe', style: AppText.label),
            const SizedBox(height: 4),
            Text('Rosangela Dias · Yago Martins · Diego Prestes · Thalia Leite', style: AppText.t(14, FontWeight.w500, AppColors.ink)),
            const SizedBox(height: 12),
            Text('Versão 1.0 (MVP)', style: AppText.caption.copyWith(fontSize: 12)),
            const SizedBox(height: 16),
            EcoButton(label: 'Fechar', kind: BtnKind.secondary, onPressed: () => Navigator.of(ctx).pop()),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) => SafeArea(
        bottom: false,
        child: ListView(padding: const EdgeInsets.fromLTRB(24, 16, 24, 24), children: [
          Center(child: Avatar(app.iniciais, size: 68, dark: true, bytes: app.fotoPerfil)),
          const SizedBox(height: 10),
          Center(child: Text(app.nome, style: AppText.t(21, FontWeight.w700, AppColors.ink, ls: -0.4))),
          const SizedBox(height: 2),
          Center(child: Text('Usuário · ${app.bairro}', style: AppText.caption.copyWith(fontSize: 14))),
          const SizedBox(height: 18),
          SoftCard(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(children: [
              _stat('${app.consultas.length}', 'consultas'),
              Container(width: 1, height: 32, color: AppColors.line),
              _stat('${app.totalColetas}', 'coletas'),
              Container(width: 1, height: 32, color: AppColors.line),
              _stat('${app.consultas.length + app.totalColetas}', 'descartes'),
            ]),
          ),
          const SizedBox(height: 14),
          GroupCard(children: [
            ListRow(
              icon: Icons.person_outline_rounded,
              title: 'Dados pessoais',
              onTap: () => Navigator.of(context).push(slideRoute(const DadosPessoaisScreen())),
            ),
            ListRow(icon: Icons.notifications_none_rounded, title: 'Notificações', onTap: () => _notificacoes(context)),
            ListRow(icon: Icons.shield_outlined, title: 'Privacidade', onTap: () => _privacidade(context)),
            ListRow(icon: Icons.info_outline_rounded, title: 'Sobre o EcoScan', onTap: () => _sobre(context)),
          ]),
          const SizedBox(height: 14),
          EcoButton(
            label: 'Sair da conta',
            icon: Icons.logout_rounded,
            kind: BtnKind.danger,
            onPressed: () {
              sessao.sair();
              Navigator.of(context).pushAndRemoveUntil(fadeRoute(const LoginScreen()), (_) => false);
            },
          ),
        ]),
      ),
    );
  }

  Widget _stat(String n, String l) => Expanded(
        child: Column(children: [
          Text(n, style: AppText.t(20, FontWeight.w700, AppColors.primary)),
          const SizedBox(height: 2),
          Text(l, style: AppText.caption.copyWith(fontSize: 12)),
        ]),
      );
}
