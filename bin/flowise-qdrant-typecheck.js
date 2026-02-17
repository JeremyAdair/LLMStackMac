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
