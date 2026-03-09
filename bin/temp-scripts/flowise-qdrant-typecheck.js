/*
############################################
# SECTION: File Overview
#
# What this part of the program does:
# Implements an automation/helper script used by the LLMStack tooling layer.
# This script performs a focused operational task in a repeatable way.
#
# Why it exists:
# Automating this workflow reduces manual commands, avoids common mistakes,
# and keeps stack operations consistent for beginner users.
#
# What happens next:
# The code below validates inputs/environment, then executes the task logic,
# and returns status/output that other scripts or users can rely on.
############################################
*/

const QdrantNode = require("/usr/local/lib/node_modules/flowise/node_modules/flowise-components/dist/nodes/vectorstores/Qdrant/Qdrant.js").nodeClass;

async function main() {
  const embInstance = {
    embedQuery: async () => [],
    embedDocuments: async () => [],
  };

  const qdrant = new QdrantNode();
  const qdrantNodeData = {
    inputs: {
      embeddings: embInstance,
      qdrantServerUrl: "http://qdrant:6333",
      qdrantCollection: "pdf_documents",
      topK: 6,
      contentPayloadKey: "content",
      metadataPayloadKey: "metadata",
    },
    outputs: {
      output: "retriever",
    },
  };
  const out = await qdrant.init(qdrantNodeData, "", {});
  const hasInvoke = out && typeof out.invoke === "function";
  const hasPipe = out && typeof out.pipe === "function";
  console.log(JSON.stringify({ ctor: out?.constructor?.name, hasInvoke, hasPipe }, null, 2));
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
