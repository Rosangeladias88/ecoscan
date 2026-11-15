import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../modelos.dart';
import '../theme.dart';

// ---------------------------------------------------------------- Navegação
Route<T> fadeRoute<T>(Widget page) => PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 550),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, child) =>
          FadeTransition(opacity: CurvedAnimation(parent: a, curve: Curves.easeOut), child: child),
    );

Route<T> slideRoute<T>(Widget page) => PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, child) {
        final c = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: c,
          child: SlideTransition(
            position: Tween(begin: const Offset(0.08, 0), end: Offset.zero).animate(c),
            child: child,
          ),
        );
      },
    );

void toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg)));
}

// ---------------------------------------------------------------- Botões
enum BtnKind { primary, secondary, text, light, danger, destructive }

class EcoButton extends StatelessWidget {
  const EcoButton({
    super.key,
    required this.label,
    this.onPressed,
    this.kind = BtnKind.primary,
    this.icon,
    this.expand = true,
    this.compact = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final BtnKind kind;
  final IconData? icon;
  final bool expand, compact;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (kind) {
      BtnKind.primary => (AppColors.primary, Colors.white),
      BtnKind.secondary => (AppColors.primarySoft, AppColors.primary),
      BtnKind.text => (Colors.transparent, AppColors.primary),
      BtnKind.light => (Colors.white, AppColors.primary),
      BtnKind.danger => (AppColors.dangerSoft, AppColors.danger),
      BtnKind.destructive => (AppColors.danger, Colors.white),
    };
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 20, color: fg), const SizedBox(width: 8)],
        Flexible(
          child: Text(label,
              overflow: TextOverflow.ellipsis, style: AppText.t(15, FontWeight.w600, fg)),
        ),
      ],
    );
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: onPressed == null ? 0.45 : 1,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: compact ? 12 : 16, horizontal: 20),
            child: content,
          ),
        ),
      ),
    );
  }
}

class CircleBtn extends StatelessWidget {
  const CircleBtn({super.key, required this.icon, this.onTap, this.dark = false, this.size = 40});
  final IconData icon;
  final VoidCallback? onTap;
  final bool dark;
  final double size;
  @override
  Widget build(BuildContext context) => Material(
        color: dark ? AppColors.white10 : AppColors.surface,
        shape: const CircleBorder(),
        elevation: 0,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: dark ? null : AppShadows.soft,
            ),
            child: Icon(icon, size: 20, color: dark ? Colors.white : AppColors.primary),
          ),
        ),
      );
}

// ---------------------------------------------------------------- Superfícies
class SoftCard extends StatelessWidget {
  const SoftCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.border, this.color});
  final Widget child;
  final EdgeInsets padding;
  final Color? border;
  final Color? color;
  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppShadows.soft,
          border: border != null ? Border.all(color: border!, width: 1.5) : null,
        ),
        child: child,
      );
}

/// Cartão com linhas separadas por divisórias finas.
class GroupCard extends StatelessWidget {
  const GroupCard({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => SoftCard(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(children: [
            for (var i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1) const Divider(height: 1, thickness: 1, color: AppColors.line, indent: 16, endIndent: 16),
            ]
          ]),
        ),
      );
}

class IconBox extends StatelessWidget {
  const IconBox({super.key, required this.icon, this.size = 40, this.active = false, this.bg, this.fg, this.radius = 12});
  final IconData icon;
  final double size;
  final bool active;
  final Color? bg, fg;
  final double radius;
  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bg ?? (active ? AppColors.primary : AppColors.primarySoft),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Icon(icon, size: size * 0.5, color: fg ?? (active ? AppColors.accent : AppColors.primary)),
      );
}

class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
    this.chevron = true,
    this.leading,
  });
  final IconData icon;
  final String title;
  final String? subtitle, value;
  final Widget? trailing, leading;
  final VoidCallback? onTap;
  final bool chevron;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            leading ?? IconBox(icon: icon),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: AppText.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: AppText.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ]),
            ),
            if (value != null) ...[
              const SizedBox(width: 8),
              Text(value!, style: AppText.t(13, FontWeight.w500, AppColors.muted)),
            ],
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            if (chevron && onTap != null) ...[
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.muted),
            ],
          ]),
        ),
      );
}

// ---------------------------------------------------------------- Cabeçalhos
class StepHeader extends StatelessWidget {
  const StepHeader({super.key, required this.step, required this.title, this.onBack, this.dark = false});
  final int step;
  final String title;
  final VoidCallback? onBack;
  final bool dark;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 10),
        child: Column(children: [
          Row(children: [
            CircleBtn(
              icon: dark ? Icons.close_rounded : Icons.arrow_back_rounded,
              dark: dark,
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Passo $step de 3',
                    style: AppText.t(12, FontWeight.w500, dark ? AppColors.accent : AppColors.muted)),
                Text(title, style: AppText.t(17, FontWeight.w700, dark ? Colors.white : AppColors.ink)),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          ProgressSegments(total: 3, done: step, dark: dark),
        ]),
      );
}

class ProgressSegments extends StatelessWidget {
  const ProgressSegments({super.key, required this.total, required this.done, this.dark = false, this.height = 4, this.current});
  final int total, done;
  final int? current;
  final bool dark;
  final double height;
  @override
  Widget build(BuildContext context) => Row(children: [
        for (var i = 1; i <= total; i++) ...[
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: i <= done ? 1 : 0),
              duration: Duration(milliseconds: 400 + i * 120),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => Container(
                height: height,
                decoration: BoxDecoration(
                  color: i == current ? AppColors.accent : (dark ? AppColors.white15 : AppColors.line),
                  borderRadius: BorderRadius.circular(height),
                ),
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: v,
                  child: Container(
                    decoration: BoxDecoration(
                      color: dark ? AppColors.accent : AppColors.primary,
                      borderRadius: BorderRadius.circular(height),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (i < total) const SizedBox(width: 6),
        ]
      ]);
}

class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.title, this.close = false, this.onBack, this.action});
  final String title;
  final bool close;
  final VoidCallback? onBack;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
        child: Row(children: [
          CircleBtn(
            icon: close ? Icons.close_rounded : Icons.arrow_back_rounded,
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: AppText.t(17, FontWeight.w700, AppColors.ink))),
          if (action != null) action!,
        ]),
      );
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.action, this.onAction});
  final String text;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Expanded(child: Text(text, style: AppText.label)),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!, style: AppText.t(13, FontWeight.w600, AppColors.primary)),
            ),
        ]),
      );
}

/// Barra inferior branca para a ação principal da tela.
class ActionBar extends StatelessWidget {
  const ActionBar({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(color: AppColors.surface, boxShadow: AppShadows.top),
        padding: EdgeInsets.fromLTRB(24, 14, 24, 14 + MediaQuery.of(context).padding.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      );
}

// ---------------------------------------------------------------- Entradas
class AppField extends StatelessWidget {
  const AppField({
    super.key,
    required this.label,
    required this.icon,
    this.controller,
    this.hint,
    this.obscure = false,
    this.keyboard,
    this.suffix,
    this.onChanged,
    this.maxLines = 1,
  });
  final String label;
  final IconData icon;
  final TextEditingController? controller;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboard;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder b(Color c, [double w = 1]) =>
        OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c, width: w));
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      onChanged: onChanged,
      maxLines: maxLines,
      style: AppText.t(15, FontWeight.w500, AppColors.ink),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: AppText.t(15, FontWeight.w400, AppColors.muted),
        labelStyle: AppText.t(14, FontWeight.w500, AppColors.muted),
        floatingLabelStyle: AppText.t(13, FontWeight.w600, AppColors.primary),
        prefixIcon: Icon(icon, size: 20, color: AppColors.muted),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: b(AppColors.line),
        focusedBorder: b(AppColors.primary, 1.5),
        border: b(AppColors.line),
      ),
    );
  }
}

class Segmented extends StatelessWidget {
  const Segmented({super.key, required this.options, required this.selected, required this.onChanged});
  final List<String> options;
  final int selected;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: AppColors.subtle, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          for (var i = 0; i < options.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: i == selected ? AppColors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: i == selected ? AppShadows.soft : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(options[i],
                      style: AppText.t(13, i == selected ? FontWeight.w600 : FontWeight.w500,
                          i == selected ? AppColors.ink : AppColors.muted)),
                ),
              ),
            ),
        ]),
      );
}

class RadioDot extends StatelessWidget {
  const RadioDot({super.key, required this.on});
  final bool on;
  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: on ? AppColors.primary : Colors.transparent,
          border: Border.all(color: on ? AppColors.primary : AppColors.line, width: 2),
        ),
        child: on ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
      );
}

// ---------------------------------------------------------------- Pequenos
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});
  final StatusPedido status;
  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (status) {
      StatusPedido.enviado => (AppColors.warnSoft, AppColors.warn),
      StatusPedido.aceito => (AppColors.accentSoft, AppColors.primary),
      StatusPedido.concluido => (AppColors.primary, Colors.white),
      StatusPedido.recusado => (AppColors.dangerSoft, AppColors.danger),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(status.label, style: AppText.t(11, FontWeight.w700, fg)),
    );
  }
}

class Tag extends StatelessWidget {
  const Tag(this.text, {super.key, this.icon});
  final String text;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(6)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 12, color: AppColors.primary), const SizedBox(width: 4)],
          Text(text, style: AppText.t(11, FontWeight.w600, AppColors.primary)),
        ]),
      );
}

class Avatar extends StatelessWidget {
  const Avatar(this.initials, {super.key, this.size = 44, this.dark = false, this.bytes});
  final String initials;
  final double size;
  final bool dark;
  final Uint8List? bytes;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: dark ? AppColors.primary : AppColors.primarySoft,
        ),
        child: bytes != null
            ? Image.memory(bytes!, width: size, height: size, fit: BoxFit.cover)
            : Text(initials,
                style: AppText.t(size * 0.33, FontWeight.w700, dark ? AppColors.accent : AppColors.primary)),
      );
}

/// Miniatura da foto do resíduo (ou ícone sobre gradiente quando não há foto).
class PhotoThumb extends StatelessWidget {
  const PhotoThumb({super.key, this.bytes, required this.icon, this.size = 48, this.radius = 12});
  final Uint8List? bytes;
  final IconData icon;
  final double size, radius;
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          width: size,
          height: size,
          child: bytes != null
              ? Image.memory(bytes!, fit: BoxFit.cover)
              : DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFEDBD54), Color(0xFFC78526)],
                    ),
                  ),
                  child: Icon(icon, color: Colors.white, size: size * 0.45),
                ),
        ),
      );
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.text});
  final IconData icon;
  final String title, text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(children: [
          IconBox(icon: icon, size: 64, radius: 20),
          const SizedBox(height: 16),
          Text(title, style: AppText.section, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(text, style: AppText.caption, textAlign: TextAlign.center),
        ]),
      );
}

/// Entrada suave (fade + subida) com atraso, para listas e cartões.
class FadeIn extends StatelessWidget {
  const FadeIn({super.key, required this.child, this.delay = 0});
  final Widget child;
  final int delay; // ms
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 450 + delay),
        curve: Interval(delay / (450 + delay), 1, curve: Curves.easeOutCubic),
        builder: (_, v, c) => Opacity(
          opacity: v,
          child: Transform.translate(offset: Offset(0, (1 - v) * 14), child: c),
        ),
        child: child,
      );
}
