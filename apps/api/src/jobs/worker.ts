import { Worker } from "bullmq";
import { connection } from "./queues";
import type { JobName } from "./types";

import { ebaySoldIngest } from "./processors/ebaySoldIngest";
import { ebayActiveRefresh } from "./processors/ebayActiveRefresh";
import { psaPopSnapshot } from "./processors/psaPopSnapshot";
import { metricsRecompute } from "./processors/metricsRecompute";

export const worker = new Worker(
    "slabforge",
    async (job) => {
        console.log(`[worker] START ${job.name}`, {
            id: job.id,
            data: job.data,
        });

        let result;

        switch (job.name) {
            case "EBAY_SOLD_INGEST":
                result = await ebaySoldIngest(job as any);
                break;
            case "EBAY_ACTIVE_REFRESH":
                result = await ebayActiveRefresh(job as any);
                break;
            case "PSA_POP_SNAPSHOT":
                result = await psaPopSnapshot(job as any);
                break;
            case "METRICS_RECOMPUTE":
                result = await metricsRecompute(job as any);
                break;
            default:
                throw new Error(`Unknown job: ${job.name}`);
        }

        return result;
    },
    { connection, concurrency: 5 }
);


worker.on("failed", (job, err) => {
    console.error(`[worker] job failed`, { name: job?.name, id: job?.id, err: err.message });
});

worker.on("completed", (job) => {
    // Keep logs light in prod; useful in dev
    console.log(`[worker] job completed`, { name: job.name, id: job.id });
});
