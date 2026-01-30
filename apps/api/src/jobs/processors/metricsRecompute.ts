import type { Job } from "bullmq";
import { prisma } from "../../lib/prisma";
import type { MetricsRecomputePayload } from "../types";

export async function metricsRecompute(job: Job) {
    const payload = job.data as MetricsRecomputePayload;

    // v1 placeholder: you’ll compute and store derived metrics later.
    // For now we just prove the pipeline works and you can add logs.
    if (payload.variantId) {
        // Example: read recent sales count
        const count = await prisma.marketSale.count({ where: { variantId: payload.variantId } });
        return { variantId: payload.variantId, salesCount: count };
    }

    return { ok: true };
}
