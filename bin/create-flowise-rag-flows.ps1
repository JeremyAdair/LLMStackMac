[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$headers = @{ Host = 'flowise.llmstack.lan'; 'x-request-from' = 'internal' }
$flowiseEmail = $env:FLOWISE_ADMIN_EMAIL
$flowisePassword = $env:FLOWISE_ADMIN_PASSWORD

if ([string]::IsNullOrWhiteSpace($flowiseEmail) -or [string]::IsNullOrWhiteSpace($flowisePassword)) {
    throw "Set FLOWISE_ADMIN_EMAIL and FLOWISE_ADMIN_PASSWORD before running this script."
}

$loginBody = @{ email = $flowiseEmail; password = $flowisePassword } | ConvertTo-Json -Compress
Invoke-WebRequest -Method Post -Uri 'https://127.0.0.1/api/v1/auth/login' -Headers $headers -WebSession $session -ContentType 'application/json' -Body $loginBody | Out-Null

$existing = Invoke-RestMethod -Method Get -Uri 'https://127.0.0.1/api/v1/chatflows' -Headers $headers -WebSession $session
$toDeleteNames = @('tmp', 'PDF Ingestion - Qdrant', 'PDF Retrieval QA - Qdrant')
foreach ($f in $existing) {
    if ($toDeleteNames -contains $f.name) {
        Invoke-RestMethod -Method Delete -Uri ("https://127.0.0.1/api/v1/chatflows/{0}" -f $f.id) -Headers $headers -WebSession $session | Out-Null
    }
}

$ingestionFlowData = @{
    nodes = @(
        @{
            id       = 'pdf_1'
            type     = 'customNode'
            position = @{ x = 120; y = 120 }
            data     = @{
                id       = 'pdfFile'
                label    = 'Pdf File'
                name     = 'pdfFile'
                version  = 2
                type     = 'Document'
                category = 'Document Loaders'
                inputs   = @{
                    usage = 'perPage'
                }
            }
        },
        @{
            id       = 'split_1'
            type     = 'customNode'
            position = @{ x = 120; y = 320 }
            data     = @{
                id       = 'recursiveCharacterTextSplitter'
                label    = 'Recursive Character Text Splitter'
                name     = 'recursiveCharacterTextSplitter'
                version  = 2
                type     = 'RecursiveCharacterTextSplitter'
                category = 'Text Splitters'
                inputs   = @{
                    chunkSize    = 800
                    chunkOverlap = 120
                }
            }
        },
        @{
            id       = 'embed_1'
            type     = 'customNode'
            position = @{ x = 430; y = 320 }
            data     = @{
                id       = 'ollamaEmbedding'
                label    = 'Ollama Embeddings'
                name     = 'ollamaEmbedding'
                version  = 1
                type     = 'OllamaEmbeddings'
                category = 'Embeddings'
                inputs   = @{
                    baseUrl   = 'http://ollama:11434'
                    modelName = 'nomic-embed-text'
                }
            }
        },
        @{
            id       = 'qdrant_1'
            type     = 'customNode'
            position = @{ x = 760; y = 200 }
            data     = @{
                id       = 'qdrant'
                label    = 'Qdrant'
                name     = 'qdrant'
                version  = 5
                type     = 'Qdrant'
                category = 'Vector Stores'
                inputs   = @{
                    qdrantServerUrl    = 'http://qdrant:6333'
                    qdrantCollection   = 'pdf_documents'
                    contentPayloadKey  = 'content'
                    metadataPayloadKey = 'metadata'
                }
            }
        }
    )
    edges = @(
        @{ id = 'e_split_pdf'; source = 'split_1'; target = 'pdf_1'; sourceHandle = 'textSplitter'; targetHandle = 'textSplitter' },
        @{ id = 'e_pdf_qdrant'; source = 'pdf_1'; target = 'qdrant_1'; sourceHandle = 'document'; targetHandle = 'document' },
        @{ id = 'e_embed_qdrant'; source = 'embed_1'; target = 'qdrant_1'; sourceHandle = 'embeddings'; targetHandle = 'embeddings' }
    )
    viewport = @{ x = 0; y = 0; zoom = 1 }
}

$qaPrompt = @'
You are a strict retrieval QA assistant.
Use ONLY the provided context to answer the user question.
If the answer is not explicitly in the context, respond exactly with: dont know

Context:
{context}
'@

$qaFlowData = @{
    nodes = @(
        @{
            id       = 'chat_1'
            type     = 'customNode'
            position = @{ x = 120; y = 120 }
            data     = @{
                id       = 'chatOllama'
                label    = 'ChatOllama'
                name     = 'chatOllama'
                version  = 5
                type     = 'ChatOllama'
                category = 'Chat Models'
                inputs   = @{
                    baseUrl     = 'http://ollama:11434'
                    modelName   = 'qwen:1.8b'
                    temperature = 0
                }
            }
        },
        @{
            id       = 'embed_2'
            type     = 'customNode'
            position = @{ x = 120; y = 320 }
            data     = @{
                id       = 'ollamaEmbedding'
                label    = 'Ollama Embeddings'
                name     = 'ollamaEmbedding'
                version  = 1
                type     = 'OllamaEmbeddings'
                category = 'Embeddings'
                inputs   = @{
                    baseUrl   = 'http://ollama:11434'
                    modelName = 'nomic-embed-text'
                }
            }
        },
        @{
            id       = 'qdrant_2'
            type     = 'customNode'
            position = @{ x = 430; y = 240 }
            data     = @{
                id       = 'qdrant'
                label    = 'Qdrant'
                name     = 'qdrant'
                version  = 5
                type     = 'Qdrant'
                category = 'Vector Stores'
                inputs   = @{
                    qdrantServerUrl    = 'http://qdrant:6333'
                    qdrantCollection   = 'pdf_documents'
                    topK               = 6
                    contentPayloadKey  = 'content'
                    metadataPayloadKey = 'metadata'
                }
            }
        },
        @{
            id       = 'qa_1'
            type     = 'customNode'
            position = @{ x = 760; y = 180 }
            data     = @{
                id       = 'conversationalRetrievalQAChain'
                label    = 'Conversational Retrieval QA Chain'
                name     = 'conversationalRetrievalQAChain'
                version  = 3
                type     = 'ConversationalRetrievalQAChain'
                category = 'Chains'
                inputs   = @{
                    returnSourceDocuments = $true
                    responsePrompt        = $qaPrompt
                }
            }
        }
    )
    edges = @(
        @{ id = 'e_chat_qa'; source = 'chat_1'; target = 'qa_1'; sourceHandle = 'model'; targetHandle = 'model' },
        @{ id = 'e_embed_qdrant2'; source = 'embed_2'; target = 'qdrant_2'; sourceHandle = 'embeddings'; targetHandle = 'embeddings' },
        @{ id = 'e_qdrant_qa'; source = 'qdrant_2'; target = 'qa_1'; sourceHandle = 'retriever'; targetHandle = 'vectorStoreRetriever' }
    )
    viewport = @{ x = 0; y = 0; zoom = 1 }
}

$createPayloads = @(
    @{ name = 'PDF Ingestion - Qdrant'; type = 'CHATFLOW'; flowData = ($ingestionFlowData | ConvertTo-Json -Depth 30 -Compress) },
    @{ name = 'PDF Retrieval QA - Qdrant'; type = 'CHATFLOW'; flowData = ($qaFlowData | ConvertTo-Json -Depth 30 -Compress) }
)

$created = @()
foreach ($p in $createPayloads) {
    $body = $p | ConvertTo-Json -Depth 30 -Compress
    $created += Invoke-RestMethod -Method Post -Uri 'https://127.0.0.1/api/v1/chatflows' -Headers $headers -WebSession $session -ContentType 'application/json' -Body $body
}

$verify = Invoke-RestMethod -Method Get -Uri 'https://127.0.0.1/api/v1/chatflows' -Headers $headers -WebSession $session
$verify | Where-Object { $_.name -in @('PDF Ingestion - Qdrant', 'PDF Retrieval QA - Qdrant') } |
    Select-Object id, name, type, updatedDate |
    ConvertTo-Json -Depth 10
