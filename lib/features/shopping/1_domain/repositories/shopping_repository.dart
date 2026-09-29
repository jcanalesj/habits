import 'package:habits/features/shopping/0_entity/entity.dart';

abstract class ShoppingRepository {
  Stream<List<ShoppingListInfo>> watchLists();
  Stream<List<ShoppingItem>> watchItems(String listId);
  Future<String> createList(String name);
  Future<void> renameList(String id, String name);
  Future<void> deleteList(String id);
  Future<String> add(String listId, ShoppingDraft draft);
  Future<void> update(String listId, String id, ShoppingDraft draft);
  Future<void> setBought(String listId, String id, bool bought);
  Future<void> delete(String listId, String id);

  /// Borra los comprados (o todo con [all]).
  Future<void> clear(String listId, {required bool all});
}
