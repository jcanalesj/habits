/// Un artículo de la lista de la compra.
class ShoppingItem {
  const ShoppingItem({
    required this.id,
    required this.name,
    this.quantity,
    this.note,
    this.boughtAt,
    this.createdAt,
  });

  final String id;
  final String name;
  final int? quantity;
  final String? note;

  /// Marcado en el carrito.
  final DateTime? boughtAt;
  final DateTime? createdAt;

  bool get isBought => boughtAt != null;

  static const maxNameLength = 80;
  static const maxNoteLength = 120;
  static const maxQuantity = 999;
}

/// Datos de alta o edición.
class ShoppingDraft {
  const ShoppingDraft({required this.name, this.quantity, this.note});

  final String name;
  final int? quantity;
  final String? note;

  bool get isValid =>
      name.trim().isNotEmpty &&
      name.trim().length <= ShoppingItem.maxNameLength &&
      (quantity == null ||
          (quantity! >= 1 && quantity! <= ShoppingItem.maxQuantity)) &&
      (note == null || note!.length <= ShoppingItem.maxNoteLength);

  /// "2 leche" → cantidad 2, nombre "leche". Sin número inicial, todo es
  /// nombre. Solo se aplica a la entrada rápida.
  static ShoppingDraft parseQuick(String raw) {
    final text = raw.trim();
    final match = RegExp(r'^(\d{1,3})\s*[xX×]?\s+(.+)$').firstMatch(text);
    if (match == null) return ShoppingDraft(name: text);
    final quantity = int.parse(match.group(1)!);
    if (quantity < 1) return ShoppingDraft(name: text);
    return ShoppingDraft(name: match.group(2)!.trim(), quantity: quantity);
  }
}

/// Orden de la lista: pendientes por fecha de alta (los últimos primero);
/// comprados por fecha de compra (los últimos primero).
int compareShoppingItems(ShoppingItem a, ShoppingItem b) {
  if (a.isBought != b.isBought) return a.isBought ? 1 : -1;
  if (a.isBought) {
    return (b.boughtAt ?? DateTime(0)).compareTo(a.boughtAt ?? DateTime(0));
  }
  return (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0));
}
