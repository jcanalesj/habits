class ShoppingListInfo {
  const ShoppingListInfo({
    required this.id,
    required this.name,
    this.createdAt,
  });

  final String id;
  final String name;
  final DateTime? createdAt;

  static const maxNameLength = 60;
}
