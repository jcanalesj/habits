import 'package:habits/features/shopping/0_entity/entity.dart';

abstract class ShoppingRepository {
  Stream<List<ShoppingItem>> watchItems();
  Future<String> add(ShoppingDraft draft);
  Future<void> update(String id, ShoppingDraft draft);
  Future<void> setBought(String id, bool bought);
  Future<void> delete(String id);

  /// Borra los comprados (o todo con [all]).
  Future<void> clear({required bool all});
}
