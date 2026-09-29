import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/features/shopping/0_entity/entity.dart';
import 'package:habits/features/shopping/1_domain/domain.dart';
// Capa de inyección de dependencias: único punto autorizado a importar 3_data.
import 'package:habits/features/shopping/3_data/data.dart';

final shoppingRepositoryProvider = Provider.autoDispose<ShoppingRepository>((
  ref,
) {
  final userId = ref.read(authControllerProvider).value?.id ?? 'anonymous';
  return FirestoreShoppingRepository(userId: userId);
});

final shoppingListsProvider =
    StreamProvider.autoDispose<List<ShoppingListInfo>>(
      (ref) => ref.watch(shoppingRepositoryProvider).watchLists(),
    );

final shoppingItemsProvider = StreamProvider.autoDispose
    .family<List<ShoppingItem>, String>(
      (ref, listId) => ref.watch(shoppingRepositoryProvider).watchItems(listId),
    );

/// Artículos por comprar (dato vivo del panel).
final shoppingPendingCountProvider = Provider.autoDispose<int?>((ref) {
  final lists = ref.watch(shoppingListsProvider);
  if (!lists.hasValue) return null;
  var total = 0;
  for (final list in lists.value!) {
    final items = ref.watch(shoppingItemsProvider(list.id));
    if (!items.hasValue) return null;
    total += items.value!.where((item) => !item.isBought).length;
  }
  return total;
});
