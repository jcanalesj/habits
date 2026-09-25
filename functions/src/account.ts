import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";
import * as functionsV1 from "firebase-functions/v1";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";

/** Antigüedad máxima del inicio de sesión para poder borrar la cuenta. */
const RECENT_LOGIN_SECONDS = 5 * 60;

/** Borra `users/{uid}` con TODAS sus subcolecciones. Idempotente. */
async function deleteUserData(uid: string): Promise<void> {
  const db = getFirestore();
  await db.recursiveDelete(db.doc(`users/${uid}`));
}

/**
 * Borrado de cuenta pedido desde la app (Perfil › Eliminar cuenta).
 *
 * Exige un inicio de sesión reciente: la app reautentica con la contraseña
 * justo antes de llamar. Primero se borran los datos y después el usuario de
 * Auth; si lo segundo falla, reintentar es seguro.
 */
export const deleteAccount = onCall(async (request) => {
  const auth = request.auth;
  if (!auth) {
    throw new HttpsError("unauthenticated", "Sesión requerida.");
  }
  const authTime = Number(auth.token.auth_time ?? 0);
  if (Date.now() / 1000 - authTime > RECENT_LOGIN_SECONDS) {
    throw new HttpsError("failed-precondition", "requires-recent-login");
  }

  const uid = auth.uid;
  await deleteUserData(uid);
  try {
    await getAuth().deleteUser(uid);
  } catch (error) {
    // Si ya no existe, el objetivo está cumplido.
    if ((error as { code?: string }).code !== "auth/user-not-found") {
      throw error;
    }
  }
  logger.info("Cuenta eliminada", { uid });
  return { deleted: true };
});

/**
 * Red de seguridad: si la cuenta se borra por otra vía (consola de Firebase,
 * Admin SDK), sus datos también se van.
 */
export const cleanupDeletedUser = functionsV1
  .region("europe-west1")
  .auth.user()
  .onDelete(async (user) => {
    await deleteUserData(user.uid);
    logger.info("Datos de usuario eliminados tras borrar la cuenta", {
      uid: user.uid,
    });
  });
