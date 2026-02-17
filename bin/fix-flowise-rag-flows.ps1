$ErrorActionPreference = "Stop"

$ingestionId = "7ee5bbb5-d588-4de7-8723-5d95ed843216"
$qaId = "cc81ca95-c0f1-4ff6-b0b2-130be3d709c7"

$ingestionFlow = @{
    nodes = @(
        @{
            id = "pdf_0"
            type = "customNode"
            position = @{ x = 120; y = 120 }
            data = @{
                id = "pdf_0"
                label = "Pdf File"
                name = "pdfFile"
                version = 2
                type = "Document"
                category = "Document Loaders"
                baseClasses = @("Document")
                inputParams = @(
                    @{ id = "pdf_0-input-pdfFile-file"; name = "pdfFile"; label = "Pdf File"; type = "file"; fileType = ".pdf" },
                    @{
                        id = "pdf_0-input-usage-options"
                        name = "usage"
                        label = "Usage"
                        type = "options"
                        default = "perPage"
                        options = @(
                            @{ label = "One document per page"; name = "perPage" },
                            @{ label = "One document per file"; name = "perFile" }
                        )
                    },
                    @{ id = "pdf_0-input-legacyBuild-boolean"; name = "legacyBuild"; label = "Use Legacy Build"; type = "boolean"; optional = $true },
                    @{ id = "pdf_0-input-metadata-json"; name = "metadata"; label = "Additional Metadata"; type = "json"; optional = $true },
                    @{ id = "pdf_0-input-omitMetadataKeys-string"; name = "omitMetadataKeys"; label = "Omit Metadata Keys"; type = "string"; optional = $true }
                )
                inputAnchors = @(
                    @{ id = "pdf_0-input-textSplitter-TextSplitter"; name = "textSplitter"; label = "Text Splitter"; type = "TextSplitter"; optional = $true }
                )
                inputs = @{
                    usage = "perPage"
                    textSplitter = "{{split_0.data.instance}}"
                }
                outputAnchors = @(
                    @{
                        name = "output"
                        label = "Output"
                        type = "options"
                        default = "document"
                        options = @(
                            @{ id = "pdf_0-output-document-Document|json"; name = "document"; label = "Document"; type = "Document | json" },
                            @{ id = "pdf_0-output-text-string|json"; name = "text"; label = "Text"; type = "string | json" }
                        )
                    }
                )
                outputs = @{ output = "document" }
            }
            selected = $false
        },
        @{
            id = "split_0"
            type = "customNode"
            position = @{ x = 120; y = 320 }
            data = @{
                id = "split_0"
                label = "Recursive Character Text Splitter"
                name = "recursiveCharacterTextSplitter"
                version = 2
                type = "RecursiveCharacterTextSplitter"
                category = "Text Splitters"
                baseClasses = @("TextSplitter")
                inputParams = @(
                    @{ id = "split_0-input-chunkSize-number"; name = "chunkSize"; label = "Chunk Size"; type = "number"; default = 1000; optional = $true },
                    @{ id = "split_0-input-chunkOverlap-number"; name = "chunkOverlap"; label = "Chunk Overlap"; type = "number"; default = 200; optional = $true },
                    @{ id = "split_0-input-separators-string"; name = "separators"; label = "Custom Separators"; type = "string"; optional = $true }
                )
                inputAnchors = @()
                inputs = @{
                    chunkSize = 800
                    chunkOverlap = 120
                }
                outputAnchors = @(
                    @{ id = "split_0-output-recursiveCharacterTextSplitter-TextSplitter"; name = "recursiveCharacterTextSplitter"; label = "RecursiveCharacterTextSplitter"; type = "TextSplitter" }
                )
                outputs = @{}
            }
            selected = $false
        },
        @{
            id = "embed_0"
            type = "customNode"
            position = @{ x = 430; y = 320 }
            data = @{
                id = "embed_0"
                label = "Ollama Embeddings"
                name = "ollamaEmbedding"
                version = 1
                type = "OllamaEmbeddings"
                category = "Embeddings"
                baseClasses = @("Embeddings")
                inputParams = @(
                    @{ id = "embed_0-input-baseUrl-string"; name = "baseUrl"; label = "Base URL"; type = "string"; default = "http://localhost:11434" },
                    @{ id = "embed_0-input-modelName-string"; name = "modelName"; label = "Model Name"; type = "string" },
                    @{ id = "embed_0-input-numGpu-number"; name = "numGpu"; label = "Number of GPU"; type = "number"; optional = $true },
                    @{ id = "embed_0-input-numThread-number"; name = "numThread"; label = "Number of Thread"; type = "number"; optional = $true },
                    @{ id = "embed_0-input-useMMap-boolean"; name = "useMMap"; label = "Use MMap"; type = "boolean"; default = $true; optional = $true }
                )
                inputAnchors = @()
                inputs = @{
                    baseUrl = "http://ollama:11434"
                    modelName = "nomic-embed-text"
                }
                outputAnchors = @(
                    @{ id = "embed_0-output-ollamaEmbedding-Embeddings"; name = "ollamaEmbedding"; label = "OllamaEmbeddings"; type = "Embeddings" }
                )
                outputs = @{}
            }
            selected = $false
        },
        @{
            id = "qdrant_0"
            type = "customNode"
            position = @{ x = 760; y = 200 }
            data = @{
                id = "qdrant_0"
                label = "Qdrant"
                name = "qdrant"
                version = 5
                type = "Qdrant"
                category = "Vector Stores"
                baseClasses = @("Qdrant", "VectorStoreRetriever", "BaseRetriever")
                inputParams = @(
                    @{ id = "qdrant_0-input-qdrantServerUrl-string"; name = "qdrantServerUrl"; label = "Qdrant Server URL"; type = "string" },
                    @{ id = "qdrant_0-input-qdrantCollection-string"; name = "qdrantCollection"; label = "Qdrant Collection Name"; type = "string" },
                    @{ id = "qdrant_0-input-fileUpload-boolean"; name = "fileUpload"; label = "File Upload"; type = "boolean"; optional = $true },
                    @{ id = "qdrant_0-input-qdrantVectorDimension-number"; name = "qdrantVectorDimension"; label = "Vector Dimension"; type = "number"; default = 1536 },
                    @{ id = "qdrant_0-input-contentPayloadKey-string"; name = "contentPayloadKey"; label = "Content Key"; type = "string"; default = "content"; optional = $true },
                    @{ id = "qdrant_0-input-metadataPayloadKey-string"; name = "metadataPayloadKey"; label = "Metadata Key"; type = "string"; default = "metadata"; optional = $true },
                    @{ id = "qdrant_0-input-batchSize-number"; name = "batchSize"; label = "Upsert Batch Size"; type = "number"; optional = $true },
                    @{
                        id = "qdrant_0-input-qdrantSimilarity-options"
                        name = "qdrantSimilarity"
                        label = "Similarity"
                        type = "options"
                        default = "Cosine"
                        options = @(
                            @{ label = "Cosine"; name = "Cosine" },
                            @{ label = "Euclid"; name = "Euclid" },
                            @{ label = "Dot"; name = "Dot" }
                        )
                    },
                    @{ id = "qdrant_0-input-qdrantCollectionConfiguration-json"; name = "qdrantCollectionConfiguration"; label = "Additional Collection Cofiguration"; type = "json"; optional = $true },
                    @{ id = "qdrant_0-input-topK-number"; name = "topK"; label = "Top K"; type = "number"; optional = $true },
                    @{ id = "qdrant_0-input-qdrantFilter-json"; name = "qdrantFilter"; label = "Qdrant Search Filter"; type = "json"; optional = $true }
                )
                inputAnchors = @(
                    @{ id = "qdrant_0-input-document-Document"; name = "document"; label = "Document"; type = "Document"; list = $true; optional = $true },
                    @{ id = "qdrant_0-input-embeddings-Embeddings"; name = "embeddings"; label = "Embeddings"; type = "Embeddings" },
                    @{ id = "qdrant_0-input-recordManager-RecordManager"; name = "recordManager"; label = "Record Manager"; type = "RecordManager"; optional = $true }
                )
                inputs = @{
                    document = @("{{pdf_0.data.instance}}")
                    embeddings = "{{embed_0.data.instance}}"
                    qdrantServerUrl = "http://qdrant:6333"
                    qdrantCollection = "pdf_documents"
                    contentPayloadKey = "content"
                    metadataPayloadKey = "metadata"
                    qdrantSimilarity = "Cosine"
                }
                outputAnchors = @(
                    @{
                        name = "output"
                        label = "Output"
                        type = "options"
                        default = "retriever"
                        options = @(
                            @{ id = "qdrant_0-output-retriever-Qdrant|VectorStoreRetriever|BaseRetriever"; name = "retriever"; label = "Qdrant Retriever"; type = "Qdrant | VectorStoreRetriever | BaseRetriever" },
                            @{ id = "qdrant_0-output-vectorStore-Qdrant|VectorStore"; name = "vectorStore"; label = "Qdrant Vector Store"; type = "Qdrant | VectorStore" }
                        )
                    }
                )
                outputs = @{ output = "retriever" }
            }
            selected = $false
        }
    )
    edges = @(
        @{
            id = "e_split_pdf"
            source = "split_0"
            target = "pdf_0"
            sourceHandle = "split_0-output-recursiveCharacterTextSplitter-TextSplitter"
            targetHandle = "pdf_0-input-textSplitter-TextSplitter"
        },
        @{
            id = "e_pdf_qdrant"
            source = "pdf_0"
            target = "qdrant_0"
            sourceHandle = "pdf_0-output-document-Document|json"
            targetHandle = "qdrant_0-input-document-Document"
        },
        @{
            id = "e_embed_qdrant"
            source = "embed_0"
            target = "qdrant_0"
            sourceHandle = "embed_0-output-ollamaEmbedding-Embeddings"
            targetHandle = "qdrant_0-input-embeddings-Embeddings"
        }
    )
    viewport = @{ x = 0; y = 0; zoom = 1 }
}

$qaPrompt = @"
You are a strict retrieval QA assistant.
Use ONLY the provided context to answer the user question.
If the answer is not explicitly in the context, respond exactly with: dont know

Context:
{context}
"@

$qaFlow = @{
    nodes = @(
        @{
            id = "chat_0"
            type = "customNode"
            position = @{ x = 120; y = 120 }
            data = @{
                id = "chat_0"
                label = "ChatOllama"
                name = "chatOllama"
                version = 5
                type = "ChatOllama"
                category = "Chat Models"
                baseClasses = @("ChatOllama", "BaseChatModel", "BaseLanguageModel")
                inputParams = @(
                    @{ id = "chat_0-input-baseUrl-string"; name = "baseUrl"; label = "Base URL"; type = "string"; default = "http://localhost:11434" },
                    @{ id = "chat_0-input-modelName-string"; name = "modelName"; label = "Model Name"; type = "string" },
                    @{ id = "chat_0-input-temperature-number"; name = "temperature"; label = "Temperature"; type = "number"; optional = $true },
                    @{ id = "chat_0-input-streaming-boolean"; name = "streaming"; label = "Streaming"; type = "boolean"; optional = $true }
                )
                inputAnchors = @(
                    @{ id = "chat_0-input-cache-BaseCache"; name = "cache"; label = "Cache"; type = "BaseCache"; optional = $true }
                )
                inputs = @{
                    baseUrl = "http://ollama:11434"
                    modelName = "qwen:1.8b"
                    temperature = 0
                    streaming = $true
                }
                outputAnchors = @(
                    @{ id = "chat_0-output-chatOllama-ChatOllama|BaseChatModel|BaseLanguageModel"; name = "chatOllama"; label = "ChatOllama"; type = "ChatOllama | BaseChatModel | BaseLanguageModel" }
                )
                outputs = @{}
            }
            selected = $false
        },
        @{
            id = "embed_1"
            type = "customNode"
            position = @{ x = 120; y = 320 }
            data = @{
                id = "embed_1"
                label = "Ollama Embeddings"
                name = "ollamaEmbedding"
                version = 1
                type = "OllamaEmbeddings"
                category = "Embeddings"
                baseClasses = @("Embeddings")
                inputParams = @(
                    @{ id = "embed_1-input-baseUrl-string"; name = "baseUrl"; label = "Base URL"; type = "string"; default = "http://localhost:11434" },
                    @{ id = "embed_1-input-modelName-string"; name = "modelName"; label = "Model Name"; type = "string" }
                )
                inputAnchors = @()
                inputs = @{
                    baseUrl = "http://ollama:11434"
                    modelName = "nomic-embed-text"
                }
                outputAnchors = @(
                    @{ id = "embed_1-output-ollamaEmbedding-Embeddings"; name = "ollamaEmbedding"; label = "OllamaEmbeddings"; type = "Embeddings" }
                )
                outputs = @{}
            }
            selected = $false
        },
        @{
            id = "qdrant_1"
            type = "customNode"
            position = @{ x = 430; y = 240 }
            data = @{
                id = "qdrant_1"
                label = "Qdrant"
                name = "qdrant"
                version = 5
                type = "Qdrant"
                category = "Vector Stores"
                baseClasses = @("Qdrant", "VectorStoreRetriever", "BaseRetriever")
                inputParams = @(
                    @{ id = "qdrant_1-input-qdrantServerUrl-string"; name = "qdrantServerUrl"; label = "Qdrant Server URL"; type = "string" },
                    @{ id = "qdrant_1-input-qdrantCollection-string"; name = "qdrantCollection"; label = "Qdrant Collection Name"; type = "string" },
                    @{ id = "qdrant_1-input-contentPayloadKey-string"; name = "contentPayloadKey"; label = "Content Key"; type = "string"; default = "content"; optional = $true },
                    @{ id = "qdrant_1-input-metadataPayloadKey-string"; name = "metadataPayloadKey"; label = "Metadata Key"; type = "string"; default = "metadata"; optional = $true },
                    @{ id = "qdrant_1-input-topK-number"; name = "topK"; label = "Top K"; type = "number"; optional = $true }
                )
                inputAnchors = @(
                    @{ id = "qdrant_1-input-document-Document"; name = "document"; label = "Document"; type = "Document"; list = $true; optional = $true },
                    @{ id = "qdrant_1-input-embeddings-Embeddings"; name = "embeddings"; label = "Embeddings"; type = "Embeddings" }
                )
                inputs = @{
                    embeddings = "{{embed_1.data.instance}}"
                    qdrantServerUrl = "http://qdrant:6333"
                    qdrantCollection = "pdf_documents"
                    contentPayloadKey = "content"
                    metadataPayloadKey = "metadata"
                    topK = 6
                }
                outputAnchors = @(
                    @{
                        name = "output"
                        label = "Output"
                        type = "options"
                        default = "retriever"
                        options = @(
                            @{ id = "qdrant_1-output-retriever-Qdrant|VectorStoreRetriever|BaseRetriever"; name = "retriever"; label = "Qdrant Retriever"; type = "Qdrant | VectorStoreRetriever | BaseRetriever" },
                            @{ id = "qdrant_1-output-vectorStore-Qdrant|VectorStore"; name = "vectorStore"; label = "Qdrant Vector Store"; type = "Qdrant | VectorStore" }
                        )
                    }
                )
                outputs = @{ output = "retriever" }
            }
            selected = $false
        },
        @{
            id = "qa_0"
            type = "customNode"
            position = @{ x = 760; y = 180 }
            data = @{
                id = "qa_0"
                label = "Retrieval QA Chain"
                name = "retrievalQAChain"
                version = 2
                type = "RetrievalQAChain"
                category = "Chains"
                baseClasses = @("RetrievalQAChain")
                inputParams = @()
                inputAnchors = @(
                    @{ id = "qa_0-input-model-BaseLanguageModel"; name = "model"; label = "Language Model"; type = "BaseLanguageModel" },
                    @{ id = "qa_0-input-vectorStoreRetriever-BaseRetriever"; name = "vectorStoreRetriever"; label = "Vector Store Retriever"; type = "BaseRetriever" }
                )
                inputs = @{
                    model = "{{chat_0.data.instance}}"
                    vectorStoreRetriever = "{{qdrant_1.data.instance}}"
                    # Keep strict behavior hint in model context field for future UI adjustments.
                    systemNote = $qaPrompt
                }
                outputAnchors = @(
                    @{ id = "qa_0-output-retrievalQAChain-RetrievalQAChain"; name = "retrievalQAChain"; label = "RetrievalQAChain"; type = "RetrievalQAChain" }
                )
                outputs = @{}
            }
            selected = $false
        }
    )
    edges = @(
        @{
            id = "e_chat_qa"
            source = "chat_0"
            target = "qa_0"
            sourceHandle = "chat_0-output-chatOllama-ChatOllama|BaseChatModel|BaseLanguageModel"
            targetHandle = "qa_0-input-model-BaseLanguageModel"
        },
        @{
            id = "e_embed_qdrant"
            source = "embed_1"
            target = "qdrant_1"
            sourceHandle = "embed_1-output-ollamaEmbedding-Embeddings"
            targetHandle = "qdrant_1-input-embeddings-Embeddings"
        },
        @{
            id = "e_qdrant_qa"
            source = "qdrant_1"
            target = "qa_0"
            sourceHandle = "qdrant_1-output-retriever-Qdrant|VectorStoreRetriever|BaseRetriever"
            targetHandle = "qa_0-input-vectorStoreRetriever-BaseRetriever"
        }
    )
    viewport = @{ x = 0; y = 0; zoom = 1 }
}

$ingestionJson = $ingestionFlow | ConvertTo-Json -Depth 40 -Compress
$qaJson = $qaFlow | ConvertTo-Json -Depth 40 -Compress

$ingestionSqlSafe = $ingestionJson.Replace("'", "''")
$qaSqlSafe = $qaJson.Replace("'", "''")

$sqlPath = Join-Path $PSScriptRoot "tmp-flowise-flow-repair.sql"
$sql = @(
    "update chat_flow set flowData='$ingestionSqlSafe', updatedDate=datetime('now') where id='$ingestionId';"
    "update chat_flow set flowData='$qaSqlSafe', updatedDate=datetime('now') where id='$qaId';"
)
$sql -join "`n" | Set-Content -Path $sqlPath -Encoding UTF8

docker cp $sqlPath llm-stack-flowise-1:/tmp/flow-repair.sql
docker exec llm-stack-flowise-1 sh -lc "sqlite3 /root/.flowise/database.sqlite '.read /tmp/flow-repair.sql'"
docker exec llm-stack-flowise-1 sh -lc "sqlite3 /root/.flowise/database.sqlite 'select id,length(flowData) from chat_flow;'"

Remove-Item $sqlPath -Force
Write-Output "Flow repair updates applied."
