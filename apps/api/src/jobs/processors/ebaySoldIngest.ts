import type { Job } from "bullmq";
import { connection } from "../queues";
import { allow } from "../rateLimit";
import { acquireLock } from "../locks";
import { slabforgeQueue } from "../queues";
import { prisma } from "../../lib/prisma";
import type { EbaySoldIngestPayload } from "../types";

/**
 * TODO: Replace this with real eBay sold comps fetch.
 * Must return normalized sold items.
 */
async function fetchEbaySoldComps(_payload: EbaySoldIngestPayload): Promise<Array<{
    sourceItemId: string;
    soldAt: Date;
    price: string;        // decimal as string
    shipping?: string;    // decimal string
    totalPrice?: string;  // decimal string
    currency?: string;
    titleSnapshot: string;
    gradeDetected?: string;
}>> {
    // Stub (no-op)
    return [];
}

export async function ebaySoldIngest(job: Job<"EbaySoldIngestPayload", any, string>) {
    const payload = job.data as EbaySoldIngestPayload;

    // Lock by variant or query to prevent spam-ingestion
    const lockKey = payload.variantId
        ? `lock:ebay:sold:variant:${payload.variantId}`
        : `lock:ebay:sold:q:${Buffer.from(payload.searchQuery ?? "all").toString("base64")}`;

    const acquired = await acquireLock(connection, lockKey, 60); // 1 minute lock
    if (!acquired) return { skipped: "locked" };

    // Rate limit eBay calls
    const maxPerMin = Number(process.env.EBAY_MAX_REQ_PER_MIN ?? 120);
    const ok = await allow(connection, { key: "rl:ebay", maxPerWindow: maxPerMin, windowMs: 60_000 });
    if (!ok) {
        throw new Error("Rate limited: eBay budget exceeded (per-minute).");
    }

    const soldItems = await fetchEbaySoldComps(payload);

    let upserts = 0;
    for (const it of soldItems) {
        // Dedupe is enforced via @@unique([source, sourceItemId]) in schema
        // Use create with catch, or upsert.
        await prisma.marketSale.upsert({
            where: {
                source_sourceItemId: { source: "EBAY", sourceItemId: it.sourceItemId },
            },
            update: {
                soldAt: it.soldAt,
                price: it.price,
                shipping: it.shipping ?? null,
                totalPrice: it.totalPrice ?? null,
                currency: it.currency ?? "USD",
                titleSnapshot: it.titleSnapshot,
                gradeDetected: it.gradeDetected ?? null,
                // Keep existing variant match/confidence unless you have new matching logic:
            },
            create: {
                source: "EBAY",
                sourceItemId: it.sourceItemId,
                soldAt: it.soldAt,
                price: it.price,
                shipping: it.shipping ?? null,
                totalPrice: it.totalPrice ?? null,
                currency: it.currency ?? "USD",
                titleSnapshot: it.titleSnapshot,
                gradeDetected: it.gradeDetected ?? null,
                confidence: 0,
                variantId: payload.variantId ?? null,
            },
        });
        upserts++;
    }

    // Trigger metrics recompute for a variant-specific run
    if (payload.variantId) {
        await slabforgeQueue.add("METRICS_RECOMPUTE", { variantId: payload.variantId }, { jobId: `metrics:${payload.variantId}` });
    }

    return { upserts, soldCount: soldItems.length };
}
