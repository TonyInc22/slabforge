import { Queue } from "bullmq";
import IORedis from "ioredis";
import type { JobName, JobPayloadMap } from "./types";

// DataType for the queue is "any job payload", not the job name.
type AnyJobPayload = JobPayloadMap[keyof JobPayloadMap];

export const connection = new IORedis(process.env.REDIS_URL ?? "redis://localhost:6379", {
    maxRetriesPerRequest: null,
});

export const slabforgeQueue = new Queue<AnyJobPayload, any, JobName>("slabforge", {
    connection,
    defaultJobOptions: {
        removeOnComplete: 500,
        removeOnFail: 500,
        attempts: 5,
        backoff: { type: "exponential", delay: 2_000 },
    },
});
