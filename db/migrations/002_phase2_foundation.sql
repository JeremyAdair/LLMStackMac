CREATE SCHEMA IF NOT EXISTS models;
CREATE SCHEMA IF NOT EXISTS observability;

CREATE TABLE IF NOT EXISTS chat.message_metadata (
  message_id uuid PRIMARY KEY REFERENCES chat.messages(id) ON DELETE CASCADE,
  citations jsonb NOT NULL DEFAULT '[]'::jsonb,
  tool_calls jsonb NOT NULL DEFAULT '[]'::jsonb,
  safety_flags jsonb NOT NULL DEFAULT '{}'::jsonb,
  latency_ms integer,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

DROP TRIGGER IF EXISTS trg_message_metadata_set_updated_at ON chat.message_metadata;
CREATE TRIGGER trg_message_metadata_set_updated_at
BEFORE UPDATE ON chat.message_metadata
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE IF NOT EXISTS chat.conversation_summaries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id uuid NOT NULL REFERENCES chat.conversations(id) ON DELETE CASCADE,
  summary_text text NOT NULL,
  summary_until_message_index integer,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS conversation_summaries_conversation_idx ON chat.conversation_summaries (conversation_id, created_at DESC);
DROP TRIGGER IF EXISTS trg_conversation_summaries_set_updated_at ON chat.conversation_summaries;
CREATE TRIGGER trg_conversation_summaries_set_updated_at
BEFORE UPDATE ON chat.conversation_summaries
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE IF NOT EXISTS prompting.prompt_versions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  prompt_template_id uuid NOT NULL REFERENCES prompting.prompt_templates(id) ON DELETE CASCADE,
  version_number integer NOT NULL,
  template_text text NOT NULL,
  change_note text,
  created_by_user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT prompt_versions_version_number_chk CHECK (version_number > 0)
);

CREATE UNIQUE INDEX IF NOT EXISTS prompt_versions_template_version_uq ON prompting.prompt_versions (prompt_template_id, version_number);

CREATE TABLE IF NOT EXISTS models.model_registry (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  model_identifier text NOT NULL,
  provider varchar(50) NOT NULL DEFAULT 'ollama',
  display_name text NOT NULL,
  family text,
  context_window integer,
  is_active boolean NOT NULL DEFAULT true,
  capabilities jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS model_registry_identifier_uq ON models.model_registry (model_identifier);
CREATE INDEX IF NOT EXISTS model_registry_active_idx ON models.model_registry (is_active);
DROP TRIGGER IF EXISTS trg_model_registry_set_updated_at ON models.model_registry;
CREATE TRIGGER trg_model_registry_set_updated_at
BEFORE UPDATE ON models.model_registry
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE IF NOT EXISTS knowledge.document_collections (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  collection_key varchar(120) NOT NULL,
  display_name text NOT NULL,
  description text,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS document_collections_user_key_uq ON knowledge.document_collections (user_id, collection_key);
DROP TRIGGER IF EXISTS trg_document_collections_set_updated_at ON knowledge.document_collections;
CREATE TRIGGER trg_document_collections_set_updated_at
BEFORE UPDATE ON knowledge.document_collections
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE IF NOT EXISTS knowledge.chunks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id uuid NOT NULL REFERENCES knowledge.documents(id) ON DELETE CASCADE,
  chunk_index integer NOT NULL,
  content text NOT NULL,
  token_count integer,
  char_start integer,
  char_end integer,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT chunks_chunk_index_chk CHECK (chunk_index >= 0)
);

CREATE UNIQUE INDEX IF NOT EXISTS chunks_document_index_uq ON knowledge.chunks (document_id, chunk_index);
CREATE INDEX IF NOT EXISTS chunks_document_idx ON knowledge.chunks (document_id);
DROP TRIGGER IF EXISTS trg_chunks_set_updated_at ON knowledge.chunks;
CREATE TRIGGER trg_chunks_set_updated_at
BEFORE UPDATE ON knowledge.chunks
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE IF NOT EXISTS knowledge.chunk_vector_refs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  chunk_id uuid NOT NULL REFERENCES knowledge.chunks(id) ON DELETE CASCADE,
  vector_db varchar(30) NOT NULL DEFAULT 'qdrant',
  vector_collection varchar(120) NOT NULL,
  vector_point_id text NOT NULL,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS chunk_vector_refs_point_uq ON knowledge.chunk_vector_refs (vector_db, vector_collection, vector_point_id);
CREATE INDEX IF NOT EXISTS chunk_vector_refs_chunk_idx ON knowledge.chunk_vector_refs (chunk_id);
DROP TRIGGER IF EXISTS trg_chunk_vector_refs_set_updated_at ON knowledge.chunk_vector_refs;
CREATE TRIGGER trg_chunk_vector_refs_set_updated_at
BEFORE UPDATE ON knowledge.chunk_vector_refs
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE IF NOT EXISTS observability.inference_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  conversation_id uuid REFERENCES chat.conversations(id) ON DELETE SET NULL,
  message_id uuid REFERENCES chat.messages(id) ON DELETE SET NULL,
  model_identifier text,
  provider varchar(50),
  status varchar(20) NOT NULL DEFAULT 'ok',
  latency_ms integer,
  token_input integer,
  token_output integer,
  error_text text,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT inference_events_status_chk CHECK (status IN ('ok', 'error', 'timeout', 'cancelled'))
);

CREATE INDEX IF NOT EXISTS inference_events_created_idx ON observability.inference_events (created_at DESC);
CREATE INDEX IF NOT EXISTS inference_events_model_idx ON observability.inference_events (model_identifier);
CREATE INDEX IF NOT EXISTS inference_events_conversation_idx ON observability.inference_events (conversation_id);
