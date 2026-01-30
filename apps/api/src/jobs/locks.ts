// src/jobs/locks.ts
import type IORedis from "ioredis";

/**
 * Acquire a lock key with TTL. Returns true if acquired.
 */
export async function acquireLock(redis: IORedis, key: string, ttlSeconds: number) {
    const ok = await redis.setnx(key, "1");
    if (ok === 1) {
        await redis.expire(key, ttlSeconds);
        return true;
    }
    return false;
}
