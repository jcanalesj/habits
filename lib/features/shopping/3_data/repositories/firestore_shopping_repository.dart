import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habits/features/shopping/0_entity/entity.dart';
import 'package:habits/features/shopping/1_domain/domain.dart';
import 'package:habits/firestore_write.dart';

class FirestoreShoppingRepository implements ShoppingRepository {
  FirestoreShoppingRepository({
    required this.userId,
    FirebaseFirestore? firestore,
  }) : _db = firestore ?? FirebaseFirestore.instance;

  final String userId;
  final FirebaseFirestore _db;

  static const collection = 'listasCompra';
  static const defaultListId = 'principal';
  static const itemsCollection = 'items';

  CollectionReference<Map<String, dynamic>> get _lists =>
      _db.collection('users').doc(userId).collection(collection);
  CollectionReference<Map<String, dynamic>> _items(String listId) =>
      _lists.doc(listId).collection(itemsCollection);

  @override
  Stream<List<ShoppingListInfo>> watchLists() => _lists.snapshots().map((snap) {
    final lists = [
      for (final document in snap.docs)
        ShoppingListInfo(
          id: document.id,
          name:
              (document.data()['nombre'] as String?)?.trim().isNotEmpty == true
              ? document.data()['nombre'] as String
              : 'Supermercado',
          createdAt: (document.data()['createdAt'] as Timestamp?)?.toDate(),
        ),
    ];
    if (!lists.any((list) => list.id == defaultListId)) {
      lists.insert(
        0,
        const ShoppingListInfo(id: defaultListId, name: 'Supermercado'),
      );
    }
    lists.sort((a, b) {
      if (a.id == defaultListId) return -1;
      if (b.id == defaultListId) return 1;
      return (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0));
    });
    return lists;
  });

  @override
  Stream<List<ShoppingItem>> watchItems(String listId) =>
      _items(listId).snapshots().map((snapshot) {
        final items = <ShoppingItem>[
          for (final document in snapshot.docs)
            ?fromData(document.id, document.data()),
        ];
        items.sort(compareShoppingItems);
        return items;
      });

  @override
  Future<String> createList(String name) async {
    final reference = _lists.doc();
    await awaitWrite(
      reference.set({
        'nombre': name.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }),
    );
    return reference.id;
  }

  @override
  Future<void> renameList(String id, String name) => awaitWrite(
    _lists.doc(id).set({
      'nombre': name.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)),
  );

  @override
  Future<void> deleteList(String id) async {
    if (id == defaultListId) return;
    final documents = await _items(id).get();
    for (var offset = 0; offset < documents.docs.length; offset += 400) {
      final batch = _db.batch();
      for (final document in documents.docs.skip(offset).take(400)) {
        batch.delete(document.reference);
      }
      await awaitWrite(batch.commit());
    }
    await awaitWrite(_lists.doc(id).delete());
  }

  static ShoppingItem? fromData(String id, Map<String, dynamic> data) {
    final name = data['nombre'];
    if (name is! String) return null;
    return ShoppingItem(
      id: id,
      name: name,
      quantity: (data['cantidad'] as num?)?.toInt(),
      note: data['nota'] as String?,
      boughtAt: (data['compradoEn'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  static Map<String, dynamic> _draftData(ShoppingDraft draft) => {
    'nombre': draft.name.trim(),
    'cantidad': draft.quantity,
    'nota': (draft.note?.trim().isEmpty ?? true) ? null : draft.note!.trim(),
  };

  @override
  Future<String> add(String listId, ShoppingDraft draft) async {
    final reference = _items(listId).doc();
    await awaitWrite(
      reference.set({
        ..._draftData(draft),
        'compradoEn': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }),
    );
    return reference.id;
  }

  @override
  Future<void> update(String listId, String id, ShoppingDraft draft) =>
      awaitWrite(
        _items(listId).doc(id).update({
          ..._draftData(draft),
          'updatedAt': FieldValue.serverTimestamp(),
        }),
      );

  @override
  Future<void> setBought(String listId, String id, bool bought) => awaitWrite(
    _items(listId).doc(id).update({
      'compradoEn': bought ? FieldValue.serverTimestamp() : null,
      'updatedAt': FieldValue.serverTimestamp(),
    }),
  );

  @override
  Future<void> delete(String listId, String id) =>
      awaitWrite(_items(listId).doc(id).delete());

  @override
  Future<void> clear(String listId, {required bool all}) async {
    final collection = _items(listId);
    final query = all
        ? collection
        : collection.where('compradoEn', isNull: false);
    final documents = await query.get();
    for (var offset = 0; offset < documents.docs.length; offset += 400) {
      final batch = _db.batch();
      for (final document in documents.docs.skip(offset).take(400)) {
        batch.delete(document.reference);
      }
      await awaitWrite(batch.commit());
    }
  }
}
