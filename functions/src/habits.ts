import { FieldValue, getFirestore, Timestamp } from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";
import { onDocumentCreated } from "firebase-functions/v2/firestore";

/** Hábitos activos que puede tener una cuenta gratuita (igual que la app). */
export const FREE_HABIT_LIMIT = 5;

interface Subscription {
  status?: string;
  expiresAt?: Timestamp | null;
}

export function isPremium(subscription: Subscription | undefined): boolean {
  if (!subscription) return false;
  if (subscription.status !== "active" && subscription.status !== "premium") {
    return false;
  }
  const expiresAt = subscription.expiresAt;
  return !expiresAt || expiresAt.toMillis() > Date.now();
}

/**
 * Aplica en servidor el límite de hábitos de la versión gratuita.
 *
 * La app ya lo impide (pide Premium al crear el sexto), pero un cliente
 * modificado podría saltárselo escribiendo directamente en Firestore. Las
 * reglas no pueden contar documentos, así que se corrige después: si una
 * cuenta gratuita supera el límite, el hábito nuevo se archiva (soft delete,
 * igual que al borrarlo desde la app).
 */
export const enforceFreeHabitLimit = onDocumentCreated(
  "users/{uid}/habitos/{habitId}",
  async (event) => {
    const { uid, habitId } = event.params;
    const db = getFirestore();
    const user = await db.doc(`users/${uid}`).get();
    if (isPremium(user.get("subscription") as Subscription | undefined)) {
      return;
    }
    const active = await db
      .collection(`users/${uid}/habitos`)
      .where("deletedAt", "==", null)
      .count()
      .get();
    if (active.data().count <= FREE_HABIT_LIMIT) return;

    await db.doc(`users/${uid}/habitos/${habitId}`).update({
      deletedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    logger.warn("Hábito archivado: supera el límite gratuito", {
      uid,
      habitId,
      active: active.data().count,
    });
  },
);
