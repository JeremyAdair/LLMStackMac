CREATE SCHEMA IF NOT EXISTS agents;
CREATE SCHEMA IF NOT EXISTS tools;
CREATE SCHEMA IF NOT EXISTS memory;

CREATE TABLE IF NOT EXISTS tools.tools (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tool_key varchar(100) NOT NULL,
  display_name text NOT NULL,
  description text,
  endpoint text,
  config jsonb NOT NULL DEFAULT '{}'::jsonb,
  is_enabled boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS tools_tool_key_uq ON tools.tools (tool_key);
CREATE INDEX IF NOT EXISTS tools_enabled_idx ON tools.tools (is_enabled);
DROP TRIGGER IF EXISTS trg_tools_set_updated_at ON tools.tools;
CREATE TRIGGER trg_tools_set_updated_at
BEFORE UPDATE ON tools.tools
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE IF NOT EXISTS tools.tool_permissions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tool_id uuid NOT NULL REFERENCES tools.tools(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  permission varchar(20) NOT NULL DEFAULT 'use',
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT tool_permissions_perm_chk CHECK (permission IN ('use', 'admin'))
);

CREATE UNIQUE INDEX IF NOT EXISTS tool_permissions_user_tool_uq ON tools.tool_permissions (tool_id, user_id);

CREATE TABLE IF NOT EXISTS agents.workflows (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name varchar(160) NOT NULL,
  description text,
  definition jsonb NOT NULL DEFAULT '{}'::jsonb,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS workflows_user_name_uq ON agents.workflows (user_id, lower(name));
CREATE INDEX IF NOT EXISTS workflows_active_idx ON agents.workflows (is_active);
DROP TRIGGER IF EXISTS trg_workflows_set_updated_at ON agents.workflows;
CREATE TRIGGER trg_workflows_set_updated_at
BEFORE UPDATE ON agents.workflows
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE IF NOT EXISTS agents.workflow_runs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workflow_id uuid NOT NULL REFERENCES agents.workflows(id) ON DELETE CASCADE,
  triggered_by_user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  status varchar(20) NOT NULL DEFAULT 'queued',
  input_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  output_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  job_id uuid REFERENCES jobs.jobs(id) ON DELETE SET NULL,
  started_at timestamptz,
  finished_at timestamptz,
  error_text text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT workflow_runs_status_chk CHECK (status IN ('queued', 'running', 'succeeded', 'failed', 'cancelled'))
);

CREATE INDEX IF NOT EXISTS workflow_runs_workflow_idx ON agents.workflow_runs (workflow_id, created_at DESC);
CREATE INDEX IF NOT EXISTS workflow_runs_status_idx ON agents.workflow_runs (status);
DROP TRIGGER IF EXISTS trg_workflow_runs_set_updated_at ON agents.workflow_runs;
CREATE TRIGGER trg_workflow_runs_set_updated_at
BEFORE UPDATE ON agents.workflow_runs
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE IF NOT EXISTS memory.memory_entries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  conversation_id uuid REFERENCES chat.conversations(id) ON DELETE SET NULL,
  source_message_id uuid REFERENCES chat.messages(id) ON DELETE SET NULL,
  memory_type varchar(40) NOT NULL DEFAULT 'fact',
  content text NOT NULL,
  salience smallint NOT NULL DEFAULT 50,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT memory_entries_salience_chk CHECK (salience BETWEEN 0 AND 100)
);

CREATE INDEX IF NOT EXISTS memory_entries_user_idx ON memory.memory_entries (user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS memory_entries_type_idx ON memory.memory_entries (memory_type);
DROP TRIGGER IF EXISTS trg_memory_entries_set_updated_at ON memory.memory_entries;
CREATE TRIGGER trg_memory_entries_set_updated_at
BEFORE UPDATE ON memory.memory_entries
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
