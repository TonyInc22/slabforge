import "dotenv/config";
import { addJob } from "./jobs/addJob";

async function run() {
    const job = await addJob("EBAY_SOLD_INGEST", {
        lookbackDays: 7,
    });

    console.log("[test] Job enqueued");
    console.log("[test] Job ID:", job.id);
    console.log("[test] Job Name:", job.name);
    console.log("[test] Payload:", job.data);

    process.exit(0);
}

run().catch((e) => {
    console.error("[test] enqueue failed", e);
    process.exit(1);
});
