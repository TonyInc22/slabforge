import { slabforgeQueue } from "./queues";

/**
 * Call once at worker startup.
 * Uses repeatable jobs to keep ingestion running.
 */
export async function registerRepeatableJobs() {
    // Sold comps: every 6 hours (for "hot" variants you’ll enqueue specifically later)
    await slabforgeQueue.add(
        "EBAY_SOLD_INGEST",
        { lookbackDays: Number(process.env.EBAY_SOLD_LOOKBACK_DAYS ?? 30) },
        { repeat: { pattern: "0 */6 * * *" }, jobId: "repeat:ebay:sold:global" }
    );

    // Active listings refresh: every 15 minutes for a default query (replace with your own)
    // In real usage you will enqueue these per-search signature, not global.
    await slabforgeQueue.add(
        "EBAY_ACTIVE_REFRESH",
        { searchQuery: "2024 Select PSA 10", ttlSeconds: 15 * 60 },
        { repeat: { pattern: "*/15 * * * *" }, jobId: "repeat:ebay:active:default" }
    );

    // PSA pop: weekly (Sunday at 3am)
    // Real usage: enqueue per tracked variant, not global.
    // This placeholder won’t do much without a variantId.
}
