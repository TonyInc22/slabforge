import type IORedis from "ioredis";

export type RateLimitConfig = {
    key: string;          // e.g. "rl:ebay"
    maxPerWindow: number; // e.g. 120
    windowMs: number;     // e.g. 60_000
};

/**
 * Returns true if allowed now; false if rate-limited.
 * Uses Redis INCR + EXPIRE as a fixed-window counter (simple + reliable).
 */
export async function allow(redis: IORedis, cfg: RateLimitConfig): Promise<boolean> {
    const count = await redis.incr(cfg.key);
    if (count === 1) {
        await redis.pexpire(cfg.key, cfg.windowMs);
    }
    return count <= cfg.maxPerWindow;
}
