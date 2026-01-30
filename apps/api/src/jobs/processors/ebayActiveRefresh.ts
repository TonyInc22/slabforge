import type { Job } from "bullmq";
import { connection } from "../queues";
import { allow } from "../rateLimit";
import { acquireLock } from "../locks";
import { prisma } from "../../lib/prisma";
import type { EbayActiveRefreshPayload } from "../types";

/** TODO: replace with real eBay active listings search */
async function fetchEbayActiveListings(_searchQuery: string) {
    return { items: [], fetchedAt: new Date().toISOString() };
}

export async function ebayActiveRefresh(job: Job) {
    const payload = job.data as EbayActiveRefreshPayload;

    const ttlSeconds = payload.ttlSeconds ?? 15 * 60; // 15 min
    const key = `cache:ebay:active:${Buffer.from(payload.searchQuery).toString("base64")}`;

    const acquired = await acquireLock(connection, `lock:${key}`, 30);
    if (!acquired) return { skipped: "locked" };

    const maxPerMin = Number(process.env.EBAY_MAX_REQ_PER_MIN ?? 120);
    const ok = await allow(connection, { key: "rl:ebay", maxPerWindow: maxPerMin, windowMs: 60_000 });
    if (!ok) throw new Error("Rate limited: eBay budget exceeded (per-minute).");

    // Fetch and cache in Redis
    const result = await fetchEbayActiveListings(payload.searchQuery);
    await connection.set(key, JSON.stringify(result), "EX", ttlSeconds);

    // Optional: also persist query cache in Postgres for transparency/debugging
    const expiresAt = new Date(Date.now() + ttlSeconds * 1000);
    const queryKey = key; // reuse the same stable key; or hash it if you prefer shorter keys

    await prisma.queryCache.upsert({
        where: { source_queryKey: { source: "EBAY", queryKey } },
        update: { payload: result as any, expiresAt },
        create: { source: "EBAY", queryKey, payload: result as any, expiresAt },
    });

    return { cached: true, ttlSeconds };
}
