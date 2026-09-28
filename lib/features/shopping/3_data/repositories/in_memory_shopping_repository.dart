import 'dart:async';

import 'package:habits/features/shopping/0_entity/entity.dart';
import 'package:habits/features/shopping/1_domain/domain.dart';

class InMemoryShoppingRepository implements ShoppingRepository {
  InMemoryShoppingRepository({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final _items = <String, ShoppingItem>{};
  final _controller = StreamController<void>.broadcast();
  int _sequence = 0;

  List<ShoppingItem> get all => _items.values.toList(growable: false);

  List<ShoppingItem> _sorted() =>
      _items.values.toList()..sort(compareShoppingItems);

  @override
  Stream<List<ShoppingItem>> watchItems() async* {
    yield _sorted();
    yield* _controller.stream.map((_) => _sorted());
  }

  @override
  Future<String> add(ShoppingDraft draft) async {
    final id = 'item-${++_sequence}';
    _items[id] = ShoppingItem(
      id: id,
      name: draft.name.trim(),
      quantity: draft.quantity,
      note: draft.note,
      createdAt: _now().add(Duration(milliseconds: _sequence)),
    );
    _controller.add(null);
    return id;
  }

  @override
  Future<void> update(String id, ShoppingDraft draft) async {
    final current = _items[id];
    if (current == null) return;
    _items[id] = ShoppingItem(
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
  Future<void> setBought(String id, bool bought) async {
    final current = _items[id];
    if (current == null) return;
    _items[id] = ShoppingItem(
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
  Future<void> delete(String id) async {
    _items.remove(id);
    _controller.add(null);
  }

  @override
  Future<void> clear({required bool all}) async {
    _items.removeWhere((_, item) => all || item.isBought);
    _controller.add(null);
  }

  void dispose() => _controller.close();
}
