import 'package:flutter/material.dart';

import '../theme.dart';
import 'common.dart';

/// Painel que sobe de baixo — equivale aos frames "Sheet · ..." do Figma.
Future<T?> showEcoSheet<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  required List<Widget> children,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) {
      final mq = MediaQuery.of(ctx);
      return Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + mq.viewInsets.bottom + mq.padding.bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: AppText.title),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle, style: AppText.caption.copyWith(fontSize: 14)),
              ],
              const SizedBox(height: 16),
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      );
    },
  );
}

/// Lista de opções com seleção única (radio).
class OptionList extends StatelessWidget {
  const OptionList({super.key, required this.options, required this.selected, required this.onChanged});
  final List<String> options;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(children: [
          for (var i = 0; i < options.length; i++)
            Material(
              color: i == selected ? AppColors.accentSoft : Colors.transparent,
              child: InkWell(
                onTap: () => onChanged(i),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 13, 16, 13),
                  child: Row(children: [
                    RadioDot(on: i == selected),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(options[i],
                          style: AppText.t(14, i == selected ? FontWeight.w600 : FontWeight.w400, AppColors.ink)),
                    ),
                  ]),
                ),
              ),
            ),
        ]),
      );
}

/// Linhas de informação simples (ícone + texto), usadas nos detalhes de pedido.
class InfoRows extends StatelessWidget {
  const InfoRows(this.rows, {super.key});
  final List<(IconData, String)> rows;
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(children: [
          for (var i = 0; i < rows.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                border: i < rows.length - 1 ? const Border(bottom: BorderSide(color: AppColors.line)) : null,
              ),
              child: Row(children: [
                Icon(rows[i].$1, size: 16, color: AppColors.muted),
                const SizedBox(width: 10),
                Expanded(child: Text(rows[i].$2, style: AppText.t(14, FontWeight.w500, AppColors.ink))),
              ]),
            ),
        ]),
      );
}

/// Escolha de uma opção. Devolve o índice escolhido (ou null se fechar).
Future<int?> showOptionsSheet(
  BuildContext context, {
  required String title,
  String? subtitle,
  required List<String> options,
  required int selected,
  String confirm = 'Confirmar',
}) {
  var sel = selected;
  return showEcoSheet<int>(context, title: title, subtitle: subtitle, children: [
    StatefulBuilder(
      builder: (ctx, setS) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        OptionList(options: options, selected: sel, onChanged: (i) => setS(() => sel = i)),
        const SizedBox(height: 16),
        EcoButton(label: confirm, onPressed: () => Navigator.of(ctx).pop(sel)),
      ]),
    ),
  ]);
}

/// Contador de quantidade (− valor +). Devolve o novo valor.
Future<int?> showCounterSheet(
  BuildContext context, {
  required String title,
  String? subtitle,
  required int value,
  required String Function(int) label,
  String? Function(int)? hint,
  int min = 1,
  int max = 20,
}) {
  var v = value;
  return showEcoSheet<int>(context, title: title, subtitle: subtitle, children: [
    StatefulBuilder(
      builder: (ctx, setS) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(children: [
            _CounterBtn(icon: Icons.remove_rounded, onTap: v > min ? () => setS(() => v--) : null),
            Expanded(
              child: Column(children: [
                Text(label(v), style: AppText.t(15, FontWeight.w700, AppColors.ink)),
                if (hint?.call(v) != null) Text(hint!(v)!, style: AppText.caption.copyWith(fontSize: 12)),
              ]),
            ),
            _CounterBtn(icon: Icons.add_rounded, filled: true, onTap: v < max ? () => setS(() => v++) : null),
          ]),
        ),
        const SizedBox(height: 16),
        EcoButton(label: 'Confirmar', onPressed: () => Navigator.of(ctx).pop(v)),
      ]),
    ),
  ]);
}

class _CounterBtn extends StatelessWidget {
  const _CounterBtn({required this.icon, this.onTap, this.filled = false});
  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;
  @override
  Widget build(BuildContext context) => Opacity(
        opacity: onTap == null ? 0.4 : 1,
        child: Material(
          color: filled ? AppColors.primary : AppColors.primarySoft,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(icon, size: 18, color: filled ? Colors.white : AppColors.primary),
            ),
          ),
        ),
      );
}

/// Campos de texto + botão de salvar. Devolve true se salvou.
/// Os controllers pertencem a quem chama (crie e descarte no State).
Future<bool> showFieldsSheet(
  BuildContext context, {
  required String title,
  String? subtitle,
  required List<Widget> fields,
  String confirm = 'Salvar',
  String? cancel,
}) async {
  final ok = await showEcoSheet<bool>(context, title: title, subtitle: subtitle, children: [
    ...fields,
    Builder(
      builder: (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 4),
        EcoButton(label: confirm, onPressed: () => Navigator.of(ctx).pop(true)),
        if (cancel != null) ...[
          const SizedBox(height: 4),
          EcoButton(label: cancel, kind: BtnKind.text, compact: true, onPressed: () => Navigator.of(ctx).pop(false)),
        ],
      ]),
    ),
  ]);
  return ok ?? false;
}

/// Confirmação simples (ex.: ligar, recusar pedido). Devolve true se confirmou.
Future<bool> showConfirmSheet(
  BuildContext context, {
  required String title,
  String? subtitle,
  required String confirm,
  String cancel = 'Cancelar',
  bool destructive = false,
}) async {
  final ok = await showEcoSheet<bool>(context, title: title, subtitle: subtitle, children: [
    Builder(
      builder: (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        EcoButton(
          label: confirm,
          kind: destructive ? BtnKind.destructive : BtnKind.primary,
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
        const SizedBox(height: 4),
        EcoButton(label: cancel, kind: BtnKind.text, compact: true, onPressed: () => Navigator.of(ctx).pop(false)),
      ]),
    ),
  ]);
  return ok ?? false;
}
