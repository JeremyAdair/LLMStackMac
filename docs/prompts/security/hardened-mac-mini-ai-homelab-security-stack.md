PROJECT: Hardened Mac Mini AI Homelab Security Stack

SYSTEM

Host machine:
Mac Mini (Apple Silicon)

Operating system:
macOS

Container runtime:
Docker Desktop

Primary project directory:

~/llmstackmac

Workloads running on this system:

* Ollama
* OpenWebUI
* Flowise
* AI agents
* Prometheus
* Grafana

This environment is a Docker-based homelab, NOT Kubernetes.

The goal is to build a hardened AI homelab security stack providing:

1. Host intrusion detection
2. Container vulnerability scanning
3. Supply chain verification
4. Network attack detection
5. AI prompt injection protection
6. Safe execution of AI-generated code
7. Observability integration
8. Hardened container configuration

---

WAZUH-LIKE HOST MONITORING

macOS does not support Linux kernel security tools like Falco.

Instead, the host intrusion detection layer will use:

osquery
Santa
LuLu
KnockKnock

These tools provide a macOS equivalent to Wazuh-style monitoring.

Capabilities provided:

osquery

* query system state
* detect persistence changes
* monitor processes
* detect unauthorized configuration changes

Santa

* binary allowlisting
* detect unauthorized executables
* prevent malware execution

LuLu

* outbound network monitoring

KnockKnock

* persistence detection

---

CODEX AUTONOMY POLICY

Codex is allowed to maintain and extend this security stack.

Codex MAY:

* modify docker compose files
* install or update containers
* modify scanning scripts
* update AI guardrails
* add observability integrations
* update security documentation
* automate vulnerability scanning

Codex MUST NOT:

* disable LuLu firewall
* disable Santa binary protection
* disable osquery monitoring
* expose docker.sock to AI agents
* expose secrets to AI models
* run AI-generated code directly on the macOS host

Codex should treat this stack as security-critical infrastructure.

---

TOOLS TO INSTALL

HOST (macOS)

osquery
Santa
LuLu
KnockKnock
Trivy
Syft
Grype
Cosign

CONTAINERS

CrowdSec
NeMo Guardrails

OBSERVABILITY

Prometheus
Grafana

---

STEP 1 — Install Homebrew

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew update

---

STEP 2 — Install host intrusion detection tools

brew install osquery

brew install santa

brew install --cask lulu

brew install --cask knockknock

---

STEP 3 — Install container security tools

brew install trivy
brew install syft
brew install grype
brew install cosign

brew install jq
brew install yq

---

STEP 4 — Create security workspace

mkdir -p ~/llmstackmac/security
mkdir -p ~/llmstackmac/security/scripts
mkdir -p ~/llmstackmac/security/reports
mkdir -p ~/llmstackmac/security/docs
mkdir -p ~/llmstackmac/security/crowdsec
mkdir -p ~/llmstackmac/security/guardrails

---

STEP 5 — Container vulnerability scanning

Create script:

~/llmstackmac/security/scripts/scan-images.sh

Script behavior:

* list docker images
* scan with trivy
* generate SBOM using syft
* scan SBOM using grype
* store reports

Example logic:

images=$(docker images --format "{{.Repository}}:{{.Tag}}")

for image in $images
do
safe=$(echo $image | tr '/:' '_')

trivy image $image > ~/llmstackmac/security/reports/trivy-$safe.txt

syft $image > ~/llmstackmac/security/reports/sbom-$safe.txt

grype $image > ~/llmstackmac/security/reports/grype-$safe.txt

done

chmod +x ~/llmstackmac/security/scripts/scan-images.sh

Codex may expand this automation.

---

STEP 6 — Container image signing

Create:

~/llmstackmac/security/docs/cosign-workflow.md

Document:

cosign sign image
cosign verify image

---

STEP 7 — Deploy CrowdSec container

Create:

~/llmstackmac/security/crowdsec/docker-compose.yml

version: "3"

services:

crowdsec:
image: crowdsecurity/crowdsec
container_name: crowdsec
volumes:
- ./config:/etc/crowdsec
- ./data:/var/lib/crowdsec/data
- /var/log:/var/log:ro
ports:
- "8080:8080"
restart: unless-stopped

docker compose up -d

---

STEP 8 — Install AI guardrails

cd ~/llmstackmac/security/guardrails

python3 -m venv .venv

source .venv/bin/activate

pip install nemoguardrails

Create:

~/llmstackmac/security/guardrails/policies.md

Include rules:

block prompt injection
deny shell execution
restrict filesystem access
require container sandbox for generated code

---

STEP 9 — AI execution sandbox

AI-generated code must never run directly on macOS.

Workflow:

AI generates code
→ temporary docker container created
→ code executed
→ container destroyed

Docker socket must never be exposed to AI agents.

---

STEP 10 — Container hardening

Create:

~/llmstackmac/security/docs/container-hardening.md

Recommended settings:

--read-only
--cap-drop ALL
--security-opt=no-new-privileges
--pids-limit=100

Avoid:

--privileged
docker.sock mounts
root containers

---

FINAL SECURITY STACK

Host layer

osquery
Santa
LuLu
KnockKnock
Trivy
Syft
Grype
Cosign

Container layer

CrowdSec
NeMo Guardrails

AI services

Ollama
OpenWebUI
Flowise

Observability

Prometheus
Grafana

Codex is allowed to maintain and extend this stack while preserving security controls.

END PROMPT
