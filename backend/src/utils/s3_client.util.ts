import { S3Client } from "@aws-sdk/client-s3";
import { config } from "./config.js";

// Explicit keys when they are set, otherwise the machine's own role, exactly
// as bedrock_client.util.ts already does. Production sets the keys and is
// unchanged; a deployment running on an instance role (the TEST server) no
// longer needs a stored access key for uploads at all.
const s3Client = new S3Client({
  region: config.aws.s3.region,
  ...(config.aws.s3.accessKeyId && config.aws.s3.secretAccessKey
    ? {
        credentials: {
          accessKeyId: config.aws.s3.accessKeyId,
          secretAccessKey: config.aws.s3.secretAccessKey,
        },
      }
    : {}),
});

export default s3Client;
