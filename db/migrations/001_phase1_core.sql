CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS chat;
CREATE SCHEMA IF NOT EXISTS prompting;
CREATE SCHEMA IF NOT EXISTS knowledge;
CREATE SCHEMA IF NOT EXISTS jobs;

CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE TABLE IF NOT EXISTS auth.users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  username varchar(64) NOT NULL,
  email varchar(254) NOT NULL,
  display_name varchar(128),
  status varchar(20) NOT NULL DEFAULT 'active',
  profile jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  last_login_at timestamptz,
  CONSTRAINT users_status_chk CHECK (status IN ('active', 'disabled', 'invited'))
);

CREATE UNIQUE INDEX IF NOT EXISTS users_username_uq ON auth.users (lower(username));
CREATE UNIQUE INDEX IF NOT EXISTS users_email_uq ON auth.users (lower(email));
CREATE INDEX IF NOT EXISTS users_status_idx ON auth.users (status);

DROP TRIGGER IF EXISTS trg_users_set_updated_at ON auth.users;
CREATE TRIGGER trg_users_set_updated_at
BEFORE UPDATE ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE IF NOT EXISTS chat.conversations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title text NOT NULL DEFAULT 'New Conversation',
  model_identifier text NOT NULL,
  system_prompt_snapshot text,
  status varchar(20) NOT NULL DEFAULT 'active',
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  last_message_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT conversations_status_chk CHECK (status IN ('active', 'archived', 'deleted'))
);

CREATE INDEX IF NOT EXISTS conversations_user_last_msg_idx ON chat.conversations (user_id, last_message_at DESC);
CREATE INDEX IF NOT EXISTS conversations_status_idx ON chat.conversations (status);
CREATE INDEX IF NOT EXISTS conversations_model_idx ON chat.conversations (model_identifier);

DROP TRIGGER IF EXISTS trg_conversations_set_updated_at ON chat.conversations;
CREATE TRIGGER trg_conversations_set_updated_at
BEFORE UPDATE ON chat.conversations
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE IF NOT EXISTS chat.messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id uuid NOT NULL REFERENCES chat.conversations(id) ON DELETE CASCADE,
  user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  role varchar(20) NOT NULL,
  content text NOT NULL,
  message_index integer NOT NULL,
  token_input integer,
  token_output integer,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT messages_role_chk CHECK (role IN ('system', 'user', 'assistant', 'tool')),
  CONSTRAINT messages_token_input_chk CHECK (token_input IS NULL OR token_input >= 0),
  CONSTRAINT messages_token_output_chk CHECK (token_output IS NULL OR token_output >= 0)
);

CREATE UNIQUE INDEX IF NOT EXISTS messages_conversation_index_uq ON chat.messages (conversation_id, message_index);
CREATE INDEX IF NOT EXISTS messages_conversation_created_idx ON chat.messages (conversation_id, created_at);
CREATE INDEX IF NOT EXISTS messages_role_idx ON chat.messages (role);

DROP TRIGGER IF EXISTS trg_messages_set_updated_at ON chat.messages;
CREATE TRIGGER trg_messages_set_updated_at
BEFORE UPDATE ON chat.messages
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE IF NOT EXISTS prompting.prompt_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name varchar(120) NOT NULL,
  description text,
  template_text text NOT NULL,
  kind varchar(20) NOT NULL DEFAULT 'general',
  is_shared boolean NOT NULL DEFAULT false,
  status varchar(20) NOT NULL DEFAULT 'active',
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT prompt_templates_kind_chk CHECK (kind IN ('system', 'assistant', 'general', 'tool')),
  CONSTRAINT prompt_templates_status_chk CHECK (status IN ('active', 'archived'))
);

CREATE UNIQUE INDEX IF NOT EXISTS prompt_templates_user_name_uq ON prompting.prompt_templates (user_id, lower(name));
CREATE INDEX IF NOT EXISTS prompt_templates_kind_idx ON prompting.prompt_templates (kind);
CREATE INDEX IF NOT EXISTS prompt_templates_shared_idx ON prompting.prompt_templates (is_shared);

DROP TRIGGER IF EXISTS trg_prompt_templates_set_updated_at ON prompting.prompt_templates;
CREATE TRIGGER trg_prompt_templates_set_updated_at
BEFORE UPDATE ON prompting.prompt_templates
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE IF NOT EXISTS knowledge.documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  collection_key varchar(120) NOT NULL DEFAULT 'default',
  title text NOT NULL,
  storage_uri text NOT NULL,
  mime_type varchar(120),
  sha256 char(64) NOT NULL,
  size_bytes bigint,
  ingestion_status varchar(20) NOT NULL DEFAULT 'pending',
  qdrant_collection varchar(120),
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  ingested_at timestamptz,
  CONSTRAINT documents_size_bytes_chk CHECK (size_bytes IS NULL OR size_bytes >= 0),
  CONSTRAINT documents_ingestion_status_chk CHECK (ingestion_status IN ('pending', 'processing', 'indexed', 'failed', 'deleted'))
);

CREATE UNIQUE INDEX IF NOT EXISTS documents_sha256_uq ON knowledge.documents (sha256);
CREATE INDEX IF NOT EXISTS documents_user_created_idx ON knowledge.documents (user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS documents_ingestion_status_idx ON knowledge.documents (ingestion_status);
CREATE INDEX IF NOT EXISTS documents_collection_idx ON knowledge.documents (collection_key);

DROP TRIGGER IF EXISTS trg_documents_set_updated_at ON knowledge.documents;
CREATE TRIGGER trg_documents_set_updated_at
BEFORE UPDATE ON knowledge.documents
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE IF NOT EXISTS jobs.jobs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  job_type varchar(50) NOT NULL,
  status varchar(20) NOT NULL DEFAULT 'queued',
  priority smallint NOT NULL DEFAULT 100,
  requested_by_user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  document_id uuid REFERENCES knowledge.documents(id) ON DELETE SET NULL,
  payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  result jsonb NOT NULL DEFAULT '{}'::jsonb,
  attempt_count integer NOT NULL DEFAULT 0,
  max_attempts integer NOT NULL DEFAULT 3,
  scheduled_at timestamptz NOT NULL DEFAULT now(),
  started_at timestamptz,
  finished_at timestamptz,
  last_error text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT jobs_status_chk CHECK (status IN ('queued', 'running', 'succeeded', 'failed', 'cancelled')),
  CONSTRAINT jobs_attempt_count_chk CHECK (attempt_count >= 0),
  CONSTRAINT jobs_max_attempts_chk CHECK (max_attempts >= 1)
);

CREATE INDEX IF NOT EXISTS jobs_queue_scan_idx ON jobs.jobs (status, priority, scheduled_at);
CREATE INDEX IF NOT EXISTS jobs_type_idx ON jobs.jobs (job_type);
CREATE INDEX IF NOT EXISTS jobs_requested_by_idx ON jobs.jobs (requested_by_user_id);
CREATE INDEX IF NOT EXISTS jobs_document_idx ON jobs.jobs (document_id);

DROP TRIGGER IF EXISTS trg_jobs_set_updated_at ON jobs.jobs;
CREATE TRIGGER trg_jobs_set_updated_at
BEFORE UPDATE ON jobs.jobs
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
