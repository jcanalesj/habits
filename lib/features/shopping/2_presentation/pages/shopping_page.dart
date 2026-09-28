import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/shopping/0_entity/entity.dart';
import 'package:habits/features/shopping/2_presentation/providers/shopping_providers.dart';
import 'package:habits/features/shopping/2_presentation/widgets/shopping_item_dialog.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

enum _ShoppingMenu { clearBought, clearAll }

/// Lista de la compra: entrada rápida, "Por comprar" y "En el carrito".
class ShoppingPage extends ConsumerStatefulWidget {
  const ShoppingPage({super.key});

  @override
  ConsumerState<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends ConsumerState<ShoppingPage> {
  final _input = TextEditingController();
  final _focus = FocusNode();
  bool _cartExpanded = false;

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _addQuick() async {
    final draft = ShoppingDraft.parseQuick(_input.text);
    if (!draft.isValid) return;
    _input.clear();
    // El campo queda listo para el siguiente artículo.
    _focus.requestFocus();
    try {
      await ref.read(shoppingRepositoryProvider).add(draft);
    } catch (_) {
      if (!mounted) return;
      AppNotice.show(
        context,
        message: context.l10n.shoppingSaveError,
        type: AppNoticeType.error,
      );
    }
  }

  Future<void> _edit(ShoppingItem item) async {
    final draft = await showShoppingItemDialog(context, item: item);
    if (draft == null || !mounted) return;
    await ref.read(shoppingRepositoryProvider).update(item.id, draft);
  }

  Future<void> _delete(ShoppingItem item) async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: l10n.shoppingDeleteTitle,
      body: item.name,
    );
    if (!confirmed || !mounted) return;
    await ref.read(shoppingRepositoryProvider).delete(item.id);
  }

  Future<void> _onMenu(_ShoppingMenu action) async {
    final l10n = context.l10n;
    final all = action == _ShoppingMenu.clearAll;
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: all ? l10n.shoppingClearAllTitle : l10n.shoppingClearBoughtTitle,
      body: all ? l10n.shoppingClearAllBody : l10n.shoppingClearBoughtBody,
    );
    if (!confirmed || !mounted) return;
    await ref.read(shoppingRepositoryProvider).clear(all: all);
    if (!mounted) return;
    AppNotice.show(context, message: l10n.shoppingCleared);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final items = ref.watch(shoppingItemsProvider);
    final list = items.value ?? const <ShoppingItem>[];
    final pending = list.where((item) => !item.isBought).toList();
    final bought = list.where((item) => item.isBought).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.shoppingTitle,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          PopupMenuButton<_ShoppingMenu>(
            key: const ValueKey('shopping-menu'),
            icon: const Icon(PhosphorIconsBold.dotsThreeVertical),
            onSelected: _onMenu,
            itemBuilder: (context) => [
              PopupMenuItem(
                key: const ValueKey('shopping-clear-bought'),
                value: _ShoppingMenu.clearBought,
                enabled: bought.isNotEmpty,
                child: Text(l10n.shoppingClearBought),
              ),
              PopupMenuItem(
                key: const ValueKey('shopping-clear-all'),
                value: _ShoppingMenu.clearAll,
                enabled: list.isNotEmpty,
                child: Text(l10n.shoppingClearAll),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    key: const ValueKey('shopping-quick-input'),
                    controller: _input,
                    focusNode: _focus,
                    hint: l10n.shoppingAddHint,
                    prefixIcon: PhosphorIconsBold.plus,
                    maxLength: ShoppingItem.maxNameLength + 4,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addQuick(),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.tonal(
                  key: const ValueKey('shopping-quick-add'),
                  onPressed: _addQuick,
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.tint(AppColors.blue, .14),
                    foregroundColor: palette.isDark
                        ? AppColors.blue
                        : const Color(0xFF0E7EA8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  child: Text(l10n.shoppingAdd),
                ),
              ],
            ),
          ),
          Expanded(
            child: switch (items) {
              AsyncError(:final error) => AppErrorView(
                error: error,
                onRetry: () => ref.invalidate(shoppingItemsProvider),
              ),
              _ => ListView(
                key: const ValueKey('shopping-page'),
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  40 + MediaQuery.viewPaddingOf(context).bottom,
                ),
                children: [
                  if (list.isEmpty && !items.isLoading)
                    EmptyStateBlock(
                      icon: PhosphorIconsRegular.shoppingCart,
                      text: l10n.shoppingEmpty,
                      color: AppColors.blue,
                    ),
                  if (pending.isNotEmpty) ...[
                    _SectionLabel('${l10n.shoppingToBuy} · ${pending.length}'),
                    _ItemsCard(
                      items: pending,
                      onToggle: (item) => ref
                          .read(shoppingRepositoryProvider)
                          .setBought(item.id, true),
                      onTap: _edit,
                      onDelete: _delete,
                    ),
                  ],
                  if (bought.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    InkWell(
                      key: const ValueKey('shopping-cart-toggle'),
                      onTap: () =>
                          setState(() => _cartExpanded = !_cartExpanded),
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: _SectionLabel(
                              '${l10n.shoppingInCart} · ${bought.length}',
                            ),
                          ),
                          Icon(
                            _cartExpanded
                                ? PhosphorIconsBold.caretUp
                                : PhosphorIconsBold.caretDown,
                            size: 16,
                            color: palette.textSecondary,
                          ),
                        ],
                      ),
                    ),
                    if (_cartExpanded)
                      _ItemsCard(
                        items: bought,
                        onToggle: (item) => ref
                            .read(shoppingRepositoryProvider)
                            .setBought(item.id, false),
                        onTap: _edit,
                        onDelete: _delete,
                      ),
                  ],
                  if (items.isLoading) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: CircularProgressIndicator(color: palette.primary),
                    ),
                  ],
                ],
              ),
            },
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 6, 4, 8),
    child: Text(
      text,
      style: TextStyle(
        color: context.palette.textSecondary,
        fontWeight: FontWeight.w800,
        fontSize: 13,
      ),
    ),
  );
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({
    required this.items,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  final List<ShoppingItem> items;
  final void Function(ShoppingItem item) onToggle;
  final void Function(ShoppingItem item) onTap;
  final void Function(ShoppingItem item) onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: surfaceDecoration(palette),
      child: Column(
        children: [
          for (final (index, item) in items.indexed) ...[
            if (index > 0)
              Divider(height: 1, indent: 56, color: palette.divider),
            Dismissible(
              key: ValueKey('shopping-${item.id}'),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) async {
                onDelete(item);
                return false;
              },
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 22),
                color: dangerColor.withValues(alpha: .12),
                child: const Icon(PhosphorIconsBold.trash, color: dangerColor),
              ),
              child: _ShoppingTile(
                item: item,
                onToggle: () => onToggle(item),
                onTap: () => onTap(item),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ShoppingTile extends StatelessWidget {
  const _ShoppingTile({
    required this.item,
    required this.onToggle,
    required this.onTap,
  });

  final ShoppingItem item;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final bought = item.isBought;
    final details = [
      if (item.quantity != null) l10n.shoppingQuantityShort(item.quantity!),
      if (item.note?.isNotEmpty ?? false) item.note!,
    ].join('  ·  ');

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
        child: Row(
          children: [
            Semantics(
              button: true,
              checked: bought,
              label: bought
                  ? l10n.shoppingMarkPending(item.name)
                  : l10n.shoppingMarkBought(item.name),
              child: InkWell(
                key: ValueKey('shopping-toggle-${item.id}'),
                onTap: onToggle,
                customBorder: const CircleBorder(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: bought ? AppColors.blue : Colors.transparent,
                    border: Border.all(
                      color: bought ? AppColors.blue : palette.textHint,
                      width: 2,
                    ),
                  ),
                  child: bought
                      ? const Icon(
                          PhosphorIconsBold.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: bought
                          ? palette.textSecondary
                          : palette.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      decoration: bought ? TextDecoration.lineThrough : null,
                      decorationColor: palette.textSecondary,
                    ),
                  ),
                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      details,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              PhosphorIconsBold.caretRight,
              color: palette.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
