import { FieldValue, getFirestore, Timestamp } from "firebase-admin/firestore";
import { defineSecret } from "firebase-functions/params";
import { logger } from "firebase-functions/v2";
import { onRequest } from "firebase-functions/v2/https";

/**
 * Valor exacto que RevenueCat envía en la cabecera Authorization del
 * webhook (se configura en RevenueCat › Integrations › Webhooks).
 */
const webhookAuth = defineSecret("REVENUECAT_WEBHOOK_AUTH");

/** Clave secreta de la API REST de RevenueCat (v1, "sk_..."). */
const revenuecatApiKey = defineSecret("REVENUECAT_API_KEY");

/** Entitlement que desbloquea Premium en RevenueCat. */
const ENTITLEMENT = "premium";

interface RevenueCatEvent {
  type?: string;
  app_user_id?: string;
  original_app_user_id?: string;
  aliases?: string[];
  transferred_from?: string[];
  transferred_to?: string[];
}

interface Entitlement {
  expires_date: string | null;
  product_identifier?: string;
}

interface SubscriberResponse {
  subscriber?: {
    entitlements?: Record<string, Entitlement>;
    subscriptions?: Record<string, { store?: string }>;
  };
}

/** Los ids anónimos de RevenueCat no son usuarios de Firebase. */
function isFirebaseUid(id: string | undefined): id is string {
  return !!id && !id.startsWith("$RCAnonymousID:");
}

/**
 * Webhook de RevenueCat.
 *
 * No se fía del contenido del evento para decidir el estado (los eventos
 * pueden llegar desordenados o repetidos): cada evento solo indica QUÉ
 * usuarios hay que refrescar, y el estado real se pide a la API de
 * RevenueCat. Así el resultado es siempre el mismo, llegue en el orden que
 * llegue.
 */
export const revenuecatWebhook = onRequest(
  { secrets: [webhookAuth, revenuecatApiKey] },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }
    if (req.get("Authorization") !== webhookAuth.value()) {
      res.status(401).send("Unauthorized");
      return;
    }

    const event = (req.body?.event ?? {}) as RevenueCatEvent;
    const uids = new Set<string>(
      [
        event.app_user_id,
        event.original_app_user_id,
        ...(event.aliases ?? []),
        ...(event.transferred_from ?? []),
        ...(event.transferred_to ?? []),
      ].filter(isFirebaseUid),
    );

    try {
      await Promise.all([...uids].map((uid) => refreshSubscription(uid)));
      res.status(200).send({ ok: true, refreshed: uids.size });
    } catch (error) {
      logger.error("Error procesando el webhook de RevenueCat", {
        type: event.type,
        error,
      });
      // 500 hace que RevenueCat reintente más tarde.
      res.status(500).send({ ok: false });
    }
  },
);

/** Consulta el estado en RevenueCat y lo copia a `users/{uid}.subscription`. */
async function refreshSubscription(uid: string): Promise<void> {
  const response = await fetch(
    `https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(uid)}`,
    { headers: { Authorization: `Bearer ${revenuecatApiKey.value()}` } },
  );
  if (!response.ok) {
    throw new Error(`RevenueCat respondió ${response.status} para ${uid}`);
  }
  const body = (await response.json()) as SubscriberResponse;
  const entitlement = body.subscriber?.entitlements?.[ENTITLEMENT];
  const expiresAt = entitlement?.expires_date
    ? new Date(entitlement.expires_date)
    : null;
  // Sin fecha de caducidad = compra de por vida.
  const active =
    !!entitlement && (expiresAt === null || expiresAt.getTime() > Date.now());
  const productId = entitlement?.product_identifier ?? null;
  const store = productId
    ? (body.subscriber?.subscriptions?.[productId]?.store ?? null)
    : null;

  const userRef = getFirestore().doc(`users/${uid}`);
  const snapshot = await userRef.get();
  if (!snapshot.exists) {
    // El perfil lo crea la app al registrarse. Si aún no existe (o la cuenta
    // se borró), no hay dónde escribir.
    logger.warn("Evento de RevenueCat para un usuario sin perfil", { uid });
    return;
  }
  await userRef.update({
    subscription: {
      status: active ? "active" : "free",
      entitlement: ENTITLEMENT,
      productId,
      store,
      expiresAt: expiresAt ? Timestamp.fromDate(expiresAt) : null,
      updatedAt: FieldValue.serverTimestamp(),
    },
  });
  logger.info("Suscripción actualizada", { uid, active, productId });
}
