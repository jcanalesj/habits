import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/2_presentation/providers/auth_providers.dart';

/// Estado de sesión de la app: usuario autenticado o null.
class AuthController extends Notifier<AppUser?> {
  @override
  AppUser? build() => ref.read(authRepositoryProvider).currentUser;

  void setUser(AppUser user) => state = user;

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = null;
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AppUser?>(AuthController.new);
