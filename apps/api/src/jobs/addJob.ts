import type { JobsOptions } from "bullmq";
import { slabforgeQueue } from "./queues";
import type { JobName, JobPayloadMap } from "./types";

/**
 * Strongly-typed job enqueue helper.
 * Ensures job payload matches job name.
 */
export function addJob<N extends JobName>(
    name: N,
    data: JobPayloadMap[N],
    options?: JobsOptions
) {
    return slabforgeQueue.add(name, data, options);
}
