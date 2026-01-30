import "dotenv/config";
import "./worker";
import { registerRepeatableJobs } from "./schedulers";

registerRepeatableJobs()
    .then(() => console.log("[jobs] repeatable jobs registered"))
    .catch((e) => console.error("[jobs] failed to register repeatable jobs", e));
