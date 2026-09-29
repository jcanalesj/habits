import 'dart:async';

import 'package:habits/features/shopping/0_entity/entity.dart';
import 'package:habits/features/shopping/1_domain/domain.dart';
import 'package:habits/features/shopping/3_data/repositories/firestore_shopping_repository.dart';

class InMemoryShoppingRepository implements ShoppingRepository {
  InMemoryShoppingRepository({DateTime Function()? now})
    : _now = now ?? DateTime.now {
    _lists[FirestoreShoppingRepository.defaultListId] = ShoppingListInfo(
      id: FirestoreShoppingRepository.defaultListId,
      name: 'Supermercado',
      createdAt: _now(),
    );
  }

  final DateTime Function() _now;
  final _lists = <String, ShoppingListInfo>{};
  final _items = <String, Map<String, ShoppingItem>>{};
  final _controller = StreamController<void>.broadcast();
  int _itemSequence = 0;
  int _listSequence = 0;

  List<ShoppingItem> get all =>
      _items.values.expand((items) => items.values).toList(growable: false);
  List<ShoppingListInfo> get lists => _lists.values.toList(growable: false);

  @override
  Stream<List<ShoppingListInfo>> watchLists() async* {
    List<ShoppingListInfo> select() => _lists.values.toList()
      ..sort((a, b) {
        if (a.id == FirestoreShoppingRepository.defaultListId) return -1;
        if (b.id == FirestoreShoppingRepository.defaultListId) return 1;
        return (a.createdAt ?? DateTime(0)).compareTo(
          b.createdAt ?? DateTime(0),
        );
      });
    yield select();
    yield* _controller.stream.map((_) => select());
  }

  @override
  Stream<List<ShoppingItem>> watchItems(String listId) async* {
    List<ShoppingItem> select() =>
        (_items[listId]?.values.toList() ?? <ShoppingItem>[])
          ..sort(compareShoppingItems);
    yield select();
    yield* _controller.stream.map((_) => select());
  }

  @override
  Future<String> createList(String name) async {
    final id = 'list-${++_listSequence}';
    _lists[id] = ShoppingListInfo(id: id, name: name.trim(), createdAt: _now());
    _controller.add(null);
    return id;
  }

  @override
  Future<void> renameList(String id, String name) async {
    final current = _lists[id];
    if (current == null) return;
    _lists[id] = ShoppingListInfo(
      id: id,
      name: name.trim(),
      createdAt: current.createdAt,
    );
    _controller.add(null);
  }

  @override
  Future<void> deleteList(String id) async {
    if (id == FirestoreShoppingRepository.defaultListId) return;
    _lists.remove(id);
    _items.remove(id);
    _controller.add(null);
  }

  @override
  Future<String> add(String listId, ShoppingDraft draft) async {
    final id = 'item-${++_itemSequence}';
    (_items[listId] ??= {})[id] = ShoppingItem(
      id: id,
      name: draft.name.trim(),
      quantity: draft.quantity,
      note: draft.note,
      createdAt: _now().add(Duration(milliseconds: _itemSequence)),
    );
    _controller.add(null);
    return id;
  }

  @override
  Future<void> update(String listId, String id, ShoppingDraft draft) async {
    final current = _items[listId]?[id];
    if (current == null) return;
    _items[listId]![id] = ShoppingItem(
      id: id,
      name: draft.name.trim(),
      quantity: draft.quantity,
      note: draft.note,
      boughtAt: current.boughtAt,
      createdAt: current.createdAt,
    );
    _controller.add(null);
  }

  @override
  Future<void> setBought(String listId, String id, bool bought) async {
    final current = _items[listId]?[id];
    if (current == null) return;
    _items[listId]![id] = ShoppingItem(
      id: id,
      name: current.name,
      quantity: current.quantity,
      note: current.note,
      boughtAt: bought ? _now() : null,
      createdAt: current.createdAt,
    );
    _controller.add(null);
  }

  @override
  Future<void> delete(String listId, String id) async {
    _items[listId]?.remove(id);
    _controller.add(null);
  }

  @override
  Future<void> clear(String listId, {required bool all}) async {
    _items[listId]?.removeWhere((_, item) => all || item.isBought);
    _controller.add(null);
  }

  void dispose() => _controller.close();
}
