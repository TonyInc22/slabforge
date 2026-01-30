export type JobName =
    | "EBAY_SOLD_INGEST"
    | "EBAY_ACTIVE_REFRESH"
    | "PSA_POP_SNAPSHOT"
    | "METRICS_RECOMPUTE";

export type EbaySoldIngestPayload = {
    /** If provided, ingest for this Variant only */
    variantId?: string;
    /** Optional query string to fetch comps by search term */
    searchQuery?: string;
    lookbackDays?: number;
};

export type EbayActiveRefreshPayload = {
    /** Search signature for active listings */
    searchQuery: string;
    ttlSeconds?: number;
};

export type PsaPopSnapshotPayload = {
    variantId: string;
    /** A PSA “lookup key” you store per variant later, if needed */
    psaLookupKey?: string;
    asOfDate?: string; // YYYY-MM-DD
};

export type MetricsRecomputePayload = {
    variantId?: string;
};

export type JobPayloadMap = {
    EBAY_SOLD_INGEST: EbaySoldIngestPayload;
    EBAY_ACTIVE_REFRESH: EbayActiveRefreshPayload;
    PSA_POP_SNAPSHOT: PsaPopSnapshotPayload;
    METRICS_RECOMPUTE: MetricsRecomputePayload;
};
