import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habits/features/shopping/0_entity/entity.dart';
import 'package:habits/features/shopping/1_domain/domain.dart';
import 'package:habits/firestore_write.dart';

/// `users/{uid}/listasCompra/principal/items/{itemId}`. En v2 hay una sola
/// lista, `principal`; el modelo deja sitio para varias sin migrar.
class FirestoreShoppingRepository implements ShoppingRepository {
  FirestoreShoppingRepository({
    required this.userId,
    FirebaseFirestore? firestore,
    this.listId = defaultListId,
  }) : _db = firestore ?? FirebaseFirestore.instance;

  final String userId;
  final String listId;
  final FirebaseFirestore _db;

  static const collection = 'listasCompra';
  static const defaultListId = 'principal';
  static const itemsCollection = 'items';

  CollectionReference<Map<String, dynamic>> get _items => _db
      .collection('users')
      .doc(userId)
      .collection(collection)
      .doc(listId)
      .collection(itemsCollection);

  @override
  Stream<List<ShoppingItem>> watchItems() => _items.snapshots().map((snapshot) {
    final items = <ShoppingItem>[
      for (final document in snapshot.docs)
        ?fromData(document.id, document.data()),
    ];
    items.sort(compareShoppingItems);
    return items;
  });

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
  Future<String> add(ShoppingDraft draft) async {
    final reference = _items.doc();
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
  Future<void> update(String id, ShoppingDraft draft) => awaitWrite(
    _items.doc(id).update({
      ..._draftData(draft),
      'updatedAt': FieldValue.serverTimestamp(),
    }),
  );

  @override
  Future<void> setBought(String id, bool bought) => awaitWrite(
    _items.doc(id).update({
      'compradoEn': bought ? FieldValue.serverTimestamp() : null,
      'updatedAt': FieldValue.serverTimestamp(),
    }),
  );

  @override
  Future<void> delete(String id) => awaitWrite(_items.doc(id).delete());

  @override
  Future<void> clear({required bool all}) async {
    final query = all ? _items : _items.where('compradoEn', isNull: false);
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
