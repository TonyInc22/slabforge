import type { Job } from "bullmq";
import { connection } from "../queues";
import { allow } from "../rateLimit";
import { acquireLock } from "../locks";
import { prisma } from "../../lib/prisma";
import type { PsaPopSnapshotPayload } from "../types";

/** TODO: replace with real PSA pop fetch */
async function fetchPsaPop(_variantId: string, _lookupKey?: string): Promise<{ totalGraded: number; byGrade: Record<string, number> }> {
    return { totalGraded: 0, byGrade: {} };
}

export async function psaPopSnapshot(job: Job) {
    const payload = job.data as PsaPopSnapshotPayload;

    const asOf = payload.asOfDate ? new Date(payload.asOfDate) : new Date();
    // Normalize to date-only (UTC) for @db.Date
    const asOfDate = new Date(Date.UTC(asOf.getUTCFullYear(), asOf.getUTCMonth(), asOf.getUTCDate()));

    const lockKey = `lock:psa:pop:${payload.variantId}:${asOfDate.toISOString().slice(0, 10)}`;
    const acquired = await acquireLock(connection, lockKey, 60);
    if (!acquired) return { skipped: "locked" };

    const maxPerMin = Number(process.env.PSA_MAX_REQ_PER_MIN ?? 30);
    const ok = await allow(connection, { key: "rl:psa", maxPerWindow: maxPerMin, windowMs: 60_000 });
    if (!ok) throw new Error("Rate limited: PSA budget exceeded (per-minute).");

    const pop = await fetchPsaPop(payload.variantId, payload.psaLookupKey);

    await prisma.popReportSnapshot.upsert({
        where: { variantId_asOfDate: { variantId: payload.variantId, asOfDate } },
        update: {
            totalGraded: pop.totalGraded,
            byGrade: pop.byGrade as any,
            source: "PSA",
        },
        create: {
            variantId: payload.variantId,
            asOfDate,
            totalGraded: pop.totalGraded,
            byGrade: pop.byGrade as any,
            source: "PSA",
        },
    });

    return { variantId: payload.variantId, asOfDate: asOfDate.toISOString().slice(0, 10), totalGraded: pop.totalGraded };
}
