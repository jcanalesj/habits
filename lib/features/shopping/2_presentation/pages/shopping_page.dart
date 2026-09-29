import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/shopping/0_entity/entity.dart';
import 'package:habits/features/shopping/2_presentation/providers/shopping_providers.dart';
import 'package:habits/features/shopping/2_presentation/widgets/shopping_item_dialog.dart';
import 'package:habits/features/shopping/3_data/repositories/firestore_shopping_repository.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:share_plus/share_plus.dart';

enum _ShoppingMenu { clearBought, clearAll, renameList, deleteList }

class ShoppingPage extends ConsumerStatefulWidget {
  const ShoppingPage({super.key});

  @override
  ConsumerState<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends ConsumerState<ShoppingPage> {
  final _input = TextEditingController();
  final _focus = FocusNode();
  String _selectedListId = FirestoreShoppingRepository.defaultListId;
  bool _cartExpanded = false;
  bool _listsExpanded = true;
  bool _completionDialogVisible = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_collapseListsWhileEditing);
  }

  void _collapseListsWhileEditing() {
    if (_focus.hasFocus && _listsExpanded) {
      setState(() => _listsExpanded = false);
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_collapseListsWhileEditing);
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _addQuick() async {
    final draft = ShoppingDraft.parseQuick(_input.text);
    if (!draft.isValid) return;
    _input.clear();
    _focus.requestFocus();
    try {
      await ref.read(shoppingRepositoryProvider).add(_selectedListId, draft);
    } catch (_) {
      if (mounted) {
        AppNotice.show(
          context,
          message: context.l10n.shoppingSaveError,
          type: AppNoticeType.error,
        );
      }
    }
  }

  Future<void> _edit(ShoppingItem item) async {
    final draft = await showShoppingItemDialog(context, item: item);
    if (draft == null || !mounted) return;
    await ref
        .read(shoppingRepositoryProvider)
        .update(_selectedListId, item.id, draft);
  }

  Future<void> _delete(ShoppingItem item) async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: l10n.shoppingDeleteTitle,
      body: item.name,
    );
    if (!confirmed || !mounted) return;
    await ref.read(shoppingRepositoryProvider).delete(_selectedListId, item.id);
  }

  Future<void> _markAsBought(
    ShoppingListInfo list,
    ShoppingItem item,
    int pendingCount,
  ) async {
    final completesList = pendingCount == 1;
    await ref
        .read(shoppingRepositoryProvider)
        .setBought(list.id, item.id, true);
    if (!completesList || !mounted || _completionDialogVisible) return;

    _completionDialogVisible = true;
    try {
      await showDialog<void>(
        context: context,
        barrierColor: context.palette.scrim,
        builder: (dialogContext) => AppFormDialog(
          key: const ValueKey('shopping-completed-dialog'),
          hero: const AppDialogHero.cat(
            badge: PhosphorIconsBold.check,
            color: AppColors.green,
            asset: 'assets/images/shopping/shopping_share_cat.png',
          ),
          title: context.l10n.shoppingCompletedTitle,
          helper: context.l10n.shoppingCompletedBody,
          primaryLabel: context.l10n.continueLabel,
          primaryIcon: PhosphorIconsBold.sparkle,
          primaryColor: AppColors.green,
          primaryKey: const ValueKey('shopping-completed-ok'),
          onPrimary: () => Navigator.pop(dialogContext),
          secondaryLabel: context.l10n.cancel,
        ),
      );
    } finally {
      _completionDialogVisible = false;
    }
  }

  Future<String?> _askListName({String? initial}) async {
    final controller = TextEditingController(text: initial);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AppFormDialog(
        key: const ValueKey('shopping-list-dialog'),
        hero: const AppDialogHero.cat(badge: PhosphorIconsBold.shoppingBag),
        title: initial == null
            ? context.l10n.shoppingCreateList
            : context.l10n.shoppingRenameList,
        primaryLabel: context.l10n.save,
        primaryKey: const ValueKey('shopping-list-save'),
        onPrimary: () {
          final name = controller.text.trim();
          if (name.isNotEmpty &&
              name.length <= ShoppingListInfo.maxNameLength) {
            Navigator.pop(dialogContext, name);
          }
        },
        children: [
          AppTextField(
            key: const ValueKey('shopping-list-name'),
            controller: controller,
            label: context.l10n.shoppingListName,
            maxLength: ShoppingListInfo.maxNameLength,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              final name = controller.text.trim();
              if (name.isNotEmpty) Navigator.pop(dialogContext, name);
            },
          ),
        ],
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
    return result;
  }

  Future<void> _createList() async {
    final name = await _askListName();
    if (name == null || !mounted) return;
    final id = await ref.read(shoppingRepositoryProvider).createList(name);
    if (mounted) {
      setState(() {
        _selectedListId = id;
      });
    }
  }

  Future<void> _onMenu(
    _ShoppingMenu action,
    ShoppingListInfo selected,
    List<ShoppingItem> items,
  ) async {
    final l10n = context.l10n;
    final repository = ref.read(shoppingRepositoryProvider);
    if (action == _ShoppingMenu.renameList) {
      final name = await _askListName(initial: selected.name);
      if (name != null) await repository.renameList(selected.id, name);
      return;
    }
    if (action == _ShoppingMenu.deleteList) {
      final confirmed = await showConfirmDeleteDialog(
        context,
        title: l10n.shoppingDeleteListTitle,
        body: l10n.shoppingDeleteListBody(selected.name),
      );
      if (!confirmed || !mounted) return;
      await repository.deleteList(selected.id);
      if (mounted) {
        setState(
          () => _selectedListId = FirestoreShoppingRepository.defaultListId,
        );
      }
      return;
    }
    final all = action == _ShoppingMenu.clearAll;
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: all ? l10n.shoppingClearAllTitle : l10n.shoppingClearBoughtTitle,
      body: all ? l10n.shoppingClearAllBody : l10n.shoppingClearBoughtBody,
    );
    if (!confirmed || !mounted) return;
    await repository.clear(selected.id, all: all);
    if (mounted) AppNotice.show(context, message: l10n.shoppingCleared);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final listsAsync = ref.watch(shoppingListsProvider);
    final lists = listsAsync.value ?? const <ShoppingListInfo>[];
    final selected = lists.firstWhere(
      (list) => list.id == _selectedListId,
      orElse: () => const ShoppingListInfo(
        id: FirestoreShoppingRepository.defaultListId,
        name: 'Supermercado',
      ),
    );
    final itemsAsync = ref.watch(shoppingItemsProvider(selected.id));
    final items = itemsAsync.value ?? const <ShoppingItem>[];
    final pending = items.where((item) => !item.isBought).toList();
    final bought = items.where((item) => item.isBought).toList();
    final progress = items.isEmpty ? 0.0 : bought.length / items.length;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Semantics(
          button: true,
          expanded: _listsExpanded,
          child: InkWell(
            key: const ValueKey('shopping-lists-toggle'),
            onTap: () => setState(() => _listsExpanded = !_listsExpanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.shoppingListsTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: _listsExpanded ? .5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      PhosphorIconsBold.caretDown,
                      size: 17,
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          IconButton.filled(
            key: const ValueKey('shopping-new-list'),
            onPressed: _createList,
            tooltip: l10n.shoppingCreateList,
            icon: const Icon(PhosphorIconsBold.plus),
            style: IconButton.styleFrom(
              minimumSize: const Size.square(52),
              iconSize: 25,
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Column(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _listsExpanded
                ? SizedBox(
                    height: 190,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: lists.length + 1,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        if (index == lists.length) {
                          return _NewListCard(onTap: _createList);
                        }
                        final list = lists[index];
                        return _ShoppingListCard(
                          list: list,
                          selected: list.id == selected.id,
                          onTap: () => setState(() {
                            _selectedListId = list.id;
                            _cartExpanded = false;
                          }),
                        );
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: ListView(
              key: const ValueKey('shopping-page'),
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                32 + MediaQuery.viewPaddingOf(context).bottom,
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selected.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -.7,
                            ),
                      ),
                    ),
                    IconButton.filledTonal(
                      key: const ValueKey('shopping-share'),
                      onPressed: items.isEmpty
                          ? null
                          : () => showDialog<void>(
                              context: context,
                              barrierColor: context.palette.scrim,
                              builder: (_) => _ShareListDialog(
                                list: selected,
                                items: items,
                              ),
                            ),
                      tooltip: l10n.shoppingShare,
                      icon: const Icon(PhosphorIconsBold.shareNetwork),
                    ),
                    PopupMenuButton<_ShoppingMenu>(
                      key: const ValueKey('shopping-menu'),
                      icon: const Icon(PhosphorIconsBold.dotsThreeVertical),
                      onSelected: (action) => _onMenu(action, selected, items),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: _ShoppingMenu.renameList,
                          child: Text(l10n.shoppingRenameList),
                        ),
                        PopupMenuItem(
                          key: const ValueKey('shopping-clear-bought'),
                          value: _ShoppingMenu.clearBought,
                          enabled: bought.isNotEmpty,
                          child: Text(l10n.shoppingClearBought),
                        ),
                        PopupMenuItem(
                          key: const ValueKey('shopping-clear-all'),
                          value: _ShoppingMenu.clearAll,
                          enabled: items.isNotEmpty,
                          child: Text(l10n.shoppingClearAll),
                        ),
                        if (selected.id !=
                            FirestoreShoppingRepository.defaultListId)
                          PopupMenuItem(
                            value: _ShoppingMenu.deleteList,
                            child: Text(
                              l10n.shoppingDeleteList,
                              style: TextStyle(color: dangerColor),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.shoppingProgress(bought.length, items.length),
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                _ShoppingProgress(
                  progress: progress,
                  label: items.isEmpty
                      ? l10n.shoppingPendingWithCount(0)
                      : l10n.shoppingProgress(bought.length, items.length),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: palette.surface,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: palette.border),
                        ),
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
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      key: const ValueKey('shopping-quick-add'),
                      onPressed: _addQuick,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(64, 64),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: const Icon(PhosphorIconsBold.arrowUp, size: 26),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (items.isEmpty && !itemsAsync.isLoading)
                  _ShoppingEmptyState(
                    title: l10n.shoppingEmptyTitle,
                    body: l10n.shoppingEmptyBody,
                  ),
                if (pending.isNotEmpty) ...[
                  _SectionLabel('${l10n.shoppingToBuy} · ${pending.length}'),
                  _ItemsCard(
                    items: pending,
                    onToggle: (item) =>
                        _markAsBought(selected, item, pending.length),
                    onTap: _edit,
                    onDelete: _delete,
                  ),
                ],
                if (bought.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  InkWell(
                    key: const ValueKey('shopping-cart-toggle'),
                    onTap: () => setState(() => _cartExpanded = !_cartExpanded),
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
                          .setBought(selected.id, item.id, false),
                      onTap: _edit,
                      onDelete: _delete,
                    ),
                ],
                if (itemsAsync.isLoading || listsAsync.isLoading) ...[
                  const SizedBox(height: 24),
                  Center(
                    child: CircularProgressIndicator(color: palette.primary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShoppingProgress extends StatelessWidget {
  const _ShoppingProgress({required this.progress, required this.label});

  final double progress;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: palette.primarySoft.withValues(alpha: palette.isDark ? .55 : .5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 30,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 4,
              strokeCap: StrokeCap.round,
              backgroundColor: palette.divider,
              color: palette.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '${(progress * 100).round()}%',
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShoppingEmptyState extends StatelessWidget {
  const _ShoppingEmptyState({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withValues(alpha: .12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/images/shopping/shopping_empty_cart_cat.png',
            height: 132,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShoppingListCard extends ConsumerWidget {
  const _ShoppingListCard({
    required this.list,
    required this.selected,
    required this.onTap,
  });

  final ShoppingListInfo list;
  final bool selected;
  final VoidCallback onTap;

  bool get _isBirthday {
    final value = list.name.toLowerCase();
    return value.contains('cumple') ||
        value.contains('regalo') ||
        value.contains('birthday');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final items = ref.watch(shoppingItemsProvider(list.id)).value ?? const [];
    final pending = items.where((item) => !item.isBought).length;
    final accent = _isBirthday ? AppColors.pink : AppColors.blue;
    final asset = _isBirthday
        ? 'assets/images/shopping/shopping_birthday_cat.png'
        : 'assets/images/shopping/shopping_groceries_cat.png';
    return InkWell(
      key: ValueKey('shopping-list-${list.id}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 184,
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: BoxDecoration(
          color: palette.tint(accent, selected ? .16 : .09),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: selected ? palette.primary : palette.tint(accent, .28),
            width: selected ? 3 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: palette.primary.withValues(alpha: .12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(child: Image.asset(asset, fit: BoxFit.contain)),
            ),
            Text(
              list.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
            ),
            const SizedBox(height: 2),
            Text(
              context.l10n.shoppingPendingWithCount(pending),
              maxLines: 1,
              style: TextStyle(color: palette.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewListCard extends StatelessWidget {
  const _NewListCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    key: const ValueKey('shopping-list-new-card'),
    onTap: onTap,
    borderRadius: BorderRadius.circular(26),
    child: Container(
      width: 132,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: context.palette.primary.withValues(alpha: .35),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: context.palette.primarySoft,
            child: Icon(PhosphorIconsBold.plus, color: context.palette.primary),
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.shoppingNewList,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    ),
  );
}

class _ShareListDialog extends StatefulWidget {
  const _ShareListDialog({required this.list, required this.items});
  final ShoppingListInfo list;
  final List<ShoppingItem> items;

  @override
  State<_ShareListDialog> createState() => _ShareListDialogState();
}

class _ShareListDialogState extends State<_ShareListDialog> {
  final _boundaryKey = GlobalKey();
  bool _busy = false;

  String _text(BuildContext context) {
    final buffer = StringBuffer('🛍️ ${widget.list.name}\n\n');
    for (final item in widget.items) {
      buffer.writeln(
        '${item.isBought ? '✅' : '⬜'} ${item.name}'
        '${item.quantity == null ? '' : ' ×${item.quantity}'}',
      );
    }
    buffer.write('\n🐱 Constanza');
    return buffer.toString();
  }

  Rect? _origin() {
    final box = context.findRenderObject() as RenderBox?;
    return box == null ? null : box.localToGlobal(Offset.zero) & box.size;
  }

  Future<void> _shareText() => SharePlus.instance.share(
    ShareParams(text: _text(context), sharePositionOrigin: _origin()),
  );

  Future<void> _shareImage() async {
    setState(() => _busy = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          _boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (bytes == null) return;
      final directory = await getTemporaryDirectory();
      final safeName = widget.list.name.toLowerCase().replaceAll(
        RegExp(r'[^a-z0-9]+'),
        '-',
      );
      final file = File('${directory.path}/constanza-$safeName.png');
      await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: widget.list.name,
          sharePositionOrigin: _origin(),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    return Dialog(
      key: const ValueKey('shopping-share-dialog'),
      backgroundColor: palette.dialogSurface,
      insetPadding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: RepaintBoundary(
                  key: _boundaryKey,
                  child: _ExportCard(list: widget.list, items: widget.items),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      key: const ValueKey('shopping-share-image'),
                      onPressed: _busy ? null : _shareImage,
                      icon: _busy
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(PhosphorIconsBold.image),
                      label: Text(l10n.shoppingShareImage),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        foregroundColor: palette.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      key: const ValueKey('shopping-share-text'),
                      onPressed: _shareText,
                      icon: const Icon(PhosphorIconsBold.textT),
                      label: Text(l10n.shoppingShareText),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        foregroundColor: palette.textPrimary,
                        backgroundColor: palette.primarySoft,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: palette.primaryDeep,
                ),
                child: Text(
                  l10n.cancel,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExportCard extends StatelessWidget {
  const _ExportCard({required this.list, required this.items});
  final ShoppingListInfo list;
  final List<ShoppingItem> items;

  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFFF7F3FF),
    padding: const EdgeInsets.all(24),
    child: Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x187C5CE0),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 126,
            child: Image.asset(
              'assets/images/shopping/shopping_share_cat.png',
              fit: BoxFit.contain,
            ),
          ),
          Text(
            list.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF2B214A),
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          for (final item in items.take(10))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Icon(
                    item.isBought
                        ? PhosphorIconsFill.checkCircle
                        : PhosphorIconsRegular.circle,
                    color: item.isBought
                        ? AppColors.primary
                        : const Color(0xFF9B94AA),
                    size: 21,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(
                        color: const Color(0xFF403852),
                        fontWeight: FontWeight.w700,
                        decoration: item.isBought
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  if (item.quantity != null)
                    Text(
                      '×${item.quantity}',
                      style: const TextStyle(color: Color(0xFF7C5CE0)),
                    ),
                ],
              ),
            ),
          if (items.length > 10)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '+${items.length - 10}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF7C5CE0)),
              ),
            ),
          const SizedBox(height: 14),
          const Text(
            'Constanza ♡',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8C82A2),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );
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
  final void Function(ShoppingItem) onToggle;
  final void Function(ShoppingItem) onTap;
  final void Function(ShoppingItem) onDelete;

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: surfaceDecoration(context.palette),
    child: Column(
      children: [
        for (final (index, item) in items.indexed) ...[
          if (index > 0)
            Divider(height: 1, indent: 60, color: context.palette.divider),
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

class _ShoppingTile extends StatelessWidget {
  const _ShoppingTile({
    required this.item,
    required this.onToggle,
    required this.onTap,
  });
  final ShoppingItem item;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  IconData get _icon {
    final name = item.name.toLowerCase();
    if (name.contains('leche')) return PhosphorIconsFill.pintGlass;
    if (name.contains('pan')) return PhosphorIconsFill.bread;
    if (name.contains('café') || name.contains('cafe')) {
      return PhosphorIconsFill.coffee;
    }
    if (name.contains('tomate') || name.contains('fruta')) {
      return PhosphorIconsFill.orange;
    }
    return PhosphorIconsFill.shoppingBag;
  }

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
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        child: Row(
          children: [
            InkWell(
              key: ValueKey('shopping-toggle-${item.id}'),
              onTap: onToggle,
              customBorder: const CircleBorder(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bought ? palette.primary : Colors.transparent,
                  border: Border.all(
                    color: bought ? palette.primary : palette.textHint,
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
            const SizedBox(width: 10),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: palette.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: palette.primary, size: 21),
            ),
            const SizedBox(width: 11),
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
                      fontWeight: FontWeight.w800,
                      decoration: bought ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (details.isNotEmpty)
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
