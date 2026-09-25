/**
 * Cloud Functions de Constanza.
 *
 * Todo lo que el cliente NO puede hacer por sí mismo porque las reglas se lo
 * impiden a propósito:
 *  - borrar la cuenta y todos sus datos (las reglas prohíben borrar el
 *    perfil, los hábitos, los comodines…);
 *  - escribir el estado de la suscripción Premium (solo lo decide el
 *    servidor a partir de RevenueCat);
 *  - aplicar límites que las reglas no pueden comprobar (contar hábitos).
 *
 * Requiere el plan Blaze. Región europe-west1, junto a Firestore (eur3).
 */
import { initializeApp } from "firebase-admin/app";
import { setGlobalOptions } from "firebase-functions/v2";

initializeApp();
setGlobalOptions({ region: "europe-west1", maxInstances: 10 });

export { deleteAccount, cleanupDeletedUser } from "./account";
export { enforceFreeHabitLimit } from "./habits";
export { revenuecatWebhook } from "./revenuecat";
