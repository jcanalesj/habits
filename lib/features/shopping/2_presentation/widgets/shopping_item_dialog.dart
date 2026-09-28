import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/shopping/0_entity/entity.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Editar un artículo (nombre, cantidad, nota).
Future<ShoppingDraft?> showShoppingItemDialog(
  BuildContext context, {
  required ShoppingItem item,
}) => showDialog<ShoppingDraft>(
  context: context,
  barrierColor: context.palette.scrim,
  builder: (_) => _ShoppingItemDialog(item: item),
);

class _ShoppingItemDialog extends StatefulWidget {
  const _ShoppingItemDialog({required this.item});
  final ShoppingItem item;

  @override
  State<_ShoppingItemDialog> createState() => _ShoppingItemDialogState();
}

class _ShoppingItemDialogState extends State<_ShoppingItemDialog> {
  late final _name = TextEditingController(text: widget.item.name);
  late final _quantity = TextEditingController(
    text: widget.item.quantity?.toString() ?? '',
  );
  late final _note = TextEditingController(text: widget.item.note ?? '');

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    _note.dispose();
    super.dispose();
  }

  ShoppingDraft get _draft => ShoppingDraft(
    name: _name.text,
    quantity: int.tryParse(_quantity.text.trim()),
    note: _note.text.trim().isEmpty ? null : _note.text.trim(),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = _draft;
    return AppFormDialog(
      key: const ValueKey('shopping-item-dialog'),
      hero: const AppDialogHero.icon(
        icon: PhosphorIconsFill.shoppingCart,
        color: AppColors.blue,
      ),
      title: l10n.shoppingEditItem,
      primaryLabel: l10n.shoppingSave,
      primaryKey: const ValueKey('shopping-item-save'),
      onPrimary: draft.isValid ? () => Navigator.pop(context, draft) : null,
      children: [
        AppTextField(
          key: const ValueKey('shopping-name-field'),
          controller: _name,
          label: l10n.shoppingNameLabel,
          prefixIcon: PhosphorIconsBold.basket,
          maxLength: ShoppingItem.maxNameLength,
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        AppTextField(
          key: const ValueKey('shopping-quantity-field'),
          controller: _quantity,
          label: l10n.shoppingQuantityLabel,
          prefixIcon: PhosphorIconsBold.hash,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: _note,
          label: l10n.shoppingNoteLabel,
          prefixIcon: PhosphorIconsBold.notePencil,
          maxLength: ShoppingItem.maxNoteLength,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }
}
